--[[
	FarmService
	Responsável pela fazenda/base física do jogador no mapa. No MVP, cobre
	apenas a etapa de UC01 em que o jogador novo "é guiado até sua base":
	atribui um slot de base livre e teleporta o jogador até ele.

	Expansão de base (upgrades visuais, Dragon Tower) pertence ao UC10 e
	fica fora do escopo desta implementação inicial.
]]

local CollectionService = game:GetService("CollectionService")

local FarmService = {}

-- Tag usada em Workspace para marcar os spawns de base (ex.: Parts
-- posicionadas no mapa, uma por uma das 6 bases do MVP), cada uma marcada
-- com CollectionService:AddTag(part, "PlayerFarmSpawn") no Studio.
local FARM_SPAWN_TAG = "PlayerFarmSpawn"

-- [Player] = spawn (Instance) atribuído
local assignedSpawns: { [Player]: Instance } = {}

-- Retorna um spawn de base livre no mapa, ou nil se todas estiverem ocupadas.
local function getFreeSpawn(): Instance?
	local taken = {}
	for _, spawn in assignedSpawns do
		taken[spawn] = true
	end

	for _, spawn in CollectionService:GetTagged(FARM_SPAWN_TAG) do
		if not taken[spawn] then
			return spawn
		end
	end

	return nil
end

-- UC01 ("é guiado até sua base"): atribui uma base livre ao jogador e move
-- seu personagem até lá. Retorna true se conseguiu atribuir/mover.
function FarmService.CreateFarm(player: Player): boolean
	if assignedSpawns[player] then
		-- Jogador já tem base atribuída nesta sessão.
		local spawn = assignedSpawns[player]
		local character = player.Character
		if character and character.PrimaryPart and spawn:IsA("BasePart") then
			character:PivotTo(spawn.CFrame + Vector3.new(0, 3, 0))
		end
		return true
	end

	local spawn = getFreeSpawn()
	if not spawn then
		warn(("[FarmService] Nenhuma base livre disponível para %s"):format(player.Name))
		return false
	end

	assignedSpawns[player] = spawn

	local character = player.Character or player.CharacterAdded:Wait()
	if character.PrimaryPart and spawn:IsA("BasePart") then
		character:PivotTo(spawn.CFrame + Vector3.new(0, 3, 0))
	end

	return true
end

-- Placeholder para UC10 (upgrade visual da base) — fora do escopo de
-- UC01/UC02/UC03.
function FarmService.ExpandFarm()
	-- Expandir a fazenda
end

return FarmService
