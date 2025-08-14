--[[
    Улучшенное меню телепортации с сохранением точек
    Функции:
    - Сохранение точек телепорта с названиями
    - Удаление сохраненных точек
    - Телепорт к координатам
    - Телепорт к игроку
    - Постоянная телепортация за игроком
    - Показать координаты
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Цветовая схема
local ColorScheme = {
    Background = Color3.fromRGB(25, 30, 40),
    Primary = Color3.fromRGB(65, 125, 210),
    Secondary = Color3.fromRGB(45, 85, 160),
    Accent = Color3.fromRGB(90, 190, 255),
    Text = Color3.fromRGB(245, 245, 245),
    Error = Color3.fromRGB(225, 75, 75),
    Success = Color3.fromRGB(75, 225, 110),
    SavedLocation = Color3.fromRGB(85, 195, 100),
    DeleteButton = Color3.fromRGB(200, 70, 70)
}

-- Создание интерфейса
local TeleportMenu = Instance.new("ScreenGui")
TeleportMenu.Name = "TeleportMenu"
TeleportMenu.ResetOnSpawn = false
TeleportMenu.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Основной фрейм с эффектом стекла
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0.35, 0, 0.55, 0)
MainFrame.Position = UDim2.new(0.02, 0, 0.225, 0)
MainFrame.BackgroundColor3 = ColorScheme.Background
MainFrame.BackgroundTransparency = 0.15
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

-- Заголовок с градиентом
local Title = Instance.new("Frame")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0.08, 0)
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
TitleText.Text = "✦ ТЕЛЕПОРТ МЕНЮ ✦"
TitleText.TextColor3 = ColorScheme.Text
TitleText.TextScaled = true
TitleText.Font = Enum.Font.GothamBold
TitleText.BackgroundTransparency = 1

-- Область прокрутки
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Name = "ScrollingFrame"
ScrollingFrame.Size = UDim2.new(1, 0, 0.92, 0)
ScrollingFrame.Position = UDim2.new(0, 0, 0.08, 0)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 5
ScrollingFrame.ScrollBarImageColor3 = ColorScheme.Accent
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 2, 0)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 12)
UIPadding.PaddingBottom = UDim.new(0, 12)
UIPadding.PaddingLeft = UDim.new(0, 12)
UIPadding.PaddingRight = UDim.new(0, 12)
UIPadding.Parent = ScrollingFrame

-- Кнопка переключения меню
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0.08, 0, 0.08, 0)
ToggleButton.Position = UDim2.new(0.02, 0, 0.02, 0)
ToggleButton.BackgroundColor3 = ColorScheme.Primary
ToggleButton.BackgroundTransparency = 0.2
ToggleButton.Image = "rbxassetid://3926305904"
ToggleButton.ImageRectOffset = Vector2.new(124, 204)
ToggleButton.ImageRectSize = Vector2.new(36, 36)
ToggleButton.ImageColor3 = ColorScheme.Text

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0.5, 0)
UICorner2.Parent = ToggleButton

-- Эффект свечения при наведении
local HoverEffect = Instance.new("Frame")
HoverEffect.Size = UDim2.new(1, 10, 1, 10)
HoverEffect.Position = UDim2.new(0, -5, 0, -5)
HoverEffect.BackgroundTransparency = 1
HoverEffect.ZIndex = -1

local HoverGlow = Instance.new("ImageLabel")
HoverGlow.Image = "rbxassetid://5028857084"
HoverGlow.ImageColor3 = ColorScheme.Accent
HoverGlow.ImageTransparency = 0.8
HoverGlow.ScaleType = Enum.ScaleType.Slice
HoverGlow.SliceCenter = Rect.new(24, 24, 276, 276)
HoverGlow.Size = UDim2.new(1, 0, 1, 0)
HoverGlow.BackgroundTransparency = 1
HoverGlow.Parent = HoverEffect

-- Сохраненные координаты
local SavedLocations = {}

