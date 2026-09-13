------------------------------------------------------------
-- SERVICES
------------------------------------------------------------
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local StarterPack = game:GetService("StarterPack")
local StarterPlayer = game:GetService("StarterPlayer")
local SoundService = game:GetService("SoundService")
local Teams = game:GetService("Teams")
local Workspace = game:GetService("Workspace")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

------------------------------------------------------------
-- CONFIGURATION
------------------------------------------------------------
local CONFIG = {

    --------------------------------------------------------
    -- MODE
    --------------------------------------------------------
	Mode = "FULL", -- "QUICK" or "FULL"

    --------------------------------------------------------
    -- OUTPUT
    --------------------------------------------------------
	CopyClipboard = true,
	SaveFiles = true,
	FolderName = "EvolsDumper",
	MainFile = "FullDump.lua",

    --------------------------------------------------------
    -- SERVICES
    --------------------------------------------------------
	DumpWorkspace = true,
	DumpReplicatedStorage = true,
	DumpLighting = true,
	DumpSoundService = true,
	DumpStarterGui = true,
	DumpStarterPack = true,
	DumpStarterPlayer = true,
	DumpTeams = true,
	DumpCoreGui = true,

    --------------------------------------------------------
    -- EXTRA INFORMATION
    --------------------------------------------------------
	DumpAttributes = true,
	DumpTags = true,
	DumpValues = true,
	DumpRemotes = true,
	DumpScripts = true,
	DumpInstances = true,

    --------------------------------------------------------
    -- SCRIPT SOURCE
    --------------------------------------------------------
	AttemptScriptSource = true,

    --------------------------------------------------------
    -- PERFORMANCE
    --------------------------------------------------------
	MaxDepth = 100,
	YieldEvery = 30,
	ProgressUpdate = 0.05,

    --------------------------------------------------------
    -- UI
    --------------------------------------------------------
	ShowUI = true,
	UIPosition = "TOP",

    --------------------------------------------------------
    -- SEPARATE FILES
    --------------------------------------------------------
	SaveGameInfo = true,
	SaveRemotes = true,
	SaveScripts = true,
	SaveClasses = true,
	SaveStatistics = true,
	SaveErrors = true
}

------------------------------------------------------------
-- STATE
------------------------------------------------------------
local StartTime = tick()
local Stats = {
	Objects = 0,
	Properties = 0,
	Attributes = 0,
	Tags = 0,
	Remotes = 0,
	Scripts = 0,
	Modules = 0,
	Values = 0,
	Errors = 0,
	Bytes = 0
}
local ClassCounts = {}
local Errors = {}
local RemoteList = {}
local ScriptList = {}
local ValueList = {}
local DumpFinished = false

