--[[
    УЛЬТРА МЕНЮ ТЕЛЕПОРТАЦИИ С БЕСКОНЕЧНЫМ СКРОЛЛОМ
    Функции:
    - Система сохранения точек телепорта
    - Удаление сохраненных точек
    - Телепорт к координатам
    - Телепорт к игроку
    - Постоянная телепортация за игроком
    - Показать координаты
    - Телепорт вверх/вниз
    - Сохранение позиции
    - Возврат к сохраненной позиции
    - Ноклип режим
    - Режим полета
    - Изменение скорости
    - Изменение силы прыжка
    - Копирование координат
    - Авто-сохранение точек
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

--🌈 Цветовая схема с градиентами
local ColorScheme = {
    Background = Color3.fromRGB(20, 25, 35),
    Primary = Color3.fromRGB(60, 120, 220),
    Secondary = Color3.fromRGB(40, 80, 160),
    Accent = Color3.fromRGB(80, 180, 255),
    Text = Color3.fromRGB(250, 250, 250),
    Error = Color3.fromRGB(230, 70, 70),
    Success = Color3.fromRGB(70, 230, 120),
    SavedLocation = Color3.fromRGB(80, 200, 100),
    DeleteButton = Color3.fromRGB(210, 65, 65),
    Special = Color3.fromRGB(160, 100, 255)
}

--✨ Создание интерфейса с неоновым эффектом
local TeleportMenu = Instance.new("ScreenGui")
TeleportMenu.Name = "UltraTeleportMenu"
TeleportMenu.ResetOnSpawn = false
TeleportMenu.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

--🎆 Основной фрейм с эффектом неона
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0.38, 0, 0.7, 0)
MainFrame.Position = UDim2.new(0.015, 0, 0.15, 0)
MainFrame.BackgroundColor3 = ColorScheme.Background
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0

--💎 Эффект стекла с бликами
local GlassEffect = Instance.new("Frame")
GlassEffect.Size = UDim2.new(1, 0, 1, 0)
GlassEffect.BackgroundTransparency = 0.95
GlassEffect.BackgroundColor3 = Color3.fromRGB(180, 220, 255)
GlassEffect.BorderSizePixel = 0
GlassEffect.ZIndex = -1

--🌌 Неоновое свечение
local NeonGlow = Instance.new("ImageLabel")
NeonGlow.Name = "NeonGlow"
NeonGlow.Image = "rbxassetid://5028857084"
NeonGlow.ImageColor3 = ColorScheme.Accent
NeonGlow.ImageTransparency = 0.9
NeonGlow.ScaleType = Enum.ScaleType.Slice
NeonGlow.SliceCenter = Rect.new(24, 24, 276, 276)
NeonGlow.Size = UDim2.new(1, 24, 1, 24)
NeonGlow.Position = UDim2.new(-0.1, 0, -0.1, 0)
NeonGlow.BackgroundTransparency = 1
NeonGlow.ZIndex = -2

--🌀 Скругление углов
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.045, 0)
UICorner.Parent = MainFrame
UICorner.Parent = GlassEffect

--🌑 Тень с градиентом
local DropShadow = Instance.new("ImageLabel")
DropShadow.Name = "DropShadow"
DropShadow.Image = "rbxassetid://1316045217"
DropShadow.ImageColor3 = Color3.new(0, 0, 0)
DropShadow.ImageTransparency = 0.85
DropShadow.ScaleType = Enum.ScaleType.Slice
DropShadow.SliceCenter = Rect.new(10, 10, 118, 118)
DropShadow.Size = UDim2.new(1, 14, 1, 14)
DropShadow.Position = UDim2.new(0, -7, 0, -7)
DropShadow.BackgroundTransparency = 1

--🚀 Заголовок с анимированным градиентом
local Title = Instance.new("Frame")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0.075, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, ColorScheme.Primary),
    ColorSequenceKeypoint.new(0.5, ColorScheme.Accent),
    ColorSequenceKeypoint.new(1, ColorScheme.Special)
})
TitleGradient.Rotation = 90
TitleGradient.Parent = Title

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.Text = "🚀 ULTRA TELEPORT MENU 🚀"
TitleText.TextColor3 = ColorScheme.Text
TitleText.TextScaled = true
TitleText.Font = Enum.Font.GothamBlack
TitleText.BackgroundTransparency = 1
TitleText.TextStrokeTransparency = 0.7
TitleText.TextStrokeColor3 = ColorScheme.Accent

--🌀 Область прокрутки с бесконечным скроллом
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Name = "ScrollingFrame"
ScrollingFrame.Size = UDim2.new(1, 0, 0.925, 0)
ScrollingFrame.Position = UDim2.new(0, 0, 0.075, 0)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.ScrollBarImageColor3 = ColorScheme.Accent
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 10, 0) -- Большая область для скролла
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y -- Автоматическое расширение

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 15)
UIPadding.PaddingBottom = UDim.new(0, 15)
UIPadding.PaddingLeft = UDim.new(0, 15)
UIPadding.PaddingRight = UDim.new(0, 15)
UIPadding.Parent = ScrollingFrame

--🔘 Кнопка переключения меню с анимацией
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0.09, 0, 0.09, 0)
ToggleButton.Position = UDim2.new(0.02, 0, 0.02, 0)
ToggleButton.BackgroundColor3 = ColorScheme.Primary
ToggleButton.BackgroundTransparency = 0.2
ToggleButton.Image = "rbxassetid://3926307971"
ToggleButton.ImageRectOffset = Vector2.new(884, 4)
ToggleButton.ImageRectSize = Vector2.new(36, 36)
ToggleButton.ImageColor3 = ColorScheme.Text
ToggleButton.Rotation = 180

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0.5, 0)
UICorner2.Parent = ToggleButton

