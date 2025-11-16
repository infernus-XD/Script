--// UI Area Scanner - Finds ALL UI Elements Where You Click
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

print("=== UI AREA SCANNER LOADED ===")

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UIAreaScanner"
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 400)
MainFrame.Position = UDim2.new(0.5, -275, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 2
MainFrame.Parent = ScreenGui

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(100, 200, 255)
Title.Text = "🖱️ UI AREA SCANNER - CLICK TO FIND ALL UI ELEMENTS"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.Parent = TitleBar

-- Status label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 40)
StatusLabel.Position = UDim2.new(0, 10, 0, 35)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
StatusLabel.Text = "Status: Ready - Click anywhere to scan for UI elements"
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextWrapped = true
StatusLabel.Parent = MainFrame

-- Settings
local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(1, -20, 0, 70)
SettingsFrame.Position = UDim2.new(0, 10, 0, 80)
SettingsFrame.BackgroundTransparency = 1
SettingsFrame.Parent = MainFrame

local ScanRadiusLabel = Instance.new("TextLabel")
ScanRadiusLabel.Size = UDim2.new(0.4, 0, 0, 25)
ScanRadiusLabel.Position = UDim2.new(0, 0, 0, 0)
ScanRadiusLabel.BackgroundTransparency = 1
ScanRadiusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ScanRadiusLabel.Text = "Scan Radius: 50 pixels"
ScanRadiusLabel.Font = Enum.Font.Gotham
ScanRadiusLabel.TextSize = 11
ScanRadiusLabel.TextXAlignment = Enum.TextXAlignment.Left
ScanRadiusLabel.Parent = SettingsFrame

local ScanRadiusSlider = Instance.new("TextButton")
ScanRadiusSlider.Size = UDim2.new(0.6, 0, 0, 25)
ScanRadiusSlider.Position = UDim2.new(0.4, 0, 0, 0)
ScanRadiusSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
ScanRadiusSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanRadiusSlider.Text = "Adjust Radius"
ScanRadiusSlider.Font = Enum.Font.Gotham
ScanRadiusSlider.TextSize = 11
ScanRadiusSlider.Parent = SettingsFrame

local FilterLabel = Instance.new("TextLabel")
FilterLabel.Size = UDim2.new(0.4, 0, 0, 25)
FilterLabel.Position = UDim2.new(0, 0, 0, 30)
FilterLabel.BackgroundTransparency = 1
FilterLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FilterLabel.Text = "UI Types: All"
FilterLabel.Font = Enum.Font.Gotham
FilterLabel.TextSize = 11
FilterLabel.TextXAlignment = Enum.TextXAlignment.Left
FilterLabel.Parent = SettingsFrame

local FilterButton = Instance.new("TextButton")
FilterButton.Size = UDim2.new(0.6, 0, 0, 25)
FilterButton.Position = UDim2.new(0.4, 0, 0, 30)
FilterButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
FilterButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FilterButton.Text = "Change Filter"
FilterButton.Font = Enum.Font.Gotham
FilterButton.TextSize = 11
FilterButton.Parent = SettingsFrame

