-- Teleport System with Stylish UI
-- Version 1.0

local teleportSystem = {
    savedPoints = {},
    config = {
        followPlayer = nil,
        followInterval = 1000, -- ms
        uiColor = {r = 0.2, g = 0.6, b = 0.9, a = 0.8},
        uiAnimSpeed = 0.3,
        notificationsEnabled = true
    },
    ui = {
        mainWindow = nil,
        isMinimized = false,
        isVisible = true
    }
}

-- Animation functions
local function animateElement(element, targetProps, duration, callback)
    local startTime = getTickCount()
    local initialProps = {}
    
    for prop, value in pairs(targetProps) do
        initialProps[prop] = guiGetProperty(element, prop)
    end
    
    local function updateAnimation()
        local progress = (getTickCount() - startTime) / duration
        if progress > 1 then progress = 1 end
        
        for prop, targetValue in pairs(targetProps) do
            local initialValue = initialProps[prop]
            local newValue = initialValue + (targetValue - initialValue) * progress
            guiSetProperty(element, prop, tostring(newValue))
        end
        
        if progress == 1 then
            removeEventHandler("onClientRender", root, updateAnimation)
            if callback then callback() end
        end
    end
    
    addEventHandler("onClientRender", root, updateAnimation)
end

-- Notification system
local function showNotification(message, isError)
    if not teleportSystem.config.notificationsEnabled then return end
    
    local notification = guiCreateLabel(0.8, 0.05, 0.18, 0.05, message, true)
    guiSetProperty(notification, "AlwaysOnTop", "True")
    guiSetProperty(notification, "TextColour", isError and "FFFF0000" or "FF00FF00")
    guiSetAlpha(notification, 0)
    
    animateElement(notification, {Alpha = 1}, 300, function()
        setTimer(function()
            animateElement(notification, {Alpha = 0}, 300, function()
                destroyElement(notification)
            end)
        end, 3000, 1)
    end)
end

-- Coordinate functions
local function getPlayerCoordinates()
    local x, y, z = getElementPosition(localPlayer)
    return x, y, z
end

local function formatCoordinates(x, y, z)
    return string.format("%.2f, %.2f, %.2f", x, y, z)
end

-- Teleport functions
local function teleportToCoordinates(x, y, z)
    if not x or not y or not z then
        showNotification("Invalid coordinates!", true)
        return false
    end
    
    if setElementPosition(localPlayer, x, y, z) then
        showNotification("Teleported successfully!")
        return true
    else
        showNotification("Teleport failed!", true)
        return false
    end
end

local function teleportToPlayer(targetPlayer)
    if not isElement(targetPlayer) then
        showNotification("Player not found!", true)
        return false
    end
    
    local x, y, z = getElementPosition(targetPlayer)
    return teleportToCoordinates(x, y, z)
end

local function startFollowingPlayer(targetPlayer)
    if teleportSystem.config.followPlayer == targetPlayer then
        teleportSystem.config.followPlayer = nil
        showNotification("Stopped following player")
        return
    end
    
    teleportSystem.config.followPlayer = targetPlayer
    showNotification("Now following " .. getPlayerName(targetPlayer))
    
    -- Create follow loop if not already running
    if not teleportSystem.followTimer then
        teleportSystem.followTimer = setTimer(function()
            if teleportSystem.config.followPlayer and isElement(teleportSystem.config.followPlayer) then
                teleportToPlayer(teleportSystem.config.followPlayer)
            else
                if isTimer(teleportSystem.followTimer) then
                    killTimer(teleportSystem.followTimer)
                    teleportSystem.followTimer = nil
                end
                teleportSystem.config.followPlayer = nil
                showNotification("Stopped following (player left)", true)
            end
        end, teleportSystem.config.followInterval, 0)
    end
end

-- Saved points management
local function saveCurrentPosition(pointName)
    if not pointName or pointName == "" then
        showNotification("Point name cannot be empty!", true)
        return false
    end
    
    if teleportSystem.savedPoints[pointName] then
        showNotification("Point name already exists!", true)
        return false
    end
    
    local x, y, z = getPlayerCoordinates()
    teleportSystem.savedPoints[pointName] = {x = x, y = y, z = z}
    
    showNotification("Point '" .. pointName .. "' saved successfully!")
    return true
end

