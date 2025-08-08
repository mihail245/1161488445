--[[
    Персональный мобильный скрипт для Roblox
    Автор: Ассистент
    Версия: 3.0
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Цветовая схема
local ColorScheme = {
    Background = Color3.fromRGB(30, 30, 40),
    Primary = Color3.fromRGB(80, 120, 200),
    Secondary = Color3.fromRGB(60, 90, 150),
    Accent = Color3.fromRGB(100, 200, 255),
    Text = Color3.fromRGB(240, 240, 240),
    Error = Color3.fromRGB(220, 80, 80),
    Success = Color3.fromRGB(80, 220, 120)
}

-- Создание основного интерфейса
local MobileMenu = Instance.new("ScreenGui")
MobileMenu.Name = "MobileMenu"
MobileMenu.ResetOnSpawn = false
MobileMenu.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0.4, 0, 0.6, 0)
MainFrame.Position = UDim2.new(0.01, 0, 0.2, 0)
MainFrame.BackgroundColor3 = ColorScheme.Background
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

-- Скругление углов
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.03, 0)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0.08, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = ColorScheme.Primary
Title.BackgroundTransparency = 0.2
Title.Text = "✦ ПЕРСОНАЛЬНОЕ МЕНЮ ✦"
Title.TextColor3 = ColorScheme.Text
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 0)
UICorner2.Parent = Title

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Name = "ScrollingFrame"
ScrollingFrame.Size = UDim2.new(1, 0, 0.92, 0)
ScrollingFrame.Position = UDim2.new(0, 0, 0.08, 0)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 5
ScrollingFrame.ScrollBarImageColor3 = ColorScheme.Accent
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 3, 0)

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
ToggleButton.Position = UDim2.new(0.01, 0, 0.01, 0)
ToggleButton.BackgroundColor3 = ColorScheme.Primary
ToggleButton.BackgroundTransparency = 0.2
ToggleButton.Image = "rbxassetid://3926305904"
ToggleButton.ImageRectOffset = Vector2.new(124, 204)
ToggleButton.ImageRectSize = Vector2.new(36, 36)
ToggleButton.ImageColor3 = ColorScheme.Text

local UICorner3 = Instance.new("UICorner")
UICorner3.CornerRadius = UDim.new(0.5, 0)
UICorner3.Parent = ToggleButton

-- Анимация наведения
local function SetupButtonHoverEffect(button)
    local originalSize = button.Size
    local originalColor = button.BackgroundColor3
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {Size = originalSize + UDim2.new(0.05, 0, 0.05, 0), BackgroundColor3 = ColorScheme.Accent}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {Size = originalSize, BackgroundColor3 = originalColor}):Play()
    end)
end

-- Сборка интерфейса
MainFrame.Parent = MobileMenu
Title.Parent = MainFrame
ScrollingFrame.Parent = MainFrame
UIListLayout.Parent = ScrollingFrame
ToggleButton.Parent = MobileMenu
MobileMenu.Parent = playerGui

-- Переменные состояния
local menuVisible = true
local debounce = false

-- Функция создания кнопки
local function CreateButton(text, callback, isImportant)
    local button = Instance.new("TextButton")
    button.Name = text
    button.Size = UDim2.new(0.9, 0, 0, 50)
    button.BackgroundColor3 = isImportant and ColorScheme.Secondary or ColorScheme.Primary
    button.BackgroundTransparency = 0.2
    button.Text = text
    button.TextColor3 = ColorScheme.Text
    button.TextScaled = true
    button.Font = Enum.Font.Gotham
    button.AutoButtonColor = false
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0.1, 0)
    buttonCorner.Parent = button
    
    local textPadding = Instance.new("UITextSizeConstraint")
    textPadding.MaxTextSize = 18
    textPadding.Parent = button
    
    SetupButtonHoverEffect(button)
    
    button.MouseButton1Click:Connect(function()
        if not debounce then
            debounce = true
            
            -- Анимация нажатия
            TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = ColorScheme.Accent, TextColor3 = Color3.new(1,1,1)}):Play()
            task.wait(0.1)
            TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = isImportant and ColorScheme.Secondary or ColorScheme.Primary, TextColor3 = ColorScheme.Text}):Play()
            
            callback()
            task.wait(0.2)
            debounce = false
        end
    end)
    
    button.Parent = ScrollingFrame
    return button