-- Buttons
local ButtonsFrame = Instance.new("Frame")
ButtonsFrame.Size = UDim2.new(1, -20, 0, 60)
ButtonsFrame.Position = UDim2.new(0, 10, 0, 155)
ButtonsFrame.BackgroundTransparency = 1
ButtonsFrame.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.48, 0, 0, 25)
ToggleButton.Position = UDim2.new(0, 0, 0, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "ENABLE SCANNER"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 11
ToggleButton.Parent = ButtonsFrame

local ClearButton = Instance.new("TextButton")
ClearButton.Size = UDim2.new(0.48, 0, 0, 25)
ClearButton.Position = UDim2.new(0.52, 0, 0, 0)
ClearButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
ClearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearButton.Text = "Clear Results"
ClearButton.Font = Enum.Font.Gotham
ClearButton.TextSize = 11
ClearButton.Parent = ButtonsFrame

local CopyAllButton = Instance.new("TextButton")
CopyAllButton.Size = UDim2.new(1, 0, 0, 25)
CopyAllButton.Position = UDim2.new(0, 0, 0, 30)
CopyAllButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
CopyAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyAllButton.Text = "Copy All Paths to Clipboard"
CopyAllButton.Font = Enum.Font.Gotham
CopyAllButton.TextSize = 11
CopyAllButton.Parent = ButtonsFrame

-- Results list
local ResultsFrame = Instance.new("ScrollingFrame")
ResultsFrame.Size = UDim2.new(1, -20, 1, -230)
ResultsFrame.Position = UDim2.new(0, 10, 0, 220)
ResultsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ResultsFrame.BorderSizePixel = 1
ResultsFrame.ScrollBarThickness = 8
ResultsFrame.Parent = MainFrame

local ResultsLayout = Instance.new("UIListLayout")
ResultsLayout.Padding = UDim.new(0, 2)
ResultsLayout.Parent = ResultsFrame

-- Variables
local scannerEnabled = false
local scanRadius = 50
local allPaths = {}
local inputConnection = nil
local highlightFrame = nil
local currentFilter = "All"

-- UI Classes we want to detect
local UIClasses = {
    "TextButton", "ImageButton", "TextLabel", "ImageLabel", "TextBox",
    "ScrollingFrame", "Frame", "CanvasGroup", "ViewportFrame",
    "ScreenGui", "SurfaceGui", "BillboardGui"
}

-- Function to get full path of an object
function GetFullPath(obj)
    local path = {}
    local current = obj
    while current and current ~= game do
        table.insert(path, 1, current.Name)
        current = current.Parent
    end
    return "game" .. (#path > 0 and ("." .. table.concat(path, ".")) or "")
end

-- Function to check if position is within bounds of GUI object
function IsPositionInGUIObject(position, guiObject)
    if not guiObject:IsA("GuiObject") then return false end
    if not guiObject.Visible then return false end
    
    local absPos = guiObject.AbsolutePosition
    local absSize = guiObject.AbsoluteSize
    
    return position.X >= absPos.X - scanRadius and 
           position.X <= absPos.X + absSize.X + scanRadius and
           position.Y >= absPos.Y - scanRadius and 
           position.Y <= absPos.Y + absSize.Y + scanRadius
end

-- Function to recursively find ALL UI elements near position
function FindAllUIElementsNearPosition(position, gui, foundElements)
    foundElements = foundElements or {}
    
    for _, child in ipairs(gui:GetChildren()) do
        if child:IsA("GuiObject") then
            if IsPositionInGUIObject(position, child) then
                -- Check if this is a UI class we care about
                local isUIClass = false
                for _, className in ipairs(UIClasses) do
                    if child.ClassName == className then
                        isUIClass = true
                        break
                    end
                end
                
                if isUIClass then
                    -- Apply filter
                    local shouldAdd = true
                    if currentFilter == "Buttons" and not (child:IsA("TextButton") or child:IsA("ImageButton")) then
                        shouldAdd = false
                    elseif currentFilter == "Text" and not (child:IsA("TextLabel") or child:IsA("TextBox")) then
                        shouldAdd = false
                    elseif currentFilter == "Images" and not (child:IsA("ImageLabel") or child:IsA("ImageButton")) then
                        shouldAdd = false
                    elseif currentFilter == "Frames" and not (child:IsA("Frame") or child:IsA("ScrollingFrame")) then
                        shouldAdd = false
                    end
                    
                    if shouldAdd then
                        -- Calculate distance for sorting
                        local centerX = child.AbsolutePosition.X + (child.AbsoluteSize.X / 2)
                        local centerY = child.AbsolutePosition.Y + (child.AbsoluteSize.Y / 2)
                        local distance = math.sqrt((position.X - centerX)^2 + (position.Y - centerY)^2)
                        
                        table.insert(foundElements, {
                            Object = child,
                            Distance = distance
                        })
                    end
                end
            end
            
            -- Recursively check children
            FindAllUIElementsNearPosition(position, child, foundElements)
            
        elseif child:IsA("ScreenGui") or child:IsA("SurfaceGui") or child:IsA("BillboardGui") then
            FindAllUIElementsNearPosition(position, child, foundElements)
        end
    end
    
    return foundElements
end

-- Function to scan ALL GUIs for UI elements near position
function ScanForUIElements(position)
    local allFoundElements = {}
    
    -- Scan PlayerGui
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        local playerElements = FindAllUIElementsNearPosition(position, playerGui)
        for _, element in ipairs(playerElements) do
            table.insert(allFoundElements, element)
        end
    end
    
    -- Scan StarterGui
    local starterGui = game:GetService("StarterGui")
    local starterElements = FindAllUIElementsNearPosition(position, starterGui)
    for _, element in ipairs(starterElements) do
        table.insert(allFoundElements, element)
    end
    
    -- Scan CoreGui (if accessible)
    local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if success and coreGui then
        local coreElements = FindAllUIElementsNearPosition(position, coreGui)
        for _, element in ipairs(coreElements) do
            table.insert(allFoundElements, element)
        end
    end
    
    -- Sort by distance (closest first)
    table.sort(allFoundElements, function(a, b)
        return a.Distance < b.Distance
    end)
    
    return allFoundElements
end

-- Function to add result to the list
function AddResult(object, distance)
    local path = GetFullPath(object)
    local className = object.ClassName
    
    -- Store path for copy all function
    table.insert(allPaths, path)
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 55)
    button.Position = UDim2.new(0, 5, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    -- Color code by type
    if object:IsA("TextButton") or object:IsA("ImageButton") then
        button.BackgroundColor3 = Color3.fromRGB(60, 80, 50)  -- Green for buttons
    elseif object:IsA("TextLabel") or object:IsA("TextBox") then
        button.BackgroundColor3 = Color3.fromRGB(50, 60, 80)  -- Blue for text
    elseif object:IsA("ImageLabel") then
        button.BackgroundColor3 = Color3.fromRGB(80, 60, 50)  -- Orange for images
    end
    
    local distanceText = string.format("Distance: %.0fpx", distance)
    button.Text = "📄 " .. object.Name .. " (" .. className .. ")\n" .. path .. "\n" .. distanceText
    button.Font = Enum.Font.Code
    button.TextSize = 10
    button.TextWrapped = true
    button.AutoButtonColor = true
    button.Parent = ResultsFrame
    
    -- Left click to copy path
    button.MouseButton1Click:Connect(function()
        local success = pcall(function()
            setclipboard(path)
        end)
        
        if success then
            button.Text = "✓ COPIED!\n" .. path
            button.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
            task.wait(1.5)
            button.Text = "📄 " .. object.Name .. " (" .. className .. ")\n" .. path .. "\n" .. distanceText
            -- Reset to original color
            if object:IsA("TextButton") or object:IsA("ImageButton") then
                button.BackgroundColor3 = Color3.fromRGB(60, 80, 50)
            elseif object:IsA("TextLabel") or object:IsA("TextBox") then
                button.BackgroundColor3 = Color3.fromRGB(50, 60, 80)
            elseif object:IsA("ImageLabel") then
                button.BackgroundColor3 = Color3.fromRGB(80, 60, 50)
            else
                button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            end
        else
            print("[UI SCANNER] Path: " .. path)
        end
    end)
    
    -- Right click for more info
    button.MouseButton2Click:Connect(function()
        print("=== UI ELEMENT INFO ===")
        print("Name: " .. object.Name)
        print("Class: " .. className) 
        print("Path: " .. path)
        print("Distance from click: " .. string.format("%.0fpx", distance))
        print("Parent: " .. (object.Parent and object.Parent.Name or "None"))
        
        -- UI-specific info
        if object:IsA("GuiObject") then
            print("Absolute Position: " .. tostring(object.AbsolutePosition))
            print("Absolute Size: " .. tostring(object.AbsoluteSize))
            print("Visible: " .. tostring(object.Visible))
            
            if object:IsA("TextButton") or object:IsA("TextLabel") or object:IsA("TextBox") then
                print("Text: " .. tostring(object.Text))
                print("Text Color: " .. tostring(object.TextColor3))
                print("Text Size: " .. tostring(object.TextSize))
            end
            
            if object:IsA("ImageButton") or object:IsA("ImageLabel") then
                print("Image: " .. tostring(object.Image))
            end
        end
    end)
    
    -- Update canvas size
    task.spawn(function()
        task.wait(0.1)
        local totalHeight = 0
        for _, child in ipairs(ResultsFrame:GetChildren()) do
            if child:IsA("TextButton") then
                totalHeight = totalHeight + child.Size.Y.Offset + 2
            end
        end
        ResultsFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 10)
    end)
end

-- Function to handle area scan
function HandleAreaScan(input)
    if not scannerEnabled or input.UserInputType ~= Enum.UserInputType.MouseButton1 then 
        return 
    end
    
    local mouse = player:GetMouse()
    local clickPosition = Vector2.new(mouse.X, mouse.Y)
    
    StatusLabel.Text = "Status: Scanning area around " .. math.floor(clickPosition.X) .. ", " .. math.floor(clickPosition.Y) .. "..."
    
    -- Scan for all UI elements in the area
    local foundElements = ScanForUIElements(clickPosition)
    
    if #foundElements > 0 then
        -- Clear previous results
        for _, child in ipairs(ResultsFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        allPaths = {}
        
        -- Add new results
        for _, elementInfo in ipairs(foundElements) do
            AddResult(elementInfo.Object, elementInfo.Distance)
        end
        
        StatusLabel.Text = "Status: Found " .. #foundElements .. " UI elements near click position"
        Title.Text = "🖱️ UI AREA SCANNER - FOUND " .. #foundElements .. " ELEMENTS"
    else
        StatusLabel.Text = "Status: No UI elements found in " .. scanRadius .. "px radius"
    end
end

-- Function to enable scanner
function EnableScanner()
    if scannerEnabled then return end
    
    scannerEnabled = true
    ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    ToggleButton.Text = "DISABLE SCANNER"
    StatusLabel.Text = "Status: Scanner ENABLED - Click anywhere to find UI elements!"
    
    -- Connect input event
    if inputConnection then
        inputConnection:Disconnect()
    end
    
    inputConnection = UserInputService.InputBegan:Connect(HandleAreaScan)
    
    print("[UI SCANNER] Area scanner enabled - click anywhere to find UI elements")
end

-- Function to disable scanner
function DisableScanner()
    if not scannerEnabled then return end
    
    scannerEnabled = false
    ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
    ToggleButton.Text = "ENABLE SCANNER"
    StatusLabel.Text = "Status: Scanner DISABLED"
    
    -- Disconnect input event
    if inputConnection then
        inputConnection:Disconnect()
        inputConnection = nil
    end
    
    print("[UI SCANNER] Area scanner disabled")
end

-- Function to adjust scan radius
function AdjustRadius()
    scanRadius = scanRadius + 25
    if scanRadius > 200 then
        scanRadius = 25
    end
    ScanRadiusLabel.Text = "Scan Radius: " .. scanRadius .. " pixels"
    StatusLabel.Text = "Status: Scan radius set to " .. scanRadius .. "px"
end

-- Function to change filter
function ChangeFilter()
    local filters = {"All", "Buttons", "Text", "Images", "Frames"}
    local currentIndex = 1
    for i, filter in ipairs(filters) do
        if filter == currentFilter then
            currentIndex = i
            break
        end
    end
    
    currentIndex = currentIndex + 1
    if currentIndex > #filters then
        currentIndex = 1
    end
    
    currentFilter = filters[currentIndex]
    FilterLabel.Text = "UI Types: " .. currentFilter
    StatusLabel.Text = "Status: Filter set to " .. currentFilter
end

-- Function to clear results
function ClearResults()
    for _, child in ipairs(ResultsFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    allPaths = {}
    StatusLabel.Text = "Status: Results cleared"
    Title.Text = "🖱️ UI AREA SCANNER - CLICK TO FIND ALL UI ELEMENTS"
end

-- Function to copy all paths
function CopyAllPaths()
    if #allPaths == 0 then
        StatusLabel.Text = "Status: No paths to copy!"
        return
    end
    
    local allPathsText = table.concat(allPaths, "\n")
    local success = pcall(function()
        setclipboard(allPathsText)
    end)
    
    if success then
        StatusLabel.Text = "Status: Copied " .. #allPaths .. " paths to clipboard!"
        CopyAllButton.Text = "✓ COPIED " .. #allPaths .. " PATHS"
        CopyAllButton.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
        task.wait(2)
        CopyAllButton.Text = "Copy All Paths to Clipboard"
        CopyAllButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
    else
        StatusLabel.Text = "Status: Failed to copy paths"
        print("[UI SCANNER] All Paths:\n" .. allPathsText)
    end
end

-- Button connections
ToggleButton.MouseButton1Click:Connect(function()
    if scannerEnabled then
        DisableScanner()
    else
        EnableScanner()
    end
end)

ClearButton.MouseButton1Click:Connect(ClearResults)
CopyAllButton.MouseButton1Click:Connect(CopyAllPaths)
ScanRadiusSlider.MouseButton1Click:Connect(AdjustRadius)
FilterButton.MouseButton1Click:Connect(ChangeFilter)

-- Make UI draggable
local dragging = false
local dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Auto-enable scanner
task.spawn(function()
    task.wait(1)
    EnableScanner()
end)

print("=== UI AREA SCANNER READY ===")
print("Features:")
print("- Click anywhere to scan for ALL UI elements in that area")
print("- Adjustable scan radius (25px to 200px)")
print("- Filter by UI type (Buttons, Text, Images, Frames)")
print("- Color-coded results by element type")
print("- Shows distance from click position")
print("- Copy individual or all paths")

-- Keybind to toggle scanner
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F8 then
        if scannerEnabled then
            DisableScanner()
        else
            EnableScanner()
        end
    end
end)