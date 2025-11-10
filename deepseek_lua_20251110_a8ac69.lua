--// Roblox Game Explorer / Spy Tool
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

print("=== ROBOX GAME EXPLORER LOADED ===")

-- Exploration state
local ExplorerState = {
    currentPath = {"game"},
    selectedObject = nil,
    autoRefresh = false,
    showProperties = false,
    searchTerm = ""
}

-- Create the main explorer UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GameExplorer"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

-- Main container
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 600, 0, 500)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Game Explorer - Spy Tool"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0, 2)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 12
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeButton

-- Search box
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(0.7, 0, 0, 25)
searchBox.Position = UDim2.new(0, 10, 0, 35)
searchBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.PlaceholderText = "Search objects... (by name or class)"
searchBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 12
searchBox.Parent = mainFrame

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 4)
searchCorner.Parent = searchBox

-- Control buttons frame
local controlsFrame = Instance.new("Frame")
controlsFrame.Size = UDim2.new(0.28, 0, 0, 25)
controlsFrame.Position = UDim2.new(0.72, 0, 0, 35)
controlsFrame.BackgroundTransparency = 1
controlsFrame.Parent = mainFrame

-- Refresh button
local refreshButton = Instance.new("TextButton")
refreshButton.Size = UDim2.new(0.3, 0, 1, 0)
refreshButton.Position = UDim2.new(0, 0, 0, 0)
refreshButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
refreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshButton.Text = "Refresh"
refreshButton.Font = Enum.Font.Gotham
refreshButton.TextSize = 11
refreshButton.Parent = controlsFrame

-- Auto refresh toggle
local autoRefreshButton = Instance.new("TextButton")
autoRefreshButton.Size = UDim2.new(0.3, 0, 1, 0)
autoRefreshButton.Position = UDim2.new(0.35, 0, 0, 0)
autoRefreshButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
autoRefreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoRefreshButton.Text = "Auto: OFF"
autoRefreshButton.Font = Enum.Font.Gotham
autoRefreshButton.TextSize = 11
autoRefreshButton.Parent = controlsFrame

-- Properties toggle
local propsButton = Instance.new("TextButton")
propsButton.Size = UDim2.new(0.3, 0, 1, 0)
propsButton.Position = UDim2.new(0.7, 0, 0, 0)
propsButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
propsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
propsButton.Text = "Props: OFF"
propsButton.Font = Enum.Font.Gotham
propsButton.TextSize = 11
propsButton.Parent = controlsFrame

-- Add corners to control buttons
local controlCorner = Instance.new("UICorner")
controlCorner.CornerRadius = UDim.new(0, 4)
controlCorner:Clone().Parent = refreshButton
controlCorner:Clone().Parent = autoRefreshButton
controlCorner:Clone().Parent = propsButton

-- Path display
local pathLabel = Instance.new("TextLabel")
pathLabel.Size = UDim2.new(1, -20, 0, 20)
pathLabel.Position = UDim2.new(0, 10, 0, 65)
pathLabel.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
pathLabel.TextColor3 = Color3.fromRGB(200, 200, 100)
pathLabel.Text = "Path: game"
pathLabel.Font = Enum.Font.Code
pathLabel.TextSize = 12
pathLabel.TextXAlignment = Enum.TextXAlignment.Left
pathLabel.Parent = mainFrame

local pathCorner = Instance.new("UICorner")
pathCorner.CornerRadius = UDim.new(0, 4)
pathCorner.Parent = pathLabel

-- Content area (split into two)
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -110)
contentFrame.Position = UDim2.new(0, 10, 0, 90)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Objects list (left side)
local objectsFrame = Instance.new("ScrollingFrame")
objectsFrame.Size = UDim2.new(0.5, -5, 1, 0)
objectsFrame.Position = UDim2.new(0, 0, 0, 0)
objectsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
objectsFrame.BorderSizePixel = 1
objectsFrame.ScrollBarThickness = 8
objectsFrame.Parent = contentFrame

local objectsLayout = Instance.new("UIListLayout")
objectsLayout.Parent = objectsFrame

-- Details frame (right side)
local detailsFrame = Instance.new("ScrollingFrame")
detailsFrame.Size = UDim2.new(0.5, -5, 1, 0)
detailsFrame.Position = UDim2.new(0.5, 5, 0, 0)
detailsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
detailsFrame.BorderSizePixel = 1
detailsFrame.ScrollBarThickness = 8
detailsFrame.Parent = contentFrame

local detailsLayout = Instance.new("UIListLayout")
detailsLayout.Parent = detailsFrame

-- Add corners to content frames
local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 4)
contentCorner:Clone().Parent = objectsFrame
contentCorner:Clone().Parent = detailsFrame

-- Utility functions
local function SafeGetChildren(obj)
    local success, result = pcall(function()
        return obj:GetChildren()
    end)
    return success and result or {}
end