--💫 Эффект свечения при наведении
local HoverEffect = Instance.new("Frame")
HoverEffect.Size = UDim2.new(1, 16, 1, 16)
HoverEffect.Position = UDim2.new(0, -8, 0, -8)
HoverEffect.BackgroundTransparency = 1
HoverEffect.ZIndex = -1

local HoverGlow = Instance.new("ImageLabel")
HoverGlow.Image = "rbxassetid://5028857084"
HoverGlow.ImageColor3 = ColorScheme.Accent
HoverGlow.ImageTransparency = 0.85
HoverGlow.ScaleType = Enum.ScaleType.Slice
HoverGlow.SliceCenter = Rect.new(24, 24, 276, 276)
HoverGlow.Size = UDim2.new(1, 0, 1, 0)
HoverGlow.BackgroundTransparency = 1
HoverGlow.Parent = HoverEffect

--🌈 Сборка интерфейса
MainFrame.Parent = TeleportMenu
GlassEffect.Parent = MainFrame
NeonGlow.Parent = MainFrame
DropShadow.Parent = MainFrame
Title.Parent = MainFrame
TitleText.Parent = Title
ScrollingFrame.Parent = MainFrame
UIListLayout.Parent = ScrollingFrame
ToggleButton.Parent = TeleportMenu
TeleportMenu.Parent = playerGui

--🔮 Переменные состояния
local menuVisible = true
local debounce = false
local trackingPlayer = nil
local trackingConnection = nil
local savedPosition = nil
local noclipEnabled = false
local flyEnabled = false
local infiniteJumpEnabled = false
local walkSpeed = 16
local jumpPower = 50

--🔄 Автоматическое обновление размера Canvas
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 50)
end)

--✨ Функция создания стилизованной кнопки
local function CreateButton(text, callback, buttonType)
    local button = Instance.new("TextButton")
    button.Name = text
    button.Size = UDim2.new(0.92, 0, 0, 55)
    
    -- Определение стиля кнопки
    if buttonType == "SAVED" then
        button.BackgroundColor3 = ColorScheme.SavedLocation
        button.Text = "📍 " .. text
    elseif buttonType == "DELETE" then
        button.BackgroundColor3 = ColorScheme.DeleteButton
        button.Text = "❌ " .. text
    elseif buttonType == "SPECIAL" then
        button.BackgroundColor3 = ColorScheme.Special
        button.Text = "✨ " .. text
    else
        button.BackgroundColor3 = ColorScheme.Primary
        button.Text = text
    end
    
    button.BackgroundTransparency = 0.2
    button.TextColor3 = ColorScheme.Text
    button.TextScaled = true
    button.Font = Enum.Font.GothamMedium
    button.AutoButtonColor = false
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.PaddingLeft = UDim.new(0, 15)
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0.08, 0)
    buttonCorner.Parent = button
    
    local textConstraint = Instance.new("UITextSizeConstraint")
    textConstraint.MaxTextSize = 18
    textConstraint.Parent = button
    
    -- Добавление иконки в зависимости от типа
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 25, 0, 25)
    icon.Position = UDim2.new(0.85, 0, 0.5, 0)
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.BackgroundTransparency = 1
    
    if buttonType == "SAVED" then
        icon.Image = "rbxassetid://3926305904"
        icon.ImageRectOffset = Vector2.new(324, 364)
    elseif buttonType == "DELETE" then
        icon.Image = "rbxassetid://3926305904"
        icon.ImageRectOffset = Vector2.new(924, 724)
    elseif buttonType == "SPECIAL" then
        icon.Image = "rbxassetid://3926307971"
        icon.ImageRectOffset = Vector2.new(884, 124)
    else
        icon.Image = "rbxassetid://3926305904"
        icon.ImageRectOffset = Vector2.new(124, 204)
    end
    
    icon.ImageColor3 = ColorScheme.Text
    icon.Parent = button
    
    -- Эффекты кнопки
    local effect = HoverEffect:Clone()
    effect.Parent = button
    effect.Visible = false
    
    button.MouseEnter:Connect(function()
        effect.Visible = true
        TweenService:Create(button, TweenInfo.new(0.15), {
            Size = UDim2.new(0.95, 0, 0, 60),
            BackgroundTransparency = 0.1
        }):Play()
        TweenService:Create(effect, TweenInfo.new(0.15), {
            Size = UDim2.new(1.1, 0, 1.1, 0)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        effect.Visible = false
        TweenService:Create(button, TweenInfo.new(0.15), {
            Size = UDim2.new(0.92, 0, 0, 55),
            BackgroundTransparency = 0.2
        }):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        if not debounce then
            debounce = true
            
            -- Анимация нажатия
            TweenService:Create(button, TweenInfo.new(0.1), {
                BackgroundTransparency = 0,
                Size = UDim2.new(0.9, 0, 0, 50)
            }):Play()
            task.wait(0.1)
            TweenService:Create(button, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.2,
                Size = UDim2.new(0.92, 0, 0, 55)
            }):Play()
            
            callback()
            task.wait(0.2)
            debounce = false
        end
    end)
    
    button.Parent = ScrollingFrame
    return button
end

--🌀 Функция показа/скрытия меню с анимацией
local function ToggleMenu()
    menuVisible = not menuVisible
    if menuVisible then
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.015, 0, 0.15, 0),
            BackgroundTransparency = 0.15
        }):Play()
        TweenService:Create(ToggleButton, TweenInfo.new(0.3), {
            Rotation = 180
        }):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(-0.5, 0, 0.15, 0),
            BackgroundTransparency = 0.5
        }):Play()
        TweenService:Create(ToggleButton, TweenInfo.new(0.3), {
            Rotation = 0
        }):Play()
    end
