-- Roblox Scripting Explorer v2.0
-- For development & debugging in executors
-- No game functions, just analysis tools

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local gui = nil
local selectedObject = nil
local currentHighlights = {}
local eventListeners = {}
local functionLog = {}
local isLoggingEvents = false

-- Core UI Creation
local function createMainUI()
    if gui then gui:Destroy() end
    
    gui = Instance.new("ScreenGui")
    gui.Name = "ScriptingExplorer"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = player:WaitForChild("PlayerGui")
    
    -- Main Container
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 900, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -450, 0.5, -300)
    mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = Color3.fromRGB(60, 60, 70)
    mainFrame.Parent = gui
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0.7, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(100, 180, 255)
    title.Text = "🔧 SCRIPTING EXPLORER v2.0"
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.PaddingLeft = UDim.new(0, 10)
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
    tabsContainer.BorderSizePixel = 0
    tabsContainer.Parent = mainFrame
    
    local tabButtons = {
        {name = "ExplorerTab", text = "📁 Explorer"},
        {name = "EventsTab", text = "📡 Events"},
        {name = "FunctionsTab", text = "⚙️ Functions"},
        {name = "LogTab", text = "📝 Event Log"}
    }
    
    for i, tabInfo in ipairs(tabButtons) do
        local tab = Instance.new("TextButton")
        tab.Name = tabInfo.name
        tab.Size = UDim2.new(0.25, 0, 1, 0)
        tab.Position = UDim2.new((i-1) * 0.25, 0, 0, 0)
        tab.BackgroundColor3 = i == 1 and Color3.fromRGB(50, 50, 60) or Color3.fromRGB(40, 40, 50)
        tab.TextColor3 = Color3.fromRGB(220, 220, 220)
        tab.Text = tabInfo.text
        tab.Font = Enum.Font.SourceSans
        tab.TextSize = 14
        tab.BorderSizePixel = 0
        tab.Parent = tabsContainer
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
    searchBox.PlaceholderText = "Search objects by name (supports * wildcards)..."
    searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    searchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.Font = Enum.Font.Code
    searchBox.TextSize = 14
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
    
    -- Search Results
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
    
    -- Object Info Panel
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
    eventsHeader.TextSize = 16
    eventsHeader.Parent = eventsTab
    
    local eventsControls = Instance.new("Frame")
    eventsControls.Name = "EventsControls"
    eventsControls.Size = UDim2.new(1, -20, 0, 40)
    eventsControls.Position = UDim2.new(0, 10, 0, 60)
    eventsControls.BackgroundTransparency = 1
    eventsControls.Parent = eventsTab
    
    local scanEventsButton = Instance.new("TextButton")
    scanEventsButton.Name = "ScanEventsButton"
    scanEventsButton.Size = UDim2.new(0.3, 0, 1, 0)
    scanEventsButton.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
    scanEventsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    scanEventsButton.Text = "🔍 Scan All Events"
    scanEventsButton.Font = Enum.Font.SourceSansBold
    scanEventsButton.TextSize = 14
    scanEventsButton.Parent = eventsControls
    
    local startLoggingButton = Instance.new("TextButton")
    startLoggingButton.Name = "StartLoggingButton"
    startLoggingButton.Size = UDim2.new(0.3, 0, 1, 0)
    startLoggingButton.Position = UDim2.new(0.32, 10, 0, 0)
    startLoggingButton.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
    startLoggingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    startLoggingButton.Text = "▶️ Start Logging"
    startLoggingButton.Font = Enum.Font.SourceSansBold
    startLoggingButton.TextSize = 14
    startLoggingButton.Parent = eventsControls
    
    local stopLoggingButton = Instance.new("TextButton")
    stopLoggingButton.Name = "StopLoggingButton"
    stopLoggingButton.Size = UDim2.new(0.3, 0, 1, 0)
    stopLoggingButton.Position = UDim2.new(0.64, 10, 0, 0)
    stopLoggingButton.BackgroundColor3 = Color3.fromRGB(180, 80, 80)
    stopLoggingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopLoggingButton.Text = "⏹️ Stop Logging"
    stopLoggingButton.Font = Enum.Font.SourceSansBold
    stopLoggingButton.TextSize = 14
    stopLoggingButton.Parent = eventsControls
    
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
    functionsHeader.Text = "⚙️ FUNCTION LIST (Click Once)"
    functionsHeader.Font = Enum.Font.SourceSansBold
    functionsHeader.TextSize = 16
    functionsHeader.Parent = functionsTab
    
    local functionControls = Instance.new("Frame")
    functionControls.Name = "FunctionControls"
    functionControls.Size = UDim2.new(1, -20, 0, 40)
    functionControls.Position = UDim2.new(0, 10, 0, 60)
    functionControls.BackgroundTransparency = 1
    functionControls.Parent = functionsTab
    
    local findFunctionsButton = Instance.new("TextButton")
    findFunctionsButton.Name = "FindFunctionsButton"
    findFunctionsButton.Size = UDim2.new(0.4, 0, 1, 0)
    findFunctionsButton.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
    findFunctionsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    findFunctionsButton.Text = "🔍 Find All Functions"
    findFunctionsButton.Font = Enum.Font.SourceSansBold
    findFunctionsButton.TextSize = 14
    findFunctionsButton.Parent = functionControls
    
    local hookFunctionsButton = Instance.new("TextButton")
    hookFunctionsButton.Name = "HookFunctionsButton"
    hookFunctionsButton.Size = UDim2.new(0.4, 0, 1, 0)
    hookFunctionsButton.Position = UDim2.new(0.42, 10, 0, 0)
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
    
    -- ====== EVENT LOG TAB ======
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
    logHeader.Text = "📝 EVENT EXECUTION LOG"
    logHeader.Font = Enum.Font.SourceSansBold
    logHeader.TextSize = 16
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
    exportLogButton.Position = UDim2.new(0.32, 10, 0, 0)
    exportLogButton.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
    exportLogButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    exportLogButton.Text = "💾 Export Log"
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
        tabButtons = tabButtons,
        searchBox = searchBox,
        searchButton = searchButton,
        clearSearchButton = clearSearchButton,
        resultsFrame = resultsFrame,
        infoPanel = infoPanel,
        copyPathButton = copyPathButton,
        highlightButton = highlightButton,
        clearHighlightsButton = clearHighlightsButton,
        scanEventsButton = scanEventsButton,
        startLoggingButton = startLoggingButton,
        stopLoggingButton = stopLoggingButton,
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