------------------------------------------------------------
-- GUI
------------------------------------------------------------
local ScreenGui
local Main
local Title
local Status
local CurrentObject
local ProgressBackground
local ProgressBar
local Percentage
local StatsLabel
local SpeedLabel
local TimeLabel
if CONFIG.ShowUI then
	pcall(function()
		local old = PlayerGui:FindFirstChild("EvolsDumperUI")
		if old then
			old:Destroy()
		end
		ScreenGui = Instance.new("ScreenGui")
		ScreenGui.Name = "EvolsDumperUI"
		ScreenGui.ResetOnSpawn = false
		ScreenGui.IgnoreGuiInset = true
		ScreenGui.DisplayOrder = 999999
		ScreenGui.Parent = PlayerGui
		Main = Instance.new("Frame")
		Main.Name = "Main"
		Main.Size = UDim2.new(0, 560, 0, 205)
		Main.Position = UDim2.new(0.5, - 280, 0, 25)
		Main.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
		Main.BorderSizePixel = 0
		Main.Parent = ScreenGui
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = Main
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(65, 65, 75)
		stroke.Thickness = 1
		stroke.Parent = Main
		Title = Instance.new("TextLabel")
		Title.Size = UDim2.new(1, - 30, 0, 30)
		Title.Position = UDim2.new(0, 15, 0, 9)
		Title.BackgroundTransparency = 1
		Title.Text = "EVOLSDUMPER"
		Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		Title.TextSize = 21
		Title.Font = Enum.Font.GothamBold
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Parent = Main
		Status = Instance.new("TextLabel")
		Status.Size = UDim2.new(1, - 30, 0, 22)
		Status.Position = UDim2.new(0, 15, 0, 42)
		Status.BackgroundTransparency = 1
		Status.Text = "Initializing..."
		Status.TextColor3 = Color3.fromRGB(190, 190, 200)
		Status.TextSize = 13
		Status.Font = Enum.Font.Gotham
		Status.TextXAlignment = Enum.TextXAlignment.Left
		Status.Parent = Main
		CurrentObject = Instance.new("TextLabel")
		CurrentObject.Size = UDim2.new(1, - 30, 0, 21)
		CurrentObject.Position = UDim2.new(0, 15, 0, 65)
		CurrentObject.BackgroundTransparency = 1
		CurrentObject.Text = ""
		CurrentObject.TextColor3 = Color3.fromRGB(125, 125, 140)
		CurrentObject.TextSize = 11
		CurrentObject.Font = Enum.Font.Code
		CurrentObject.TextXAlignment = Enum.TextXAlignment.Left
		CurrentObject.TextTruncate = Enum.TextTruncate.AtEnd
		CurrentObject.Parent = Main
		ProgressBackground = Instance.new("Frame")
		ProgressBackground.Size = UDim2.new(1, - 30, 0, 14)
		ProgressBackground.Position = UDim2.new(0, 15, 0, 92)
		ProgressBackground.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
		ProgressBackground.BorderSizePixel = 0
		ProgressBackground.Parent = Main
		local pc = Instance.new("UICorner")
		pc.CornerRadius = UDim.new(0, 7)
		pc.Parent = ProgressBackground
		ProgressBar = Instance.new("Frame")
		ProgressBar.Size = UDim2.new(0, 0, 1, 0)
		ProgressBar.BackgroundColor3 = Color3.fromRGB(135, 85, 255)
		ProgressBar.BorderSizePixel = 0
		ProgressBar.Parent = ProgressBackground
		local pbc = Instance.new("UICorner")
		pbc.CornerRadius = UDim.new(0, 7)
		pbc.Parent = ProgressBar
		Percentage = Instance.new("TextLabel")
		Percentage.Size = UDim2.new(0, 60, 0, 20)
		Percentage.Position = UDim2.new(1, - 75, 0, 110)
		Percentage.BackgroundTransparency = 1
		Percentage.Text = "0%"
		Percentage.TextColor3 = Color3.fromRGB(200, 200, 210)
		Percentage.TextSize = 11
		Percentage.Font = Enum.Font.GothamBold
		Percentage.TextXAlignment = Enum.TextXAlignment.Right
		Percentage.Parent = Main
		StatsLabel = Instance.new("TextLabel")
		StatsLabel.Size = UDim2.new(1, - 30, 0, 20)
		StatsLabel.Position = UDim2.new(0, 15, 0, 119)
		StatsLabel.BackgroundTransparency = 1
		StatsLabel.Text = "Objects: 0 | Properties: 0 | Attributes: 0"
		StatsLabel.TextColor3 = Color3.fromRGB(170, 170, 180)
		StatsLabel.TextSize = 11
		StatsLabel.Font = Enum.Font.Gotham
		StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
		StatsLabel.Parent = Main
		SpeedLabel = Instance.new("TextLabel")
		SpeedLabel.Size = UDim2.new(1, - 30, 0, 20)
		SpeedLabel.Position = UDim2.new(0, 15, 0, 141)
		SpeedLabel.BackgroundTransparency = 1
		SpeedLabel.Text = "Speed: 0 objects/s"
		SpeedLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
		SpeedLabel.TextSize = 11
		SpeedLabel.Font = Enum.Font.Gotham
		SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
		SpeedLabel.Parent = Main
		TimeLabel = Instance.new("TextLabel")
		TimeLabel.Size = UDim2.new(1, - 30, 0, 20)
		TimeLabel.Position = UDim2.new(0, 15, 0, 163)
		TimeLabel.BackgroundTransparency = 1
		TimeLabel.Text = "Elapsed: 0.0s"
		TimeLabel.TextColor3 = Color3.fromRGB(130, 130, 140)
		TimeLabel.TextSize = 11
		TimeLabel.Font = Enum.Font.Gotham
		TimeLabel.TextXAlignment = Enum.TextXAlignment.Left
		TimeLabel.Parent = Main
	end)
end

------------------------------------------------------------
-- UI UPDATE
------------------------------------------------------------
local function updateUI(status, objectPath, progress)
	if not CONFIG.ShowUI or not Main then
		return
	end
	pcall(function()
		Status.Text = status or ""
		CurrentObject.Text = objectPath or ""
		progress = math.clamp(progress or 0, 0, 1)
		ProgressBar.Size = UDim2.new(progress, 0, 1, 0)
		Percentage.Text = string.format("%d%%", math.floor(progress * 100))
		StatsLabel.Text = string.format("Objects: %d | Properties: %d | Attributes: %d | Tags: %d", Stats.Objects, Stats.Properties, Stats.Attributes, Stats.Tags)
		local elapsed = math.max(tick() - StartTime, 0.001)
		local speed = Stats.Objects / elapsed
		SpeedLabel.Text = string.format("Speed: %d objects/s | Remotes: %d | Scripts: %d | Modules: %d", speed, Stats.Remotes, Stats.Scripts, Stats.Modules)
		TimeLabel.Text = string.format("Elapsed: %.1fs | Values: %d | Errors: %d", elapsed, Stats.Values, Stats.Errors)
	end)
end

------------------------------------------------------------
-- STRING ESCAPING
------------------------------------------------------------
local function escapeString(value)
	value = tostring(value)
	value = value:gsub("\\", "\\\\")
	value = value:gsub("\n", "\\n")
	value = value:gsub("\r", "\\r")
	value = value:gsub("\t", "\\t")
	value = value:gsub("\"", "\\\"")
	return "\"" .. value .. "\""
end