end

ToggleButton.MouseButton1Click:Connect(ToggleMenu)

--💬 Всплывающее окно с улучшенным дизайном
local function ShowPopup(title, message, popupType)
    local popup = Instance.new("Frame")
    popup.Size = UDim2.new(0.8, 0, 0.16, 0)
    popup.Position = UDim2.new(0.1, 0, 0.4, 0)
    popup.BackgroundColor3 = ColorScheme.Background
    popup.BackgroundTransparency = 0.1
    popup.ZIndex = 50
    
    local popupCorner = Instance.new("UICorner")
    popupCorner.CornerRadius = UDim.new(0.06, 0)
    popupCorner.Parent = popup
    
    local popupShadow = DropShadow:Clone()
    popupShadow.Parent = popup
    
    local popupGlass = GlassEffect:Clone()
    popupGlass.Parent = popup
    
    local popupGlow = NeonGlow:Clone()
    popupGlow.ImageColor3 = popupType == "ERROR" and ColorScheme.Error 
                          or popupType == "SUCCESS" and ColorScheme.Success
                          or ColorScheme.Accent
    popupGlow.ZIndex = -1
    popupGlow.Parent = popup
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.4, 0)
    titleLabel.Text = title
    titleLabel.TextColor3 = popupType == "ERROR" and ColorScheme.Error 
                          or popupType == "SUCCESS" and ColorScheme.Success
                          or ColorScheme.Accent
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
    popupGlow.ImageTransparency = 1
    titleLabel.TextTransparency = 1
    messageLabel.TextTransparency = 1
    
    TweenService:Create(popup, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(popupGlass, TweenInfo.new(0.3), {BackgroundTransparency = 0.95}):Play()
    TweenService:Create(popupGlow, TweenInfo.new(0.3), {ImageTransparency = 0.85}):Play()
    TweenService:Create(titleLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(messageLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    
    -- Автозакрытие с анимацией
    task.delay(3, function()
        TweenService:Create(popup, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(popupGlass, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(popupGlow, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
        TweenService:Create(titleLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(messageLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        task.wait(0.3)
        popup:Destroy()
    end)
end

--📍 Функция телепортации с эффектом
local function TeleportTo(position)
    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        -- Эффект перед телепортацией
        local root = localPlayer.Character.HumanoidRootPart
        local originalPos = root.Position
        
        -- Анимация "исчезновения"
        for i = 1, 0, -0.1 do
            root.CFrame = CFrame.new(originalPos) * CFrame.new(0, (1-i)*2, 0)
            task.wait(0.02)
        end
        
        -- Телепортация
        root.CFrame = CFrame.new(position)
        
        -- Анимация "появления"
        for i = 0, 1, 0.1 do
            root.CFrame = CFrame.new(position) * CFrame.new(0, (1-i)*2, 0)
            task.wait(0.02)
        end
    end
end

--📌 Система сохранения точек
local SavedLocations = {}
local MAX_SAVED_LOCATIONS = 20

local function SaveLocation(name, position)
    if not position and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        position = localPlayer.Character.HumanoidRootPart.Position
    end
    
    if #SavedLocations >= MAX_SAVED_LOCATIONS then
        table.remove(SavedLocations, 1)
    end
    
    local id = HttpService:GenerateGUID(false)
    SavedLocations[id] = {
        Name = name,
        Position = position,
        Time = os.time()
    }
    
    return id
end

local function UpdateSavedLocationsList()
    -- Удаляем старые кнопки
    for _, child in ipairs(ScrollingFrame:GetChildren()) do
        if child:GetAttribute("IsSavedLocation") then
            child:Destroy()
        end
    end
    
    -- Сортируем по времени (новые сверху)
    local sorted = {}
    for id, data in pairs(SavedLocations) do
        table.insert(sorted, {ID = id, Data = data})
    end
    
    table.sort(sorted, function(a, b) 
        return a.Data.Time > b.Data.Time 
    end)
    
    -- Создаем новые кнопки
    for _, item in ipairs(sorted) do
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0.92, 0, 0, 60)
        container.BackgroundTransparency = 1
        container.LayoutOrder = 1
        container:SetAttribute("IsSavedLocation", true)
        
        local button = CreateButton(item.Data.Name, function()
            TeleportTo(item.Data.Position)
            ShowPopup("Телепорт", "Перемещение к '"..item.Data.Name.."'", "SUCCESS")
        end, "SAVED")
        button.Size = UDim2.new(0.75, 0, 1, 0)
        button.Position = UDim2.new(0, 0, 0, 0)
        button.Parent = container
        
        local deleteBtn = CreateButton("Удалить", function()
            SavedLocations[item.ID] = nil
            UpdateSavedLocationsList()
            ShowPopup("Удалено", "Точка '"..item.Data.Name.."' удалена", "SUCCESS")
        end, "DELETE")
        deleteBtn.Size = UDim2.new(0.22, 0, 1, 0)
        deleteBtn.Position = UDim2.new(0.78, 0, 0, 0)
        deleteBtn.TextXAlignment = Enum.TextXAlignment.Center
        deleteBtn.Parent = container
        
        container.Parent = ScrollingFrame
    end
end

--🔧 Вспомогательные функции
local function GetPlayerPosition()
    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return localPlayer.Character.HumanoidRootPart.Position
    end
    return nil
end

local function CopyToClipboard(text)
    local clipBoard = setclipboard or toclipboard or function() end
    clipBoard(text)
    ShowPopup("Скопировано", "Текст скопирован в буфер", "SUCCESS")
end

--🚀 Основные функции меню

-- 1. Добавить точку телепорта
CreateButton("Добавить точку телепорта", function()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.8, 0, 0.35, 0)
    frame.Position = UDim2.new(0.1, 0, 0.325, 0)
    frame.BackgroundColor3 = ColorScheme.Background
    frame.BackgroundTransparency = 0.1
    frame.ZIndex = 20
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.06, 0)
    corner.Parent = frame
    
    local shadow = DropShadow:Clone()
    shadow.Parent = frame
    
    local glass = GlassEffect:Clone()
    glass.Parent = frame
    
    local glow = NeonGlow:Clone()
    glow.ZIndex = -1
    glow.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.2, 0)
    title.Text = "Добавить точку телепорта"
    title.TextColor3 = ColorScheme.Accent
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    
    local nameInput = Instance.new("TextBox")
    nameInput.Size = UDim2.new(0.9, 0, 0.18, 0)
    nameInput.Position = UDim2.new(0.05, 0, 0.2, 0)
    nameInput.PlaceholderText = "Название точки"
    nameInput.BackgroundColor3 = ColorScheme.Primary
    nameInput.BackgroundTransparency = 0.3
    nameInput.TextColor3 = ColorScheme.Text
    nameInput.Font = Enum.Font.Gotham
    nameInput.ClearTextOnFocus = false
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0.05, 0)
    inputCorner.Parent = nameInput
    
    local coordsInput = nameInput:Clone()
    coordsInput.Position = UDim2.new(0.05, 0, 0.4, 0)
    coordsInput.PlaceholderText = "X,Y,Z (оставьте пустым для текущих)"
    coordsInput.Parent = frame
    
    local currentPosBtn = CreateButton("Текущая позиция", function()
        local pos = GetPlayerPosition()
        if pos then
            coordsInput.Text = string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
            ShowPopup("Координаты", "Текущие координаты установлены", "SUCCESS")
        else
            ShowPopup("Ошибка", "Не удалось получить позицию", "ERROR")
        end
    end)
    currentPosBtn.Size = UDim2.new(0.9, 0, 0.15, 0)
    currentPosBtn.Position = UDim2.new(0.05, 0, 0.6, 0)
    currentPosBtn.Parent = frame
    
    local addBtn = CreateButton("Сохранить точку", function()
        local name = nameInput.Text:gsub("^%s*(.-)%s*$", "%1")
        if name == "" then
            ShowPopup("Ошибка", "Введите название точки", "ERROR")
            return
        end
        
        local position
        if coordsInput.Text == "" then
            position = GetPlayerPosition()
            if not position then
                ShowPopup("Ошибка", "Не удалось получить позицию", "ERROR")
                return
            end
        else
            local coords = {}
            for coord in string.gmatch(coordsInput.Text, "[^,]+") do
                table.insert(coords, tonumber(coord))
            end
            
            if #coords ~= 3 then
                ShowPopup("Ошибка", "Неверный формат координат", "ERROR")
                return
            end
            
            position = Vector3.new(coords[1], coords[2], coords[3])
        end
        
        SaveLocation(name, position)
        UpdateSavedLocationsList()
        
        ShowPopup("Сохранено", "Точка '"..name.."' добавлена", "SUCCESS")
        frame:Destroy()
    end)
    addBtn.Size = UDim2.new(0.6, 0, 0.15, 0)
    addBtn.Position = UDim2.new(0.2, 0, 0.8, 0)
    addBtn.Parent = frame
    
    frame.Parent = TeleportMenu
    title.Parent = frame
    nameInput.Parent = frame
    
    -- Анимация появления
    frame.BackgroundTransparency = 1
    glass.BackgroundTransparency = 1
    glow.ImageTransparency = 1
    title.TextTransparency = 1
    nameInput.BackgroundTransparency = 1
    nameInput.TextTransparency = 1
    coordsInput.BackgroundTransparency = 1
    coordsInput.TextTransparency = 1
    currentPosBtn.BackgroundTransparency = 1
    currentPosBtn.TextTransparency = 1
    addBtn.BackgroundTransparency = 1
    addBtn.TextTransparency = 1
    
    TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(glass, TweenInfo.new(0.3), {BackgroundTransparency = 0.95}):Play()
    TweenService:Create(glow, TweenInfo.new(0.3), {ImageTransparency = 0.85}):Play()
    TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(nameInput, TweenInfo.new(0.3), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
    TweenService:Create(coordsInput, TweenInfo.new(0.3), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
    TweenService:Create(currentPosBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.2, TextTransparency = 0}):Play()
    TweenService:Create(addBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.2, TextTransparency = 0}):Play()
end)

-- 2. Телепорт к координатам
CreateButton("Телепорт к координатам", function()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.8, 0, 0.35, 0)
    frame.Position = UDim2.new(0.1, 0, 0.325, 0)
    frame.BackgroundColor3 = ColorScheme.Background
    frame.BackgroundTransparency = 0.1
    frame.ZIndex = 20
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.06, 0)
    corner.Parent = frame
    
    local shadow = DropShadow:Clone()
    shadow.Parent = frame
    
    local glass = GlassEffect:Clone()
    glass.Parent = frame
    
    local glow = NeonGlow:Clone()
    glow.ZIndex = -1
    glow.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.2, 0)
    title.Text = "Телепорт к координатам"
    title.TextColor3 = ColorScheme.Accent
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    
    local xInput = Instance.new("TextBox")
    xInput.Size = UDim2.new(0.9, 0, 0.15, 0)
    xInput.Position = UDim2.new(0.05, 0, 0.2, 0)
    xInput.PlaceholderText = "X координата"
    xInput.BackgroundColor3 = ColorScheme.Primary
    xInput.BackgroundTransparency = 0.3
    xInput.TextColor3 = ColorScheme.Text
    xInput.Font = Enum.Font.Gotham
    xInput.ClearTextOnFocus = false
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0.05, 0)
    inputCorner.Parent = xInput
    
    local yInput = xInput:Clone()
    yInput.Position = UDim2.new(0.05, 0, 0.37, 0)
    yInput.PlaceholderText = "Y координата"
    yInput.Parent = frame
    
    local zInput = xInput:Clone()
    zInput.Position = UDim2.new(0.05, 0, 0.54, 0)
    zInput.PlaceholderText = "Z координата"
    zInput.Parent = frame
    
    local currentPosBtn = CreateButton("Вставить текущие", function()
        local pos = GetPlayerPosition()
        if pos then
            xInput.Text = string.format("%.1f", pos.X)
            yInput.Text = string.format("%.1f", pos.Y)
            zInput.Text = string.format("%.1f", pos.Z)
            ShowPopup("Координаты", "Текущие координаты установлены", "SUCCESS")
        else
            ShowPopup("Ошибка", "Не удалось получить позицию", "ERROR")
        end
    end)
    currentPosBtn.Size = UDim2.new(0.9, 0, 0.15, 0)
    currentPosBtn.Position = UDim2.new(0.05, 0, 0.71, 0)
    currentPosBtn.Parent = frame
    
    local teleportBtn = CreateButton("Телепортироваться", function()
        local x = tonumber(xInput.Text)
        local y = tonumber(yInput.Text)
        local z = tonumber(zInput.Text)
        
        if x and y and z then
            TeleportTo(Vector3.new(x, y, z))
            ShowPopup("Телепорт", string.format("Перемещение к %.1f, %.1f, %.1f", x, y, z), "SUCCESS")
            frame:Destroy()
        else
            ShowPopup("Ошибка", "Неверные координаты", "ERROR")
        end
    end)
    teleportBtn.Size = UDim2.new(0.6, 0, 0.15, 0)
    teleportBtn.Position = UDim2.new(0.2, 0, 0.88, 0)
    teleportBtn.Parent = frame
    
    frame.Parent = TeleportMenu
    title.Parent = frame
    xInput.Parent = frame
    
    -- Анимация появления
    frame.BackgroundTransparency = 1
    glass.BackgroundTransparency = 1
    glow.ImageTransparency = 1
    title.TextTransparency = 1
    xInput.BackgroundTransparency = 1
    xInput.TextTransparency = 1
    yInput.BackgroundTransparency = 1
    yInput.TextTransparency = 1
    zInput.BackgroundTransparency = 1
    zInput.TextTransparency = 1
    currentPosBtn.BackgroundTransparency = 1
    currentPosBtn.TextTransparency = 1
    teleportBtn.BackgroundTransparency = 1
    teleportBtn.TextTransparency = 1
    
    TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(glass, TweenInfo.new(0.3), {BackgroundTransparency = 0.95}):Play()
    TweenService:Create(glow, TweenInfo.new(0.3), {ImageTransparency = 0.85}):Play()
    TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(xInput, TweenInfo.new(0.3), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
    TweenService:Create(yInput, TweenInfo.new(0.3), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
    TweenService:Create(zInput, TweenInfo.new(0.3), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
    TweenService:Create(currentPosBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.2, TextTransparency = 0}):Play()
    TweenService:Create(teleportBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.2, TextTransparency = 0}):Play()
end)

