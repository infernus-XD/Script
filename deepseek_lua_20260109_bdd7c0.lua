-- Roblox Scripting Explorer v4.0 (Fixed with Minimize)
-- For development & debugging in executors

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local gui = nil
local minimizedGui = nil
local isMinimized = false
local selectedObject = nil
local currentHighlights = {}
local clickLog = {}  -- To store click events
local isLoggingClicks = false
local hookConnections = {}

-- Simple UI Creation
local function createMainUI()
    if gui then gui:Destroy() end
    if minimizedGui then minimizedGui:Destroy() end
    
    gui = Instance.new("ScreenGui")
    gui.Name = "ScriptingExplorer"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")
    
    -- Main Container
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.9, 0, 0.8, 0)
    mainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
    mainFrame.Visible = true
    mainFrame.Parent = gui
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    titleBar.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(100, 180, 255)
    title.Text = "🔧 SCRIPTING EXPLORER"
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    -- Title bar buttons container
    local titleButtons = Instance.new("Frame")
    titleButtons.Name = "TitleButtons"
    titleButtons.Size = UDim2.new(0.4, 0, 1, 0)
    titleButtons.Position = UDim2.new(0.6, 0, 0, 0)
    titleButtons.BackgroundTransparency = 1
    titleButtons.Parent = titleBar
    
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0.3, 0, 1, 0)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
    minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeButton.Text = "➖ MIN"
    minimizeButton.Font = Enum.Font.SourceSansBold
    minimizeButton.TextSize = 12
    minimizeButton.Parent = titleButtons
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0.3, 0, 1, 0)
    closeButton.Position = UDim2.new(0.35, 5, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Text = "✕ CLOSE"
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 12
    closeButton.Parent = titleButtons
    
    -- Tabs Container
    local tabsContainer = Instance.new("Frame")
    tabsContainer.Name = "TabsContainer"
    tabsContainer.Size = UDim2.new(1, 0, 0, 40)
    tabsContainer.Position = UDim2.new(0, 0, 0, 40)
    tabsContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    tabsContainer.Parent = mainFrame
    
    local tabs = {}
    local tabNames = {"📁 Explorer", "📡 Click Logger", "⚙️ Functions"}
    
    for i, tabName in ipairs(tabNames) do
        local tab = Instance.new("TextButton")
        tab.Name = "Tab" .. i
        tab.Size = UDim2.new(1/#tabNames, 0, 1, 0)
        tab.Position = UDim2.new((i-1) * (1/#tabNames), 0, 0, 0)
        tab.BackgroundColor3 = i == 1 and Color3.fromRGB(50, 50, 60) or Color3.fromRGB(40, 40, 50)
        tab.TextColor3 = Color3.fromRGB(220, 220, 220)
        tab.Text = tabName
        tab.Font = Enum.Font.SourceSans
        tab.TextSize = 14
        tab.BorderSizePixel = 0
        tab.Parent = tabsContainer
        table.insert(tabs, tab)
    end
    
    -- Content Area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, 0, 1, -80)
    contentArea.Position = UDim2.new(0, 0, 0, 80)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainFrame
    
    -- ====== EXPLORER TAB ======
    local explorerTab = Instance.new("Frame")
    explorerTab.Name = "ExplorerTab"
    explorerTab.Size = UDim2.new(1, 0, 1, 0)
    explorerTab.BackgroundTransparency = 1
    explorerTab.Visible = true
    explorerTab.Parent = contentArea
    
    -- Search Section
    local searchSection = Instance.new("Frame")
    searchSection.Name = "SearchSection"
    searchSection.Size = UDim2.new(1, -20, 0, 50)
    searchSection.Position = UDim2.new(0, 10, 0, 10)
    searchSection.BackgroundTransparency = 1
    searchSection.Parent = explorerTab
    
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(0.6, 0, 0, 35)
    searchBox.PlaceholderText = "Search objects by name..."
    searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    searchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.Font = Enum.Font.SourceSans
    searchBox.TextSize = 16
    searchBox.Parent = searchSection
    
    local searchButton = Instance.new("TextButton")
    searchButton.Name = "SearchButton"
    searchButton.Size = UDim2.new(0.15, 0, 0, 35)
    searchButton.Position = UDim2.new(0.6, 5, 0, 0)
    searchButton.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
    searchButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchButton.Text = "SEARCH"
    searchButton.Font = Enum.Font.SourceSansBold
    searchButton.TextSize = 14
    searchButton.Parent = searchSection
    
    local clearSearchButton = Instance.new("TextButton")
    clearSearchButton.Name = "ClearSearchButton"
    clearSearchButton.Size = UDim2.new(0.15, 0, 0, 35)
    clearSearchButton.Position = UDim2.new(0.75, 5, 0, 0)
    clearSearchButton.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
    clearSearchButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearSearchButton.Text = "CLEAR"
    clearSearchButton.Font = Enum.Font.SourceSans
    clearSearchButton.TextSize = 14
    clearSearchButton.Parent = searchSection
    
    -- Results Frame
    local resultsFrame = Instance.new("ScrollingFrame")
    resultsFrame.Name = "ResultsFrame"
    resultsFrame.Size = UDim2.new(1, -20, 0.5, -10)
    resultsFrame.Position = UDim2.new(0, 10, 0, 60)
    resultsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    resultsFrame.BorderSizePixel = 1
    resultsFrame.BorderColor3 = Color3.fromRGB(60, 60, 70)
    resultsFrame.ScrollBarThickness = 8
    resultsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    resultsFrame.Parent = explorerTab
    
    local resultsLayout = Instance.new("UIListLayout")
    resultsLayout.Padding = UDim.new(0, 2)
    resultsLayout.Parent = resultsFrame
    
    -- Info Panel
    local infoPanel = Instance.new("ScrollingFrame")
    infoPanel.Name = "InfoPanel"
    infoPanel.Size = UDim2.new(1, -20, 0.5, -70)
    infoPanel.Position = UDim2.new(0, 10, 0.5, 10)
    infoPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    infoPanel.BorderSizePixel = 1
    infoPanel.BorderColor3 = Color3.fromRGB(60, 60, 70)
    infoPanel.ScrollBarThickness = 8
    infoPanel.AutomaticCanvasSize = Enum.AutomaticSize.Y
    infoPanel.Parent = explorerTab
    
    local infoLayout = Instance.new("UIListLayout")
    infoLayout.Padding = UDim.new(0, 5)
    infoLayout.Parent = infoPanel
    
    -- Action Buttons
    local actionButtons = Instance.new("Frame")
    actionButtons.Name = "ActionButtons"
    actionButtons.Size = UDim2.new(1, -20, 0, 40)
    actionButtons.Position = UDim2.new(0, 10, 1, -50)
    actionButtons.BackgroundTransparency = 1
    actionButtons.Parent = explorerTab
    
    local copyPathButton = Instance.new("TextButton")
    copyPathButton.Name = "CopyPathButton"
    copyPathButton.Size = UDim2.new(0.3, -5, 1, 0)
    copyPathButton.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
    copyPathButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyPathButton.Text = "📋 Copy Path"
    copyPathButton.Font = Enum.Font.SourceSansBold
    copyPathButton.TextSize = 14
    copyPathButton.Parent = actionButtons
    
    local highlightButton = Instance.new("TextButton")
    highlightButton.Name = "HighlightButton"
    highlightButton.Size = UDim2.new(0.3, -5, 1, 0)
    highlightButton.Position = UDim2.new(0.3, 5, 0, 0)
    highlightButton.BackgroundColor3 = Color3.fromRGB(200, 160, 60)
    highlightButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    highlightButton.Text = "🔦 Highlight"
    highlightButton.Font = Enum.Font.SourceSansBold
    highlightButton.TextSize = 14
    highlightButton.Parent = actionButtons
    
    local clearHighlightsButton = Instance.new("TextButton")
    clearHighlightsButton.Name = "ClearHighlightsButton"
    clearHighlightsButton.Size = UDim2.new(0.3, -5, 1, 0)
    clearHighlightsButton.Position = UDim2.new(0.6, 5, 0, 0)
    clearHighlightsButton.BackgroundColor3 = Color3.fromRGB(180, 80, 80)
    clearHighlightsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearHighlightsButton.Text = "🗑️ Clear All"
    clearHighlightsButton.Font = Enum.Font.SourceSansBold
    clearHighlightsButton.TextSize = 14
    clearHighlightsButton.Parent = actionButtons
    
    -- ====== CLICK LOGGER TAB ======
    local clickLoggerTab = Instance.new("Frame")
    clickLoggerTab.Name = "ClickLoggerTab"
    clickLoggerTab.Size = UDim2.new(1, 0, 1, 0)
    clickLoggerTab.BackgroundTransparency = 1
    clickLoggerTab.Visible = false
    clickLoggerTab.Parent = contentArea
    
    local clickLoggerHeader = Instance.new("TextLabel")
    clickLoggerHeader.Name = "ClickLoggerHeader"
    clickLoggerHeader.Size = UDim2.new(1, -20, 0, 40)
    clickLoggerHeader.Position = UDim2.new(0, 10, 0, 10)
    clickLoggerHeader.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    clickLoggerHeader.TextColor3 = Color3.fromRGB(220, 220, 220)
    clickLoggerHeader.Text = "📡 CLICK EVENT LOGGER"
    clickLoggerHeader.Font = Enum.Font.SourceSansBold
    clickLoggerHeader.TextSize = 18
    clickLoggerHeader.Parent = clickLoggerTab
    
    local clickControls = Instance.new("Frame")
    clickControls.Name = "ClickControls"
    clickControls.Size = UDim2.new(1, -20, 0, 40)
    clickControls.Position = UDim2.new(0, 10, 0, 60)
    clickControls.BackgroundTransparency = 1
    clickControls.Parent = clickLoggerTab
    
    local startLoggingButton = Instance.new("TextButton")
    startLoggingButton.Name = "StartLoggingButton"
    startLoggingButton.Size = UDim2.new(0.3, 0, 1, 0)
    startLoggingButton.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
    startLoggingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    startLoggingButton.Text = "▶️ Start Logging"
    startLoggingButton.Font = Enum.Font.SourceSansBold
    startLoggingButton.TextSize = 14
    startLoggingButton.Parent = clickControls
    
    local stopLoggingButton = Instance.new("TextButton")
    stopLoggingButton.Name = "StopLoggingButton"
    stopLoggingButton.Size = UDim2.new(0.3, 0, 1, 0)
    stopLoggingButton.Position = UDim2.new(0.35, 10, 0, 0)
    stopLoggingButton.BackgroundColor3 = Color3.fromRGB(180, 80, 80)
    stopLoggingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopLoggingButton.Text = "⏹️ Stop Logging"
    stopLoggingButton.Font = Enum.Font.SourceSansBold
    stopLoggingButton.TextSize = 14
    stopLoggingButton.Parent = clickControls
    
    local clearLogButton = Instance.new("TextButton")
    clearLogButton.Name = "ClearLogButton"
    clearLogButton.Size = UDim2.new(0.3, 0, 1, 0)
    clearLogButton.Position = UDim2.new(0.7, 10, 0, 0)
    clearLogButton.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
    clearLogButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearLogButton.Text = "🗑️ Clear Log"
    clearLogButton.Font = Enum.Font.SourceSansBold
    clearLogButton.TextSize = 14
    clearLogButton.Parent = clickControls
    
    local clickLogList = Instance.new("ScrollingFrame")
    clickLogList.Name = "ClickLogList"
    clickLogList.Size = UDim2.new(1, -20, 1, -120)
    clickLogList.Position = UDim2.new(0, 10, 0, 110)
    clickLogList.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    clickLogList.BorderSizePixel = 1
    clickLogList.BorderColor3 = Color3.fromRGB(60, 60, 70)
    clickLogList.ScrollBarThickness = 8
    clickLogList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    clickLogList.Parent = clickLoggerTab
    
    local clickLogLayout = Instance.new("UIListLayout")
    clickLogLayout.Padding = UDim.new(0, 5)
    clickLogLayout.Parent = clickLogList
    
    -- ====== FUNCTIONS TAB ======
    local functionsTab = Instance.new("Frame")
    functionsTab.Name = "FunctionsTab"
    functionsTab.Size = UDim2.new(1, 0, 1, 0)
    functionsTab.BackgroundTransparency = 1
    functionsTab.Visible = false
    functionsTab.Parent = contentArea
    
    local functionsHeader = Instance.new("TextLabel")
    functionsHeader.Name = "FunctionsHeader"
    functionsHeader.Size = UDim2.new(1, -20, 0, 40)
    functionsHeader.Position = UDim2.new(0, 10, 0, 10)
    functionsHeader.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    functionsHeader.TextColor3 = Color3.fromRGB(220, 220, 220)
    functionsHeader.Text = "⚙️ FUNCTION FINDER"
    functionsHeader.Font = Enum.Font.SourceSansBold
    functionsHeader.TextSize = 18
    functionsHeader.Parent = functionsTab
    
    local functionControls = Instance.new("Frame")
    functionControls.Name = "FunctionControls"
    functionControls.Size = UDim2.new(1, -20, 0, 40)
    functionControls.Position = UDim2.new(0, 10, 0, 60)
    functionControls.BackgroundTransparency = 1
    functionControls.Parent = functionsTab
    
    local findRemoteFunctionsButton = Instance.new("TextButton")
    findRemoteFunctionsButton.Name = "FindRemoteFunctionsButton"
    findRemoteFunctionsButton.Size = UDim2.new(0.45, 0, 1, 0)
    findRemoteFunctionsButton.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
    findRemoteFunctionsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    findRemoteFunctionsButton.Text = "🔍 Find Remotes"
    findRemoteFunctionsButton.Font = Enum.Font.SourceSansBold
    findRemoteFunctionsButton.TextSize = 14
    findRemoteFunctionsButton.Parent = functionControls
    
    local findAttackFunctionsButton = Instance.new("TextButton")
    findAttackFunctionsButton.Name = "FindAttackFunctionsButton"
    findAttackFunctionsButton.Size = UDim2.new(0.45, 0, 1, 0)
    findAttackFunctionsButton.Position = UDim2.new(0.5, 5, 0, 0)
    findAttackFunctionsButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    findAttackFunctionsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    findAttackFunctionsButton.Text = "⚔️ Attack Remotes"
    findAttackFunctionsButton.Font = Enum.Font.SourceSansBold
    findAttackFunctionsButton.TextSize = 14
    findAttackFunctionsButton.Parent = functionControls
    
    local functionsList = Instance.new("ScrollingFrame")
    functionsList.Name = "FunctionsList"
    functionsList.Size = UDim2.new(1, -20, 1, -120)
    functionsList.Position = UDim2.new(0, 10, 0, 110)
    functionsList.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    functionsList.BorderSizePixel = 1
    functionsList.BorderColor3 = Color3.fromRGB(60, 60, 70)
    functionsList.ScrollBarThickness = 8
    functionsList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    functionsList.Parent = functionsTab
    
    local functionsListLayout = Instance.new("UIListLayout")
    functionsListLayout.Padding = UDim.new(0, 5)
    functionsListLayout.Parent = functionsList
    
    -- Create minimized icon GUI (hidden by default)
    minimizedGui = Instance.new("ScreenGui")
    minimizedGui.Name = "ScriptingExplorerMinimized"
    minimizedGui.ResetOnSpawn = false
    minimizedGui.Parent = player.PlayerGui
    minimizedGui.Enabled = false
    
    local minimizedIcon = Instance.new("TextButton")
    minimizedIcon.Name = "MinimizedIcon"
    minimizedIcon.Size = UDim2.new(0, 60, 0, 60)
    minimizedIcon.Position = UDim2.new(0.9, 0, 0.02, 0)  -- Top right
    minimizedIcon.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    minimizedIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizedIcon.Text = "🔧\nSPY"
    minimizedIcon.Font = Enum.Font.SourceSansBold
    minimizedIcon.TextSize = 14
    minimizedIcon.TextWrapped = true
    minimizedIcon.Parent = minimizedGui
    
    return {
        gui = gui,
        minimizedGui = minimizedGui,
        mainFrame = mainFrame,
        tabs = {
            explorer = explorerTab,
            clickLogger = clickLoggerTab,
            functions = functionsTab
        },
        tabButtons = tabs,
        searchBox = searchBox,
        searchButton = searchButton,
        clearSearchButton = clearSearchButton,
        resultsFrame = resultsFrame,
        infoPanel = infoPanel,
        copyPathButton = copyPathButton,
        highlightButton = highlightButton,
        clearHighlightsButton = clearHighlightsButton,
        startLoggingButton = startLoggingButton,
        stopLoggingButton = stopLoggingButton,
        clearLogButton = clearLogButton,
        clickLogList = clickLogList,
        findRemoteFunctionsButton = findRemoteFunctionsButton,
        findAttackFunctionsButton = findAttackFunctionsButton,
        functionsList = functionsList,
        minimizeButton = minimizeButton,
        closeButton = closeButton,
        minimizedIcon = minimizedIcon
    }
end

-- ====== UTILITY FUNCTIONS ======
local function showNotification(message)
    if not gui or not gui.Parent then return end
    
    local notification = Instance.new("TextLabel")
    notification.Size = UDim2.new(0.8, 0, 0, 50)
    notification.Position = UDim2.new(0.1, 0, 0.1, 0)
    notification.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    notification.Text = message
    notification.Font = Enum.Font.SourceSansBold
    notification.TextSize = 16
    notification.TextWrapped = true
    notification.ZIndex = 100
    notification.Parent = gui
    
    task.delay(3, function()
        if notification and notification.Parent then
            notification:Destroy()
        end
    end)
end

local function updateClickLogDisplay(ui)
    if not ui or not ui.clickLogList then return end
    
    -- Clear previous log
    for _, child in pairs(ui.clickLogList:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    -- Show logs (newest first)
    for i = #clickLog, 1, -1 do
        local log = clickLog[i]
        
        local logEntry = Instance.new("TextLabel")
        logEntry.Size = UDim2.new(1, -10, 0, 60)
        logEntry.BackgroundTransparency = 1
        logEntry.TextColor3 = Color3.fromRGB(220, 220, 220)
        logEntry.Text = "[" .. log.timestamp .. "] " .. log.eventType .. "\n" .. log.objectName .. "\nPath: " .. log.objectPath
        logEntry.Font = Enum.Font.SourceSans
        logEntry.TextSize = 12
        logEntry.TextXAlignment = Enum.TextXAlignment.Left
        logEntry.TextWrapped = true
        logEntry.Parent = ui.clickLogList
    end
end

-- ====== EXPLORER FUNCTIONS ======
local function searchObjects(searchTerm)
    local results = {}
    searchTerm = string.lower(searchTerm)
    
    for _, obj in pairs(game:GetDescendants()) do
        if string.find(string.lower(obj.Name), searchTerm, 1, true) then
            table.insert(results, {
                object = obj,
                path = obj:GetFullName(),
                class = obj.ClassName
            })
        end
    end
    
    return results
end

local function displaySearchResults(results, ui)
    if not ui or not ui.resultsFrame then return end
    
    -- Clear previous results
    for _, child in pairs(ui.resultsFrame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    if #results == 0 then
        local noResults = Instance.new("TextLabel")
        noResults.Size = UDim2.new(1, -10, 0, 40)
        noResults.BackgroundTransparency = 1
        noResults.TextColor3 = Color3.fromRGB(150, 150, 150)
        noResults.Text = "No objects found. Try a different search."
        noResults.Font = Enum.Font.SourceSans
        noResults.TextSize = 16
        noResults.TextWrapped = true
        noResults.Parent = ui.resultsFrame
        return
    end
    
    for i, result in ipairs(results) do
        if i > 50 then break end
        
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -10, 0, 35)
        button.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(45, 45, 55) or Color3.fromRGB(40, 40, 50)
        button.BorderSizePixel = 0
        button.TextColor3 = Color3.fromRGB(220, 220, 220)
        button.Text = result.object.Name .. "  [" .. result.object.ClassName .. "]"
        button.Font = Enum.Font.SourceSans
        button.TextSize = 14
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.Parent = ui.resultsFrame
        
        button.MouseButton1Click:Connect(function()
            selectedObject = result.object
            updateObjectInfo(result.object, ui)
        end)
    end
end

local function updateObjectInfo(obj, ui)
    if not ui or not ui.infoPanel then return end
    
    -- Clear previous info
    for _, child in pairs(ui.infoPanel:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    if not obj then return end
    
    local function addInfo(text, color)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 25)
        label.BackgroundTransparency = 1
        label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
        label.Text = text
        label.Font = Enum.Font.SourceSans
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = ui.infoPanel
    end
    
    addInfo("Name: " .. obj.Name, Color3.fromRGB(100, 200, 255))
    addInfo("Class: " .. obj.ClassName, Color3.fromRGB(255, 150, 100))
    addInfo("Path: " .. obj:GetFullName(), Color3.fromRGB(150, 255, 150))
    
    if obj:IsA("BasePart") then
        addInfo("Position: " .. tostring(obj.Position), Color3.fromRGB(255, 200, 100))
        addInfo("Size: " .. tostring(obj.Size), Color3.fromRGB(200, 100, 255))
    end
    
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        addInfo("Event Type: " .. obj.ClassName, Color3.fromRGB(255, 100, 100))
        addInfo("This is a network event!", Color3.fromRGB(255, 100, 100))
    end
end

-- ====== HIGHLIGHT SYSTEM ======
local function highlightObject(obj)
    if not obj then return end
    
    -- Remove existing highlight
    if currentHighlights[obj] then
        currentHighlights[obj]:Destroy()
        currentHighlights[obj] = nil
        return
    end
    
    -- Create highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "ExplorerHighlight"
    highlight.FillColor = Color3.fromRGB(255, 255, 0)
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = Color3.fromRGB(255, 200, 0)
    highlight.Parent = obj
    
    currentHighlights[obj] = highlight
end

local function clearAllHighlights()
    for obj, highlight in pairs(currentHighlights) do
        if highlight then
            highlight:Destroy()
        end
    end
    currentHighlights = {}
end

-- ====== CLICK LOGGER SYSTEM ======
local function logClickEvent(obj, eventType)
    table.insert(clickLog, {
        timestamp = os.date("%H:%M:%S"),
        objectName = obj.Name,
        objectPath = obj:GetFullName(),
        objectClass = obj.ClassName,
        eventType = eventType
    })
    
    -- Keep only last 100 logs
    if #clickLog > 100 then
        table.remove(clickLog, 1)
    end
end

-- FIXED: Safe hooking function that checks for MouseButton1Click
local function safeHookClickEvent(obj)
    if not obj:IsA("TextButton") and not obj:IsA("ImageButton") then
        return
    end
    
    -- Check if MouseButton1Click exists
    local success, mouseButton1Click = pcall(function()
        return obj.MouseButton1Click
    end)
    
    if not success then
        return -- MouseButton1Click doesn't exist for this object
    end
    
    -- Store original connection if it exists
    local originalEvent = mouseButton1Click
    
    -- Create a new connection that logs the click
    local newConnection
    newConnection = obj.MouseButton1Click:Connect(function(...)
        logClickEvent(obj, "MouseButton1Click")
    end)
    
    -- Store for cleanup
    hookConnections[obj] = newConnection
end

local function startClickLogging(ui)
    if isLoggingClicks then return end
    isLoggingClicks = true
    
    -- Clear previous logs and connections
    clickLog = {}
    hookConnections = {}
    
    -- Hook all existing buttons SAFELY
    for _, obj in pairs(game:GetDescendants()) do
        safeHookClickEvent(obj)
    end
    
    -- Hook new buttons as they're created
    local connection = game.DescendantAdded:Connect(function(obj)
        if isLoggingClicks then
            safeHookClickEvent(obj)
        end
    end)
    
    hookConnections["DescendantAdded"] = connection
    
    showNotification("▶️ Started logging click events! Click buttons in-game to see them here.")
    updateClickLogDisplay(ui)
end

local function stopClickLogging()
    if not isLoggingClicks then return end
    isLoggingClicks = false
    
    -- Disconnect all hook connections
    for obj, connection in pairs(hookConnections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    
    hookConnections = {}
    showNotification("⏹️ Stopped logging click events")
end

-- ====== FUNCTION FINDER ======
local function findRemoteFunctions(ui)
    if not ui or not ui.functionsList then return end
    
    -- Clear previous list
    for _, child in pairs(ui.functionsList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local foundRemotes = {}
    
    -- Find all RemoteEvents and RemoteFunctions
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(foundRemotes, {
                object = obj,
                path = obj:GetFullName(),
                type = obj.ClassName
            })
        end
    end
    
    if #foundRemotes == 0 then
        local noRemotes = Instance.new("TextLabel")
        noRemotes.Size = UDim2.new(1, -10, 0, 40)
        noRemotes.BackgroundTransparency = 1
        noRemotes.TextColor3 = Color3.fromRGB(150, 150, 150)
        noRemotes.Text = "No remote events/functions found."
        noRemotes.Font = Enum.Font.SourceSans
        noRemotes.TextSize = 16
        noRemotes.TextWrapped = true
        noRemotes.Parent = ui.functionsList
        return
    end
    
    for i, remote in ipairs(foundRemotes) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -10, 0, 40)
        button.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(45, 45, 55) or Color3.fromRGB(40, 40, 50)
        button.BorderSizePixel = 0
        button.TextColor3 = Color3.fromRGB(220, 220, 220)
        button.Text = remote.type .. ": " .. remote.object.Name .. "\nPath: " .. remote.path
        button.Font = Enum.Font.SourceSans
        button.TextSize = 12
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.TextWrapped = true
        button.Parent = ui.functionsList
        
        button.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(remote.path)
                showNotification("✓ Path copied: " .. remote.path)
            else
                showNotification("Path: " .. remote.path)
            end
        end)
    end
    
    showNotification("✓ Found " .. #foundRemotes .. " remote events/functions")
end

local function findAttackFunctions(ui)
    if not ui or not ui.functionsList then return end
    
    -- Clear previous list
    for _, child in pairs(ui.functionsList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local attackKeywords = {
        "Damage", "Attack", "Hit", "Kill", "Health", "Hurt",
        "TakeDamage", "DamagePlayer", "Stun", "Knockback",
        "Explode", "Shot", "Fire", "Swing", "Punch", "Kick",
        "Sword", "Gun", "Weapon", "Bullet", "Projectile",
        "Ability", "Skill", "Spell", "Cast", "Shoot", "Strike"
    }
    
    local foundAttackRemotes = {}
    
    -- Find remotes with attack-related names
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local objName = string.lower(obj.Name)
            
            for _, keyword in pairs(attackKeywords) do
                if string.find(objName, string.lower(keyword)) then
                    table.insert(foundAttackRemotes, {
                        object = obj,
                        path = obj:GetFullName(),
                        type = obj.ClassName,
                        keyword = keyword
                    })
                    break
                end
            end
        end
    end
    
    -- Find scripts with attack-related names
    for _, script in pairs(game:GetDescendants()) do
        if script:IsA("ModuleScript") or script:IsA("Script") then
            local scriptName = string.lower(script.Name)
            
            for _, keyword in pairs(attackKeywords) do
                if string.find(scriptName, string.lower(keyword)) then
                    table.insert(foundAttackRemotes, {
                        object = script,
                        path = script:GetFullName(),
                        type = script.ClassName,
                        keyword = keyword
                    })
                    break
                end
            end
        end
    end
    
    if #foundAttackRemotes == 0 then
        local noAttack = Instance.new("TextLabel")
        noAttack.Size = UDim2.new(1, -10, 0, 40)
        noAttack.BackgroundTransparency = 1
        noAttack.TextColor3 = Color3.fromRGB(150, 150, 150)
        noAttack.Text = "No attack-related functions found.\nTry searching in Explorer tab."
        noAttack.Font = Enum.Font.SourceSans
        noAttack.TextSize = 16
        noAttack.TextWrapped = true
        noAttack.Parent = ui.functionsList
        return
    end
    
    for i, attackRemote in ipairs(foundAttackRemotes) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -10, 0, 50)
        button.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(45, 45, 55) or Color3.fromRGB(40, 40, 50)
        button.BorderSizePixel = 0
        button.TextColor3 = Color3.fromRGB(220, 220, 220)
        button.Text = "⚔️ " .. attackRemote.object.Name .. " (" .. attackRemote.type .. ")\nContains: " .. attackRemote.keyword .. "\nPath: " .. attackRemote.path
        button.Font = Enum.Font.SourceSans
        button.TextSize = 12
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.TextWrapped = true
        button.Parent = ui.functionsList
        
        button.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(attackRemote.path)
                showNotification("✓ Attack path copied: " .. attackRemote.path)
            else
                showNotification("Attack path: " .. attackRemote.path)
            end
        end)
    end
    
    showNotification("✓ Found " .. #foundAttackRemotes .. " potential attack functions")
end

-- ====== TAB SWITCHING ======
local function switchToTab(tabIndex, ui)
    if not ui or not ui.tabs then return end
    
    ui.tabs.explorer.Visible = false
    ui.tabs.clickLogger.Visible = false
    ui.tabs.functions.Visible = false
    
    if tabIndex == 1 then
        ui.tabs.explorer.Visible = true
    elseif tabIndex == 2 then
        ui.tabs.clickLogger.Visible = true
        updateClickLogDisplay(ui)
    elseif tabIndex == 3 then
        ui.tabs.functions.Visible = true
    end
    
    -- Update tab colors
    if ui.tabButtons then
        for i, tabBtn in ipairs(ui.tabButtons) do
            if tabBtn and tabBtn.Parent then
                tabBtn.BackgroundColor3 = i == tabIndex and Color3.fromRGB(60, 60, 75) or Color3.fromRGB(40, 40, 50)
            end
        end
    end
end

-- ====== MINIMIZE/MAXIMIZE FUNCTIONS ======
local function minimizeWindow(ui)
    if not ui or not ui.gui or not ui.minimizedGui then return end
    
    isMinimized = true
    ui.gui.Enabled = false
    ui.minimizedGui.Enabled = true
    
    -- Make minimized icon draggable
    local dragStart, startPos, dragging
    
    ui.minimizedIcon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = ui.minimizedIcon.Position
        end
    end)
    
    ui.minimizedIcon.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            ui.minimizedIcon.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function maximizeWindow(ui)
    if not ui or not ui.gui or not ui.minimizedGui then return end
    
    isMinimized = false
    ui.gui.Enabled = true
    ui.minimizedGui.Enabled = false
end

-- ====== MAIN INITIALIZATION ======
local function init()
    local ui = createMainUI()
    
    -- Tab switching
    for i, tabBtn in ipairs(ui.tabButtons) do
        tabBtn.MouseButton1Click:Connect(function()
            switchToTab(i, ui)
        end)
    end
    
    -- Explorer functions
    ui.searchButton.MouseButton1Click:Connect(function()
        local searchTerm = ui.searchBox.Text
        if searchTerm and #searchTerm > 0 then
            local results = searchObjects(searchTerm)
            displaySearchResults(results, ui)
            showNotification("Found " .. #results .. " objects")
        end
    end)
    
    ui.searchBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local searchTerm = ui.searchBox.Text
            if searchTerm and #searchTerm > 0 then
                local results = searchObjects(searchTerm)
                displaySearchResults(results, ui)
            end
        end
    end)
    
    ui.clearSearchButton.MouseButton1Click:Connect(function()
        ui.searchBox.Text = ""
        for _, child in pairs(ui.resultsFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        showNotification("Search cleared")
    end)
    
    ui.copyPathButton.MouseButton1Click:Connect(function()
        if selectedObject then
            local path = selectedObject:GetFullName()
            if setclipboard then
                setclipboard(path)
                showNotification("✓ Path copied: " .. path)
            else
                showNotification("Path: " .. path)
            end
        else
            showNotification("⚠️ No object selected")
        end
    end)
    
    ui.highlightButton.MouseButton1Click:Connect(function()
        if selectedObject then
            highlightObject(selectedObject)
            showNotification("Highlight toggled: " .. selectedObject.Name)
        else
            showNotification("⚠️ No object selected")
        end
    end)
    
    ui.clearHighlightsButton.MouseButton1Click:Connect(function()
        clearAllHighlights()
        showNotification("All highlights cleared")
    end)
    
    -- Click Logger functions
    ui.startLoggingButton.MouseButton1Click:Connect(function()
        startClickLogging(ui)
    end)
    
    ui.stopLoggingButton.MouseButton1Click:Connect(function()
        stopClickLogging()
    end)
    
    ui.clearLogButton.MouseButton1Click:Connect(function()
        clickLog = {}
        updateClickLogDisplay(ui)
        showNotification("Click log cleared")
    end)
    
    -- Functions tab buttons
    ui.findRemoteFunctionsButton.MouseButton1Click:Connect(function()
        findRemoteFunctions(ui)
    end)
    
    ui.findAttackFunctionsButton.MouseButton1Click:Connect(function()
        findAttackFunctions(ui)
    end)
    
    -- Minimize/Maximize buttons
    ui.minimizeButton.MouseButton1Click:Connect(function()
        minimizeWindow(ui)
        showNotification("Window minimized to icon")
    end)
    
    ui.minimizedIcon.MouseButton1Click:Connect(function()
        maximizeWindow(ui)
        showNotification("Window restored")
    end)
    
    -- Close button
    ui.closeButton.MouseButton1Click:Connect(function()
        stopClickLogging()
        clearAllHighlights()
        if ui.gui then
            ui.gui:Destroy()
        end
        if ui.minimizedGui then
            ui.minimizedGui:Destroy()
        end
        gui = nil
        minimizedGui = nil
    end)
    
    -- Make window draggable
    local dragStart, startPos, dragging
    ui.mainFrame.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = ui.mainFrame.Position
        end
    end)
    
    ui.mainFrame.TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            ui.mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    showNotification("🔧 Scripting Explorer v4.0 Loaded!")
    return ui
end

-- Start the script
init()