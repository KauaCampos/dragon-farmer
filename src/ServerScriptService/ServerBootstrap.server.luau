--[[
	ServerBootstrap
	Ponto de entrada do servidor. Cria os Remotes, conecta o fluxo de entrada
	do jogador (UC01) e expõe os endpoints de UC02 (BuyEggs) e UC03 (HatchEgg)
	para o cliente via RemoteFunction.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemotesSetup = require(ReplicatedStorage.Remotes.RemotesSetup)

local DataService = require(script.Parent.Services.DataService)
local EggService = require(script.Parent.Services.EggService)
local DragonService = require(script.Parent.Services.DragonService)
local FarmService = require(script.Parent.Services.FarmService)

local Remotes = RemotesSetup.Init(ReplicatedStorage)

-- Envia ao cliente um resumo do PlayerData relevante para a HUD.
local function pushPlayerDataUpdate(player: Player)
	local data = DataService.Get(player)
	if not data then
		return
	end

	Remotes.PlayerDataUpdated:FireClient(player, {
		Gold = data.Gold,
		Eggs = data.Eggs,
		DragonCount = (function()
			local count = 0
			for _ in data.Dragons do
				count += 1
			end
			return count
		end)(),
	})
end

-- UC01: Jogador entra no servidor -> PlayerData é carregado/criado ->
-- recebe Free Dragon Egg -> é guiado até sua base.
local function onPlayerAdded(player: Player)
	DataService.Load(player)

	local receivedStarterEgg = EggService.GrantStarterEggIfNeeded(player)

	player.CharacterAdded:Connect(function()
		FarmService.CreateFarm(player)
	end)

	if player.Character then
		FarmService.CreateFarm(player)
	end

	if receivedStarterEgg then
		Remotes.EggReceived:FireClient(player, { EggId = "free_dragon_egg" })
	end

	pushPlayerDataUpdate(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)

-- Cobre jogadores já conectados caso este script seja recarregado em testes.
for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

-- UC02: Jogador interage com pad de compra -> escolhe quantidade -> servidor
-- valida Gold -> debita Gold -> adiciona ovos ao inventário.
Remotes.BuyEggs.OnServerInvoke = function(player: Player, amount: number)
	if typeof(amount) ~= "number" then
		return { Success = false, Reason = "InvalidAmount" }
	end

	local result = EggService.BuyEggs(player, amount)

	if result.Success then
		pushPlayerDataUpdate(player)
	end

	return result
end

-- UC03: Jogador usa um ovo na incubadora -> sorteio de espécie/raridade/
-- mutação -> dragão criado e adicionado à base -> Dragon Index atualizado
-- se aplicável -> cliente recebe evento para animação especial.
Remotes.HatchEgg.OnServerInvoke = function(player: Player)
	local result = DragonService.Hatch(player)

	if result.Success then
		Remotes.DragonHatched:FireClient(player, {
			Dragon = result.Dragon,
			IsNewSpecies = result.IsNewSpecies,
		})
		pushPlayerDataUpdate(player)
	end

	return result
end

print("[ServerBootstrap] Dragon Farmer server inicializado (UC01, UC02, UC03).")