end

-- Функция обновления размера Canvas
local function UpdateCanvasSize()
    local count = #ScrollingFrame:GetChildren() - 1
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, count * 58)
end

-- Функция показа/скрытия меню
local function ToggleMenu()
    menuVisible = not menuVisible
    if menuVisible then
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.01, 0, 0.2, 0)}):Play()
        ToggleButton.ImageRectOffset = Vector2.new(124, 204)
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(-0.5, 0, 0.2, 0)}):Play()
        ToggleButton.ImageRectOffset = Vector2.new(964, 324)
    end
end

ToggleButton.MouseButton1Click:Connect(ToggleMenu)

-- Функция создания всплывающего окна
local function CreatePopup(title, message, isError)
    local popup = Instance.new("Frame")
    popup.Name = "Popup"
    popup.Size = UDim2.new(0.8, 0, 0.2, 0)
    popup.Position = UDim2.new(0.1, 0, 0.4, 0)
    popup.BackgroundColor3 = ColorScheme.Background
    popup.BackgroundTransparency = 0.1
    popup.ZIndex = 10
    
    local popupCorner = Instance.new("UICorner")
    popupCorner.CornerRadius = UDim.new(0.05, 0)
    popupCorner.Parent = popup
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.3, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = isError and ColorScheme.Error or ColorScheme.Success
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, 0, 0.5, 0)
    messageLabel.Position = UDim2.new(0, 0, 0.3, 0)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = ColorScheme.Text
    messageLabel.TextScaled = true
    messageLabel.Font = Enum.Font.Gotham
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0.4, 0, 0.2, 0)
    closeButton.Position = UDim2.new(0.3, 0, 0.8, 0)
    closeButton.BackgroundColor3 = isError and ColorScheme.Error or ColorScheme.Success
    closeButton.Text = "OK"
    closeButton.TextColor3 = ColorScheme.Text
    closeButton.Font = Enum.Font.GothamBold
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0.1, 0)
    buttonCorner.Parent = closeButton
    
    popup.Parent = MobileMenu
    titleLabel.Parent = popup
    messageLabel.Parent = popup
    closeButton.Parent = popup
    
    -- Анимация появления
    popup.BackgroundTransparency = 1
    titleLabel.TextTransparency = 1
    messageLabel.TextTransparency = 1
    closeButton.BackgroundTransparency = 1
    closeButton.TextTransparency = 1
    
    TweenService:Create(popup, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(titleLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(messageLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(closeButton, TweenInfo.new(0.3), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
    
    closeButton.MouseButton1Click:Connect(function()
        TweenService:Create(popup, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(titleLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(messageLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(closeButton, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        task.wait(0.3)
        popup:Destroy()
    end)
end

-- 1. Телепорт вперёд
CreateButton("Телепорт вперёд", function()
    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = localPlayer.Character.HumanoidRootPart
        local direction = root.CFrame.LookVector
        root.CFrame = root.CFrame + direction * 10
    end
end)

-- 2. Телепорт вверх
CreateButton("Телепорт вверх", function()
    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = localPlayer.Character.HumanoidRootPart
        root.CFrame = root.CFrame + Vector3.new(0, 50, 0)
    end
end)

-- 3. Сохранить позицию
local savedPosition = nil
CreateButton("Сохранить позицию", function()
    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        savedPosition = localPlayer.Character.HumanoidRootPart.CFrame
        CreatePopup("Успех", "Позиция сохранена!", false)
    end
end)

-- 4. Вернуться к сохранённой позиции
CreateButton("Вернуться к сохранённой позиции", function()
    if savedPosition and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        localPlayer.Character.HumanoidRootPart.CFrame = savedPosition
    else
        CreatePopup("Ошибка", "Позиция не сохранена!", true)
    end
end)

-- 5. Установить спавн-точку (исправленная)
CreateButton("Установить спавн-точку", function()
    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        -- Удаляем старую спавн-точку если есть
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj.Name == "MySpawnPoint" then
                obj:Destroy()
            end
        end
        
        -- Создаём новую спавн-точку
        local spawn = Instance.new("SpawnLocation")
        spawn.Name = "MySpawnPoint"
        spawn.Position = localPlayer.Character.HumanoidRootPart.Position
        spawn.Anchored = true
        spawn.Enabled = true
        spawn.Neutral = false
        spawn.TeamColor = localPlayer.TeamColor
        spawn.Transparency = 0.5
        spawn.CanCollide = false
        spawn.Parent = workspace
        
        -- Делаем её вашей точкой возрождения
        localPlayer.RespawnLocation = spawn
        
        CreatePopup("Успех", "Спавн-точка установлена!", false)
    end
end)

-- 6. Удалить спавн-точку
CreateButton("Удалить спавн-точку", function()
    local found = false
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name == "MySpawnPoint" then
            obj:Destroy()
            found = true
        end
    end
    
    if found then
        localPlayer.RespawnLocation = nil
        CreatePopup("Успех", "Спавн-точка удалена!", false)
    else
        CreatePopup("Ошибка", "Спавн-точка не найдена!", true)
    end
end)

-- 7. Отправить сообщение (исправленная)
CreateButton("Отправить сообщение", function()
    local chatFrame = Instance.new("Frame")
    chatFrame.Size = UDim2.new(0.8, 0, 0.3, 0)
    chatFrame.Position = UDim2.new(0.1, 0, 0.35, 0)
    chatFrame.BackgroundColor3 = ColorScheme.Background
    chatFrame.BackgroundTransparency = 0.1
    chatFrame.ZIndex = 10
    
    local chatCorner = Instance.new("UICorner")
    chatCorner.CornerRadius = UDim.new(0.05, 0)
    chatCorner.Parent = chatFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.2, 0)
    title.Text = "Введите сообщение"
    title.TextColor3 = ColorScheme.Accent
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.9, 0, 0.4, 0)
    input.Position = UDim2.new(0.05, 0, 0.2, 0)
    input.PlaceholderText = "Текст сообщения..."
    input.Text = ""
    input.TextColor3 = ColorScheme.Text
    input.BackgroundColor3 = ColorScheme.Primary
    input.BackgroundTransparency = 0.3
    input.ClearTextOnFocus = false
    input.Font = Enum.Font.Gotham
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0.05, 0)
    inputCorner.Parent = input
    
    local sendButton = Instance.new("TextButton")
    sendButton.Size = UDim2.new(0.4, 0, 0.2, 0)
    sendButton.Position = UDim2.new(0.3, 0, 0.7, 0)
    sendButton.Text = "Отправить"
    sendButton.TextColor3 = ColorScheme.Text
    sendButton.Font = Enum.Font.GothamBold
    sendButton.BackgroundColor3 = ColorScheme.Accent
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0.1, 0)
    buttonCorner.Parent = sendButton
    
    chatFrame.Parent = MobileMenu
    title.Parent = chatFrame
    input.Parent = chatFrame
    sendButton.Parent = chatFrame
    
    -- Анимация появления
    chatFrame.BackgroundTransparency = 1
    title.TextTransparency = 1
    input.BackgroundTransparency = 1
    input.TextTransparency = 1
    sendButton.BackgroundTransparency = 1
    sendButton.TextTransparency = 1
    
    TweenService:Create(chatFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(input, TweenInfo.new(0.3), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
    TweenService:Create(sendButton, TweenInfo.new(0.3), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
    
    -- Функция отправки
    sendButton.MouseButton1Click:Connect(function()
        if input.Text ~= "" then
            local success, err = pcall(function()
                localPlayer:Chat(input.Text)
            end)
            
            if success then
                TweenService:Create(chatFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                TweenService:Create(input, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
                TweenService:Create(sendButton, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
                task.wait(0.3)
                chatFrame:Destroy()
            else
                CreatePopup("Ошибка", "Не удалось отправить сообщение", true)
            end
        end
    end)
    
    -- Закрытие при клике вне окна
    local closeConnection
    closeConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not processed then
            local mousePos = UserInputService:GetMouseLocation()
            local framePos = chatFrame.AbsolutePosition
            local frameSize = chatFrame.AbsoluteSize
            
            if mousePos.X < framePos.X or mousePos.X > framePos.X + frameSize.X or
               mousePos.Y < framePos.Y or mousePos.Y > framePos.Y + frameSize.Y then
                closeConnection:Disconnect()
                TweenService:Create(chatFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                TweenService:Create(input, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
                TweenService:Create(sendButton, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
                task.wait(0.3)
                chatFrame:Destroy()
            end
        end
    end)
end)

-- 8. Показать координаты
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
coordsDisplay.Visible = false
coordsDisplay.Font = Enum.Font.GothamBold

local coordsCorner = Instance.new("UICorner")
coordsCorner.CornerRadius = UDim.new(0.1, 0)
coordsCorner.Parent = coordsDisplay

coordsDisplay.Parent = MobileMenu

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

-- 9. Невидимость
local invisible = false
CreateButton("Переключить невидимость", function()
    invisible = not invisible
    if localPlayer.Character then
        for _, part in ipairs(localPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = invisible and 1 or 0
                if part:IsA("MeshPart") or part:IsA("Part") then
                    part.LocalTransparencyModifier = invisible and 1 or 0
                end
            end
        end
        CreatePopup("Успех", "Невидимость: " .. (invisible and "ВКЛ" or "ВЫКЛ"), false)
    end
end)

-- 10. Бессмертие
local godMode = false
CreateButton("Переключить бессмертие", function()
    godMode = not godMode
    if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
        localPlayer.Character.Humanoid.MaxHealth = godMode and math.huge or 100
        if godMode then
            localPlayer.Character.Humanoid.Health = math.huge
        end
        CreatePopup("Успех", "Бессмертие: " .. (godMode and "ВКЛ" or "ВЫКЛ"), false)
    end
end)

-- 11. Ноклип
local noclip = false
local noclipConnection
CreateButton("Переключить ноклип", function()
    noclip = not noclip
    if noclip then
        if localPlayer.Character then
            for _, part in ipairs(localPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            
            noclipConnection = RunService.Stepped:Connect(function()
                if localPlayer.Character and noclip then
                    for _, part in ipairs(localPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                else
                    noclipConnection:Disconnect()
                end
            end)
        end
    else
        if noclipConnection then
            noclipConnection:Disconnect()
        end
        if localPlayer.Character then
            for _, part in ipairs(localPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
    CreatePopup("Успех", "Ноклип: " .. (noclip and "ВКЛ" or "ВЫКЛ"), false)
end)

-- 12. Бесконечный прыжок
local infiniteJump = false
local jumpConnection
CreateButton("Переключить беск. прыжок", function()
    infiniteJump = not infiniteJump
    if infiniteJump then
        jumpConnection = UserInputService.JumpRequest:Connect(function()
            if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
                localPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if jumpConnection then
            jumpConnection:Disconnect()
        end
    end
    CreatePopup("Успех", "Беск. прыжок: " .. (infiniteJump and "ВКЛ" or "ВЫКЛ"), false)
end)

-- 13. Полёт
local flying = false
local flySpeed = 50
local bg, bv, flyConnection
CreateButton("Переключить полёт", function()
    flying = not flying
    if flying then
        if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            localPlayer.Character.Humanoid.PlatformStand = true
            
            bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bg.P = 10000
            bg.D = 1000
            
            bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = Vector3.new(0, 0, 0)
            
            bg.Parent = localPlayer.Character.HumanoidRootPart
            bv.Parent = localPlayer.Character.HumanoidRootPart
            
            flyConnection = RunService.Heartbeat:Connect(function()
                if not flying or not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    if flyConnection then flyConnection:Disconnect() end
                    return
                end
                
                local cam = workspace.CurrentCamera.CFrame
                local moveVec = Vector3.new()
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + cam.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - cam.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - cam.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + cam.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVec = moveVec + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVec = moveVec - Vector3.new(0, 1, 0) end
                
                if moveVec.Magnitude > 0 then
                    moveVec = moveVec.Unit * flySpeed
                end
                
                bv.Velocity = moveVec
                bg.CFrame = cam
            end)
        end
    else
        if flyConnection then flyConnection:Disconnect() end
        if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
            localPlayer.Character.Humanoid.PlatformStand = false
            if bg then bg:Destroy() end
            if bv then bv:Destroy() end
        end
    end
    CreatePopup("Успех", "Полёт: " .. (flying and "ВКЛ" or "ВЫКЛ"), false)
end)

-- 14. Установить скорость
CreateButton("Установить скорость", function()
    local speedFrame = Instance.new("Frame")
    speedFrame.Size = UDim2.new(0.8, 0, 0.25, 0)
    speedFrame.Position = UDim2.new(0.1, 0, 0.375, 0)
    speedFrame.BackgroundColor3 = ColorScheme.Background
    speedFrame.BackgroundTransparency = 0.1
    speedFrame.ZIndex = 10
    
    local speedCorner = Instance.new("UICorner")
    speedCorner.CornerRadius = UDim.new(0.05, 0)
    speedCorner.Parent = speedFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.3, 0)
    title.Text = "Скорость передвижения"
    title.TextColor3 = ColorScheme.Accent
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.9, 0, 0.3, 0)
    input.Position = UDim2.new(0.05, 0, 0.3, 0)
    input.PlaceholderText = "Скорость (16 по умолчанию)"
    input.Text = ""
    input.TextColor3 = ColorScheme.Text
    input.BackgroundColor3 = ColorScheme.Primary
    input.BackgroundTransparency = 0.3
    input.ClearTextOnFocus = false
    input.Font = Enum.Font.Gotham
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0.05, 0)
    inputCorner.Parent = input
    
    local setButton = Instance.new("TextButton")
    setButton.Size = UDim2.new(0.4, 0, 0.2, 0)
    setButton.Position = UDim2.new(0.3, 0, 0.7, 0)
    setButton.Text = "Установить"
    setButton.TextColor3 = ColorScheme.Text
    setButton.Font = Enum.Font.GothamBold
    setButton.BackgroundColor3 = ColorScheme.Accent
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0.1, 0)
    buttonCorner.Parent = setButton
    
    speedFrame.Parent = MobileMenu
    title.Parent = speedFrame
    input.Parent = speedFrame
    setButton.Parent = speedFrame
    
    -- Анимация появления
    speedFrame.BackgroundTransparency = 1
    title.TextTransparency = 1
    input.BackgroundTransparency = 1
    input.TextTransparency = 1
    setButton.BackgroundTransparency = 1
    setButton.TextTransparency = 1
    
    TweenService:Create(speedFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(input, TweenInfo.new(0.3), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
    TweenService:Create(setButton, TweenInfo.new(0.3), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
    
    setButton.MouseButton1Click:Connect(function()
        local speed = tonumber(input.Text) or 16
        if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
            localPlayer.Character.Humanoid.WalkSpeed = speed
            CreatePopup("Успех", "Скорость установлена: "..speed, false)
            
            TweenService:Create(speedFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            TweenService:Create(input, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
            TweenService:Create(setButton, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
            task.wait(0.3)
            speedFrame:Destroy()
        end
    end)
    
    -- Закрытие при клике вне окна
    local closeConnection
    closeConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not processed then
            local mousePos = UserInputService:GetMouseLocation()
            local framePos = speedFrame.AbsolutePosition
            local frameSize = speedFrame.AbsoluteSize
            
            if mousePos.X < framePos.X or mousePos.X > framePos.X + frameSize.X or
               mousePos.Y < framePos.Y or mousePos.Y > framePos.Y + frameSize.Y then
                closeConnection:Disconnect()
                TweenService:Create(speedFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                TweenService:Create(input, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
                TweenService:Create(setButton, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
                task.wait(0.3)
                speedFrame:Destroy()
            end
        end
    end)
end)

-- 15. Установить высоту прыжка
CreateButton("Установить прыжок", function()
    local jumpFrame = Instance.new("Frame")
    jumpFrame.Size = UDim2.new(0.8, 0, 0.25, 0)
    jumpFrame.Position = UDim2.new(0.1, 0, 0.375, 0)
    jumpFrame.BackgroundColor3 = ColorScheme.Background
    jumpFrame.BackgroundTransparency = 0.1
    jumpFrame.ZIndex = 10
    
    local jumpCorner = Instance.new("UICorner")
    jumpCorner.CornerRadius = UDim.new(0.05, 0)
    jumpCorner.Parent = jumpFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.3, 0)
    title.Text = "Высота прыжка"
    title.TextColor3 = ColorScheme.Accent
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.9, 0, 0.3, 0)
    input.Position = UDim2.new(0.05, 0, 0.3, 0)
    input.PlaceholderText = "Высота (50 по умолчанию)"
    input.Text = ""
    input.TextColor3 = ColorScheme.Text
    input.BackgroundColor3 = ColorScheme.Primary
    input.BackgroundTransparency = 0.3
    input.ClearTextOnFocus = false
    input.Font = Enum.Font.Gotham
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0.05, 0)
    inputCorner.Parent = input
    
    local setButton = Instance.new("TextButton")
    setButton.Size = UDim2.new(0.4, 0, 0.2, 0)
    setButton.Position = UDim2.new(0.3, 0, 0.7, 0)
    setButton.Text = "Установить"
    setButton.TextColor3 = ColorScheme.Text
    setButton.Font = Enum.Font.GothamBold
    setButton.BackgroundColor3 = ColorScheme.Accent
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0.1, 0)
    buttonCorner.Parent = setButton
    
    jumpFrame.Parent = MobileMenu
    title.Parent = jumpFrame
    input.Parent = jumpFrame
    setButton.Parent = jumpFrame
    
    -- Анимация появления
    jumpFrame.BackgroundTransparency = 1
    title.TextTransparency = 1
    input.BackgroundTransparency = 1
    input.TextTransparency = 1
    setButton.BackgroundTransparency = 1
    setButton.TextTransparency = 1
    
    TweenService:Create(jumpFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(input, TweenInfo.new(0.3), {BackgroundTransparency = 0.3, TextTransparency = 0}):Play()
    TweenService:Create(setButton, TweenInfo.new(0.3), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
    
    setButton.MouseButton1Click:Connect(function()
        local power = tonumber(input.Text) or 50
        if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
            localPlayer.Character.Humanoid.JumpPower = power
            CreatePopup("Успех", "Высота прыжка установлена: "..power, false)
            
            TweenService:Create(jumpFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            TweenService:Create(input, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
            TweenService:Create(setButton, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
            task.wait(0.3)
            jumpFrame:Destroy()
        end
    end)
    
    -- Закрытие при клике вне окна
    local closeConnection
    closeConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not processed then
            local mousePos = UserInputService:GetMouseLocation()
            local framePos = jumpFrame.AbsolutePosition
            local frameSize = jumpFrame.AbsoluteSize
            
            if mousePos.X < framePos.X or mousePos.X > framePos.X + frameSize.X or
               mousePos.Y < framePos.Y or mousePos.Y > framePos.Y + frameSize.Y then
                closeConnection:Disconnect()
                TweenService:Create(jumpFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                TweenService:Create(input, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
                TweenService:Create(setButton, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
                task.wait(0.3)
                jumpFrame:Destroy()
            end
        end
    end)
end)

-- Обновляем размер прокручиваемой области
UpdateCanvasSize()

-- Анимация появления меню
MainFrame.Position = UDim2.new(-0.5, 0, 0.2, 0)
ToggleMenu()
