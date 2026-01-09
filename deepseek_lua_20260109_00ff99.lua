-- Roblox Scripting Explorer v2.1 (Fixed)
-- For development & debugging in executors

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local gui = nil
local selectedObject = nil
local currentHighlights = {}

-- Simple UI Creation without errors
local function createMainUI()
    if gui then gui:Destroy() end
    
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
    mainFrame.Parent = gui
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    titleBar.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0.7, 0, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(100, 180, 255)
    title.Text = "🔧 SCRIPTING EXPLORER"
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 80, 1, 0)
    closeButton.Position = UDim2.new(1, -80, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Text = "✕ CLOSE"
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 14
    closeButton.Parent = titleBar
    
    -- Tabs Container
    local tabsContainer = Instance.new("Frame")
    tabsContainer.Name = "TabsContainer"
    tabsContainer.Size = UDim2.new(1, 0, 0, 40)
    tabsContainer.Position = UDim2.new(0, 0, 0, 40)
    tabsContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    tabsContainer.Parent = mainFrame
    
    local tabs = {}
    local tabNames = {"📁 Explorer", "📡 Events", "⚙️ Functions", "📝 Log"}
    
    for i, tabName in ipairs(tabNames) do
        local tab = Instance.new("TextButton")
        tab.Name = "Tab" .. i
        tab.Size = UDim2.new(0.25, 0, 1, 0)
        tab.Position = UDim2.new((i-1) * 0.25, 0, 0, 0)
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
    searchBox.PlaceholderText = "Search objects..."
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
    
    -- ====== EVENTS TAB ======
    local eventsTab = Instance.new("Frame")
    eventsTab.Name = "EventsTab"
    eventsTab.Size = UDim2.new(1, 0, 1, 0)
    eventsTab.BackgroundTransparency = 1
    eventsTab.Visible = false
    eventsTab.Parent = contentArea
    
    local eventsHeader = Instance.new("TextLabel")
    eventsHeader.Name = "EventsHeader"
    eventsHeader.Size = UDim2.new(1, -20, 0, 40)
    eventsHeader.Position = UDim2.new(0, 10, 0, 10)
    eventsHeader.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    eventsHeader.TextColor3 = Color3.fromRGB(220, 220, 220)
    eventsHeader.Text = "📡 EVENT DETECTOR"
    eventsHeader.Font = Enum.Font.SourceSansBold
    eventsHeader.TextSize = 18
    eventsHeader.Parent = eventsTab
    
    local eventsControls = Instance.new("Frame")
    eventsControls.Name = "EventsControls"
    eventsControls.Size = UDim2.new(1, -20, 0, 40)
    eventsControls.Position = UDim2.new(0, 10, 0, 60)
    eventsControls.BackgroundTransparency = 1
    eventsControls.Parent = eventsTab
    
    local scanEventsButton = Instance.new("TextButton")
    scanEventsButton.Name = "ScanEventsButton"
    scanEventsButton.Size = UDim2.new(0.45, 0, 1, 0)
    scanEventsButton.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
    scanEventsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    scanEventsButton.Text = "🔍 Scan All Events"
    scanEventsButton.Font = Enum.Font.SourceSansBold
    scanEventsButton.TextSize = 14
    scanEventsButton.Parent = eventsControls
    
    local findAttackEventsButton = Instance.new("TextButton")
    findAttackEventsButton.Name = "FindAttackEventsButton"
    findAttackEventsButton.Size = UDim2.new(0.45, 0, 1, 0)
    findAttackEventsButton.Position = UDim2.new(0.5, 5, 0, 0)
    findAttackEventsButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    findAttackEventsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    findAttackEventsButton.Text = "⚔️ Find Attack"
    findAttackEventsButton.Font = Enum.Font.SourceSansBold
    findAttackEventsButton.TextSize = 14
    findAttackEventsButton.Parent = eventsControls
    
    local eventsList = Instance.new("ScrollingFrame")
    eventsList.Name = "EventsList"
    eventsList.Size = UDim2.new(1, -20, 1, -120)
    eventsList.Position = UDim2.new(0, 10, 0, 110)
    eventsList.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    eventsList.BorderSizePixel = 1
    eventsList.BorderColor3 = Color3.fromRGB(60, 60, 70)
    eventsList.ScrollBarThickness = 8
    eventsList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    eventsList.Parent = eventsTab
    
    local eventsListLayout = Instance.new("UIListLayout")
    eventsListLayout.Padding = UDim.new(0, 5)
    eventsListLayout.Parent = eventsList
    
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
    
    local findFunctionsButton = Instance.new("TextButton")
    findFunctionsButton.Name = "FindFunctionsButton"
    findFunctionsButton.Size = UDim2.new(0.45, 0, 1, 0)
    findFunctionsButton.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
    findFunctionsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    findFunctionsButton.Text = "🔍 Find Functions"
    findFunctionsButton.Font = Enum.Font.SourceSansBold
    findFunctionsButton.TextSize = 14
    findFunctionsButton.Parent = functionControls
    
    local hookFunctionsButton = Instance.new("TextButton")
    hookFunctionsButton.Name = "HookFunctionsButton"
    hookFunctionsButton.Size = UDim2.new(0.45, 0, 1, 0)
    hookFunctionsButton.Position = UDim2.new(0.5, 5, 0, 0)
    hookFunctionsButton.BackgroundColor3 = Color3.fromRGB(160, 100, 200)
    hookFunctionsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    hookFunctionsButton.Text = "🎣 Hook Functions"
    hookFunctionsButton.Font = Enum.Font.SourceSansBold
    hookFunctionsButton.TextSize = 14
    hookFunctionsButton.Parent = functionControls
    
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
    
    -- ====== LOG TAB ======
    local logTab = Instance.new("Frame")
    logTab.Name = "LogTab"
    logTab.Size = UDim2.new(1, 0, 1, 0)
    logTab.BackgroundTransparency = 1
    logTab.Visible = false
    logTab.Parent = contentArea
    
    local logHeader = Instance.new("TextLabel")
    logHeader.Name = "LogHeader"
    logHeader.Size = UDim2.new(1, -20, 0, 40)
    logHeader.Position = UDim2.new(0, 10, 0, 10)
    logHeader.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    logHeader.TextColor3 = Color3.fromRGB(220, 220, 220)
    logHeader.Text = "📝 EVENT LOG"
    logHeader.Font = Enum.Font.SourceSansBold
    logHeader.TextSize = 18
    logHeader.Parent = logTab
    
    local logControls = Instance.new("Frame")
    logControls.Name = "LogControls"
    logControls.Size = UDim2.new(1, -20, 0, 40)
    logControls.Position = UDim2.new(0, 10, 0, 60)
    logControls.BackgroundTransparency = 1
    logControls.Parent = logTab
    
    local clearLogButton = Instance.new("TextButton")
    clearLogButton.Name = "ClearLogButton"
    clearLogButton.Size = UDim2.new(0.3, 0, 1, 0)
    clearLogButton.BackgroundColor3 = Color3.fromRGB(180, 80, 80)
    clearLogButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearLogButton.Text = "🗑️ Clear Log"
    clearLogButton.Font = Enum.Font.SourceSansBold
    clearLogButton.TextSize = 14
    clearLogButton.Parent = logControls
    
    local exportLogButton = Instance.new("TextButton")
    exportLogButton.Name = "ExportLogButton"
    exportLogButton.Size = UDim2.new(0.3, 0, 1, 0)
    exportLogButton.Position = UDim2.new(0.35, 10, 0, 0)
    exportLogButton.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
    exportLogButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    exportLogButton.Text = "💾 Export"
    exportLogButton.Font = Enum.Font.SourceSansBold
    exportLogButton.TextSize = 14
    exportLogButton.Parent = logControls
    
    local logList = Instance.new("ScrollingFrame")
    logList.Name = "LogList"
    logList.Size = UDim2.new(1, -20, 1, -120)
    logList.Position = UDim2.new(0, 10, 0, 110)
    logList.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    logList.BorderSizePixel = 1
    logList.BorderColor3 = Color3.fromRGB(60, 60, 70)
    logList.ScrollBarThickness = 8
    logList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    logList.Parent = logTab
    
    local logListLayout = Instance.new("UIListLayout")
    logListLayout.Padding = UDim.new(0, 5)
    logListLayout.Parent = logList
    
    return {
        gui = gui,
        mainFrame = mainFrame,
        tabs = {
            explorer = explorerTab,
            events = eventsTab,
            functions = functionsTab,
            log = logTab
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
        scanEventsButton = scanEventsButton,
        findAttackEventsButton = findAttackEventsButton,
        eventsList = eventsList,
        findFunctionsButton = findFunctionsButton,
        hookFunctionsButton = hookFunctionsButton,
        functionsList = functionsList,
        clearLogButton = clearLogButton,
        exportLogButton = exportLogButton,
        logList = logList,
        closeButton = closeButton
    }
end

-- Search function
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

-- Display results
local function displaySearchResults(results, ui)
    -- Clear previous
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

-- Update object info
local function updateObjectInfo(obj, ui)
    -- Clear previous
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
end

-- Highlight system
local function highlightObject(obj)
    if not obj then return end
    
    -- Remove existing
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

-- Find attack events/functions
local function findAttackEvents(ui)
    -- Clear previous
    for _, child in pairs(ui.eventsList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local attackKeywords = {
        "Damage", "Attack", "Hit", "Kill", "Health",
        "TakeDamage", "DamagePlayer", "Hurt", "Stun",
        "Knockback", "Explode", "Shot", "Fire", "Swing",
        "Punch", "Kick", "Sword", "Gun", "Weapon"
    }
    
    local foundEvents = {}
    
    -- Search for remotes with attack names
    for _, obj in pairs(game:GetDescendants()) do
        local objName = string.lower(obj.Name)
        
        for _, keyword in pairs(attackKeywords) do
            if string.find(objName, string.lower(keyword)) then
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or 
                   obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
                    
                    table.insert(foundEvents, {
                        object = obj,
                        path = obj:GetFullName(),
                        type = obj.ClassName,
                        reason = "Contains: " .. keyword
                    })
                    break
                end
            end
        end
    end
    
    -- Search for scripts with attack names
    for _, script in pairs(game:GetDescendants()) do
        if script:IsA("ModuleScript") or script:IsA("Script") then
            local scriptName = string.lower(script.Name)
            
            for _, keyword in pairs(attackKeywords) do
                if string.find(scriptName, string.lower(keyword)) then
                    table.insert(foundEvents, {
                        object = script,
                        path = script:GetFullName(),
                        type = script.ClassName,
                        reason = "Contains: " .. keyword
                    })
                    break
                end
            end
        end
    end
    
    if #foundEvents == 0 then
        local noEvents = Instance.new("TextLabel")
        noEvents.Size = UDim2.new(1, -10, 0, 40)
        noEvents.BackgroundTransparency = 1
        noEvents.TextColor3 = Color3.fromRGB(150, 150, 150)
        noEvents.Text = "No attack events found. Try different keywords."
        noEvents.Font = Enum.Font.SourceSans
        noEvents.TextSize = 16
        noEvents.TextWrapped = true
        noEvents.Parent = ui.eventsList
        return
    end
    
    for i, event in ipairs(foundEvents) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -10, 0, 50)
        button.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(45, 45, 55) or Color3.fromRGB(40, 40, 50)
        button.BorderSizePixel = 0
        button.TextColor3 = Color3.fromRGB(220, 220, 220)
        button.Text = "⚔️ " .. event.object.Name .. " (" .. event.type .. ")\n" .. event.reason
        button.Font = Enum.Font.SourceSans
        button.TextSize = 12
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.TextWrapped = true
        button.Parent = ui.eventsList
        
        button.MouseButton1Click:Connect(function()
            selectedObject = event.object
            if setclipboard then
                setclipboard(event.path)
                showNotification("Path copied: " .. event.path)
            end
        end)
    end
end

-- Show notification
local function showNotification(message)
    if not gui then return end
    
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

-- Tab switching
local function switchToTab(tabIndex, ui)
    ui.tabs.explorer.Visible = false
    ui.tabs.events.Visible = false
    ui.tabs.functions.Visible = false
    ui.tabs.log.Visible = false
    
    if tabIndex == 1 then
        ui.tabs.explorer.Visible = true
    elseif tabIndex == 2 then
        ui.tabs.events.Visible = true
    elseif tabIndex == 3 then
        ui.tabs.functions.Visible = true
    elseif tabIndex == 4 then
        ui.tabs.log.Visible = true
    end
    
    -- Update tab colors
    for i, tabBtn in ipairs(ui.tabButtons) do
        tabBtn.BackgroundColor3 = i == tabIndex and Color3.fromRGB(60, 60, 75) or Color3.fromRGB(40, 40, 50)
    end
end

-- Main initialization
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
    
    ui.clearSearchButton.MouseButton1Click:Connect(function()
        ui.searchBox.Text = ""
        for _, child in pairs(ui.resultsFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
    end)
    
    ui.copyPathButton.MouseButton1Click:Connect(function()
        if selectedObject then
            local path = selectedObject:GetFullName()
            if setclipboard then
                setclipboard(path)
                showNotification("✓ Path copied: " .. path)
            else
                showNotification("⚠️ No clipboard access")
            end
        else
            showNotification("⚠️ No object selected")
        end
    end)
    
    ui.highlightButton.MouseButton1Click:Connect(function()
        if selectedObject then
            highlightObject(selectedObject)
            showNotification("Highlight toggled: " .. selectedObject.Name)
        end
    end)
    
    ui.clearHighlightsButton.MouseButton1Click:Connect(function()
        clearAllHighlights()
        showNotification("All highlights cleared")
    end)
    
    -- Events tab functions
    ui.scanEventsButton.MouseButton1Click:Connect(function()
        findAttackEvents(ui)
    end)
    
    ui.findAttackEventsButton.MouseButton1Click:Connect(function()
        findAttackEvents(ui)
    end)
    
    -- Close button
    ui.closeButton.MouseButton1Click:Connect(function()
        clearAllHighlights()
        gui:Destroy()
        gui = nil
    end)
    
    -- Make draggable
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
    
    showNotification("🔧 Scripting Explorer Loaded!")
    return ui
end

-- Start the script
init()