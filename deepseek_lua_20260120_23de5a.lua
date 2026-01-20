-- Mob Circling Script for Mobile
-- Automatically finds nearest mob and circles around it

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Configuration
local CIRCLE_CONFIG = {
    Enabled = false,
    Speed = 5, -- How fast to circle (rotations per second)
    Radius = 10, -- Distance from mob
    HeightOffset = 0, -- Height above ground
    TargetMob = nil,
    FollowMode = true, -- If true, circle around mob as it moves
    ShowTrail = false -- Show circling trail
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
local isTouchingUI = false

-- Create Main UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobCircleUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Container Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 350)
mainFrame.Position = UDim2.new(0, 10, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
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
title.Text = "🔄 Mob Circling"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Minimize Button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 36, 0, 36)
minimizeButton.Position = UDim2.new(1, -46, 0, 2)
minimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.Text = "─"
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 24
minimizeButton.Parent = titleBar

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 8)
minimizeCorner.Parent = minimizeButton

-- Content Area
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -40)
contentFrame.Position = UDim2.new(0, 0, 0, 40)
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
speedLabel.TextSize = 14
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = contentFrame

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0.8, 0, 0, 35)
speedBox.Position = UDim2.new(0.1, 0, 0, 40)
speedBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.Text = tostring(CIRCLE_CONFIG.Speed)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 14
speedBox.TextXAlignment = Enum.TextXAlignment.Center
speedBox.Parent = contentFrame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 8)
speedCorner.Parent = speedBox

-- Radius Input
local radiusLabel = Instance.new("TextLabel")
radiusLabel.Size = UDim2.new(0.8, 0, 0, 25)
radiusLabel.Position = UDim2.new(0.1, 0, 0, 85)
radiusLabel.BackgroundTransparency = 1
radiusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
radiusLabel.Text = "📏 Radius (1-50):"
radiusLabel.Font = Enum.Font.Gotham
radiusLabel.TextSize = 14
radiusLabel.TextXAlignment = Enum.TextXAlignment.Left
radiusLabel.Parent = contentFrame

local radiusBox = Instance.new("TextBox")
radiusBox.Size = UDim2.new(0.8, 0, 0, 35)
radiusBox.Position = UDim2.new(0.1, 0, 0, 115)
radiusBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
radiusBox.TextColor3 = Color3.fromRGB(255, 255, 255)
radiusBox.Text = tostring(CIRCLE_CONFIG.Radius)
radiusBox.Font = Enum.Font.Gotham
radiusBox.TextSize = 14
radiusBox.TextXAlignment = Enum.TextXAlignment.Center
radiusBox.Parent = contentFrame

local radiusCorner = Instance.new("UICorner")
radiusCorner.CornerRadius = UDim.new(0, 8)
radiusCorner.Parent = radiusBox

-- Height Input
local heightLabel = Instance.new("TextLabel")
heightLabel.Size = UDim2.new(0.8, 0, 0, 25)
heightLabel.Position = UDim2.new(0.1, 0, 0, 160)
heightLabel.BackgroundTransparency = 1
heightLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
heightLabel.Text = "📐 Height (-10 to 10):"
heightLabel.Font = Enum.Font.Gotham
heightLabel.TextSize = 14
heightLabel.TextXAlignment = Enum.TextXAlignment.Left
heightLabel.Parent = contentFrame

local heightBox = Instance.new("TextBox")
heightBox.Size = UDim2.new(0.8, 0, 0, 35)
heightBox.Position = UDim2.new(0.1, 0, 0, 190)
heightBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
heightBox.TextColor3 = Color3.fromRGB(255, 255, 255)
heightBox.Text = tostring(CIRCLE_CONFIG.HeightOffset)
heightBox.Font = Enum.Font.Gotham
heightBox.TextSize = 14
heightBox.TextXAlignment = Enum.TextXAlignment.Center
heightBox.Parent = contentFrame

local heightCorner = Instance.new("UICorner")
heightCorner.CornerRadius = UDim.new(0, 8)
heightCorner.Parent = heightBox

-- Main Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.8, 0, 0, 50)
toggleButton.Position = UDim2.new(0.1, 0, 0, 235)
toggleButton.BackgroundColor3 = CircleEnabled and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Text = CircleEnabled and "▶️ STOP CIRCLING" or "▶️ START CIRCLING"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.Parent = contentFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = toggleButton

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.8, 0, 0, 25)
statusLabel.Position = UDim2.new(0.1, 0, 0, 295)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Text = "Ready to circle"
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.Parent = contentFrame

