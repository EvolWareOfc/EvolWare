local CONFIG = {
	IgnoreEmpty = true,
	MinSourceLength = 32,
	IncludeCoreGui = false,
	IncludeCorePackages = false,
	IncludeNilInstances = true,
	IncludeScriptClass = true,
	MaxScripts = 0,
	FilePrefix = "EvolsScriptDump",
	PlaceIdInName = true,
	Clipboard = true,
	ClipboardMaxChars = 2000000,
	PrintEvery = 1,
}
local CoreGui = game:GetService("CoreGui")
local CorePackages = game:FindService("CorePackages")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local function has(fn)
	return typeof(fn) == "function"
end

----------------------------------------------------------------
-- PROGRESS UI
----------------------------------------------------------------
local Progress = {}
Progress._gui = nil
function Progress:Create()
	if self._gui then
		self._gui:Destroy()
	end
	local parent = CoreGui
	pcall(function()
		if gethui then
			parent = gethui()
		end
	end)
	local gui = Instance.new("ScreenGui")
	gui.Name = "EvolsScriptDumperUI"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = 999999
	gui.Parent = parent
	local frame = Instance.new("Frame")
	frame.Name = "Main"
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = UDim2.new(0.5, 0, 0, 40)
	frame.Size = UDim2.fromOffset(420, 118)
	frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	frame.BorderSizePixel = 0
	frame.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(60, 60, 70)
	stroke.Thickness = 1
	stroke.Parent = frame
	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(14, 10)
	title.Size = UDim2.new(1, - 28, 0, 22)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Color3.fromRGB(240, 240, 245)
	title.Text = "EvolsScriptDumper"
	title.Parent = frame
	local status = Instance.new("TextLabel")
	status.Name = "Status"
	status.BackgroundTransparency = 1
	status.Position = UDim2.fromOffset(14, 34)
	status.Size = UDim2.new(1, - 28, 0, 18)
	status.Font = Enum.Font.Gotham
	status.TextSize = 13
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.TextColor3 = Color3.fromRGB(180, 180, 190)
	status.Text = "Starting..."
	status.TextTruncate = Enum.TextTruncate.AtEnd
	status.Parent = frame
	local barBg = Instance.new("Frame")
	barBg.Name = "BarBg"
	barBg.Position = UDim2.fromOffset(14, 62)
	barBg.Size = UDim2.new(1, - 28, 0, 14)
	barBg.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
	barBg.BorderSizePixel = 0
	barBg.Parent = frame
	local c1 = Instance.new("UICorner")
	c1.CornerRadius = UDim.new(0, 7)
	c1.Parent = barBg
	local barFill = Instance.new("Frame")
	barFill.Name = "BarFill"
	barFill.Size = UDim2.new(0, 0, 1, 0)
	barFill.BackgroundColor3 = Color3.fromRGB(120, 90, 255)
	barFill.BorderSizePixel = 0
	barFill.Parent = barBg
	local c2 = Instance.new("UICorner")
	c2.CornerRadius = UDim.new(0, 7)
	c2.Parent = barFill
	local percent = Instance.new("TextLabel")
	percent.Name = "Percent"
	percent.BackgroundTransparency = 1
	percent.Position = UDim2.fromOffset(14, 82)
	percent.Size = UDim2.new(1, - 28, 0, 28)
	percent.Font = Enum.Font.GothamMedium
	percent.TextSize = 13
	percent.TextXAlignment = Enum.TextXAlignment.Left
	percent.TextColor3 = Color3.fromRGB(200, 200, 210)
	percent.Text = "0%  |  0 / 0"
	percent.Parent = frame
	self._gui = gui
	self._status = status
	self._fill = barFill
	self._percent = percent
	self._frame = frame
end
function Progress:Set(current, total, text)
	if not self._gui then
		return
	end
	total = math.max(total, 1)
	current = math.clamp(current, 0, total)
	local alpha = current / total
	self._status.Text = tostring(text or "")
	self._percent.Text = string.format("%d%%  |  %d / %d", math.floor(alpha * 100), current, total)
	pcall(function()
		TweenService:Create(self._fill, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
			Size = UDim2.new(alpha, 0, 1, 0),
		}):Play()
	end)
