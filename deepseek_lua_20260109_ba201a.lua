-- Enhanced Attack Aura Script
-- Damages all mobs within radius with better detection and visuals

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Configuration
local AURA_CONFIG = {
    Enabled = true,
    Radius = 30, -- Increased radius
    BaseDamage = 15,
    DamageMultiplier = 1.0,
    ShowVisuals = true,
    VisualColor = Color3.fromRGB(255, 50, 50),
    PulseSpeed = 1, -- Seconds per pulse
    Cooldown = 0.3,
    AutoAttack = false, -- Auto-damage without needing to attack
    UseWeaponRange = false -- If true, uses weapon range instead of fixed radius
}

-- Variables
local Character = player.Character or player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local CurrentWeapon = nil
local AuraEnabled = AURA_CONFIG.Enabled
local LastAttackTime = 0
local AuraParts = {}
local AttackConnection = nil
local Mouse = player:GetMouse()

-- Try to find combat events
local CombatEvents
local AttackEvent
pcall(function()
    CombatEvents = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Combat")
    AttackEvent = CombatEvents:WaitForChild("Attack")
end)

-- Create UI
local function CreateUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AttackAuraUI"
    screenGui.ResetOnSpawn = false
    
    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
    end
    
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 180)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.3
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    title.TextColor3 = Color3.fromRGB(255, 100, 100)
    title.Text = "⚔️ ATTACK AURA ⚔️"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = frame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = title

    -- Toggle Button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0.9, 0, 0, 35)
    toggleButton.Position = UDim2.new(0.05, 0, 0, 30)
    toggleButton.BackgroundColor3 = AuraEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Text = AuraEnabled and "AURA: ACTIVE" or "AURA: INACTIVE"
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 12
    toggleButton.Parent = frame

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = toggleButton

    -- Auto Attack Toggle
    local autoButton = Instance.new("TextButton")
    autoButton.Size = UDim2.new(0.9, 0, 0, 30)
    autoButton.Position = UDim2.new(0.05, 0, 0, 70)
    autoButton.BackgroundColor3 = AURA_CONFIG.AutoAttack and Color3.fromRGB(50, 150, 200) or Color3.fromRGB(80, 80, 100)
    autoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoButton.Text = AURA_CONFIG.AutoAttack and "AUTO: ON" or "AUTO: OFF"
    autoButton.Font = Enum.Font.Gotham
    autoButton.TextSize = 11
    autoButton.Parent = frame

    local autoCorner = Instance.new("UICorner")
    autoCorner.CornerRadius = UDim.new(0, 6)
    autoCorner.Parent = autoButton

    -- Range Slider
    local rangeLabel = Instance.new("TextLabel")
    rangeLabel.Size = UDim2.new(0.9, 0, 0, 20)
    rangeLabel.Position = UDim2.new(0.05, 0, 0, 105)
    rangeLabel.BackgroundTransparency = 1
    rangeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    rangeLabel.Text = "Range: " .. AURA_CONFIG.Radius
    rangeLabel.Font = Enum.Font.Gotham
    rangeLabel.TextSize = 11
    rangeLabel.Parent = frame

    local rangeSlider = Instance.new("TextBox")
    rangeSlider.Size = UDim2.new(0.9, 0, 0, 25)
    rangeSlider.Position = UDim2.new(0.05, 0, 0, 125)
    rangeSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    rangeSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    rangeSlider.PlaceholderText = "Enter radius (10-50)"
    rangeSlider.Text = tostring(AURA_CONFIG.Radius)
    rangeSlider.Font = Enum.Font.Gotham
    rangeSlider.TextSize = 11
    rangeSlider.Parent = frame

    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 4)
    sliderCorner.Parent = rangeSlider

    -- Damage Multiplier
    local damageLabel = Instance.new("TextLabel")
    damageLabel.Size = UDim2.new(0.9, 0, 0, 20)
    damageLabel.Position = UDim2.new(0.05, 0, 0, 155)
    damageLabel.BackgroundTransparency = 1
    damageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    damageLabel.Text = "Damage: " .. AURA_CONFIG.BaseDamage .. " (x" .. AURA_CONFIG.DamageMultiplier .. ")"
    damageLabel.Font = Enum.Font.Gotham
    damageLabel.TextSize = 11
    damageLabel.Parent = frame

    -- Event Handlers
    toggleButton.MouseButton1Click:Connect(function()
        AuraEnabled = not AuraEnabled
        toggleButton.BackgroundColor3 = AuraEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        toggleButton.Text = AuraEnabled and "AURA: ACTIVE" or "AURA: INACTIVE"
        
        if AuraEnabled then
            CreateAuraVisual()
        else
            ClearAuraVisual()
        end
    end)

    autoButton.MouseButton1Click:Connect(function()
        AURA_CONFIG.AutoAttack = not AURA_CONFIG.AutoAttack
        autoButton.BackgroundColor3 = AURA_CONFIG.AutoAttack and Color3.fromRGB(50, 150, 200) or Color3.fromRGB(80, 80, 100)
        autoButton.Text = AURA_CONFIG.AutoAttack and "AUTO: ON" or "AUTO: OFF"
    end)

    rangeSlider.FocusLost:Connect(function()
        local newRadius = tonumber(rangeSlider.Text)
        if newRadius and newRadius >= 10 and newRadius <= 100 then
            AURA_CONFIG.Radius = newRadius
            rangeLabel.Text = "Range: " .. AURA_CONFIG.Radius
            ClearAuraVisual()
            if AuraEnabled then
                CreateAuraVisual()
            end
        else
            rangeSlider.Text = tostring(AURA_CONFIG.Radius)
        end
    end)

    return screenGui
