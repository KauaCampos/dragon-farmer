--[[
	UIController
	Interface do jogador para os fluxos de UC01 (aviso de ovo recebido),
	UC02 (comprar ovos) e UC03 (chocar ovo). A UI visual (StarterGui) fica
	fora do escopo desta implementação; este controller expõe as funções
	que os pads/botões da UI devem chamar, e reage aos eventos do servidor.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIController = {}

local Remotes
local latestPlayerData = {
	Gold = 0,
	Eggs = 0,
	DragonCount = 0,
}

-- UC02: chamado pelo pad de compra de ovos (ex.: ao clicar no botão
-- "Comprar 5"). `amount` deve ser uma das quantidades configuradas em
-- GameConfig.EggPurchase.Bundles (1, 5, 25, 100).
function UIController.BuyEggs(amount: number)
	local buyEggs = Remotes:WaitForChild("BuyEggs") :: RemoteFunction
	local result = buyEggs:InvokeServer(amount)

	if not result.Success then
		warn(("[UIController] Compra de %d ovos falhou: %s"):format(amount, tostring(result.Reason)))
	end

	return result
end

-- UC03: chamado ao interagir com a incubadora.
function UIController.HatchEgg()
	local hatchEgg = Remotes:WaitForChild("HatchEgg") :: RemoteFunction
	local result = hatchEgg:InvokeServer()

	if not result.Success then
		warn(("[UIController] Hatch falhou: %s"):format(tostring(result.Reason)))
	end

	return result
end

function UIController.GetLatestPlayerData()
	return latestPlayerData
end

function UIController.Start()
	Remotes = ReplicatedStorage:WaitForChild("Remotes")

	local eggReceived = Remotes:WaitForChild("EggReceived") :: RemoteEvent
	local playerDataUpdated = Remotes:WaitForChild("PlayerDataUpdated") :: RemoteEvent

	-- UC01: feedback ao jogador de que o Free Dragon Egg foi recebido.
	eggReceived.OnClientEvent:Connect(function(_payload)
		print("[UIController] Você recebeu um Free Dragon Egg!")
	end)

	playerDataUpdated.OnClientEvent:Connect(function(data)
		latestPlayerData = data
	end)
end

return UIController