-- 3. Телепорт к игроку
CreateButton("Телепорт к игроку", function()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.8, 0, 0.6, 0)
    frame.Position = UDim2.new(0.1, 0, 0.2, 0)
    frame.BackgroundColor3 = ColorScheme.Background
    frame.BackgroundTransparency = 0.1
    frame.ZIndex = 20
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.06, 0)
    corner.Parent = frame
    
    local shadow = DropShadow:Clone()
    shadow.Parent = frame
    
    local glass = GlassEffect:Clone()
    glass.Parent = frame
    
    local glow = NeonGlow:Clone()
    glow.ZIndex = -1
    glow.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.1, 0)
    title.Text = "Выберите игрока"
    title.TextColor3 = ColorScheme.Accent
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 0.8, 0)
    scrollFrame.Position = UDim2.new(0, 0, 0.1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = ColorScheme.Accent
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = scrollFrame
    
    frame.Parent = TeleportMenu
    title.Parent = frame
    scrollFrame.Parent = frame
    
    -- Добавляем игроков
    local players = Players:GetPlayers()
    for _, player in ipairs(players) do
        if player ~= localPlayer then
            local btn = CreateButton(player.Name, function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    TeleportTo(player.Character.HumanoidRootPart.Position)
                    ShowPopup("Телепорт", "Перемещение к "..player.Name, "SUCCESS")
                    frame:Destroy()
                else
                    ShowPopup("Ошибка", "Игрок не найден", "ERROR")
                end
            end)
            btn.Size = UDim2.new(0.9, 0, 0, 55)
            btn.Position = UDim2.new(0.05, 0, 0, 0)
            btn.Parent = scrollFrame
        end
    end
    
    -- Обновляем размер прокрутки
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #players * 63)
    
    -- Анимация появления
    frame.BackgroundTransparency = 1
    glass.BackgroundTransparency = 1
    glow.ImageTransparency = 1
    title.TextTransparency = 1
    
    TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(glass, TweenInfo.new(0.3), {BackgroundTransparency = 0.95}):Play()
    TweenService:Create(glow, TweenInfo.new(0.3), {ImageTransparency = 0.85}):Play()
    TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
end)