------------------------------------------------------------
-- VALUE SERIALIZER
------------------------------------------------------------
local function serializeValue(value, depth)
	depth = depth or 0
	if depth > 15 then
		return "\"[MAX DEPTH]\""
	end
	local valueType = typeof(value)
	if value == nil then
		return "nil"
	elseif valueType == "string" then
		return escapeString(value)
	elseif valueType == "number" then
		if value ~= value then
			return "0/0"
		end
		if value == math.huge then
			return "math.huge"
		end
		if value == - math.huge then
			return "-math.huge"
		end
		return string.format("%.17g", value)
	elseif valueType == "boolean" then
		return tostring(value)
	elseif valueType == "Vector2" then
		return string.format("Vector2.new(%.17g, %.17g)", value.X, value.Y)
	elseif valueType == "Vector3" then
		return string.format("Vector3.new(%.17g, %.17g, %.17g)", value.X, value.Y, value.Z)
	elseif valueType == "Vector2int16" then
		return string.format("Vector2int16.new(%d, %d)", value.X, value.Y)
	elseif valueType == "Vector3int16" then
		return string.format("Vector3int16.new(%d, %d, %d)", value.X, value.Y, value.Z)
	elseif valueType == "CFrame" then
		local components = {
			value:GetComponents()
		}
		local output = {}
		for _, component in ipairs(components) do
			table.insert(
                output, string.format("%.17g", component))
		end
		return "CFrame.new(" .. table.concat(output, ", ") .. ")"
	elseif valueType == "Color3" then
		return string.format("Color3.new(%.17g, %.17g, %.17g)", value.R, value.G, value.B)
	elseif valueType == "BrickColor" then
		return "BrickColor.new(" .. escapeString(value.Name) .. ")"
	elseif valueType == "UDim" then
		return string.format("UDim.new(%.17g, %d)", value.Scale, value.Offset)
	elseif valueType == "UDim2" then
		return string.format("UDim2.new(%.17g, %d, %.17g, %d)", value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset)
	elseif valueType == "Rect" then
		return string.format("Rect.new(%d, %d, %d, %d)", value.Min.X, value.Min.Y, value.Max.X, value.Max.Y)
	elseif valueType == "NumberRange" then
		return string.format("NumberRange.new(%.17g, %.17g)", value.Min, value.Max)
	elseif valueType == "NumberSequence" then
		local points = {}
		for _, point in ipairs(value.Keypoints) do
			table.insert(
                points, string.format("NumberSequenceKeypoint.new(%.17g, %.17g, %.17g)", point.Time, point.Value, point.Envelope))
		end
		return "NumberSequence.new({" .. table.concat(points, ", ") .. "})"
	elseif valueType == "ColorSequence" then
		local points = {}
		for _, point in ipairs(value.Keypoints) do
			table.insert(
                points, string.format("ColorSequenceKeypoint.new(%.17g, Color3.new(%.17g, %.17g, %.17g))", point.Time, point.Value.R, point.Value.G, point.Value.B))
		end
		return "ColorSequence.new({" .. table.concat(points, ", ") .. "})"
	elseif valueType == "EnumItem" then
		return tostring(value)
	elseif valueType == "PhysicalProperties" then
		return string.format("PhysicalProperties.new(%.17g, %.17g, %.17g, %.17g, %.17g)", value.Density, value.Friction, value.Elasticity, value.FrictionWeight, value.ElasticityWeight)
	elseif valueType == "Instance" then
		local success, path = pcall(function()
			return value:GetFullName()
		end)
		if success then
			return escapeString(path)
		end
		return "\"[INSTANCE]\""
	elseif valueType == "table" then
		local result = "{"
		local keys = {}
		for key in pairs(value) do
			table.insert(keys, key)
		end
		table.sort(
            keys, function(a, b)
			return tostring(a) < tostring(b)
		end)
		for _, key in ipairs(keys) do
			result = result .. "[" .. serializeValue(key, depth + 1) .. "] = " .. serializeValue(
                    value[key], depth + 1) .. ","
		end
		return result .. "}"
	end
	local success, result = pcall(function()
		return tostring(value)
	end)
	if success then
		return escapeString(result)
	end
	return "\"[UNSUPPORTED]\""
end

------------------------------------------------------------
-- ERROR LOGGER
------------------------------------------------------------
local function logError(path, reason)
	Stats.Errors = Stats.Errors + 1
	table.insert(
        Errors, {
		Path = tostring(path),
		Reason = tostring(reason)
	})
end

------------------------------------------------------------
-- PROPERTY READER
------------------------------------------------------------
local function addProperty(data, object, property)
	local success, value = pcall(function()
		return object[property]
	end)
	if not success then
		return
	end
	if value == nil then
		return
	end
	local serializeSuccess, serialized = pcall(function()
		return serializeValue(value)
	end)
	if serializeSuccess and serialized then
		data.Properties[property] = serialized
		Stats.Properties = Stats.Properties + 1
	end
end

