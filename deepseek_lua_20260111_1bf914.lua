-- Auto-Dodge Script with Attack Detection
-- Detects mob attacks by animations/effects and dodges automatically

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Configuration
local DODGE_CONFIG = {
    Enabled = true,
    DodgeDistance = 30, -- How far to teleport away
    DodgeCooldown = 3, -- Seconds before returning
    ReturnDelay = 3, -- Seconds to wait before returning
    DetectionRadius = 50, -- How far to look for mobs
    UseTween = true, -- Use smooth tween instead of instant teleport
    TweenDuration = 0.3, -- Seconds for dodge tween
    ShowUI = true,
    AutoDodge = true, -- Automatically dodge detected attacks
    ManualDodgeKey = Enum.KeyCode.E, -- Manual dodge key
    MobileButtons = true -- Show mobile buttons
}

-- Variables
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local isDodging = false
local lastDodgeTime = 0
local dodgeCooldown = 0
local originalPositions = {}
local detectionConnection
local mobileButtons = {}

-- Attack Animation Patterns to detect
local ATTACK_ANIMATIONS = {
    "attack", "swing", "slash", "hit", "strike", "punch", "kick",
    "smash", "crush", "shoot", "fire", "cast", "spell", "ability",
    "skill", "rage", "fury", "charge", "dash", "leap", "jump"
}

-- Attack Effect Patterns to detect
local ATTACK_EFFECTS = {
    "effect", "particle", "explosion", "blast", "wave", "shock",
    "trail", "smoke", "fire", "spark", "energy", "magic", "aura",
    "projectile", "bullet", "arrow", "missile", "orb", "ball"
}

-- Sound Patterns for attacks
local ATTACK_SOUNDS = {
    "slash", "hit", "attack", "shoot", "fire", "cast", "explode",
    "swing", "punch", "kick", "impact", "crash", "bang", "boom"
}

-- Create Mobile-Friendly UI
local function CreateMobileUI()
    if not DODGE_CONFIG.MobileButtons then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DodgeMobileUI"
    screenGui.ResetOnSpawn = false
    
    -- Dodge Button (Large, easy to press)
    local dodgeButton = Instance.new("TextButton")
    dodgeButton.Name = "DodgeButton"
    dodgeButton.Size = UDim2.new(0, 120, 0, 120)
    dodgeButton.Position = UDim2.new(1, -140, 1, -140)
    dodgeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    dodgeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    dodgeButton.Text = "DODGE"
    dodgeButton.Font = Enum.Font.GothamBold
    dodgeButton.TextSize = 18
    dodgeButton.TextScaled = true
    dodgeButton.Parent = screenGui
    
    local dodgeCorner = Instance.new("UICorner")
    dodgeCorner.CornerRadius = UDim.new(0, 60)
    dodgeCorner.Parent = dodgeButton
    
    -- Toggle Auto-Dodge Button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 120, 0, 50)
    toggleButton.Position = UDim2.new(1, -140, 1, -210)
    toggleButton.BackgroundColor3 = DODGE_CONFIG.AutoDodge and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(100, 100, 100)
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Text = DODGE_CONFIG.AutoDodge and "AUTO: ON" or "AUTO: OFF"
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 14
    toggleButton.Parent = screenGui
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 10)
    toggleCorner.Parent = toggleButton
    
    -- Status Indicator
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(0, 120, 0, 30)
    statusLabel.Position = UDim2.new(1, -140, 0, 10)
    statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    statusLabel.BackgroundTransparency = 0.5
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.Text = "READY"
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 12
    statusLabel.Parent = screenGui
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 8)
    statusCorner.Parent = statusLabel
    
    -- Button handlers
    dodgeButton.MouseButton1Click:Connect(function()
        ManualDodge()
    end)
    
    toggleButton.MouseButton1Click:Connect(function()
        DODGE_CONFIG.AutoDodge = not DODGE_CONFIG.AutoDodge
        toggleButton.BackgroundColor3 = DODGE_CONFIG.AutoDodge and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(100, 100, 100)
        toggleButton.Text = DODGE_CONFIG.AutoDodge and "AUTO: ON" : "AUTO: OFF"
    end)
    
    mobileButtons = {
        dodgeButton = dodgeButton,
        toggleButton = toggleButton,
        statusLabel = statusLabel
    }
    
    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
    end
    
    screenGui.Parent = player:WaitForChild("PlayerGui")
    return screenGui