-- 4. Постоянная телепортация за игроком
CreateButton("Следовать за игроком", function()
    if trackingPlayer then
        if trackingConnection then
            trackingConnection:Disconnect()
            trackingConnection = nil
        end
        trackingPlayer = nil
        ShowPopup("Инфо", "Режим следования отключен", "SUCCESS")
        return
    end
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.8, 0, 0.6, 0)
    frame.Position = UDim2.new(0.1, 0, 0.2, 0)
    frame.BackgroundColor3 = ColorScheme.Background
    frame.BackgroundTransparency = 0.1
    frame.ZIndex = 20
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.06, 0)
    corner.Parent = frame
    
    local shadow = DropShadow:Clone()
    shadow.Parent = frame
    
    local glass = GlassEffect:Clone()
    glass.Parent = frame
    
    local glow = NeonGlow:Clone()
    glow.ZIndex = -1
    glow.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.1, 0)
    title.Text = "Выберите игрока для слежения"
    title.TextColor3 = ColorScheme.Accent
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 0.8, 0)
    scrollFrame.Position = UDim2.new(0, 0, 0.1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = ColorScheme.Accent
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = scrollFrame
    
    frame.Parent = TeleportMenu
    title.Parent = frame
    scrollFrame.Parent = frame
    
    -- Добавляем игроков
    local players = Players:GetPlayers()
    for _, player in ipairs(players) do
        if player ~= localPlayer then
            local btn = CreateButton(player.Name, function()
                trackingPlayer = player
                frame:Destroy()
                
                if trackingConnection then
                    trackingConnection:Disconnect()
                end
                
                trackingConnection = RunService.Heartbeat:Connect(function()
                    if trackingPlayer and trackingPlayer.Character and trackingPlayer.Character:FindFirstChild("HumanoidRootPart") and
                       localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local offset = CFrame.new(0, 0, -4)
                        localPlayer.Character.HumanoidRootPart.CFrame = trackingPlayer.Character.HumanoidRootPart.CFrame * offset
                    end
                end)
                
                ShowPopup("Режим следования", "Вы следуете за "..player.Name, "SUCCESS")
            end)
            btn.Size = UDim2.new(0.9, 0, 0, 55)
            btn.Position = UDim2.new(0.05, 0, 0, 0)
            btn.Parent = scrollFrame
        end
    end
    
    -- Обновляем размер прокрутки
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #players * 63)
    
    -- Анимация появления
    frame.BackgroundTransparency = 1
    glass.BackgroundTransparency = 1
    glow.ImageTransparency = 1
    title.TextTransparency = 1
    
    TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(glass, TweenInfo.new(0.3), {BackgroundTransparency = 0.95}):Play()
    TweenService:Create(glow, TweenInfo.new(0.3), {ImageTransparency = 0.85}):Play()
    TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
end)

