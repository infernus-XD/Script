-- Mob Circling Script with Tweening
-- Automatically finds and circles mobs using tween animations

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Configuration
local CIRCLE_CONFIG = {
    Enabled = false,
    Speed = 5, -- Rotation speed (1-20)
    Radius = 15, -- Distance from mob (1-50)
    HeightOffset = 0, -- Height above ground (no limit)
    TargetMob = nil,
    ShowTrail = false,
    CircleMode = true -- True: circle around mob, False: teleport to mob
}

-- Variables
local Character = player.Character or player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local CircleEnabled = CIRCLE_CONFIG.Enabled
local circlingLoop = nil
local currentAngle = 0
local isMinimized = false
local targetMobHighlight = nil
local currentTween = nil

-- Create Main UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobCircleUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Container Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 320)
mainFrame.Position = UDim2.new(0, 10, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.Parent = mainFrame

local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, 12)
titleBarCorner.Parent = titleBar

-- Title Text
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "🌀 Mob Circler"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Minimize Button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -40, 0, 2)
minimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.Text = "─"
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 20
minimizeButton.Parent = titleBar

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 8)
minimizeCorner.Parent = minimizeButton

-- Content Area
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -35)
contentFrame.Position = UDim2.new(0, 0, 0, 35)
contentFrame.BackgroundTransparency = 1
contentFrame.Name = "ContentFrame"
contentFrame.Parent = mainFrame

-- Speed Input
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.8, 0, 0, 25)
speedLabel.Position = UDim2.new(0.1, 0, 0, 10)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
speedLabel.Text = "⚡ Speed (1-20):"
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 12
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = contentFrame

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0.8, 0, 0, 30)
speedBox.Position = UDim2.new(0.1, 0, 0, 40)
speedBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.Text = tostring(CIRCLE_CONFIG.Speed)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 12
speedBox.TextXAlignment = Enum.TextXAlignment.Center
speedBox.Parent = contentFrame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 8)
speedCorner.Parent = speedBox

-- Radius Input
local radiusLabel = Instance.new("TextLabel")
radiusLabel.Size = UDim2.new(0.8, 0, 0, 25)
radiusLabel.Position = UDim2.new(0.1, 0, 0, 80)
radiusLabel.BackgroundTransparency = 1
radiusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
radiusLabel.Text = "📏 Radius (1-50):"
radiusLabel.Font = Enum.Font.Gotham
radiusLabel.TextSize = 12
radiusLabel.TextXAlignment = Enum.TextXAlignment.Left
radiusLabel.Parent = contentFrame

local radiusBox = Instance.new("TextBox")
radiusBox.Size = UDim2.new(0.8, 0, 0, 30)
radiusBox.Position = UDim2.new(0.1, 0, 0, 110)
radiusBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
radiusBox.TextColor3 = Color3.fromRGB(255, 255, 255)
radiusBox.Text = tostring(CIRCLE_CONFIG.Radius)
radiusBox.Font = Enum.Font.Gotham
radiusBox.TextSize = 12
radiusBox.TextXAlignment = Enum.TextXAlignment.Center
radiusBox.Parent = contentFrame

local radiusCorner = Instance.new("UICorner")
radiusCorner.CornerRadius = UDim.new(0, 8)
radiusCorner.Parent = radiusBox

-- Height Input - NO LIMITS
local heightLabel = Instance.new("TextLabel")
heightLabel.Size = UDim2.new(0.8, 0, 0, 25)
heightLabel.Position = UDim2.new(0.1, 0, 0, 150)
heightLabel.BackgroundTransparency = 1
heightLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
heightLabel.Text = "📐 Height (any value):"
heightLabel.Font = Enum.Font.Gotham
heightLabel.TextSize = 12
heightLabel.TextXAlignment = Enum.TextXAlignment.Left
heightLabel.Parent = contentFrame