end

-- Create aura visual effect
local function CreateAuraVisual()
    if not AURA_CONFIG.ShowVisuals then return end
    ClearAuraVisual()
    
    local auraRing = Instance.new("Part")
    auraRing.Name = "AuraRing"
    auraRing.Size = Vector3.new(0.5, 0.5, 0.5)
    auraRing.Transparency = 0.3
    auraRing.Color = AURA_CONFIG.VisualColor
    auraRing.Material = Enum.Material.Neon
    auraRing.CanCollide = false
    auraRing.Anchored = true
    auraRing.Locked = true
    auraRing.CastShadow = false
    
    local auraDisc = Instance.new("Part")
    auraDisc.Name = "AuraDisc"
    auraDisc.Size = Vector3.new(AURA_CONFIG.Radius * 2, 0.2, AURA_CONFIG.Radius * 2)
    auraDisc.Transparency = 0.8
    auraDisc.Color = AURA_CONFIG.VisualColor
    auraDisc.Material = Enum.Material.Neon
    auraDisc.CanCollide = false
    auraDisc.Anchored = true
    auraDisc.Locked = true
    auraDisc.CastShadow = false
    
    -- Particle effects
    local particles = Instance.new("ParticleEmitter")
    particles.Color = ColorSequence.new(AURA_CONFIG.VisualColor)
    particles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 3)
    })
    particles.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 1)
    })
    particles.Lifetime = NumberRange.new(0.5, 1)
    particles.Rate = 50
    particles.Speed = NumberRange.new(2, 5)
    particles.SpreadAngle = Vector2.new(360, 360)
    particles.Parent = auraRing
    
    table.insert(AuraParts, auraRing)
    table.insert(AuraParts, auraDisc)
    
    -- Animation loop
    coroutine.wrap(function()
        while AuraEnabled and #AuraParts > 0 do
            if RootPart and RootPart.Parent then
                local position = RootPart.Position
                
                -- Position disc at feet
                auraDisc.Position = Vector3.new(position.X, position.Y - 2, position.Z)
                auraDisc.Parent = workspace
                
                -- Animate ring
                auraRing.Position = position + Vector3.new(0, 1, 0)
                auraRing.Parent = workspace
                
                -- Rotate ring
                auraRing.CFrame = auraRing.CFrame * CFrame.Angles(0, math.rad(2), 0)
                
                -- Pulse effect
                local pulse = math.sin(tick() * AURA_CONFIG.PulseSpeed) * 0.2 + 1
                auraRing.Size = Vector3.new(pulse, pulse, pulse)
                
                -- Pulsing color
                local r = math.sin(tick() * 2) * 0.5 + 0.5
                auraRing.Color = Color3.fromRGB(255, 50 + r * 100, 50)
            end
            RunService.Heartbeat:Wait()
        end
        
        -- Cleanup
        ClearAuraVisual()
    end)()
end

-- Clear aura visuals
local function ClearAuraVisual()
    for _, part in ipairs(AuraParts) do
        if part and part.Parent then
            part:Destroy()
        end
    end
    AuraParts = {}
end

-- Enhanced enemy detection
local function GetEnemiesInRadius(position, radius)
    local enemies = {}
    
    -- Check workspace directly
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= Character then
            local humanoid = obj:FindFirstChild("Humanoid")
            local rootPart = obj:FindFirstChild("HumanoidRootPart") or 
                            obj:FindFirstChild("Torso") or 
                            obj:FindFirstChild("UpperTorso") or
                            obj:FindFirstChild("Head")
            
            if humanoid and rootPart and humanoid.Health > 0 then
                local distance = (rootPart.Position - position).Magnitude
                if distance <= radius then
                    table.insert(enemies, {
                        Model = obj,
                        Humanoid = humanoid,
                        RootPart = rootPart,
                        Name = obj.Name,
                        Distance = distance
                    })
                end
            end
        end
    end
    
    return enemies
end