-- Анимация кнопок
local function SetupButton(button)
    local originalSize = button.Size
    local originalColor = button.BackgroundColor3
    
    local effect = HoverEffect:Clone()
    effect.Parent = button
    effect.Visible = false
    
    button.MouseEnter:Connect(function()
        effect.Visible = true
        TweenService:Create(button, TweenInfo.new(0.15), {
            Size = originalSize + UDim2.new(0.05, 0, 0.05, 0),
            BackgroundColor3 = ColorScheme.Accent
        }):Play()
        TweenService:Create(effect, TweenInfo.new(0.15), {
            Size = originalSize + UDim2.new(0.1, 0, 0.1, 0)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        effect.Visible = false
        TweenService:Create(button, TweenInfo.new(0.15), {
            Size = originalSize,
            BackgroundColor3 = originalColor
        }):Play()
    end)
end

-- Сборка интерфейса
MainFrame.Parent = TeleportMenu
GlassEffect.Parent = MainFrame
DropShadow.Parent = MainFrame
Title.Parent = MainFrame
TitleText.Parent = Title
ScrollingFrame.Parent = MainFrame
UIListLayout.Parent = ScrollingFrame
ToggleButton.Parent = TeleportMenu
TeleportMenu.Parent = playerGui

-- Переменные состояния
local menuVisible = true
local debounce = false
local trackingPlayer = nil
local trackingConnection = nil

-- Функция создания кнопки
local function CreateButton(text, callback, isSavedLocation, isDeleteButton)
    local button = Instance.new("TextButton")
    button.Name = text
    button.Size = UDim2.new(0.9, 0, 0, 50)
    button.BackgroundColor3 = isDeleteButton and ColorScheme.DeleteButton 
                            or isSavedLocation and ColorScheme.SavedLocation 
                            or ColorScheme.Primary
    button.BackgroundTransparency = 0.2
    button.Text = text
    button.TextColor3 = ColorScheme.Text
    button.TextScaled = true
    button.Font = Enum.Font.GothamMedium
    button.AutoButtonColor = false
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0.1, 0)
    buttonCorner.Parent = button
    
    local textConstraint = Instance.new("UITextSizeConstraint")
    textConstraint.MaxTextSize = 18
    textConstraint.Parent = button
    
    SetupButton(button)
    
    button.MouseButton1Click:Connect(function()
        if not debounce then
            debounce = true
            
            -- Анимация нажатия
            TweenService:Create(button, TweenInfo.new(0.1), {
                BackgroundColor3 = ColorScheme.Accent,
                TextColor3 = Color3.new(1,1,1),
                Size = button.Size + UDim2.new(0, -5, 0, -5)
            }):Play()
            task.wait(0.1)
            TweenService:Create(button, TweenInfo.new(0.1), {
                BackgroundColor3 = isDeleteButton and ColorScheme.DeleteButton 
                                or isSavedLocation and ColorScheme.SavedLocation 
                                or ColorScheme.Primary,
                TextColor3 = ColorScheme.Text,
                Size = button.Size
            }):Play()
            
            callback()
            task.wait(0.2)
            debounce = false
        end
    end)
    
    button.Parent = ScrollingFrame
    return button
end

-- Функция показа/скрытия меню
local function ToggleMenu()
    menuVisible = not menuVisible
    if menuVisible then
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.02, 0, 0.225, 0),
            BackgroundTransparency = 0.15
        }):Play()
        ToggleButton.ImageRectOffset = Vector2.new(124, 204)
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(-0.5, 0, 0.225, 0),
            BackgroundTransparency = 0.5
        }):Play()
        ToggleButton.ImageRectOffset = Vector2.new(964, 324)
    end
end

ToggleButton.MouseButton1Click:Connect(ToggleMenu)

