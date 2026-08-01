# 🟣 Nunito Library

<p align="center">
  <img src="https://img.shields.io/badge/Roblox-Studio-blue?style=for-the-badge&logo=roblox" alt="Roblox" />
  <img src="https://img.shields.io/badge/License-MIT-purple?style=for-the-badge" alt="License" />
  <img src="https://img.shields.io/badge/Status-Active-success?style=for-the-badge" alt="Status" />
</p>

---

**Nunito Library** is a modern, aesthetic, and modular UI library for Roblox. Designed with a focus on maximum performance, smooth animations, and a strict square design (clean square aesthetic).

---

## ✨ Features

*   🎨 **Purple Gradient Aesthetic:** Deep black background (`#0A0A0A`) combined with vibrant purple gradient accents.
*   📦 **Modular Components:** Toggle, Slider, Dropdown, Keybind, Button, Textbox, and ColorPicker.
*   💾 **Config System:** Full filesystem support (Save, Load, Delete, Refresh).
*   🔔 **Notification System:** Animated pop-ups with 4 types: *Error, Warning, Success*, and *Info*.
*   🌈 **Theme Engine:** Dynamic switching between themes: *Purple, Blue, Red*, and *Green*.
*   🚀 **Optimization:** Smooth tweens, zero memory leaks, and clean code architecture.
*   🖱️ **Interactivity:** Draggable windows, minimize/close buttons, and adaptive hover effects.

---

## 🚀 Quick Start & Usage

Copy and paste the following Lua script into your executor:

```lua
-- Load Nunito Library
local Nunito = loadstring(game:HttpGet("https://raw.githubusercontent.com/WareSploit/Nunito-Library/main/Nunito.lua"))()

-- Create Main Window
local Window = Nunito:CreateWindow({
    Title = "Nunito Library | Modern UI"
})

-- Startup Notification
Window:SendNotification("Successfully Loaded!", "success", 3)

-- Create Tabs
local MainTab = Window:CreateTab("Main")
local SettingsTab = Window:CreateTab("Settings")

-- Create Sections
local MainSection = MainTab:CreateSection("Player Tweaks")
local ElementsSection = MainTab:CreateSection("UI Elements")

-- Toggle
MainSection:Toggle({
    Text = "Enable Speed",
    Default = false,
    Callback = function(state)
        print("Speed Active:", state)
    end
})

-- Slider
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

-- Dropdown
ElementsSection:Dropdown({
    Text = "Select Theme Mode",
    Options = {"Purple", "Blue", "Red", "Green"},
    Default = "Purple",
    Callback = function(selected)
        print("Selected Theme:", selected)
    end
})

-- Keybind
ElementsSection:Keybind({
    Text = "Toggle Menu Key",
    Default = Enum.KeyCode.RightControl,
    Callback = function(key)
        print("Key Pressed / Bound:", key)
    end
})

-- Textbox
ElementsSection:Textbox({
    Text = "Custom Message",
    Placeholder = "Type here...",
    Callback = function(text)
        Window:SendNotification("Entered: " .. text, "info", 3)
    end
})

-- Button
ElementsSection:Button({
    Text = "Test Notification",
    Callback = function()
        Window:SendNotification("Warning: Action executed!", "warning", 4)
    end
})

-- Enable Systems
Window:CreateConfigs()
Window:CreateThemes()
```

---

## 📚 Документация API (API Reference)

### 🪟 Инициализация интерфейса

#### `Nunito:CreateWindow(config)`
Создает главное окно пользовательского интерфейса.
*   `config.Title` *(string)* — Заголовок окна.

#### `Window:CreateTab(name)`
Добавляет новую вкладку на боковую панель.
*   `name` *(string)* — Название вкладки.

#### `Tab:CreateSection(name)`
Группирует элементы управления внутри конкретной вкладки.
*   `name` *(string)* — Заголовок секции.

---

### 🎛️ Компоненты управления (`Section:...`)

| Компонент | Параметры и типы | Описание |
| :--- | :--- | :--- |
| **Toggle** | `Text` (str), `Default` (bool), `Callback` (func) | Переключатель состояния (`true` / `false`). |
| **Slider** | `Text` (str), `Min` (num), `Max` (num), `Default` (num), `Callback` (func) | Настраиваемый числовой ползунок. |
| **Dropdown** | `Text` (str), `Options` (table), `Default` (str), `Callback` (func) | Выпадающий список элементов. |
| **Keybind** | `Text` (str), `Default` (Enum.KeyCode), `Callback` (func) | Назначение горячей клавиши для действия. |
| **Button** | `Text` (str), `Callback` (func) | Триггерная кнопка для выполнения функции. |
| **Textbox** | `Text` (str), `Placeholder` (str), `Callback` (func) | Поле для ввода текста (срабатывает при потере фокуса). |

---

### 🔔 Системные вызовы

#### `Window:SendNotification(text, type, duration)`
Показывает красивое всплывающее уведомление на экране пользователя.
*   `text` *(string)* — Текст сообщения.
*   `type` *(string)* — Тип иконки/стиля: `"error"`, `"warning"`, `"success"` или `"info"`.
*   `duration` *(number)* — Время отображения в секундах до исчезновения.

---

## 📂 Структура проекта (Project Structure)

```plaintext
Nunito-Library/
├── README.md       # Подробная документация и быстрый старт
├── Nunito.lua      # Ядро библиотеки (Core GUI Module)
└── example.lua     # Расширенный пример использования всех функций
```

---

## 🤝 Авторы и Благодарности (Credits)

*   **Разработчик:** [@WareSploit](https://github.com)
*   **Дизайн:** Вдохновлено современными трендами минимализма и плоских квадратных UI (Square UI).

---

## 📝 Лицензия (License)

Проект распространяется под лицензией **MIT License**. Подробности читайте в файле [LICENSE](LICENSE).
