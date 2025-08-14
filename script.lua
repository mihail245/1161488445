--[[
    Продвинутое меню телепортации с сохранением точек
    Улучшенные функции:
    - Современный UI с анимациями и эффектами
    - Сохранение точек телепорта с названиями и иконками
    - Удаление/редактирование сохраненных точек
    - Телепорт к координатам с вводом вручную
    - Телепорт к игроку (из списка онлайн-игроков)
    - Постоянная телепортация за игроком (режим слежения)
    - Отображение текущих координат
    - Экспорт/импорт точек телепортации
    - Поиск по сохраненным точкам
    - Категории для точек телепортации
    - Настройка интерфейса (цвета, прозрачность)
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Настройки
local SETTINGS = {
    AutoSave = true,
    SaveKey = "TeleportMenuData_v3",
    DefaultCategory = "Основные",
    FollowDistance = 3,
    FollowHeight = 0
}

-- Цветовая схема
local ColorScheme = {
    Background = Color3.fromRGB(25, 30, 40),
    Primary = Color3.fromRGB(65, 125, 210),
    Secondary = Color3.fromRGB(45, 85, 160),
    Accent = Color3.fromRGB(90, 190, 255),
    Text = Color3.fromRGB(245, 245, 245),
    Error = Color3.fromRGB(225, 75, 75),
    Success = Color3.fromRGB(75, 225, 110),
    Warning = Color3.fromRGB(255, 165, 0),
    SavedLocation = Color3.fromRGB(85, 195, 100),
    DeleteButton = Color3.fromRGB(200, 70, 70),
    EditButton = Color3.fromRGB(255, 200, 0),
    Category = Color3.fromRGB(120, 85, 180)
}

-- Иконки для кнопок
local Icons = {
    Add = "rbxassetid://3926305904",
    Delete = "rbxassetid://3926307971",
    Edit = "rbxassetid://3926307971",
    Teleport = "rbxassetid://3926307971",
    Player = "rbxassetid://3926307971",
    Coordinates = "rbxassetid://3926307971",
    Follow = "rbxassetid://3926307971",
    Save = "rbxassetid://3926307971",
    Load = "rbxassetid://3926307971",
    Settings = "rbxassetid://3926307971",
    Search = "rbxassetid://3926307971",
    Category = "rbxassetid://3926307971"
}

-- Данные меню
local MenuData = {
    SavedLocations = {},
    Categories = {SETTINGS.DefaultCategory},
    TrackingPlayer = nil,
    TrackingConnection = nil,
    CoordsEnabled = false,
    MenuVisible = true,
    CurrentCategory = SETTINGS.DefaultCategory,
    SearchQuery = ""
}

-- Создание основного интерфейса
local TeleportMenu = Instance.new("ScreenGui")
TeleportMenu.Name = "TeleportMenu"
TeleportMenu.ResetOnSpawn = false
TeleportMenu.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
TeleportMenu.DisplayOrder = 999

-- Основной фрейм с эффектом стекла
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0.35, 0, 0.6, 0)
MainFrame.Position = UDim2.new(0.02, 0, 0.2, 0)
MainFrame.BackgroundColor3 = ColorScheme.Background
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0

-- Эффект стекла
local GlassEffect = Instance.new("Frame")
GlassEffect.Size = UDim2.new(1, 0, 1, 0)
GlassEffect.BackgroundTransparency = 0.9
GlassEffect.BackgroundColor3 = Color3.fromRGB(200, 200, 255)
GlassEffect.BorderSizePixel = 0
GlassEffect.ZIndex = -1

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.04, 0)
UICorner.Parent = MainFrame
UICorner.Parent = GlassEffect

-- Тень
local DropShadow = Instance.new("ImageLabel")
DropShadow.Name = "DropShadow"
DropShadow.Image = "rbxassetid://1316045217"
DropShadow.ImageColor3 = Color3.new(0, 0, 0)
DropShadow.ImageTransparency = 0.8
DropShadow.ScaleType = Enum.ScaleType.Slice
DropShadow.SliceCenter = Rect.new(10, 10, 118, 118)
DropShadow.Size = UDim2.new(1, 10, 1, 10)
DropShadow.Position = UDim2.new(0, -5, 0, -5)
DropShadow.BackgroundTransparency = 1
DropShadow.Parent = MainFrame

-- Заголовок с градиентом
local Title = Instance.new("Frame")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0.07, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, ColorScheme.Primary),
    ColorSequenceKeypoint.new(1, ColorScheme.Accent)
})
TitleGradient.Rotation = 90
TitleGradient.Parent = Title

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.Text = "🚀 ТЕЛЕПОРТ МЕНЮ"
TitleText.TextColor3 = ColorScheme.Text
TitleText.TextScaled = true
TitleText.Font = Enum.Font.GothamBold
TitleText.BackgroundTransparency = 1
TitleText.Parent = Title

-- Панель управления
local ControlPanel = Instance.new("Frame")
ControlPanel.Name = "ControlPanel"
ControlPanel.Size = UDim2.new(1, 0, 0.08, 0)
ControlPanel.Position = UDim2.new(0, 0, 0.07, 0)
ControlPanel.BackgroundTransparency = 1

-- Кнопка переключения категорий
local CategoryButton = Instance.new("TextButton")
CategoryButton.Name = "CategoryButton"
CategoryButton.Size = UDim2.new(0.3, 0, 0.8, 0)
CategoryButton.Position = UDim2.new(0.02, 0, 0.1, 0)
CategoryButton.Text = SETTINGS.DefaultCategory
CategoryButton.TextColor3 = ColorScheme.Text
CategoryButton.Font = Enum.Font.GothamMedium
CategoryButton.BackgroundColor3 = ColorScheme.Category
CategoryButton.BackgroundTransparency = 0.2

local CategoryCorner = Instance.new("UICorner")
CategoryCorner.CornerRadius = UDim.new(0.2, 0)
CategoryCorner.Parent = CategoryButton

-- Поле поиска
local SearchBox = Instance.new("TextBox")
SearchBox.Name = "SearchBox"
SearchBox.Size = UDim2.new(0.4, 0, 0.8, 0)
SearchBox.Position = UDim2.new(0.34, 0, 0.1, 0)
SearchBox.PlaceholderText = "Поиск..."
SearchBox.Text = ""
SearchBox.TextColor3 = ColorScheme.Text
SearchBox.Font = Enum.Font.Gotham
SearchBox.BackgroundColor3 = ColorScheme.Background
SearchBox.BackgroundTransparency = 0.7
SearchBox.ClearTextOnFocus = false

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0.2, 0)
SearchCorner.Parent = SearchBox

local SearchIcon = Instance.new("ImageLabel")
SearchIcon.Name = "SearchIcon"
SearchIcon.Size = UDim2.new(0.15, 0, 0.7, 0)
SearchIcon.Position = UDim2.new(0.85, 0, 0.15, 0)
SearchIcon.Image = Icons.Search
SearchIcon.ImageColor3 = ColorScheme.Accent
SearchIcon.BackgroundTransparency = 1
SearchIcon.Parent = SearchBox

-- Кнопка настроек
local SettingsButton = Instance.new("ImageButton")
SettingsButton.Name = "SettingsButton"
SettingsButton.Size = UDim2.new(0.1, 0, 0.8, 0)
SettingsButton.Position = UDim2.new(0.88, 0, 0.1, 0)
SettingsButton.Image = Icons.Settings
SettingsButton.ImageColor3 = ColorScheme.Text
SettingsButton.BackgroundColor3 = ColorScheme.Primary
SettingsButton.BackgroundTransparency = 0.2

local SettingsCorner = Instance.new("UICorner")
SettingsCorner.CornerRadius = UDim.new(0.2, 0)
SettingsCorner.Parent = SettingsButton

-- Область прокрутки для точек телепортации
local LocationsScroll = Instance.new("ScrollingFrame")
LocationsScroll.Name = "LocationsScroll"
LocationsScroll.Size = UDim2.new(1, 0, 0.7, 0)
LocationsScroll.Position = UDim2.new(0, 0, 0.15, 0)
LocationsScroll.BackgroundTransparency = 1
LocationsScroll.ScrollBarThickness = 5
LocationsScroll.ScrollBarImageColor3 = ColorScheme.Accent
LocationsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LocationsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local LocationsLayout = Instance.new("UIListLayout")
LocationsLayout.Padding = UDim.new(0, 8)
LocationsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
LocationsLayout.Parent = LocationsScroll

local LocationsPadding = Instance.new("UIPadding")
LocationsPadding.PaddingTop = UDim.new(0, 8)
LocationsPadding.PaddingBottom = UDim.new(0, 8)
LocationsPadding.PaddingLeft = UDim.new(0, 8)
LocationsPadding.PaddingRight = UDim.new(0, 8)
LocationsPadding.Parent = LocationsScroll

-- Панель действий
local ActionsPanel = Instance.new("Frame")
ActionsPanel.Name = "ActionsPanel"
ActionsPanel.Size = UDim2.new(1, 0, 0.15, 0)
ActionsPanel.Position = UDim2.new(0, 0, 0.85, 0)
ActionsPanel.BackgroundTransparency = 1

local ActionsLayout = Instance.new("UIListLayout")
ActionsLayout.FillDirection = Enum.FillDirection.Horizontal
ActionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ActionsLayout.Padding = UDim.new(0, 10)
ActionsLayout.Parent = ActionsPanel