end

-- Create PC UI
local function CreatePCUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DodgePCUI"
    screenGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 200, 0, 120)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    mainFrame.BackgroundTransparency = 0.3
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    title.TextColor3 = Color3.fromRGB(200, 150, 255)
    title.Text = "⚡ AUTO-DODGE ⚡"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = title
    
    -- Toggle Button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0.9, 0, 0, 35)
    toggleButton.Position = UDim2.new(0.05, 0, 0, 30)
    toggleButton.BackgroundColor3 = DODGE_CONFIG.Enabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Text = DODGE_CONFIG.Enabled and "AUTO-DODGE: ON" or "AUTO-DODGE: OFF"
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 12
    toggleButton.Parent = mainFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = toggleButton
    
    -- Status
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
    statusLabel.Position = UDim2.new(0.05, 0, 0, 70)
    statusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.Text = "Status: Ready"
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 11
    statusLabel.Parent = mainFrame
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 6)
    statusCorner.Parent = statusLabel
    
    -- Button handlers
    toggleButton.MouseButton1Click:Connect(function()
        DODGE_CONFIG.Enabled = not DODGE_CONFIG.Enabled
        toggleButton.BackgroundColor3 = DODGE_CONFIG.Enabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        toggleButton.Text = DODGE_CONFIG.Enabled and "AUTO-DODGE: ON" or "AUTO-DODGE: OFF"
        statusLabel.Text = DODGE_CONFIG.Enabled and "Status: Active" or "Status: Inactive"
    end)
    
    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
    end
    
    screenGui.Parent = player:WaitForChild("PlayerGui")
    return screenGui, toggleButton, statusLabel
end

-- Update mobile UI status
local function UpdateMobileStatus(text, color)
    if mobileButtons.statusLabel then
        mobileButtons.statusLabel.Text = text
        mobileButtons.statusLabel.BackgroundColor3 = color or Color3.fromRGB(40, 40, 40)
    end
end

-- Check if object is a mob (not player)
local function IsMob(object)
    if object == character then return false end
    if object:IsA("Model") then
        if object:FindFirstChild("Humanoid") then
            return true
        end
        -- Check for common mob indicators
        local name = object.Name:lower()
        if name:find("mob") or name:find("enemy") or name:find("boss") or 
           name:find("creature") or name:find("monster") or name:find("npc") then
            return true
        end
    end
    return false
end

-- Detect attack animations on mobs
local function DetectAttackAnimations()
    local attacks = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if IsMob(obj) then
            local humanoid = obj:FindFirstChild("Humanoid")
            if humanoid then
                -- Check playing animations
                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                    local animName = track.Name:lower()
                    for _, pattern in pairs(ATTACK_ANIMATIONS) do
                        if animName:find(pattern) then
                            table.insert(attacks, {
                                Source = obj,
                                Type = "Animation",
                                Name = animName,
                                Position = obj:GetPivot().Position,
                                Timestamp = tick()
                            })
                            break
                        end
                    end
                end
            end
        end
    end
    
    return attacks
end

-- Detect attack visual effects
local function DetectAttackEffects()
    local attacks = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if not obj:IsDescendantOf(character) then
            local objName = obj.Name:lower()
            
            -- Check for particle effects
            if obj:IsA("ParticleEmitter") then
                for _, pattern in pairs(ATTACK_EFFECTS) do
                    if objName:find(pattern) then
                        local parent = obj.Parent
                        if parent and IsMob(parent) then
                            table.insert(attacks, {
                                Source = parent,
                                Type = "Particle",
                                Name = objName,
                                Position = obj.Position,
                                Timestamp = tick()
                            })
                        end
                        break
                    end
                end
            end
            
            -- Check for sound effects
            if obj:IsA("Sound") then
                for _, pattern in pairs(ATTACK_SOUNDS) do
                    if objName:find(pattern) and obj.Playing then
                        local parent = obj.Parent
                        if parent and IsMob(parent) then
                            table.insert(attacks, {
                                Source = parent,
                                Type = "Sound",
                                Name = objName,
                                Position = parent:GetPivot().Position,
                                Timestamp = tick()
                            })
                        end
                        break
                    end
                end
            end
        end
    end
    
    return attacks
