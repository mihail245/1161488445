--[[
    Красивое меню телепортации для Roblox
    Функции:
    - Телепорт к координатам
    - Телепорт к игроку (выбор из списка)
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
    Background = Color3.fromRGB(30, 35, 45),
    Primary = Color3.fromRGB(70, 130, 200),
    Secondary = Color3.fromRGB(50, 90, 150),
    Accent = Color3.fromRGB(100, 200, 255),
    Text = Color3.fromRGB(240, 240, 240),
    Error = Color3.fromRGB(220, 80, 80),
    Success = Color3.fromRGB(80, 220, 120)
}

-- Создание интерфейса
local TeleportMenu = Instance.new("ScreenGui")
TeleportMenu.Name = "TeleportMenu"
TeleportMenu.ResetOnSpawn = false
TeleportMenu.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0.35, 0, 0.45, 0)
MainFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
MainFrame.BackgroundColor3 = ColorScheme.Background
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.03, 0)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0.1, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = ColorScheme.Primary
Title.BackgroundTransparency = 0.2
Title.Text = "✦ ТЕЛЕПОРТ МЕНЮ ✦"
Title.TextColor3 = ColorScheme.Text
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Name = "ScrollingFrame"
ScrollingFrame.Size = UDim2.new(1, 0, 0.9, 0)
ScrollingFrame.Position = UDim2.new(0, 0, 0.1, 0)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 5
ScrollingFrame.ScrollBarImageColor3 = ColorScheme.Accent
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 2, 0)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 10)
UIPadding.PaddingBottom = UDim.new(0, 10)
UIPadding.PaddingLeft = UDim.new(0, 10)
UIPadding.PaddingRight = UDim.new(0, 10)
UIPadding.Parent = ScrollingFrame

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

-- Анимация кнопок
local function SetupButton(button)
    local originalSize = button.Size
    local originalColor = button.BackgroundColor3
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {
            Size = originalSize + UDim2.new(0.05, 0, 0.05, 0),
            BackgroundColor3 = ColorScheme.Accent
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {
            Size = originalSize,
            BackgroundColor3 = originalColor
        }):Play()
    end)
end

-- Сборка интерфейса
MainFrame.Parent = TeleportMenu
Title.Parent = MainFrame
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
local function CreateButton(text, callback)
    local button = Instance.new("TextButton")
    button.Name = text
    button.Size = UDim2.new(0.9, 0, 0, 50)
    button.BackgroundColor3 = ColorScheme.Primary
    button.BackgroundTransparency = 0.2
    button.Text = text
    button.TextColor3 = ColorScheme.Text
    button.TextScaled = true
    button.Font = Enum.Font.Gotham
    button.AutoButtonColor = false
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0.1, 0)
    buttonCorner.Parent = button
    
    SetupButton(button)
    
    button.MouseButton1Click:Connect(function()
        if not debounce then
            debounce = true
            -- Анимация нажатия
            TweenService:Create(button, TweenInfo.new(0.1), {
                BackgroundColor3 = ColorScheme.Accent,
                TextColor3 = Color3.new(1,1,1)
            }):Play()
            task.wait(0.1)
            TweenService:Create(button, TweenInfo.new(0.1), {
                BackgroundColor3 = ColorScheme.Primary,
                TextColor3 = ColorScheme.Text
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
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.02, 0, 0.3, 0)
        }):Play()
        ToggleButton.ImageRectOffset = Vector2.new(124, 204)
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(-0.5, 0, 0.3, 0)
        }):Play()
        ToggleButton.ImageRectOffset = Vector2.new(964, 324)
    end
end

ToggleButton.MouseButton1Click:Connect(ToggleMenu)