------------------------------------------------------------
-- PROPERTY LIST
------------------------------------------------------------
local CommonProperties = {
	"Name",
	"Archivable",
	"Parent"
}
local BasePartProperties = {
	"CFrame",
	"Position",
	"Orientation",
	"Rotation",
	"Size",
	"Color",
	"BrickColor",
	"Material",
	"MaterialVariant",
	"Transparency",
	"Reflectance",
	"Anchored",
	"CanCollide",
	"CanTouch",
	"CanQuery",
	"CastShadow",
	"Massless",
	"RootPriority",
	"CollisionGroup",
	"CustomPhysicalProperties",
	"AssemblyLinearVelocity",
	"AssemblyAngularVelocity",
	"Velocity",
	"RotVelocity",
	"CurrentPhysicalProperties",
	"ReceiveAge"
}
local GuiProperties = {
	"Visible",
	"Active",
	"Selectable",
	"AutoButtonColor",
	"ClipsDescendants",
	"LayoutOrder",
	"ZIndex",
	"AnchorPoint",
	"Position",
	"Size",
	"Rotation",
	"BackgroundColor3",
	"BackgroundTransparency",
	"BorderColor3",
	"BorderSizePixel",
	"BorderMode"
}
local TextProperties = {
	"Text",
	"TextColor3",
	"TextTransparency",
	"TextSize",
	"TextScaled",
	"TextWrapped",
	"TextStrokeColor3",
	"TextStrokeTransparency",
	"Font",
	"RichText",
	"TextXAlignment",
	"TextYAlignment",
	"LineHeight",
	"MaxVisibleGraphemes",
	"ClearTextOnFocus",
	"MultiLine",
	"PlaceholderText",
	"PlaceholderColor3"
}
local ImageProperties = {
	"Image",
	"ImageColor3",
	"ImageTransparency",
	"ResampleMode",
	"ScaleType",
	"SliceCenter",
	"SliceScale",
	"TileSize"
}
local SoundProperties = {
	"SoundId",
	"Volume",
	"PlaybackSpeed",
	"Looped",
	"Playing",
	"TimePosition",
	"RollOffMode",
	"RollOffMaxDistance",
	"RollOffMinDistance",
	"EmitterSize",
	"SoundGroup",
	"PlaybackRegionEnabled",
	"PlaybackRegionStart",
	"PlaybackRegionEnd"
}
local LightProperties = {
	"Brightness",
	"Color",
	"Enabled",
	"Range",
	"Shadows",
	"Angle",
	"Face"
}
local ParticleProperties = {
	"Enabled",
	"Rate",
	"Lifetime",
	"Speed",
	"Rotation",
	"RotSpeed",
	"SpreadAngle",
	"LightEmission",
	"LightInfluence",
	"Drag",
	"LockedToPart",
	"VelocityInheritance",
	"ZOffset",
	"Acceleration",
	"Squash"
}
local PromptProperties = {
	"ActionText",
	"ObjectText",
	"Enabled",
	"HoldDuration",
	"MaxActivationDistance",
	"RequiresLineOfSight",
	"KeyboardKeyCode",
	"GamepadKeyCode",
	"Style",
	"ClickablePrompt"
}

