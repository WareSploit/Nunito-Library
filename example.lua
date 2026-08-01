local Nunito = loadstring(game:HttpGet("https://raw.githubusercontent.com/WareSploit/Nunito-Library/refs/heads/main/Nunito.lua"))()

local Window = Nunito:CreateWindow({
    Title = "Nunito Example"
})

local MainTab = Window:CreateTab("Main")
local VisualsTab = Window:CreateTab("Visuals")
local SettingsTab = Window:CreateTab("Settings")

local CombatSec = MainTab:CreateSection("Combat")
local MovementSec = MainTab:CreateSection("Movement")

CombatSec:Toggle({
    Text = "Aimbot",
    Default = false,
    Callback = function(v)
        print("Aimbot:", v)
    end
})

CombatSec:Slider({
    Text = "FOV",
    Min = 10, Max = 360, Default = 90,
    Callback = function(v)
        print("FOV:", v)
    end
})

CombatSec:Dropdown({
    Text = "Target Part",
    Options = {"Head", "Torso", "HumanoidRootPart"},
    Default = "Head",
    Callback = function(v)
        print("Target:", v)
    end
})

CombatSec:Keybind({
    Text = "Aim Key",
    Default = Enum.KeyCode.Q,
    Callback = function(type, key)
        if type == "press" then
            print("Pressed:", key)
        end
    end
})

MovementSec:Toggle({
    Text = "Speed Hack",
    Default = false,
    Callback = function(v)
        print("Speed Hack:", v)
    end
})

MovementSec:Slider({
    Text = "WalkSpeed",
    Min = 16, Max = 200, Default = 50,
    Callback = function(v)
        print("WalkSpeed:", v)
    end
})

local EspSec = VisualsTab:CreateSection("ESP")

EspSec:Toggle({
    Text = "Enable ESP",
    Default = true,
    Callback = function(v)
        print("ESP:", v)
    end
})

EspSec:ColorPicker({
    Text = "ESP Color",
    Default = Color3.fromRGB(138, 43, 226),
    Callback = function(c)
        print("Color:", c)
    end
})

EspSec:Button({
    Text = "Refresh ESP",
    Callback = function()
        Window:SendNotification("ESP Refreshed!", "success")
    end
})

local UiSec = SettingsTab:CreateSection("Interface")

UiSec:Toggle({
    Text = "Show Watermark",
    Default = true,
    Callback = function(v)
        print("Watermark:", v)
    end
})

UiSec:Dropdown({
    Text = "Theme",
    Options = {"Purple", "Blue", "Red", "Green"},
    Default = "Purple",
    Callback = function(v)
        print("Theme:", v)
    end
})

UiSec:Textbox({
    Text = "Username",
    Placeholder = "Enter your name...",
    Callback = function(v)
        print("Username:", v)
    end
})

Window:CreateConfigs()
Window:CreateThemes()

task.wait(2)
Window:SendNotification("Welcome to Nunito Example!", "info", 5)
Window:SendNotification("This is a warning message", "warning", 4)
Window:SendNotification("Something went wrong!", "error", 3)
Window:SendNotification("Action completed successfully", "success", 3)