-- Minimized Icon (hidden by default)
local minimizedIcon = Instance.new("TextButton")
minimizedIcon.Size = UDim2.new(0, 60, 0, 60)
minimizedIcon.Position = UDim2.new(0, 10, 1, -70)
minimizedIcon.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
minimizedIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizedIcon.Text = "🌀"
minimizedIcon.Font = Enum.Font.GothamBold
minimizedIcon.TextSize = 28
minimizedIcon.Visible = false
minimizedIcon.Name = "MinimizedIcon"
minimizedIcon.Parent = screenGui

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(0, 12)
iconCorner.Parent = minimizedIcon

-- Find nearest mob and teleport to it
local function FindAndTeleportToNearestMob()
    if not Character or not RootPart then 
        statusLabel.Text = "❌ No character"
        return nil 
    end
    
    local nearestMob = nil
    local nearestDistance = math.huge
    local playerPos = RootPart.Position
    
    print("Searching for mobs...")
    statusLabel.Text = "🔍 Searching for mobs..."
    
    -- Search for mobs in workspace
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") then
            local humanoid = obj:FindFirstChild("Humanoid")
            local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("Head")
            
            if humanoid and rootPart and obj ~= Character and humanoid.Health > 0 then
                local distance = (rootPart.Position - playerPos).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestMob = obj
                end
            end
        end
    end
    
    -- Also check in folders
    for _, folder in pairs(workspace:GetChildren()) do
        if folder:IsA("Folder") then
            for _, obj in pairs(folder:GetChildren()) do
                if obj:IsA("Model") then
                    local humanoid = obj:FindFirstChild("Humanoid")
                    local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("Head")
                    
                    if humanoid and rootPart and obj ~= Character and humanoid.Health > 0 then
                        local distance = (rootPart.Position - playerPos).Magnitude
                        if distance < nearestDistance then
                            nearestDistance = distance
                            nearestMob = obj
                        end
                    end
                end
            end
        end
    end
    
    if nearestMob then
        print("Found mob: " .. nearestMob.Name .. " (" .. math.floor(nearestDistance) .. " studs away)")
        
        -- Remove old highlight
        if targetMobHighlight then
            targetMobHighlight:Destroy()
            targetMobHighlight = nil
        end
        
        -- Create highlight
        targetMobHighlight = Instance.new("Highlight")
        targetMobHighlight.Name = "CircleTargetHighlight"
        targetMobHighlight.FillColor = Color3.fromRGB(255, 50, 50)
        targetMobHighlight.OutlineColor = Color3.fromRGB(255, 255, 100)
        targetMobHighlight.FillTransparency = 0.7
        targetMobHighlight.OutlineTransparency = 0
        targetMobHighlight.Parent = nearestMob
        
        -- Get mob root part
        local mobRoot = nearestMob:FindFirstChild("HumanoidRootPart") or 
                       nearestMob:FindFirstChild("Torso") or 
                       nearestMob:FindFirstChild("Head")
        
        if mobRoot then
            -- Calculate teleport position at desired radius from mob
            local direction = (mobRoot.Position - playerPos).Unit
            local teleportPos = mobRoot.Position - (direction * CIRCLE_CONFIG.Radius)
            
            -- Adjust Y position
            teleportPos = Vector3.new(teleportPos.X, mobRoot.Position.Y + CIRCLE_CONFIG.HeightOffset, teleportPos.Z)
            
            -- Teleport character
            RootPart.CFrame = CFrame.new(teleportPos)
            
            print("✅ Teleported to " .. nearestMob.Name)
            statusLabel.Text = "✅ Target: " .. nearestMob.Name
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            
            CIRCLE_CONFIG.TargetMob = nearestMob
            return nearestMob
        end
    end
    
    print("❌ No mobs found nearby!")
    statusLabel.Text = "❌ No mobs found nearby"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    return nil
end

-- Get mob root position
local function GetMobPosition()
    if not CIRCLE_CONFIG.TargetMob then return nil end
    if not CIRCLE_CONFIG.TargetMob.Parent then return nil end
    
    local rootPart = CIRCLE_CONFIG.TargetMob:FindFirstChild("HumanoidRootPart") or 
                     CIRCLE_CONFIG.TargetMob:FindFirstChild("Torso") or 
                     CIRCLE_CONFIG.TargetMob:FindFirstChild("Head")
    
    if rootPart then
        return rootPart.Position
    end
    return nil
