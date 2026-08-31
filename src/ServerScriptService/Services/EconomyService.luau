--[[
	EconomyService
	Gerencia o saldo de Gold do jogador. Usado pelo EggService (UC02) para
	validar e debitar o custo da compra de ovos. Toda alteração de Gold
	passa por aqui para manter a validação server-authoritative centralizada.
]]

local ServerScriptService = game:GetService("ServerScriptService")
local DataService = require(ServerScriptService.Services.DataService)

local EconomyService = {}

-- Retorna o saldo atual de Gold do jogador.
function EconomyService.GetGold(player: Player): number
	local data = DataService.Get(player)
	if not data then
		return 0
	end
	return data.Gold
end

-- Adiciona `amount` Gold ao jogador. `amount` deve ser >= 0.
function EconomyService.AddGold(player: Player, amount: number): boolean
	if amount < 0 then
		return false
	end

	local data = DataService.Get(player)
	if not data then
		return false
	end

	data.Gold += amount
	return true
end

-- Tenta remover `amount` Gold do jogador. Retorna false sem alterar o
-- saldo caso o jogador não tenha Gold suficiente (UC02: "servidor valida
-- Gold disponível").
function EconomyService.RemoveGold(player: Player, amount: number): boolean
	if amount < 0 then
		return false
	end

	local data = DataService.Get(player)
	if not data then
		return false
	end

	if data.Gold < amount then
		return false
	end

	data.Gold -= amount
	return true
end

-- Verifica se o jogador possui Gold suficiente, sem debitar.
function EconomyService.HasEnoughGold(player: Player, amount: number): boolean
	return EconomyService.GetGold(player) >= amount
end

return EconomyService
