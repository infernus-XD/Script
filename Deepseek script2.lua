local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

-- Store UI state to persist across respawns - MOVED TO TOP LEVEL
local movementState = {
    isMoving = false,
    shiftLockEnabled = false,
    autoTeleportEnabled = false,
    autoDungeonEnabled = false,
    autoDungeonButtonsEnabled = false,
    isMinimized = false
}

-- Game variables
local Mobs = workspace:WaitForChild("__Main"):WaitForChild("__Enemies")
local Character = player.Character or player.CharacterAdded:Wait()
local DungeonFolder = workspace:WaitForChild("__Main"):WaitForChild("__Dungeon")
local CurrentRod

-- Update character reference on respawn
player.CharacterAdded:Connect(function(newChar) 
    Character = newChar 
end)

-- Dungeon Rod Detection
local function DetectDungeonRod()
    local rod = DungeonFolder:FindFirstChild("Dungeon", true)
    if rod then
        local primary = rod:FindFirstChild("DungeonRod")
        if primary then
            CurrentRod = primary:FindFirstChild("Primary", true)
            if CurrentRod then
                print("[Movement Control] Detected DungeonRod:", CurrentRod:GetFullName())
            end
        end
    end
end

-- Monitor for dungeon rod spawns
DungeonFolder.DescendantAdded:Connect(function(obj)
    if obj.Name == "DungeonRod" then
        task.wait(0.2)
        DetectDungeonRod()
    end
end)
DetectDungeonRod()

-- Button clicking functions
local function highlightButton(button)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 3
    stroke.Color = Color3.fromRGB(0, 255, 0)
    stroke.Parent = button
end

local function pressEnterOn(button)
    GuiService.SelectedObject = button
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
end

-- Function to click dungeon buttons sequence
local function ClickDungeonButtons()
    -- Wait for UI to load
    task.wait(1)
    
    -- Method 1: Try to find gems button by structure
    local gemsButton = player:WaitForChild("PlayerGui")
        :WaitForChild("Menus")
        :WaitForChild("Dungeon")
        :WaitForChild("Create")
        :WaitForChild("Completed")
        :WaitForChild("Gems", 2)

    -- Method 2: If not found, search for any button that contains "Gems" in its text
    if not gemsButton then
        for _, gui in ipairs(player:WaitForChild("PlayerGui"):GetDescendants()) do
            if gui:IsA("TextButton") and gui.Text:lower():find("gems") then
                gemsButton = gui
                break
            end
        end
    end

    if gemsButton then
        highlightButton(gemsButton)
        pressEnterOn(gemsButton)
        print("Clicked Gems button: " .. gemsButton.Text)
    else
        print("Gems button not found")
    end

    -- Create button
    task.wait(1)
    
    -- Method 1: Try specific path first
    local createButton = player:WaitForChild("PlayerGui")
        :WaitForChild("Menus")
        :WaitForChild("Dungeon")
        :WaitForChild("Create")
        :FindFirstChild("Create", 2)

    -- Method 2: Search for Create button by text
    if not createButton then
        for _, gui in ipairs(player:WaitForChild("PlayerGui"):GetDescendants()) do
            if gui:IsA("TextButton") and gui.Text:lower():find("create") then
                createButton = gui
                break
            end
        end
    end

    if createButton then
        highlightButton(createButton)
        pressEnterOn(createButton)
        print("Clicked Create button")
    else
        print("Create button not found")
    end

    -- Join/Start button
    task.wait(1)
    
    -- Method 1: Try specific path first
    local joinButton = player:WaitForChild("PlayerGui")
        :WaitForChild("Menus")
        :WaitForChild("Dungeon")
        :WaitForChild("InDungeon")
        :WaitForChild("Start", 2)

    -- Method 2: Search for Join/Start button by text
    if not joinButton then
        for _, gui in ipairs(player:WaitForChild("PlayerGui"):GetDescendants()) do
            if gui:IsA("TextButton") and (gui.Text:lower():find("join") or gui.Text:lower():find("start")) then
                joinButton = gui
                break
            end
        end
    end

    if joinButton then
        highlightButton(joinButton)
        pressEnterOn(joinButton)
        print("Clicked Join/Start button")
    else
        print("Join/Start button not found")
    end
end