end

-- Calculate safe dodge position
local function CalculateDodgePosition(attackPosition)
    if not humanoidRootPart then return nil end
    
    local characterPos = humanoidRootPart.Position
    local direction = (characterPos - attackPosition).Unit
    direction = direction.Magnitude > 0 and direction or Vector3.new(1, 0, 0)
    
    -- Calculate position behind the character (away from attack)
    local dodgePos = characterPos + (direction * DODGE_CONFIG.DodgeDistance)
    
    -- Add some vertical offset to avoid getting stuck
    dodgePos = dodgePos + Vector3.new(0, 5, 0)
    
    -- Make sure position is above ground
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local raycast = workspace:Raycast(dodgePos, Vector3.new(0, -100, 0), raycastParams)
    if raycast then
        dodgePos = raycast.Position + Vector3.new(0, 5, 0)
    end
    
    return dodgePos
end

-- Smooth tween movement
local function TweenToPosition(position, duration)
    if not humanoidRootPart then return end
    
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.new(position)})
    tween:Play()
    
    -- Wait for tween to complete
    local completed = false
    tween.Completed:Connect(function()
        completed = true
    end)
    
    local startTime = tick()
    while not completed and tick() - startTime < duration + 0.5 do
        RunService.Heartbeat:Wait()
    end
    
    return completed
end

-- Instant teleport
local function TeleportToPosition(position)
    if not humanoidRootPart then return false end
    
    pcall(function()
        humanoidRootPart.CFrame = CFrame.new(position)
    end)
    
    return true
end

-- Main dodge function
local function PerformDodge(attackInfo)
    if isDodging then return false end
    if tick() - lastDodgeTime < dodgeCooldown then return false end
    
    isDodging = true
    lastDodgeTime = tick()
    
    -- Store original position
    if humanoidRootPart then
        originalPositions.dodge = humanoidRootPart.Position
        originalPositions.time = tick()
    end
    
    -- Calculate dodge position
    local dodgePos = CalculateDodgePosition(attackInfo.Position)
    if not dodgePos then
        isDodging = false
        return false
    end
    
    -- Visual feedback
    if DODGE_CONFIG.ShowUI then
        UpdateMobileStatus("DODGING!", Color3.fromRGB(255, 100, 100))
    end
    
    -- Perform dodge movement
    local success
    if DODGE_CONFIG.UseTween then
        success = TweenToPosition(dodgePos, DODGE_CONFIG.TweenDuration)
    else
        success = TeleportToPosition(dodgePos)
    end
    
    if success then
        -- Wait before returning
        task.wait(DODGE_CONFIG.ReturnDelay)
        
        -- Return to original position
        if originalPositions.dodge then
            if DODGE_CONFIG.UseTween then
                TweenToPosition(originalPositions.dodge, DODGE_CONFIG.TweenDuration)
            else
                TeleportToPosition(originalPositions.dodge)
            end
        end
        
        -- Cooldown
        dodgeCooldown = DODGE_CONFIG.DodgeCooldown
        task.wait(0.5) -- Small buffer
    end
    
    -- Reset status
    isDodging = false
    if DODGE_CONFIG.ShowUI then
        UpdateMobileStatus("READY", Color3.fromRGB(40, 200, 40))
    end
    
    return success
end

-- Manual dodge function
local function ManualDodge()
    if isDodging or not DODGE_CONFIG.Enabled then return false end
    
    -- Find nearest mob for direction
    local nearestMob = nil
    local nearestDistance = math.huge
    
    for _, obj in pairs(Workspace:GetChildren()) do
        if IsMob(obj) then
            local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
            if rootPart then
                local distance = (rootPart.Position - humanoidRootPart.Position).Magnitude
                if distance < nearestDistance and distance < DODGE_CONFIG.DetectionRadius then
                    nearestDistance = distance
                    nearestMob = obj
                end
            end
        end
    end
    
    -- Perform dodge away from nearest mob or in random direction
    local attackPos
    if nearestMob then
        local rootPart = nearestMob:FindFirstChild("HumanoidRootPart") or nearestMob:FindFirstChild("Torso")
        attackPos = rootPart and rootPart.Position or humanoidRootPart.Position + Vector3.new(10, 0, 0)
    else
        attackPos = humanoidRootPart.Position + Vector3.new(10, 0, 0)
    end
    
    return PerformDodge({
        Source = nearestMob or "Manual",
        Type = "Manual",
        Position = attackPos,
        Timestamp = tick()
    })
