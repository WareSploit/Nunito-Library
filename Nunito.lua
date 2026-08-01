local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

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
    return s
end

local function makeGradient(parent, c1, c2)
    local g = Instance.new("UIGradient")
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

local Nunito = {}
Nunito.__index = Nunito

function Nunito:CreateWindow(config)
    config = config or {}
    local self = setmetatable({}, Nunito)
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NunitoGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = PlayerGui

    local NotifHolder = Instance.new("Frame")
    NotifHolder.Size = UDim2.new(0, 320, 1, -40)
    NotifHolder.Position = UDim2.new(1, -332, 0, 20)
    NotifHolder.BackgroundTransparency = 1
    NotifHolder.Parent = ScreenGui
    
    local NotifLayout = Instance.new("UIListLayout")
    NotifLayout.Padding = UDim.new(0, 8)
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotifLayout.Parent = NotifHolder

    local Window = Instance.new("Frame")
    Window.Size = UDim2.fromOffset(560, 420)
    Window.Position = UDim2.fromScale(0.5, 0.5)
    Window.AnchorPoint = Vector2.new(0.5, 0.5)
    Window.BackgroundColor3 = Theme.Background
    Window.BorderSizePixel = 0
    Window.ClipsDescendants = true
    Window.Parent = ScreenGui
    makeStroke(Window)

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 34)
    TitleBar.BackgroundColor3 = Theme.Background2
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
    CloseBtn.TextSize = 14
    CloseBtn.Parent = TitleBar

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.fromOffset(30, 30)
    MinBtn.Position = UDim2.new(1, -60, 0, 0)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Font = Enum.Font.RobotoMono
    MinBtn.Text = "—"
    MinBtn.TextColor3 = Theme.TextDim
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

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.fromOffset(140, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Background2
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

    local tabs = {}
    local activeTab = nil

    local function switchTab(tabObj)
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

        local elements = {}

        function tab:CreateSection(name)
            local sec = {}
            local SecFrame = Instance.new("Frame")
            SecFrame.Size = UDim2.new(1, 0, 0, 28)
            SecFrame.BackgroundColor3 = Theme.Background2
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

            function sec:Toggle(config)
                config = config or {}
                local state = config.Default or false
                local api = {}

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 28)
                Frame.BackgroundColor3 = Theme.Background3
                Frame.BorderSizePixel = 0
                Frame.Parent = SecContent
                makeStroke(Frame)

                local Label = Instance.new("TextLabel")
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.fromOffset(8, 0)
                Label.Size = UDim2.new(1, -50, 1, 0)
                Label.Font = Enum.Font.RobotoMono
                Label.Text = config.Text or "Toggle"
                Label.TextColor3 = Theme.Text
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Frame

                local Track = Instance.new("Frame")
                Track.Size = UDim2.fromOffset(32, 14)
                Track.Position = UDim2.new(1, -42, 0.5, -7)
                Track.BackgroundColor3 = Theme.Background
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
                    if config.Callback then config.Callback(state) end
                end

                Frame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        state = not state
                        update()
                    end
                end)

                function api:Set(v)
                    state = v
                    update()
                end
                function api:Get() return state end

                if state then update() end
                table.insert(elements, {Key = config.Text, Type = "Toggle", API = api})
                return api
            end

            function sec:Slider(config)
                config = config or {}
                local min = config.Min or 0
                local max = config.Max or 100
                local val = config.Default or min
                local api = {}

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 36)
                Frame.BackgroundColor3 = Theme.Background3
                Frame.BorderSizePixel = 0
                Frame.Parent = SecContent
                makeStroke(Frame)

                local Label = Instance.new("TextLabel")
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.fromOffset(8, 2)
                Label.Size = UDim2.new(1, -10, 0, 18)
                Label.Font = Enum.Font.RobotoMono
                Label.Text = config.Text or "Slider"
                Label.TextColor3 = Theme.Text
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
                ValLabel.TextSize = 11
                ValLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValLabel.Parent = Frame

                local Track = Instance.new("Frame")
                Track.Size = UDim2.new(1, -16, 0, 4)
                Track.Position = UDim2.fromOffset(8, 28)
                Track.BackgroundColor3 = Theme.Background
                Track.BorderSizePixel = 0
                Track.Parent = Frame

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.fromScale((val - min) / (max - min), 1)
                Fill.BackgroundColor3 = Theme.Accent
                Fill.BorderSizePixel = 0
                Fill.Parent = Track
                makeGradient(Fill)

                local dragging = false
                local function update(x)
                    local rel = math.clamp((x - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    val = math.floor(min + (max - min) * rel)
                    Fill.Size = UDim2.fromScale(rel, 1)
                    ValLabel.Text = tostring(val)
                    if config.Callback then config.Callback(val) end
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
                    if config.Callback then config.Callback(val) end
                end
                function api:Get() return val end

                table.insert(elements, {Key = config.Text, Type = "Slider", API = api})
                return api
            end

            function sec:Dropdown(config)
                config = config or {}
                local options = config.Options or {}
                local selected = options[1] or ""
                local open = false
                local api = {}

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 28)
                Frame.BackgroundColor3 = Theme.Background3
                Frame.BorderSizePixel = 0
                Frame.ClipsDescendants = true
                Frame.Parent = SecContent
                makeStroke(Frame)

                local Header = Instance.new("TextButton")
                Header.Size = UDim2.new(1, 0, 0, 28)
                Header.BackgroundTransparency = 1
                Header.Text = ""
                Header.Parent = Frame

                local Label = Instance.new("TextLabel")
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.fromOffset(8, 0)
                Label.Size = UDim2.new(1, -40, 1, 0)
                Label.Font = Enum.Font.RobotoMono
                Label.Text = (config.Text or "Dropdown") .. ": " .. selected
                Label.TextColor3 = Theme.Text
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Frame

                local Arrow = Instance.new("TextLabel")
                Arrow.BackgroundTransparency = 1
                Arrow.Position = UDim2.new(1, -24, 0, 0)
                Arrow.Size = UDim2.fromOffset(20, 28)
                Arrow.Font = Enum.Font.RobotoMono
                Arrow.Text = "▼"
                Arrow.TextColor3 = Theme.TextDim
                Arrow.TextSize = 10
                Arrow.Parent = Frame

                local List = Instance.new("Frame")
                List.Position = UDim2.fromOffset(0, 28)
                List.Size = UDim2.new(1, 0, 0, 0)
                List.BackgroundTransparency = 1
                List.Parent = Frame

                local ListLayout = Instance.new("UIListLayout")
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout.Parent = List

                local function rebuild()
                    for _, c in ipairs(List:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                    for i, opt in ipairs(options) do
                        local Btn = Instance.new("TextButton")
                        Btn.Size = UDim2.new(1, 0, 0, 24)
                        Btn.BackgroundColor3 = Theme.Background2
                        Btn.BorderSizePixel = 0
                        Btn.Font = Enum.Font.RobotoMono
                        Btn.Text = "  " .. opt
                        Btn.TextColor3 = Theme.Text
                        Btn.TextSize = 12
                        Btn.TextXAlignment = Enum.TextXAlignment.Left
                        Btn.Parent = List
                        
                        Btn.MouseButton1Click:Connect(function()
                            selected = opt
                            Label.Text = (config.Text or "Dropdown") .. ": " .. selected
                            if config.Callback then config.Callback(selected) end
                            open = false
                            tween(Frame, {Size = UDim2.new(1, 0, 0, 28)}, 0.2)
                            tween(Arrow, {Rotation = 0}, 0.15)
                        end)
                    end
                    List.Size = UDim2.new(1, 0, 0, #options * 24)
                end

                Header.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        tween(Frame, {Size = UDim2.new(1, 0, 0, 28 + #options * 24)}, 0.2)
                        tween(Arrow, {Rotation = 180}, 0.15)
                    else
                        tween(Frame, {Size = UDim2.new(1, 0, 0, 28)}, 0.2)
                        tween(Arrow, {Rotation = 0}, 0.15)
                    end
                end)

                function api:SetOptions(opts)
                    options = opts
                    rebuild()
                end
                function api:Set(opt)
                    selected = opt
                    Label.Text = (config.Text or "Dropdown") .. ": " .. selected
                end
                function api:Get() return selected end

                rebuild()
                table.insert(elements, {Key = config.Text, Type = "Dropdown", API = api})
                return api
            end

            function sec:Keybind(config)
                config = config or {}
                local key = config.Default or Enum.KeyCode.Unknown
                local listening = false
                local api = {}

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 28)
                Frame.BackgroundColor3 = Theme.Background3
                Frame.BorderSizePixel = 0
                Frame.Parent = SecContent
                makeStroke(Frame)

                local Label = Instance.new("TextLabel")
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.fromOffset(8, 0)
                Label.Size = UDim2.new(1, -80, 1, 0)
                Label.Font = Enum.Font.RobotoMono
                Label.Text = config.Text or "Keybind"
                Label.TextColor3 = Theme.Text
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Frame

                local KeyBtn = Instance.new("TextButton")
                KeyBtn.Size = UDim2.fromOffset(60, 20)
                KeyBtn.Position = UDim2.new(1, -70, 0.5, -10)
                KeyBtn.BackgroundColor3 = Theme.Background
                KeyBtn.BorderSizePixel = 0
                KeyBtn.Font = Enum.Font.RobotoMono
                KeyBtn.Text = key == Enum.KeyCode.Unknown and "None" :gsub("Enum.KeyCode.", "")
                KeyBtn.TextColor3 = Theme.Accent2
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
                        if config.Callback then config.Callback("bind", key) end
                    else
                        if input.KeyCode == key or (input.UserInputType == Enum.UserInputType.MouseButton1 and key == Enum.KeyCode.MouseButton1) then
                            if config.Callback then config.Callback("press", key) end
                        end
                    end
                end)

                function api:Set(k)
                    key = k
                    KeyBtn.Text = tostring(k):gsub("Enum.KeyCode.", "")
                end
                function api:Get() return key end

                table.insert(elements, {Key = config.Text, Type = "Keybind", API = api})
                return api
            end
            
            function sec:Button(config)
                config = config or {}
                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 28)
                Frame.BackgroundColor3 = Theme.Background3
                Frame.BorderSizePixel = 0
                Frame.Parent = SecContent
                makeStroke(Frame)

                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, -16, 1, -8)
                Btn.Position = UDim2.fromOffset(8, 4)
                Btn.BackgroundColor3 = Theme.Background2
                Btn.BorderSizePixel = 0
                Btn.Font = Enum.Font.RobotoMono
                Btn.Text = config.Text or "Button"
                Btn.TextColor3 = Theme.Text
                Btn.TextSize = 13
                Btn.Parent = Frame
                makeStroke(Btn)

                Btn.MouseEnter:Connect(function() tween(Btn, {BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text}, 0.15) end)
                Btn.MouseLeave:Connect(function() tween(Btn, {BackgroundColor3 = Theme.Background2, TextColor3 = Theme.Text}, 0.15) end)
                Btn.MouseButton1Click:Connect(function()
                    if config.Callback then config.Callback() end
                end)
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

    function self:CreateConfigs()
        local tab = self:CreateTab("Configs")
        local sec = tab:CreateSection("Manager")
        
        local nameBox = sec:Textbox({Text = "Name", Placeholder = "config_name"})
        local listDrop = sec:Dropdown({Text = "List", Options = listConfigs()})

        sec:Button({
            Text = "Save",
            Callback = function()
                if nameBox:Get() == "" then return end
                local data = {}
                for _, el in ipairs(elements) do
                    data[el.Key] = {Type = el.Type, Value = el.API:Get()}
                end
                if saveConfig(nameBox:Get(), data) then
                    self:SendNotification("Saved: " .. nameBox:Get(), "success")
                    listDrop:SetOptions(listConfigs())
                end
            end
        })

        sec:Button({
            Text = "Load",
            Callback = function()
                local data = loadConfig(listDrop:Get())
                if data then
                    for _, el in ipairs(elements) do
                        local d = data[el.Key]
                        if d and d.Type == el.Type then el.API:Set(d.Value) end
                    end
                    self:SendNotification("Loaded: " .. listDrop:Get(), "success")
                end
            end
        })

        sec:Button({
            Text = "Delete",
            Callback = function()
                deleteConfig(listDrop:Get())
                self:SendNotification("Deleted: " .. listDrop:Get(), "warning")
                listDrop:SetOptions(listConfigs())
            end
        })
    end
    
    function self:CreateThemes()
        local tab = self:CreateTab("Themes")
        local sec = tab:CreateSection("Colors")
        local themes = {"Purple", "Blue", "Red", "Green"}
        local themeColors = {
            Purple = {Color3.fromHex("8A2BE2"), Color3.fromHex("C77DFF")},
            Blue = {Color3.fromHex("3278E2"), Color3.fromHex("78B2FF")},
            Red = {Color3.fromHex("E23250"), Color3.fromHex("FF788C")},
            Green = {Color3.fromHex("3CB464"), Color3.fromHex("8CE6AA")}
        }

        for _, tName in ipairs(themes) do
            sec:Button({
                Text = tName,
                Callback = function()
                    Theme.Accent = themeColors[tName][1]
                    Theme.Accent2 = themeColors[tName][2]
                    self:SendNotification("Theme set to " .. tName, "info")
                end
            })
        end
    end

    return self
end

return Nunito