-- Кнопка переключения меню
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0.06, 0, 0.06, 0)
ToggleButton.Position = UDim2.new(0.02, 0, 0.02, 0)
ToggleButton.BackgroundColor3 = ColorScheme.Primary
ToggleButton.BackgroundTransparency = 0.2
ToggleButton.Image = "rbxassetid://3926305904"
ToggleButton.ImageRectOffset = Vector2.new(124, 204)
ToggleButton.ImageRectSize = Vector2.new(36, 36)
ToggleButton.ImageColor3 = ColorScheme.Text

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0.5, 0)
ToggleCorner.Parent = ToggleButton

-- Индикатор координат
local CoordsDisplay = Instance.new("TextLabel")
CoordsDisplay.Name = "CoordsDisplay"
CoordsDisplay.Size = UDim2.new(0.25, 0, 0.04, 0)
CoordsDisplay.Position = UDim2.new(0.375, 0, 0, 0)
CoordsDisplay.BackgroundColor3 = ColorScheme.Background
CoordsDisplay.BackgroundTransparency = 0.7
CoordsDisplay.Text = "X: 0, Y: 0, Z: 0"
CoordsDisplay.TextColor3 = ColorScheme.Accent
CoordsDisplay.TextScaled = true
CoordsDisplay.Font = Enum.Font.GothamBold
CoordsDisplay.Visible = false

local CoordsCorner = Instance.new("UICorner")
CoordsCorner.CornerRadius = UDim.new(0.1, 0)
CoordsCorner.Parent = CoordsDisplay

local CoordsShadow = DropShadow:Clone()
CoordsShadow.Parent = CoordsDisplay

-- Сборка интерфейса
MainFrame.Parent = TeleportMenu
GlassEffect.Parent = MainFrame
Title.Parent = MainFrame
ControlPanel.Parent = MainFrame
CategoryButton.Parent = ControlPanel
SearchBox.Parent = ControlPanel
SettingsButton.Parent = ControlPanel
LocationsScroll.Parent = MainFrame
ActionsPanel.Parent = MainFrame
ToggleButton.Parent = TeleportMenu
CoordsDisplay.Parent = TeleportMenu
TeleportMenu.Parent = playerGui

