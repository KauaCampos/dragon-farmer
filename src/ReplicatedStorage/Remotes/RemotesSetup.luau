--[[
	RemotesSetup
	Cria (idempotentemente) as RemoteEvents/RemoteFunctions usadas pelos
	casos de uso UC01, UC02 e UC03. Chamado uma única vez pelo servidor no
	boot (ver ServerBootstrap) antes de qualquer serviço precisar delas.

	Mantemos a criação em código (em vez de instâncias .rbxm no Rojo) para
	que os nomes e a lista de remotes fiquem centralizados e versionados
	junto do código que os consome.
]]

local RemotesSetup = {}

local REMOTE_EVENTS = {
	"EggReceived", -- server -> client: UC01, notifica ovo inicial recebido
	"DragonHatched", -- server -> client: UC03, notifica dragão criado (para efeitos/UI)
	"PlayerDataUpdated", -- server -> client: sincroniza PlayerData resumido (Gold, Eggs, etc.)
}

local REMOTE_FUNCTIONS = {
	"BuyEggs", -- client -> server: UC02
	"HatchEgg", -- client -> server: UC03
}

-- Garante que uma pasta Remotes exista dentro de `parent` e retorna a Folder.
local function getOrCreateFolder(parent: Instance, name: string): Folder
	local existing = parent:FindFirstChild(name)
	if existing and existing:IsA("Folder") then
		return existing
	end

	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

local function getOrCreateInstance(parent: Instance, className: string, name: string): Instance
	local existing = parent:FindFirstChild(name)
	if existing and existing.ClassName == className then
		return existing
	end

	local instance = Instance.new(className)
	instance.Name = name
	instance.Parent = parent
	return instance
end

-- Cria todos os remotes necessários dentro de `ReplicatedStorage/Remotes`
-- e retorna uma tabela { [nome] = instância } para uso direto pelos serviços.
function RemotesSetup.Init(replicatedStorage: Instance): { [string]: RemoteEvent | RemoteFunction }
	local remotesFolder = getOrCreateFolder(replicatedStorage, "Remotes")

	local remotes: { [string]: RemoteEvent | RemoteFunction } = {}

	for _, remoteName in REMOTE_EVENTS do
		remotes[remoteName] = getOrCreateInstance(remotesFolder, "RemoteEvent", remoteName) :: RemoteEvent
	end

	for _, remoteName in REMOTE_FUNCTIONS do
		remotes[remoteName] = getOrCreateInstance(remotesFolder, "RemoteFunction", remoteName) :: RemoteFunction
	end

	return remotes
end

return RemotesSetup