-- 5. Телепорт вверх/вниз
CreateButton("Телепорт вверх", function()
    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = localPlayer.Character.HumanoidRootPart
        TeleportTo(root.Position + Vector3.new(0, 50, 0))
        ShowPopup("Телепорт", "Перемещение на 50 единиц вверх", "SUCCESS")
    end
end)

CreateButton("Телепорт вниз", function()
    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = localPlayer.Character.HumanoidRootPart
        TeleportTo(root.Position + Vector3.new(0, -50, 0))
        ShowPopup("Телепорт", "Перемещение на 50 единиц вниз", "SUCCESS")
    end
end)

-- 6. Сохранение позиции
CreateButton("Сохранить позицию", function()
    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        savedPosition = localPlayer.Character.HumanoidRootPart.Position
        ShowPopup("Сохранено", "Текущая позиция сохранена", "SUCCESS")
    end
end)

CreateButton("Вернуться к сохраненной", function()
    if savedPosition then
        TeleportTo(savedPosition)
        ShowPopup("Телепорт", "Возврат к сохраненной позиции", "SUCCESS")
    else
        ShowPopup("Ошибка", "Позиция не сохранена", "ERROR")
    end
end)

-- 7. Ноклип режим
CreateButton("Переключить ноклип", function()
    noclipEnabled = not noclipEnabled
    if localPlayer.Character then
        for _, part in ipairs(localPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not noclipEnabled
            end
        end
    end
    ShowPopup("Ноклип", noclipEnabled and "Режим ноклип ВКЛ" or "Режим ноклип ВЫКЛ", "SUCCESS")
end)

-- 8. Режим полета
CreateButton("Переключить полет", function()
    flyEnabled = not flyEnabled
    -- Здесь должна быть реализация полета
    ShowPopup("Полет", flyEnabled and "Режим полета ВКЛ" or "Режим полета ВЫКЛ", "SUCCESS")
end)

-- 9. Настройки скорости
CreateButton("Изменить скорость", function()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.8, 0, 0.25, 0)
    frame.Position = UDim2.new(0.1, 0, 0.375, 0)
    frame.BackgroundColor3 = ColorScheme.Background
    frame.BackgroundTransparency = 0.1
    frame.ZIndex = 20
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.06, 0)
    corner.Parent = frame
    
    local shadow = DropShadow:Clone()
    shadow.Parent = frame
    
    local glass = GlassEffect:Clone()
    glass.Parent = frame
    
    local glow = NeonGlow:Clone()
    glow.ZIndex = -1
    glow.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.3, 0)
    title.Text = "Скорость передвижения"
    title.TextColor3 = ColorScheme.Accent
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.9, 0, 0.2, 0)
    slider.Position = UDim2.new(0.05, 0, 0.3, 0)
    slider.BackgroundColor3 = ColorScheme.Primary
    slider.BackgroundTransparency = 0.3
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0.5, 0)
    sliderCorner.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(walkSpeed / 50, 0, 1, 0)
    fill.BackgroundColor3 = ColorScheme.Accent
    fill.BorderSizePixel = 0
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0.5, 0)
    fillCorner.Parent = fill
    
    local valueText = Instance.new("TextLabel")
    valueText.Size = UDim2.new(1, 0, 0.5, 0)
    valueText.Position = UDim2.new(0, 0, 0.5, 0)
    valueText.Text = tostring(walkSpeed)
    valueText.TextColor3 = ColorScheme.Text
    valueText.Font = Enum.Font.GothamBold
    valueText.BackgroundTransparency = 1
    
    local setBtn = CreateButton("Применить", function()
        if localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
            localPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = walkSpeed
            ShowPopup("Скорость", "Установлена скорость: "..walkSpeed, "SUCCESS")
            frame:Destroy()
        end
    end)
    setBtn.Size = UDim2.new(0.4, 0, 0.2, 0)
    setBtn.Position = UDim2.new(0.3, 0, 0.8, 0)
    
    frame.Parent = TeleportMenu
    title.Parent = frame
    slider.Parent = frame
    fill.Parent = slider
    valueText.Parent = slider
    setBtn.Parent = frame
    
    -- Логика слайдера
    local function updateSlider(input)
        local pos = UDim2.new(math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1), 0, 1, 0)
        fill.Size = pos
        walkSpeed = math.floor(pos.X.Scale * 50)
        valueText.Text = tostring(walkSpeed)
    end
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input)
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                else
                    updateSlider(input)
                end
            end)
        end
    end)
    
    -- Анимация появления
    frame.BackgroundTransparency = 1
    glass.BackgroundTransparency = 1
    glow.ImageTransparency = 1
    title.TextTransparency = 1
    slider.BackgroundTransparency = 1
    fill.BackgroundTransparency = 1
    valueText.TextTransparency = 1
    setBtn.BackgroundTransparency = 1
    setBtn.TextTransparency = 1
    
    TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(glass, TweenInfo.new(0.3), {BackgroundTransparency = 0.95}):Play()
    TweenService:Create(glow, TweenInfo.new(0.3), {ImageTransparency = 0.85}):Play()
    TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(slider, TweenInfo.new(0.3), {BackgroundTransparency = 0.3}):Play()
    TweenService:Create(fill, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    TweenService:Create(valueText, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(setBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.2, TextTransparency = 0}):Play()
end)