-- Enhanced damage function
local function DamageEnemy(enemy)
    local damage = AURA_CONFIG.BaseDamage * AURA_CONFIG.DamageMultiplier
    
    -- Method 1: Direct damage
    pcall(function()
        enemy.Humanoid.Health = enemy.Humanoid.Health - damage
    end)
    
    -- Method 2: TakeDamage
    pcall(function()
        enemy.Humanoid:TakeDamage(damage)
    end)
    
    -- Method 3: Try remote events
    if AttackEvent then
        pcall(function()
            AttackEvent:FireServer(enemy.Model, damage)
        end)
        
        -- Try different parameter formats
        pcall(function()
            AttackEvent:FireServer({
                Target = enemy.Model,
                Damage = damage,
                Type = "Aura"
            })
        end)
        
        pcall(function()
            AttackEvent:FireServer(enemy.Name, damage, "Aura")
        end)
    end
    
    -- Visual feedback
    if enemy.RootPart then
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 100, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = "-" .. math.floor(damage)
        text.TextColor3 = Color3.fromRGB(255, 50, 50)
        text.Font = Enum.Font.GothamBold
        text.TextSize = 18
        text.Parent = billboard
        
        billboard.Parent = enemy.RootPart
        
        game:GetService("Debris"):AddItem(billboard, 1)
    end
    
    return true
end

-- Attack detection
local function IsAttacking()
    if not Character or not Humanoid or Humanoid.Health <= 0 then
        return false
    end
    
    -- Check animation tracks
    for _, track in pairs(Humanoid:GetPlayingAnimationTracks()) do
        local animName = track.Name:lower()
        if animName:find("attack") or 
           animName:find("swing") or 
           animName:find("slash") or
           animName:find("hit") or
           animName:find("punch") or
           animName:find("kick") then
            return true
        end
    end
    
    -- Check for tool activation
    if CurrentWeapon then
        local toolAnim = CurrentWeapon:FindFirstChild("ToolAnimation")
        if toolAnim and toolAnim.IsPlaying then
            return true
        end
    end
    
    return false
end

-- Main aura attack function
local function PerformAuraAttack()
    if not AuraEnabled or not RootPart or not RootPart.Parent then
        return false
    end
    
    local currentTime = tick()
    if currentTime - LastAttackTime < AURA_CONFIG.Cooldown then
        return false
    end
    
    -- Get enemies
    local enemies = GetEnemiesInRadius(RootPart.Position, AURA_CONFIG.Radius)
    
    if #enemies > 0 then
        -- Damage all enemies
        local damaged = 0
        for _, enemy in ipairs(enemies) do
            if DamageEnemy(enemy) then
                damaged = damaged + 1
            end
        end
        
        -- Visual feedback
        if AURA_CONFIG.ShowVisuals and #AuraParts > 0 then
            for _, part in ipairs(AuraParts) do
                if part and part.Parent then
                    part.Transparency = 0.3
                    part.Color = Color3.fromRGB(255, 0, 0)
                    
                    task.delay(0.1, function()
                        if part and part.Parent then
                            part.Transparency = part.Name == "AuraRing" and 0.3 or 0.8
                            part.Color = AURA_CONFIG.VisualColor
                        end
                    end)
                end
            end
        end
        
        LastAttackTime = currentTime
        return damaged > 0
    end
    
    return false
end

-- Tool tracking
local function UpdateEquippedTool()
    if Character then
        for _, child in ipairs(Character:GetChildren()) do
            if child:IsA("Tool") then
                CurrentWeapon = child
                return
            end
        end
        
        -- Check backpack
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    CurrentWeapon = tool
                    return
                end
            end
        end
    end
    CurrentWeapon = nil
end

-- Mouse click detection
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and AuraEnabled then
        PerformAuraAttack()
    end
    
    -- Manual trigger with R key
    if input.KeyCode == Enum.KeyCode.R then
        PerformAuraAttack()
    end
end)

-- Main aura loop
local function StartAura()
    if AuraEnabled then
        CreateAuraVisual()
        print("Attack aura activated! Radius: " .. AURA_CONFIG.Radius)
        
        -- Auto-attack loop
        coroutine.wrap(function()
            while AuraEnabled do
                if AURA_CONFIG.AutoAttack then
                    PerformAuraAttack()
                end
                task.wait(AURA_CONFIG.Cooldown)
            end
        end)()
        
        -- Attack detection loop
        coroutine.wrap(function()
            while AuraEnabled do
                if IsAttacking() then
                    PerformAuraAttack()
                end
                task.wait(0.1)
            end
        end)()
    end
end

-- Initialize
local UI = CreateUI()

-- Character respawn handling
player.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
    
    if AuraEnabled then
        task.wait(1)
        ClearAuraVisual()
        StartAura()
    end
end)

-- Tool tracking loop
RunService.Heartbeat:Connect(function()
    UpdateEquippedTool()
end)

-- Start aura if enabled
if AuraEnabled then
    task.wait(2)
    StartAura()
end

-- Cleanup on script stop
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Attack Aura Loaded",
    Text = "Radius: " .. AURA_CONFIG.Radius .. " | Auto: " .. (AURA_CONFIG.AutoAttack and "ON" or "OFF"),
    Duration = 5
})

print("Attack Aura Script Loaded Successfully!")
print("Features:")
print("- Radius: " .. AURA_CONFIG.Radius .. " studs")
print("- Base Damage: " .. AURA_CONFIG.BaseDamage)
print("- Auto Attack: " .. tostring(AURA_CONFIG.AutoAttack))
print("- Visuals: " .. tostring(AURA_CONFIG.ShowVisuals))

-- Keep script running
while true do
    task.wait(10)
    if not UI or not UI.Parent then
        UI = CreateUI()
    end
end