local heightBox = Instance.new("TextBox")
heightBox.Size = UDim2.new(0.8, 0, 0, 30)
heightBox.Position = UDim2.new(0.1, 0, 0, 180)
heightBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
heightBox.TextColor3 = Color3.fromRGB(255, 255, 255)
heightBox.Text = tostring(CIRCLE_CONFIG.HeightOffset)
heightBox.Font = Enum.Font.Gotham
heightBox.TextSize = 12
heightBox.TextXAlignment = Enum.TextXAlignment.Center
heightBox.Parent = contentFrame

local heightCorner = Instance.new("UICorner")
heightCorner.CornerRadius = UDim.new(0, 8)
heightCorner.Parent = heightBox

-- Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.8, 0, 0, 35)
toggleButton.Position = UDim2.new(0.1, 0, 0, 220)
toggleButton.BackgroundColor3 = CircleEnabled and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Text = CircleEnabled and "⏸️ STOP" or "▶️ START"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 13
toggleButton.Parent = contentFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = toggleButton

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.8, 0, 0, 25)
statusLabel.Position = UDim2.new(0.1, 0, 0, 265)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Text = "Click START to begin"
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 11
statusLabel.Parent = contentFrame

-- Minimized Icon
local minimizedIcon = Instance.new("TextButton")
minimizedIcon.Size = UDim2.new(0, 40, 0, 40)
minimizedIcon.Position = UDim2.new(0, 10, 1, -50)
minimizedIcon.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
minimizedIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizedIcon.Text = "🌀"
minimizedIcon.Font = Enum.Font.GothamBold
minimizedIcon.TextSize = 20
minimizedIcon.Visible = false
minimizedIcon.Name = "MinimizedIcon"
minimizedIcon.Parent = screenGui

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(0, 10)
iconCorner.Parent = minimizedIcon

-- Find mobs using the same method as your script
local function FindNearestMob()
    if not Character or not RootPart then 
        return nil 
    end
    
    local Mobs = workspace:WaitForChild("__Main"):WaitForChild("__Enemies")
    local nearestMob = nil
    local nearestDistance = math.huge
    local playerPos = RootPart.Position
    
    -- Method 1: Check in the Mobs folder structure
    local ServerFolder = Mobs:FindFirstChild("Server") or Mobs
    for _, SubFolder in ipairs(ServerFolder:GetChildren()) do
        if not SubFolder:IsA("Folder") and not SubFolder:GetAttribute("Dead") then
            local mobPos = SubFolder:GetPivot().Position
            local distance = (mobPos - playerPos).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestMob = SubFolder
            end
        end
        
        if SubFolder:IsA("Folder") and #SubFolder:GetChildren() > 0 then
            for _, Mob in ipairs(SubFolder:GetChildren()) do
                if not Mob:GetAttribute("Dead") then
                    local mobPos = Mob:GetPivot().Position
                    local distance = (mobPos - playerPos).Magnitude
                    if distance < nearestDistance then
                        nearestDistance = distance
                        nearestMob = Mob
                    end
                end
            end
        end
    end
    
    return nearestMob, nearestDistance
end

-- Teleport to mob using tween
local function TeleportToMob(mob)
    if not Character or not RootPart then return false end
    
    local mobPos = mob:GetPivot().Position
    local teleportPos = mobPos + Vector3.new(0, 0, CIRCLE_CONFIG.Radius) -- Start at radius distance
    
    if currentTween then
        currentTween:Cancel()
        currentTween = nil
    end
    
    currentTween = TweenService:Create(
        RootPart,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {CFrame = CFrame.new(teleportPos)}
    )
    currentTween:Play()
    
    return true
end