-- Функция загрузки сохраненных данных
local function LoadData()
    local success, data = pcall(function()
        return HttpService:JSONDecode(localPlayer:GetAttribute(SETTINGS.SaveKey) or {}
    end)
    
    if success and data then
        MenuData.SavedLocations = data.SavedLocations or {}
        MenuData.Categories = data.Categories or {SETTINGS.DefaultCategory}
        MenuData.CurrentCategory = data.CurrentCategory or SETTINGS.DefaultCategory
    else
        MenuData.SavedLocations = {}
        MenuData.Categories = {SETTINGS.DefaultCategory}
        MenuData.CurrentCategory = SETTINGS.DefaultCategory
    end
    
    -- Обновляем кнопку категории
    CategoryButton.Text = MenuData.CurrentCategory
end

-- Функция сохранения данных
local function SaveData()
    if SETTINGS.AutoSave then
        local data = {
            SavedLocations = MenuData.SavedLocations,
            Categories = MenuData.Categories,
            CurrentCategory = MenuData.CurrentCategory
        }
        
        local success, err = pcall(function()
            localPlayer:SetAttribute(SETTINGS.SaveKey, HttpService:JSONEncode(data))
        end)
        
        if not success then
            warn("Ошибка сохранения данных: " .. err)
        end
    end
end

-- Функция создания кнопки с улучшенным дизайном
local function CreateButton(text, callback, options)
    options = options or {}
    local button = Instance.new("TextButton")
    button.Name = text
    button.Size = options.Size or UDim2.new(0.9, 0, 0, 50)
    button.BackgroundColor3 = options.BackgroundColor or ColorScheme.Primary
    button.BackgroundTransparency = options.Transparency or 0.2
    button.Text = text
    button.TextColor3 = options.TextColor or ColorScheme.Text
    button.TextScaled = true
    button.Font = Enum.Font.GothamMedium
    button.AutoButtonColor = false
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0.1, 0)
    buttonCorner.Parent = button
    
    local textConstraint = Instance.new("UITextSizeConstraint")
    textConstraint.MaxTextSize = 18
    textConstraint.Parent = button
    
    -- Добавляем иконку, если указана
    if options.Icon then
        local icon = Instance.new("ImageLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(0.15, 0, 0.7, 0)
        icon.Position = UDim2.new(0.05, 0, 0.15, 0)
        icon.Image = options.Icon
        icon.ImageColor3 = options.IconColor or ColorScheme.Text
        icon.BackgroundTransparency = 1
        icon.Parent = button
        
        -- Сдвигаем текст, чтобы освободить место для иконки
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.PaddingLeft = UDim.new(0.15, 0)
    end
    
    -- Эффект при наведении
    local hoverEffect = Instance.new("Frame")
    hoverEffect.Name = "HoverEffect"
    hoverEffect.Size = UDim2.new(1, 10, 1, 10)
    hoverEffect.Position = UDim2.new(0, -5, 0, -5)
    hoverEffect.BackgroundTransparency = 1
    hoverEffect.ZIndex = -1
    
    local hoverGlow = Instance.new("ImageLabel")
    hoverGlow.Image = "rbxassetid://5028857084"
    hoverGlow.ImageColor3 = options.HoverColor or ColorScheme.Accent
    hoverGlow.ImageTransparency = 0.9
    hoverGlow.ScaleType = Enum.ScaleType.Slice
    hoverGlow.SliceCenter = Rect.new(24, 24, 276, 276)
    hoverGlow.Size = UDim2.new(1, 0, 1, 0)
    hoverGlow.BackgroundTransparency = 1
    hoverGlow.Parent = hoverEffect
    
    hoverEffect.Parent = button
    hoverEffect.Visible = false
    
    -- Анимации при наведении
    button.MouseEnter:Connect(function()
        hoverEffect.Visible = true
        TweenService:Create(button, TweenInfo.new(0.15), {
            BackgroundColor3 = options.HoverColor or ColorScheme.Accent,
            BackgroundTransparency = 0.1
        }):Play()
        TweenService:Create(hoverGlow, TweenInfo.new(0.15), {
            ImageTransparency = 0.8
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        hoverEffect.Visible = false
        TweenService:Create(button, TweenInfo.new(0.15), {
            BackgroundColor3 = options.BackgroundColor or ColorScheme.Primary,
            BackgroundTransparency = options.Transparency or 0.2
        }):Play()
    end)
    
    -- Обработка нажатия
    button.MouseButton1Click:Connect(function()
        if not options.Debounce then
            -- Анимация нажатия
            TweenService:Create(button, TweenInfo.new(0.1), {
                BackgroundTransparency = 0,
                Size = button.Size - UDim2.new(0.02, 0, 0.02, 0)
            }):Play()
            
            task.wait(0.1)
            
            TweenService:Create(button, TweenInfo.new(0.1), {
                BackgroundTransparency = options.Transparency or 0.2,
                Size = button.Size
            }):Play()
            
            -- Вызов колбэка
            if callback then callback() end
        end
    end)
    
    return button
end

-- Функция показа всплывающего сообщения
local function ShowPopup(title, message, popupType)
    popupType = popupType or "info" -- info, error, success, warning
    
    local colorMap = {
        info = ColorScheme.Accent,
        error = ColorScheme.Error,
        success = ColorScheme.Success,
        warning = ColorScheme.Warning
    }
    
    local popupColor = colorMap[popupType] or ColorScheme.Accent
    
    local popup = Instance.new("Frame")
    popup.Name = "Popup"
    popup.Size = UDim2.new(0.8, 0, 0.12, 0)
    popup.Position = UDim2.new(0.1, 0, 0.4, 0)
    popup.BackgroundColor3 = ColorScheme.Background
    popup.BackgroundTransparency = 0.1
    popup.ZIndex = 100
    
    local popupCorner = Instance.new("UICorner")
    popupCorner.CornerRadius = UDim.new(0.05, 0)
    popupCorner.Parent = popup
    
    local popupShadow = DropShadow:Clone()
    popupShadow.Parent = popup
    
    local popupGlass = GlassEffect:Clone()
    popupGlass.Parent = popup
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.4, 0)
    titleLabel.Text = title
    titleLabel.TextColor3 = popupColor
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.BackgroundTransparency = 1
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, 0, 0.6, 0)
    messageLabel.Position = UDim2.new(0, 0, 0.4, 0)
    messageLabel.Text = message
    messageLabel.TextColor3 = ColorScheme.Text
    messageLabel.TextScaled = true
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.BackgroundTransparency = 1
    
    popup.Parent = TeleportMenu
    titleLabel.Parent = popup
    messageLabel.Parent = popup
    
    -- Анимация появления
    popup.BackgroundTransparency = 1
    popupGlass.BackgroundTransparency = 1
    titleLabel.TextTransparency = 1
    messageLabel.TextTransparency = 1
    
    TweenService:Create(popup, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(popupGlass, TweenInfo.new(0.3), {BackgroundTransparency = 0.9}):Play()
    TweenService:Create(titleLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(messageLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    
    -- Автозакрытие
    task.delay(3, function()
        TweenService:Create(popup, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(popupGlass, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(titleLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(messageLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        task.wait(0.3)
        popup:Destroy()
    end)
end

-- Функция телепортации
local function TeleportTo(position)
    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position)
        return true
    end
    return false
end

-- Функция создания карточки точки телепортации
local function CreateLocationCard(locationData)
    local container = Instance.new("Frame")
    container.Name = locationData.Name
    container.Size = UDim2.new(0.95, 0, 0, 60)
    container.BackgroundTransparency = 1
    
    local card = Instance.new("Frame")
    card.Name = "Card"
    card.Size = UDim2.new(0.8, 0, 1, 0)
    card.Position = UDim2.new(0, 0, 0, 0)
    card.BackgroundColor3 = ColorScheme.SavedLocation
    card.BackgroundTransparency = 0.2
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0.1, 0)
    cardCorner.Parent = card
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(0.7, 0, 0.6, 0)
    nameLabel.Position = UDim2.new(0.1, 0, 0.1, 0)
    nameLabel.Text = locationData.Name
    nameLabel.TextColor3 = ColorScheme.Text
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.BackgroundTransparency = 1
    
    local coordsLabel = Instance.new("TextLabel")
    coordsLabel.Name = "Coords"
    coordsLabel.Size = UDim2.new(0.7, 0, 0.4, 0)
    coordsLabel.Position = UDim2.new(0.1, 0, 0.6, 0)
    coordsLabel.Text = string.format("X: %d, Y: %d, Z: %d", 
        math.floor(locationData.Position.X), 
        math.floor(locationData.Position.Y), 
        math.floor(locationData.Position.Z))
    coordsLabel.TextColor3 = ColorScheme.Text
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    coordsLabel.TextTransparency = 0.5
    coordsLabel.Font = Enum.Font.Gotham
    coordsLabel.BackgroundTransparency = 1
    
    local categoryLabel = Instance.new("TextLabel")
    categoryLabel.Name = "Category"
    categoryLabel.Size = UDim2.new(0.2, 0, 0.3, 0)
    categoryLabel.Position = UDim2.new(0.7, 0, 0.1, 0)
    categoryLabel.Text = locationData.Category or SETTINGS.DefaultCategory
    categoryLabel.TextColor3 = ColorScheme.Category
    categoryLabel.Font = Enum.Font.GothamMedium
    categoryLabel.BackgroundTransparency = 1
    
    -- Кнопка телепортации
    local teleportBtn = CreateButton("", function()
        if TeleportTo(locationData.Position) then
            ShowPopup("Телепортация", "Перемещение к '"..locationData.Name.."'", "success")
        else
            ShowPopup("Ошибка", "Не удалось телепортироваться", "error")
        end
    end, {
        Size = UDim2.new(0.8, 0, 1, 0),
        BackgroundColor = ColorScheme.SavedLocation,
        Transparency = 0.2,
        HoverColor = ColorScheme.Accent,
        Debounce = true
    })
    
    teleportBtn.Parent = card
    nameLabel.Parent = card
    coordsLabel.Parent = card
    categoryLabel.Parent = card
    card.Parent = container
    
    -- Кнопка редактирования
    local editBtn = CreateButton("", function()
        ShowEditLocationPopup(locationData)
    end, {
        Size = UDim2.new(0.15, 0, 1, 0),
        Position = UDim2.new(0.8, 0, 0, 0),
        BackgroundColor = ColorScheme.EditButton,
        Icon = Icons.Edit,
        HoverColor = ColorScheme.Warning
    })
    
    editBtn.Parent = container
    
    -- Кнопка удаления
    local deleteBtn = CreateButton("", function()
        MenuData.SavedLocations[locationData.Name] = nil
        UpdateLocationsList()
        ShowPopup("Удалено", "Точка '"..locationData.Name.."' удалена", "success")
    end, {
        Size = UDim2.new(0.15, 0, 1, 0),
        Position = UDim2.new(0.95, 0, 0, 0),
        BackgroundColor = ColorScheme.DeleteButton,
        Icon = Icons.Delete,
        HoverColor = ColorScheme.Error
    })
    
    deleteBtn.Parent = container
    
    return container
end

-- Функция обновления списка точек телепортации
local function UpdateLocationsList()
    -- Очищаем текущий список
    for _, child in ipairs(LocationsScroll:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "UIListLayout" then
            child:Destroy()
        end
    end
    
    -- Фильтрация по категории и поисковому запросу
    local filteredLocations = {}
    for name, location in pairs(MenuData.SavedLocations) do
        if (MenuData.CurrentCategory == "Все" or location.Category == MenuData.CurrentCategory) and
           (MenuData.SearchQuery == "" or string.find(string.lower(name), string.lower(MenuData.SearchQuery))) then
            table.insert(filteredLocations, location)
        end
    end
    
    -- Сортировка по алфавиту
    table.sort(filteredLocations, function(a, b)
        return a.Name < b.Name
    end)
    
    -- Добавляем отфильтрованные точки
    for _, location in ipairs(filteredLocations) do
        local card = CreateLocationCard(location)
        card.Parent = LocationsScroll
    end
    
    -- Сохраняем изменения
    SaveData()
end

-- Функция создания попапа редактирования точки
local function ShowEditLocationPopup(locationData)
    local popup = Instance.new("Frame")
    popup.Name = "EditLocationPopup"
    popup.Size = UDim2.new(0.8, 0, 0.4, 0)
    popup.Position = UDim2.new(0.1, 0, 0.3, 0)
    popup.BackgroundColor3 = ColorScheme.Background
    popup.BackgroundTransparency = 0.1
    popup.ZIndex = 100
    
    local popupCorner = Instance.new("UICorner")
    popupCorner.CornerRadius = UDim.new(0.05, 0)
    popupCorner.Parent = popup
    
    local popupShadow = DropShadow:Clone()
    popupShadow.Parent = popup
    
    local popupGlass = GlassEffect:Clone()
    popupGlass.Parent = popup
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.15, 0)
    title.Text = "Редактирование точки"
    title.TextColor3 = ColorScheme.Accent
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    
    local nameInput = Instance.new("TextBox")
    nameInput.Size = UDim2.new(0.9, 0, 0.15, 0)
    nameInput.Position = UDim2.new(0.05, 0, 0.15, 0)
    nameInput.Text = locationData.Name
    nameInput.PlaceholderText = "Название точки"
    nameInput.BackgroundColor3 = ColorScheme.Primary
    nameInput.BackgroundTransparency = 0.3
    nameInput.TextColor3 = ColorScheme.Text
    nameInput.Font = Enum.Font.Gotham
    nameInput.ClearTextOnFocus = false
    
    local nameCorner = Instance.new("UICorner")
    nameCorner.CornerRadius = UDim.new(0.05, 0)
    nameCorner.Parent = nameInput
    
    local coordsInput = Instance.new("TextBox")
    coordsInput.Size = UDim2.new(0.9, 0, 0.15, 0)
    coordsInput.Position = UDim2.new(0.05, 0, 0.35, 0)
    coordsInput.Text = string.format("%.1f, %.1f, %.1f", 
        locationData.Position.X, 
        locationData.Position.Y, 
        locationData.Position.Z)
    coordsInput.PlaceholderText = "X, Y, Z"
    coordsInput.BackgroundColor3 = ColorScheme.Primary
    coordsInput.BackgroundTransparency = 0.3
    coordsInput.TextColor3 = ColorScheme.Text
    coordsInput.Font = Enum.Font.Gotham
    coordsInput.ClearTextOnFocus = false
    nameCorner:Clone().Parent = coordsInput
    
    -- Выбор категории
    local categoryDropdown = Instance.new("TextButton")
    categoryDropdown.Name = "CategoryDropdown"
    categoryDropdown.Size = UDim2.new(0.9, 0, 0.15, 0)
    categoryDropdown.Position = UDim2.new(0.05, 0, 0.55, 0)
    categoryDropdown.Text = locationData.Category or SETTINGS.DefaultCategory
    categoryDropdown.TextColor3 = ColorScheme.Text
    categoryDropdown.Font = Enum.Font.Gotham
    categoryDropdown.BackgroundColor3 = ColorScheme.Primary
    categoryDropdown.BackgroundTransparency = 0.3
    nameCorner:Clone().Parent = categoryDropdown
    
    -- Кнопки действий
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(0.9, 0, 0.15, 0)
    buttonContainer.Position = UDim2.new(0.05, 0, 0.75, 0)
    buttonContainer.BackgroundTransparency = 1
    
    local saveBtn = CreateButton("Сохранить", function()
        local newName = nameInput.Text
        local coordsText = coordsInput.Text
        local newCategory = categoryDropdown.Text
        
        if newName == "" then
            ShowPopup("Ошибка", "Введите название точки", "error")
            return
        end
        
        -- Парсим координаты
        local coords = {}
        for coord in string.gmatch(coordsText, "[^,]+") do
            table.insert(coords, tonumber(coord))
        end
        
        if #coords ~= 3 then
            ShowPopup("Ошибка", "Некорректные координаты", "error")
            return
        end
        
        -- Удаляем старую запись, если имя изменилось
        if newName ~= locationData.Name then
            MenuData.SavedLocations[locationData.Name] = nil
        end
        
        -- Сохраняем новую точку
        MenuData.SavedLocations[newName] = {
            Name = newName,
            Position = Vector3.new(coords[1], coords[2], coords[3]),
            Category = newCategory
        }
        
        UpdateLocationsList()
        ShowPopup("Успех", "Точка сохранена", "success")
        popup:Destroy()
    end, {
        Size = UDim2.new(0.45, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0)
    })
    
    local cancelBtn = CreateButton("Отмена", function()
        popup:Destroy()
    end, {
        Size = UDim2.new(0.45, 0, 1, 0),
        Position = UDim2.new(0.55, 0, 0, 0),
        BackgroundColor = ColorScheme.DeleteButton
    })
    
    popup.Parent = TeleportMenu
    title.Parent = popup
    nameInput.Parent = popup
    coordsInput.Parent = popup
    categoryDropdown.Parent = popup
    buttonContainer.Parent = popup
    saveBtn.Parent = buttonContainer
    cancelBtn.Parent = buttonContainer
    
    -- Анимация появления
    popup.BackgroundTransparency = 1
    popupGlass.BackgroundTransparency = 1
    title.TextTransparency = 1
    nameInput.BackgroundTransparency = 1
    nameInput.TextTransparency = 1
    coordsInput.BackgroundTransparency = 1
    coordsInput.TextTransparency = 1
    categoryDropdown.BackgroundTransparency = 1
    categoryDropdown.TextTransparency = 1
    saveBtn.BackgroundTransparency = 1
    saveBtn.TextTransparency = 1
    cancelBtn.BackgroundTransparency = 1
    cancelBtn.TextTransparency = 1
    
    TweenService:Create(popup, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(popupGlass, TweenInfo.new(0.3), {BackgroundTransparency = 0.9}):Play()
    TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(nameInput, TweenInfo.new(0.3), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
    TweenService:Create(coordsInput, TweenInfo.new(0.3), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
    TweenService:Create(categoryDropdown, TweenInfo.new(0.3), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
    TweenService:Create(saveBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.2, TextTransparency = 0}):Play()
    TweenService:Create(cancelBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.2, TextTransparency = 0}):Play()
    
    -- Обработчик выбора категории
    categoryDropdown.MouseButton1Click:Connect(function()
        local categoryPopup = Instance.new("Frame")
        categoryPopup.Name = "CategoryPopup"
        categoryPopup.Size = UDim2.new(0.8, 0, 0.3, 0)
        categoryPopup.Position = UDim2.new(0.1, 0, 0.2, 0)
        categoryPopup.BackgroundColor3 = ColorScheme.Background
        categoryPopup.BackgroundTransparency = 0.1
        categoryPopup.ZIndex = 110
        
        local categoryPopupCorner = Instance.new("UICorner")
        categoryPopupCorner.CornerRadius = UDim.new(0.05, 0)
        categoryPopupCorner.Parent = categoryPopup
        
        local categoryPopupShadow = DropShadow:Clone()
        categoryPopupShadow.Parent = categoryPopup
        
        local categoryPopupGlass = GlassEffect:Clone()
        categoryPopupGlass.Parent = categoryPopup
        
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(0.9, 0, 0.9, 0)
        scroll.Position = UDim2.new(0.05, 0, 0.05, 0)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 5
        scroll.ScrollBarImageColor3 = ColorScheme.Accent
        scroll.CanvasSize = UDim2.new(0, 0, 0, #MenuData.Categories * 40)
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 5)
        layout.Parent = scroll
        
        for _, category in ipairs(MenuData.Categories) do
            local btn = CreateButton(category, function()
                categoryDropdown.Text = category
                categoryPopup:Destroy()
            end, {
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundColor = ColorScheme.Category,
                Transparency = 0.3
            })
            btn.Parent = scroll
        end
        
        categoryPopup.Parent = popup
        scroll.Parent = categoryPopup
        
        -- Анимация появления
        categoryPopup.BackgroundTransparency = 1
        categoryPopupGlass.BackgroundTransparency = 1
        
        TweenService:Create(categoryPopup, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
        TweenService:Create(categoryPopupGlass, TweenInfo.new(0.2), {BackgroundTransparency = 0.9}):Play()
    end)
end

-- Функция создания попапа добавления новой точки
local function ShowAddLocationPopup()
    local popup = Instance.new("Frame")
    popup.Name = "AddLocationPopup"
    popup.Size = UDim2.new(0.8, 0, 0.4, 0)
    popup.Position = UDim2.new(0.1, 0, 0.3, 0)
    popup.BackgroundColor3 = ColorScheme.Background
    popup.BackgroundTransparency = 0.1
    popup.ZIndex = 100
    
    local popupCorner = Instance.new("UICorner")
    popupCorner.CornerRadius = UDim.new(0.05, 0)
    popupCorner.Parent = popup
    
    local popupShadow = DropShadow:Clone()
    popupShadow.Parent = popup
    
    local popupGlass = GlassEffect:Clone()
    popupGlass.Parent = popup
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.15, 0)
    title.Text = "Добавить новую точку"
    title.TextColor3 = ColorScheme.Accent
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    
    local nameInput = Instance.new("TextBox")
    nameInput.Size = UDim2.new(0.9, 0, 0.15, 0)
    nameInput.Position = UDim2.new(0.05, 0, 0.15, 0)
    nameInput.PlaceholderText = "Название точки"
    nameInput.BackgroundColor3 = ColorScheme.Primary
    nameInput.BackgroundTransparency = 0.3
    nameInput.TextColor3 = ColorScheme.Text
    nameInput.Font = Enum.Font.Gotham
    nameInput.ClearTextOnFocus = false
    
    local nameCorner = Instance.new("UICorner")
    nameCorner.CornerRadius = UDim.new(0.05, 0)
    nameCorner.Parent = nameInput
    
    local coordsInput = Instance.new("TextBox")
    coordsInput.Size = UDim2.new(0.9, 0, 0.15, 0)
    coordsInput.Position = UDim2.new(0.05, 0, 0.35, 0)
    coordsInput.PlaceholderText = "X, Y, Z (оставьте пустым для текущих)"
    coordsInput.BackgroundColor3 = ColorScheme.Primary
    coordsInput.BackgroundTransparency = 0.3
    coordsInput.TextColor3 = ColorScheme.Text
    coordsInput.Font = Enum.Font.Gotham
    coordsInput.ClearTextOnFocus = false
    nameCorner:Clone().Parent = coordsInput
    
    -- Выбор категории
    local categoryDropdown = Instance.new("TextButton")
    categoryDropdown.Name = "CategoryDropdown"
    categoryDropdown.Size = UDim2.new(0.9, 0, 0.15, 0)
    categoryDropdown.Position = UDim2.new(0.05, 0, 0.55, 0)
    categoryDropdown.Text = MenuData.CurrentCategory
    categoryDropdown.TextColor3 = ColorScheme.Text
    categoryDropdown.Font = Enum.Font.Gotham
    categoryDropdown.BackgroundColor3 = ColorScheme.Primary
    categoryDropdown.BackgroundTransparency = 0.3
    nameCorner:Clone().Parent = categoryDropdown
    
    -- Кнопки действий
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(0.9, 0, 0.15, 0)
    buttonContainer.Position = UDim2.new(0.05, 0, 0.75, 0)
    buttonContainer.BackgroundTransparency = 1
    
    local addBtn = CreateButton("Добавить", function()
        local name = nameInput.Text
        local coordsText = coordsInput.Text
        local category = categoryDropdown.Text
        
        if name == "" then
            ShowPopup("Ошибка", "Введите название точки", "error")
            return
        end
        
        local position
        if coordsText == "" then
            -- Используем текущие координаты
            if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                position = localPlayer.Character.HumanoidRootPart.Position
            else
                ShowPopup("Ошибка", "Не удалось получить текущие координаты", "error")
                return
            end
        else
            -- Парсим введенные координаты
            local coords = {}
            for coord in string.gmatch(coordsText, "[^,]+") do
                table.insert(coords, tonumber(coord))
            end
            
            if #coords ~= 3 then
                ShowPopup("Ошибка", "Введите координаты в формате X,Y,Z", "error")
                return
            end
            
            position = Vector3.new(coords[1], coords[2], coords[3])
        end
        
        -- Проверяем, существует ли уже точка с таким именем
        if MenuData.SavedLocations[name] then
            ShowPopup("Ошибка", "Точка с таким именем уже существует", "error")
            return
        end
        
        -- Добавляем новую точку
        MenuData.SavedLocations[name] = {
            Name = name,
            Position = position,
            Category = category
        }
        
        -- Если категория новая, добавляем ее в список
        if not table.find(MenuData.Categories, category) then
            table.insert(MenuData.Categories, category)
        end
        
        UpdateLocationsList()
        ShowPopup("Успех", "Точка '"..name.."' добавлена", "success")
        popup:Destroy()
    end, {
        Size = UDim2.new(0.45, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0)
    })
    
    local cancelBtn = CreateButton("Отмена", function()
        popup:Destroy()
    end, {
        Size = UDim2.new(0.45, 0, 1, 0),
        Position = UDim2.new(0.55, 0, 0, 0),
        BackgroundColor = ColorScheme.DeleteButton
    })
    
    popup.Parent = TeleportMenu
    title.Parent = popup
    nameInput.Parent = popup
    coordsInput.Parent = popup
    categoryDropdown.Parent = popup
    buttonContainer.Parent = popup
    addBtn.Parent = buttonContainer
    cancelBtn.Parent = buttonContainer
    
    -- Анимация появления
    popup.BackgroundTransparency = 1
    popupGlass.BackgroundTransparency = 1
    title.TextTransparency = 1
    nameInput.BackgroundTransparency = 1
    nameInput.TextTransparency = 1
    coordsInput.BackgroundTransparency = 1
    coordsInput.TextTransparency = 1
    categoryDropdown.BackgroundTransparency = 1
    categoryDropdown.TextTransparency = 1
    addBtn.BackgroundTransparency = 1
    addBtn.TextTransparency = 1
    cancelBtn.BackgroundTransparency = 1
    cancelBtn.TextTransparency = 1
    
    TweenService:Create(popup, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(popupGlass, TweenInfo.new(0.3), {BackgroundTransparency = 0.9}):Play()
    TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(nameInput, TweenInfo.new(0.3), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
    TweenService:Create(coordsInput, TweenInfo.new(0.3), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
    TweenService:Create(categoryDropdown, TweenInfo.new(0.3), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
    TweenService:Create(addBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.2, TextTransparency = 0}):Play()
    TweenService:Create(cancelBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.2, TextTransparency = 0}):Play()
    
    -- Обработчик выбора категории
    categoryDropdown.MouseButton1Click:Connect(function()
        local categoryPopup = Instance.new("Frame")
        categoryPopup.Name = "CategoryPopup"
        categoryPopup.Size = UDim2.new(0.8, 0, 0.3, 0)
        categoryPopup.Position = UDim2.new(0.1, 0, 0.2, 0)
        categoryPopup.BackgroundColor3 = ColorScheme.Background
        categoryPopup.BackgroundTransparency = 0.1
        categoryPopup.ZIndex = 110
        
        local categoryPopupCorner = Instance.new("UICorner")
        categoryPopupCorner.CornerRadius = UDim.new(0.05, 0)
        categoryPopupCorner.Parent = categoryPopup
        
        local categoryPopupShadow = DropShadow:Clone()
        categoryPopupShadow.Parent = categoryPopup
        
        local categoryPopupGlass = GlassEffect:Clone()
        categoryPopupGlass.Parent = categoryPopup
        
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(0.9, 0, 0.9, 0)
        scroll.Position = UDim2.new(0.05, 0, 0.05, 0)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 5
        scroll.ScrollBarImageColor3 = ColorScheme.Accent
        scroll.CanvasSize = UDim2.new(0, 0, 0, #MenuData.Categories * 40)
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 5)
        layout.Parent = scroll
        
        -- Кнопка добавления новой категории
        local newCategoryBtn = CreateButton("+ Новая категория", function()
            local inputPopup = Instance.new("Frame")
            inputPopup.Name = "InputPopup"
            inputPopup.Size = UDim2.new(0.8, 0, 0.2, 0)
            inputPopup.Position = UDim2.new(0.1, 0, 0.4, 0)
            inputPopup.BackgroundColor3 = ColorScheme.Background
            inputPopup.BackgroundTransparency = 0.1
            inputPopup.ZIndex = 120
            
            local inputPopupCorner = Instance.new("UICorner")
            inputPopupCorner.CornerRadius = UDim.new(0.05, 0)
            inputPopupCorner.Parent = inputPopup
            
            local inputPopupShadow = DropShadow:Clone()
            inputPopupShadow.Parent = inputPopup
            
            local inputPopupGlass = GlassEffect:Clone()
            inputPopupGlass.Parent = inputPopup
            
            local input = Instance.new("TextBox")
            input.Size = UDim2.new(0.8, 0, 0.5, 0)
            input.Position = UDim2.new(0.1, 0, 0.1, 0)
            input.PlaceholderText = "Название категории"
            input.BackgroundColor3 = ColorScheme.Primary
            input.BackgroundTransparency = 0.3
            input.TextColor3 = ColorScheme.Text
            input.Font = Enum.Font.Gotham
            input.ClearTextOnFocus = false
            
            local inputCorner = Instance.new("UICorner")
            inputCorner.CornerRadius = UDim.new(0.05, 0)
            inputCorner.Parent = input
            
            local addBtn = CreateButton("Добавить", function()
                local newCategory = input.Text
                if newCategory == "" then
                    ShowPopup("Ошибка", "Введите название категории", "error")
                    return
                end
                
                if table.find(MenuData.Categories, newCategory) then
                    ShowPopup("Ошибка", "Категория уже существует", "error")
                    return
                end
                
                table.insert(MenuData.Categories, newCategory)
                categoryDropdown.Text = newCategory
                inputPopup:Destroy()
                categoryPopup:Destroy()
            end, {
                Size = UDim2.new(0.8, 0, 0.3, 0),
                Position = UDim2.new(0.1, 0, 0.7, 0)
            })
            
            inputPopup.Parent = categoryPopup
            input.Parent = inputPopup
            addBtn.Parent = inputPopup
            
            -- Анимация появления
            inputPopup.BackgroundTransparency = 1
            inputPopupGlass.BackgroundTransparency = 1
            input.BackgroundTransparency = 1
            input.TextTransparency = 1
            addBtn.BackgroundTransparency = 1
            addBtn.TextTransparency = 1
            
            TweenService:Create(inputPopup, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
            TweenService:Create(inputPopupGlass, TweenInfo.new(0.2), {BackgroundTransparency = 0.9}):Play()
            TweenService:Create(input, TweenInfo.new(0.2), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
            TweenService:Create(addBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2, TextTransparency = 0}):Play()
        end, {
            Size = UDim2.new(0.9, 0, 0, 35),
            BackgroundColor = ColorScheme.Accent,
            Transparency = 0.3
        })
        
        newCategoryBtn.Parent = scroll
        
        -- Существующие категории
        for _, category in ipairs(MenuData.Categories) do
            local btn = CreateButton(category, function()
                categoryDropdown.Text = category
                categoryPopup:Destroy()
            end, {
                Size = UDim2.new(0.9, 0, 0, 35),
                BackgroundColor = ColorScheme.Category,
                Transparency = 0.3
            })
            btn.Parent = scroll
        end
        
        categoryPopup.Parent = popup
        scroll.Parent = categoryPopup
        
        -- Анимация появления
        categoryPopup.BackgroundTransparency = 1
        categoryPopupGlass.BackgroundTransparency = 1
        
        TweenService:Create(categoryPopup, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
        TweenService:Create(categoryPopupGlass, TweenInfo.new(0.2), {BackgroundTransparency = 0.9}):Play()
    end)
end

-- Функция показа попапа телепортации к координатам
local function ShowCoordinatesPopup()
    local popup = Instance.new("Frame")
    popup.Name = "CoordinatesPopup"
    popup.Size = UDim2.new(0.8, 0, 0.3, 0)
    popup.Position = UDim2.new(0.1, 0, 0.35, 0)
    popup.BackgroundColor3 = ColorScheme.Background
    popup.BackgroundTransparency = 0.1
    popup.ZIndex = 100
    
    local popupCorner = Instance.new("UICorner")
    popupCorner.CornerRadius = UDim.new(0.05, 0)
    popupCorner.Parent = popup
    
    local popupShadow = DropShadow:Clone()
    popupShadow.Parent = popup
    
    local popupGlass = GlassEffect:Clone()
    popupGlass.Parent = popup
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.2, 0)
    title.Text = "Введите координаты"
    title.TextColor3 = ColorScheme.Accent
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    
    local xInput = Instance.new("TextBox")
    xInput.Size = UDim2.new(0.25, 0, 0.15, 0)
    xInput.Position = UDim2.new(0.1, 0, 0.25, 0)
    xInput.PlaceholderText = "X"
    xInput.BackgroundColor3 = ColorScheme.Primary
    xInput.BackgroundTransparency = 0.3
    xInput.TextColor3 = ColorScheme.Text
    xInput.Font = Enum.Font.Gotham
    xInput.ClearTextOnFocus = false
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0.05, 0)
    inputCorner.Parent = xInput
    
    local yInput = xInput:Clone()
    yInput.Position = UDim2.new(0.4, 0, 0.25, 0)
    yInput.PlaceholderText = "Y"
    yInput.Parent = popup
    
    local zInput = xInput:Clone()
    zInput.Position = UDim2.new(0.7, 0, 0.25, 0)
    zInput.PlaceholderText = "Z"
    zInput.Parent = popup
    
    -- Кнопка текущих координат
    local currentBtn = CreateButton("Текущие", function()
        if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local pos = localPlayer.Character.HumanoidRootPart.Position
            xInput.Text = string.format("%.1f", pos.X)
            yInput.Text = string.format("%.1f", pos.Y)
            zInput.Text = string.format("%.1f", pos.Z)
        else
            ShowPopup("Ошибка", "Не удалось получить координаты", "error")
        end
    end, {
        Size = UDim2.new(0.4, 0, 0.15, 0),
        Position = UDim2.new(0.1, 0, 0.45, 0),
        BackgroundColor = ColorScheme.Secondary
    })
    
    -- Кнопка телепортации
    local teleportBtn = CreateButton("Телепорт", function()
        local x = tonumber(xInput.Text)
        local y = tonumber(yInput.Text)
        local z = tonumber(zInput.Text)
        
        if x and y and z then
            if TeleportTo(Vector3.new(x, y, z)) then
                ShowPopup("Успех", string.format("Телепорт к %.1f, %.1f, %.1f", x, y, z), "success")
                popup:Destroy()
            else
                ShowPopup("Ошибка", "Не удалось телепортироваться", "error")
            end
        else
            ShowPopup("Ошибка", "Некорректные координаты", "error")
        end
    end, {
        Size = UDim2.new(0.4, 0, 0.15, 0),
        Position = UDim2.new(0.5, 0, 0.45, 0)
    })
    
    -- Кнопка сохранения
    local saveBtn = CreateButton("Сохранить точку", function()
        local x = tonumber(xInput.Text)
        local y = tonumber(yInput.Text)
        local z = tonumber(zInput.Text)
        
        if x and y and z then
            popup:Destroy()
            ShowAddLocationPopup()
            task.wait(0.3)
            -- Устанавливаем координаты в попапе добавления
            local addPopup = TeleportMenu:FindFirstChild("AddLocationPopup")
            if addPopup then
                local coordsInput = addPopup:FindFirstChild("CoordsInput")
                if coordsInput then
                    coordsInput.Text = string.format("%.1f, %.1f, %.1f", x, y, z)
                end
            end
        else
            ShowPopup("Ошибка", "Некорректные координаты", "error")
        end
    end, {
        Size = UDim2.new(0.8, 0, 0.15, 0),
        Position = UDim2.new(0.1, 0, 0.65, 0),
        BackgroundColor = ColorScheme.SavedLocation
    })
    
    popup.Parent = TeleportMenu
    title.Parent = popup
    xInput.Parent = popup
    currentBtn.Parent = popup
    teleportBtn.Parent = popup
    saveBtn.Parent = popup
    
    -- Анимация появления
    popup.BackgroundTransparency = 1
    popupGlass.BackgroundTransparency = 1
    title.TextTransparency = 1
    xInput.BackgroundTransparency = 1
    xInput.TextTransparency = 1
    yInput.BackgroundTransparency = 1
    yInput.TextTransparency = 1
    zInput.BackgroundTransparency = 1
    zInput.TextTransparency = 1
    currentBtn.BackgroundTransparency = 1
    currentBtn.TextTransparency = 1
    teleportBtn.BackgroundTransparency = 1
    teleportBtn.TextTransparency = 1
    saveBtn.BackgroundTransparency = 1
    saveBtn.TextTransparency = 1
    
    TweenService:Create(popup, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(popupGlass, TweenInfo.new(0.3), {BackgroundTransparency = 0.9}):Play()
    TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(xInput, TweenInfo.new(0.3), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
    TweenService:Create(yInput, TweenInfo.new(0.3), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
    TweenService:Create(zInput, TweenInfo.new(0.3), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
    TweenService:Create(currentBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.2, TextTransparency = 0}):Play()
    TweenService:Create(teleportBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.2, TextTransparency = 0}):Play()
    TweenService:Create(saveBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.2, TextTransparency = 0}):Play()
end

-- Функция показа попапа телепортации к игроку
local function ShowPlayerTeleportPopup()
    local popup = Instance.new("Frame")
    popup.Name = "PlayerTeleportPopup"
    popup.Size = UDim2.new(0.8, 0, 0.6, 0)
    popup.Position = UDim2.new(0.1, 0, 0.2, 0)
    popup.BackgroundColor3 = ColorScheme.Background
    popup.BackgroundTransparency = 0.1
    popup.ZIndex = 100
    
    local popupCorner = Instance.new("UICorner")
    popupCorner.CornerRadius = UDim.new(0.05, 0)
    popupCorner.Parent = popup
    
    local popupShadow = DropShadow:Clone()
    popupShadow.Parent = popup
    
    local popupGlass = GlassEffect:Clone()
    popupGlass.Parent = popup
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.1, 0)
    title.Text = "Выберите игрока"
    title.TextColor3 = ColorScheme.Accent
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(0.9, 0, 0.8, 0)
    scroll.Position = UDim2.new(0.05, 0, 0.1, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 5
    scroll.ScrollBarImageColor3 = ColorScheme.Accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scroll
    
    popup.Parent = TeleportMenu
    title.Parent = popup
    scroll.Parent = popup
    
    -- Добавляем игроков
    local players = Players:GetPlayers()
    for _, player in ipairs(players) do
        if player ~= localPlayer then
            local btn = CreateButton(player.Name, function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    if TeleportTo(player.Character.HumanoidRootPart.Position) then
                        ShowPopup("Успех", "Телепорт к "..player.Name, "success")
                        popup:Destroy()
                    else
                        ShowPopup("Ошибка", "Не удалось телепортироваться", "error")
                    end
                else
                    ShowPopup("Ошибка", "Игрок не найден", "error")
                end
            end, {
                Size = UDim2.new(0.9, 0, 0, 50),
                Icon = Icons.Player
            })
            btn.Parent = scroll
        end
    end
    
    -- Обновляем размер прокрутки
    scroll.CanvasSize = UDim2.new(0, 0, 0, #players * 55)
    
    -- Анимация появления
    popup.BackgroundTransparency = 1
    popupGlass.BackgroundTransparency = 1
    title.TextTransparency = 1
    
    TweenService:Create(popup, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(popupGlass, TweenInfo.new(0.3), {BackgroundTransparency = 0.9}):Play()
    TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
end

-- Функция показа попапа слежения за игроком
local function ShowFollowPlayerPopup()
    local popup = Instance.new("Frame")
    popup.Name = "FollowPlayerPopup"
    popup.Size = UDim2.new(0.8, 0, 0.6, 0)
    popup.Position = UDim2.new(0.1, 0, 0.2, 0)
    popup.BackgroundColor3 = ColorScheme.Background
    popup.BackgroundTransparency = 0.1
    popup.ZIndex = 100
    
    local popupCorner = Instance.new("UICorner")
    popupCorner.CornerRadius = UDim.new(0.05, 0)
    popupCorner.Parent = popup
    
    local popupShadow = DropShadow:Clone()
    popupShadow.Parent = popup
    
    local popupGlass = GlassEffect:Clone()
    popupGlass.Parent = popup
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.1, 0)
    title.Text = MenuData.TrackingPlayer and "Остановить слежение?" or "Слежение за игроком"
    title.TextColor3 = MenuData.TrackingPlayer and ColorScheme.Error or ColorScheme.Accent
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(0.9, 0, MenuData.TrackingPlayer and 0.5 or 0.8, 0)
    scroll.Position = UDim2.new(0.05, 0, 0.1, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 5
    scroll.ScrollBarImageColor3 = ColorScheme.Accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scroll
    
    popup.Parent = TeleportMenu
    title.Parent = popup
    scroll.Parent = popup
    
    if MenuData.TrackingPlayer then
        -- Кнопка остановки слежения
        local stopBtn = CreateButton("Остановить слежение", function()
            if MenuData.TrackingConnection then
                MenuData.TrackingConnection:Disconnect()
                MenuData.TrackingConnection = nil
            end
            MenuData.TrackingPlayer = nil
            ShowPopup("Инфо", "Слежение остановлено", "info")
            popup:Destroy()
        end, {
            Size = UDim2.new(0.9, 0, 0, 50),
            Position = UDim2.new(0.05, 0, 0.65, 0),
            BackgroundColor = ColorScheme.Error,
            Icon = Icons.Delete
        })
        stopBtn.Parent = popup
    else
        -- Добавляем игроков для слежения
        local players = Players:GetPlayers()
        for _, player in ipairs(players) do
            if player ~= localPlayer then
                local btn = CreateButton(player.Name, function()
                    MenuData.TrackingPlayer = player
                    popup:Destroy()
                    
                    if MenuData.TrackingConnection then
                        MenuData.TrackingConnection:Disconnect()
                    end
                    
                    MenuData.TrackingConnection = RunService.Heartbeat:Connect(function()
                        if MenuData.TrackingPlayer and MenuData.TrackingPlayer.Character and MenuData.TrackingPlayer.Character:FindFirstChild("HumanoidRootPart") and
                           localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            localPlayer.Character.HumanoidRootPart.CFrame = MenuData.TrackingPlayer.Character.HumanoidRootPart.CFrame * 
                                CFrame.new(0, SETTINGS.FollowHeight, -SETTINGS.FollowDistance)
                        end
                    end)
                    
                    ShowPopup("Инфо", "Слежение за "..player.Name, "info")
                end, {
                    Size = UDim2.new(0.9, 0, 0, 50),
                    Icon = Icons.Follow
                })
                btn.Parent = scroll
            end
        end
        
        -- Обновляем размер прокрутки
        scroll.CanvasSize = UDim2.new(0, 0, 0, #players * 55)
    end
    
    -- Анимация появления
    popup.BackgroundTransparency = 1
    popupGlass.BackgroundTransparency = 1
    title.TextTransparency = 1
    
    TweenService:Create(popup, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(popupGlass, TweenInfo.new(0.3), {BackgroundTransparency = 0.9}):Play()
    TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
end

-- Функция показа попапа настроек
local function ShowSettingsPopup()
    local popup = Instance.new("Frame")
    popup.Name = "SettingsPopup"
    popup.Size = UDim2.new(0.8, 0, 0.5, 0)
    popup.Position = UDim2.new(0.1, 0, 0.25, 0)
    popup.BackgroundColor3 = ColorScheme.Background
    popup.BackgroundTransparency = 0.1
    popup.ZIndex = 100
    
    local popupCorner = Instance.new("UICorner")
    popupCorner.CornerRadius = UDim.new(0.05, 0)
    popupCorner.Parent = popup
    
    local popupShadow = DropShadow:Clone()
    popupShadow.Parent = popup
    
    local popupGlass = GlassEffect:Clone()
    popupGlass.Parent = popup
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.1, 0)
    title.Text = "Настройки"
    title.TextColor3 = ColorScheme.Accent
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(0.9, 0, 0.8, 0)
    scroll.Position = UDim2.new(0.05, 0, 0.1, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 5
    scroll.ScrollBarImageColor3 = ColorScheme.Accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = scroll
    
    popup.Parent = TeleportMenu
    title.Parent = popup
    scroll.Parent = popup
    
    -- Настройка расстояния слежения
    local followDistanceLabel = Instance.new("TextLabel")
    followDistanceLabel.Size = UDim2.new(0.9, 0, 0, 30)
    followDistanceLabel.Text = "Дистанция слежения: "..SETTINGS.FollowDistance
    followDistanceLabel.TextColor3 = ColorScheme.Text
    followDistanceLabel.Font = Enum.Font.Gotham
    followDistanceLabel.TextXAlignment = Enum.TextXAlignment.Left
    followDistanceLabel.BackgroundTransparency = 1
    
    local followDistanceSlider = Instance.new("TextButton")
    followDistanceSlider.Size = UDim2.new(0.9, 0, 0, 20)
    followDistanceSlider.Text = ""
    followDistanceSlider.BackgroundColor3 = ColorScheme.Primary
    followDistanceSlider.BackgroundTransparency = 0.3
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0.5, 0)
    sliderCorner.Parent = followDistanceSlider
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((SETTINGS.FollowDistance - 1) / 9, 0, 1, 0)
    sliderFill.BackgroundColor3 = ColorScheme.Accent
    sliderFill.BorderSizePixel = 0
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0.5, 0)
    fillCorner.Parent = sliderFill
    
    sliderFill.Parent = followDistanceSlider
    
    -- Обработчик слайдера
    local sliding = false
    followDistanceSlider.MouseButton1Down:Connect(function()
        sliding = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
    
    followDistanceSlider.MouseMoved:Connect(function()
        if sliding then
            local x = math.clamp(UserInputService:GetMouseLocation().X - followDistanceSlider.AbsolutePosition.X, 0, followDistanceSlider.AbsoluteSize.X)
            local ratio = x / followDistanceSlider.AbsoluteSize.X
            SETTINGS.FollowDistance = math.floor(1 + ratio * 9) -- От 1 до 10
            sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
            followDistanceLabel.Text = "Дистанция слежения: "..SETTINGS.FollowDistance
        end
    end)
    
    -- Настройка высоты слежения
    local followHeightLabel = Instance.new("TextLabel")
    followHeightLabel.Size = UDim2.new(0.9, 0, 0, 30)
    followHeightLabel.Text = "Высота слежения: "..SETTINGS.FollowHeight
    followHeightLabel.TextColor3 = ColorScheme.Text
    followHeightLabel.Font = Enum.Font.Gotham
    followHeightLabel.TextXAlignment = Enum.TextXAlignment.Left
    followHeightLabel.BackgroundTransparency = 1
    
    local followHeightSlider = Instance.new("TextButton")
    followHeightSlider.Size = UDim2.new(0.9, 0, 0, 20)
    followHeightSlider.Text = ""
    followHeightSlider.BackgroundColor3 = ColorScheme.Primary
    followHeightSlider.BackgroundTransparency = 0.3
    sliderCorner:Clone().Parent = followHeightSlider
    
    local heightFill = Instance.new("Frame")
    heightFill.Size = UDim2.new((SETTINGS.FollowHeight + 5) / 10, 0, 1, 0)
    heightFill.BackgroundColor3 = ColorScheme.Accent
    heightFill.BorderSizePixel = 0
    fillCorner:Clone().Parent = heightFill
    heightFill.Parent = followHeightSlider
    
    -- Обработчик слайдера высоты
    local heightSliding = false
    followHeightSlider.MouseButton1Down:Connect(function()
        heightSliding = true
    end)
    
    followHeightSlider.MouseMoved:Connect(function()
        if heightSliding then
            local x = math.clamp(UserInputService:GetMouseLocation().X - followHeightSlider.AbsolutePosition.X, 0, followHeightSlider.AbsoluteSize.X)
            local ratio = x / followHeightSlider.AbsoluteSize.X
            SETTINGS.FollowHeight = math.floor(-5 + ratio * 10) -- От -5 до 5
            heightFill.Size = UDim2.new(ratio, 0, 1, 0)
            followHeightLabel.Text = "Высота слежения: "..SETTINGS.FollowHeight
        end
    end)
    
    -- Кнопка экспорта данных
    local exportBtn = CreateButton("Экспорт точек", function()
        local data = {
            SavedLocations = MenuData.SavedLocations,
            Categories = MenuData.Categories
        }
        
        local json = HttpService:JSONEncode(data)
        setclipboard(json)
        ShowPopup("Экспорт", "Данные скопированы в буфер", "success")
    end, {
        Size = UDim2.new(0.9, 0, 0, 40),
        Icon = Icons.Save
    })
    
    -- Кнопка импорта данных
    local importBtn = CreateButton("Импорт точек", function()
        local inputPopup = Instance.new("Frame")
        inputPopup.Name = "ImportPopup"
        inputPopup.Size = UDim2.new(0.8, 0, 0.3, 0)
        inputPopup.Position = UDim2.new(0.1, 0, 0.35, 0)
        inputPopup.BackgroundColor3 = ColorScheme.Background
        inputPopup.BackgroundTransparency = 0.1
        inputPopup.ZIndex = 110
        
        local inputPopupCorner = Instance.new("UICorner")
        inputPopupCorner.CornerRadius = UDim.new(0.05, 0)
        inputPopupCorner.Parent = inputPopup
        
        local inputPopupShadow = DropShadow:Clone()
        inputPopupShadow.Parent = inputPopup
        
        local inputPopupGlass = GlassEffect:Clone()
        inputPopupGlass.Parent = inputPopup
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0.2, 0)
        title.Text = "Вставьте JSON данные"
        title.TextColor3 = ColorScheme.Accent
        title.TextScaled = true
        title.Font = Enum.Font.GothamBold
        title.BackgroundTransparency = 1
        
        local input = Instance.new("TextBox")
        input.Size = UDim2.new(0.9, 0, 0.4, 0)
        input.Position = UDim2.new(0.05, 0, 0.2, 0)
        input.PlaceholderText = "Вставьте сюда JSON данные..."
        input.Text = ""
        input.BackgroundColor3 = ColorScheme.Primary
        input.BackgroundTransparency = 0.3
        input.TextColor3 = ColorScheme.Text
        input.Font = Enum.Font.Gotham
        input.ClearTextOnFocus = false
        input.MultiLine = true
        
        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0.05, 0)
        inputCorner.Parent = input
        
        local importBtn = CreateButton("Импорт", function()
            local success, data = pcall(function()
                return HttpService:JSONDecode(input.Text)
            end)
            
            if success and data then
                MenuData.SavedLocations = data.SavedLocations or {}
                MenuData.Categories = data.Categories or {SETTINGS.DefaultCategory}
                UpdateLocationsList()
                ShowPopup("Успех", "Данные успешно импортированы", "success")
                inputPopup:Destroy()
                popup:Destroy()
            else
                ShowPopup("Ошибка", "Неверный формат данных", "error")
            end
        end, {
            Size = UDim2.new(0.4, 0, 0.2, 0),
            Position = UDim2.new(0.3, 0, 0.7, 0)
        })
        
        inputPopup.Parent = popup
        title.Parent = inputPopup
        input.Parent = inputPopup
        importBtn.Parent = inputPopup
        
        -- Анимация появления
        inputPopup.BackgroundTransparency = 1
        inputPopupGlass.BackgroundTransparency = 1
        title.TextTransparency = 1
        input.BackgroundTransparency = 1
        input.TextTransparency = 1
        importBtn.BackgroundTransparency = 1
        importBtn.TextTransparency = 1
        
        TweenService:Create(inputPopup, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
        TweenService:Create(inputPopupGlass, TweenInfo.new(0.2), {BackgroundTransparency = 0.9}):Play()
        TweenService:Create(title, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
        TweenService:Create(input, TweenInfo.new(0.2), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
        TweenService:Create(importBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2, TextTransparency = 0}):Play()
    end, {
        Size = UDim2.new(0.9, 0, 0, 40),
        Icon = Icons.Load
    })
    
    -- Кнопка сброса данных
    local resetBtn = CreateButton("Сбросить все точки", function()
        MenuData.SavedLocations = {}
        MenuData.Categories = {SETTINGS.DefaultCategory}
        MenuData.CurrentCategory = SETTINGS.DefaultCategory
        UpdateLocationsList()
        ShowPopup("Сброс", "Все точки удалены", "warning")
    end, {
        Size = UDim2.new(0.9, 0, 0, 40),
        BackgroundColor = ColorScheme.Error,
        Icon = Icons.Delete
    })
    
    -- Добавляем элементы в скролл
    followDistanceLabel.Parent = scroll
    followDistanceSlider.Parent = scroll
    followHeightLabel.Parent = scroll
    followHeightSlider.Parent = scroll
    exportBtn.Parent = scroll
    importBtn.Parent = scroll
    resetBtn.Parent = scroll
    
    -- Обновляем размер скролла
    scroll.CanvasSize = UDim2.new(0, 0, 0, 300)
    
    -- Кнопка закрытия
    local closeBtn = CreateButton("Закрыть", function()
        popup:Destroy()
    end, {
        Size = UDim2.new(0.9, 0, 0, 40),
        Position = UDim2.new(0.05, 0, 0.9, 0),
        BackgroundColor = ColorScheme.Secondary
    })
    closeBtn.Parent = popup
    
    -- Анимация появления
    popup.BackgroundTransparency = 1
    popupGlass.BackgroundTransparency = 1
    title.TextTransparency = 1
    
    TweenService:Create(popup, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(popupGlass, TweenInfo.new(0.3), {BackgroundTransparency = 0.9}):Play()
    TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
end

-- Функция переключения меню
local function ToggleMenu()
    MenuData.MenuVisible = not MenuData.MenuVisible
    if MenuData.MenuVisible then
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.02, 0, 0.2, 0),
            BackgroundTransparency = 0.1
        }):Play()
        ToggleButton.ImageRectOffset = Vector2.new(124, 204)
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(-0.5, 0, 0.2, 0),
            BackgroundTransparency = 0.5
        }):Play()
        ToggleButton.ImageRectOffset = Vector2.new(964, 324)
    end
end

-- Функция переключения категорий
local function ShowCategorySelection()
    local popup = Instance.new("Frame")
    popup.Name = "CategorySelectionPopup"
    popup.Size = UDim2.new(0.8, 0, 0.5, 0)
    popup.Position = UDim2.new(0.1, 0, 0.25, 0)
    popup.BackgroundColor3 = ColorScheme.Background
    popup.BackgroundTransparency = 0.1
    popup.ZIndex = 100
    
    local popupCorner = Instance.new("UICorner")
    popupCorner.CornerRadius = UDim.new(0.05, 0)
    popupCorner.Parent = popup
    
    local popupShadow = DropShadow:Clone()
    popupShadow.Parent = popup
    
    local popupGlass = GlassEffect:Clone()
    popupGlass.Parent = popup
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.1, 0)
    title.Text = "Выберите категорию"
    title.TextColor3 = ColorScheme.Accent
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(0.9, 0, 0.8, 0)
    scroll.Position = UDim2.new(0.05, 0, 0.1, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 5
    scroll.ScrollBarImageColor3 = ColorScheme.Accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = scroll
    
    popup.Parent = TeleportMenu
    title.Parent = popup
    scroll.Parent = popup
    
    -- Кнопка "Все"
    local allBtn = CreateButton("Все", function()
        MenuData.CurrentCategory = "Все"
        CategoryButton.Text = "Все"
        UpdateLocationsList()
        popup:Destroy()
    end, {
        Size = UDim2.new(0.9, 0, 0, 50),
        BackgroundColor = ColorScheme.Primary,
        Icon = Icons.Category
    })
    allBtn.Parent = scroll
    
    -- Добавляем категории
    for _, category in ipairs(MenuData.Categories) do
        local btn = CreateButton(category, function()
            MenuData.CurrentCategory = category
            CategoryButton.Text = category
            UpdateLocationsList()
            popup:Destroy()
        end, {
            Size = UDim2.new(0.9, 0, 0, 50),
            BackgroundColor = ColorScheme.Category,
            Icon = Icons.Category
        })
        btn.Parent = scroll
    end
    
    -- Кнопка добавления новой категории
    local newCategoryBtn = CreateButton("+ Новая категория", function()
        local inputPopup = Instance.new("Frame")
        inputPopup.Name = "NewCategoryPopup"
        inputPopup.Size = UDim2.new(0.8, 0, 0.2, 0)
        inputPopup.Position = UDim2.new(0.1, 0, 0.4, 0)
        inputPopup.BackgroundColor3 = ColorScheme.Background
        inputPopup.BackgroundTransparency = 0.1
        inputPopup.ZIndex = 110
        
        local inputPopupCorner = Instance.new("UICorner")
        inputPopupCorner.CornerRadius = UDim.new(0.05, 0)
        inputPopupCorner.Parent = inputPopup
        
        local inputPopupShadow = DropShadow:Clone()
        inputPopupShadow.Parent = inputPopup
        
        local inputPopupGlass = GlassEffect:Clone()
        inputPopupGlass.Parent = inputPopup
        
        local input = Instance.new("TextBox")
        input.Size = UDim2.new(0.8, 0, 0.5, 0)
        input.Position = UDim2.new(0.1, 0, 0.1, 0)
        input.PlaceholderText = "Название категории"
        input.BackgroundColor3 = ColorScheme.Primary
        input.BackgroundTransparency = 0.3
        input.TextColor3 = ColorScheme.Text
        input.Font = Enum.Font.Gotham
        input.ClearTextOnFocus = false
        
        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0.05, 0)
        inputCorner.Parent = input
        
        local addBtn = CreateButton("Добавить", function()
            local newCategory = input.Text
            if newCategory == "" then
                ShowPopup("Ошибка", "Введите название категории", "error")
                return
            end
            
            if table.find(MenuData.Categories, newCategory) then
                ShowPopup("Ошибка", "Категория уже существует", "error")
                return
            end
            
            table.insert(MenuData.Categories, newCategory)
            MenuData.CurrentCategory = newCategory
            CategoryButton.Text = newCategory
            UpdateLocationsList()
            inputPopup:Destroy()
            popup:Destroy()
        end, {
            Size = UDim2.new(0.8, 0, 0.3, 0),
            Position = UDim2.new(0.1, 0, 0.7, 0)
        })
        
        inputPopup.Parent = popup
        input.Parent = inputPopup
        addBtn.Parent = inputPopup
        
        -- Анимация появления
        inputPopup.BackgroundTransparency = 1
        inputPopupGlass.BackgroundTransparency = 1
        input.BackgroundTransparency = 1
        input.TextTransparency = 1
        addBtn.BackgroundTransparency = 1
        addBtn.TextTransparency = 1
        
        TweenService:Create(inputPopup, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
        TweenService:Create(inputPopupGlass, TweenInfo.new(0.2), {BackgroundTransparency = 0.9}):Play()
        TweenService:Create(input, TweenInfo.new(0.2), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
        TweenService:Create(addBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2, TextTransparency = 0}):Play()
    end, {
        Size = UDim2.new(0.9, 0, 0, 50),
        BackgroundColor = ColorScheme.Accent
    })
    newCategoryBtn.Parent = scroll
    
    -- Обновляем размер скролла
    scroll.CanvasSize = UDim2.new(0, 0, 0, (#MenuData.Categories + 2) * 60)
    
    -- Анимация появления
    popup.BackgroundTransparency = 1
    popupGlass.BackgroundTransparency = 1
    title.TextTransparency = 1
    
    TweenService:Create(popup, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(popupGlass, TweenInfo.new(0.3), {BackgroundTransparency = 0.9}):Play()
    TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
end

-- Создаем кнопки действий
local addLocationBtn = CreateButton("Добавить точку", ShowAddLocationPopup, {
    Size = UDim2.new(0.3, 0, 0.8, 0),
    Icon = Icons.Add
})

local teleportToCoordsBtn = CreateButton("К координатам", ShowCoordinatesPopup, {
    Size = UDim2.new(0.3, 0, 0.8, 0),
    Icon = Icons.Coordinates
})

local teleportToPlayerBtn = CreateButton("К игроку", ShowPlayerTeleportPopup, {
    Size = UDim2.new(0.3, 0, 0.8, 0),
    Icon = Icons.Player
})

local followPlayerBtn = CreateButton("Слежение", ShowFollowPlayerPopup, {
    Size = UDim2.new(0.3, 0, 0.8, 0),
    Icon = Icons.Follow
})

local toggleCoordsBtn = CreateButton("Координаты", function()
    MenuData.CoordsEnabled = not MenuData.CoordsEnabled
    CoordsDisplay.Visible = MenuData.CoordsEnabled
    
    if MenuData.CoordsEnabled then
        RunService.Heartbeat:Connect(function()
            if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local pos = localPlayer.Character.HumanoidRootPart.Position
                CoordsDisplay.Text = string.format("X: %d, Y: %d, Z: %d", math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z))
            end
        end)
    end
end, {
    Size = UDim2.new(0.3, 0, 0.8, 0),
    Icon = Icons.Coordinates
})

-- Добавляем кнопки на панель действий
addLocationBtn.Parent = ActionsPanel
teleportToCoordsBtn.Parent = ActionsPanel
teleportToPlayerBtn.Parent = ActionsPanel
followPlayerBtn.Parent = ActionsPanel
toggleCoordsBtn.Parent = ActionsPanel

-- Обработчики событий
ToggleButton.MouseButton1Click:Connect(ToggleMenu)
CategoryButton.MouseButton1Click:Connect(ShowCategorySelection)
SettingsButton.MouseButton1Click:Connect(ShowSettingsPopup)

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    MenuData.SearchQuery = SearchBox.Text
    UpdateLocationsList()
end)

-- Загружаем данные и обновляем интерфейс
LoadData()
UpdateLocationsList()

-- Анимация появления меню
MainFrame.Position = UDim2.new(-0.5, 0, 0.2, 0)
ToggleMenu()

-- Обработчик закрытия игры для сохранения данных
localPlayer.AncestryChanged:Connect(function()
    if not localPlayer.Parent then
        SaveData()
    end
end)

game:BindToClose(function()
    SaveData()
end)