end

-- Calculate circle position
local function GetCirclePosition(center, radius, angle, heightOffset)
    local x = center.X + radius * math.cos(angle)
    local z = center.Z + radius * math.sin(angle)
    
    -- Use mob's Y position with offset
    local y = center.Y + heightOffset
    
    return Vector3.new(x, y, z)
end

-- Make character look at mob
local function LookAtMob()
    if not CIRCLE_CONFIG.TargetMob then return end
    if not RootPart then return end
    
    local mobPos = GetMobPosition()
    if not mobPos then return end
    
    -- Calculate direction to mob
    local direction = (mobPos - RootPart.Position).Unit
    RootPart.CFrame = CFrame.lookAt(RootPart.Position, RootPart.Position + direction)
end

-- Start circling
local function StartCircling()
    if circlingLoop then 
        print("Already circling!")
        return 
    end
    
    print("Starting circling...")
    
    -- Update config from UI
    CIRCLE_CONFIG.Speed = tonumber(speedBox.Text) or CIRCLE_CONFIG.Speed
    CIRCLE_CONFIG.Radius = tonumber(radiusBox.Text) or CIRCLE_CONFIG.Radius
    CIRCLE_CONFIG.HeightOffset = tonumber(heightBox.Text) or CIRCLE_CONFIG.HeightOffset
    
    -- Clamp values
    CIRCLE_CONFIG.Speed = math.clamp(CIRCLE_CONFIG.Speed, 1, 20)
    CIRCLE_CONFIG.Radius = math.clamp(CIRCLE_CONFIG.Radius, 1, 50)
    CIRCLE_CONFIG.HeightOffset = math.clamp(CIRCLE_CONFIG.HeightOffset, -10, 10)
    
    -- Find and teleport to nearest mob
    if not CIRCLE_CONFIG.TargetMob or not CIRCLE_CONFIG.TargetMob.Parent then
        if not FindAndTeleportToNearestMob() then
            print("Failed to find mob!")
            return
        end
    end
    
    print("Starting to circle mob: " .. CIRCLE_CONFIG.TargetMob.Name)
    CircleEnabled = true
    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    toggleButton.Text = "⏸️ STOP CIRCLING"
    statusLabel.Text = "🌀 Circling: " .. CIRCLE_CONFIG.TargetMob.Name
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    
    currentAngle = 0
    
    -- Start circling loop
    circlingLoop = RunService.Heartbeat:Connect(function(deltaTime)
        if not Character or not RootPart then
            print("Character lost!")
            StopCircling()
            return
        end
        
        -- Check if target mob is still valid
        if not CIRCLE_CONFIG.TargetMob or not CIRCLE_CONFIG.TargetMob.Parent then
            print("Target mob lost!")
            statusLabel.Text = "⚠️ Target lost, finding new..."
            
            -- Try to find new mob
            if FindAndTeleportToNearestMob() then
                print("Found new target")
            else
                StopCircling()
                return
            end
        end
        
        -- Get mob position
        local mobPosition = GetMobPosition()
        if not mobPosition then
            print("Couldn't get mob position!")
            StopCircling()
            return
        end
        
        -- Update angle for circling
        currentAngle = currentAngle + (CIRCLE_CONFIG.Speed * deltaTime * 0.5)
        if currentAngle > (2 * math.pi) then
            currentAngle = currentAngle - (2 * math.pi)
        end
        
        -- Calculate new position
        local newPosition = GetCirclePosition(mobPosition, CIRCLE_CONFIG.Radius, currentAngle, CIRCLE_CONFIG.HeightOffset)
        
        -- Move character to new position
        Humanoid:MoveTo(newPosition)
        
        -- Make character look at mob
        LookAtMob()
        
        -- Create visual trail if enabled
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
    
    CircleEnabled = false
    toggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    toggleButton.Text = "▶️ START CIRCLING"
    statusLabel.Text = "⏹️ Stopped circling"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    
    -- Remove highlight
    if targetMobHighlight then
        targetMobHighlight:Destroy()
        targetMobHighlight = nil
    end
    
    print("⏹️ Circling stopped")
end

-- Find New Mob Button
local findButton = Instance.new("TextButton")
findButton.Size = UDim2.new(0.8, 0, 0, 40)
findButton.Position = UDim2.new(0.1, 0, 0, 320)
findButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
findButton.TextColor3 = Color3.fromRGB(255, 255, 255)
findButton.Text = "🔍 Find New Mob"
findButton.Font = Enum.Font.GothamBold
findButton.TextSize = 14
findButton.Parent = contentFrame

local findCorner = Instance.new("UICorner")
findCorner.CornerRadius = UDim.new(0, 8)
findCorner.Parent = findButton

-- Adjust frame size
mainFrame.Size = UDim2.new(0, 280, 0, 380)

-- Mobile Touch Events
local function onToggleButtonTouch()
    if not isTouchingUI then
        isTouchingUI = true
        
        if CircleEnabled then
            StopCircling()
        else
            StartCircling()
        end
        
        wait(0.5)
        isTouchingUI = false
    end
end

local function onFindButtonTouch()
    if not isTouchingUI then
        isTouchingUI = true
        
        print("Manually searching for mob...")
        statusLabel.Text = "🔍 Searching for mob..."
        
        -- Stop current circling if active
        if CircleEnabled then
            StopCircling()
        end
        
        -- Find new mob
        if FindAndTeleportToNearestMob() then
            -- Optionally start circling after finding
            if not CircleEnabled then
                wait(0.5)
                StartCircling()
            end
        end
        
        wait(0.5)
        isTouchingUI = false
    end
end

-- Connect touch events
toggleButton.Activated:Connect(onToggleButtonTouch)
findButton.Activated:Connect(onFindButtonTouch)

-- Minimize/Maximize functions
local function onMinimizeButtonTouch()
    if not isTouchingUI then
        isTouchingUI = true
        
        isMinimized = not isMinimized
        
        if isMinimized then
            -- Minimize: hide main content, show icon
            contentFrame.Visible = false
            mainFrame.Size = UDim2.new(0, 280, 0, 40)
            minimizedIcon.Visible = true
            minimizeButton.Text = "□" -- Change to maximize symbol
        else
            -- Maximize: show main content, hide icon
            contentFrame.Visible = true
            mainFrame.Size = UDim2.new(0, 280, 0, 380)
            minimizedIcon.Visible = false
            minimizeButton.Text = "─" -- Change to minimize symbol
        end
        
        wait(0.3)
        isTouchingUI = false
    end
end

local function onMinimizedIconTouch()
    if not isTouchingUI then
        isTouchingUI = true
        
        -- Maximize when clicking the minimized icon
        isMinimized = false
        contentFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 280, 0, 380)
        minimizedIcon.Visible = false
        minimizeButton.Text = "─"
        
        wait(0.3)
        isTouchingUI = false
    end