end
function Progress:Finish(ok, message)
	if not self._gui then
		return
	end
	self._status.Text = message or (ok and "Done" or "Finished with errors")
	self._fill.BackgroundColor3 = ok and Color3.fromRGB(70, 200, 120) or Color3.fromRGB(230, 90, 90)
	self._fill.Size = UDim2.new(1, 0, 1, 0)
	self._percent.Text = ok and "100%  |  Complete" or self._percent.Text
	task.delay(6, function()
		if self._gui then
			pcall(function()
				self._gui:Destroy()
			end)
			self._gui = nil
		end
	end)
end

----------------------------------------------------------------
-- CHECKS
----------------------------------------------------------------
Progress:Create()
Progress:Set(0, 1, "Checking executor functions...")
if not has(decompile) then
	Progress:Finish(false, "Missing decompile() - cannot continue")
	warn("[EvolsScriptDumper] Missing decompile()")
	return
end
if not has(writefile) then
	warn("[EvolsScriptDumper] Missing writefile() - file save may fail")
end
print("[EvolsScriptDumper] Started")

----------------------------------------------------------------
-- HELPERS
----------------------------------------------------------------
local invalidPattern = "[%z\1-\31\127<>:\"/\\|%?%*]"
local function sanitizeName(str)
	str = tostring(str or "unknown")
	str = str:gsub(invalidPattern, "_")
	str = str:gsub("%s+", "_")
	if # str == 0 then
		str = "unnamed"
	end
	return str
end
local function isUnder(inst, ancestor)
	if not ancestor then
		return false
	end
	local ok, res = pcall(function()
		return inst:IsDescendantOf(ancestor)
	end)
	return ok and res
end
local function shouldSkip(inst)
	if not CONFIG.IncludeCoreGui and isUnder(inst, CoreGui) then
		return true
	end
	if not CONFIG.IncludeCorePackages and CorePackages and isUnder(inst, CorePackages) then
		return true
	end
	return false
end
local function isScriptLike(inst)
	if not inst or not inst.ClassName then
		return false
	end
	local c = inst.ClassName
	if c == "LocalScript" or c == "ModuleScript" then
		return true
	end
	if CONFIG.IncludeScriptClass and c == "Script" then
		return true
	end
	return false
end
local function safeFullName(inst)
	local ok, name = pcall(function()
		return inst:GetFullName()
	end)
	if ok and name and name ~= "" then
		return name
	end
	local ok2, n = pcall(function()
		return inst.Name
	end)
	return (ok2 and n) or "Unknown"
end
local function collectScripts()
	local list = {}
	local seen = {}
	local function add(inst)
		if not isScriptLike(inst) then
			return
		end
		if seen[inst] then
			return
		end
		if shouldSkip(inst) then
			return
		end
		seen[inst] = true
		table.insert(list, inst)
	end
	local function walk(inst)
		add(inst)
		local ok, children = pcall(function()
			return inst:GetChildren()
		end)
		if not ok then
			return
		end
		for _, child in ipairs(children) do
			walk(child)
		end
	end
	Progress:Set(0, 1, "Scanning DataModel...")
	for _, service in ipairs(game:GetChildren()) do
		pcall(walk, service)
	end
	if CONFIG.IncludeNilInstances and has(getnilinstances) then
		Progress:Set(0, 1, "Scanning nil instances...")
		local ok, nils = pcall(getnilinstances)
		if ok and type(nils) == "table" then
			for _, inst in ipairs(nils) do
				pcall(walk, inst)
			end
		end
	end
	pcall(function()
		walk(settings())
	end)
	return list
end
local function isEffectivelyEmpty(src)
	if not src or # src < CONFIG.MinSourceLength then
		return true
	end
	for line in string.gmatch(src, "[^\r\n]+") do
		local trimmed = line:match("^%s*(.-)%s*$") or ""
		if trimmed ~= "" and not trimmed:match("^%-%-") then
			return false
		end
	end
	return true
end
local function header(path, className, index, total, status)
	return table.concat({
		"",
		string.rep("=", 78),
		string.format("-- [%d/%d] %s", index, total, path),
		string.format("-- Class: %s", className),
		string.format("-- Status: %s", status),
		string.rep("=", 78),
		"",
	}, "\n")