-- Advanced Search with Wildcards
local function searchObjectsWithWildcards(searchTerm)
    local results = {}
    
    -- Convert wildcard pattern to Lua pattern
    local pattern = "^" .. string.gsub(string.gsub(searchTerm, "%*", ".*"), "%?", ".") .. "$"
    pattern = string.lower(pattern)
    
    local function searchRecursive(parent)
        for _, child in ipairs(parent:GetChildren()) do
            local name = string.lower(child.Name)
            
            -- Check if name matches pattern
            if string.match(name, pattern) then
                table.insert(results, {
                    object = child,
                    path = child:GetFullName(),
                    class = child.ClassName
                })
            end
            
            -- Recursive search (limited depth for performance)
            if #child:GetChildren() > 0 then
                searchRecursive(child)
            end
        end
    end
    
    searchRecursive(game)
    return results
end

-- Display Search Results
local function displaySearchResults(results, ui)
    -- Clear previous results
    for _, child in ipairs(ui.resultsFrame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    if #results == 0 then
        local noResults = Instance.new("TextLabel")
        noResults.Size = UDim2.new(1, -10, 0, 40)
        noResults.BackgroundTransparency = 1
        noResults.TextColor3 = Color3.fromRGB(150, 150, 150)
        noResults.Text = "No objects found. Try using * as wildcard (e.g., 'Part*', '*Remote*')"
        noResults.Font = Enum.Font.Code
        noResults.TextSize = 14
        noResults.TextWrapped = true
        noResults.Parent = ui.resultsFrame
        return
    end
    
    for i, result in ipairs(results) do
        if i > 100 then break end -- Limit results
        
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -10, 0, 35)
        button.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(45, 45, 55) or Color3.fromRGB(40, 40, 50)
        button.BorderSizePixel = 0
        button.TextColor3 = Color3.fromRGB(220, 220, 220)
        button.Text = result.object.Name .. "  [" .. result.object.ClassName .. "]"
        button.Font = Enum.Font.Code
        button.TextSize = 13
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.PaddingLeft = UDim.new(0, 10)
        button.Parent = ui.resultsFrame
        
        button.MouseButton1Click:Connect(function()
            selectedObject = result.object
            updateObjectInfo(result.object, ui)
        end)
        
        -- Right click to copy path
        button.MouseButton2Click:Connect(function()
            if setclipboard then
                setclipboard(result.path)
                showNotification("✓ Path copied to clipboard: " .. result.path)
            else
                -- Fallback for executors without setclipboard
                local pathLabel = Instance.new("TextLabel")
                pathLabel.Size = UDim2.new(1, -10, 0, 60)
                pathLabel.Position = UDim2.new(0, 5, 0.5, -30)
                pathLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
                pathLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                pathLabel.Text = "PATH:\n" .. result.path .. "\n\n(Click to close)"
                pathLabel.Font = Enum.Font.Code
                pathLabel.TextSize = 12
                pathLabel.TextWrapped = true
                pathLabel.ZIndex = 100
                pathLabel.Parent = button
                
                pathLabel.MouseButton1Click:Connect(function()
                    pathLabel:Destroy()
                end)
            end
        end)
    end
