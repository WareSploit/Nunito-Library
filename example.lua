--[[
    Nunito Library v1.2.0 — example.lua
    Вставь в эксплойт и нажми Execute
]]

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local url = "https://raw.githubusercontent.com/WareSploit/Nunito-Library/refs/heads/main/Nunito.lua"
local Nunito = loadstring(game:HttpGet(url .. "?v=" .. tostring(os.time()), true))()

local Window = Nunito:CreateWindow({
    Title = "Nunito Hub",
})

local function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid") or nil
end

--=====================================================
-- MAIN
--=====================================================
local Main = Window:CreateTab("Main")

local MoveSec = Main:CreateSection("Movement")

local FlyToggle = MoveSec:Toggle({
    Text = "Fly",
    Default = false,
    Callback = function(state)
        print("[Nunito] Fly:", state)
    end,
})

MoveSec:Slider({
    Text = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(value)
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = value end
    end,
})

MoveSec:Slider({
    Text = "JumpPower",
    Min = 50,
    Max = 300,
    Default = 50,
    Callback = function(value)
        local hum = getHumanoid()
        if hum then hum.JumpPower = value end
    end,
})

MoveSec:Keybind({
    Text = "Fly Key",
    Default = Enum.KeyCode.F,
    Callback = function(action)
        if action == "press" then
            FlyToggle:Set(not FlyToggle:Get())
        end
    end,
})

local CombatSec = Main:CreateSection("Combat")

CombatSec:Toggle({
    Text = "Kill Aura",
    Default = false,
    Callback = function(state)
        print("[Nunito] Kill Aura:", state)
    end,
})

CombatSec:Dropdown({
    Text = "Target Priority",
    Options = {"Closest", "Lowest HP", "Highest HP"},
    Callback = function(opt)
        print("[Nunito] Priority:", opt)
    end,
})

CombatSec:Slider({
    Text = "Range",
    Min = 1,
    Max = 50,
    Default = 10,
    Callback = function(v)
        print("[Nunito] Range:", v)
    end,
})

--=====================================================
-- VISUALS
--=====================================================
local Visuals = Window:CreateTab("Visuals")

local EspSec = Visuals:CreateSection("ESP")

EspSec:Toggle({
    Text = "Enable ESP",
    Default = false,
    Callback = function(state)
        print("[Nunito] ESP:", state)
    end,
})

EspSec:Dropdown({
    Text = "ESP Type",
    Options = {"Box", "Chams", "Tracers", "Skeleton", "All"},
    Callback = function(opt)
        print("[Nunito] ESP Type:", opt)
    end,
})

EspSec:Slider({
    Text = "Max Distance",
    Min = 100,
    Max = 5000,
    Default = 1000,
    Callback = function(v)
        print("[Nunito] Distance:", v)
    end,
})

local FxSec = Visuals:CreateSection("Effects")

local oldLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
}

FxSec:Toggle({
    Text = "Fullbright",
    Default = false,
    Callback = function(state)
        if state then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
        else
            Lighting.Brightness = oldLighting.Brightness
            Lighting.ClockTime = oldLighting.ClockTime
            Lighting.FogEnd = oldLighting.FogEnd
        end
    end,
})

FxSec:Textbox({
    Text = "Chat Prefix",
    Default = "[Nunito]",
    Placeholder = "prefix",
    Callback = function(text)
        print("[Nunito] Prefix:", text)
    end,
})

FxSec:Label({ Text = "Visuals are client-side only" })

--=====================================================
-- MISC
--=====================================================
local Misc = Window:CreateTab("Misc")

local UtilSec = Misc:CreateSection("Utilities")

UtilSec:Button({
    Text = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end,
})

UtilSec:Button({
    Text = "Copy Join Script",
    Callback = function()
        local ok = pcall(function()
            setclipboard("roblox://experiences/start?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. game.JobId)
        end)
        if ok then
            Window:SendNotification("Скопировано в буфер", "success")
        else
            Window:SendNotification("setclipboard недоступен", "error")
        end
    end,
})

local ChatSec = Misc:CreateSection("Chat")

ChatSec:Textbox({
    Text = "Spam Message",
    Default = "Nunito on top",
    Placeholder = "message",
    Callback = function(text)
        print("[Nunito] Spam:", text)
    end,
})

ChatSec:Slider({
    Text = "Spam Delay (sec)",
    Min = 1,
    Max = 60,
    Default = 5,
    Callback = function(v)
        print("[Nunito] Delay:", v)
    end,
})

ChatSec:Label({ Text = "Nunito v1.2.0 | by WareSploit" })

--=====================================================
-- CONFIGS + THEMES
--=====================================================
Window:CreateConfigs()
Window:CreateThemes()

Window:SendNotification("Nunito Hub v" .. Nunito.Version .. " загружен", "success", 3)
Window:SendNotification("F - переключить Fly", "info", 4)
