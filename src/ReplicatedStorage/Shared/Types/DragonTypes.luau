--[[
	DragonTypes
	Tipos compartilhados entre servidor e cliente.
]]

export type Dragon = {
	Id: string,
	SpeciesId: string,
	Name: string,
	Tier: number,
	Rarity: string,
	Mutation: string,
	Level: number,
	CreatedAt: number,
}

export type DailyRewardData = {
	Day: number,
	LastClaim: number,
}

export type PlayerData = {
	Gold: number,
	Essence: number,
	Ascensions: number,
	Eggs: number,
	Dragons: { [string]: Dragon },
	DiscoveredDragons: { [string]: boolean },
	PurchaseLevel: number,
	TowerLevel: number,
	Upgrades: { [string]: any },
	DailyReward: DailyRewardData,
	Playtime: number,
	Settings: { [string]: any },
	HasReceivedStarterEgg: boolean,
}

return {}