end

-- Update Object Info
local function updateObjectInfo(obj, ui)
    -- Clear previous info
    for _, child in ipairs(ui.infoPanel:GetChildren()) do
        if child:IsA("TextLabel") or child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    if not obj then return end
    
    local function addInfoRow(label, value, color)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -10, 0, 25)
        row.BackgroundTransparency = 1
        row.Parent = ui.infoPanel
        
        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(0.3, 0, 1, 0)
        labelText.BackgroundTransparency = 1
        labelText.TextColor3 = Color3.fromRGB(180, 180, 180)
        labelText.Text = label .. ":"
        labelText.Font = Enum.Font.Code
        labelText.TextSize = 13
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = row
        
        local valueText = Instance.new("TextLabel")
        valueText.Size = UDim2.new(0.7, 0, 1, 0)
        valueText.Position = UDim2.new(0.3, 0, 0, 0)
        valueText.BackgroundTransparency = 1
        valueText.TextColor3 = color or Color3.fromRGB(255, 255, 255)
        valueText.Text = tostring(value)
        valueText.Font = Enum.Font.Code
        valueText.TextSize = 13
        valueText.TextXAlignment = Enum.TextXAlignment.Left
        valueText.TextWrapped = true
        valueText.Parent = row
    end
    
    -- Basic Info
    addInfoRow("Name", obj.Name, Color3.fromRGB(100, 200, 255))
    addInfoRow("Class", obj.ClassName, Color3.fromRGB(255, 150, 100))
    addInfoRow("Full Path", obj:GetFullName(), Color3.fromRGB(150, 255, 150))
    
    if obj.Parent then
        addInfoRow("Parent", obj.Parent.Name, Color3.fromRGB(200, 200, 100))
    end
    
    -- Object-specific properties
    if obj:IsA("BasePart") then
        addInfoRow("Position", string.format("X: %.2f, Y: %.2f, Z: %.2f", 
            obj.Position.X, obj.Position.Y, obj.Position.Z), Color3.fromRGB(255, 200, 100))
        addInfoRow("Size", string.format("W: %.2f, H: %.2f, D: %.2f", 
            obj.Size.X, obj.Size.Y, obj.Size.Z), Color3.fromRGB(200, 100, 255))
    end
    
    -- Check for events/functions
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or 
       obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
        addInfoRow("Event Type", obj.ClassName, Color3.fromRGB(255, 100, 100))
    end
    
    -- Children count
    addInfoRow("Children", #obj:GetChildren(), Color3.fromRGB(200, 200, 200))
end

-- Highlight System
local function highlightObject(obj)
    if not obj then return end
    
    -- Remove existing highlight for this object
    if currentHighlights[obj] then
        currentHighlights[obj]:Destroy()
        currentHighlights[obj] = nil
        return
    end
    
    -- Create highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "ScriptExplorer_Highlight"
    highlight.FillColor = Color3.fromRGB(255, 255, 0)
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = Color3.fromRGB(255, 200, 0)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = obj
    
    currentHighlights[obj] = highlight
end

local function clearAllHighlights()
    for obj, highlight in pairs(currentHighlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    currentHighlights = {}
end

-- Event Detection System
local function scanAllEvents(ui)
    local eventTypes = {
        "RemoteEvent",
        "RemoteFunction", 
        "BindableEvent",
        "BindableFunction"
    }
    
    -- Clear previous list
    for _, child in ipairs(ui.eventsList:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    local allEvents = {}
    
    -- Find all events
    for _, obj in ipairs(game:GetDescendants()) do
        for _, eventType in ipairs(eventTypes) do
            if obj:IsA(eventType) then
                table.insert(allEvents, {
                    object = obj,
                    path = obj:GetFullName(),
                    type = eventType
                })
            end
        end
    end
    
    if #allEvents == 0 then
        local noEvents = Instance.new("TextLabel")
        noEvents.Size = UDim2.new(1, -10, 0, 40)
        noEvents.BackgroundTransparency = 1
        noEvents.TextColor3 = Color3.fromRGB(150, 150, 150)
        noEvents.Text = "No events found in the game."
        noEvents.Font = Enum.Font.Code
        noEvents.TextSize = 14
        noEvents.TextWrapped = true
        noEvents.Parent = ui.eventsList
        return
    end
    
    for i, event in ipairs(allEvents) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -10, 0, 40)
        button.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(45, 45, 55) or Color3.fromRGB(40, 40, 50)
        button.BorderSizePixel = 0
        button.TextColor3 = Color3.fromRGB(220, 220, 220)
        button.Text = event.type .. ": " .. event.object.Name .. "\n" .. event.path
        button.Font = Enum.Font.Code
        button.TextSize = 12
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.TextWrapped = true
        button.PaddingLeft = UDim.new(0, 10)
        button.Parent = ui.eventsList
        
        button.MouseButton1Click:Connect(function()
            selectedObject = event.object
            -- Switch to explorer tab and select this object
            switchToTab(1) -- Explorer tab
            -- We would need to search for and select this object
            -- For now, just copy the path
            if setclipboard then
                setclipboard(event.path)
                showNotification("✓ Event path copied: " .. event.path)
            end
        end)
    end
    
    showNotification("✓ Found " .. #allEvents .. " events in the game")
end

-- Event Logging System
local function startEventLogging(ui)
    if isLoggingEvents then return end
    isLoggingEvents = true
    
    -- Clear previous event listeners
    for _, connection in pairs(eventListeners) do
        if connection then
            connection:Disconnect()
        end
    end
    eventListeners = {}
    
    -- Hook all remote events
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local originalFireServer = obj.FireServer
            obj.FireServer = function(self, ...)
                local args = {...}
                local logEntry = {
                    timestamp = os.date("%H:%M:%S"),
                    eventType = "RemoteEvent",
                    eventName = obj.Name,
                    path = obj:GetFullName(),
                    args = args
                }
                
                table.insert(functionLog, logEntry)
                updateLogDisplay(ui)
                
                -- Call original function
                return originalFireServer(self, ...)
            end
            
            table.insert(eventListeners, {object = obj, original = originalFireServer})
        end
        
        if obj:IsA("RemoteFunction") then
            local originalInvokeServer = obj.InvokeServer
            obj.InvokeServer = function(self, ...)
                local args = {...}
                local logEntry = {
                    timestamp = os.date("%H:%M:%S"),
                    eventType = "RemoteFunction",
                    eventName = obj.Name,
                    path = obj:GetFullName(),
                    args = args
                }
                
                table.insert(functionLog, logEntry)
                updateLogDisplay(ui)
                
                -- Call original function
                return originalInvokeServer(self, ...)
            end
            
            table.insert(eventListeners, {object = obj, original = originalInvokeServer})
        end
    end
    
    showNotification("▶️ Started logging events. Perform actions in-game to see them here.")
end

local function stopEventLogging()
    if not isLoggingEvents then return end
    isLoggingEvents = false
    
    -- Restore original functions
    for _, listener in pairs(eventListeners) do
        if listener.object:IsA("RemoteEvent") then
            listener.object.FireServer = listener.original
        elseif listener.object:IsA("RemoteFunction") then
            listener.object.InvokeServer = listener.original
        end
    end
    
    eventListeners = {}
    showNotification("⏹️ Stopped logging events")
end

-- Function Finder (for attack paths)
local function findFunctions(ui)
    -- Clear previous list
    for _, child in ipairs(ui.functionsList:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    -- Look for potential attack functions
    local suspiciousFunctions = {
        "Damage", "Attack", "Hit", "Kill", "Health", 
        "TakeDamage", "DamagePlayer", "DamageEnemy",
        "Remote", "Event", "Function", "Fire", "Invoke"
    }
    
    local foundFunctions = {}
    
    -- Search in scripts
    for _, script in ipairs(game:GetDescendants()) do
        if script:IsA("ModuleScript") or script:IsA("Script") then
            local scriptName = string.lower(script.Name)
            
            for _, funcName in ipairs(suspiciousFunctions) do
                if string.find(scriptName, string.lower(funcName)) then
                    table.insert(foundFunctions, {
                        object = script,
                        path = script:GetFullName(),
                        reason = "Contains: " .. funcName
                    })
                    break
                end
            end
        end
    end
    
    -- Search for remotes with attack-related names
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local objName = string.lower(obj.Name)
            
            for _, funcName in ipairs(suspiciousFunctions) do
                if string.find(objName, string.lower(funcName)) then
                    table.insert(foundFunctions, {
                        object = obj,
                        path = obj:GetFullName(),
                        reason = obj.ClassName .. " with attack name"
                    })
                    break
                end
            end
        end
    end
    
    if #foundFunctions == 0 then
        local noFuncs = Instance.new("TextLabel")
        noFuncs.Size = UDim2.new(1, -10, 0, 40)
        noFuncs.BackgroundTransparency = 1
        noFuncs.TextColor3 = Color3.fromRGB(150, 150, 150)
        noFuncs.Text = "No suspicious functions found.\nTry searching for specific terms in Explorer tab."
        noFuncs.Font = Enum.Font.Code
        noFuncs.TextSize = 14
        noFuncs.TextWrapped = true
        noFuncs.Parent = ui.functionsList
        return
    end
    
    for i, func in ipairs(foundFunctions) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -10, 0, 50)
        button.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(45, 45, 55) or Color3.fromRGB(40, 40, 50)
        button.BorderSizePixel = 0
        button.TextColor3 = Color3.fromRGB(220, 220, 220)
        button.Text = "🔍 " .. func.object.Name .. " (" .. func.object.ClassName .. ")\n" .. func.reason .. "\nPath: " .. func.path
        button.Font = Enum.Font.Code
        button.TextSize = 11
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.TextWrapped = true
        button.PaddingLeft = UDim.new(0, 10)
        button.Parent = ui.functionsList
        
        button.MouseButton1Click:Connect(function()
            selectedObject = func.object
            if setclipboard then
                setclipboard(func.path)
                showNotification("✓ Path copied: " .. func.path)
            end
        end)
    end
    
    showNotification("✓ Found " .. #foundFunctions .. " potential attack functions")
end

-- Update Log Display
local function updateLogDisplay(ui)
    -- Clear previous log
    for _, child in ipairs(ui.logList:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    -- Show most recent logs (max 50)
    local startIndex = math.max(1, #functionLog - 49)
    
    for i = startIndex, #functionLog do
        local log = functionLog[i]
        
        local logEntry = Instance.new("TextLabel")
        logEntry.Size = UDim2.new(1, -10, 0, 60)
        logEntry.BackgroundTransparency = 1
        logEntry.TextColor3 = Color3.fromRGB(220, 220, 220)
        logEntry.Text = "[" .. log.timestamp .. "] " .. log.eventType .. ": " .. log.eventName .. "\nPath: " .. log.path .. "\nArgs: " .. tostring(#log.args) .. " arguments"
        logEntry.Font = Enum.Font.Code
        logEntry.TextSize = 12
        logEntry.TextXAlignment = Enum.TextXAlignment.Left
        logEntry.TextWrapped = true
        logEntry.Parent = ui.logList
    end
    
    -- Auto-scroll to bottom
    ui.logList.CanvasPosition = Vector2.new(0, ui.logList.CanvasSize.Y.Offset)
end

-- Notification System
local function showNotification(message)
    if not gui then return end
    
    local notification = Instance.new("TextLabel")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0.4, 0, 0, 40)
    notification.Position = UDim2.new(0.3, 0, 0.02, 0)
    notification.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    notification.Text = message
    notification.Font = Enum.Font.SourceSansBold
    notification.TextSize = 14
    notification.TextWrapped = true
    notification.ZIndex = 100
    notification.Parent = gui
    
    task.delay(3, function()
        if notification and notification.Parent then
            notification:Destroy()
        end
    end)
end

-- Tab Switching
local function switchToTab(tabIndex, ui)
    -- Hide all tabs
    for _, tab in pairs(ui.tabs) do
        tab.Visible = false
    end
    
    -- Show selected tab
    local tabNames = {"explorer", "events", "functions", "log"}
    ui.tabs[tabNames[tabIndex]].Visible = true
    
    -- Update tab buttons
    for i, tabBtn in ipairs(ui.tabButtons) do
        local button = ui.tabsContainer:FindFirstChild(tabBtn.name)
        if button then
            button.BackgroundColor3 = i == tabIndex and Color3.fromRGB(60, 60, 75) or Color3.fromRGB(40, 40, 50)
        end
    end
end

-- Main Initialization
local function init()
    local ui = createMainUI()
    
    -- Tab switching
    for i, tabBtn in ipairs(ui.tabButtons) do
        local button = ui.tabsContainer:FindFirstChild(tabBtn.name)
        if button then
            button.MouseButton1Click:Connect(function()
                switchToTab(i, ui)
            end)
        end
    end
    
    -- Explorer Tab Functions
    ui.searchButton.MouseButton1Click:Connect(function()
        local searchTerm = ui.searchBox.Text
        if searchTerm and #searchTerm > 0 then
            local results = searchObjectsWithWildcards(searchTerm)
            displaySearchResults(results, ui)
            showNotification("🔍 Found " .. #results .. " objects matching '" .. searchTerm .. "'")
        else
            showNotification("⚠️ Please enter a search term")
        end
    end)
    
    ui.searchBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local searchTerm = ui.searchBox.Text
            if searchTerm and #searchTerm > 0 then
                local results = searchObjectsWithWildcards(searchTerm)
                displaySearchResults(results, ui)
            end
        end
    end)
    
    ui.clearSearchButton.MouseButton1Click:Connect(function()
        ui.searchBox.Text = ""
        for _, child in ipairs(ui.resultsFrame:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("TextLabel") then
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
                showNotification("✓ Path copied to clipboard:\n" .. path)
            else
                showNotification("⚠️ setclipboard not available in this executor")
            end
        else
            showNotification("⚠️ No object selected")
        end
    end)
    
    ui.highlightButton.MouseButton1Click:Connect(function()
        if selectedObject then
            highlightObject(selectedObject)
            showNotification("🔦 Toggled highlight for " .. selectedObject.Name)
        else
            showNotification("⚠️ No object selected")
        end
    end)
    
    ui.clearHighlightsButton.MouseButton1Click:Connect(function()
        clearAllHighlights()
        showNotification("🗑️ All highlights cleared")
    end)
    
    -- Events Tab Functions
    ui.scanEventsButton.MouseButton1Click:Connect(function()
        scanAllEvents(ui)
    end)
    
    ui.startLoggingButton.MouseButton1Click:Connect(function()
        startEventLogging(ui)
    end)
    
    ui.stopLoggingButton.MouseButton1Click:Connect(function()
        stopEventLogging()
    end)
    
    -- Functions Tab Functions
    ui.findFunctionsButton.MouseButton1Click:Connect(function()
        findFunctions(ui)
    end)
    
    ui.hookFunctionsButton.MouseButton1Click:Connect(function()
        showNotification("🎣 Function hooking would go here (advanced feature)")
        -- This would require more complex hooking logic
    end)
    
    -- Log Tab Functions
    ui.clearLogButton.MouseButton1Click:Connect(function()
        functionLog = {}
        updateLogDisplay(ui)
        showNotification("🗑️ Event log cleared")
    end)
    
    ui.exportLogButton.MouseButton1Click:Connect(function()
        if #functionLog == 0 then
            showNotification("⚠️ No logs to export")
            return
        end
        
        local logText = "-- Event Log Export --\n"
        for _, log in ipairs(functionLog) do
            logText = logText .. string.format("[%s] %s: %s (%s)\n", 
                log.timestamp, log.eventType, log.eventName, log.path)
        end
        
        if setclipboard then
            setclipboard(logText)
            showNotification("✓ Log exported to clipboard")
        else
            showNotification("⚠️ Export requires setclipboard")
        end
    end)
    
    -- Close button
    ui.closeButton.MouseButton1Click:Connect(function()
        stopEventLogging()
        clearAllHighlights()
        gui:Destroy()
        gui = nil
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
    
    showNotification("🔧 Scripting Explorer v2.0 loaded!")
    return ui
end

-- Auto-execute when script is loaded (for executors)
if not gui then
    init()
end

-- Return the init function for manual execution
return init