-- 10. Настройки прыжка
CreateButton("Изменить прыжок", function()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.8, 0, 0.25, 0)
    frame.Position = UDim2.new(0.1, 0, 0.375, 0)
    frame.BackgroundColor3 = ColorScheme.Background
    frame.BackgroundTransparency = 0.1
    frame.ZIndex = 20
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.06, 0)
    corner.Parent = frame
    
    local shadow = DropShadow:Clone()
    shadow.Parent = frame
    
    local glass = GlassEffect:Clone()
    glass.Parent = frame
    
    local glow = NeonGlow:Clone()
    glow.ZIndex = -1
    glow.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.3, 0)
    title.Text = "Сила прыжка"
    title.TextColor3 = ColorScheme.Accent
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.9, 0, 0.2, 0)
    slider.Position = UDim2.new(0.05, 0, 0.3, 0)
    slider.BackgroundColor3 = ColorScheme.Primary
    slider.BackgroundTransparency = 0.3
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0.5, 0)
    sliderCorner.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(jumpPower / 100, 0, 1, 0)
    fill.BackgroundColor3 = ColorScheme.Accent
    fill.BorderSizePixel = 0
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0.5, 0)
    fillCorner.Parent = fill
    
    local valueText = Instance.new("TextLabel")
    valueText.Size = UDim2.new(1, 0, 0.5, 0)
    valueText.Position = UDim2.new(0, 0, 0.5, 0)
    valueText.Text = tostring(jumpPower)
    valueText.TextColor3 = ColorScheme.Text
    valueText.Font = Enum.Font.GothamBold
    valueText.BackgroundTransparency = 1
    
    local setBtn = CreateButton("Применить", function()
        if localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
            localPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = jumpPower
            ShowPopup("Прыжок", "Установлена сила прыжка: "..jumpPower, "SUCCESS")
            frame:Destroy()
        end
    end)
    setBtn.Size = UDim2.new(0.4, 0, 0.2, 0)
    setBtn.Position = UDim2.new(0.3, 0, 0.8, 0)
    
    frame.Parent = TeleportMenu
    title.Parent = frame
    slider.Parent = frame
    fill.Parent = slider
    valueText.Parent = slider
    setBtn.Parent = frame
    
    -- Логика слайдера
    local function updateSlider(input)
        local pos = UDim2.new(math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1), 0, 1, 0)
        fill.Size = pos
        jumpPower = math.floor(pos.X.Scale * 100)
        valueText.Text = tostring(jumpPower)
    end
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input)
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                else
                    updateSlider(input)
                end
            end)
        end
    end)
    
    -- Анимация появления
    frame.BackgroundTransparency = 1
    glass.BackgroundTransparency = 1
    glow.ImageTransparency = 1
    title.TextTransparency = 1
    slider.BackgroundTransparency = 1
    fill.BackgroundTransparency = 1
    valueText.TextTransparency = 1
    setBtn.BackgroundTransparency = 1
    setBtn.TextTransparency = 1
    
    TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(glass, TweenInfo.new(0.3), {BackgroundTransparency = 0.95}):Play()
    TweenService:Create(glow, TweenInfo.new(0.3), {ImageTransparency = 0.85}):Play()
    TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(slider, TweenInfo.new(0.3), {BackgroundTransparency = 0.3}):Play()
    TweenService:Create(fill, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    TweenService:Create(valueText, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(setBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.2, TextTransparency = 0}):Play()
end)

