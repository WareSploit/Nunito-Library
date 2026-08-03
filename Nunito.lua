local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--=========================================================================
-- THEMES SYSTEM (полноценные темы: Dark/Light/etc)
--=========================================================================
local Theme = {
	Background  = Color3.fromHex("0A0A0A"),
	Background2 = Color3.fromHex("121212"),
	Background3 = Color3.fromHex("1A1A1A"),
	Accent      = Color3.fromHex("8A2BE2"),
	Accent2     = Color3.fromHex("C77DFF"),
	Text        = Color3.fromHex("FFFFFF"),
	TextDim     = Color3.fromHex("A0A0A0"),
	Border      = Color3.fromHex("282828"),
	Error       = Color3.fromHex("DC3232"),
	Warning     = Color3.fromHex("F0C83C"),
	Success     = Color3.fromHex("50C878"),
}

-- Реестр всех Instance'ов с ролями (для перекраски при смене темы)
local ThemeRegistry = {}
local function reg(obj, role)
	if not obj or not role then return obj end
	if not ThemeRegistry[role] then ThemeRegistry[role] = {} end
	table.insert(ThemeRegistry[role], obj)
	return obj
end

local THEMES = {
	Dark = {
		Background  = Color3.fromHex("0A0A0A"),
		Background2 = Color3.fromHex("121212"),
		Background3 = Color3.fromHex("1A1A1A"),
		Text        = Color3.fromHex("FFFFFF"),
		TextDim     = Color3.fromHex("A0A0A0"),
		Border      = Color3.fromHex("282828"),
	},
	Light = {
		Background  = Color3.fromHex("F5F5F5"),
		Background2 = Color3.fromHex("E8E8E8"),
		Background3 = Color3.fromHex("DDDDDD"),
		Text        = Color3.fromHex("1A1A1A"),
		TextDim     = Color3.fromHex("666666"),
		Border      = Color3.fromHex("CCCCCC"),
	},
	Midnight = {
		Background  = Color3.fromHex("050510"),
		Background2 = Color3.fromHex("0A0A1F"),
		Background3 = Color3.fromHex("14142B"),
		Text        = Color3.fromHex("E8E8FF"),
		TextDim     = Color3.fromHex("8888AA"),
		Border      = Color3.fromHex("2A2A44"),
	},
	Crimson = {
		Background  = Color3.fromHex("0A0505"),
		Background2 = Color3.fromHex("1A0A0A"),
		Background3 = Color3.fromHex("2B0F0F"),
		Text        = Color3.fromHex("FFE8E8"),
		TextDim     = Color3.fromHex("AA8888"),
		Border      = Color3.fromHex("442A2A"),
	},
}

local ACCENT_PRESETS = {
	{name = "Purple",  c1 = Color3.fromHex("8A2BE2"), c2 = Color3.fromHex("C77DFF")},
	{name = "Blue",    c1 = Color3.fromHex("3278E2"), c2 = Color3.fromHex("78B2FF")},
	{name = "Red",     c1 = Color3.fromHex("E23250"), c2 = Color3.fromHex("FF788C")},
	{name = "Green",   c1 = Color3.fromHex("3CB464"), c2 = Color3.fromHex("8CE6AA")},
	{name = "Orange",  c1 = Color3.fromHex("E28C32"), c2 = Color3.fromHex("FFB878")},
	{name = "Pink",    c1 = Color3.fromHex("E232B4"), c2 = Color3.fromHex("FF78D4")},
}

local function applyTheme(themeName)
	local t = THEMES[themeName]
	if not t then return end
	for k, v in pairs(t) do Theme[k] = v end

	for role, list in pairs(ThemeRegistry) do
		local color = Theme[role]
		if color then
			for _, obj in ipairs(list) do
				if obj and obj.Parent then
					if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
						if role == "Text" or role == "TextDim" then
							obj.TextColor3 = color
						elseif role == "Background" or role == "Background2" or role == "Background3" then
							obj.BackgroundColor3 = color
						end
					else
						if role == "Background" or role == "Background2" or role == "Background3" then
							obj.BackgroundColor3 = color
						elseif role == "Border" and obj:IsA("UIStroke") then
							obj.Color = color
						end
					end
				end
			end
		end
	end
end

local function applyAccent(c1, c2)
	Theme.Accent = c1
	Theme.Accent2 = c2
	for _, list in ipairs({ThemeRegistry.Accent or {}, ThemeRegistry.Accent2 or {}}) do
		for _, obj in ipairs(list) do
			if obj and obj.Parent then
				obj.BackgroundColor3 = list == ThemeRegistry.Accent and c1 or c2
			end
		end
	end
	for _, g in ipairs(ThemeRegistry.Gradient or {}) do
		if g and g.Parent then
			g.Color = ColorSequence.new(c1, c2)
		end
	end
end