-- Function to create the UI
local function createUI()
    -- Check if UI already exists to prevent duplicates
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui and playerGui:FindFirstChild("MovementControl") then
        playerGui.MovementControl:Destroy()
    end

    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MovementControl"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = player:WaitForChild("PlayerGui")

    -- Create main frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 210)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    -- Add corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    -- Create title bar with buttons
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 20)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 6)
    titleCorner.Parent = titleBar

    -- Title label
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 120, 1, 0)
    title.Position = UDim2.new(0, 5, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Text = "Movement Control"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    -- Minimize button
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Size = UDim2.new(0, 20, 0, 15)
    minimizeButton.Position = UDim2.new(1, -45, 0, 2)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
    minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeButton.Text = "_"
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.TextSize = 12
    minimizeButton.Parent = titleBar

    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 3)
    minimizeCorner.Parent = minimizeButton

    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 20, 0, 15)
    closeButton.Position = UDim2.new(1, -20, 0, 2)
    closeButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Text = "X"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 10
    closeButton.Parent = titleBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 3)
    closeCorner.Parent = closeButton

    -- Create minimize icon (initially hidden)
    local minimizeIcon = Instance.new("TextButton")
    minimizeIcon.Size = UDim2.new(0, 30, 0, 20)
    minimizeIcon.Position = UDim2.new(0, 10, 0, 10)
    minimizeIcon.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    minimizeIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeIcon.Text = "MC"
    minimizeIcon.Font = Enum.Font.GothamBold
    minimizeIcon.TextSize = 10
    minimizeIcon.Visible = false
    minimizeIcon.Parent = screenGui

    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 4)
    iconCorner.Parent = minimizeIcon

    -- Content frame for buttons
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 1, -20)
    contentFrame.Position = UDim2.new(0, 0, 0, 20)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = frame

    -- Control variables
    local movementConnection
    local teleportConnection
    local dungeonConnection
    local dungeonButtonsConnection

    -- Create Shift Lock Toggle
    local shiftLockButton = Instance.new("TextButton")
    shiftLockButton.Size = UDim2.new(0.9, 0, 0, 25)
    shiftLockButton.Position = UDim2.new(0.05, 0, 0, 5)
    shiftLockButton.BackgroundColor3 = movementState.shiftLockEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(80, 80, 180)
    shiftLockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    shiftLockButton.Text = movementState.shiftLockEnabled and "SHIFT: ON" or "SHIFT: OFF"
    shiftLockButton.Font = Enum.Font.GothamBold
    shiftLockButton.TextSize = 10
    shiftLockButton.Parent = contentFrame

    -- Create Auto Teleport to Mob Toggle
    local teleportButton = Instance.new("TextButton")
    teleportButton.Size = UDim2.new(0.9, 0, 0, 25)
    teleportButton.Position = UDim2.new(0.05, 0, 0, 35)
    teleportButton.BackgroundColor3 = movementState.autoTeleportEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(180, 100, 50)
    teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    teleportButton.Text = movementState.autoTeleportEnabled and "TELEPORT: ON" or "TELEPORT: OFF"
    teleportButton.Font = Enum.Font.GothamBold
    teleportButton.TextSize = 10
    teleportButton.Parent = contentFrame

    -- Create Auto Dungeon Teleport Toggle
    local dungeonButton = Instance.new("TextButton")
    dungeonButton.Size = UDim2.new(0.9, 0, 0, 25)
    dungeonButton.Position = UDim2.new(0.05, 0, 0, 65)
    dungeonButton.BackgroundColor3 = movementState.autoDungeonEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 180)
    dungeonButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    dungeonButton.Text = movementState.autoDungeonEnabled and "DUNGEON: ON" or "DUNGEON: OFF"
    dungeonButton.Font = Enum.Font.GothamBold
    dungeonButton.TextSize = 10
    dungeonButton.Parent = contentFrame

    -- Create Auto Dungeon Buttons Toggle
    local dungeonButtonsButton = Instance.new("TextButton")
    dungeonButtonsButton.Size = UDim2.new(0.9, 0, 0, 25)
    dungeonButtonsButton.Position = UDim2.new(0.05, 0, 0, 95)
    dungeonButtonsButton.BackgroundColor3 = movementState.autoDungeonButtonsEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 150)
    dungeonButtonsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    dungeonButtonsButton.Text = movementState.autoDungeonButtonsEnabled and "D.BUTTONS: ON" or "D.BUTTONS: OFF"
    dungeonButtonsButton.Font = Enum.Font.GothamBold
    dungeonButtonsButton.TextSize = 10
    dungeonButtonsButton.Parent = contentFrame

    -- Create Start button
    local startButton = Instance.new("TextButton")
    startButton.Size = UDim2.new(0.9, 0, 0, 25)
    startButton.Position = UDim2.new(0.05, 0, 0, 125)
    startButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    startButton.Text = "START"
    startButton.Font = Enum.Font.GothamBold
    startButton.TextSize = 10
    startButton.Parent = contentFrame

    -- Create Stop button
    local stopButton = Instance.new("TextButton")
    stopButton.Size = UDim2.new(0.9, 0, 0, 25)
    stopButton.Position = UDim2.new(0.05, 0, 0, 155)
    stopButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopButton.Text = "STOP"
    stopButton.Font = Enum.Font.GothamBold
    stopButton.TextSize = 10
    stopButton.Parent = contentFrame

    -- Add corners to buttons
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    for _, button in pairs({startButton, stopButton, shiftLockButton, teleportButton, dungeonButton, dungeonButtonsButton}) do
        buttonCorner:Clone().Parent = button
    end

    -- Minimize/Restore functions
    local function minimizeUI()
        frame.Visible = false
        minimizeIcon.Visible = true
        movementState.isMinimized = true
    end

    local function restoreUI()
        frame.Visible = true
        minimizeIcon.Visible = false
        movementState.isMinimized = false
    end

    local function toggleMinimize()
        if movementState.isMinimized then
            restoreUI()
        else
            minimizeUI()
        end
    end

    -- Button click handlers
    minimizeButton.MouseButton1Click:Connect(toggleMinimize)
    minimizeIcon.MouseButton1Click:Connect(restoreUI)

    -- Helper Functions
    local function getCharacter()
        return player.Character
    end

    local function getHumanoid(character)
        return character and character:FindFirstChild("Humanoid")
    end

    -- Mob Functions
    local function GetAnyMob()
        local ServerFolder = Mobs:FindFirstChild("Server") or Mobs
        for _, SubFolder in ipairs(ServerFolder:GetChildren()) do
            if not SubFolder:IsA("Folder") and not SubFolder:GetAttribute("Dead") then
                return SubFolder
            end
            if SubFolder:IsA("Folder") and #SubFolder:GetChildren() > 0 then
                for _, Mob in ipairs(SubFolder:GetChildren()) do
                    if not Mob:GetAttribute("Dead") then
                        return Mob
                    end
                end
            end
        end
        return nil
    end

    local function TweenToPosition(Pos)
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            local HRP = Character.HumanoidRootPart
            local Tween = TweenService:Create(
                HRP,
                TweenInfo.new(0.3, Enum.EasingStyle.Linear),
                {CFrame = CFrame.new(Pos) * CFrame.new(0,0,6)}
            )
            Tween:Play()
            Tween.Completed:Wait()
            return true
        end
        return false
    end

    local function IsMobAlive(mob)
        return mob and mob.Parent and not mob:GetAttribute("Dead")
    end

    -- Dungeon Functions
    local function TeleportToDungeonRod()
        -- Only teleport if CurrentRod actually exists
        if CurrentRod and Character and Character:FindFirstChild("HumanoidRootPart") then
            local hrp = Character.HumanoidRootPart
            local yOffset = 1000
            local oldAnchor = hrp.Anchored
            hrp.Anchored = true
            local targetY = CurrentRod.Position.Y - yOffset
            hrp.CFrame = CFrame.new(CurrentRod.Position.X, targetY, CurrentRod.Position.Z)
            task.wait(0.2)
            hrp.Anchored = oldAnchor
            return true
        end
        return false
    end

    -- Auto Teleport System
    local function StartAutoTeleport()
        if movementState.autoTeleportEnabled then return end
        
        movementState.autoTeleportEnabled = true
        teleportButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        teleportButton.Text = "TELEPORT: ON"
        
        teleportConnection = RunService.Heartbeat:Connect(function()
            if not movementState.autoTeleportEnabled then 
                if teleportConnection then
                    teleportConnection:Disconnect()
                    teleportConnection = nil
                end
                return 
            end
            
            local Target = GetAnyMob()
            if Target and IsMobAlive(Target) then
                local TargetPos = Target:GetPivot().Position
                local PlayerPos = Character:GetPivot().Position
                local Distance = (PlayerPos - TargetPos).Magnitude
                
                if Distance > 10 then
                    TweenToPosition(TargetPos)
                    task.wait(1)
                else
                    task.wait(0.5)
                end
            else
                task.wait(1)
            end
        end)
    end

    local function StopAutoTeleport()
        if not movementState.autoTeleportEnabled then return end
        
        movementState.autoTeleportEnabled = false
        teleportButton.BackgroundColor3 = Color3.fromRGB(180, 100, 50)
        teleportButton.Text = "TELEPORT: OFF"
        
        if teleportConnection then
            teleportConnection:Disconnect()
            teleportConnection = nil
        end
    end

    -- Auto Dungeon System
    local function StartAutoDungeon()
        if movementState.autoDungeonEnabled then return end
        
        movementState.autoDungeonEnabled = true
        dungeonButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        dungeonButton.Text = "DUNGEON: ON"
        
        dungeonConnection = RunService.Heartbeat:Connect(function()
            if not movementState.autoDungeonEnabled then 
                if dungeonConnection then
                    dungeonConnection:Disconnect()
                    dungeonConnection = nil
                end
                return 
            end
            
            -- Only teleport if dungeon rod actually exists
            if CurrentRod then
                local success = TeleportToDungeonRod()
                if success then
                    dungeonButton.Text = "DUNGEON: AT PORTAL"
                    task.wait(2)
                else
                    dungeonButton.Text = "DUNGEON: SEARCHING"
                    task.wait(1)
                end
            else
                dungeonButton.Text = "DUNGEON: NO PORTAL"
                DetectDungeonRod()
                task.wait(2)
            end
        end)
    end

    local function StopAutoDungeon()
        if not movementState.autoDungeonEnabled then return end
        
        movementState.autoDungeonEnabled = false
        dungeonButton.BackgroundColor3 = Color3.fromRGB(100, 50, 180)
        dungeonButton.Text = "DUNGEON: OFF"
        
        if dungeonConnection then
            dungeonConnection:Disconnect()
            dungeonConnection = nil
        end
    end

    -- Auto Dungeon Buttons System
    local function StartAutoDungeonButtons()
        if movementState.autoDungeonButtonsEnabled then return end
        
        movementState.autoDungeonButtonsEnabled = true
        dungeonButtonsButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        dungeonButtonsButton.Text = "D.BUTTONS: ON"
        
        dungeonButtonsConnection = RunService.Heartbeat:Connect(function()
            if not movementState.autoDungeonButtonsEnabled then 
                if dungeonButtonsConnection then
                    dungeonButtonsConnection:Disconnect()
                    dungeonButtonsConnection = nil
                end
                return 
            end
            
            -- Check if we're at dungeon portal and click buttons
            if CurrentRod then
                ClickDungeonButtons()
                task.wait(5)
            else
                task.wait(2)
            end
        end)
    end

    local function StopAutoDungeonButtons()
        if not movementState.autoDungeonButtonsEnabled then return end
        
        movementState.autoDungeonButtonsEnabled = false
        dungeonButtonsButton.BackgroundColor3 = Color3.fromRGB(150, 50, 150)
        dungeonButtonsButton.Text = "D.BUTTONS: OFF"
        
        if dungeonButtonsConnection then
            dungeonButtonsConnection:Disconnect()
            dungeonButtonsConnection = nil
        end
    end

    -- Movement Functions
    local function getMovementDirection(character)
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return Vector3.new(0, 0, 0) end
        
        if movementState.shiftLockEnabled then
            local camera = workspace.CurrentCamera
            return camera.CFrame.LookVector
        else
            return rootPart.CFrame.LookVector
        end
    end

    local function updateCharacterRotation(character)
        if not movementState.shiftLockEnabled then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        
        if rootPart and humanoid then
            local camera = workspace.CurrentCamera
            local lookVector = camera.CFrame.LookVector
            local horizontalLook = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
            
            if horizontalLook.Magnitude > 0 then
                rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + horizontalLook)
            end
        end
    end

    local function startMovement()
        if movementState.isMoving then return end
        
        local character = getCharacter()
        local humanoid = getHumanoid(character)
        
        if not character or not humanoid then return end
        
        movementState.isMoving = true
        
        movementConnection = RunService.RenderStepped:Connect(function()
            if not movementState.isMoving then return end
            
            local currentCharacter = getCharacter()
            local currentHumanoid = getHumanoid(currentCharacter)
            
            if currentCharacter and currentHumanoid and currentHumanoid.Health > 0 then
                if movementState.shiftLockEnabled then
                    updateCharacterRotation(currentCharacter)
                end
                
                local moveDirection = getMovementDirection(currentCharacter)
                currentHumanoid:Move(moveDirection)
            else
                stopMovement()
            end
        end)
    end

    local function stopMovement()
        if not movementState.isMoving then return end
        
        movementState.isMoving = false
        if movementConnection then
            movementConnection:Disconnect()
            movementConnection = nil
        end
        
        local character = getCharacter()
        local humanoid = getHumanoid(character)
        if humanoid then
            humanoid:Move(Vector3.new(0, 0, 0))
        end
    end

    -- Toggle Functions
    local function toggleShiftLock()
        movementState.shiftLockEnabled = not movementState.shiftLockEnabled
        
        if movementState.shiftLockEnabled then
            shiftLockButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
            shiftLockButton.Text = "SHIFT: ON"
        else
            shiftLockButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
            shiftLockButton.Text = "SHIFT: OFF"
        end
    end

    local function toggleAutoTeleport()
        if movementState.autoTeleportEnabled then
            StopAutoTeleport()
        else
            StartAutoTeleport()
        end
    end

    local function toggleAutoDungeon()
        if movementState.autoDungeonEnabled then
            StopAutoDungeon()
        else
            StartAutoDungeon()
        end
    end

    local function toggleAutoDungeonButtons()
        if movementState.autoDungeonButtonsEnabled then
            StopAutoDungeonButtons()
        else
            StartAutoDungeonButtons()
        end
    end

    -- Button Events
    shiftLockButton.MouseButton1Click:Connect(toggleShiftLock)
    teleportButton.MouseButton1Click:Connect(toggleAutoTeleport)
    dungeonButton.MouseButton1Click:Connect(toggleAutoDungeon)
    dungeonButtonsButton.MouseButton1Click:Connect(toggleAutoDungeonButtons)
    startButton.MouseButton1Click:Connect(startMovement)
    stopButton.MouseButton1Click:Connect(stopMovement)
    
    -- Close button - stops all functions and removes UI
    closeButton.MouseButton1Click:Connect(function()
        stopMovement()
        StopAutoTeleport()
        StopAutoDungeon()
        StopAutoDungeonButtons()
        screenGui:Destroy()
    end)

    -- Make window draggable
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
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
            update(input)
        end
    end)

    -- Auto-start functions based on saved state
    if movementState.autoTeleportEnabled then
        task.wait(1)
        StartAutoTeleport()
    end
    
    if movementState.autoDungeonEnabled then
        task.wait(1)
        StartAutoDungeon()
    end
    
    if movementState.autoDungeonButtonsEnabled then
        task.wait(1)
        StartAutoDungeonButtons()
    end
    
    if movementState.isMoving then
        task.wait(1)
        startMovement()
    end

    -- Clean up
    screenGui.Destroying:Connect(function()
        stopMovement()
        StopAutoTeleport()
        StopAutoDungeon()
        StopAutoDungeonButtons()
    end)
    
    return {
        stopMovement = stopMovement,
        startMovement = startMovement,
        StartAutoTeleport = StartAutoTeleport,
        StopAutoTeleport = StopAutoTeleport,
        StartAutoDungeon = StartAutoDungeon,
        StopAutoDungeon = StopAutoDungeon,
        StartAutoDungeonButtons = StartAutoDungeonButtons,
        StopAutoDungeonButtons = StopAutoDungeonButtons,
        screenGui = screenGui
    }
