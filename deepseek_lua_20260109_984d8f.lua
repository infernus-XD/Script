-- ============================================
-- MOBILE EXECUTOR SPY TOOL
-- Designed for Synapse, Krnl, Fluxus, etc.
-- ============================================

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

-- Variables
local player = Players.LocalPlayer
local spyEnabled = false
local selectedObject = nil
local currentHighlights = {}
local lastSearchResults = {}

-- ============================================
-- NOTIFICATION SYSTEM (No GUI Required)
-- ============================================

local function notify(message, duration)
    duration = duration or 3
    print("[SPY] " .. message)
    
    -- Try to show notification in CoreGui if possible
    if CoreGui then
        local notification = Instance.new("TextLabel")
        notification.Name = "SpyNotification"
        notification.Size = UDim2.new(0.7, 0, 0, 40)
        notification.Position = UDim2.new(0.15, 0, 0.02, 0)
        notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        notification.BackgroundTransparency = 0.3
        notification.TextColor3 = Color3.fromRGB(255, 255, 0)
        notification.Text = "🔍 " .. message
        notification.Font = Enum.Font.SourceSansBold
        notification.TextSize = 16
        notification.TextWrapped = true
        notification.ZIndex = 100
        notification.Parent = CoreGui
        
        task.delay(duration, function()
            if notification and notification.Parent then
                notification:Destroy()
            end
        end)
    end
end

-- ============================================
-- COMMAND SYSTEM (Executor Console)
-- ============================================

local commands = {}

-- Help command
commands.help = function()
    print("=== MOBILE SPY COMMANDS ===")
    print("spy.search <name> - Search for objects")
    print("spy.list <class> - List objects by class")
    print("spy.info <name> - Get object info")
    print("spy.tp <name> - Teleport to object")
    print("spy.highlight <name> - Highlight object")
    print("spy.unhighlight <name> - Remove highlight")
    print("spy.clear - Clear all highlights")
    print("spy.players - List all players")
    print("spy.scripts - List all scripts")
    print("spy.ws <value> - Set walkspeed")
    print("spy.jp <value> - Set jump power")
    print("spy.hh <value> - Set hip height")
    print("spy.fly - Toggle fly mode")
    print("spy.noclip - Toggle noclip")
    print("spy.refresh - Refresh character")
    print("spy.gui - Open mobile GUI")
    print("spy.close - Close all spy windows")
    print("==========================")
end