end

minimizeButton.Activated:Connect(onMinimizeButtonTouch)
minimizedIcon.Activated:Connect(onMinimizedIconTouch)

-- Auto-find new mob if current one dies
local function MonitorTargetHealth()
    while true do
        task.wait(2)
        
        if CircleEnabled and CIRCLE_CONFIG.TargetMob then
            local humanoid = CIRCLE_CONFIG.TargetMob:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Health <= 0 then
                print("⚠️ Target mob died, finding new one...")
                statusLabel.Text = "⚠️ Target died, finding new..."
                
                -- Remove old highlight
                if targetMobHighlight then
                    targetMobHighlight:Destroy()
                    targetMobHighlight = nil
                end
                
                -- Find new mob
                if FindAndTeleportToNearestMob() then
                    print("✅ Found new target: " .. CIRCLE_CONFIG.TargetMob.Name)
                else
                    StopCircling()
                end
            end
        end
    end
end

-- Character respawn handling
player.CharacterAdded:Connect(function(character)
    Character = character
    Humanoid = character:WaitForChild("Humanoid")
    RootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Stop circling if character dies
    StopCircling()
    
    -- Wait a bit then restart if was enabled
    task.wait(3)
    if CircleEnabled then
        print("Character respawned, restarting circling...")
        StartCircling()
    end
end)

-- Initialize
task.spawn(function()
    task.wait(2)
    print("🔧 Mob Circling Script Loaded!")
    print("📱 Mobile version ready")
    print("👉 Tap START CIRCLING to begin")
end)

-- Start health monitoring
task.spawn(MonitorTargetHealth)

print("✅ Script loaded successfully!")