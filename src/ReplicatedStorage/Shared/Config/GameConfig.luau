--[[
	GameConfig
	Configuração central de balanceamento do MVP (casos de uso UC01, UC02, UC03).
	Mantido em dados puros para facilitar ajustes sem tocar na lógica dos serviços.
]]

local GameConfig = {}

-- Economia inicial
GameConfig.StartingGold = 100
GameConfig.MaxDragonsPerPlayer = 10

-- UC02 — Compra de ovos (pads físicos na base)
-- Quantidades compráveis e preço unitário em Gold. `RequiredPurchaseLevel`
-- é o PurchaseLevel mínimo do jogador para desbloquear aquele lote de compra.
GameConfig.EggPurchase = {
	PricePerEgg = 10,
	Bundles = {
		{ Amount = 1, RequiredPurchaseLevel = 1 },
		{ Amount = 5, RequiredPurchaseLevel = 1 },
		{ Amount = 25, RequiredPurchaseLevel = 2 },
		{ Amount = 100, RequiredPurchaseLevel = 3 },
	},
	MaxInventoryEggs = 50,
}

-- UC01 — Ovo gratuito recebido ao entrar no jogo pela primeira vez
GameConfig.FreeStarterEgg = {
	EggId = "free_dragon_egg",
}

-- UC07 (referência tier 1-2 usada no UC03) — Tabela de progressão de dragões.
-- Produção usada futuramente pelo ProductionSystem (UC04).
GameConfig.DragonTiers = {
	{ Tier = 1, Name = "Baby Dragon", ProductionPerSecond = 1 },
	{ Tier = 2, Name = "Forest Dragon", ProductionPerSecond = 5 },
	{ Tier = 3, Name = "Fire Dragon", ProductionPerSecond = 25 },
	{ Tier = 4, Name = "Ice Dragon", ProductionPerSecond = 125 },
	{ Tier = 5, Name = "Thunder Dragon", ProductionPerSecond = 625 },
	{ Tier = 6, Name = "Shadow Dragon", ProductionPerSecond = 3100 },
	{ Tier = 7, Name = "Lava Dragon", ProductionPerSecond = 15600 },
	{ Tier = 8, Name = "Crystal Dragon", ProductionPerSecond = 78000 },
	{ Tier = 9, Name = "Galaxy Dragon", ProductionPerSecond = 390000 },
	{ Tier = 10, Name = "Void Dragon", ProductionPerSecond = 1950000 },
	{ Tier = 11, Name = "Celestial Dragon", ProductionPerSecond = 9700000 },
	{ Tier = 12, Name = "Ancient Dragon", ProductionPerSecond = 48800000 },
}

-- UC03 — Chocar ovo (Hatch): toda espécie disponível no MVP nasce como Tier 1
-- (Baby Dragon). O sorteio do UC03 ocorre sobre Raridade e Mutação; a espécie
-- em si evolui via Merge (UC06), então o hatch do MVP sempre entrega o dragão
-- base de tier 1. Deixado como tabela para permitir múltiplas espécies base
-- no futuro sem mudar a lógica do EggService.
GameConfig.HatchableSpecies = {
	{ SpeciesId = "baby_dragon", Name = "Baby Dragon", Tier = 1, Weight = 100 },
}

-- UC03 — Tabela de sorteio de raridade no hatch (pesos relativos, soma livre).
GameConfig.HatchRarityWeights = {
	{ Rarity = "Common", Weight = 60 },
	{ Rarity = "Uncommon", Weight = 25 },
	{ Rarity = "Rare", Weight = 10 },
	{ Rarity = "Epic", Weight = 4 },
	{ Rarity = "Legendary", Weight = 1 },
}

-- UC03 — Tabela de sorteio de mutação no hatch (pesos relativos, soma livre).
-- Multiplicadores usados futuramente pelo ProductionSystem (UC04).
GameConfig.HatchMutationWeights = {
	{ Mutation = "Normal", Weight = 1000, Multiplier = 1 },
	{ Mutation = "Golden", Weight = 20, Multiplier = 2 },
	{ Mutation = "Rainbow", Weight = 5, Multiplier = 5 },
}

return GameConfig
