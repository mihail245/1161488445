--[[
    Многофункциональный мобильный скрипт для Roblox
    Автор: Ассистент
    Версия: 2.0
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Создание основного интерфейса
local MobileMenu = Instance.new("ScreenGui")
MobileMenu.Name = "MobileMenu"
MobileMenu.ResetOnSpawn = false
MobileMenu.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0.35, 0, 0.5, 0)
MainFrame.Position = UDim2.new(0.01, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0.1, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.BackgroundTransparency = 0.2
Title.Text = "Мобильное меню [30 функций]"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Name = "ScrollingFrame"
ScrollingFrame.Size = UDim2.new(1, 0, 0.9, 0)
ScrollingFrame.Position = UDim2.new(0, 0, 0.1, 0)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 5
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 3, 0)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0.1, 0, 0.1, 0)
ToggleButton.Position = UDim2.new(0, 0, 0, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ToggleButton.Text = "≡"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true

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
local selectedPlayer = nil
local playerButtons = {}

-- Функция создания кнопки
local function CreateButton(text, callback)
    local button = Instance.new("TextButton")
    button.Name = text
    button.Size = UDim2.new(0.95, 0, 0, 50)
    button.Position = UDim2.new(0.025, 0, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.BackgroundTransparency = 0.2
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    
    button.MouseButton1Click:Connect(function()
        if not debounce then
            debounce = true
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
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, count * 55)
end

-- Функция показа/скрытия меню
local function ToggleMenu()
    menuVisible = not menuVisible
    if menuVisible then
        MainFrame.Visible = true
        ToggleButton.Text = "≡"
    else
        MainFrame.Visible = false
        ToggleButton.Text = "≡"
    end
end

ToggleButton.MouseButton1Click:Connect(ToggleMenu)

-- Функция создания окна выбора игрока
local function ShowPlayerSelection(title, callback)
    local selectionFrame = Instance.new("Frame")
    selectionFrame.Name = "PlayerSelection"
    selectionFrame.Size = UDim2.new(0.8, 0, 0.7, 0)
    selectionFrame.Position = UDim2.new(0.1, 0, 0.15, 0)
    selectionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    selectionFrame.BackgroundTransparency = 0.1
    
    local selectionTitle = Instance.new("TextLabel")
    selectionTitle.Size = UDim2.new(1, 0, 0.1, 0)
    selectionTitle.Position = UDim2.new(0, 0, 0, 0)
    selectionTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    selectionTitle.Text = title
    selectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    selectionTitle.TextScaled = true
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 0.8, 0)
    scrollFrame.Position = UDim2.new(0, 0, 0.1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 5
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(1, 0, 0.1, 0)
    closeButton.Position = UDim2.new(0, 0, 0.9, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
    closeButton.Text = "Закрыть"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    
    -- Сборка фрейма
    selectionFrame.Parent = MobileMenu
    selectionTitle.Parent = selectionFrame
    scrollFrame.Parent = selectionFrame
    closeButton.Parent = selectionFrame
    
    -- Очистка старых кнопок
    for _, btn in pairs(playerButtons) do
        btn:Destroy()
    end
    playerButtons = {}
    
    -- Создание кнопок игроков
    local players = Players:GetPlayers()
    for i, player in ipairs(players) do
        if player ~= localPlayer then
            local playerButton = Instance.new("TextButton")
            playerButton.Size = UDim2.new(0.95, 0, 0, 50)
            playerButton.Position = UDim2.new(0.025, 0, 0, (i-1)*55)
            playerButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            playerButton.Text = player.Name
            playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerButton.TextScaled = true
            
            playerButton.MouseButton1Click:Connect(function()
                callback(player)
                selectionFrame:Destroy()
            end)
            
            playerButton.Parent = scrollFrame
            table.insert(playerButtons, playerButton)
        end
    end
    
    -- Обновление размера Canvas
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #players * 55)
    
    -- Функция закрытия
    closeButton.MouseButton1Click:Connect(function()
        selectionFrame:Destroy()
    end)
end

-- 1. Телепорт к игроку
CreateButton("Телепорт к игроку", function()
    ShowPlayerSelection("Выберите игрока для телепорта", function(player)
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            localPlayer.Character:MoveTo(player.Character.HumanoidRootPart.Position)
        end
    end)
end)

-- 2. Притянуть игрока
CreateButton("Притянуть игрока", function()
    ShowPlayerSelection("Выберите игрока для притягивания", function(player)
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = localPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, -5)
        end
    end)
end)

-- 3. Оттолкнуть игрока
CreateButton("Оттолкнуть игрока", function()
    ShowPlayerSelection("Выберите игрока для отталкивания", function(player)
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local direction = (player.Character.HumanoidRootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Unit
            player.Character.HumanoidRootPart.Velocity = direction * 100
        end
    end)
end)

-- 4. Подбросить игрока
CreateButton("Подбросить игрока", function()
    ShowPlayerSelection("Выберите игрока для подбрасывания", function(player)
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Velocity = Vector3.new(0, 100, 0)
        end
    end)
end)

-- 5. Заморозить игрока
CreateButton("Заморозить игрока", function()
    ShowPlayerSelection("Выберите игрока для заморозки", function(player)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.PlatformStand = true
        end
    end)
end)

-- 6. Разморозить игрока
CreateButton("Разморозить игрока", function()
    ShowPlayerSelection("Выберите игрока для разморозки", function(player)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.PlatformStand = false
        end
    end)
end)

-- 7. Показать координаты
local coordsEnabled = false
local coordsDisplay = Instance.new("TextLabel")
coordsDisplay.Name = "CoordsDisplay"
coordsDisplay.Size = UDim2.new(0.3, 0, 0.05, 0)
coordsDisplay.Position = UDim2.new(0.35, 0, 0, 0)
coordsDisplay.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
coordsDisplay.BackgroundTransparency = 0.5
coordsDisplay.Text = "X: 0, Y: 0, Z: 0"
coordsDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
coordsDisplay.TextScaled = true
coordsDisplay.Visible = false
coordsDisplay.Parent = MobileMenu

CreateButton("Показать координаты", function()
    coordsEnabled = not coordsEnabled
    coordsDisplay.Visible = coordsEnabled
    
    if coordsEnabled then
        RunService.Heartbeat:Connect(function()
            if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local pos = localPlayer.Character.HumanoidRootPart.Position
                coordsDisplay.Text = string.format("X: %.1f, Y: %.1f, Z: %.1f", pos.X, pos.Y, pos.Z)
            end
        end)
    end
end)

-- 8. Телепорт по координатам
CreateButton("Телепорт по координатам", function()
    local teleportFrame = Instance.new("Frame")
    teleportFrame.Size = UDim2.new(0.8, 0, 0.4, 0)
    teleportFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
    teleportFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    teleportFrame.BackgroundTransparency = 0.1
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.2, 0)
    title.Text = "Введите координаты X Y Z"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    
    local xInput = Instance.new("TextBox")
    xInput.Size = UDim2.new(0.9, 0, 0.2, 0)
    xInput.Position = UDim2.new(0.05, 0, 0.2, 0)
    xInput.PlaceholderText = "X координата"
    xInput.Text = ""
    
    local yInput = Instance.new("TextBox")
    yInput.Size = UDim2.new(0.9, 0, 0.2, 0)
    yInput.Position = UDim2.new(0.05, 0, 0.4, 0)
    yInput.PlaceholderText = "Y координата"
    yInput.Text = ""
    
    local zInput = Instance.new("TextBox")
    zInput.Size = UDim2.new(0.9, 0, 0.2, 0)
    zInput.Position = UDim2.new(0.05, 0, 0.6, 0)
    zInput.PlaceholderText = "Z координата"
    zInput.Text = ""
    
    local teleportButton = Instance.new("TextButton")
    teleportButton.Size = UDim2.new(0.9, 0, 0.2, 0)
    teleportButton.Position = UDim2.new(0.05, 0, 0.8, 0)
    teleportButton.Text = "Телепортироваться"
    teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0.2, 0, 0.2, 0)
    closeButton.Position = UDim2.new(0.8, 0, -0.2, 0)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    -- Сборка интерфейса
    teleportFrame.Parent = MobileMenu
    title.Parent = teleportFrame
    xInput.Parent = teleportFrame
    yInput.Parent = teleportFrame
    zInput.Parent = teleportFrame
    teleportButton.Parent = teleportFrame
    closeButton.Parent = teleportFrame
    
    -- Функция телепортации
    teleportButton.MouseButton1Click:Connect(function()
        local x = tonumber(xInput.Text)
        local y = tonumber(yInput.Text)
        local z = tonumber(zInput.Text)
        
        if x and y and z and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
        end
    end)
    
    -- Функция закрытия
    closeButton.MouseButton1Click:Connect(function()
        teleportFrame:Destroy()
    end)
end)

-- 9. Сохранить позицию
local savedPosition = nil
CreateButton("Сохранить позицию", function()
    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        savedPosition = localPlayer.Character.HumanoidRootPart.CFrame
    end
end)

-- 10. Вернуться к сохраненной позиции
CreateButton("Вернуться к сохран. позиции", function()
    if savedPosition and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        localPlayer.Character.HumanoidRootPart.CFrame = savedPosition
    end
end)

-- 11. Нокаут игрока
CreateButton("Нокаут игрока", function()
    ShowPlayerSelection("Выберите игрока для нокаута", function(player)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        end
    end)
end)

-- 12. Воскресить игрока
CreateButton("Воскресить игрока", function()
    ShowPlayerSelection("Выберите игрока для воскрешения", function(player)
        if player.Character then
            player.Character:BreakJoints()
        end
    end)
end)

-- 13. Установить скорость игрока
CreateButton("Установить скорость", function()
    ShowPlayerSelection("Выберите игрока", function(player)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local speedFrame = Instance.new("Frame")
            speedFrame.Size = UDim2.new(0.8, 0, 0.3, 0)
            speedFrame.Position = UDim2.new(0.1, 0, 0.35, 0)
            speedFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            
            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, 0, 0.3, 0)
            title.Text = "Скорость для "..player.Name
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            local input = Instance.new("TextBox")
            input.Size = UDim2.new(0.9, 0, 0.3, 0)
            input.Position = UDim2.new(0.05, 0, 0.3, 0)
            input.PlaceholderText = "Скорость (16 по умолчанию)"
            input.Text = ""
            
            local setButton = Instance.new("TextButton")
            setButton.Size = UDim2.new(0.9, 0, 0.3, 0)
            setButton.Position = UDim2.new(0.05, 0, 0.6, 0)
            setButton.Text = "Установить"
            setButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            speedFrame.Parent = MobileMenu
            title.Parent = speedFrame
            input.Parent = speedFrame
            setButton.Parent = speedFrame
            
            setButton.MouseButton1Click:Connect(function()
                local speed = tonumber(input.Text) or 16
                player.Character.Humanoid.WalkSpeed = speed
                speedFrame:Destroy()
            end)
        end
    end)
end)