------------------------------------------------------------
-- SERIALIZE INSTANCE
------------------------------------------------------------
local function serializeInstance(object, depth)
	depth = depth or 0
	if not object then
		return nil
	end
	if depth > CONFIG.MaxDepth then
		return {
			Name = tostring(object.Name),
			ClassName = tostring(object.ClassName),
			FullName = "",
			Properties = {},
			Attributes = {},
			Tags = {},
			Children = {},
			Truncated = true
		}
	end
	Stats.Objects = Stats.Objects + 1
	local className = "Unknown"
	local objectName = "Unknown"
	local fullName = ""
	pcall(function()
		className = object.ClassName
		objectName = object.Name
		fullName = object:GetFullName()
	end)
	ClassCounts[className] = (ClassCounts[className] or 0) + 1
	if CONFIG.ShowUI then
		CurrentObject.Text = fullName
	end
	local data = {
		Name = objectName,
		ClassName = className,
		FullName = fullName,
		Properties = {},
		Attributes = {},
		Tags = {},
		Children = {}
	}

    --------------------------------------------------------
    -- COMMON
    --------------------------------------------------------
	for _, property in ipairs(CommonProperties) do
		addProperty(data, object, property)
	end

    --------------------------------------------------------
    -- FULL MODE PROPERTIES
    --------------------------------------------------------
	if CONFIG.Mode == "FULL" then

        ----------------------------------------------------
        -- BASE PART
        ----------------------------------------------------
		pcall(function()
			if object:IsA("BasePart") then
				for _, property in ipairs(BasePartProperties) do
					addProperty(data, object, property)
				end
			end
		end)

        ----------------------------------------------------
        -- MODEL
        ----------------------------------------------------
		pcall(function()
			if object:IsA("Model") then
				addProperty(
                    data, object, "PrimaryPart")
				addProperty(
                    data, object, "WorldPivot")
				addProperty(
                    data, object, "LevelOfDetail")
				addProperty(
                    data, object, "ModelStreamingMode")
			end
		end)

        ----------------------------------------------------
        -- GUI
        ----------------------------------------------------
		pcall(function()
			if object:IsA("GuiObject") then
				for _, property in ipairs(GuiProperties) do
					addProperty(data, object, property)
				end
			end
		end)

        ----------------------------------------------------
        -- TEXT GUI
        ----------------------------------------------------
		pcall(function()
			if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
				for _, property in ipairs(TextProperties) do
					addProperty(data, object, property)
				end
			end
		end)

        ----------------------------------------------------
        -- IMAGE GUI
        ----------------------------------------------------
		pcall(function()
			if object:IsA("ImageLabel") or object:IsA("ImageButton") then
				for _, property in ipairs(ImageProperties) do
					addProperty(data, object, property)
				end
			end
		end)

        ----------------------------------------------------
        -- SOUND
        ----------------------------------------------------
		pcall(function()
			if object:IsA("Sound") then
				for _, property in ipairs(SoundProperties) do
					addProperty(data, object, property)
				end
			end
		end)

        ----------------------------------------------------
        -- LIGHT
        ----------------------------------------------------
		pcall(function()
			if object:IsA("Light") then
				for _, property in ipairs(LightProperties) do
					addProperty(data, object, property)
				end
			end
		end)

        ----------------------------------------------------
        -- PARTICLE
        ----------------------------------------------------
		pcall(function()
			if object:IsA("ParticleEmitter") then
				for _, property in ipairs(ParticleProperties) do
					addProperty(data, object, property)
				end
			end
		end)

        ----------------------------------------------------
        -- PROMPT
        ----------------------------------------------------
		pcall(function()
			if object:IsA("ProximityPrompt") then
				for _, property in ipairs(PromptProperties) do
					addProperty(data, object, property)
				end
			end
		end)

        ----------------------------------------------------
        -- ATTACHMENT
        ----------------------------------------------------
		pcall(function()
			if object:IsA("Attachment") then
				addProperty(data, object, "CFrame")
				addProperty(data, object, "Position")
				addProperty(data, object, "Orientation")
				addProperty(data, object, "Axis")
				addProperty(data, object, "SecondaryAxis")
				addProperty(data, object, "Visible")
			end
		end)

        ----------------------------------------------------
        -- MESH
        ----------------------------------------------------
		pcall(function()
			if object:IsA("SpecialMesh") then
				addProperty(data, object, "MeshId")
				addProperty(data, object, "TextureId")
				addProperty(data, object, "MeshType")
				addProperty(data, object, "Scale")
				addProperty(data, object, "Offset")
			end
			if object:IsA("MeshPart") then
				addProperty(data, object, "MeshId")
				addProperty(data, object, "TextureID")
				addProperty(data, object, "RenderFidelity")
				addProperty(data, object, "DoubleSided")
			end
		end)

        ----------------------------------------------------
        -- DECAL / TEXTURE
        ----------------------------------------------------
		pcall(function()
			if object:IsA("Decal") or object:IsA("Texture") then
				addProperty(data, object, "Texture")
				addProperty(data, object, "Color3")
				addProperty(data, object, "Transparency")
				addProperty(data, object, "Face")
			end
			if object:IsA("Texture") then
				addProperty(
                    data, object, "StudsPerTileU")
				addProperty(
                    data, object, "StudsPerTileV")
			end
		end)

        ----------------------------------------------------
        -- BEAM
        ----------------------------------------------------
		pcall(function()
			if object:IsA("Beam") then
				local beamProperties = {
					"Attachment0",
					"Attachment1",
					"Color",
					"Transparency",
					"Width0",
					"Width1",
					"CurveSize0",
					"CurveSize1",
					"Segments",
					"Texture",
					"TextureLength",
					"TextureSpeed",
					"FaceCamera",
					"LightEmission",
					"LightInfluence"
				}
				for _, property in ipairs(beamProperties) do
					addProperty(data, object, property)
				end
			end
		end)

        ----------------------------------------------------
        -- TRAIL
        ----------------------------------------------------
		pcall(function()
			if object:IsA("Trail") then
				local trailProperties = {
					"Attachment0",
					"Attachment1",
					"Color",
					"Transparency",
					"Lifetime",
					"MinLength",
					"MaxLength",
					"Texture",
					"TextureMode",
					"TextureLength",
					"FaceCamera",
					"LightEmission",
					"LightInfluence"
				}
				for _, property in ipairs(trailProperties) do
					addProperty(data, object, property)
				end
			end
		end)

        ----------------------------------------------------
        -- HUMANOID
        ----------------------------------------------------
		pcall(function()
			if object:IsA("Humanoid") then
				local humanoidProperties = {
					"Health",
					"MaxHealth",
					"WalkSpeed",
					"JumpPower",
					"JumpHeight",
					"HipHeight",
					"AutoRotate",
					"RigType",
					"UseJumpPower",
					"DisplayDistanceType",
					"NameDisplayDistance",
					"HealthDisplayDistance",
					"Sit",
					"PlatformStand",
					"BreakJointsOnDeath",
					"RequiresNeck"
				}
				for _, property in ipairs(humanoidProperties) do
					addProperty(data, object, property)
				end
			end
		end)

        ----------------------------------------------------
        -- ANIMATION
        ----------------------------------------------------
		pcall(function()
			if object:IsA("Animation") then
				addProperty(data, object, "AnimationId")
			end
			if object:IsA("AnimationController") then
				addProperty(
                    data, object, "Enabled")
			end
		end)

        ----------------------------------------------------
        -- TOOL
        ----------------------------------------------------
		pcall(function()
			if object:IsA("Tool") then
				addProperty(data, object, "Enabled")
				addProperty(data, object, "CanBeDropped")
				addProperty(data, object, "RequiresHandle")
				addProperty(data, object, "ToolTip")
			end
		end)

        ----------------------------------------------------
        -- CAMERA
        ----------------------------------------------------
		pcall(function()
			if object:IsA("Camera") then
				local cameraProperties = {
					"CFrame",
					"Focus",
					"FieldOfView",
					"FieldOfViewMode",
					"CameraType",
					"CameraSubject",
					"ViewportSize"
				}
				for _, property in ipairs(cameraProperties) do
					addProperty(data, object, property)
				end
			end
		end)

        ----------------------------------------------------
        -- CONSTRAINTS
        ----------------------------------------------------
		pcall(function()
			if object:IsA("Constraint") then
				addProperty(data, object, "Attachment0")
				addProperty(data, object, "Attachment1")
			end
			if object:IsA("RopeConstraint") then
				addProperty(data, object, "Length")
				addProperty(data, object, "Thickness")
				addProperty(data, object, "Visible")
				addProperty(data, object, "Restitution")
			end
			if object:IsA("SpringConstraint") then
				addProperty(data, object, "FreeLength")
				addProperty(data, object, "Stiffness")
				addProperty(data, object, "Damping")
				addProperty(data, object, "MaxForce")
				addProperty(data, object, "Coils")
				addProperty(data, object, "Radius")
				addProperty(data, object, "Thickness")
				addProperty(data, object, "Visible")
			end
		end)
	end

    --------------------------------------------------------
    -- ATTRIBUTES
    --------------------------------------------------------
	if CONFIG.DumpAttributes then
		pcall(function()
			local attributes = object:GetAttributes()
			for name, value in pairs(attributes) do
				local success, serialized = pcall(function()
					return serializeValue(value)
				end)
				if success and serialized then
					data.Attributes[name] = serialized
					Stats.Attributes = Stats.Attributes + 1
				end
			end
		end)
	end

    --------------------------------------------------------
    -- TAGS
    --------------------------------------------------------
	if CONFIG.DumpTags then
		pcall(function()
			local tags = CollectionService:GetTags(object)
			for _, tag in ipairs(tags) do
				table.insert(
                    data.Tags, tag)
				Stats.Tags = Stats.Tags + 1
			end
		end)
	end

    --------------------------------------------------------
    -- VALUES
    --------------------------------------------------------
	if CONFIG.DumpValues then
		pcall(function()
			if object:IsA("ValueBase") then
				Stats.Values = Stats.Values + 1
				addProperty(
                    data, object, "Value")
				table.insert(
                    ValueList, {
					Name = object.Name,
					ClassName = object.ClassName,
					Path = fullName,
					Value = data.Properties.Value
				})
			end
		end)
	end

    --------------------------------------------------------
    -- REMOTES
    --------------------------------------------------------
	if CONFIG.DumpRemotes then
		pcall(function()
			local remoteType
			if object:IsA("RemoteEvent") then
				remoteType = "RemoteEvent"
			elseif object:IsA("RemoteFunction") then
				remoteType = "RemoteFunction"
			elseif object:IsA("BindableEvent") then
				remoteType = "BindableEvent"
			elseif object:IsA("BindableFunction") then
				remoteType = "BindableFunction"
			end
			if remoteType then
				Stats.Remotes = Stats.Remotes + 1
				data.RemoteType = remoteType
				table.insert(
                    RemoteList, {
					Name = object.Name,
					ClassName = object.ClassName,
					RemoteType = remoteType,
					Path = fullName
				})
			end
		end)
	end

    --------------------------------------------------------
    -- SCRIPTS / MODULES
    --------------------------------------------------------
	if CONFIG.DumpScripts then
		pcall(function()
			if object:IsA("Script") or object:IsA("LocalScript") or object:IsA("ModuleScript") then
				local scriptType = object.ClassName
				if object:IsA("ModuleScript") then
					Stats.Modules = Stats.Modules + 1
				else
					Stats.Scripts = Stats.Scripts + 1
				end
				local scriptData = {
					Name = object.Name,
					ClassName = scriptType,
					Path = fullName,
					SourceAvailable = false,
					Source = nil
				}
				if CONFIG.AttemptScriptSource then
					local sourceSuccess, source = pcall(function()
						return object.Source
					end)
					if sourceSuccess and type(source) == "string" and source ~= "" then
						scriptData.SourceAvailable = true
						scriptData.Source = escapeString(source)
					end
				end
				table.insert(
                    ScriptList, scriptData)
			end
		end)
	end

    --------------------------------------------------------
    -- CHILDREN
    --------------------------------------------------------
	local childSuccess, children = pcall(function()
		return object:GetChildren()
	end)
	if childSuccess and children then
		table.sort(
            children, function(a, b)
			return tostring(a.Name):lower() < tostring(b.Name):lower()
		end)
		for _, child in ipairs(children) do
			local success, result = pcall(function()
				return serializeInstance(
                        child, depth + 1)
			end)
			if success and result then
				table.insert(
                    data.Children, result)
			else
				logError(
                    child:GetFullName(), "Failed to serialize child")
			end
			if Stats.Objects % CONFIG.YieldEvery == 0 then
				task.wait()
			end
		end
	end
	return data