-- Всплывающее окно с анимацией
local function ShowPopup(title, message, isError)
    local popup = Instance.new("Frame")
    popup.Size = UDim2.new(0.8, 0, 0.15, 0)
    popup.Position = UDim2.new(0.1, 0, 0.4, 0)
    popup.BackgroundColor3 = ColorScheme.Background
    popup.BackgroundTransparency = 0.1
    popup.ZIndex = 10
    
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
    titleLabel.TextColor3 = isError and ColorScheme.Error or ColorScheme.Success
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
    end
end

-- Функция обновления списка сохраненных точек
local function UpdateSavedLocations()
    -- Удаляем старые кнопки сохраненных точек
    for _, child in ipairs(ScrollingFrame:GetChildren()) do
        if child:GetAttribute("IsSavedLocation") then
            child:Destroy()
        end
    end
    
    -- Создаем новые кнопки
    for name, position in pairs(SavedLocations) do
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0.9, 0, 0, 50)
        container.BackgroundTransparency = 1
        container.LayoutOrder = 1
        container:SetAttribute("IsSavedLocation", true)
        
        local button = CreateButton(name, function()
            TeleportTo(position)
        end, true)
        button.Size = UDim2.new(0.8, 0, 1, 0)
        button.Position = UDim2.new(0, 0, 0, 0)
        button.Parent = container
        
        local deleteBtn = CreateButton("×", function()
            SavedLocations[name] = nil
            UpdateSavedLocations()
            ShowPopup("Успех", "Точка '"..name.."' удалена", false)
        end, false, true)
        deleteBtn.Size = UDim2.new(0.15, 0, 1, 0)
        deleteBtn.Position = UDim2.new(0.85, 0, 0, 0)
        deleteBtn.TextXAlignment = Enum.TextXAlignment.Center
        deleteBtn.Parent = container
        
        container.Parent = ScrollingFrame
    end
end

-- 1. Добавить новую точку телепорта
CreateButton("Добавить точку телепорта", function()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.8, 0, 0.3, 0)
    frame.Position = UDim2.new(0.1, 0, 0.35, 0)
    frame.BackgroundColor3 = ColorScheme.Background
    frame.BackgroundTransparency = 0.1
    frame.ZIndex = 10
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.05, 0)
    corner.Parent = frame
    
    local shadow = DropShadow:Clone()
    shadow.Parent = frame
    
    local glass = GlassEffect:Clone()
    glass.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.2, 0)
    title.Text = "Добавить точку телепорта"
    title.TextColor3 = ColorScheme.Accent
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    
    local nameInput = Instance.new("TextBox")
    nameInput.Size = UDim2.new(0.9, 0, 0.2, 0)
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
    
    local coordsInput = Instance.new("TextBox")
    coordsInput.Size = UDim2.new(0.9, 0, 0.2, 0)
    coordsInput.Position = UDim2.new(0.05, 0, 0.4, 0)
    coordsInput.PlaceholderText = "X,Y,Z или оставьте пустым для текущих"
    coordsInput.BackgroundColor3 = ColorScheme.Primary
    coordsInput.BackgroundTransparency = 0.3
    coordsInput.TextColor3 = ColorScheme.Text
    coordsInput.Font = Enum.Font.Gotham
    coordsInput.ClearTextOnFocus = false
    inputCorner:Clone().Parent = coordsInput
    
    local addBtn = CreateButton("Добавить", function()
        local name = nameInput.Text
        if name == "" then
            ShowPopup("Ошибка", "Введите название точки", true)
            return
        end
        
        local position
        if coordsInput.Text == "" then
            -- Используем текущие координаты
            if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                position = localPlayer.Character.HumanoidRootPart.Position
            else
                ShowPopup("Ошибка", "Не удалось получить текущие координаты", true)
                return
            end
        else
            -- Парсим введенные координаты
            local coords = {}
            for coord in string.gmatch(coordsInput.Text, "[^,]+") do
                table.insert(coords, tonumber(coord))
            end
            
            if #coords ~= 3 then
                ShowPopup("Ошибка", "Введите координаты в формате X,Y,Z", true)
                return
            end
            
            position = Vector3.new(coords[1], coords[2], coords[3])
        end
        
        -- Сохраняем точку
        SavedLocations[name] = position
        UpdateSavedLocations()
        
        ShowPopup("Успех", "Точка '"..name.."' добавлена", false)
        frame:Destroy()
    end)
    addBtn.Size = UDim2.new(0.4, 0, 0.2, 0)
    addBtn.Position = UDim2.new(0.3, 0, 0.7, 0)
    addBtn.Parent = frame
    
    frame.Parent = TeleportMenu
    title.Parent = frame
    nameInput.Parent = frame
    coordsInput.Parent = frame
    
    -- Анимация появления
    frame.BackgroundTransparency = 1
    glass.BackgroundTransparency = 1
    title.TextTransparency = 1
    nameInput.BackgroundTransparency = 1
    nameInput.TextTransparency = 1
    coordsInput.BackgroundTransparency = 1
    coordsInput.TextTransparency = 1
    addBtn.BackgroundTransparency = 1
    addBtn.TextTransparency = 1
    
    TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(glass, TweenInfo.new(0.3), {BackgroundTransparency = 0.9}):Play()
    TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(nameInput, TweenInfo.new(0.3), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
    TweenService:Create(coordsInput, TweenInfo.new(0.3), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
    TweenService:Create(addBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.2, TextTransparency = 0}):Play()
end)

