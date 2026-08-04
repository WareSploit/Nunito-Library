--[[
	Nunito UI Library v1.2.0
	Single-file Luau library for Roblox
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Nunito = {Version = "1.2.0"}
Nunito.__index = Nunito

--=========================================================================
-- THEME + РЕЕСТР ДЛЯ СМЕНЫ ТЕМЫ НА ЛЕТУ
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

local RegItems = {}
local function reg(obj, role, prop)
	table.insert(RegItems, {obj = obj, role = role, prop = prop})
	return obj
end

local THEMES = {
	Dark = {
		Background = Color3.fromHex("0A0A0A"), Background2 = Color3.fromHex("121212"),
		Background3 = Color3.fromHex("1A1A1A"), Text = Color3.fromHex("FFFFFF"),
		TextDim = Color3.fromHex("A0A0A0"), Border = Color3.fromHex("282828"),
	},
	Light = {
		Background = Color3.fromHex("F2F2F2"), Background2 = Color3.fromHex("E6E6E6"),
		Background3 = Color3.fromHex("D9D9D9"), Text = Color3.fromHex("141414"),
		TextDim = Color3.fromHex("5A5A5A"), Border = Color3.fromHex("BEBEBE"),
	},
	Midnight = {
		Background = Color3.fromHex("05050F"), Background2 = Color3.fromHex("0A0A1C"),
		Background3 = Color3.fromHex("12122A"), Text = Color3.fromHex("E8E8FF"),
		TextDim = Color3.fromHex("8A8AB0"), Border = Color3.fromHex("26264A"),
	},
	Crimson = {
		Background = Color3.fromHex("0F0505"), Background2 = Color3.fromHex("1C0A0A"),
		Background3 = Color3.fromHex("2A1010"), Text = Color3.fromHex("FFE8E8"),
		TextDim = Color3.fromHex("B08A8A"), Border = Color3.fromHex("4A2626"),
	},
}

local ACCENTS = {
	Purple = {Color3.fromHex("8A2BE2"), Color3.fromHex("C77DFF")},
	Blue   = {Color3.fromHex("3278E2"), Color3.fromHex("78B2FF")},
	Red    = {Color3.fromHex("E23250"), Color3.fromHex("FF788C")},
	Green  = {Color3.fromHex("3CB464"), Color3.fromHex("8CE6AA")},
	Orange = {Color3.fromHex("E28C32"), Color3.fromHex("FFB878")},
}

local function repaint()
	for _, e in ipairs(RegItems) do
		local o = e.obj
		if o and o.Parent then
			if e.role == "Gradient" then
				o.Color = ColorSequence.new(Theme.Accent, Theme.Accent2)
			else
				local c = Theme[e.role]
				if c then o[e.prop] = c end
			end
		end
	end
end

local function applyTheme(name)
	local t = THEMES[name]
	if not t then return false end
	for k, v in pairs(t) do Theme[k] = v end
	repaint()
	return true
end

local function applyAccent(c1, c2)
	Theme.Accent = c1
	Theme.Accent2 = c2
	repaint()
end

--=========================================================================
-- UTILS
--=========================================================================
local function tween(obj, props, duration)
	local t = TweenService:Create(obj, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function makeStroke(parent)
	local s = Instance.new("UIStroke")
	s.Color = Theme.Border
	s.Thickness = 1
	s.Parent = parent
	reg(s, "Border", "Color")
	return s
end

local function makeGradient(parent, c1, c2)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(c1 or Theme.Accent, c2 or Theme.Accent2)
	g.Rotation = 90
	g.Parent = parent
	reg(g, "Gradient", "Color")
	return g
end

local function makeCorner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = r or UDim.new(0, 4)
	c.Parent = parent
	return c
end

--=========================================================================
-- CONFIG STORAGE
--=========================================================================
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

local function packValue(v)
	if typeof(v) == "EnumItem" then
		return {__enum = v.EnumType, name = v.Name}
	end
	return v
end

local function unpackValue(v)
	if type(v) == "table" and v.__enum then
		local ok, e = pcall(function() return Enum[v.__enum][v.name] end)
		if ok then return e end
		return nil
	end
	return v
end

local function saveConfig(name, data)
	if name == "" then return false end
	local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
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
	if not name or name == "" then return nil end
	local raw
	if HasFS then
		if not isfile(CONFIG_FOLDER .. "/" .. name .. ".json") then return nil end
		local ok, content = pcall(readfile, CONFIG_FOLDER .. "/" .. name .. ".json")
		if not ok then return nil end
		raw = content
	else
		raw = MemoryConfigs[name]
		if not raw then return nil end
	end
	local ok, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
	return ok and decoded or nil
end

local function deleteConfig(name)
	if not name or name == "" then return end
	if HasFS then
		pcall(delfile, CONFIG_FOLDER .. "/" .. name .. ".json")
	else
		MemoryConfigs[name] = nil
	end
end

--=========================================================================
-- CREATE WINDOW
--=========================================================================
function Nunito:CreateWindow(config)
	config = config or {}
	local self = setmetatable({}, Nunito)

	RegItems = {}
	local allElements = {}
	local openDropdowns = {}

	local function closeAllDropdowns()
		for _, dd in pairs(openDropdowns) do
			if dd.isOpen then dd.close() end
		end
	end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "NunitoGUI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = PlayerGui

	--=====================================================
	-- WATERMARK (с версией библиотеки)
	--=====================================================
	local Watermark = Instance.new("Frame")
	Watermark.Size = UDim2.fromOffset(180, 24)
	Watermark.Position = UDim2.new(1, -188, 0, 8)
	Watermark.BackgroundColor3 = Theme.Background2
	Watermark.BorderSizePixel = 0
	Watermark.Parent = ScreenGui
	reg(Watermark, "Background2", "BackgroundColor3")
	makeCorner(Watermark)
	makeStroke(Watermark)

	local WMBar = Instance.new("Frame")
	WMBar.Size = UDim2.new(0, 3, 1, -8)
	WMBar.Position = UDim2.fromOffset(4, 4)
	WMBar.BackgroundColor3 = Theme.Accent
	WMBar.BorderSizePixel = 0
	WMBar.Parent = Watermark
	reg(WMBar, "Accent", "BackgroundColor3")
	makeCorner(WMBar, UDim.new(1, 0))

	local WMText = Instance.new("TextLabel")
	WMText.BackgroundTransparency = 1
	WMText.Position = UDim2.fromOffset(12, 0)
	WMText.Size = UDim2.new(1, -16, 1, 0)
	WMText.Font = Enum.Font.RobotoMono
	WMText.Text = (config.Title or "Nunito") .. " | v" .. Nunito.Version
	WMText.TextColor3 = Theme.Text
	WMText.TextSize = 11
	WMText.TextXAlignment = Enum.TextXAlignment.Left
	WMText.Parent = Watermark
	reg(WMText, "Text", "TextColor3")

	--=====================================================
	-- NOTIFICATIONS
	--=====================================================
	local NotifHolder = Instance.new("Frame")
	NotifHolder.Size = UDim2.new(0, 320, 1, -50)
	NotifHolder.Position = UDim2.new(1, -332, 0, 40)
	NotifHolder.BackgroundTransparency = 1
	NotifHolder.Parent = ScreenGui

	local NotifLayout = Instance.new("UIListLayout")
	NotifLayout.Padding = UDim.new(0, 8)
	NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
	NotifLayout.Parent = NotifHolder

	--=====================================================
	-- WINDOW
	--=====================================================
	local Window = Instance.new("Frame")
	Window.Size = UDim2.fromOffset(560, 420)
	Window.Position = UDim2.fromScale(0.5, 0.5)
	Window.AnchorPoint = Vector2.new(0.5, 0.5)
	Window.BackgroundColor3 = Theme.Background
	Window.BorderSizePixel = 0
	Window.ClipsDescendants = true
	Window.Parent = ScreenGui
	reg(Window, "Background", "BackgroundColor3")
	makeStroke(Window)

	local TitleBar = Instance.new("Frame")
	TitleBar.Size = UDim2.new(1, 0, 0, 34)
	TitleBar.BackgroundColor3 = Theme.Background2
	TitleBar.BorderSizePixel = 0
	TitleBar.Parent = Window
	reg(TitleBar, "Background2", "BackgroundColor3")

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
	TitleLabel.TextSize = 14
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = TitleBar
	reg(TitleLabel, "Text", "TextColor3")

	-- Кнопки: закрыть = текст "x", свернуть = "-"
	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.fromOffset(30, 30)
	CloseBtn.Position = UDim2.new(1, -30, 0, 0)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Font = Enum.Font.RobotoMono
	CloseBtn.Text = "x"
	CloseBtn.TextColor3 = Theme.TextDim
	CloseBtn.TextSize = 16
	CloseBtn.Parent = TitleBar
	reg(CloseBtn, "TextDim", "TextColor3")

	local MinBtn = Instance.new("TextButton")
	MinBtn.Size = UDim2.fromOffset(30, 30)
	MinBtn.Position = UDim2.new(1, -60, 0, 0)
	MinBtn.BackgroundTransparency = 1
	MinBtn.Font = Enum.Font.RobotoMono
	MinBtn.Text = "-"
	MinBtn.TextColor3 = Theme.TextDim
	MinBtn.TextSize = 16
	MinBtn.Parent = TitleBar
	reg(MinBtn, "TextDim", "TextColor3")

	CloseBtn.MouseEnter:Connect(function() CloseBtn.TextColor3 = Theme.Error end)
	CloseBtn.MouseLeave:Connect(function() CloseBtn.TextColor3 = Theme.TextDim end)
	MinBtn.MouseEnter:Connect(function() MinBtn.TextColor3 = Theme.Text end)
	MinBtn.MouseLeave:Connect(function() MinBtn.TextColor3 = Theme.TextDim end)

	-- DRAG
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

	local Sidebar = Instance.new("Frame")
	Sidebar.Size = UDim2.new(0, 140, 1, 0)
	Sidebar.BackgroundColor3 = Theme.Background2
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = ContentArea
	reg(Sidebar, "Background2", "BackgroundColor3")
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

	local tabs = {}
	local activeTab = nil

	local function switchTab(tabObj)
		closeAllDropdowns()
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

	--=====================================================
	-- TAB
	--=====================================================
	function self:CreateTab(name)
		local tab = {}

		local Btn = Instance.new("TextButton")
		Btn.Size = UDim2.new(1, -8, 0, 32)
		Btn.BackgroundTransparency = 1
		Btn.Font = Enum.Font.RobotoMono
		Btn.Text = "  " .. name
		Btn.TextColor3 = Theme.TextDim
		Btn.TextSize = 13
		Btn.TextXAlignment = Enum.TextXAlignment.Left
		Btn.Parent = Sidebar

		local Indicator = Instance.new("Frame")
		Indicator.Size = UDim2.fromOffset(3, 20)
		Indicator.Position = UDim2.new(0, 0, 0.5, -10)
		Indicator.BackgroundColor3 = Theme.Accent
		Indicator.BackgroundTransparency = 1
		Indicator.BorderSizePixel = 0
		Indicator.Parent = Btn
		reg(Indicator, "Accent", "BackgroundColor3")
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

		--=================================================
		-- SECTION: заголовок СВЕРХУ, элементы СНИЗУ (AutomaticSize)
		--=================================================
		function tab:CreateSection(name)
			local sec = {}

			local SecFrame = Instance.new("Frame")
			SecFrame.Size = UDim2.new(1, 0, 0, 0)
			SecFrame.AutomaticSize = Enum.AutomaticSize.Y
			SecFrame.BackgroundColor3 = Theme.Background2
			SecFrame.BorderSizePixel = 0
			SecFrame.Parent = Page
			reg(SecFrame, "Background2", "BackgroundColor3")
			makeStroke(SecFrame)

			local SecMainLayout = Instance.new("UIListLayout")
			SecMainLayout.Padding = UDim.new(0, 0)
			SecMainLayout.SortOrder = Enum.SortOrder.LayoutOrder
			SecMainLayout.Parent = SecFrame

			local SecLabel = Instance.new("TextLabel")
			SecLabel.Size = UDim2.new(1, 0, 0, 28)
			SecLabel.BackgroundTransparency = 1
			SecLabel.Font = Enum.Font.RobotoMono
			SecLabel.Text = "  " .. name
			SecLabel.TextColor3 = Theme.Accent2
			SecLabel.TextSize = 13
			SecLabel.TextXAlignment = Enum.TextXAlignment.Left
			SecLabel.Parent = SecFrame
			reg(SecLabel, "Accent2", "TextColor3")

			local SecContent = Instance.new("Frame")
			SecContent.Size = UDim2.new(1, 0, 0, 0)
			SecContent.AutomaticSize = Enum.AutomaticSize.Y
			SecContent.BackgroundTransparency = 1
			SecContent.Parent = SecFrame

			local SecLayout = Instance.new("UIListLayout")
			SecLayout.Padding = UDim.new(0, 4)
			SecLayout.SortOrder = Enum.SortOrder.LayoutOrder
			SecLayout.Parent = SecContent

			local SecPad = Instance.new("UIPadding")
			SecPad.PaddingLeft = UDim.new(0, 4)
			SecPad.PaddingRight = UDim.new(0, 4)
			SecPad.PaddingBottom = UDim.new(0, 6)
			SecPad.Parent = SecContent

			--=============================================
			-- TOGGLE
			--=============================================
			function sec:Toggle(cfg)
				cfg = cfg or {}
				local state = cfg.Default or false
				local api = {}

				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 28)
				Frame.BackgroundColor3 = Theme.Background3
				Frame.BorderSizePixel = 0
				Frame.Parent = SecContent
				reg(Frame, "Background3", "BackgroundColor3")
				makeStroke(Frame)

				local Label = Instance.new("TextLabel")
				Label.BackgroundTransparency = 1
				Label.Position = UDim2.fromOffset(8, 0)
				Label.Size = UDim2.new(1, -50, 1, 0)
				Label.Font = Enum.Font.RobotoMono
				Label.Text = cfg.Text or "Toggle"
				Label.TextColor3 = Theme.Text
				Label.TextSize = 13
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Frame
				reg(Label, "Text", "TextColor3")

				local Track = Instance.new("Frame")
				Track.Size = UDim2.fromOffset(32, 14)
				Track.Position = UDim2.new(1, -42, 0.5, -7)
				Track.BackgroundColor3 = state and Theme.Accent or Theme.Background
				Track.BorderSizePixel = 0
				Track.Parent = Frame
				makeStroke(Track)

				local Knob = Instance.new("Frame")
				Knob.Size = UDim2.fromOffset(10, 10)
				Knob.Position = state and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2)
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

				function api:Set(v) state = v and true or false; update() end
				function api:Get() return state end

				table.insert(allElements, {Key = cfg.Text, Type = "Toggle", API = api})
				return api
			end

			--=============================================
			-- SLIDER: цифра сверху справа + квадратный ползунок
			--=============================================
			function sec:Slider(cfg)
				cfg = cfg or {}
				local min = cfg.Min or 0
				local max = cfg.Max or 100
				if max <= min then max = min + 1 end
				local val = math.clamp(cfg.Default or min, min, max)
				local api = {}

				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 44)
				Frame.BackgroundColor3 = Theme.Background3
				Frame.BorderSizePixel = 0
				Frame.Parent = SecContent
				reg(Frame, "Background3", "BackgroundColor3")
				makeStroke(Frame)

				local Label = Instance.new("TextLabel")
				Label.BackgroundTransparency = 1
				Label.Position = UDim2.fromOffset(10, 6)
				Label.Size = UDim2.new(1, -90, 0, 16)
				Label.Font = Enum.Font.RobotoMono
				Label.Text = cfg.Text or "Slider"
				Label.TextColor3 = Theme.Text
				Label.TextSize = 13
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Frame
				reg(Label, "Text", "TextColor3")

				-- Цифра: чётко сверху справа, всегда видна
				local ValLabel = Instance.new("TextLabel")
				ValLabel.BackgroundTransparency = 1
				ValLabel.Position = UDim2.new(1, -80, 0, 6)
				ValLabel.Size = UDim2.new(0, 70, 0, 16)
				ValLabel.Font = Enum.Font.RobotoMono
				ValLabel.Text = tostring(val)
				ValLabel.TextColor3 = Theme.Accent2
				ValLabel.TextSize = 12
				ValLabel.TextXAlignment = Enum.TextXAlignment.Right
				ValLabel.Parent = Frame
				reg(ValLabel, "Accent2", "TextColor3")

				local Track = Instance.new("Frame")
				Track.Size = UDim2.new(1, -20, 0, 5)
				Track.Position = UDim2.fromOffset(10, 30)
				Track.BackgroundColor3 = Theme.Background
				Track.BorderSizePixel = 0
				Track.Parent = Frame
				reg(Track, "Background", "BackgroundColor3")
				makeCorner(Track, UDim.new(1, 0))

				local Fill = Instance.new("Frame")
				Fill.Size = UDim2.fromScale((val - min) / (max - min), 1)
				Fill.BackgroundColor3 = Theme.Accent
				Fill.BorderSizePixel = 0
				Fill.Parent = Track
				reg(Fill, "Accent", "BackgroundColor3")
				makeGradient(Fill)
				makeCorner(Fill, UDim.new(1, 0))

				-- Квадратный ползунок-ручка
				local Knob = Instance.new("Frame")
				Knob.Size = UDim2.fromOffset(10, 10)
				Knob.Position = UDim2.new((val - min) / (max - min), -5, 0.5, -5)
				Knob.BackgroundColor3 = Theme.Text
				Knob.BorderSizePixel = 0
				Knob.Parent = Track
				reg(Knob, "Text", "BackgroundColor3")
				makeCorner(Knob, UDim.new(0, 2))

				local function setRatio(r, fire)
					r = math.clamp(r, 0, 1)
					val = math.clamp(math.floor(min + (max - min) * r + 0.5), min, max)
					local vr = (val - min) / (max - min)
					Fill.Size = UDim2.fromScale(vr, 1)
					Knob.Position = UDim2.new(vr, -5, 0.5, -5)
					ValLabel.Text = tostring(val)
					if fire and cfg.Callback then cfg.Callback(val) end
				end

				local draggingS = false
				local function fromX(x)
					local w = Track.AbsoluteSize.X
					if w <= 0 then return end
					setRatio((x - Track.AbsolutePosition.X) / w, true)
				end

				Track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						draggingS = true
						fromX(input.Position.X)
					end
				end)
				Knob.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						draggingS = true
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if draggingS and input.UserInputType == Enum.UserInputType.MouseMovement then
						fromX(input.Position.X)
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						draggingS = false
					end
				end)

				function api:Set(v)
					local nv = math.clamp(v, min, max)
					setRatio((nv - min) / (max - min), true)
				end
				function api:Get() return val end

				table.insert(allElements, {Key = cfg.Text, Type = "Slider", API = api})
				return api
			end

			--=============================================
			-- DROPDOWN: открывается вниз, элементы ниже едут,
			-- при закрытии всё возвращается
			--=============================================
			function sec:Dropdown(cfg)
				cfg = cfg or {}
				local options = cfg.Options or {}
				local selected = options[1] or ""
				local open = false
				local api = {}

				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 28)
				Frame.BackgroundColor3 = Theme.Background3
				Frame.BorderSizePixel = 0
				Frame.ClipsDescendants = true
				Frame.Parent = SecContent
				reg(Frame, "Background3", "BackgroundColor3")
				makeStroke(Frame)

				local Header = Instance.new("TextButton")
				Header.Size = UDim2.new(1, 0, 0, 28)
				Header.BackgroundTransparency = 1
				Header.Text = ""
				Header.Parent = Frame

				local Label = Instance.new("TextLabel")
				Label.BackgroundTransparency = 1
				Label.Position = UDim2.fromOffset(8, 0)
				Label.Size = UDim2.new(1, -40, 0, 28)
				Label.Font = Enum.Font.RobotoMono
				Label.Text = (cfg.Text or "Dropdown") .. ": " .. tostring(selected)
				Label.TextColor3 = Theme.Text
				Label.TextSize = 13
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Frame
				reg(Label, "Text", "TextColor3")

				local Arrow = Instance.new("TextLabel")
				Arrow.BackgroundTransparency = 1
				Arrow.Position = UDim2.new(1, -24, 0, 0)
				Arrow.Size = UDim2.fromOffset(20, 28)
				Arrow.Font = Enum.Font.RobotoMono
				Arrow.Text = "v"
				Arrow.TextColor3 = Theme.TextDim
				Arrow.TextSize = 10
				Arrow.Parent = Frame
				reg(Arrow, "TextDim", "TextColor3")

				local List = Instance.new("ScrollingFrame")
				List.Position = UDim2.fromOffset(4, 28)
				List.Size = UDim2.new(1, -8, 0, 0)
				List.BackgroundTransparency = 1
				List.BorderSizePixel = 0
				List.ScrollBarThickness = 2
				List.ScrollBarImageColor3 = Theme.Accent
				List.AutomaticCanvasSize = Enum.AutomaticSize.Y
				List.Parent = Frame

				local ListLayout = Instance.new("UIListLayout")
				ListLayout.Padding = UDim.new(0, 2)
				ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				ListLayout.Parent = List

				local function listHeight()
					local n = #options
					if n == 0 then return 0 end
					return math.min(n * 26 - 2, 160)
				end

				local function rebuild()
					for _, c in ipairs(List:GetChildren()) do
						if c:IsA("TextButton") then c:Destroy() end
					end
					for _, opt in ipairs(options) do
						local OptBtn = Instance.new("TextButton")
						OptBtn.Size = UDim2.new(1, 0, 0, 24)
						OptBtn.BackgroundColor3 = Theme.Background2
						OptBtn.BorderSizePixel = 0
						OptBtn.Font = Enum.Font.RobotoMono
						OptBtn.Text = "  " .. tostring(opt)
						OptBtn.TextColor3 = Theme.Text
						OptBtn.TextSize = 12
						OptBtn.TextXAlignment = Enum.TextXAlignment.Left
						OptBtn.Parent = List
						reg(OptBtn, "Background2", "BackgroundColor3")

						OptBtn.MouseEnter:Connect(function() OptBtn.BackgroundColor3 = Theme.Background3 end)
						OptBtn.MouseLeave:Connect(function() OptBtn.BackgroundColor3 = Theme.Background2 end)

						OptBtn.MouseButton1Click:Connect(function()
							selected = opt
							Label.Text = (cfg.Text or "Dropdown") .. ": " .. tostring(selected)
							if cfg.Callback then cfg.Callback(selected) end
							api.close()
						end)
					end
				end

				function api.close()
					if not open then return end
					open = false
					openDropdowns[api] = nil
					tween(Frame, {Size = UDim2.new(1, 0, 0, 28)}, 0.2)
					tween(List, {Size = UDim2.new(1, -8, 0, 0)}, 0.2)
					tween(Arrow, {Rotation = 0}, 0.15)
				end

				local function openList()
					closeAllDropdowns()
					open = true
					openDropdowns[api] = {isOpen = true, close = api.close}
					rebuild()
					local h = listHeight()
					tween(Frame, {Size = UDim2.new(1, 0, 0, 28 + h + 6)}, 0.2)
					tween(List, {Size = UDim2.new(1, -8, 0, h)}, 0.2)
					tween(Arrow, {Rotation = 180}, 0.15)
				end

				Header.MouseButton1Click:Connect(function()
					if open then api.close() else openList() end
				end)

				function api:SetOptions(opts)
					options = opts or {}
					if not table.find(options, selected) then
						selected = options[1] or ""
						Label.Text = (cfg.Text or "Dropdown") .. ": " .. tostring(selected)
					end
					if open then
						rebuild()
						local h = listHeight()
						tween(Frame, {Size = UDim2.new(1, 0, 0, 28 + h + 6)}, 0.2)
						tween(List, {Size = UDim2.new(1, -8, 0, h)}, 0.2)
					end
				end
				function api:Set(opt)
					selected = opt
					Label.Text = (cfg.Text or "Dropdown") .. ": " .. tostring(selected)
				end
				function api:Get() return selected end

				rebuild()
				table.insert(allElements, {Key = cfg.Text, Type = "Dropdown", API = api})
				return api
			end

			--=============================================
			-- KEYBIND
			--=============================================
			function sec:Keybind(cfg)
				cfg = cfg or {}
				local key = cfg.Default or Enum.KeyCode.Unknown
				local listening = false
				local api = {}

				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 28)
				Frame.BackgroundColor3 = Theme.Background3
				Frame.BorderSizePixel = 0
				Frame.Parent = SecContent
				reg(Frame, "Background3", "BackgroundColor3")
				makeStroke(Frame)

				local Label = Instance.new("TextLabel")
				Label.BackgroundTransparency = 1
				Label.Position = UDim2.fromOffset(8, 0)
				Label.Size = UDim2.new(1, -80, 1, 0)
				Label.Font = Enum.Font.RobotoMono
				Label.Text = cfg.Text or "Keybind"
				Label.TextColor3 = Theme.Text
				Label.TextSize = 13
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Frame
				reg(Label, "Text", "TextColor3")

				local KeyBtn = Instance.new("TextButton")
				KeyBtn.Size = UDim2.fromOffset(60, 20)
				KeyBtn.Position = UDim2.new(1, -70, 0.5, -10)
				KeyBtn.BackgroundColor3 = Theme.Background
				KeyBtn.BorderSizePixel = 0
				KeyBtn.Font = Enum.Font.RobotoMono
				KeyBtn.Text = key == Enum.KeyCode.Unknown and "None" or tostring(key):gsub("Enum.KeyCode.", "")
				KeyBtn.TextColor3 = Theme.Accent2
				KeyBtn.TextSize = 12
				KeyBtn.Parent = Frame
				reg(KeyBtn, "Background", "BackgroundColor3")
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
						else
							return
						end
						listening = false
						KeyBtn.Text = tostring(key):gsub("Enum.KeyCode.", "")
						KeyBtn.TextColor3 = Theme.Accent2
						if cfg.Callback then cfg.Callback("bind", key) end
					else
						if key ~= Enum.KeyCode.Unknown then
							if input.KeyCode == key
								or (input.UserInputType == Enum.UserInputType.MouseButton1 and key == Enum.KeyCode.MouseButton1)
								or (input.UserInputType == Enum.UserInputType.MouseButton2 and key == Enum.KeyCode.MouseButton2) then
								if cfg.Callback then cfg.Callback("press", key) end
							end
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

			--=============================================
			-- BUTTON
			--=============================================
			function sec:Button(cfg)
				cfg = cfg or {}
				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 28)
				Frame.BackgroundColor3 = Theme.Background3
				Frame.BorderSizePixel = 0
				Frame.Parent = SecContent
				reg(Frame, "Background3", "BackgroundColor3")
				makeStroke(Frame)

				local Btn = Instance.new("TextButton")
				Btn.Size = UDim2.new(1, -16, 1, -8)
				Btn.Position = UDim2.fromOffset(8, 4)
				Btn.BackgroundColor3 = Theme.Background2
				Btn.BorderSizePixel = 0
				Btn.Font = Enum.Font.RobotoMono
				Btn.Text = cfg.Text or "Button"
				Btn.TextColor3 = Theme.Text
				Btn.TextSize = 13
				Btn.Parent = Frame
				reg(Btn, "Background2", "BackgroundColor3")
				makeStroke(Btn)

				Btn.MouseEnter:Connect(function() tween(Btn, {BackgroundColor3 = Theme.Accent}, 0.15) end)
				Btn.MouseLeave:Connect(function() tween(Btn, {BackgroundColor3 = Theme.Background2}, 0.15) end)
				Btn.MouseButton1Click:Connect(function()
					if cfg.Callback then cfg.Callback() end
				end)
			end

			--=============================================
			-- TEXTBOX
			--=============================================
			function sec:Textbox(cfg)
				cfg = cfg or {}
				local api = {}
				local text = cfg.Default or ""

				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 28)
				Frame.BackgroundColor3 = Theme.Background3
				Frame.BorderSizePixel = 0
				Frame.Parent = SecContent
				reg(Frame, "Background3", "BackgroundColor3")
				makeStroke(Frame)

				local Label = Instance.new("TextLabel")
				Label.BackgroundTransparency = 1
				Label.Position = UDim2.fromOffset(8, 0)
				Label.Size = UDim2.new(0.4, 0, 1, 0)
				Label.Font = Enum.Font.RobotoMono
				Label.Text = cfg.Text or "Textbox"
				Label.TextColor3 = Theme.Text
				Label.TextSize = 13
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Frame
				reg(Label, "Text", "TextColor3")

				local InputBox = Instance.new("TextBox")
				InputBox.Size = UDim2.new(0.55, -12, 0, 20)
				InputBox.Position = UDim2.new(0.45, 6, 0.5, -10)
				InputBox.BackgroundColor3 = Theme.Background
				InputBox.BorderSizePixel = 0
				InputBox.Font = Enum.Font.RobotoMono
				InputBox.Text = text
				InputBox.PlaceholderText = cfg.Placeholder or ""
				InputBox.PlaceholderColor3 = Theme.TextDim
				InputBox.TextColor3 = Theme.Text
				InputBox.TextSize = 12
				InputBox.ClearTextOnFocus = false
				InputBox.Parent = Frame
				reg(InputBox, "Background", "BackgroundColor3")
				reg(InputBox, "Text", "TextColor3")
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

			--=============================================
			-- LABEL
			--=============================================
			function sec:Label(cfg)
				cfg = cfg or {}
				local L = Instance.new("TextLabel")
				L.Size = UDim2.new(1, 0, 0, 20)
				L.BackgroundTransparency = 1
				L.Font = Enum.Font.RobotoMono
				L.Text = "  " .. (cfg.Text or "")
				L.TextColor3 = Theme.TextDim
				L.TextSize = 12
				L.TextXAlignment = Enum.TextXAlignment.Left
				L.TextWrapped = true
				L.Parent = SecContent
				reg(L, "TextDim", "TextColor3")
				return L
			end

			return sec
		end

		return tab
	end

	MinBtn.MouseButton1Click:Connect(function()
		if Window.Size.Y.Offset > 40 then
			closeAllDropdowns()
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

	--=====================================================
	-- NOTIFICATIONS
	--=====================================================
	function self:SendNotification(text, ntype, duration)
		ntype = ntype or "info"
		duration = duration or 4
		local colors = {error = Theme.Error, warning = Theme.Warning, success = Theme.Success, info = Theme.Accent}
		local icons = {error = "x", warning = "!", success = "+", info = "i"}
		local color = colors[ntype] or Theme.Accent
		local icon = icons[ntype] or "i"

		local Notif = Instance.new("Frame")
		Notif.Size = UDim2.new(1, 0, 0, 0)
		Notif.BackgroundColor3 = Theme.Background2
		Notif.BorderSizePixel = 0
		Notif.ClipsDescendants = true
		Notif.Parent = NotifHolder
		makeCorner(Notif)
		makeStroke(Notif)

		local Accent = Instance.new("Frame")
		Accent.Size = UDim2.new(0, 4, 1, 0)
		Accent.BackgroundColor3 = color
		Accent.BorderSizePixel = 0
		Accent.Parent = Notif

		local IconLbl = Instance.new("TextLabel")
		IconLbl.Size = UDim2.fromOffset(30, 30)
		IconLbl.Position = UDim2.fromOffset(10, 8)
		IconLbl.BackgroundTransparency = 1
		IconLbl.Text = icon
		IconLbl.TextColor3 = color
		IconLbl.TextSize = 16
		IconLbl.Font = Enum.Font.RobotoMono
		IconLbl.Parent = Notif

		local TextLbl = Instance.new("TextLabel")
		TextLbl.Size = UDim2.new(1, -56, 1, -16)
		TextLbl.Position = UDim2.fromOffset(44, 8)
		TextLbl.BackgroundTransparency = 1
		TextLbl.Text = text
		TextLbl.TextColor3 = Theme.Text
		TextLbl.TextSize = 13
		TextLbl.Font = Enum.Font.RobotoMono
		TextLbl.TextXAlignment = Enum.TextXAlignment.Left
		TextLbl.TextWrapped = true
		TextLbl.Parent = Notif

		task.wait()
		local h = math.max(46, TextLbl.TextBounds.Y + 16)
		tween(Notif, {Size = UDim2.new(1, 0, 0, h)}, 0.3)

		task.delay(duration, function()
			tween(Notif, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
			task.wait(0.3)
			Notif:Destroy()
		end)
	end

	--=====================================================
	-- CONFIGS TAB (сохранение работает, список обновляется)
	--=====================================================
	function self:CreateConfigs()
		local tab = self:CreateTab("Configs")
		local sec = tab:CreateSection("Manager")

		local nameBox = sec:Textbox({Text = "Name", Placeholder = "config_name"})
		local listDrop = sec:Dropdown({Text = "List", Options = listConfigs()})

		sec:Button({
			Text = "Save",
			Callback = function()
				local name = nameBox:Get()
				if name == "" then
					self:SendNotification("Введи имя конфига", "warning")
					return
				end
				local data = {}
				for _, el in ipairs(allElements) do
					if el.Key then
						local ok, v = pcall(function() return el.API:Get() end)
						if ok then
							data[el.Key] = {Type = el.Type, Value = packValue(v)}
						end
					end
				end
				if saveConfig(name, data) then
					self:SendNotification("Saved: " .. name, "success")
					listDrop:SetOptions(listConfigs())
					listDrop:Set(name)
				else
					self:SendNotification("Ошибка сохранения", "error")
				end
			end
		})

		sec:Button({
			Text = "Load",
			Callback = function()
				local name = listDrop:Get()
				local data = loadConfig(name)
				if not data then
					self:SendNotification("Конфиг не найден", "error")
					return
				end
				for _, el in ipairs(allElements) do
					local d = data[el.Key]
					if d and d.Type == el.Type then
						local v = unpackValue(d.Value)
						if v ~= nil then
							pcall(function() el.API:Set(v) end)
						end
					end
				end
				self:SendNotification("Loaded: " .. tostring(name), "success")
			end
		})

		sec:Button({
			Text = "Delete",
			Callback = function()
				local name = listDrop:Get()
				deleteConfig(name)
				self:SendNotification("Deleted: " .. tostring(name), "warning")
				listDrop:SetOptions(listConfigs())
			end
		})

		sec:Button({
			Text = "Refresh",
			Callback = function()
				listDrop:SetOptions(listConfigs())
				self:SendNotification("Список обновлён", "info")
			end
		})
	end

	--=====================================================
	-- THEMES TAB (заголовок сверху, кнопки снизу)
	--=====================================================
	function self:CreateThemes()
		local tab = self:CreateTab("Themes")

		local secDesign = tab:CreateSection("Design (весь GUI)")
		for themeName, _ in pairs(THEMES) do
			secDesign:Button({
				Text = themeName,
				Callback = function()
					applyTheme(themeName)
					self:SendNotification("Theme: " .. themeName, "success")
				end
			})
		end

		local secAccent = tab:CreateSection("Accent")
		for accentName, cols in pairs(ACCENTS) do
			secAccent:Button({
				Text = accentName,
				Callback = function()
					applyAccent(cols[1], cols[2])
					self:SendNotification("Accent: " .. accentName, "success")
				end
			})
		end

		local secInfo = tab:CreateSection("Info")
		secInfo:Label({Text = "Nunito UI Library v" .. Nunito.Version})
		secInfo:Label({Text = "by WareSploit"})
	end

	return self
end

return Nunito