-- Circle around mob using tween
local function CircleAroundMob(mob)
    if not Character or not RootPart then return false end
    
    local mobPos = mob:GetPivot().Position
    
    -- Calculate circle position based on current angle
    local x = mobPos.X + CIRCLE_CONFIG.Radius * math.cos(currentAngle)
    local z = mobPos.Z + CIRCLE_CONFIG.Radius * math.sin(currentAngle)
    local y = mobPos.Y + CIRCLE_CONFIG.HeightOffset
    
    local targetPos = Vector3.new(x, y, z)
    
    if currentTween then
        currentTween:Cancel()
        currentTween = nil
    end
    
    currentTween = TweenService:Create(
        RootPart,
        TweenInfo.new(0.3, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(targetPos) * CFrame.new(0, 0, 6)}
    )
    currentTween:Play()
    
    -- Update angle for next position
    currentAngle = currentAngle + (CIRCLE_CONFIG.Speed * 0.01)
    if currentAngle > (2 * math.pi) then
        currentAngle = currentAngle - (2 * math.pi)
    end
    
    return true
end

-- Highlight mob
local function HighlightMob(mob)
    if targetMobHighlight then
        targetMobHighlight:Destroy()
        targetMobHighlight = nil
    end
    
    targetMobHighlight = Instance.new("Highlight")
    targetMobHighlight.Name = "MobCircleHighlight"
    targetMobHighlight.FillColor = Color3.fromRGB(255, 50, 50)
    targetMobHighlight.OutlineColor = Color3.fromRGB(255, 255, 100)
    targetMobHighlight.FillTransparency = 0.7
    targetMobHighlight.OutlineTransparency = 0
    targetMobHighlight.Parent = mob
    
    return targetMobHighlight
end

-- Start circling
local function StartCircling()
    if circlingLoop then 
        print("Already circling!")
        return 
    end
    
    print("Starting mob circling...")
    
    -- Update config from UI
    CIRCLE_CONFIG.Speed = tonumber(speedBox.Text) or CIRCLE_CONFIG.Speed
    CIRCLE_CONFIG.Radius = tonumber(radiusBox.Text) or CIRCLE_CONFIG.Radius
    CIRCLE_CONFIG.HeightOffset = tonumber(heightBox.Text) or CIRCLE_CONFIG.HeightOffset
    
    -- Clamp values (except height - no limits)
    CIRCLE_CONFIG.Speed = math.clamp(CIRCLE_CONFIG.Speed, 1, 20)
    CIRCLE_CONFIG.Radius = math.clamp(CIRCLE_CONFIG.Radius, 1, 50)
    -- Height has no limits - use whatever value user enters
    
    -- Find nearest mob
    local mob, distance = FindNearestMob()
    if not mob then
        statusLabel.Text = "❌ No mobs found!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    print("Found mob: " .. mob.Name .. " (" .. math.floor(distance) .. " studs away)")
    
    CIRCLE_CONFIG.TargetMob = mob
    statusLabel.Text = "🎯 Target: " .. mob.Name
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    
    -- Highlight the mob
    HighlightMob(mob)
    
    -- Initial teleport to mob
    TeleportToMob(mob)
    
    -- Wait for teleport to complete
    task.wait(0.6)
    
    CircleEnabled = true
    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    toggleButton.Text = "⏸️ STOP"
    
    -- Start circling loop
    circlingLoop = RunService.Heartbeat:Connect(function(deltaTime)
        if not Character or not RootPart or not CircleEnabled then
            StopCircling()
            return
        end
        
        -- Check if mob is still valid
        if not CIRCLE_CONFIG.TargetMob or not CIRCLE_CONFIG.TargetMob.Parent then
            statusLabel.Text = "⚠️ Target lost, finding new..."
            
            -- Find new mob
            local newMob, newDistance = FindNearestMob()
            if newMob then
                CIRCLE_CONFIG.TargetMob = newMob
                statusLabel.Text = "🎯 Target: " .. newMob.Name
                HighlightMob(newMob)
            else
                statusLabel.Text = "❌ No mobs found!"
                StopCircling()
                return
            end
        end
        
        -- Circle around mob
        CircleAroundMob(CIRCLE_CONFIG.TargetMob)
        
        -- Create trail if enabled
        if CIRCLE_CONFIG.ShowTrail then
            local trailPart = Instance.new("Part")
            trailPart.Size = Vector3.new(0.5, 0.5, 0.5)
            trailPart.Position = RootPart.Position
            trailPart.Color = Color3.fromRGB(0, 150, 255)
            trailPart.Material = Enum.Material.Neon
            trailPart.Transparency = 0.5
            trailPart.CanCollide = false
            trailPart.Anchored = true
            trailPart.Parent = workspace
            game:GetService("Debris"):AddItem(trailPart, 1)
        end
    end)
    
    print("✅ Circling started successfully!")