-- 2. Телепорт к координатам
CreateButton("Телепорт к координатам", function()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.8, 0, 0.3, 0)
    frame.Position = UDim2.new(0.1, 0, 0.35, 0)
    frame.BackgroundColor3 = ColorScheme.Background
    frame.BackgroundTransparency = 0.1
    frame.ZIndex = 10
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.05, 0)
    corner.Parent = frame
    
    local shadow = DropShadow:Clone()
    shadow.Parent = frame
    
    local glass = GlassEffect:Clone()
    glass.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.2, 0)
    title.Text = "Введите координаты"
    title.TextColor3 = ColorScheme.Accent
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    
    local xInput = Instance.new("TextBox")
    xInput.Size = UDim2.new(0.9, 0, 0.2, 0)
    xInput.Position = UDim2.new(0.05, 0, 0.2, 0)
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
    yInput.Position = UDim2.new(0.05, 0, 0.4, 0)
    yInput.PlaceholderText = "Y"
    yInput.Parent = frame
    
    local zInput = xInput:Clone()
    zInput.Position = UDim2.new(0.05, 0, 0.6, 0)
    zInput.PlaceholderText = "Z"
    zInput.Parent = frame
    
    local teleportBtn = CreateButton("Телепорт", function()
        local x = tonumber(xInput.Text)
        local y = tonumber(yInput.Text)
        local z = tonumber(zInput.Text)
        
        if x and y and z then
            TeleportTo(Vector3.new(x, y, z))
            ShowPopup("Успех", string.format("Телепорт к %.1f, %.1f, %.1f", x, y, z), false)
            frame:Destroy()
        else
            ShowPopup("Ошибка", "Некорректные координаты", true)
        end
    end)
    teleportBtn.Size = UDim2.new(0.4, 0, 0.2, 0)
    teleportBtn.Position = UDim2.new(0.3, 0, 0.8, 0)
    teleportBtn.Parent = frame
    
    frame.Parent = TeleportMenu
    title.Parent = frame
    xInput.Parent = frame
    
    -- Анимация появления
    frame.BackgroundTransparency = 1
    glass.BackgroundTransparency = 1
    title.TextTransparency = 1
    xInput.BackgroundTransparency = 1
    xInput.TextTransparency = 1
    yInput.BackgroundTransparency = 1
    yInput.TextTransparency = 1
    zInput.BackgroundTransparency = 1
    zInput.TextTransparency = 1
    teleportBtn.BackgroundTransparency = 1
    teleportBtn.TextTransparency = 1
    
    TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(glass, TweenInfo.new(0.3), {BackgroundTransparency = 0.9}):Play()
    TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(xInput, TweenInfo.new(0.3), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
    TweenService:Create(yInput, TweenInfo.new(0.3), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
    TweenService:Create(zInput, TweenInfo.new(0.3), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
    TweenService:Create(teleportBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.2, TextTransparency = 0}):Play()
end)

-- 3. Телепорт к игроку
CreateButton("Телепорт к игроку", function()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.8, 0, 0.6, 0)
    frame.Position = UDim2.new(0.1, 0, 0.2, 0)
    frame.BackgroundColor3 = ColorScheme.Background
    frame.BackgroundTransparency = 0.1
    frame.ZIndex = 10
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.05, 0)
    corner.Parent = frame
    
    local shadow = DropShadow:Clone()
    shadow.Parent = frame
    
    local glass = GlassEffect:Clone()
    glass.Parent = frame
    
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
    scrollFrame.ScrollBarThickness = 5
    scrollFrame.ScrollBarImageColor3 = ColorScheme.Accent
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
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
                    ShowPopup("Успех", "Телепорт к "..player.Name, false)
                    frame:Destroy()
                else
                    ShowPopup("Ошибка", "Игрок не найден", true)
                end
            end)
            btn.Size = UDim2.new(0.9, 0, 0, 50)
            btn.Position = UDim2.new(0.05, 0, 0, 0)
            btn.Parent = scrollFrame
        end
    end
    
    -- Обновляем размер прокрутки
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #players * 55)
    
    -- Анимация появления
    frame.BackgroundTransparency = 1
    glass.BackgroundTransparency = 1
    title.TextTransparency = 1
    
    TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(glass, TweenInfo.new(0.3), {BackgroundTransparency = 0.9}):Play()
    TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