-- Search command
commands.search = function(searchTerm)
    if not searchTerm or searchTerm == "" then
        notify("Usage: spy.search <name>", 3)
        return
    end
    
    searchTerm = string.lower(searchTerm)
    local results = {}
    local count = 0
    
    local function searchRecursive(parent)
        for _, child in pairs(parent:GetChildren()) do
            if string.find(string.lower(child.Name), searchTerm, 1, true) then
                table.insert(results, child)
                count = count + 1
                if count >= 50 then break end
            end
            
            if #child:GetChildren() > 0 then
                searchRecursive(child)
                if count >= 50 then break end
            end
        end
    end
    
    searchRecursive(game)
    lastSearchResults = results
    
    notify("Found " .. #results .. " objects", 3)
    
    for i, obj in ipairs(results) do
        if i <= 10 then -- Only show first 10 results
            print(string.format("%d. %s (%s) - %s", 
                i, obj.Name, obj.ClassName, obj:GetFullName()))
        end
    end
    
    if #results > 10 then
        print("... and " .. (#results - 10) .. " more")
    end
    
    if #results > 0 then
        selectedObject = results[1]
        notify("Selected: " .. selectedObject.Name, 3)
    end
end

-- List by class
commands.list = function(className)
    local results = {}
    
    for _, obj in pairs(game:GetDescendants()) do
        if obj.ClassName == className then
            table.insert(results, obj)
            if #results >= 100 then break end
        end
    end
    
    notify("Found " .. #results .. " " .. className .. " objects", 3)
    
    for i, obj in ipairs(results) do
        if i <= 20 then
            print(string.format("%d. %s - %s", i, obj.Name, obj:GetFullName()))
        end
    end
    
    lastSearchResults = results
end

-- Info command
commands.info = function(objName)
    local target = nil
    
    if objName == "selected" and selectedObject then
        target = selectedObject
    else
        -- Search for object
        for _, obj in pairs(game:GetDescendants()) do
            if string.lower(obj.Name) == string.lower(objName) then
                target = obj
                break
            end
        end
    end
    
    if not target then
        notify("Object not found: " .. objName, 3)
        return
    end
    
    print("=== OBJECT INFO ===")
    print("Name: " .. target.Name)
    print("Class: " .. target.ClassName)
    print("Full Path: " .. target:GetFullName())
    
    if target:IsA("BasePart") then
        print("Position: " .. tostring(target.Position))
        print("Size: " .. tostring(target.Size))
        print("Anchored: " .. tostring(target.Anchored))
        print("CanCollide: " .. tostring(target.CanCollide))
        print("Transparency: " .. tostring(target.Transparency))
    elseif target:IsA("Player") then
        print("Display Name: " .. target.DisplayName)
        print("User ID: " .. tostring(target.UserId))
        print("Account Age: " .. tostring(target.AccountAge) .. " days")
    elseif target:IsA("Model") then
        print("Children: " .. #target:GetChildren())
        print("Primary Part: " .. (target.PrimaryPart and target.PrimaryPart.Name or "None"))
    end
    
    selectedObject = target
    notify("Selected: " .. target.Name, 3)
end

-- Teleport command
commands.tp = function(targetName)
    local target = nil
    local char = player.Character
    if not char then
        notify("No character found", 3)
        return
    end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        notify("No HRP found", 3)
        return
    end
    
    -- Check for special targets
    if targetName == "spawn" then
        hrp.CFrame = CFrame.new(0, 5, 0)
        notify("Teleported to spawn", 3)
        return
    end
    
    -- Search for target
    if targetName == "selected" and selectedObject then
        target = selectedObject
    else
        for _, obj in pairs(game:GetDescendants()) do
            if string.lower(obj.Name) == string.lower(targetName) then
                target = obj
                break
            end
        end
    end
    
    if not target then
        notify("Target not found: " .. targetName, 3)
        return
    end
    
    -- Teleport to target
    if target:IsA("BasePart") then
        hrp.CFrame = target.CFrame + Vector3.new(0, 5, 0)
        notify("Teleported to " .. target.Name, 3)
    elseif target:IsA("Model") then
        local part = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
        if part then
            hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)
            notify("Teleported to " .. target.Name, 3)
        else
            notify("No valid part found in model", 3)
        end
    elseif target:IsA("Player") and target.Character then
        local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
        if targetHrp then
            hrp.CFrame = targetHrp.CFrame + Vector3.new(0, 5, 0)
            notify("Teleported to player: " .. target.Name, 3)
        else
            notify("Target player has no HRP", 3)
        end
    else
        notify("Cannot teleport to this object type", 3)
    end
end

-- Highlight command
commands.highlight = function(objName)
    local target = nil
    
    if objName == "selected" and selectedObject then
        target = selectedObject
    else
        for _, obj in pairs(game:GetDescendants()) do
            if string.lower(obj.Name) == string.lower(objName) then
                target = obj
                break
            end
        end
    end
    
    if not target then
        notify("Object not found: " .. objName, 3)
        return
    end
    
    -- Remove existing highlight
    local existing = target:FindFirstChild("SpyHighlight")
    if existing then
        existing:Destroy()
    end
    
    -- Create highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "SpyHighlight"
    highlight.FillColor = Color3.fromRGB(255, 255, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 200, 0)
    highlight.OutlineTransparency = 0
    highlight.Parent = target
    
    -- Store reference
    currentHighlights[target] = highlight
    
    notify("Highlighted: " .. target.Name, 3)
    
    -- Auto-remove after 30 seconds
    task.delay(30, function()
        if highlight and highlight.Parent then
            highlight:Destroy()
            currentHighlights[target] = nil
        end
    end)
end

-- Unhighlight command
commands.unhighlight = function(objName)
    if objName == "all" then
        for target, highlight in pairs(currentHighlights) do
            if highlight and highlight.Parent then
                highlight:Destroy()
            end
        end
        currentHighlights = {}
        notify("Removed all highlights", 3)
        return
    end
    
    local target = nil
    
    if objName == "selected" and selectedObject then
        target = selectedObject
    else
        for _, obj in pairs(game:GetDescendants()) do
            if string.lower(obj.Name) == string.lower(objName) then
                target = obj
                break
            end
        end
    end
    
    if not target then
        notify("Object not found: " .. objName, 3)
        return
    end
    
    local highlight = target:FindFirstChild("SpyHighlight")
    if highlight then
        highlight:Destroy()
        currentHighlights[target] = nil
        notify("Removed highlight from " .. target.Name, 3)
    else
        notify("No highlight found on " .. target.Name, 3)
    end
end

-- Player list command
commands.players = function()
    notify("Players: " .. #Players:GetPlayers(), 3)
    for i, plr in pairs(Players:GetPlayers()) do
        print(string.format("%d. %s (ID: %d) - %s", 
            i, plr.Name, plr.UserId, plr.DisplayName))
    end
end

-- Scripts command
commands.scripts = function()
    local scripts = {}
    
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("BaseScript") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            table.insert(scripts, obj)
            if #scripts >= 100 then break end
        end
    end
    
    notify("Found " .. #scripts .. " scripts", 3)
    
    for i, script in ipairs(scripts) do
        if i <= 20 then
            print(string.format("%d. %s (%s) - %s", 
                i, script.Name, script.ClassName, script:GetFullName()))
        end
    end
    
    lastSearchResults = scripts
end

-- Walkspeed command
commands.ws = function(value)
    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    humanoid.WalkSpeed = tonumber(value) or 16
    notify("Walkspeed set to " .. humanoid.WalkSpeed, 3)
end

-- Jump power command
commands.jp = function(value)
    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    humanoid.JumpPower = tonumber(value) or 50
    notify("Jump power set to " .. humanoid.JumpPower, 3)
end

-- Hip height command
commands.hh = function(value)
    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    humanoid.HipHeight = tonumber(value) or 0
    notify("Hip height set to " .. humanoid.HipHeight, 3)
end

-- Fly command
commands.fly = function()
    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if humanoid:FindFirstChild("SpyFlyController") then
        humanoid.SpyFlyController:Destroy()
        notify("Fly mode disabled", 3)
    else
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "SpyFlyController"
        bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.P = 10000
        bodyVelocity.Parent = humanoid.RootPart or char:FindFirstChild("HumanoidRootPart")
        
        local flying = true
        local speed = 50
        
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not flying or not bodyVelocity or not bodyVelocity.Parent then
                connection:Disconnect()
                return
            end
            
            local camera = workspace.CurrentCamera
            local root = bodyVelocity.Parent
            
            if root and camera then
                local lookVector = camera.CFrame.LookVector
                local rightVector = camera.CFrame.RightVector
                local upVector = camera.CFrame.UpVector
                
                local direction = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    direction = direction + lookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    direction = direction - lookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    direction = direction + rightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    direction = direction - rightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    direction = direction + upVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    direction = direction - upVector
                end
                
                if direction.Magnitude > 0 then
                    direction = direction.Unit * speed
                end
                
                bodyVelocity.Velocity = direction
            end
        end)
        
        notify("Fly mode enabled (WASD + Space/Shift)", 3)
    end
end

-- Noclip command
commands.noclip = function()
    local char = player.Character
    if not char then return end
    
    local connection = char:FindFirstChild("SpyNoclipConnection")
    if connection then
        connection:Disconnect()
        connection:Destroy()
        notify("Noclip disabled", 3)
    else
        local noclipConnection
        noclipConnection = RunService.Stepped:Connect(function()
            if not char then
                noclipConnection:Disconnect()
                return
            end
            
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
        noclipConnection.Name = "SpyNoclipConnection"
        notify("Noclip enabled", 3)
    end
end

-- Refresh character
commands.refresh = function()
    local char = player.Character
    if char then
        char:BreakJoints()
        notify("Character refreshing...", 3)
    end
end

-- GUI command (Simple mobile GUI)
commands.gui = function()
    if CoreGui:FindFirstChild("SpyMobileGUI") then
        CoreGui.SpyMobileGUI:Destroy()
        notify("GUI closed", 3)
        return
    end
    
    -- Create simple mobile GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SpyMobileGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui
    
    -- Main frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0.8, 0)
    frame.Position = UDim2.new(0.05, 0, 0.1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    frame.BorderSizePixel = 3
    frame.BorderColor3 = Color3.fromRGB(0, 150, 255)
    frame.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.Text = "📱 EXECUTOR SPY"
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 20
    title.Parent = frame
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.2, 0, 0, 40)
    closeBtn.Position = UDim2.new(0.8, 0, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Text = "✕ CLOSE"
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 16
    closeBtn.Parent = frame
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Button container
    local buttonContainer = Instance.new("ScrollingFrame")
    buttonContainer.Size = UDim2.new(1, -10, 1, -50)
    buttonContainer.Position = UDim2.new(0, 5, 0, 45)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.ScrollBarThickness = 8
    buttonContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    buttonContainer.Parent = frame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = buttonContainer
    
    -- Common commands as buttons
    local buttonCommands = {
        {"🔍 Search Players", function() commands.players() end},
        {"🧱 Search Parts", function() commands.list("Part") end},
        {"💡 Search Lights", function() commands.list("Light") end},
        {"💻 Search Scripts", function() commands.scripts() end},
        {"🚀 Teleport to Spawn", function() commands.tp("spawn") end},
        {"⚡ Speed Boost", function() commands.ws(100) end},
        {"🕊️ Toggle Fly", function() commands.fly() end},
        {"👻 Toggle Noclip", function() commands.noclip() end},
        {"✨ Refresh Character", function() commands.refresh() end},
        {"🔦 Highlight Selected", function() if selectedObject then commands.highlight("selected") end end},
        {"❌ Clear Highlights", function() commands.unhighlight("all") end},
        {"📋 Show Help", function() commands.help() end}
    }
    
    for i, cmdInfo in ipairs(buttonCommands) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 50)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = cmdInfo[1]
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 16
        btn.Parent = buttonContainer
        
        btn.MouseButton1Click:Connect(cmdInfo[2])
    end
    
    -- Search box
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -10, 0, 40)
    searchBox.Position = UDim2.new(0, 5, 1, -45)
    searchBox.PlaceholderText = "Search object name..."
    searchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.Font = Enum.Font.SourceSans
    searchBox.TextSize = 18
    searchBox.Parent = frame
    
    local searchBtn = Instance.new("TextButton")
    searchBtn.Size = UDim2.new(1, -10, 0, 40)
    searchBtn.Position = UDim2.new(0, 5, 1, 5)
    searchBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    searchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBtn.Text = "🔍 SEARCH AND SELECT"
    searchBtn.Font = Enum.Font.SourceSansBold
    searchBtn.TextSize = 16
    searchBtn.Parent = frame
    
    searchBtn.MouseButton1Click:Connect(function()
        if searchBox.Text ~= "" then
            commands.search(searchBox.Text)
        end
    end)
    
    notify("Mobile GUI opened", 3)
end

-- Close all spy windows
commands.close = function()
    for _, gui in pairs(CoreGui:GetChildren()) do
        if string.find(gui.Name, "Spy") then
            gui:Destroy()
        end
    end
    
    for _, obj in pairs(game:GetDescendants()) do
        if obj.Name == "SpyHighlight" or obj.Name == "SpyFlyController" then
            obj:Destroy()
        end
    end
    
    currentHighlights = {}
    notify("All spy windows and effects closed", 3)
end

-- ============================================
-- MAIN EXECUTOR INTERFACE
-- ============================================

local function executeCommand(input)
    local parts = {}
    for part in string.gmatch(input, "[^%s]+") do
        table.insert(parts, part)
    end
    
    if #parts == 0 then return end
    
    local cmd = parts[1]
    local arg = parts[2] or ""
    
    if cmd == "spy" then
        if #parts >= 2 then
            local subcmd = parts[2]
            local subarg = parts[3] or ""
            
            if commands[subcmd] then
                commands[subcmd](subarg)
            else
                notify("Unknown command: " .. subcmd, 3)
                commands.help()
            end
        else
            commands.help()
        end
    elseif cmd == "help" then
        commands.help()
    elseif commands[cmd] then
        commands[cmd](arg)
    else
        notify("Type 'spy' or 'help' for commands", 3)
    end
end

-- ============================================
-- INITIALIZATION
-- ============================================

-- Auto-execute setup
spyEnabled = true

-- Create command interface in output
print("\n")
print("╔════════════════════════════════════╗")
print("║      MOBILE EXECUTOR SPY TOOL      ║")
print("║                                    ║")
print("║  Type 'spy.help' for commands      ║")
print("║  Type 'spy.gui' for mobile GUI     ║")
print("║                                    ║")
print("║  Commands:                         ║")
print("║  • spy.search <name>              ║")
print("║  • spy.tp <name>                  ║")
print("║  • spy.highlight <name>           ║")
print("║  • spy.fly                        ║")
print("║  • spy.noclip                     ║")
print("╚════════════════════════════════════╝")
print("\n")

notify("Executor Spy Tool Loaded!", 3)

-- Example usage in executor console:
-- spy.search door
-- spy.tp selected
-- spy.highlight selected
-- spy.fly
-- spy.gui

-- Return the command interface for executor
return {
    execute = executeCommand,
    commands = commands,
    notify = notify,
    help = commands.help
}