end
local function buildFilename()
	local parts = {
		CONFIG.FilePrefix
	}
	if CONFIG.PlaceIdInName then
		table.insert(parts, tostring(game.PlaceId))
	end
	table.insert(parts, os.date("%Y%m%d_%H%M%S"))
	return table.concat(parts, "_") .. ".lua"
end

----------------------------------------------------------------
-- RUN
----------------------------------------------------------------
local scripts = collectScripts()
if CONFIG.MaxScripts > 0 and # scripts > CONFIG.MaxScripts then
	local trimmed = {}
	for i = 1, CONFIG.MaxScripts do
		trimmed[i] = scripts[i]
	end
	scripts = trimmed
end
local total = # scripts
print(string.format("[EvolsScriptDumper] Found %d scripts", total))
Progress:Set(0, math.max(total, 1), string.format("Found %d scripts - decompiling...", total))
if total == 0 then
	Progress:Finish(false, "No scripts found")
	warn("[EvolsScriptDumper] No scripts found")
	return
end
local chunks = {}
table.insert(chunks, table.concat({
	"--[[",
	"    EvolsScriptDumper output",
	"    PlaceId: " .. tostring(game.PlaceId),
	"    GameId:  " .. tostring(game.GameId),
	"    Time:    " .. os.date("%Y-%m-%d %H:%M:%S"),
	"    Scripts: " .. tostring(total),
	"]]",
	"",
}, "\n"))
local okCount, failCount, skipCount = 0, 0, 0
for i, inst in ipairs(scripts) do
	local path = safeFullName(inst)
	local className = inst.ClassName

	-- yield so UI can render
	if i % 2 == 0 then
		task.wait()
	end
	Progress:Set(i - 1, total, string.format("Decompiling: %s", path))
	if i % CONFIG.PrintEvery == 0 or i == 1 or i == total then
		print(string.format("[EvolsScriptDumper] %d/%d  %s", i, total, path))
	end
	local status, src = "ok", nil
	local skipWrite = false
	local ok, result = pcall(decompile, inst)
	if not ok then
		status = "decompile_error: " .. tostring(result)
		src = "-- DECOMPILE FAILED\n-- " .. tostring(result)
		failCount += 1
	else
		src = result or ""
		if CONFIG.IgnoreEmpty and isEffectivelyEmpty(src) then
			status = "skipped_empty"
			skipCount += 1
			table.insert(chunks, header(path, className, i, total, status))
			table.insert(chunks, "-- (empty / comment-only source omitted)\n")
			skipWrite = true
		else
			okCount += 1
		end
	end
	if not skipWrite then
		table.insert(chunks, header(path, className, i, total, status))
		table.insert(chunks, src)
		if not tostring(src):match("\n$") then
			table.insert(chunks, "\n")
		end
	end
	Progress:Set(i, total, string.format("Done: %s", path))
end
Progress:Set(total, total, "Building file...")
local full = table.concat(chunks, "\n")
local filename = buildFilename()
local fileOk = false
if has(writefile) then
	fileOk = pcall(writefile, filename, full)
	if fileOk then
		print("[EvolsScriptDumper] Saved: " .. filename .. " (" .. tostring(# full) .. " chars)")
	else
		warn("[EvolsScriptDumper] writefile failed")
	end
else
	warn("[EvolsScriptDumper] writefile unavailable")
end
local clipOk = false
if CONFIG.Clipboard and has(setclipboard) then
	local clip = full
	if # clip > CONFIG.ClipboardMaxChars then
		clip = clip:sub(1, CONFIG.ClipboardMaxChars) .. "\n\n-- [EvolsScriptDumper] CLIPBOARD TRUNCATED (" .. tostring(# full) .. " total chars)\n"
		warn("[EvolsScriptDumper] Clipboard truncated")
	end
	clipOk = pcall(setclipboard, clip)
	print(clipOk and "[EvolsScriptDumper] Copied to clipboard" or "[EvolsScriptDumper] setclipboard failed")
end
local msg = string.format("ok=%d fail=%d skip=%d | file=%s clip=%s", okCount, failCount, skipCount, fileOk and filename or "no", clipOk and "yes" or "no")
print("[EvolsScriptDumper] " .. msg)
Progress:Finish(fileOk or clipOk, msg)