end)

-- 4. Постоянная телепортация за игроком
CreateButton("Телепортация за игроком", function()
    if trackingPlayer then
        if trackingConnection then
            trackingConnection:Disconnect()
            trackingConnection = nil
        end
        trackingPlayer = nil
        ShowPopup("Инфо", "Телепортация остановлена", false)
        return
    end
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.8, 0, 0.6, 0)
    frame.Position = UDim2.new(0.1, 0, 0.2, 0)
    frame.BackgroundColor3 = ColorScheme.Background
    frame.BackgroundTransparency = 0.1
    frame.ZIndex = 10
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.05, 0)
    corner.Parent = frame
    
    local shadow = DropShadow:Clone()
    shadow.Parent = frame
    
    local glass = GlassEffect:Clone()
    glass.Parent = frame
    
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
    scrollFrame.ScrollBarThickness = 5
    scrollFrame.ScrollBarImageColor3 = ColorScheme.Accent
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
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
                        localPlayer.Character.HumanoidRootPart.CFrame = trackingPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                    end
                end)
                
                ShowPopup("Инфо", "Слежение за "..player.Name, false)
            end)
            btn.Size = UDim2.new(0.9, 0, 0, 50)
            btn.Position = UDim2.new(0.05, 0, 0, 0)
            btn.Parent = scrollFrame
        end
    end
    
    -- Обновляем размер прокрутки
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #players * 55)
    
    -- Анимация появления
    frame.BackgroundTransparency = 1
    glass.BackgroundTransparency = 1
    title.TextTransparency = 1
    
    TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(glass, TweenInfo.new(0.3), {BackgroundTransparency = 0.9}):Play()
    TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
end)

-- 5. Показать координаты
local coordsEnabled = false
local coordsDisplay = Instance.new("TextLabel")
coordsDisplay.Name = "CoordsDisplay"
coordsDisplay.Size = UDim2.new(0.3, 0, 0.05, 0)
coordsDisplay.Position = UDim2.new(0.35, 0, 0, 0)
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

-- Анимация появления меню
MainFrame.Position = UDim2.new(-0.5, 0, 0.225, 0)
ToggleMenu()
