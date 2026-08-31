--[[
	Rarity
	Enumeração de raridades e utilitário de sorteio ponderado, usado pelo
	EggService no hatch (UC03) para escolher Raridade e Mutação do dragão.
]]

local Rarity = {
	Common = "Common",
	Uncommon = "Uncommon",
	Rare = "Rare",
	Epic = "Epic",
	Legendary = "Legendary",
	Mythic = "Mythic",
	Divine = "Divine",
	Secret = "Secret",
}

-- Sorteia uma entrada de uma tabela de pesos no formato:
-- { { Rarity/Mutation = "X", Weight = number, ... }, ... }
-- `weightKey` indica qual campo numérico usar como peso (default "Weight").
-- `random` é opcional; se omitido, usa Random.new() novo a cada chamada
-- (o chamador deve preferir passar um Random já semeado/reaproveitado).
function Rarity.WeightedPick(entries: { [number]: { [string]: any } }, random: Random?)
	local rng = random or Random.new()

	local totalWeight = 0
	for _, entry in entries do
		totalWeight += entry.Weight
	end

	if totalWeight <= 0 then
		return entries[1]
	end

	local roll = rng:NextNumber() * totalWeight
	local cumulative = 0

	for _, entry in entries do
		cumulative += entry.Weight
		if roll <= cumulative then
			return entry
		end
	end

	-- Fallback de segurança por imprecisão de ponto flutuante.
	return entries[#entries]
end

return Rarity
