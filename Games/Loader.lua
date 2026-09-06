local placeId = game.PlaceId
local gameId  = game.GameId

local map = {

	[82797688803922] = "https://raw.githubusercontent.com/EvolWareOfc/EvolWare/refs/heads/main/Games/82797688803922.lua",
	[98629859043211] = "https://raw.githubusercontent.com/EvolWareOfc/EvolWare/refs/heads/main/Games/98629859043211.lua",
    [99078474560152] = "https://raw.githubusercontent.com/EvolWareOfc/EvolWare/refs/heads/main/Games/98629859043211.lua",
}

local url = map[placeId] or map[gameId] or map[tostring(placeId)] or map[tostring(gameId)]

if url and url ~= "" then
	local ok, body = pcall(function()
		return game:HttpGet(url)
	end)

	if ok and body then
		local fn, err = loadstring(body)
		if fn then
			fn()
		else
			warn("[Evol-Ware Loader Error]: " .. tostring(err))
		end
	else
		warn("[Evol-Ware Loader Fetch Error]: " .. tostring(body))
	end
else
	warn("[Evol-Ware] Unsupported game (PlaceId: " .. tostring(placeId) .. ")")
end
