--[[
	DragonService
	Cobre UC03 — Chocar ovo (Hatch): consome 1 ovo do inventário do jogador,
	sorteia espécie/raridade/mutação conforme as tabelas de GameConfig, cria
	o dragão e o adiciona à base do jogador. Caso a espécie seja inédita para
	aquele jogador, atualiza o Dragon Index (data.DiscoveredDragons).

	Também expõe Create/Remove/Get para uso genérico por outros sistemas
	(ex.: Merge, futuramente).
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
local Rarity = require(ReplicatedStorage.Shared.Modules.Rarity)
local DataService = require(ServerScriptService.Services.DataService)

local DragonService = {}

-- Cria e registra um dragão no PlayerData do jogador (sem verificar ovos —
-- uso interno/genérico; UC03 usa DragonService.Hatch, que consome o ovo).
function DragonService.Create(player: Player, speciesId: string, tier: number, name: string, rarity: string, mutation: string)
	local data = DataService.Get(player)
	if not data then
		return nil
	end

	local dragon = {
		Id = HttpService:GenerateGUID(false),
		SpeciesId = speciesId,
		Name = name,
		Tier = tier,
		Rarity = rarity,
		Mutation = mutation,
		Level = 1,
		CreatedAt = os.time(),
	}

	data.Dragons[dragon.Id] = dragon

	return dragon
end

-- Remove um dragão do PlayerData pelo Id (usado futuramente por Merge, UC06).
function DragonService.Remove(player: Player, dragonId: string): boolean
	local data = DataService.Get(player)
	if not data then
		return false
	end

	if not data.Dragons[dragonId] then
		return false
	end

	data.Dragons[dragonId] = nil
	return true
end

-- Retorna os dados de um dragão específico do jogador, ou nil se não existir.
function DragonService.Get(player: Player, dragonId: string)
	local data = DataService.Get(player)
	if not data then
		return nil
	end
	return data.Dragons[dragonId]
end

export type HatchResult = {
	Success: boolean,
	Reason: string?,
	Dragon: any?,
	IsNewSpecies: boolean?,
	EggsRemaining: number?,
}

-- UC03: usa 1 ovo do inventário do jogador para chocar um novo dragão.
-- Fluxo: valida que o jogador tem >= 1 ovo -> valida limite de slots da
-- base -> sorteia espécie, raridade e mutação -> debita 1 ovo -> cria o
-- dragão -> atualiza o Dragon Index se a espécie for inédita.
function DragonService.Hatch(player: Player): HatchResult
	local data = DataService.Get(player)
	if not data then
		return { Success = false, Reason = "NoPlayerData" }
	end

	if data.Eggs < 1 then
		return { Success = false, Reason = "NoEggs" }
	end

	local dragonCount = 0
	for _ in data.Dragons do
		dragonCount += 1
	end

	if dragonCount >= GameConfig.MaxDragonsPerPlayer then
		return { Success = false, Reason = "BaseFull" }
	end

	-- Sorteio (UC03: "sistema sorteia espécie/raridade/mutação conforme
	-- tabelas configuradas").
	local species = Rarity.WeightedPick(GameConfig.HatchableSpecies)
	local rarityEntry = Rarity.WeightedPick(GameConfig.HatchRarityWeights)
	local mutationEntry = Rarity.WeightedPick(GameConfig.HatchMutationWeights)

	-- Debita o ovo somente após o sorteio ter sucesso, para não perder o
	-- ovo em caso de erro inesperado nos passos seguintes.
	data.Eggs -= 1

	local dragon = DragonService.Create(
		player,
		species.SpeciesId,
		species.Tier,
		species.Name,
		rarityEntry.Rarity,
		mutationEntry.Mutation
	)

	local isNewSpecies = not data.DiscoveredDragons[species.SpeciesId]
	if isNewSpecies then
		data.DiscoveredDragons[species.SpeciesId] = true
	end

	return {
		Success = true,
		Dragon = dragon,
		IsNewSpecies = isNewSpecies,
		EggsRemaining = data.Eggs,
	}
end

return DragonService
