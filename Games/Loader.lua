local GAMES = {
    [82797688803922] = "82797688803922.lua",
    [98629859043211] = "98629859043211.lua",
    [99078474560152] = "98629859043211.lua",
    [14776071100]    = "14776071100.lua",
    [14776084615]    = "14776071100.lua",
    [127943464865693] = "127943464865693.lua",
    [90477253860739]  = "127943464865693.lua",
}

local BASE_URL = "https://raw.githubusercontent.com/EvolWareOfc/EvolWare/refs/heads/main/Games/"

local file = GAMES[game.PlaceId] or GAMES[game.GameId]

if not file then
    warn("[Evol-Ware] Unsupported game:", game.PlaceId)
    return
end

local source = game:HttpGet(BASE_URL .. file)

if not source or source == "" then
    warn("[Evol-Ware] Failed to fetch script")
    return
end

local EvolError = loadstring(source)

if not EvolError then
    warn("[Evol-Ware] Failed to compile script")
    return
end

EvolError()