-- 11. Копирование координат
CreateButton("Копировать координаты", function()
    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local pos = localPlayer.Character.HumanoidRootPart.Position
        CopyToClipboard(string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z))
    else
        ShowPopup("Ошибка", "Не удалось получить координаты", "ERROR")
    end
end)

-- 12. Показать координаты
local coordsEnabled = false
local coordsDisplay = Instance.new("TextLabel")
coordsDisplay.Name = "CoordsDisplay"
coordsDisplay.Size = UDim2.new(0.3, 0, 0.05, 0)
coordsDisplay.Position = UDim2.new(0.35, 0, 0.01, 0)
coordsDisplay.BackgroundColor3 = ColorScheme.Background
coordsDisplay.BackgroundTransparency = 0.7
coordsDisplay.Text = "X: 0, Y: 0, Z: 0"
coordsDisplay.TextColor3 = ColorScheme.Accent
coordsDisplay.TextScaled = true
coordsDisplay.Font = Enum.Font.GothamBold
coordsDisplay.Visible = false

local coordsCorner = Instance.new("UICorner")
coordsCorner.CornerRadius = UDim.new(0.1, 0)
coordsCorner.Parent = coordsDisplay

local coordsShadow = DropShadow:Clone()
coordsShadow.Parent = coordsDisplay

coordsDisplay.Parent = TeleportMenu

CreateButton("Показать координаты", function()
    coordsEnabled = not coordsEnabled
    coordsDisplay.Visible = coordsEnabled
    
    if coordsEnabled then
        RunService.Heartbeat:Connect(function()
            if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local pos = localPlayer.Character.HumanoidRootPart.Position
                coordsDisplay.Text = string.format("X: %d, Y: %d, Z: %d", math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z))
            end
        end)
    end
end)

-- 13. Авто-сохранение точек
CreateButton("Авто-сохранение точек", function()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.8, 0, 0.25, 0)
    frame.Position = UDim2.new(0.1, 0, 0.375, 0)
    frame.BackgroundColor3 = ColorScheme.Background
    frame.BackgroundTransparency = 0.1
    frame.ZIndex = 20
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.06, 0)
    corner.Parent = frame
    
    local shadow = DropShadow:Clone()
    shadow.Parent = frame
    
    local glass = GlassEffect:Clone()
    glass.Parent = frame
    
    local glow = NeonGlow:Clone()
    glow.ZIndex = -1
    glow.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.3, 0)
    title.Text = "Авто-сохранение точек"
    title.TextColor3 = ColorScheme.Accent
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.9, 0, 0.3, 0)
    input.Position = UDim2.new(0.05, 0, 0.3, 0)
    input.PlaceholderText = "Интервал в секундах (0 = выключить)"
    input.BackgroundColor3 = ColorScheme.Primary
    input.BackgroundTransparency = 0.3
    input.TextColor3 = ColorScheme.Text
    input.Font = Enum.Font.Gotham
    input.ClearTextOnFocus = false
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0.05, 0)
    inputCorner.Parent = input
    
    local setBtn = CreateButton("Установить", function()
        local interval = tonumber(input.Text) or 0
        if interval > 0 then
            -- Здесь должна быть реализация авто-сохранения
            ShowPopup("Авто-сохранение", string.format("Точки будут сохраняться каждые %d сек", interval), "SUCCESS")
        else
            ShowPopup("Авто-сохранение", "Авто-сохранение отключено", "SUCCESS")
        end
        frame:Destroy()
    end)
    setBtn.Size = UDim2.new(0.4, 0, 0.2, 0)
    setBtn.Position = UDim2.new(0.3, 0, 0.8, 0)
    
    frame.Parent = TeleportMenu
    title.Parent = frame
    input.Parent = frame
    setBtn.Parent = frame
    
    -- Анимация появления
    frame.BackgroundTransparency = 1
    glass.BackgroundTransparency = 1
    glow.ImageTransparency = 1
    title.TextTransparency = 1
    input.BackgroundTransparency = 1
    input.TextTransparency = 1
    setBtn.BackgroundTransparency = 1
    setBtn.TextTransparency = 1
    
    TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(glass, TweenInfo.new(0.3), {BackgroundTransparency = 0.95}):Play()
    TweenService:Create(glow, TweenInfo.new(0.3), {ImageTransparency = 0.85}):Play()
    TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(input, TweenInfo.new(0.3), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
    TweenService:Create(setBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.2, TextTransparency = 0}):Play()
end)

--🌀 Анимация появления меню
MainFrame.Position = UDim2.new(-0.5, 0, 0.15, 0)
ToggleMenu()

--🎉 Добавляем несколько тестовых сохраненных точек
SaveLocation("Стартовая точка", Vector3.new(0, 5, 0))
SaveLocation("Высокая точка", Vector3.new(0, 100, 0))
SaveLocation("Далекая точка", Vector3.new(100, 5, 100))
UpdateSavedLocationsList()
