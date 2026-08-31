--[[
	DataService
	Responsável por carregar, manter em memória e salvar o PlayerData de
	cada jogador. Cobre a pós-condição do UC01 ("PlayerData criado/carregado")
	e serve de base persistente para UC02 (Gold/Eggs) e UC03 (Dragons).

	Server-authoritative: nenhuma escrita em PlayerData deve ocorrer fora
	deste módulo (os demais serviços leem/escrevem através das funções
	expostas aqui).
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)

local DataService = {}

local playerDataStore = DataStoreService:GetDataStore("DragonFarmer_PlayerData_v1")

-- Cache em memória: [Player] = PlayerData
local sessionData: { [Player]: any } = {}

-- Retorna um PlayerData novo com os valores padrão do MVP.
local function createDefaultData()
	return {
		Gold = GameConfig.StartingGold,
		Essence = 0,
		Ascensions = 0,
		Eggs = 0,
		Dragons = {},
		DiscoveredDragons = {},
		PurchaseLevel = 1,
		TowerLevel = 1,
		Upgrades = {},
		DailyReward = { Day = 1, LastClaim = 0 },
		Playtime = 0,
		Settings = {},
		HasReceivedStarterEgg = false,
	}
end

-- Preenche campos ausentes em dados antigos carregados do DataStore com os
-- valores padrão atuais, para tolerar evolução do schema entre versões.
local function reconcileWithDefaults(data)
	local defaults = createDefaultData()
	for key, defaultValue in defaults do
		if data[key] == nil then
			data[key] = defaultValue
		end
	end
	return data
end

-- UC01 (pós-condição): carrega o PlayerData do DataStore, ou cria um novo
-- caso o jogador seja novo. Deve ser chamado uma única vez por sessão,
-- antes de qualquer outro serviço acessar os dados do jogador.
function DataService.Load(player: Player)
	local key = "Player_" .. player.UserId
	local success, result = pcall(function()
		return playerDataStore:GetAsync(key)
	end)

	local data
	if success and result then
		data = reconcileWithDefaults(result)
	else
		data = createDefaultData()
	end

	sessionData[player] = data
	return data
end

-- Retorna o PlayerData em memória do jogador (deve já ter sido carregado
-- via DataService.Load). Retorna nil se o jogador ainda não foi carregado.
function DataService.Get(player: Player)
	return sessionData[player]
end

-- Persiste o PlayerData do jogador no DataStore.
function DataService.Save(player: Player)
	local data = sessionData[player]
	if not data then
		return false
	end

	local key = "Player_" .. player.UserId
	local success, err = pcall(function()
		playerDataStore:SetAsync(key, data)
	end)

	if not success then
		warn(("[DataService] Falha ao salvar dados de %s: %s"):format(player.Name, tostring(err)))
	end

	return success
end

-- Remove os dados do jogador da memória (chamado ao sair do jogo, após Save).
function DataService.Release(player: Player)
	sessionData[player] = nil
end

Players.PlayerRemoving:Connect(function(player)
	DataService.Save(player)
	DataService.Release(player)
end)

game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		DataService.Save(player)
	end
end)

return DataService