-- 14. Установить прыжок игрока
CreateButton("Установить прыжок", function()
    ShowPlayerSelection("Выберите игрока", function(player)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local jumpFrame = Instance.new("Frame")
            jumpFrame.Size = UDim2.new(0.8, 0, 0.3, 0)
            jumpFrame.Position = UDim2.new(0.1, 0, 0.35, 0)
            jumpFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            
            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, 0, 0.3, 0)
            title.Text = "Высота прыжка для "..player.Name
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            local input = Instance.new("TextBox")
            input.Size = UDim2.new(0.9, 0, 0.3, 0)
            input.Position = UDim2.new(0.05, 0, 0.3, 0)
            input.PlaceholderText = "Высота прыжка (50 по умолчанию)"
            input.Text = ""
            
            local setButton = Instance.new("TextButton")
            setButton.Size = UDim2.new(0.9, 0, 0.3, 0)
            setButton.Position = UDim2.new(0.05, 0, 0.6, 0)
            setButton.Text = "Установить"
            setButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            jumpFrame.Parent = MobileMenu
            title.Parent = jumpFrame
            input.Parent = jumpFrame
            setButton.Parent = jumpFrame
            
            setButton.MouseButton1Click:Connect(function()
                local power = tonumber(input.Text) or 50
                player.Character.Humanoid.JumpPower = power
                jumpFrame:Destroy()
            end)
        end
    end)
