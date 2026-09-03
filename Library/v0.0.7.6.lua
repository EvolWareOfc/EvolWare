-- ========================================================================= --
-- || EVOL-WARE UNIVERSAL UI LIBRARY - V2 MASTER SOURCE                   ||
-- || Host this file on GitHub (Raw) to load into your scripts.           ||
-- ========================================================================= --

local EvolLibrary = {}
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Prevent multiple instances
if CoreGui:FindFirstChild("EvolWare_Hub") then
	CoreGui.EvolWare_Hub:Destroy()
end

function EvolLibrary:CreateWindow(config)
	local Window = {
		Title = config.Title or "Evol-Ware",
		Subtitle = config.Subtitle or "Universal Hub",
		Version = config.Version or "v2.0",
		Theme = {
			Main = Color3.fromRGB(15, 16, 20),
			Lines = Color3.fromRGB(35, 36, 45),
			ElementBg = Color3.fromRGB(30, 31, 38),
			Hover = Color3.fromRGB(45, 46, 55),
			Text = Color3.fromRGB(245, 245, 250),
			TextMuted = Color3.fromRGB(140, 140, 155),
			Accent = config.AccentColor or Color3.fromRGB(0, 170, 255)
		},
		Flags = {}, -- Stores values of all elements with a Flag assigned
		ThemeUpdaters = {},
		Tabs = {},
		TabCount = 0,
		HideKey = config.HideKey or Enum.KeyCode.RightShift
	}

	function Window:SetThemeColor(newColor)
		self.Theme.Accent = newColor
		for _, updater in ipairs(self.ThemeUpdaters) do
			updater(newColor)
		end
	end

	-- ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "EvolWare_Hub"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = CoreGui
	Window.ScreenGui = screenGui

	-- Notifications Setup
	local notifContainer = Instance.new("Frame")
	notifContainer.Size = UDim2.new(0, 250, 1, -20)
	notifContainer.Position = UDim2.new(1, -270, 0, 10)
	notifContainer.BackgroundTransparency = 1
	notifContainer.Parent = screenGui
	local notifLayout = Instance.new("UIListLayout")
	notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
	notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	notifLayout.Padding = UDim.new(0, 10)
	notifLayout.Parent = notifContainer

	function Window:Notify(title, text, duration)
		duration = duration or 3
		local notif = Instance.new("Frame")
		notif.Size = UDim2.new(1, 50, 0, 60)
		notif.BackgroundColor3 = self.Theme.Main
		notif.BackgroundTransparency = 1
		notif.Parent = notifContainer
		Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 6)
		local stroke = Instance.new("UIStroke", notif)
		stroke.Color = self.Theme.Accent
		stroke.Transparency = 1
		table.insert(self.ThemeUpdaters, function(color) stroke.Color = color end)

		local tLbl = Instance.new("TextLabel", notif)
		tLbl.Size = UDim2.new(1, -20, 0, 20); tLbl.Position = UDim2.new(0, 10, 0, 8)
		tLbl.BackgroundTransparency = 1; tLbl.Text = title; tLbl.TextColor3 = self.Theme.Text
		tLbl.Font = Enum.Font.GothamBold; tLbl.TextSize = 13; tLbl.TextXAlignment = Enum.TextXAlignment.Left
		tLbl.TextTransparency = 1

		local dLbl = Instance.new("TextLabel", notif)
		dLbl.Size = UDim2.new(1, -20, 0, 20); dLbl.Position = UDim2.new(0, 10, 0, 30)
		dLbl.BackgroundTransparency = 1; dLbl.Text = text; dLbl.TextColor3 = self.Theme.TextMuted
		dLbl.Font = Enum.Font.Gotham; dLbl.TextSize = 12; dLbl.TextXAlignment = Enum.TextXAlignment.Left
		dLbl.TextTransparency = 1

		TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 0}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.4), {Transparency = 0}):Play()
		TweenService:Create(tLbl, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
		TweenService:Create(dLbl, TweenInfo.new(0.4), {TextTransparency = 0}):Play()

		task.delay(duration, function()
			TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 50, 0, 60), BackgroundTransparency = 1}):Play()
			TweenService:Create(stroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
			TweenService:Create(tLbl, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
			TweenService:Create(dLbl, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
			task.wait(0.4); notif:Destroy()
		end)
	end

	-- Main UI Frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(0, 320, 0, 550) 
	mainFrame.Position = UDim2.new(0.5, -160, 0.5, -275)
	mainFrame.BackgroundColor3 = Window.Theme.Main
	mainFrame.ClipsDescendants = true
	mainFrame.Parent = screenGui
	Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", mainFrame).Color = Window.Theme.Lines

	-- Header
	local headerFrame = Instance.new("Frame")
	headerFrame.Size = UDim2.new(1, 0, 0, 60)
	headerFrame.BackgroundTransparency = 1
	headerFrame.Parent = mainFrame

	local titleLbl = Instance.new("TextLabel", headerFrame)
	titleLbl.Size = UDim2.new(0, 100, 0, 20); titleLbl.Position = UDim2.new(0, 15, 0, 12)
	titleLbl.BackgroundTransparency = 1; titleLbl.Text = Window.Title
	titleLbl.TextColor3 = Window.Theme.Text; titleLbl.Font = Enum.Font.GothamBlack
	titleLbl.TextSize = 18; titleLbl.TextXAlignment = Enum.TextXAlignment.Left

	local verLbl = Instance.new("TextLabel", headerFrame)
	verLbl.Size = UDim2.new(0, 50, 0, 20); verLbl.Position = UDim2.new(0, 15 + titleLbl.TextBounds.X + 35, 0, 12)
	verLbl.BackgroundTransparency = 1; verLbl.Text = Window.Version
	verLbl.TextColor3 = Window.Theme.Accent; verLbl.Font = Enum.Font.GothamBold
	verLbl.TextSize = 10; verLbl.TextXAlignment = Enum.TextXAlignment.Left
	table.insert(Window.ThemeUpdaters, function(color) verLbl.TextColor3 = color end)

	local subLbl = Instance.new("TextLabel", headerFrame)
	subLbl.Size = UDim2.new(1, -30, 0, 15); subLbl.Position = UDim2.new(0, 15, 0, 32)
	subLbl.BackgroundTransparency = 1; subLbl.Text = Window.Subtitle
	subLbl.TextColor3 = Window.Theme.TextMuted; subLbl.Font = Enum.Font.GothamMedium
	subLbl.TextSize = 12; subLbl.TextXAlignment = Enum.TextXAlignment.Left

	-- Dragging Logic
	local dragging, dragInput, dragStart, startPos
	headerFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true; dragStart = input.Position; startPos = mainFrame.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)
	headerFrame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	-- Toggle UI Keybind
	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe and UserInputService:GetFocusedTextBox() then return end
		if input.KeyCode == Window.HideKey then
			screenGui.Enabled = not screenGui.Enabled
		end
	end)

	-- Tabs Container
	local tabContainer = Instance.new("Frame")
	tabContainer.Size = UDim2.new(1, 0, 0, 30); tabContainer.Position = UDim2.new(0, 0, 0, 60)
	tabContainer.BackgroundTransparency = 1; tabContainer.Parent = mainFrame
	
	local tabLine = Instance.new("Frame")
	tabLine.Size = UDim2.new(1, 0, 0, 1); tabLine.Position = UDim2.new(0, 0, 1, -1)
	tabLine.BackgroundColor3 = Window.Theme.Lines; tabLine.BorderSizePixel = 0; tabLine.Parent = tabContainer

	local tabScroll = Instance.new("ScrollingFrame", tabContainer)
	tabScroll.Size = UDim2.new(1, -10, 1, -1); tabScroll.Position = UDim2.new(0, 5, 0, 0)
	tabScroll.BackgroundTransparency = 1; tabScroll.ScrollBarThickness = 0
	tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0); tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
	local tabListLayout = Instance.new("UIListLayout", tabScroll)
	tabListLayout.FillDirection = Enum.FillDirection.Horizontal; tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	function Window:CreateTab(name)
		Window.TabCount = Window.TabCount + 1
		local isDefault = (Window.TabCount == 1)

		local scroll = Instance.new("ScrollingFrame")
		scroll.Size = UDim2.new(1, -30, 1, -105); scroll.Position = UDim2.new(0, 15, 0, 95)
		scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 2
		scroll.ScrollBarImageColor3 = Window.Theme.Accent
		scroll.CanvasSize = UDim2.new(0, 0, 0, 0); scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scroll.Visible = isDefault; scroll.Parent = mainFrame
		table.insert(Window.ThemeUpdaters, function(color) scroll.ScrollBarImageColor3 = color end)

		local layout = Instance.new("UIListLayout", scroll)
		layout.Padding = UDim.new(0, 8); layout.SortOrder = Enum.SortOrder.LayoutOrder
		Instance.new("UIPadding", scroll).PaddingBottom = UDim.new(0, 15)

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 80, 1, 0); btn.BackgroundTransparency = 1
		btn.Text = name; btn.TextColor3 = isDefault and Window.Theme.Text or Window.Theme.TextMuted
		btn.Font = Enum.Font.GothamMedium; btn.TextSize = 12; btn.Parent = tabScroll
		btn.Size = UDim2.new(0, btn.TextBounds.X + 20, 1, 0)

		local ind = Instance.new("Frame")
		ind.Size = UDim2.new(1, 0, 0, 2); ind.Position = UDim2.new(0, 0, 1, -1)
		ind.BackgroundColor3 = isDefault and Window.Theme.Accent or Window.Theme.Lines
		ind.BorderSizePixel = 0; ind.Parent = btn

		local tabObj = { Name = name, Scroll = scroll }
		if isDefault then Window.ActiveTab = tabObj end

		table.insert(Window.ThemeUpdaters, function(color)
			if Window.ActiveTab == tabObj then ind.BackgroundColor3 = color end
		end)

		btn.MouseButton1Click:Connect(function()
			for _, t in ipairs(Window.Tabs) do
				t.Scroll.Visible = false
			end
			for _, child in ipairs(tabScroll:GetChildren()) do
				if child:IsA("TextButton") then
					TweenService:Create(child, TweenInfo.new(0.2), {TextColor3 = Window.Theme.TextMuted}):Play()
					TweenService:Create(child:FindFirstChildOfClass("Frame"), TweenInfo.new(0.2), {BackgroundColor3 = Window.Theme.Lines}):Play()
				end
			end
			Window.ActiveTab = tabObj; scroll.Visible = true
			TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = Window.Theme.Text}):Play()
			TweenService:Create(ind, TweenInfo.new(0.2), {BackgroundColor3 = Window.Theme.Accent}):Play()
		end)
		table.insert(Window.Tabs, tabObj)

		-- ========================================================================= --
		-- UI ELEMENTS BUILDER
		-- ========================================================================= --

		function tabObj:CreateHeader(text)
			-- Support passing just a string OR a table (for standardisation)
			local titleText = type(text) == "table" and text.Name or text
			
			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(1, 0, 0, 16)
			lbl.BackgroundTransparency = 1
			lbl.Text = titleText
			lbl.TextColor3 = Window.Theme.TextMuted
			lbl.TextSize = 10
			lbl.Font = Enum.Font.GothamBold
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Parent = self.Scroll
		end

		function tabObj:CreateSeparator()
			local sepContainer = Instance.new("Frame")
			sepContainer.Size = UDim2.new(1, 0, 0, 8)
			sepContainer.BackgroundTransparency = 1
			sepContainer.Parent = self.Scroll

			local sep = Instance.new("Frame")
			sep.Size = UDim2.new(1, 10, 0, 1)
			sep.Position = UDim2.new(0, -5, 0.5, 0)
			sep.BackgroundColor3 = Window.Theme.Lines
			sep.BorderSizePixel = 0
			sep.Parent = sepContainer
		end

		function tabObj:CreateLabel(config)
			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(1, 0, 0, 16); lbl.BackgroundTransparency = 1
			lbl.Text = config.Name or "Label"; lbl.TextColor3 = config.UseAccent and Window.Theme.Accent or Window.Theme.Text
			lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12
			lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = self.Scroll
			if config.UseAccent then table.insert(Window.ThemeUpdaters, function(c) lbl.TextColor3 = c end) end
			return { SetText = function(_, t) lbl.Text = t end }
		end

		function tabObj:CreateParagraph(config)
			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(1, 0, 0, 0); lbl.BackgroundTransparency = 1
			lbl.Text = config.Content or ""; lbl.TextColor3 = Window.Theme.TextMuted
			lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12; lbl.TextWrapped = true
			lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.AutomaticSize = Enum.AutomaticSize.Y
			lbl.Parent = self.Scroll
			return { SetText = function(_, t) lbl.Text = t end }
		end

		function tabObj:CreateButton(config)
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 30); btn.BackgroundColor3 = Window.Theme.ElementBg
			btn.Text = config.Name or "Button"; btn.TextColor3 = Window.Theme.Text
			btn.Font = Enum.Font.GothamMedium; btn.TextSize = 12; btn.Parent = self.Scroll
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
			Instance.new("UIStroke", btn).Color = Window.Theme.Lines
			btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Window.Theme.Hover}):Play() end)
			btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Window.Theme.ElementBg}):Play() end)
			btn.MouseButton1Click:Connect(function() if config.Callback then config.Callback() end end)
		end

		function tabObj:CreateToggle(config)
			local flag = config.Flag
			local state = config.Default or false
			if flag then Window.Flags[flag] = state end

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 24); frame.BackgroundTransparency = 1; frame.Parent = self.Scroll

			local lbl = Instance.new("TextLabel", frame)
			lbl.Size = UDim2.new(1, -40, 1, 0); lbl.BackgroundTransparency = 1
			lbl.Text = config.Name or "Toggle"; lbl.TextColor3 = Window.Theme.Text
			lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left

			local tBtn = Instance.new("TextButton", frame)
			tBtn.Size = UDim2.new(0, 36, 0, 18); tBtn.Position = UDim2.new(1, -36, 0.5, -9)
			tBtn.BackgroundColor3 = state and Window.Theme.Accent or Window.Theme.ElementBg
			tBtn.Text = ""; Instance.new("UICorner", tBtn).CornerRadius = UDim.new(1, 0)
			table.insert(Window.ThemeUpdaters, function(c) if state then tBtn.BackgroundColor3 = c end end)

			local circle = Instance.new("Frame", tBtn)
			circle.Size = UDim2.new(0, 14, 0, 14)
			circle.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
			circle.BackgroundColor3 = state and Color3.fromRGB(255,255,255) or Window.Theme.TextMuted
			Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

			local function trigger(force)
				state = (force ~= nil) and force or not state
				if flag then Window.Flags[flag] = state end
				local ti = TweenInfo.new(0.2)
				TweenService:Create(tBtn, ti, {BackgroundColor3 = state and Window.Theme.Accent or Window.Theme.ElementBg}):Play()
				TweenService:Create(circle, ti, {
					Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
					BackgroundColor3 = state and Color3.new(1,1,1) or Window.Theme.TextMuted
				}):Play()
				if config.Callback then config.Callback(state) end
			end

			tBtn.MouseButton1Click:Connect(function() trigger() end)
			return { Set = function(_, val) trigger(val) end, Current = function() return state end }
		end

		function tabObj:CreateSlider(config)
			local flag = config.Flag
			local min = config.Min or 0
			local max = config.Max or 100
			local val = config.Default or min
			if flag then Window.Flags[flag] = val end

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 40); frame.BackgroundTransparency = 1; frame.Parent = self.Scroll

			local lbl = Instance.new("TextLabel", frame)
			lbl.Size = UDim2.new(1, -50, 0, 16); lbl.BackgroundTransparency = 1
			lbl.Text = config.Name or "Slider"; lbl.TextColor3 = Window.Theme.Text
			lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left

			local vLbl = Instance.new("TextLabel", frame)
			vLbl.Size = UDim2.new(0, 48, 0, 16); vLbl.Position = UDim2.new(1, -48, 0, 0)
			vLbl.BackgroundTransparency = 1; vLbl.Text = tostring(val)
			vLbl.TextColor3 = Window.Theme.Accent; vLbl.Font = Enum.Font.GothamBold
			vLbl.TextSize = 12; vLbl.TextXAlignment = Enum.TextXAlignment.Right
			table.insert(Window.ThemeUpdaters, function(c) vLbl.TextColor3 = c end)

			local track = Instance.new("TextButton", frame)
			track.Size = UDim2.new(1, 0, 0, 4); track.Position = UDim2.new(0, 0, 0, 28)
			track.BackgroundColor3 = Window.Theme.ElementBg; track.Text = ""; track.AutoButtonColor = false
			Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

			local pct = math.clamp((val - min) / (max - min), 0, 1)
			local fill = Instance.new("Frame", track)
			fill.Size = UDim2.new(pct, 0, 1, 0); fill.BackgroundColor3 = Window.Theme.Accent
			Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
			table.insert(Window.ThemeUpdaters, function(c) fill.BackgroundColor3 = c end)

			local dragging = false
			local function update(input)
				local delta = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				val = math.floor(min + (max - min) * delta)
				if flag then Window.Flags[flag] = val end
				fill.Size = UDim2.new(delta, 0, 1, 0); vLbl.Text = tostring(val)
				if config.Callback then config.Callback(val) end
			end

			track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(i) end end)
			UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
			UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
			
			return { Set = function(_, num) val=math.clamp(num,min,max); fill.Size=UDim2.new((val-min)/(max-min),0,1,0); vLbl.Text=tostring(val); if flag then Window.Flags[flag]=val end; if config.Callback then config.Callback(val) end end }
		end

		function tabObj:CreateDropdown(config)
			local flag = config.Flag
			local options = config.Options or {}
			local selected = config.Default or options[1]
			if flag then Window.Flags[flag] = selected end

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 30); frame.BackgroundColor3 = Window.Theme.ElementBg
			frame.ClipsDescendants = true; frame.Parent = self.Scroll
			Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
			Instance.new("UIStroke", frame).Color = Window.Theme.Lines

			local mainBtn = Instance.new("TextButton", frame)
			mainBtn.Size = UDim2.new(1, 0, 0, 30); mainBtn.BackgroundTransparency = 1
			mainBtn.Text = "  " .. (config.Name or "Dropdown") .. " : " .. tostring(selected)
			mainBtn.TextColor3 = Window.Theme.Text; mainBtn.Font = Enum.Font.GothamMedium
			mainBtn.TextSize = 12; mainBtn.TextXAlignment = Enum.TextXAlignment.Left

			local icon = Instance.new("TextLabel", mainBtn)
			icon.Size = UDim2.new(0, 20, 1, 0); icon.Position = UDim2.new(1, -25, 0, 0)
			icon.BackgroundTransparency = 1; icon.Text = "+"; icon.TextColor3 = Window.Theme.TextMuted
			icon.Font = Enum.Font.GothamBold; icon.TextSize = 14

			local optContainer = Instance.new("Frame", frame)
			optContainer.Size = UDim2.new(1, 0, 1, -30); optContainer.Position = UDim2.new(0, 0, 0, 30)
			optContainer.BackgroundTransparency = 1
			local list = Instance.new("UIListLayout", optContainer)
			list.SortOrder = Enum.SortOrder.LayoutOrder

			local open = false
			local function toggleDrop()
				open = not open
				icon.Text = open and "-" or "+"
				local tgtHeight = open and (30 + (#options * 26)) or 30
				TweenService:Create(frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, tgtHeight)}):Play()
			end
			mainBtn.MouseButton1Click:Connect(toggleDrop)

			local function buildOptions()
				for _, child in ipairs(optContainer:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
				for _, opt in ipairs(options) do
					local ob = Instance.new("TextButton", optContainer)
					ob.Size = UDim2.new(1, 0, 0, 26); ob.BackgroundColor3 = Window.Theme.ElementBg; ob.BorderSizePixel = 0
					ob.Text = tostring(opt); ob.TextColor3 = (opt == selected) and Window.Theme.Accent or Window.Theme.TextMuted
					ob.Font = Enum.Font.Gotham; ob.TextSize = 12
					ob.MouseEnter:Connect(function() TweenService:Create(ob, TweenInfo.new(0.1), {BackgroundColor3 = Window.Theme.Hover}):Play() end)
					ob.MouseLeave:Connect(function() TweenService:Create(ob, TweenInfo.new(0.1), {BackgroundColor3 = Window.Theme.ElementBg}):Play() end)
					ob.MouseButton1Click:Connect(function()
						selected = opt
						if flag then Window.Flags[flag] = selected end
						mainBtn.Text = "  " .. (config.Name or "Dropdown") .. " : " .. tostring(selected)
						if config.Callback then config.Callback(selected) end
						toggleDrop()
						buildOptions() -- Refresh colors
					end)
				end
			end
			buildOptions()

			return { 
				Refresh = function(_, newOpts) 
					options = newOpts; if open then toggleDrop() end; buildOptions() 
				end 
			}
		end

		function tabObj:CreateKeybind(config)
			local flag = config.Flag
			local currentKey = config.Default or Enum.KeyCode.E
			if flag then Window.Flags[flag] = currentKey end

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 26); frame.BackgroundTransparency = 1; frame.Parent = self.Scroll

			local lbl = Instance.new("TextLabel", frame)
			lbl.Size = UDim2.new(1, -100, 1, 0); lbl.BackgroundTransparency = 1
			lbl.Text = config.Name or "Keybind"; lbl.TextColor3 = Window.Theme.Text
			lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left

			local btn = Instance.new("TextButton", frame)
			btn.Size = UDim2.new(0, 90, 1, 0); btn.Position = UDim2.new(1, -90, 0, 0)
			btn.BackgroundColor3 = Window.Theme.ElementBg
			btn.Text = currentKey.Name; btn.TextColor3 = Window.Theme.Accent
			btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
			Instance.new("UIStroke", btn).Color = Window.Theme.Lines
			table.insert(Window.ThemeUpdaters, function(c) btn.TextColor3 = c end)

			local listening = false
			btn.MouseButton1Click:Connect(function()
				listening = true; btn.Text = "..."
			end)

			UserInputService.InputBegan:Connect(function(input, gpe)
				if not listening or gpe then return end
				if input.UserInputType == Enum.UserInputType.Keyboard then
					listening = false; currentKey = input.KeyCode
					if flag then Window.Flags[flag] = currentKey end
					btn.Text = currentKey.Name
					if config.Callback then config.Callback(currentKey) end
				end
			end)
		end

		function tabObj:CreateTextBox(config)
			local flag = config.Flag
			if flag then Window.Flags[flag] = "" end

			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 45); frame.BackgroundTransparency = 1; frame.Parent = self.Scroll

			local lbl = Instance.new("TextLabel", frame)
			lbl.Size = UDim2.new(1, 0, 0, 15); lbl.BackgroundTransparency = 1
			lbl.Text = config.Name or "TextBox"; lbl.TextColor3 = Window.Theme.Text
			lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left

			local box = Instance.new("TextBox", frame)
			box.Size = UDim2.new(1, 0, 0, 26); box.Position = UDim2.new(0, 0, 0, 19)
			box.BackgroundColor3 = Window.Theme.ElementBg
			box.PlaceholderText = config.Placeholder or "Type here..."
			box.Text = ""; box.TextColor3 = Window.Theme.Text
			box.Font = Enum.Font.Gotham; box.TextSize = 12
			box.ClearTextOnFocus = false
			Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
			Instance.new("UIStroke", box).Color = Window.Theme.Lines

			box.FocusLost:Connect(function()
				local txt = box.Text
				if flag then Window.Flags[flag] = txt end
				if config.Callback then config.Callback(txt) end
			end)
		end

		return tabObj
	end
	return Window
end

return EvolLibrary