--=========================================================================
-- UTILITIES
--=========================================================================
local function tween(obj, props, duration)
	local t = TweenService:Create(obj, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function makeStroke(parent)
	local s = Instance.new("UIStroke")
	reg(s, "Border")
	s.Color = Theme.Border
	s.Thickness = 1
	s.Parent = parent
	return s
end

local function makeGradient(parent, c1, c2)
	local g = Instance.new("UIGradient")
	reg(g, "Gradient")
	g.Color = ColorSequence.new(c1 or Theme.Accent, c2 or Theme.Accent2)
	g.Rotation = 90
	g.Parent = parent
	return g
end

local CONFIG_FOLDER = "NunitoLibrary/configs"
local HasFS = typeof(isfolder) == "function" and typeof(makefolder) == "function"
local MemoryConfigs = {}

local function ensureFolder()
	if HasFS and not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
end

local function listConfigs()
	local names = {}
	if HasFS then
		ensureFolder()
		for _, path in ipairs(listfiles(CONFIG_FOLDER)) do
			local n = path:match("[^/\\]+%.json$")
			if n then table.insert(names, n:gsub("%.json$", "")) end
		end
	else
		for n in pairs(MemoryConfigs) do table.insert(names, n) end
	end
	table.sort(names)
	return names
end

local function saveConfig(name, data)
	if name == "" then return false end
	local ok, encoded = pcall(HttpService.JSONEncode, HttpService, data)
	if not ok then return false end
	if HasFS then
		ensureFolder()
		pcall(writefile, CONFIG_FOLDER .. "/" .. name .. ".json", encoded)
	else
		MemoryConfigs[name] = encoded
	end
	return true
end

local function loadConfig(name)
	local raw
	if HasFS then
		local ok, content = pcall(readfile, CONFIG_FOLDER .. "/" .. name .. ".json")
		if not ok then return nil end
		raw = content
	else
		raw = MemoryConfigs[name]
		if not raw then return nil end
	end
	local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
	return ok and decoded or nil
end

local function deleteConfig(name)
	if HasFS then
		pcall(delfile, CONFIG_FOLDER .. "/" .. name .. ".json")
	else
		MemoryConfigs[name] = nil
	end
end

--=========================================================================
-- LIBRARY ROOT
--=========================================================================
local Nunito = {}
Nunito.__index = Nunito

function Nunito:CreateWindow(config)
	config = config or {}
	local self = setmetatable({}, Nunito)

	-- Общий реестр элементов для конфигов (со всех вкладок)
	local allElements = {}

	-- Сбрасываем реестр темы при создании окна
	ThemeRegistry = {}

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "NunitoGUI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = PlayerGui

	--======================================================
	-- WATERMARK
	--======================================================
	local Watermark = Instance.new("Frame")
	Watermark.Size = UDim2.fromOffset(120, 22)
	Watermark.Position = UDim2.new(1, -128, 1, -30)
	Watermark.BackgroundColor3 = Theme.Background2
	Watermark.BorderSizePixel = 0
	Watermark.Parent = ScreenGui
	reg(Watermark, "Background2")
	makeStroke(Watermark)

	local WM_Accent = Instance.new("Frame")
	WM_Accent.Size = UDim2.new(0, 3, 1, 0)
	WM_Accent.BackgroundColor3 = Theme.Accent
	WM_Accent.BorderSizePixel = 0
	WM_Accent.Parent = Watermark
	reg(WM_Accent, "Accent")

	local WM_Label = Instance.new("TextLabel")
	WM_Label.BackgroundTransparency = 1
	WM_Label.Size = UDim2.new(1, -6, 1, 0)
	WM_Label.Position = UDim2.fromOffset(6, 0)
	WM_Label.Font = Enum.Font.RobotoMono
	WM_Label.Text = "Nunito v1.0"
	WM_Label.TextColor3 = Theme.Text
	WM_Label.TextSize = 11
	WM_Label.TextXAlignment = Enum.TextXAlignment.Left
	WM_Label.Parent = Watermark
	reg(WM_Label, "Text")

	--======================================================
	-- NOTIFICATIONS
	--======================================================
	local NotifHolder = Instance.new("Frame")
	NotifHolder.Size = UDim2.new(0, 320, 1, -60)
	NotifHolder.Position = UDim2.new(1, -332, 0, 20)
	NotifHolder.BackgroundTransparency = 1
	NotifHolder.Parent = ScreenGui

	local NotifLayout = Instance.new("UIListLayout")
	NotifLayout.Padding = UDim.new(0, 8)
	NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
	NotifLayout.Parent = NotifHolder

	--======================================================
	-- WINDOW
	--======================================================
	local Window = Instance.new("Frame")
	Window.Size = UDim2.fromOffset(560, 420)
	Window.Position = UDim2.fromScale(0.5, 0.5)
	Window.AnchorPoint = Vector2.new(0.5, 0.5)
	Window.BackgroundColor3 = Theme.Background
	reg(Window, "Background")
	Window.BorderSizePixel = 0
	Window.ClipsDescendants = true
	Window.Parent = ScreenGui
	makeStroke(Window)

	local TitleBar = Instance.new("Frame")
	TitleBar.Size = UDim2.new(1, 0, 0, 34)
	TitleBar.BackgroundColor3 = Theme.Background2
	reg(TitleBar, "Background2")
	TitleBar.BorderSizePixel = 0
	TitleBar.Parent = Window

	local AccentLine = Instance.new("Frame")
	AccentLine.Size = UDim2.new(1, 0, 0, 2)
	AccentLine.Position = UDim2.new(0, 0, 1, 0)
	AccentLine.BorderSizePixel = 0
	AccentLine.Parent = TitleBar
	makeGradient(AccentLine)

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Position = UDim2.fromOffset(12, 0)
	TitleLabel.Size = UDim2.new(1, -100, 1, 0)
	TitleLabel.Font = Enum.Font.RobotoMono
	TitleLabel.Text = config.Title or "Nunito"
	TitleLabel.TextColor3 = Theme.Text
	reg(TitleLabel, "Text")
	TitleLabel.TextSize = 14
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = TitleBar

	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.fromOffset(30, 30)
	CloseBtn.Position = UDim2.new(1, -30, 0, 0)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Font = Enum.Font.RobotoMono
	CloseBtn.Text = "✕"
	CloseBtn.TextColor3 = Theme.TextDim
	reg(CloseBtn, "TextDim")
	CloseBtn.TextSize = 14
	CloseBtn.Parent = TitleBar

	local MinBtn = Instance.new("TextButton")
	MinBtn.Size = UDim2.fromOffset(30, 30)
	MinBtn.Position = UDim2.new(1, -60, 0, 0)
	MinBtn.BackgroundTransparency = 1
	MinBtn.Font = Enum.Font.RobotoMono
	MinBtn.Text = "—"
	MinBtn.TextColor3 = Theme.TextDim
	reg(MinBtn, "TextDim")
	MinBtn.TextSize = 14
	MinBtn.Parent = TitleBar

	CloseBtn.MouseEnter:Connect(function() CloseBtn.TextColor3 = Theme.Error end)
	CloseBtn.MouseLeave:Connect(function() CloseBtn.TextColor3 = Theme.TextDim end)
	MinBtn.MouseEnter:Connect(function() MinBtn.TextColor3 = Theme.Text end)
	MinBtn.MouseLeave:Connect(function() MinBtn.TextColor3 = Theme.TextDim end)

	local dragging, dragStart, startPos = false, nil, nil
	TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = Window.Position
		end
	end)
	TitleBar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	local ContentArea = Instance.new("Frame")
	ContentArea.Size = UDim2.new(1, 0, 1, -34)
	ContentArea.Position = UDim2.fromOffset(0, 34)
	ContentArea.BackgroundTransparency = 1
	ContentArea.Parent = Window

	-- Фикс: было UDim2.fromOffset(140, 1, 0) — 3 аргумента вместо 2
	local Sidebar = Instance.new("Frame")
	Sidebar.Size = UDim2.new(0, 140, 1, 0)
	Sidebar.BackgroundColor3 = Theme.Background2
	reg(Sidebar, "Background2")
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = ContentArea
	makeStroke(Sidebar)

	local SidebarLayout = Instance.new("UIListLayout")
	SidebarLayout.Padding = UDim.new(0, 2)
	SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	SidebarLayout.Parent = Sidebar

	local TabContainer = Instance.new("Frame")
	TabContainer.Size = UDim2.new(1, -140, 1, 0)
	TabContainer.Position = UDim2.fromOffset(140, 0)
	TabContainer.BackgroundTransparency = 1
	TabContainer.Parent = ContentArea

	--======================================================
	-- DROPDOWN POPUP HOLDER (чтобы список открывался поверх)
	--======================================================
	local DropdownHolder = Instance.new("Frame")
	DropdownHolder.Size = UDim2.fromScale(1, 1)
	DropdownHolder.BackgroundTransparency = 1
	DropdownHolder.ZIndex = 10
	DropdownHolder.Parent = ScreenGui

	local tabs = {}
	local activeTab = nil
	local openDropdowns = {}

	local function switchTab(tabObj)
		-- Закрываем все открытые dropdown при смене вкладки
		for dd in pairs(openDropdowns) do
			if dd.close then dd.close() end
		end

		if activeTab then
			activeTab.Page.Visible = false
			activeTab.Indicator.BackgroundTransparency = 1
			activeTab.Btn.TextColor3 = Theme.TextDim
		end
		activeTab = tabObj
		tabObj.Page.Visible = true
		tabObj.Btn.TextColor3 = Theme.Text
		tween(tabObj.Indicator, {BackgroundTransparency = 0}, 0.15)
	end

	function self:CreateTab(name)
		local tab = {}

		local Btn = Instance.new("TextButton")
		Btn.Size = UDim2.new(1, -8, 0, 32)
		Btn.BackgroundTransparency = 1
		Btn.Font = Enum.Font.RobotoMono
		Btn.Text = "  " .. name
		Btn.TextColor3 = Theme.TextDim
		reg(Btn, "TextDim")
		Btn.TextSize = 13
		Btn.TextXAlignment = Enum.TextXAlignment.Left
		Btn.Parent = Sidebar

		local Indicator = Instance.new("Frame")
		Indicator.Size = UDim2.fromOffset(3, 20)
		Indicator.Position = UDim2.new(0, 0, 0.5, -10)
		Indicator.BackgroundColor3 = Theme.Accent
		reg(Indicator, "Accent")
		Indicator.BackgroundTransparency = 1
		Indicator.BorderSizePixel = 0
		Indicator.Parent = Btn
		makeGradient(Indicator)

		local Page = Instance.new("ScrollingFrame")
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.BorderSizePixel = 0
		Page.ScrollBarThickness = 3
		Page.ScrollBarImageColor3 = Theme.Accent
		Page.CanvasSize = UDim2.new(0, 0, 0, 0)
		Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		Page.Visible = false
		Page.Parent = TabContainer

		local PageLayout = Instance.new("UIListLayout")
		PageLayout.Padding = UDim.new(0, 6)
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PageLayout.Parent = Page

		local PagePadding = Instance.new("UIPadding")
		PagePadding.PaddingTop = UDim.new(0, 10)
		PagePadding.PaddingLeft = UDim.new(0, 12)
		PagePadding.PaddingRight = UDim.new(0, 12)
		PagePadding.PaddingBottom = UDim.new(0, 10)
		PagePadding.Parent = Page

		Btn.MouseButton1Click:Connect(function() switchTab(tab) end)

		tab.Btn = Btn
		tab.Indicator = Indicator
		tab.Page = Page
		table.insert(tabs, tab)
		if #tabs == 1 then switchTab(tab) end

		function tab:CreateSection(name)
			local sec = {}
			local SecFrame = Instance.new("Frame")
			SecFrame.Size = UDim2.new(1, 0, 0, 28)
			SecFrame.BackgroundColor3 = Theme.Background2
			reg(SecFrame, "Background2")
			SecFrame.BorderSizePixel = 0
			SecFrame.Parent = Page
			makeStroke(SecFrame)

			local SecLabel = Instance.new("TextLabel")
			SecLabel.BackgroundTransparency = 1
			SecLabel.Position = UDim2.fromOffset(8, 0)
			SecLabel.Size = UDim2.new(1, 0, 1, 0)
			SecLabel.Font = Enum.Font.RobotoMono
			SecLabel.Text = name
			SecLabel.TextColor3 = Theme.Accent2
			reg(SecLabel, "Accent2")
			SecLabel.TextSize = 13
			SecLabel.TextXAlignment = Enum.TextXAlignment.Left
			SecLabel.Parent = SecFrame

			local SecContent = Instance.new("Frame")
			SecContent.Size = UDim2.new(1, 0, 0, 0)
			SecContent.BackgroundTransparency = 1
			SecContent.Position = UDim2.fromOffset(0, 28)
			SecContent.Parent = SecFrame

			local SecLayout = Instance.new("UIListLayout")
			SecLayout.Padding = UDim.new(0, 4)
			SecLayout.SortOrder = Enum.SortOrder.LayoutOrder
			SecLayout.Parent = SecContent

			SecContent.ChildAdded:Connect(function()
				task.wait()
				local h = SecLayout.AbsoluteContentSize.Y
				SecContent.Size = UDim2.new(1, 0, 0, h)
				tween(SecFrame, {Size = UDim2.new(1, 0, 0, 28 + h)}, 0.15)
			end)

			-- TOGGLE
			function sec:Toggle(cfg)
				cfg = cfg or {}
				local state = cfg.Default or false
				local api = {}

				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 28)
				Frame.BackgroundColor3 = Theme.Background3
				reg(Frame, "Background3")
				Frame.BorderSizePixel = 0
				Frame.Parent = SecContent
				makeStroke(Frame)

				local Label = Instance.new("TextLabel")
				Label.BackgroundTransparency = 1
				Label.Position = UDim2.fromOffset(8, 0)
				Label.Size = UDim2.new(1, -50, 1, 0)
				Label.Font = Enum.Font.RobotoMono
				Label.Text = cfg.Text or "Toggle"
				Label.TextColor3 = Theme.Text
				reg(Label, "Text")
				Label.TextSize = 13
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Frame

				local Track = Instance.new("Frame")
				Track.Size = UDim2.fromOffset(32, 14)
				Track.Position = UDim2.new(1, -42, 0.5, -7)
				Track.BackgroundColor3 = Theme.Background
				reg(Track, "Background")
				Track.BorderSizePixel = 0
				Track.Parent = Frame
				makeStroke(Track)

				local Knob = Instance.new("Frame")
				Knob.Size = UDim2.fromOffset(10, 10)
				Knob.Position = UDim2.fromOffset(2, 2)
				Knob.BackgroundColor3 = state and Theme.Accent2 or Theme.TextDim
				Knob.BorderSizePixel = 0
				Knob.Parent = Track

				local function update()
					if state then
						tween(Knob, {Position = UDim2.fromOffset(20, 2), BackgroundColor3 = Theme.Accent2}, 0.15)
						tween(Track, {BackgroundColor3 = Theme.Accent}, 0.15)
					else
						tween(Knob, {Position = UDim2.fromOffset(2, 2), BackgroundColor3 = Theme.TextDim}, 0.15)
						tween(Track, {BackgroundColor3 = Theme.Background}, 0.15)
					end
					if cfg.Callback then cfg.Callback(state) end
				end

				Frame.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						state = not state
						update()
					end
				end)

				function api:Set(v) state = v; update() end
				function api:Get() return state end

				if state then update() end
				table.insert(allElements, {Key = cfg.Text, Type = "Toggle", API = api})
				return api
			end

			-- SLIDER
			function sec:Slider(cfg)
				cfg = cfg or {}
				local min = cfg.Min or 0
				local max = cfg.Max or 100
				local val = cfg.Default or min
				local api = {}

				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 36)
				Frame.BackgroundColor3 = Theme.Background3
				reg(Frame, "Background3")
				Frame.BorderSizePixel = 0
				Frame.Parent = SecContent
				makeStroke(Frame)

				local Label = Instance.new("TextLabel")
				Label.BackgroundTransparency = 1
				Label.Position = UDim2.fromOffset(8, 2)
				Label.Size = UDim2.new(1, -10, 0, 18)
				Label.Font = Enum.Font.RobotoMono
				Label.Text = cfg.Text or "Slider"
				Label.TextColor3 = Theme.Text
				reg(Label, "Text")
				Label.TextSize = 13
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Frame

				local ValLabel = Instance.new("TextLabel")
				ValLabel.BackgroundTransparency = 1
				ValLabel.Position = UDim2.fromOffset(8, 20)
				ValLabel.Size = UDim2.new(1, -10, 0, 14)
				ValLabel.Font = Enum.Font.RobotoMono
				ValLabel.Text = tostring(val)
				ValLabel.TextColor3 = Theme.Accent2
				reg(ValLabel, "Accent2")
				ValLabel.TextSize = 11
				ValLabel.TextXAlignment = Enum.TextXAlignment.Right
				ValLabel.Parent = Frame

				local Track = Instance.new("Frame")
				Track.Size = UDim2.new(1, -16, 0, 4)
				Track.Position = UDim2.fromOffset(8, 28)
				Track.BackgroundColor3 = Theme.Background
				reg(Track, "Background")
				Track.BorderSizePixel = 0
				Track.Parent = Frame

				local Fill = Instance.new("Frame")
				Fill.Size = UDim2.fromScale((val - min) / (max - min), 1)
				Fill.BackgroundColor3 = Theme.Accent
				reg(Fill, "Accent")
				Fill.BorderSizePixel = 0
				Fill.Parent = Track
				makeGradient(Fill)

				local dragging = false
				local function update(x)
					local rel = math.clamp((x - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
					val = math.floor(min + (max - min) * rel)
					Fill.Size = UDim2.fromScale(rel, 1)
					ValLabel.Text = tostring(val)
					if cfg.Callback then cfg.Callback(val) end
				end

				Track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						update(input.Position.X)
					end
				end)
				Track.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						update(input.Position.X)
					end
				end)

				function api:Set(v)
					val = math.clamp(v, min, max)
					local rel = (val - min) / (max - min)
					Fill.Size = UDim2.fromScale(rel, 1)
					ValLabel.Text = tostring(val)
					if cfg.Callback then cfg.Callback(val) end
				end
				function api:Get() return val end

				table.insert(allElements, {Key = cfg.Text, Type = "Slider", API = api})
				return api
			end

			-- DROPDOWN (ПОФИКШЕН — popup поверх всего, текст не уезжает)
			function sec:Dropdown(cfg)
				cfg = cfg or {}
				local options = cfg.Options or {}
				local selected = options[1] or ""
				local api = {}

				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 28)
				Frame.BackgroundColor3 = Theme.Background3
				reg(Frame, "Background3")
				Frame.BorderSizePixel = 0
				Frame.Parent = SecContent
				makeStroke(Frame)

				local Label = Instance.new("TextLabel")
				Label.BackgroundTransparency = 1
				Label.Position = UDim2.fromOffset(8, 0)
				Label.Size = UDim2.new(1, -40, 1, 0)
				Label.Font = Enum.Font.RobotoMono
				Label.Text = (cfg.Text or "Dropdown") .. ": " .. tostring(selected)
				Label.TextColor3 = Theme.Text
				reg(Label, "Text")
				Label.TextSize = 13
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.ZIndex = 2
				Label.Parent = Frame

				local Arrow = Instance.new("TextLabel")
				Arrow.BackgroundTransparency = 1
				Arrow.Position = UDim2.new(1, -24, 0, 0)
				Arrow.Size = UDim2.fromOffset(20, 28)
				Arrow.Font = Enum.Font.RobotoMono
				Arrow.Text = "▼"
				Arrow.TextColor3 = Theme.TextDim
				reg(Arrow, "TextDim")
				Arrow.TextSize = 10
				Arrow.ZIndex = 2
				Arrow.Parent = Frame

				local Header = Instance.new("TextButton")
				Header.Size = UDim2.new(1, 0, 1, 0)
				Header.BackgroundTransparency = 1
				Header.Text = ""
				Header.ZIndex = 3
				Header.Parent = Frame

				-- Popup список (вне Frame, на уровне ScreenGui)
				local List = Instance.new("Frame")
				List.BackgroundColor3 = Theme.Background2
				reg(List, "Background2")
				List.BorderSizePixel = 0
				List.Visible = false
				List.ZIndex = 10
				List.Parent = DropdownHolder
				makeStroke(List)

				local ListScroll = Instance.new("ScrollingFrame")
				ListScroll.Size = UDim2.fromScale(1, 1)
				ListScroll.BackgroundTransparency = 1
				ListScroll.BorderSizePixel = 0
				ListScroll.ScrollBarThickness = 3
				ListScroll.ScrollBarImageColor3 = Theme.Accent
				ListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
				ListScroll.Parent = List

				local ListLayout = Instance.new("UIListLayout")
				ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				ListLayout.Parent = ListScroll

				local open = false
				openDropdowns[api] = {close = function()
					if open then
						open = false
						List.Visible = false
						tween(Arrow, {Rotation = 0}, 0.15)
					end
				end}

				local function rebuild()
					for _, c in ipairs(ListScroll:GetChildren()) do
						if c:IsA("TextButton") then c:Destroy() end
					end
					for _, opt in ipairs(options) do
						local Btn = Instance.new("TextButton")
						Btn.Size = UDim2.new(1, 0, 0, 24)
						Btn.BackgroundColor3 = Theme.Background2
						reg(Btn, "Background2")
						Btn.BorderSizePixel = 0
						Btn.Font = Enum.Font.RobotoMono
						Btn.Text = "  " .. tostring(opt)
						Btn.TextColor3 = Theme.Text
						reg(Btn, "Text")
						Btn.TextSize = 12
						Btn.TextXAlignment = Enum.TextXAlignment.Left
						Btn.ZIndex = 11
						Btn.Parent = ListScroll

						Btn.MouseEnter:Connect(function()
							tween(Btn, {BackgroundColor3 = Theme.Background3}, 0.15)
						end)
						Btn.MouseLeave:Connect(function()
							tween(Btn, {BackgroundColor3 = Theme.Background2}, 0.15)
						end)

						Btn.MouseButton1Click:Connect(function()
							selected = opt
							Label.Text = (cfg.Text or "Dropdown") .. ": " .. tostring(selected)
							if cfg.Callback then cfg.Callback(selected) end
							open = false
							List.Visible = false
							tween(Arrow, {Rotation = 0}, 0.15)
						end)
					end
				end

				local function updatePosition()
					if not Frame.Parent then return end
					local absPos = Frame.AbsolutePosition
					local absSize = Frame.AbsoluteSize
					local listHeight = math.min(#options * 24, 150)
					List.Position = UDim2.fromOffset(absPos.X, absPos.Y + absSize.Y + 2)
					List.Size = UDim2.fromOffset(absSize.X, listHeight)
				end

				Header.MouseButton1Click:Connect(function()
					open = not open
					if open then
						-- Закрываем другие дропдауны
						for otherApi, dd in pairs(openDropdowns) do
							if otherApi ~= api and dd.close then dd.close() end
						end
						rebuild()
						updatePosition()
						List.Visible = true
						tween(Arrow, {Rotation = 180}, 0.15)
					else
						List.Visible = false
						tween(Arrow, {Rotation = 0}, 0.15)
					end
				end)

				-- Обновлять позицию при скролле/изменении размера
				Page:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
					if open then updatePosition() end
				end)
				Page:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
					if open then updatePosition() end
				end)

				function api:SetOptions(opts)
					options = opts
					if open then
						rebuild()
						updatePosition()
					end
				end
				function api:Set(opt)
					selected = opt
					Label.Text = (cfg.Text or "Dropdown") .. ": " .. tostring(selected)
				end
				function api:Get() return selected end

				table.insert(allElements, {Key = cfg.Text, Type = "Dropdown", API = api})
				return api
			end

			-- KEYBIND (оригинальный, рабочий)
			function sec:Keybind(cfg)
				cfg = cfg or {}
				local key = cfg.Default or Enum.KeyCode.Unknown
				local listening = false
				local api = {}

				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 28)
				Frame.BackgroundColor3 = Theme.Background3
				reg(Frame, "Background3")
				Frame.BorderSizePixel = 0
				Frame.Parent = SecContent
				makeStroke(Frame)

				local Label = Instance.new("TextLabel")
				Label.BackgroundTransparency = 1
				Label.Position = UDim2.fromOffset(8, 0)
				Label.Size = UDim2.new(1, -80, 1, 0)
				Label.Font = Enum.Font.RobotoMono
				Label.Text = cfg.Text or "Keybind"
				Label.TextColor3 = Theme.Text
				reg(Label, "Text")
				Label.TextSize = 13
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Frame

				-- Фикс бага: добавлен or
				local KeyBtn = Instance.new("TextButton")
				KeyBtn.Size = UDim2.fromOffset(60, 20)
				KeyBtn.Position = UDim2.new(1, -70, 0.5, -10)
				KeyBtn.BackgroundColor3 = Theme.Background
				reg(KeyBtn, "Background")
				KeyBtn.BorderSizePixel = 0
				KeyBtn.Font = Enum.Font.RobotoMono
				KeyBtn.Text = key == Enum.KeyCode.Unknown and "None" or tostring(key):gsub("Enum.KeyCode.", "")
				KeyBtn.TextColor3 = Theme.Accent2
				reg(KeyBtn, "Accent2")
				KeyBtn.TextSize = 12
				KeyBtn.Parent = Frame
				makeStroke(KeyBtn)

				KeyBtn.MouseButton1Click:Connect(function()
					listening = true
					KeyBtn.Text = "..."
					KeyBtn.TextColor3 = Theme.Warning
				end)

				UserInputService.InputBegan:Connect(function(input, gpe)
					if gpe then return end
					if listening then
						if input.UserInputType == Enum.UserInputType.Keyboard then
							key = input.KeyCode
						elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
							key = Enum.KeyCode.MouseButton1
						elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
							key = Enum.KeyCode.MouseButton2
						end
						listening = false
						KeyBtn.Text = tostring(key):gsub("Enum.KeyCode.", "")
						KeyBtn.TextColor3 = Theme.Accent2
						if cfg.Callback then cfg.Callback("bind", key) end
					else
						if input.KeyCode == key or (input.UserInputType == Enum.UserInputType.MouseButton1 and key == Enum.KeyCode.MouseButton1) then
							if cfg.Callback then cfg.Callback("press", key) end
						end
					end
				end)

				function api:Set(k)
					key = k
					KeyBtn.Text = tostring(k):gsub("Enum.KeyCode.", "")
				end
				function api:Get() return key end

				table.insert(allElements, {Key = cfg.Text, Type = "Keybind", API = api})
				return api
			end

			-- BUTTON
			function sec:Button(cfg)
				cfg = cfg or {}
				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 28)
				Frame.BackgroundColor3 = Theme.Background3
				reg(Frame, "Background3")
				Frame.BorderSizePixel = 0
				Frame.Parent = SecContent
				makeStroke(Frame)

				local Btn = Instance.new("TextButton")
				Btn.Size = UDim2.new(1, -16, 1, -8)
				Btn.Position = UDim2.fromOffset(8, 4)
				Btn.BackgroundColor3 = Theme.Background2
				reg(Btn, "Background2")
				Btn.BorderSizePixel = 0
				Btn.Font = Enum.Font.RobotoMono
				Btn.Text = cfg.Text or "Button"
				Btn.TextColor3 = Theme.Text
				reg(Btn, "Text")
				Btn.TextSize = 13
				Btn.Parent = Frame
				makeStroke(Btn)

				Btn.MouseEnter:Connect(function()
					tween(Btn, {BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text}, 0.15)
				end)
				Btn.MouseLeave:Connect(function()
					tween(Btn, {BackgroundColor3 = Theme.Background2, TextColor3 = Theme.Text}, 0.15)
				end)
				Btn.MouseButton1Click:Connect(function()
					if cfg.Callback then cfg.Callback() end
				end)
			end

			-- TEXTBOX (Добавлен — раньше его не было)
			function sec:Textbox(cfg)
				cfg = cfg or {}
				local api = {}
				local text = cfg.Default or ""

				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 28)
				Frame.BackgroundColor3 = Theme.Background3
				reg(Frame, "Background3")
				Frame.BorderSizePixel = 0
				Frame.Parent = SecContent
				makeStroke(Frame)

				local Label = Instance.new("TextLabel")
				Label.BackgroundTransparency = 1
				Label.Position = UDim2.fromOffset(8, 0)
				Label.Size = UDim2.new(0.4, 0, 1, 0)
				Label.Font = Enum.Font.RobotoMono
				Label.Text = cfg.Text or "Textbox"
				Label.TextColor3 = Theme.Text
				reg(Label, "Text")
				Label.TextSize = 13
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Frame

				local InputBox = Instance.new("TextBox")
				InputBox.Size = UDim2.new(0.55, -12, 0, 20)
				InputBox.Position = UDim2.new(0.45, 6, 0.5, -10)
				InputBox.BackgroundColor3 = Theme.Background
				reg(InputBox, "Background")
				InputBox.BorderSizePixel = 0
				InputBox.Font = Enum.Font.RobotoMono
				InputBox.Text = text
				InputBox.PlaceholderText = cfg.Placeholder or ""
				InputBox.PlaceholderColor3 = Theme.TextDim
				InputBox.TextColor3 = Theme.Text
				reg(InputBox, "Text")
				InputBox.TextSize = 12
				InputBox.ClearTextOnFocus = false
				InputBox.Parent = Frame
				makeStroke(InputBox)

				InputBox.FocusLost:Connect(function()
					text = InputBox.Text
					if cfg.Callback then cfg.Callback(text) end
				end)

				function api:Set(v)
					text = tostring(v or "")
					InputBox.Text = text
				end
				function api:Get() return text end

				table.insert(allElements, {Key = cfg.Text, Type = "Textbox", API = api})
				return api
			end

			-- LABEL
			function sec:Label(cfg)
				cfg = cfg or {}
				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 22)
				Frame.BackgroundTransparency = 1
				Frame.Parent = SecContent

				local Label = Instance.new("TextLabel")
				Label.BackgroundTransparency = 1
				Label.Position = UDim2.fromOffset(8, 0)
				Label.Size = UDim2.new(1, -16, 1, 0)
				Label.Font = Enum.Font.RobotoMono
				Label.Text = cfg.Text or "Label"
				Label.TextColor3 = Theme.TextDim
				reg(Label, "TextDim")
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.TextWrapped = true
				Label.Parent = Frame
				return Frame
			end

			return sec
		end

		return tab
	end

	MinBtn.MouseButton1Click:Connect(function()
		if Window.Size.Y.Offset > 40 then
			tween(Window, {Size = UDim2.fromOffset(560, 34)}, 0.2)
		else
			tween(Window, {Size = UDim2.fromOffset(560, 420)}, 0.2)
		end
	end)

	CloseBtn.MouseButton1Click:Connect(function()
		tween(Window, {Size = UDim2.fromOffset(0, 0)}, 0.2)
		task.wait(0.2)
		ScreenGui:Destroy()
	end)

	function self:SendNotification(text, ntype, duration)
		ntype = ntype or "info"
		duration = duration or 4
		local colors = {error = Theme.Error, warning = Theme.Warning, success = Theme.Success, info = Theme.Accent}
		local icons = {error = "✕", warning = "⚠", success = "✓", info = "ℹ"}
		local color = colors[ntype] or Theme.Accent
		local icon = icons[ntype] or "ℹ"

		local Notif = Instance.new("Frame")
		Notif.Size = UDim2.new(1, 0, 0, 0)
		Notif.BackgroundColor3 = Theme.Background2
		Notif.BorderSizePixel = 0
		Notif.Parent = NotifHolder
		makeStroke(Notif)

		local Accent = Instance.new("Frame")
		Accent.Size = UDim2.new(0, 4, 1, 0)
		Accent.BackgroundColor3 = color
		Accent.BorderSizePixel = 0
		Accent.Parent = Notif

		local IconLbl = Instance.new("TextLabel")
		IconLbl.Size = UDim2.fromOffset(30, 30)
		IconLbl.Position = UDim2.fromOffset(12, 5)
		IconLbl.BackgroundTransparency = 1
		IconLbl.Text = icon
		IconLbl.TextColor3 = color
		IconLbl.TextSize = 18
		IconLbl.Font = Enum.Font.GothamBold
		IconLbl.Parent = Notif

		local TextLbl = Instance.new("TextLabel")
		TextLbl.Size = UDim2.new(1, -60, 1, 0)
		TextLbl.Position = UDim2.fromOffset(48, 0)
		TextLbl.BackgroundTransparency = 1
		TextLbl.Text = text
		TextLbl.TextColor3 = Theme.Text
		TextLbl.TextSize = 14
		TextLbl.Font = Enum.Font.RobotoMono
		TextLbl.TextXAlignment = Enum.TextXAlignment.Left
		TextLbl.TextWrapped = true
		TextLbl.Parent = Notif

		task.wait()
		local h = math.max(50, TextLbl.TextBounds.Y + 20)
		tween(Notif, {Size = UDim2.new(1, 0, 0, h)}, 0.3)

		task.delay(duration, function()
			tween(Notif, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
			task.wait(0.3)
			Notif:Destroy()
		end)
	end

	--======================================================
	-- CONFIGS TAB (полноценный)
	--======================================================
	function self:CreateConfigs()
		local tab = self:CreateTab("Configs")
		local sec = tab:CreateSection("Manager")

		local nameBox = sec:Textbox({Text = "Config Name", Placeholder = "my_config"})
		local listDrop = sec:Dropdown({Text = "Saved Configs", Options = listConfigs()})

		sec:Button({
			Text = "Save Config",
			Callback = function()
				local name = nameBox:Get()
				if name == "" then
					self:SendNotification("Enter config name", "warning")
					return
				end
				local data = {}
				for _, el in ipairs(allElements) do
					if el.Key then
						local ok, v = pcall(function() return el.API:Get() end)
						if ok then
							if typeof(v) == "EnumItem" then
								data[el.Key] = {Type = el.Type, Value = v.Name, Enum = "KeyCode"}
							else
								data[el.Key] = {Type = el.Type, Value = v}
							end
						end
					end
				end
				if saveConfig(name, data) then
					self:SendNotification("Saved: " .. name, "success")
					listDrop:SetOptions(listConfigs())
				end
			end
		})

		sec:Button({
			Text = "Load Config",
			Callback = function()
				local name = listDrop:Get()
				if not name or name == "" then return end
				local data = loadConfig(name)
				if not data then
					self:SendNotification("Config not found", "error")
					return
				end
				for _, el in ipairs(allElements) do
					local d = data[el.Key]
					if d and d.Type == el.Type then
						local v = d.Value
						if d.Enum == "KeyCode" then
							v = Enum.KeyCode[v]
						end
						pcall(function() el.API:Set(v) end)
					end
				end
				self:SendNotification("Loaded: " .. name, "success")
			end
		})

		sec:Button({
			Text = "Delete Config",
			Callback = function()
				local name = listDrop:Get()
				if not name or name == "" then return end
				deleteConfig(name)
				self:SendNotification("Deleted: " .. name, "warning")
				listDrop:SetOptions(listConfigs())
			end
		})

		sec:Button({
			Text = "Refresh List",
			Callback = function()
				listDrop:SetOptions(listConfigs())
			end
		})
	end

	--======================================================
	-- THEMES TAB (настоящая система тем — меняет весь GUI)
	--======================================================
	function self:CreateThemes()
		local tab = self:CreateTab("Themes")

		local sec1 = tab:CreateSection("Design (меняет весь GUI)")
		for themeName, _ in pairs(THEMES) do
			sec1:Button({
				Text = themeName,
				Callback = function()
					applyTheme(themeName)
					self:SendNotification("Theme: " .. themeName, "success")
				end
			})
		end

		local sec2 = tab:CreateSection("Accent Color")
		for _, preset in ipairs(ACCENT_PRESETS) do
			sec2:Button({
				Text = preset.name,
				Callback = function()
					applyAccent(preset.c1, preset.c2)
					self:SendNotification("Accent: " .. preset.name, "success")
				end
			})
		end
	end

	return self
end

return Nunito