end

------------------------------------------------------------
-- LUA TABLE SERIALIZER
------------------------------------------------------------
local function serializeLuaTable(value, indent)
	indent = indent or ""
	if type(value) ~= "table" then
		if type(value) == "string" then
			return escapeString(value)
		end
		return tostring(value)
	end
	local result = "{\n"
	local keys = {}
	for key in pairs(value) do
		table.insert(keys, key)
	end
	table.sort(
        keys, function(a, b)
		return tostring(a) < tostring(b)
	end)
	for _, key in ipairs(keys) do
		local child = value[key]
		local formattedKey
		if type(key) == "string" and key:match("^[%a_][%w_]*$") then
			formattedKey = key
		else
			formattedKey = "[" .. serializeValue(key) .. "]"
		end
		result = result .. indent .. "    " .. formattedKey .. " = "
		if type(child) == "table" then
			result = result .. serializeLuaTable(
                    child, indent .. "    ")
		elseif type(child) == "string" then
			result = result .. child
		else
			result = result .. tostring(child)
		end
		result = result .. ",\n"
	end
	result = result .. indent .. "}"
	return result
end

------------------------------------------------------------
-- GAME INFO
------------------------------------------------------------
local function getGameInfo()
	local info = {
		PlaceId = game.PlaceId,
		GameId = game.GameId,
		JobId = game.JobId,
		PlaceVersion = game.PlaceVersion,
		Name = "",
		Description = "",
		CreatorId = 0,
		CreatorName = "",
		CreatorType = "",
		CurrentPlayers = # Players:GetPlayers(),
		MaxPlayers = Players.MaxPlayers,
		IsStudio = RunService:IsStudio(),
		GeneratedAt = os.date("%Y-%m-%d %H:%M:%S")
	}
	pcall(function()
		local productInfo = MarketplaceService:GetProductInfo(
                game.PlaceId)
		if productInfo then
			info.Name = productInfo.Name or ""
			info.Description = productInfo.Description or ""
			if productInfo.Creator then
				info.CreatorId = productInfo.Creator.CreatorId or 0
				info.CreatorName = productInfo.Creator.Name or ""
				info.CreatorType = tostring(
                        productInfo.Creator.CreatorType or "")
			end
		end
	end)
	return info