-- Всплывающее окно
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
    titleLabel.TextTransparency = 1
    messageLabel.TextTransparency = 1
    
    TweenService:Create(popup, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(titleLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(messageLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    
    -- Автозакрытие
    task.delay(3, function()
        TweenService:Create(popup, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(titleLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(messageLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        task.wait(0.3)
        popup:Destroy()
    end)
end

-- 1. Телепорт к координатам
CreateButton("Телепорт к координатам", function()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.8, 0, 0.3, 0)
    frame.Position = UDim2.new(0.1, 0, 0.35, 0)
    frame.BackgroundColor3 = ColorScheme.Background
    frame.BackgroundTransparency = 0.1
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.05, 0)
    corner.Parent = frame
    
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
    
    local yInput = Instance.new("TextBox")
    yInput.Size = UDim2.new(0.9, 0, 0.2, 0)
    yInput.Position = UDim2.new(0.05, 0, 0.4, 0)
    yInput.PlaceholderText = "Y"
    yInput.BackgroundColor3 = ColorScheme.Primary
    yInput.BackgroundTransparency = 0.3
    yInput.TextColor3 = ColorScheme.Text
    
    local zInput = Instance.new("TextBox")
    zInput.Size = UDim2.new(0.9, 0, 0.2, 0)
    zInput.Position = UDim2.new(0.05, 0, 0.6, 0)
    zInput.PlaceholderText = "Z"
    zInput.BackgroundColor3 = ColorScheme.Primary
    zInput.BackgroundTransparency = 0.3
    zInput.TextColor3 = ColorScheme.Text
    
    local teleportBtn = Instance.new("TextButton")
    teleportBtn.Size = UDim2.new(0.4, 0, 0.2, 0)
    teleportBtn.Position = UDim2.new(0.3, 0, 0.8, 0)
    teleportBtn.Text = "Телепорт"
    teleportBtn.TextColor3 = ColorScheme.Text
    teleportBtn.BackgroundColor3 = ColorScheme.Accent
    teleportBtn.Font = Enum.Font.GothamBold
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0.1, 0)
    btnCorner.Parent = teleportBtn
    
    frame.Parent = TeleportMenu
    title.Parent = frame
    xInput.Parent = frame
    yInput.Parent = frame
    zInput.Parent = frame
    teleportBtn.Parent = frame
    
    teleportBtn.MouseButton1Click:Connect(function()
        local x = tonumber(xInput.Text)
        local y = tonumber(yInput.Text)
        local z = tonumber(zInput.Text)
        
        if x and y and z and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
            ShowPopup("Успех", string.format("Телепорт к %.1f, %.1f, %.1f", x, y, z), false)
            frame:Destroy()
        else
            ShowPopup("Ошибка", "Некорректные координаты", true)
        end
    end)
end)

-- 2. Телепорт к игроку
CreateButton("Телепорт к игроку", function()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.8, 0, 0.6, 0)
    frame.Position = UDim2.new(0.1, 0, 0.2, 0)
    frame.BackgroundColor3 = ColorScheme.Background
    frame.BackgroundTransparency = 0.1
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.05, 0)
    corner.Parent = frame
    
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
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.9, 0, 0, 50)
            btn.Position = UDim2.new(0.05, 0, 0, 0)
            btn.Text = player.Name
            btn.TextColor3 = ColorScheme.Text
            btn.BackgroundColor3 = ColorScheme.Primary
            btn.BackgroundTransparency = 0.2
            btn.Font = Enum.Font.Gotham
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0.1, 0)
            btnCorner.Parent = btn
            
            SetupButton(btn)
            
            btn.MouseButton1Click:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    localPlayer.Character:MoveTo(player.Character.HumanoidRootPart.Position)
                    ShowPopup("Успех", "Телепорт к "..player.Name, false)
                    frame:Destroy()
                else
                    ShowPopup("Ошибка", "Игрок не найден", true)
                end
            end)
            
            btn.Parent = scrollFrame
        end
    end
    
    -- Обновляем размер прокрутки
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #players * 55)
end)

-- 3. Постоянная телепортация за игроком
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
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.05, 0)
    corner.Parent = frame
    
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
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.9, 0, 0, 50)
            btn.Position = UDim2.new(0.05, 0, 0, 0)
            btn.Text = player.Name
            btn.TextColor3 = ColorScheme.Text
            btn.BackgroundColor3 = ColorScheme.Primary
            btn.BackgroundTransparency = 0.2
            btn.Font = Enum.Font.Gotham
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0.1, 0)
            btnCorner.Parent = btn
            
            SetupButton(btn)
            
            btn.MouseButton1Click:Connect(function()
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
            
            btn.Parent = scrollFrame
        end
    end
    
    -- Обновляем размер прокрутки
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #players * 55)
end)

-- 4. Показать координаты
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
MainFrame.Position = UDim2.new(-0.5, 0, 0.3, 0)
ToggleMenu()
