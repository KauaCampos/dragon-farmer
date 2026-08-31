--[[
	EggService
	Cobre:
	  UC01 — Entrar no jogo e receber ovo inicial (Free Dragon Egg).
	  UC02 — Comprar ovos em pads físicos, com validação server-authoritative
	         de Gold e de quantidade máxima permitida pelo PurchaseLevel.

	Todo o inventário de ovos é um contador simples (`data.Eggs`) no
	PlayerData: o MVP não diferencia "tipos" de ovo antes do hatch (a
	variação de espécie/raridade/mutação é sorteada no ato do hatch, ver
	EggService.Hatch / DragonService, UC03).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
local DataService = require(ServerScriptService.Services.DataService)
local EconomyService = require(ServerScriptService.Services.EconomyService)

local EggService = {}

-- UC01: concede o Free Dragon Egg na primeira entrada do jogador. Idempotente
-- — chamadas repetidas não concedem ovos extras (usa o flag
-- HasReceivedStarterEgg do PlayerData).
-- Retorna true se um ovo foi concedido nesta chamada, false caso já tivesse
-- sido concedido antes.
function EggService.GrantStarterEggIfNeeded(player: Player): boolean
	local data = DataService.Get(player)
	if not data then
		return false
	end

	if data.HasReceivedStarterEgg then
		return false
	end

	data.Eggs += 1
	data.HasReceivedStarterEgg = true

	return true
end

-- Retorna o bundle de compra correspondente a `amount`, ou nil se `amount`
-- não for uma quantidade válida configurada em GameConfig.EggPurchase.Bundles.
local function findBundle(amount: number)
	for _, bundle in GameConfig.EggPurchase.Bundles do
		if bundle.Amount == amount then
			return bundle
		end
	end
	return nil
end

export type BuyEggsResult = {
	Success: boolean,
	Reason: string?,
	EggsOwned: number?,
	Gold: number?,
}

-- UC02: compra `amount` ovos pelo pad de compra.
-- Fluxo (server-authoritative): valida quantidade permitida pelo
-- PurchaseLevel do jogador -> valida Gold disponível -> debita Gold ->
-- adiciona ovos ao inventário.
function EggService.BuyEggs(player: Player, amount: number): BuyEggsResult
	local data = DataService.Get(player)
	if not data then
		return { Success = false, Reason = "NoPlayerData" }
	end

	local bundle = findBundle(amount)
	if not bundle then
		return { Success = false, Reason = "InvalidAmount" }
	end

	if data.PurchaseLevel < bundle.RequiredPurchaseLevel then
		return { Success = false, Reason = "PurchaseLevelTooLow" }
	end

	if data.Eggs + amount > GameConfig.EggPurchase.MaxInventoryEggs then
		return { Success = false, Reason = "InventoryFull" }
	end

	local totalCost = amount * GameConfig.EggPurchase.PricePerEgg

	if not EconomyService.HasEnoughGold(player, totalCost) then
		return { Success = false, Reason = "NotEnoughGold" }
	end

	local removed = EconomyService.RemoveGold(player, totalCost)
	if not removed then
		-- Corrida rara entre a checagem acima e a remoção; falha de forma segura.
		return { Success = false, Reason = "NotEnoughGold" }
	end

	data.Eggs += amount

	return {
		Success = true,
		EggsOwned = data.Eggs,
		Gold = data.Gold,
	}
end

return EggService
