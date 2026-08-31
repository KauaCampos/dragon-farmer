--[[
	DragonController
	Escuta eventos do servidor relacionados a dragões (UC03) e dispara
	efeitos/animações no cliente. A lógica de sorteio e criação do dragão
	é toda server-authoritative (DragonService); este controller apenas
	reage ao resultado.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DragonController = {}

function DragonController.Start()
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local dragonHatched = remotes:WaitForChild("DragonHatched") :: RemoteEvent

	dragonHatched.OnClientEvent:Connect(function(payload)
		local dragon = payload and payload.Dragon
		if not dragon then
			return
		end

		if payload.IsNewSpecies then
			-- UC03: "se for espécie inédita, dispara animação especial e
			-- atualiza o Dragon Index". A animação/VFX específica é um item
			-- de polimento (item 14 do roadmap de desenvolvimento);
			-- deixamos o gancho pronto aqui.
			print(("[DragonController] Nova espécie descoberta: %s (%s, %s)"):format(
				dragon.Name,
				dragon.Rarity,
				dragon.Mutation
			))
		else
			print(("[DragonController] Dragão chocado: %s (%s, %s)"):format(
				dragon.Name,
				dragon.Rarity,
				dragon.Mutation
			))
		end
	end)
end

return DragonController
