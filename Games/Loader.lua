local placeId = game.PlaceId
local gameId = game.GameId

local GAMES = {
    [82797688803922] = "82797688803922.lua",
    [98629859043211] = "98629859043211.lua",
    [99078474560152] = "98629859043211.lua",
    [14776071100]    = "14776071100.lua",
    [14776084615]    = "14776071100.lua",
}

local BASE_URL = "https://raw.githubusercontent.com/EvolWareOfc/EvolWare/refs/heads/main/Games/"

local file = GAMES[placeId] or GAMES[gameId]

local function log(icon, message)
    print(string.format("[Evol-Ware] %s %s", icon, message))
end

if not file then
    log("✕", "Unsupported game [" .. placeId .. "]")
    return
end

local url = BASE_URL .. file

log("→", "Loading...")

local success, source = pcall(function()
    return game:HttpGet(url)
end)

if not success or type(source) ~= "string" or source == "" then
    log("✕", "Failed to fetch script")
    return
end

local success, fn = pcall(loadstring, source)

if not success or not fn then
    log("✕", "Failed to compile script")
    return
end

local success, err = pcall(fn)

if not success then
    log("✕", "Script error: " .. tostring(err))
    return
end

log("✓", "Loaded successfully")