local function deleteSavedPoint(pointName)
    if not teleportSystem.savedPoints[pointName] then
        showNotification("Point not found!", true)
        return false
    end
    
    teleportSystem.savedPoints[pointName] = nil
    showNotification("Point '" .. pointName .. "' deleted")
    return true
end

local function teleportToSavedPoint(pointName)
    local point = teleportSystem.savedPoints[pointName]
    if not point then
        showNotification("Point not found!", true)
        return false
    end
    
    return teleportToCoordinates(point.x, point.y, point.z)
end

-- UI functions
local function createMainWindow()
    -- Main window
    teleportSystem.ui.mainWindow = guiCreateWindow(0.7, 0.25, 0.28, 0.5, "Teleport System v1.0", true)
    guiSetProperty(teleportSystem.ui.mainWindow, "AlwaysOnTop", "True")
    guiSetProperty(teleportSystem.ui.mainWindow, "Alpha", tostring(teleportSystem.config.uiColor.a))
    guiWindowSetSizable(teleportSystem.ui.mainWindow, false)
    
    -- Tab panel
    local tabPanel = guiCreateTabPanel(0.02, 0.05, 0.96, 0.9, true, teleportSystem.ui.mainWindow)
    
    -- Teleport tab
    local teleportTab = guiCreateTab("Teleport", tabPanel)
    
    -- Coordinates section
    local coordLabel = guiCreateLabel(0.05, 0.05, 0.9, 0.05, "Current coordinates: " .. formatCoordinates(getPlayerCoordinates()), true, teleportTab)
    guiLabelSetHorizontalAlign(coordLabel, "center")
    
    -- Manual teleport section
    local manualTeleportLabel = guiCreateLabel(0.05, 0.12, 0.9, 0.05, "Manual Teleport", true, teleportTab)
    guiSetFont(manualTeleportLabel, "default-bold-small")
    
    local xEdit = guiCreateEdit(0.05, 0.18, 0.28, 0.07, "X", true, teleportTab)
    local yEdit = guiCreateEdit(0.35, 0.18, 0.28, 0.07, "Y", true, teleportTab)
    local zEdit = guiCreateEdit(0.65, 0.18, 0.28, 0.07, "Z", true, teleportTab)
    
    local teleportButton = guiCreateButton(0.05, 0.27, 0.9, 0.08, "Teleport to Coordinates", true, teleportTab)
    
    -- Player teleport section
    local playerTeleportLabel = guiCreateLabel(0.05, 0.37, 0.9, 0.05, "Teleport to Player", true, teleportTab)
    guiSetFont(playerTeleportLabel, "default-bold-small")
    
    local playerGrid = guiCreateGridList(0.05, 0.43, 0.9, 0.3, true, teleportTab)
    guiGridListAddColumn(playerGrid, "Player", 0.8)
    
    local teleportToPlayerButton = guiCreateButton(0.05, 0.74, 0.44, 0.08, "Teleport to Player", true, teleportTab)
    local followPlayerButton = guiCreateButton(0.51, 0.74, 0.44, 0.08, "Toggle Follow", true, teleportTab)
    
    -- Saved points tab
    local savedPointsTab = guiCreateTab("Saved Points", tabPanel)
    
    local savedPointsLabel = guiCreateLabel(0.05, 0.05, 0.9, 0.05, "Saved Teleport Points", true, savedPointsTab)
    guiSetFont(savedPointsLabel, "default-bold-small")
    
    local pointsGrid = guiCreateGridList(0.05, 0.12, 0.9, 0.6, true, savedPointsTab)
    guiGridListAddColumn(pointsGrid, "Point Name", 0.6)
    guiGridListAddColumn(pointsGrid, "Coordinates", 0.4)
    
    local saveCurrentButton = guiCreateButton(0.05, 0.74, 0.44, 0.08, "Save Current Position", true, savedPointsTab)
    local deletePointButton = guiCreateButton(0.51, 0.74, 0.44, 0.08, "Delete Selected", true, savedPointsTab)
    
    local pointNameEdit = guiCreateEdit(0.05, 0.83, 0.9, 0.07, "Point Name", true, savedPointsTab)
    
    -- Settings tab
    local settingsTab = guiCreateTab("Settings", tabPanel)
    
    local colorLabel = guiCreateLabel(0.05, 0.05, 0.9, 0.05, "UI Color", true, settingsTab)
    guiSetFont(colorLabel, "default-bold-small")
    
    local colorRed = guiCreateEdit(0.05, 0.12, 0.28, 0.07, tostring(teleportSystem.config.uiColor.r * 255), true, settingsTab)
    local colorGreen = guiCreateEdit(0.35, 0.12, 0.28, 0.07, tostring(teleportSystem.config.uiColor.g * 255), true, settingsTab)
    local colorBlue = guiCreateEdit(0.65, 0.12, 0.28, 0.07, tostring(teleportSystem.config.uiColor.b * 255), true, settingsTab)
    
    local applyColorButton = guiCreateButton(0.05, 0.22, 0.9, 0.08, "Apply Color", true, settingsTab)
    
    local notificationsCheckbox = guiCreateCheckBox(0.05, 0.32, 0.9, 0.06, "Enable Notifications", teleportSystem.config.notificationsEnabled, true, settingsTab)
    
    -- Minimize button
    local minimizeButton = guiCreateButton(0.9, 0.02, 0.08, 0.04, "-", true, teleportSystem.ui.mainWindow)
    guiSetProperty(minimizeButton, "AlwaysOnTop", "True")
    
    -- Update UI colors
    local function updateUIColor()
        local color = teleportSystem.config.uiColor
        local colorHex = string.format("FF%02X%02X%02X", 
            math.floor(color.r * 255), 
            math.floor(color.g * 255), 
            math.floor(color.b * 255))
        
        guiSetProperty(teleportSystem.ui.mainWindow, "CaptionColour", colorHex)
        
        for _, element in ipairs(getElementChildren(teleportSystem.ui.mainWindow)) do
            if getElementType(element) == "gui-tabpanel" then
                guiSetProperty(element, "TabTextColour", colorHex)
                guiSetProperty(element, "TabSelectedTextColour", colorHex)
            elseif getElementType(element) == "gui-button" then
                guiSetProperty(element, "NormalTextColour", colorHex)
                guiSetProperty(element, "HoverTextColour", "FFFFFFFF")
            end
        end
    end
    
    updateUIColor()
    
    -- Button hover effects
    local function setupButtonHover(button)
        local originalTextColor = guiGetProperty(button, "NormalTextColour")
        
        addEventHandler("onClientMouseEnter", button, function()
            animateElement(button, {Alpha = 1}, teleportSystem.config.uiAnimSpeed)
            guiSetProperty(button, "NormalTextColour", "FFFFFFFF")
        end, false)
        
        addEventHandler("onClientMouseLeave", button, function()
            animateElement(button, {Alpha = teleportSystem.config.uiColor.a}, teleportSystem.config.uiAnimSpeed)
            guiSetProperty(button, "NormalTextColour", originalTextColor)
        end, false)
    end
    
    -- Apply hover effects to all buttons
    for _, element in ipairs(getElementChildren(teleportTab)) do
        if getElementType(element) == "gui-button" then
            setupButtonHover(element)
        end
    end
    
    for _, element in ipairs(getElementChildren(savedPointsTab)) do
        if getElementType(element) == "gui-button" then
            setupButtonHover(element)
        end
    end
    
    for _, element in ipairs(getElementChildren(settingsTab)) do
        if getElementType(element) == "gui-button" then
            setupButtonHover(element)
        end
    end
    
    setupButtonHover(minimizeButton)
    
    -- Update player list
    local function updatePlayerList()
        guiGridListClear(playerGrid)
        
        for _, player in ipairs(getElementsByType("player")) do
            if player ~= localPlayer then
                local row = guiGridListAddRow(playerGrid)
                guiGridListSetItemText(playerGrid, row, 1, getPlayerName(player), false, false)
                guiGridListSetItemData(playerGrid, row, 1, player)
            end
        end
    end
    
    -- Update saved points list
    local function updateSavedPointsList()
        guiGridListClear(pointsGrid)
        
        for name, coords in pairs(teleportSystem.savedPoints) do
            local row = guiGridListAddRow(pointsGrid)
            guiGridListSetItemText(pointsGrid, row, 1, name, false, false)
            guiGridListSetItemText(pointsGrid, row, 2, formatCoordinates(coords.x, coords.y, coords.z), false, false)
            guiGridListSetItemData(pointsGrid, row, 1, name)
        end
    end
    
    -- Update coordinates display
    local function updateCoordinatesDisplay()
        guiSetText(coordLabel, "Current coordinates: " .. formatCoordinates(getPlayerCoordinates()))
    end
    
    -- Event handlers
    addEventHandler("onClientGUIClick", teleportButton, function()
        local x = tonumber(guiGetText(xEdit))
        local y = tonumber(guiGetText(yEdit))
        local z = tonumber(guiGetText(zEdit))
        
        teleportToCoordinates(x, y, z)
    end, false)
    
    addEventHandler("onClientGUIClick", teleportToPlayerButton, function()
        local selectedRow = guiGridListGetSelectedItem(playerGrid)
        if selectedRow == -1 then return end
        
        local player = guiGridListGetItemData(playerGrid, selectedRow, 1)
        teleportToPlayer(player)
    end, false)
    
    addEventHandler("onClientGUIClick", followPlayerButton, function()
        local selectedRow = guiGridListGetSelectedItem(playerGrid)
        if selectedRow == -1 then return end
        
        local player = guiGridListGetItemData(playerGrid, selectedRow, 1)
        startFollowingPlayer(player)
    end, false)
    
    addEventHandler("onClientGUIClick", saveCurrentButton, function()
        local pointName = guiGetText(pointNameEdit)
        if saveCurrentPosition(pointName) then
            updateSavedPointsList()
        end
    end, false)
    
    addEventHandler("onClientGUIClick", deletePointButton, function()
        local selectedRow = guiGridListGetSelectedItem(pointsGrid)
        if selectedRow == -1 then return end
        
        local pointName = guiGridListGetItemData(pointsGrid, selectedRow, 1)
        if deleteSavedPoint(pointName) then
            updateSavedPointsList()
        end
    end, false)
    
    addEventHandler("onClientGUIClick", pointsGrid, function(button, state)
        if button == "left" and state == "up" then
            local selectedRow = guiGridListGetSelectedItem(pointsGrid)
            if selectedRow == -1 then return end
            
            local pointName = guiGridListGetItemData(pointsGrid, selectedRow, 1)
            teleportToSavedPoint(pointName)
        end
    end, false)
    
    addEventHandler("onClientGUIClick", applyColorButton, function()
        local r = tonumber(guiGetText(colorRed)) or 0
        local g = tonumber(guiGetText(colorGreen)) or 0
        local b = tonumber(guiGetText(colorBlue)) or 0
        
        teleportSystem.config.uiColor.r = math.min(math.max(r / 255, 0), 1)
        teleportSystem.config.uiColor.g = math.min(math.max(g / 255, 0), 1)
        teleportSystem.config.uiColor.b = math.min(math.max(b / 255, 0), 1)
        
        updateUIColor()
        showNotification("UI color updated!")
    end, false)
    
    addEventHandler("onClientGUIClick", notificationsCheckbox, function()
        teleportSystem.config.notificationsEnabled = guiCheckBoxGetSelected(notificationsCheckbox)
    end, false)
    
    addEventHandler("onClientGUIClick", minimizeButton, function()
        if teleportSystem.ui.isMinimized then
            -- Restore
            guiSetSize(teleportSystem.ui.mainWindow, 0.28, 0.5, true)
            guiSetText(minimizeButton, "-")
            teleportSystem.ui.isMinimized = false
        else
            -- Minimize
            guiSetSize(teleportSystem.ui.mainWindow, 0.28, 0.05, true)
            guiSetText(minimizeButton, "+")
            teleportSystem.ui.isMinimized = true
        end
    end, false)
    
    -- Update lists initially
    updatePlayerList()
    updateSavedPointsList()
    
    -- Set up periodic updates
    setTimer(updatePlayerList, 5000, 0)
    setTimer(updateCoordinatesDisplay, 1000, 0)
end

-- Toggle UI visibility
local function toggleTeleportUI()
    teleportSystem.ui.isVisible = not teleportSystem.ui.isVisible
    guiSetVisible(teleportSystem.ui.mainWindow, teleportSystem.ui.isVisible)
    
    if teleportSystem.ui.isVisible then
        showNotification("Teleport system activated")
    else
        showNotification("Teleport system hidden")
    end
end

-- Initialize the system
local function initTeleportSystem()
    createMainWindow()
    
    -- Bind key to toggle UI (F5 by default)
    bindKey("F5", "down", toggleTeleportUI)
    
    showNotification("Teleport system loaded! Press F5 to open/close.")
end

-- Start the system when resource starts
addEventHandler("onClientResourceStart", resourceRoot, initTeleportSystem)