end

------------------------------------------------------------
-- SERVICE COLLECTION
------------------------------------------------------------
local Services = {}
if CONFIG.DumpWorkspace then
	Services.Workspace = Workspace
end
if CONFIG.DumpReplicatedStorage then
	Services.ReplicatedStorage = ReplicatedStorage
end
if CONFIG.DumpLighting then
	Services.Lighting = Lighting
end
if CONFIG.DumpSoundService then
	Services.SoundService = SoundService
end
if CONFIG.DumpStarterGui then
	Services.StarterGui = StarterGui
end
if CONFIG.DumpStarterPack then
	Services.StarterPack = StarterPack
end
if CONFIG.DumpStarterPlayer then
	Services.StarterPlayer = StarterPlayer
end
if CONFIG.DumpTeams then
	Services.Teams = Teams
end
if CONFIG.DumpCoreGui then
	Services.CoreGui = CoreGui
end

------------------------------------------------------------
-- MAIN DUMP
------------------------------------------------------------
task.spawn(function()
	local allData = {
		GameInfo = getGameInfo(),
		Services = {},
		Remotes = {},
		Scripts = {},
		Values = {},
		Statistics = {},
		Classes = {},
		Errors = {}
	}
	local serviceNames = {}
	for name in pairs(Services) do
		table.insert(
            serviceNames, name)
	end
	table.sort(serviceNames)

    --------------------------------------------------------
    -- DUMP SERVICES
    --------------------------------------------------------
	for index, serviceName in ipairs(serviceNames) do
		local service = Services[serviceName]
		local progress = (index - 1) / math.max(# serviceNames, 1)
		updateUI("Dumping " .. serviceName, serviceName, progress)
		local success, result = pcall(function()
			return serializeInstance(
                    service, 0)
		end)
		if success and result then
			allData.Services[serviceName] = result
		else
			logError(
                serviceName, "Service serialization failed")
		end
		task.wait()
	end

    --------------------------------------------------------
    -- INDEXES
    --------------------------------------------------------
	updateUI("Building indexes...", "Remotes / Scripts / Values", 0.9)
	allData.Remotes = RemoteList
	allData.Scripts = ScriptList
	allData.Values = ValueList

    --------------------------------------------------------
    -- CLASS COUNTS
    --------------------------------------------------------
	allData.Classes = ClassCounts

    --------------------------------------------------------
    -- STATISTICS
    --------------------------------------------------------
	local elapsed = tick() - StartTime
	allData.Statistics = {
		Objects = Stats.Objects,
		Properties = Stats.Properties,
		Attributes = Stats.Attributes,
		Tags = Stats.Tags,
		Remotes = Stats.Remotes,
		Scripts = Stats.Scripts,
		Modules = Stats.Modules,
		Values = Stats.Values,
		Errors = Stats.Errors,
		ElapsedSeconds = elapsed,
		DumpMode = CONFIG.Mode,
		Services = # serviceNames
	}

    --------------------------------------------------------
    -- ERRORS
    --------------------------------------------------------
	allData.Errors = Errors

    --------------------------------------------------------
    -- FINAL OUTPUT
    --------------------------------------------------------
	updateUI("Generating final Lua...", "Serializing output...", 0.95)
	task.wait()
	local output = "--[[\n" .. "    EVOLSDUMPER\n" .. "    Advanced Roblox Game Dump\n" .. "    Generated: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n" .. "    Mode: " .. CONFIG.Mode .. "\n" .. "    Objects: " .. Stats.Objects .. "\n" .. "    Properties: " .. Stats.Properties .. "\n" .. "    Attributes: " .. Stats.Attributes .. "\n" .. "    Remotes: " .. Stats.Remotes .. "\n" .. "    Scripts: " .. Stats.Scripts .. "\n" .. "    Modules: " .. Stats.Modules .. "\n" .. "    Errors: " .. Stats.Errors .. "\n" .. "--]]\n\n"
	output = output .. "local EvolsDump = " .. serializeLuaTable(
            allData, "") .. "\n\nreturn EvolsDump"
	Stats.Bytes = # output

    --------------------------------------------------------
    -- SAVE MAIN FILE
    --------------------------------------------------------
	local fileResults = {}
	if CONFIG.SaveFiles and writefile then
		pcall(function()
			if makefolder then
				makefolder(
                    CONFIG.FolderName)
			end
		end)
		local mainPath = CONFIG.FolderName .. "/" .. CONFIG.MainFile
		local success = pcall(function()
			writefile(
                    mainPath, output)
		end)
		fileResults.Main = success

        ----------------------------------------------------
        -- GAME INFO
        ----------------------------------------------------
		if CONFIG.SaveGameInfo then
			pcall(function()
				writefile(
                    CONFIG.FolderName .. "/GameInfo.lua", "return " .. serializeLuaTable(
                        allData.GameInfo))
			end)
		end

        ----------------------------------------------------
        -- REMOTES
        ----------------------------------------------------
		if CONFIG.SaveRemotes then
			pcall(function()
				writefile(
                    CONFIG.FolderName .. "/Remotes.lua", "return " .. serializeLuaTable(
                        allData.Remotes))
			end)
		end

        ----------------------------------------------------
        -- SCRIPTS
        ----------------------------------------------------
		if CONFIG.SaveScripts then
			pcall(function()
				writefile(
                    CONFIG.FolderName .. "/Scripts.lua", "return " .. serializeLuaTable(
                        allData.Scripts))
			end)
		end

        ----------------------------------------------------
        -- CLASSES
        ----------------------------------------------------
		if CONFIG.SaveClasses then
			pcall(function()
				writefile(
                    CONFIG.FolderName .. "/Classes.lua", "return " .. serializeLuaTable(
                        allData.Classes))
			end)
		end

        ----------------------------------------------------
        -- STATISTICS
        ----------------------------------------------------
		if CONFIG.SaveStatistics then
			pcall(function()
				writefile(
                    CONFIG.FolderName .. "/Statistics.lua", "return " .. serializeLuaTable(
                        allData.Statistics))
			end)
		end

        ----------------------------------------------------
        -- ERRORS
        ----------------------------------------------------
		if CONFIG.SaveErrors then
			pcall(function()
				writefile(
                    CONFIG.FolderName .. "/Errors.lua", "return " .. serializeLuaTable(
                        allData.Errors))
			end)
		end
	end

    --------------------------------------------------------
    -- CLIPBOARD
    --------------------------------------------------------
	local clipboardSuccess = false
	if CONFIG.CopyClipboard and setclipboard then
		clipboardSuccess = pcall(function()
			setclipboard(output)
		end)
	end

    --------------------------------------------------------
    -- COMPLETE
    --------------------------------------------------------
	DumpFinished = true
	local totalTime = tick() - StartTime
	updateUI("Dump complete!", "EvolsDumper finished successfully", 1)
	if CONFIG.ShowUI and Main then
		pcall(function()
			Title.Text = "EVOLSDUMPER • COMPLETE"
			StatsLabel.Text = string.format("Objects: %d | Properties: %d | Attributes: %d | Tags: %d", Stats.Objects, Stats.Properties, Stats.Attributes, Stats.Tags)
			SpeedLabel.Text = string.format("Remotes: %d | Scripts: %d | Modules: %d | Values: %d", Stats.Remotes, Stats.Scripts, Stats.Modules, Stats.Values)
			TimeLabel.Text = string.format("Time: %.2fs | Size: %.2f MB | Errors: %d", totalTime, Stats.Bytes / 1024 / 1024, Stats.Errors)
			CurrentObject.Text = "Clipboard: " .. tostring(clipboardSuccess) .. " | File: " .. tostring(fileResults.Main)
		end)
	end
	print("==============================================")
	print("              EVOLSDUMPER")
	print("==============================================")
	print("Objects:     ", Stats.Objects)
	print("Properties:  ", Stats.Properties)
	print("Attributes:  ", Stats.Attributes)
	print("Tags:        ", Stats.Tags)
	print("Remotes:     ", Stats.Remotes)
	print("Scripts:     ", Stats.Scripts)
	print("Modules:     ", Stats.Modules)
	print("Values:      ", Stats.Values)
	print("Errors:      ", Stats.Errors)
	print("Size:        ", string.format("%.2f MB", Stats.Bytes / 1024 / 1024))
	print("Time:        ", string.format("%.2fs", totalTime))
	print("Clipboard:   ", clipboardSuccess)
	print("==============================================")
	task.wait(6)
	if ScreenGui then
		pcall(function()
			ScreenGui:Destroy()
		end)
	end
end)

------------------------------------------------------------
-- LIVE UI LOOP
------------------------------------------------------------
if CONFIG.ShowUI then
	task.spawn(function()
		while not DumpFinished and ScreenGui and ScreenGui.Parent do
			local elapsed = tick() - StartTime
			local speed = Stats.Objects / math.max(elapsed, 0.001)
			pcall(function()
				StatsLabel.Text = string.format("Objects: %d | Properties: %d | Attributes: %d | Tags: %d", Stats.Objects, Stats.Properties, Stats.Attributes, Stats.Tags)
				SpeedLabel.Text = string.format("Speed: %d objects/s | Remotes: %d | Scripts: %d | Modules: %d", speed, Stats.Remotes, Stats.Scripts, Stats.Modules)
				TimeLabel.Text = string.format("Elapsed: %.1fs | Values: %d | Errors: %d", elapsed, Stats.Values, Stats.Errors)
			end)
			task.wait(
                CONFIG.ProgressUpdate)
		end
	end)
end
