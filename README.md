# 🟣 Nunito Library

<p align="center">
  <img src="https://shields.io" alt="License">
  <img src="https://shields.io" alt="Stars">
  <img src="https://shields.io" alt="Top Language">
</p>

---

**Nunito Library** — это современная, эстетичная и модульная UI-библиотека для Roblox. Разработана с упором на максимальную производительность, плавные анимации и строгий квадратный дизайн (clean square aesthetic).

---

## ✨ Особенности (Features)

*   🎨 **Purple Gradient Aesthetic:** Глубокий черный бэкграунд (`#0A0A0A`) в сочетании с яркими фиолетовыми градиентными акцентами.
*   📦 **Модульные компоненты:** Toggle, Slider, Dropdown, Keybind, Button, Textbox и ColorPicker.
*   💾 **Система конфигов:** Полная поддержка файловой системы (Сохранение, Загрузка, Удаление, Обновление).
*   🔔 **Система уведомлений:** Анимированные поп-апы с 4 типами: *Error, Warning, Success* и *Info*.
*   🌈 **Theme Engine:** Динамическое переключение между темами: *Purple, Blue, Red* и *Green*.
*   🚀 **Оптимизация:** Плавные твины (Tweens), полное отсутствие утечек памяти и чистая архитектура кода.
*   🖱️ **Интерактивность:** Перетаскиваемые окна (Draggable), кнопки сворачивания/закрытия и адаптивные hover-эффекты.

---

## 🚀 Быстрый старт & Пример (Usage)

Вставьте следующий Lua-скрипт в ваш контроллер или исполнитель (executor):

```lua
-- Загрузка библиотеки Nunito Library
local Nunito = loadstring(game:HttpGet("https://raw.githubusercontent.com/WareSploit/Nunito-Library/main/Nunito.lua"))()

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