end)

-- 15. Получить инструмент
CreateButton("Получить инструмент", function()
    local tool = Instance.new("Tool")
    tool.Name = "CustomTool"
    tool.Parent = localPlayer.Backpack
end)

-- 16. Удалить все инструменты
CreateButton("Удалить инструменты", function()
    for _, item in ipairs(localPlayer.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            item:Destroy()
        end
    end
    
    if localPlayer.Character then
        for _, item in ipairs(localPlayer.Character:GetChildren()) do
            if item:IsA("Tool") then
                item:Destroy()
            end
        end
    end
end)

-- 17. Невидимость
local invisible = false
CreateButton("Переключить невидимость", function()
    invisible = not invisible
    if localPlayer.Character then
        for _, part in ipairs(localPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = invisible and 1 or 0
            end
        end
    end
end)

-- 18. Бессмертие (God mode)
local godMode = false
CreateButton("Переключить бессмертие", function()
    godMode = not godMode
    if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
        localPlayer.Character.Humanoid.MaxHealth = godMode and math.huge or 100
        if godMode then
            localPlayer.Character.Humanoid.Health = math.huge
        end
    end
end)

-- 19. Бесконечный прыжок
local infiniteJump = false
CreateButton("Переключить беск. прыжок", function()
    infiniteJump = not infiniteJump
    if infiniteJump then
        local connection
        connection = UserInputService.JumpRequest:Connect(function()
            if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
                localPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        
        -- Сохраняем соединение для отключения
        CreateButton("Выключить беск. прыжок", function()
            infiniteJump = false
            if connection then
                connection:Disconnect()
            end
        end, true)
    end
end)

-- 20. Полёт
local flying = false
local flySpeed = 50
CreateButton("Переключить полёт", function()
    flying = not flying
    if flying then
        if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
            localPlayer.Character.Humanoid.PlatformStand = true
            
            local bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bg.P = 10000
            bg.D = 1000
            
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = Vector3.new(0, 0, 0)
            
            bg.Parent = localPlayer.Character.HumanoidRootPart
            bv.Parent = localPlayer.Character.HumanoidRootPart
            
            local flyConnection
            flyConnection = RunService.Heartbeat:Connect(function()
                if not flying then
                    flyConnection:Disconnect()
                    bg:Destroy()
                    bv:Destroy()
                    localPlayer.Character.Humanoid.PlatformStand = false
                    return
                end
                
                local cam = workspace.CurrentCamera.CFrame
                local moveVec = Vector3.new()
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveVec = moveVec + cam.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveVec = moveVec - cam.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveVec = moveVec - cam.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveVec = moveVec + cam.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveVec = moveVec + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveVec = moveVec - Vector3.new(0, 1, 0)
                end
                
                if moveVec.Magnitude > 0 then
                    moveVec = moveVec.Unit * flySpeed
                end
                
                bv.Velocity = moveVec
                bg.CFrame = cam
            end)
        end
    else
        if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
            localPlayer.Character.Humanoid.PlatformStand = false
            for _, v in ipairs(localPlayer.Character.HumanoidRootPart:GetChildren()) do
                if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then
                    v:Destroy()
                end
            end
        end
    end
end)

-- 21. Ноклип (NoClip)
local noclip = false
CreateButton("Переключить ноклип", function()
    noclip = not noclip
    if localPlayer.Character then
        for _, part in ipairs(localPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not noclip
            end
        end
    end
end)

-- 22. Копировать внешность
CreateButton("Копировать внешность", function()
    ShowPlayerSelection("Выберите игрока для копирования", function(player)
        if player.Character and localPlayer.Character then
            -- Удаляем текущую внешность
            for _, child in ipairs(localPlayer.Character:GetChildren()) do
                if child:IsA("Accessory") or child:IsA("Shirt") or child:IsA("Pants") or child:IsA("CharacterMesh") then
                    child:Destroy()
                end
            end
            
            -- Копируем внешность
            for _, child in ipairs(player.Character:GetChildren()) do
                if child:IsA("Accessory") or child:IsA("Shirt") or child:IsA("Pants") or child:IsA("CharacterMesh") then
                    local clone = child:Clone()
                    clone.Parent = localPlayer.Character
                end
            end
        end
    end)
end)

-- 23. Спавн машины (пример)
CreateButton("Спавн машины", function()
    local car = Instance.new("Model")
    car.Name = "Car"
    
    local base = Instance.new("Part")
    base.Size = Vector3.new(4, 1, 2)
    base.Position = localPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 0, -5)
    base.Anchored = true
    base.Name = "Base"
    base.Parent = car
    
    local seat = Instance.new("Seat")
    seat.Size = Vector3.new(2, 1, 2)
    seat.Position = base.Position + Vector3.new(0, 1, 0)
    seat.Anchored = false
    seat.Name = "DriverSeat"
    seat.Parent = car
    
    car.Parent = workspace
end)

-- 24. Удалить все машины
CreateButton("Удалить машины", function()
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name == "Car" then
            obj:Destroy()
        end
    end
end)

-- 25. Создать парт для строительства
CreateButton("Создать парт", function()
    local part = Instance.new("Part")
    part.Size = Vector3.new(4, 1, 4)
    part.Position = localPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 0, -5)
    part.Anchored = true
    part.BrickColor = BrickColor.random()
    part.Parent = workspace
end)

-- 26. Удалить все созданные парты
CreateButton("Удалить все парты", function()
    for _, part in ipairs(workspace:GetChildren()) do
        if part:IsA("Part") and part.Name == "Part" then
            part:Destroy()
        end
    end
end)

-- 27. Изменить размер персонажа
CreateButton("Изменить размер", function()
    local sizeFrame = Instance.new("Frame")
    sizeFrame.Size = UDim2.new(0.8, 0, 0.3, 0)
    sizeFrame.Position = UDim2.new(0.1, 0, 0.35, 0)
    sizeFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.3, 0)
    title.Text = "Масштаб персонажа (0.5-5)"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.9, 0, 0.3, 0)
    input.Position = UDim2.new(0.05, 0, 0.3, 0)
    input.PlaceholderText = "Масштаб (1 по умолчанию)"
    input.Text = ""
    
    local setButton = Instance.new("TextButton")
    setButton.Size = UDim2.new(0.9, 0, 0.3, 0)
    setButton.Position = UDim2.new(0.05, 0, 0.6, 0)
    setButton.Text = "Установить"
    setButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    sizeFrame.Parent = MobileMenu
    title.Parent = sizeFrame
    input.Parent = sizeFrame
    setButton.Parent = sizeFrame
    
    setButton.MouseButton1Click:Connect(function()
        local scale = tonumber(input.Text) or 1
        scale = math.clamp(scale, 0.5, 5)
        
        if localPlayer.Character then
            local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ApplyDescription(Players:GetHumanoidDescriptionFromUserId(localPlayer.UserId))
                humanoid.BodyHeightScale.Value = scale
                humanoid.BodyWidthScale.Value = scale
                humanoid.BodyDepthScale.Value = scale
                humanoid.HeadScale.Value = scale
            end
        end
        
        sizeFrame:Destroy()
    end)
end)