local function SafeGetAttributes(obj)
    local success, result = pcall(function()
        local attributes = {}
        for _, attrName in ipairs(obj:GetAttributes()) do
            attributes[attrName] = obj:GetAttribute(attrName)
        end
        return attributes
    end)
    return success and result or {}
end

local function GetFullPath(obj)
    local path = {}
    local current = obj
    while current and current ~= game do
        table.insert(path, 1, current.Name)
        current = current.Parent
    end
    return "game" .. (#path > 0 and ("." .. table.concat(path, ".")) or "")
end

-- Object exploration functions
local function ExploreObject(obj)
    local info = {
        Name = obj.Name,
        ClassName = obj.ClassName,
        FullPath = GetFullPath(obj),
        Parent = obj.Parent and obj.Parent.Name or "None"
    }
    
    -- Get children count
    local children = SafeGetChildren(obj)
    info.ChildrenCount = #children
    
    -- Get attributes
    info.Attributes = SafeGetAttributes(obj)
    
    return info
end

local function CreateObjectButton(obj, depth)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 25)
    button.Position = UDim2.new(0, 5, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = string.rep("  ", depth) .. "📁 " .. obj.Name .. " (" .. obj.ClassName .. ")"
    button.Font = Enum.Font.Code
    button.TextSize = 11
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.AutoButtonColor = true
    
    button.MouseButton1Click:Connect(function()
        ExplorerState.selectedObject = obj
        UpdateDetailsView()
    end)
    
    button.MouseButton2Click:Connect(function() -- Right click
        local info = ExploreObject(obj)
        print("=== OBJECT INFO ===")
        print("Name: " .. info.Name)
        print("Class: " .. info.ClassName)
        print("Path: " .. info.FullPath)
        print("Parent: " .. info.Parent)
        print("Children: " .. info.ChildrenCount)
        print("Attributes: " .. (#info.Attributes > 0 and tostring(#info.Attributes) or "None"))
        
        -- Copy path to clipboard (simulated)
        setclipboard(info.FullPath)
        print("Path copied to clipboard!")
    end)
    
    return button
end

local function AddDetailRow(label, value, color)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 25)
    frame.Position = UDim2.new(0, 5, 0, 0)
    frame.BackgroundTransparency = 1
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.4, 0, 1, 0)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.TextColor3 = Color3.fromRGB(200, 200, 200)
    labelText.Text = label
    labelText.Font = Enum.Font.Code
    labelText.TextSize = 11
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = frame
    
    local valueText = Instance.new("TextLabel")
    valueText.Size = UDim2.new(0.6, 0, 1, 0)
    valueText.Position = UDim2.new(0.4, 0, 0, 0)
    valueText.BackgroundTransparency = 1
    valueText.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    valueText.Text = tostring(value)
    valueText.Font = Enum.Font.Code
    valueText.TextSize = 11
    valueText.TextXAlignment = Enum.TextXAlignment.Left
    valueText.TextWrapped = true
    valueText.Parent = frame
    
    return frame
end

-- Main view functions
function UpdateObjectsView()
    -- Clear existing objects
    for _, child in ipairs(objectsFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local searchTerm = string.lower(ExplorerState.searchTerm)
    local objectsToShow = {}
    
    -- Define important services and locations to explore
    local explorationTargets = {
        game:GetService("Workspace"),
        game:GetService("Players"),
        game:GetService("ReplicatedStorage"),
        game:GetService("ServerStorage"),
        game:GetService("Lighting"),
        game:GetService("StarterPack"),
        game:GetService("StarterPlayer"),
        game:GetService("StarterGui"),
        game:GetService("SoundService"),
        game:GetService("Teams")
    }
    
    -- Add the game root itself
    table.insert(objectsToShow, game)
    
    -- Add important services
    for _, target in ipairs(explorationTargets) do
        if target then
            table.insert(objectsToShow, target)
        end
    end
    
    -- Filter by search term if provided
    if searchTerm ~= "" then
        local filtered = {}
        for _, obj in ipairs(objectsToShow) do
            if string.find(string.lower(obj.Name), searchTerm) or 
               string.find(string.lower(obj.ClassName), searchTerm) then
                table.insert(filtered, obj)
            end
        end
        objectsToShow = filtered
    end
    
    -- Create buttons for each object
    for _, obj in ipairs(objectsToShow) do
        local button = CreateObjectButton(obj, 0)
        button.Parent = objectsFrame
    end
    
    -- Update canvas size
    objectsFrame.CanvasSize = UDim2.new(0, 0, 0, (#objectsToShow * 25) + 5)
end

function UpdateDetailsView()
    -- Clear existing details
    for _, child in ipairs(detailsFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    if not ExplorerState.selectedObject then
        local noSelection = AddDetailRow("No object selected", "Click an object to view details", Color3.fromRGB(150, 150, 150))
        noSelection.Parent = detailsFrame
        detailsFrame.CanvasSize = UDim2.new(0, 0, 0, 30)
        return
    end
    
    local obj = ExplorerState.selectedObject
    local info = ExploreObject(obj)
    
    -- Add basic info
    AddDetailRow("Name:", info.Name, Color3.fromRGB(100, 200, 255)).Parent = detailsFrame
    AddDetailRow("Class:", info.ClassName, Color3.fromRGB(255, 200, 100)).Parent = detailsFrame
    AddDetailRow("Path:", info.FullPath, Color3.fromRGB(100, 255, 100)).Parent = detailsFrame
    AddDetailRow("Parent:", info.Parent, Color3.fromRGB(200, 150, 255)).Parent = detailsFrame
    AddDetailRow("Children:", info.ChildrenCount, Color3.fromRGB(255, 150, 150)).Parent = detailsFrame
    
    -- Add attributes if any
    if #info.Attributes > 0 then
        AddDetailRow("Attributes:", #info.Attributes .. " found", Color3.fromRGB(255, 255, 100)).Parent = detailsFrame
        
        for attrName, attrValue in pairs(info.Attributes) do
            AddDetailRow("  " .. attrName, tostring(attrValue), Color3.fromRGB(200, 200, 200)).Parent = detailsFrame
        end
    else
        AddDetailRow("Attributes:", "None", Color3.fromRGB(150, 150, 150)).Parent = detailsFrame
    end
    
    -- Add copy path button
    local copyButton = Instance.new("TextButton")
    copyButton.Size = UDim2.new(1, -10, 0, 30)
    copyButton.Position = UDim2.new(0, 5, 0, 0)
    copyButton.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
    copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyButton.Text = "📋 Copy Full Path to Clipboard"
    copyButton.Font = Enum.Font.Gotham
    copyButton.TextSize = 12
    copyButton.Parent = detailsFrame
    
    copyButton.MouseButton1Click:Connect(function()
        setclipboard(info.FullPath)
        copyButton.Text = "✓ Path Copied!"
        task.wait(1)
        copyButton.Text = "📋 Copy Full Path to Clipboard"
    end)
    
    -- Add generate script button
    local scriptButton = Instance.new("TextButton")
    scriptButton.Size = UDim2.new(1, -10, 0, 30)
    scriptButton.Position = UDim2.new(0, 5, 0, 0)
    scriptButton.BackgroundColor3 = Color3.fromRGB(160, 80, 255)
    scriptButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    scriptButton.Text = "💻 Generate Access Script"
    scriptButton.Font = Enum.Font.Gotham
    scriptButton.TextSize = 12
    scriptButton.Parent = detailsFrame
    
    scriptButton.MouseButton1Click:Connect(function()
        local script = "-- Generated by Game Explorer\n"
        script = script .. "local target = " .. info.FullPath .. "\n"
        script = script .. "print(\"Found: \" .. target.Name .. \" (\" .. target.ClassName .. \")\")\n"
        script = script .. "-- Use target variable to interact with the object"
        
        setclipboard(script)
        scriptButton.Text = "✓ Script Copied!"
        task.wait(1)
        scriptButton.Text = "💻 Generate Access Script"
    end)
    
    local detailCount = 7 + (#info.Attributes > 0 and #info.Attributes or 0) + 2 -- +2 for buttons
    detailsFrame.CanvasSize = UDim2.new(0, 0, 0, (detailCount * 25) + 70)
end

-- Search functionality
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    ExplorerState.searchTerm = searchBox.Text
    UpdateObjectsView()
end)

-- Control button functionality
refreshButton.MouseButton1Click:Connect(function()
    UpdateObjectsView()
    UpdateDetailsView()
end)

autoRefreshButton.MouseButton1Click:Connect(function()
    ExplorerState.autoRefresh = not ExplorerState.autoRefresh
    autoRefreshButton.BackgroundColor3 = ExplorerState.autoRefresh and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(80, 80, 80)
    autoRefreshButton.Text = ExplorerState.autoRefresh and "Auto: ON" or "Auto: OFF"
end)

propsButton.MouseButton1Click:Connect(function()
    ExplorerState.showProperties = not ExplorerState.showProperties
    propsButton.BackgroundColor3 = ExplorerState.showProperties and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(80, 80, 80)
    propsButton.Text = ExplorerState.showProperties and "Props: ON" : "Props: OFF"
end)

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Auto-refresh loop
task.spawn(function()
    while task.wait(2) do
        if ExplorerState.autoRefresh and screenGui.Parent then
            UpdateObjectsView()
            if ExplorerState.selectedObject then
                UpdateDetailsView()
            end
        end
    end
end)

-- Make window draggable
local dragging = false
local dragInput, dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Initial setup
UpdateObjectsView()
UpdateDetailsView()

print("Game Explorer Ready!")
print("Left-click: Select object")
print("Right-click: Print object info to console + copy path")
print("Use search box to filter objects by name or class")
print("Buttons at top: Refresh, Auto-refresh, Show Properties")