end

-- Initialize UI
local uiControls = createUI()

-- Handle character respawns (FIXED PERSISTENCE)
player.CharacterAdded:Connect(function(character)
    Character = character
    character:WaitForChild("Humanoid")
    
    -- Wait for character to fully load
    task.wait(2)
    
    -- FIXED: Restart functions based on saved state (buttons stay on)
    if movementState.isMoving then
        uiControls.startMovement()
    end
    
    if movementState.autoTeleportEnabled then
        uiControls.StartAutoTeleport()
    end
    
    if movementState.autoDungeonEnabled then
        uiControls.StartAutoDungeon()
    end
    
    if movementState.autoDungeonButtonsEnabled then
        uiControls.StartAutoDungeonButtons()
    end
    
    -- Recreate UI if it was destroyed (with maintained states)
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui or not playerGui:FindFirstChild("MovementControl") then
        task.wait(1)
        uiControls = createUI()
    end
end)

player.CharacterRemoving:Connect(function()
    uiControls.stopMovement()
    uiControls.StopAutoTeleport()
    uiControls.StopAutoDungeon()
    uiControls.StopAutoDungeonButtons()
end)

-- UI Persistence System
while true do
    task.wait(5)
    
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui or not playerGui:FindFirstChild("MovementControl") then
        uiControls = createUI()
    end
end