-- 28. Создать спавн-точку
CreateButton("Создать спавн-точку", function()
    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local spawn = Instance.new("SpawnLocation")
        spawn.Name = "CustomSpawn"
        spawn.Position = localPlayer.Character.HumanoidRootPart.Position
        spawn.Anchored = true
        spawn.Parent = workspace
    end
end)

-- 29. Удалить все спавн-точки
CreateButton("Удалить спавн-точки", function()
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("SpawnLocation") and obj.Name == "CustomSpawn" then
            obj:Destroy()
        end
    end
end)

-- 30. Создать сообщение в чат
CreateButton("Отправить сообщение", function()
    local chatFrame = Instance.new("Frame")
    chatFrame.Size = UDim2.new(0.8, 0, 0.3, 0)
    chatFrame.Position = UDim2.new(0.1, 0, 0.35, 0)
    chatFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.3, 0)
    title.Text = "Введите сообщение"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.9, 0, 0.3, 0)
    input.Position = UDim2.new(0.05, 0, 0.3, 0)
    input.PlaceholderText = "Текст сообщения"
    input.Text = ""
    
    local sendButton = Instance.new("TextButton")
    sendButton.Size = UDim2.new(0.9, 0, 0.3, 0)
    sendButton.Position = UDim2.new(0.05, 0, 0.6, 0)
    sendButton.Text = "Отправить"
    sendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    chatFrame.Parent = MobileMenu
    title.Parent = chatFrame
    input.Parent = chatFrame
    sendButton.Parent = chatFrame
    
    sendButton.MouseButton1Click:Connect(function()
        if input.Text ~= "" then
            localPlayer:Chat(input.Text)
            chatFrame:Destroy()
        end
    end)
end)

-- Обновляем размер прокручиваемой области
UpdateCanvasSize()
