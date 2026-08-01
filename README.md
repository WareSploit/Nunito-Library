<div align="center">

# 🟣 Nunito Library

**Modern, aesthetic, and modular UI library for Roblox.**  
*Designed with a focus on performance, smooth animations, and a clean square aesthetic.*

<p align="center">
  <img src="https://img.shields.io/badge/Roblox-Studio-blue?style=for-the-badge&logo=roblox" alt="Roblox" />
  <img src="https://img.shields.io/badge/License-MIT-purple?style=for-the-badge" alt="License" />
  <img src="https://img.shields.io/badge/Status-Active-success?style=for-the-badge" alt="Status" />
</p>

</div>

---

## ✨ Features

* **🎨 Purple Gradient Aesthetic:** Deep black background (`#0A0A0A`) with vibrant purple accents.
* **📦 Modular Components:** Toggle, Slider, Dropdown, Keybind, Button, Textbox, and ColorPicker.
* **💾 Config System:** Full filesystem support (*Save, Load, Delete, Refresh*).
* **🔔 Notification System:** Animated pop-ups with 4 types: `Error`, `Warning`, `Success`, and `Info`.
* **🎨 Theme Engine:** Dynamically switch between `Purple`, `Blue`, `Red`, and `Green` themes.
* **🚀 Optimized:** Smooth tweens, zero memory leaks, and a clean code structure.
* **🖱️ Interactive:** Draggable window, minimize/close buttons, and fluid hover effects.

---

## 📦 Quick Start & Usage Example

Вставь следующий код в контроллер или скрипт своего исполнителя:

```lua
-- Загрузка библиотеки Nunito Library
local Nunito = loadstring(game:HttpGet("[https://raw.githubusercontent.com/WareSploit/Nunito-Library/main/Nunito.lua](https://raw.githubusercontent.com/WareSploit/Nunito-Library/main/Nunito.lua)"))()

-- Создание главного окна
local Window = Nunito:CreateWindow({
    Title = "Nunito Library | Modern UI"
})

-- Уведомление о старте
Window:SendNotification("Успешно загружено!", "success", 3)

-- Создание вкладок
local MainTab = Window:CreateTab("Main")
local SettingsTab = Window:CreateTab("Settings")

-- Создание секций
local MainSection = MainTab:CreateSection("Player Tweaks")
local ElementsSection = MainTab:CreateSection("UI Elements")

-- Toggle (Переключатель)
MainSection:Toggle({
    Text = "Enable Speed",
    Default = false,
    Callback = function(state)
        print("Speed Active:", state)
    end
})

-- Slider (Ползунок)
MainSection:Slider({
    Text = "WalkSpeed",
    Min = 16,
    Max = 250,
    Default = 16,
    Callback = function(val)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
        end
    end
})

-- Dropdown (Выпадающий список)
ElementsSection:Dropdown({
    Text = "Select Theme Mode",
    Options = {"Purple", "Blue", "Red", "Green"},
    Default = "Purple",
    Callback = function(selected)
        print("Selected Theme:", selected)
    end
})

-- Keybind (Назначение клавиши)
ElementsSection:Keybind({
    Text = "Toggle Menu Key",
    Default = Enum.KeyCode.RightControl,
    Callback = function(key)
        print("Key Pressed / Bound:", key)
    end
})

-- Textbox (Поле ввода)
ElementsSection:Textbox({
    Text = "Custom Message",
    Placeholder = "Type here...",
    Callback = function(text)
        Window:SendNotification("Entered: " .. text, "info", 3)
    end
})

-- Button (Кнопка)
ElementsSection:Button({
    Text = "Test Notification",
    Callback = function()
        Window:SendNotification("Warning: Action executed!", "warning", 4)
    end
})

📚 API ReferenceNunito:CreateWindow(config)Создает главное окно пользовательского интерфейса.config.Title (string): Заголовок окна.Window:CreateTab(name)Добавляет новую вкладку на боковую панель.name (string): Название вкладки.Tab:CreateSection(name)Группирует элементы управления внутри вкладки.name (string): Заголовок секции.Компоненты управления (Section:...)КомпонентПараметры и типыОписаниеToggleText (string), Default (boolean), Callback (function)Переключатель состояния (true / false).SliderText (string), Min (number), Max (number), Default (number), Callback (function)Настраиваемый числовой ползунок.DropdownText (string), Options (table), Default (string), Callback (function)Выпадающий список элементов.KeybindText (string), Default (Enum.KeyCode), Callback (function)Назначение горячей клавиши.ButtonText (string), Callback (function)Триггерная кнопка с нажатием.TextboxText (string), Placeholder (string), Callback (function)Поле для ввода текста (срабатывает при потере фокуса).Window:SendNotification(text, type, duration)Показывает всплывающее уведомление на экране.text (string): Текст сообщения.type (string): "error", "warning", "success" или "info".duration (number): Время отображения в секундах.📂 Project StructurePlaintextNunito-Library/
├── README.md       # Full documentation & Quick Start
├── Nunito.lua      # Core GUI Library Module
└── example.lua     # Extended usage example
📝 LicenseThis project is licensed under the MIT License. See the LICENSE file for details.🙌 CreditsDeveloped by: WareSploitDesign inspired by: Modern minimalist aesthetics and square UI trends.
<ElicitationsGroup message="Что сделать дальше?">
  <Elicitation label="Написать полный код основного модуля Nunito.lua" query="Напиши исходный код библиотеки Nunito.lua на Roblox Lua с реализацией элементов UI."/>
  <Elicitation label="Создать файл example.lua" query="Создай полный отдельный файл example.lua со всеми примерами использования."/>
</ElicitationsGroup>