end

-- Stop circling
local function StopCircling()
    if circlingLoop then
        circlingLoop:Disconnect()
        circlingLoop = nil
    end
    
    if currentTween then
        currentTween:Cancel()
        currentTween = nil
    end
    
    CircleEnabled = false
    toggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    toggleButton.Text = "▶️ START"
    statusLabel.Text = "⏹️ Stopped circling"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    
    -- Remove highlight
    if targetMobHighlight then
        targetMobHighlight:Destroy()
        targetMobHighlight = nil
    end
    
    print("⏹️ Circling stopped")
end

-- Toggle circling
toggleButton.MouseButton1Click:Connect(function()
    if CircleEnabled then
        StopCircling()
    else
        StartCircling()
    end
end)

-- Minimize/Maximize
minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        contentFrame.Visible = false
        mainFrame.Size = UDim2.new(0, 250, 0, 35)
        minimizedIcon.Visible = true
        minimizeButton.Text = "□"
    else
        contentFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 250, 0, 320)
        minimizedIcon.Visible = false
        minimizeButton.Text = "─"
    end
end)

minimizedIcon.MouseButton1Click:Connect(function()
    isMinimized = false
    contentFrame.Visible = true
    mainFrame.Size = UDim2.new(0, 250, 0, 320)
    minimizedIcon.Visible = false
    minimizeButton.Text = "─"
end)

-- Character respawn handling
player.CharacterAdded:Connect(function(character)
    Character = character
    Humanoid = character:WaitForChild("Humanoid")
    RootPart = character:WaitForChild("HumanoidRootPart")
    
    StopCircling()
    
    task.wait(2)
    if CircleEnabled then
        StartCircling()
    end
end)

-- Make UI draggable
local dragging = false
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

titleBar.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Also make minimized icon draggable
minimizedIcon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = minimizedIcon.Position
    end
end)

minimizedIcon.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

minimizedIcon.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        minimizedIcon.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Optional: Add a button to test heights
local testHeightButton = Instance.new("TextButton")
testHeightButton.Size = UDim2.new(0.8, 0, 0, 25)
testHeightButton.Position = UDim2.new(0.1, 0, 0, 290)
testHeightButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
testHeightButton.TextColor3 = Color3.fromRGB(255, 255, 255)
testHeightButton.Text = "Test Height"
testHeightButton.Font = Enum.Font.Gotham
testHeightButton.TextSize = 11
testHeightButton.Parent = contentFrame

local testHeightCorner = Instance.new("UICorner")
testHeightCorner.CornerRadius = UDim.new(0, 6)
testHeightCorner.Parent = testHeightButton

testHeightButton.MouseButton1Click:Connect(function()
    if Character and RootPart then
        local currentHeight = tonumber(heightBox.Text) or 0
        local newPos = RootPart.Position + Vector3.new(0, currentHeight, 0)
        RootPart.CFrame = CFrame.new(newPos)
        print("Testing height: " .. currentHeight)
    end
end)

-- Adjust frame size
mainFrame.Size = UDim2.new(0, 250, 0, 340)

print("✅ Mob Circling Script Loaded!")
print("👉 Click START to automatically find and circle nearest mob")
print("👉 Height can be any value (positive or negative)")
print("👉 Use Test Height button to quickly test height settings")