end

-- Main detection loop
local function StartDetection()
    if detectionConnection then
        detectionConnection:Disconnect()
    end
    
    detectionConnection = RunService.Heartbeat:Connect(function()
        if not DODGE_CONFIG.Enabled or isDodging then return end
        if not DODGE_CONFIG.AutoDodge then return end
        if tick() - lastDodgeTime < dodgeCooldown then return end
        
        -- Detect attacks
        local animationAttacks = DetectAttackAnimations()
        local effectAttacks = DetectAttackEffects()
        local allAttacks = {}
        
        for _, attack in ipairs(animationAttacks) do
            table.insert(allAttacks, attack)
        end
        
        for _, attack in ipairs(effectAttacks) do
            table.insert(allAttacks, attack)
        end
        
        -- Check if any attack is targeting player
        for _, attack in ipairs(allAttacks) do
            if attack.Source then
                local sourcePos = attack.Position
                local charPos = humanoidRootPart.Position
                local distance = (sourcePos - charPos).Magnitude
                
                -- Check if attack is within detection radius and likely targeting player
                if distance < DODGE_CONFIG.DetectionRadius then
                    -- Simple direction check (attack pointed toward player)
                    local directionToPlayer = (charPos - sourcePos).Unit
                    local attackForward = attack.Source:GetPivot().LookVector
                    
                    -- If attack is generally pointing at player, dodge
                    if directionToPlayer:Dot(attackForward) > 0.3 or distance < 15 then
                        PerformDodge(attack)
                        break
                    end
                end
            end
        end
    end)
end

-- Initialize
local mobileUI = CreateMobileUI()
local pcUI, pcToggleButton, pcStatusLabel = CreatePCUI()

-- Key binding for manual dodge
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == DODGE_CONFIG.ManualDodgeKey then
        ManualDodge()
    end
end)

-- Touch input for mobile
UserInputService.TouchStarted:Connect(function(touch, gameProcessed)
    if gameProcessed then return end
    
    -- Check if touch is on dodge button (handled by button itself)
    -- Additional touch area detection could be added here
end)

-- Handle character respawn
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    task.wait(1) -- Wait for character to stabilize
    
    -- Reset dodge state
    isDodging = false
    originalPositions = {}
    
    if DODGE_CONFIG.Enabled then
        UpdateMobileStatus("READY", Color3.fromRGB(40, 200, 40))
    end
end)

-- Start detection
if DODGE_CONFIG.Enabled then
    StartDetection()
    UpdateMobileStatus("ACTIVE", Color3.fromRGB(40, 200, 40))
end

-- Instructions
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Auto-Dodge Loaded",
    Text = "Mobile: Tap DODGE button\nPC: Press E to dodge",
    Duration = 8
})

print("========================================")
print("AUTO-DODGE SCRIPT LOADED")
print("========================================")
print("Features:")
print("- Detects mob attack animations")
print("- Detects attack visual effects")
print("- Automatic dodge when attacks detected")
print("- Manual dodge with button/key")
print("- Mobile-friendly UI")
print("========================================")
print("Controls:")
print("- Mobile: Tap DODGE button")
print("- PC: Press E key")
print("- Auto-dodge can be toggled")
print("========================================")

-- Keep script alive
while true do
    task.wait(10)
    
    -- Update cooldown
    if tick() - lastDodgeTime >= dodgeCooldown then
        dodgeCooldown = 0
    end
    
    -- UI recreation if needed
    local playerGui = player:WaitForChild("PlayerGui")
    if DODGE_CONFIG.MobileButtons and not playerGui:FindFirstChild("DodgeMobileUI") then
        mobileUI:Destroy()
        mobileUI = CreateMobileUI()
    end
    
    if not playerGui:FindFirstChild("DodgePCUI") then
        if pcUI then pcUI:Destroy() end
        pcUI, pcToggleButton, pcStatusLabel = CreatePCUI()
    end
end