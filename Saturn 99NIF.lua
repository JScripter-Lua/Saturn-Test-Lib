-- Load Fluent Renewed UI Library
local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau ", true))()

-- Create Window
local Window = Library:CreateWindow({
    Title = "🌲 99 Nights in Forest",
    Subtitle = "Cheat Menu",
    ConfigurationFile = "fluent_config.json",
    Accordion = true
})

-- Create Tabs
local tabs = {
    info = Window:AddTab("Info", {InfiniteScroll = true}),
    esp = Window:AddTab("ESP"),
    teleport = Window:AddTab("Teleport"),
    bring = Window:AddTab("Bring Items"),
    hitbox = Window:AddTab("Hitbox"),
    misc = Window:AddTab("Misc")
}

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

-- Globals
local ESPFolder = {}
local tracers = {}
local itemESPTable = {}

-- ESP Settings
local espSettings = {
    PlayerESP = false,
    Fairy = false,
    Wolf = false,
    Bunny = false,
    Cultist = false,
    CrossBow = false,
    PeltTrader = false,
    NameColor = Color3.fromRGB(255, 255, 255),
    NameSize = 16,
    HPBarSize = Vector2.new(60, 6)
}

-- Create ESP for a model
local function createESP(model, nameText)
    local head = model:FindFirstChild("Head") or model:FindFirstChildWhichIsA("BasePart")
    if not head then return end
    
    local name = Drawing.new("Text")
    name.Size = espSettings.NameSize
    name.Center = true
    name.Outline = true
    name.Color = espSettings.NameColor
    name.Visible = false
    
    -- Health bar background
    local hpBack = Drawing.new("Square")
    hpBack.Color = Color3.fromRGB(0, 0, 0)
    hpBack.Thickness = 1
    hpBack.Filled = true
    hpBack.Transparency = 0.7
    hpBack.Visible = false
    
    -- Health bar foreground
    local hpBar = Drawing.new("Square")
    hpBar.Color = Color3.fromRGB(0, 255, 0)
    hpBar.Thickness = 1
    hpBar.Filled = true
    hpBar.Transparency = 0.9
    hpBar.Visible = false
    
    ESPFolder[model] = {
        head = head,
        model = model,
        name = name,
        hpBar = hpBar,
        hpBack = hpBack,
        label = nameText
    }
end

-- Remove all tracers from last frame safely
local function clearTracers()
    for _, line in ipairs(tracers) do
        line:Remove()
    end
    table.clear(tracers)
end

-- Main ESP render loop
RunService.RenderStepped:Connect(function()
    clearTracers()
    local screenMid = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    
    for model, data in pairs(ESPFolder) do
        local head = data.head
        if model and head and model.Parent and head:IsDescendantOf(workspace) then
            local isPlayer = Players:GetPlayerFromCharacter(model)
            local visible = false
            local labelText = ""
            
            if isPlayer and espSettings.PlayerESP then
                local distVal = math.floor((Camera.CFrame.Position - head.Position).Magnitude)
                labelText = model.Name .. " {" .. distVal .. "m}"
                visible = true
            elseif not isPlayer then
                local n = model.Name:lower()
                local distVal = math.floor((Camera.CFrame.Position - head.Position).Magnitude)
                
                if espSettings.Fairy and n:find("fairy") then
                    labelText = "🧚 Fairy {" .. distVal .. "m}"
                    visible = true
                elseif espSettings.Wolf and (n:find("wolf") or n:find("alpha")) then
                    labelText = "🐺 Wolf {" .. distVal .. "m}"
                    visible = true
                elseif espSettings.Bunny and n:find("bunny") then
                    labelText = "🐰 Bunny {" .. distVal .. "m}"
                    visible = true
                elseif espSettings.Cultist and n:find("cultist") and not n:find("cross") then
                    labelText = "👺 Cultist {" .. distVal .. "m}"
                    visible = true
                elseif espSettings.CrossBow and n:find("cross") then
                    labelText = "🏹 CrossBow Cultist {" .. distVal .. "m}"
                    visible = true
                elseif espSettings.PeltTrader and n:find("pelt") then
                    labelText = "🛒 Pelt Trader {" .. distVal .. "m}"
                    visible = true
                end
            end
            
            if visible then
                local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    -- Position text 25 pixels ABOVE the head
                    local textY = headPos.Y - 25
                    data.name.Text = labelText
                    data.name.Position = Vector2.new(headPos.X, textY)
                    data.name.Color = espSettings.NameColor
                    data.name.Size = espSettings.NameSize
                    data.name.Visible = true
                    
                    -- Health bar below the text
                    local humanoid = model:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        local hpPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                        local barWidth = espSettings.HPBarSize.X
                        local barHeight = espSettings.HPBarSize.Y
                        local barX = headPos.X - (barWidth / 2)
                        local barY = textY + 18
                        
                        data.hpBack.Size = Vector2.new(barWidth, barHeight)
                        data.hpBack.Position = Vector2.new(barX, barY)
                        data.hpBack.Visible = true
                        
                        data.hpBar.Size = Vector2.new(barWidth * hpPercent, barHeight)
                        data.hpBar.Position = Vector2.new(barX, barY)
                        data.hpBar.Color = Color3.new(1 - hpPercent, hpPercent, 0)
                        data.hpBar.Visible = true
                    else
                        data.hpBar.Visible = false
                        data.hpBack.Visible = false
                    end
                    
                    -- Draw tracer line
                    local line = Drawing.new("Line")
                    line.From = screenMid - Vector2.new(0, 10)
                    line.To = Vector2.new(headPos.X, headPos.Y)
                    line.Color = Color3.fromRGB(255, 0, 0)
                    line.Thickness = 1
                    line.Visible = true
                    table.insert(tracers, line)
                else
                    data.name.Visible = false
                    data.hpBar.Visible = false
                    data.hpBack.Visible = false
                end
            else
                data.name.Visible = false
                data.hpBar.Visible = false
                data.hpBack.Visible = false
            end
        else
            data.name.Visible = false
            data.hpBar.Visible = false
            data.hpBack.Visible = false
        end
    end
end)

-- Scanner to add ESP to models dynamically
task.spawn(function()
    while true do
        task.wait(1)
        for _, model in pairs(workspace:GetDescendants()) do
            if model:IsA("Model") and not ESPFolder[model] and model:FindFirstChild("Head") then
                if Players:GetPlayerFromCharacter(model) or model:IsDescendantOf(workspace.Characters) then
                    createESP(model, "Unknown")
                end
            end
        end
    end
end)

-- ESP Toggles in ESP Tab
local playerCounter = Drawing.new("Text")
playerCounter.Center = true
playerCounter.Outline = true
playerCounter.Size = 40
playerCounter.Color = Color3.fromRGB(255, 0, 0)
playerCounter.Font = 4
playerCounter.Visible = false

local linesEnabled = false
local trackerEnabled = false
local maxLines = 50
local playerLines = {}

for i = 1, maxLines do
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = Color3.fromRGB(255, 0, 0)
    line.Thickness = 2
    playerLines[i] = line
end

-- Tracker Toggle
esp:CreateToggle({
    Name = "Player ESP",
    Default = false,
    Callback = function(v)
        espSettings.PlayerESP = v
        trackerEnabled = v
        linesEnabled = v
        playerCounter.Visible = v
        
        if not v then
            for _, line in pairs(playerLines) do
                line.Visible = false
            end
        end
    end
})

-- Update Drawing
game:GetService("RunService").RenderStepped:Connect(function()
    if not trackerEnabled then
        playerCounter.Visible = false
        for _, line in pairs(playerLines) do
            line.Visible = false
        end
        return
    end
    
    local visibleCount = 0
    local viewportSize = Camera.ViewportSize
    local startLinePos = Vector2.new(viewportSize.X / 2, 50)
    local visiblePlayers = {}
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen and screenPos.Z > 0 then
                    visibleCount = visibleCount + 1
                    table.insert(visiblePlayers, {player = player, pos = Vector2.new(screenPos.X, screenPos.Y)})
                end
            end
        end
    end
    
    playerCounter.Text = tostring(visibleCount)
    playerCounter.Position = Vector2.new(viewportSize.X / 2, 8)
    playerCounter.Visible = trackerEnabled
    
    for i = 1, maxLines do
        playerLines[i].Visible = false
    end
    
    if linesEnabled and visibleCount > 0 then
        for i, info in pairs(visiblePlayers) do
            if i > maxLines then break end
            local line = playerLines[i]
            line.From = startLinePos
            line.To = info.pos
            line.Visible = true
        end
    end
end)

-- ESP Toggles
esp:CreateToggle({Name = "Fairy ESP", Default = false, Callback = function(v) espSettings.Fairy = v end})
esp:CreateToggle({Name = "Wolf ESP", Default = false, Callback = function(v) espSettings.Wolf = v end})
esp:CreateToggle({Name = "Bunny ESP", Default = false, Callback = function(v) espSettings.Bunny = v end})
esp:CreateToggle({Name = "Cultist ESP", Default = false, Callback = function(v)
    espSettings.Cultist = v
    espSettings.CrossBow = v
end})
esp:CreateToggle({Name = "Pelt Trader ESP", Default = false, Callback = function(v) espSettings.PeltTrader = v end})

-- Item ESP Settings
local itemESPEnabled = true
local itemColor = Color3.fromRGB(255, 255, 0)

-- Valid items only (confirmed working/real)
local showToggles = {
    ["Berry"] = false,
    ["Log"] = false,
    ["Chest"] = false,
    ["Toolbox"] = false,
    ["Coal"] = false,
    ["Carrot"] = false,
    ["Flashlight"] = false,
    ["Radio"] = false,
    ["Sheet Metal"] = false,
    ["Bolt"] = false,
    ["Chair"] = false,
    ["Fan"] = false,
    ["Good Sack"] = false,
    ["Good Axe"] = false,
    ["Raw Meat"] = false,
    ["Cooked Meat"] = false,
    ["Stone"] = false,
    ["Nails"] = false,
    ["Scrap"] = false,
    ["Wooden Plank"] = false,
}

-- Main ESP toggle
esp:CreateToggle({
    Name = "Item ESP",
    Default = true,
    Callback = function(v) itemESPEnabled = v 
end})

-- Color picker
esp:CreateColorSlider({
    Name = "Item ESP Color",
    Default = itemColor,
    Callback = function(v) itemColor = v 
end})

local foodItems = {
    "Berry",
    "Carrot",
    "Raw Meat",
    "Cooked Meat"
}

esp:CreateToggle({
    Name = "Food ESP",
    Default = false,
    Callback = function(v)
        for _, itemName in ipairs(foodItems) do
            showToggles[itemName] = v
        end
    end
})

esp:CreateToggle({
    Name = "Revolver + Ammo ESP",
    Default = false,
    Callback = function(v)
        showToggles["Revolver"] = v
        showToggles["Revolver Ammo"] = v
    end
})

-- Toggles for each item (excluding food items)
for itemName, _ in pairs(showToggles) do
    local isFood = table.find(foodItems, itemName)
    if not isFood then
        esp:CreateToggle({
            Name = itemName,
            Default = false,
            Callback = function(v) showToggles[itemName] = v 
        end)
    end
end

--// ESP Logic
local ItemsFolder = workspace:WaitForChild("Items")

local function createItemText()
    local text = Drawing.new("Text")
    text.Size = 14
    text.Center = true
    text.Outline = true
    text.Font = 2
    text.Color = itemColor
    text.Visible = false
    return text
end

local function updateItems()
    for _, item in ipairs(ItemsFolder:GetChildren()) do
        if not itemESPTable[item] then
            local part = item:FindFirstChildWhichIsA("BasePart") or (item:IsA("BasePart") and item)
            if part then
                itemESPTable[item] = {
                    part = part,
                    text = createItemText()
                }
            end
        end
    end
    
    for obj, esp in pairs(itemESPTable) do
        if not obj:IsDescendantOf(Workspace) then
            esp.text:Remove()
            itemESPTable[obj] = nil
        end
    end
end

RunService.RenderStepped:Connect(function()
    if not itemESPEnabled then
        for _, esp in pairs(itemESPTable) do
            esp.text.Visible = false
        end
        return
    end
    
    updateItems()
    
    for item, esp in pairs(itemESPTable) do
        local part = esp.part
        local text = esp.text
        local name = item.Name
        
        if part and showToggles[name] then
            local pos, visible = Camera:WorldToViewportPoint(part.Position)
            if visible then
                local distance = (Camera.CFrame.Position - part.Position).Magnitude
                text.Text = string.format("%s [%.0fm]", name, distance)
                text.Position = Vector2.new(pos.X, pos.Y)
                text.Color = itemColor
                text.Visible = true
            else
                text.Visible = false
            end
        else
            text.Visible = false
        end
    end
end)

-- Speed hack
getgenv().speedEnabled = false
getgenv().speedValue = 28

misc:CreateToggle({
    Name = "Speed Hack",
    Default = false,
    Callback = function(v)
        getgenv().speedEnabled = v
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = v and getgenv().speedValue or 16 
    end
})

misc:CreateSlider({
    Name = "Speed Value",
    Min = 16,
    Max = 600,
    Default = 28,
    Rounding = 1,
    Suffix = "Speed",
    Callback = function(val)
        getgenv().speedValue = val
        if getgenv().speedEnabled then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = val end
        end
    end
})

-- FPS + Ping Drawing Setup
local showFPS = true
local showPing = true

local fpsText = Drawing.new("Text")
fpsText.Size = 16
fpsText.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X - 100, 10)
fpsText.Color = Color3.fromRGB(0, 255, 0)
fpsText.Center = false
fpsText.Outline = true
fpsText.Visible = showFPS

local msText = Drawing.new("Text")
msText.Size = 16
msText.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X - 100, 30)
msText.Color = Color3.fromRGB(0, 255, 0)
msText.Center = false
msText.Outline = true
msText.Visible = showPing

local fpsCounter = 0
local fpsLastUpdate = tick()

RunService.RenderStepped:Connect(function()
    fpsCounter = fpsCounter + 1
    
    if tick() - fpsLastUpdate >= 1 then
        -- Update FPS
        if showFPS then
            fpsText.Text = "FPS: " .. tostring(fpsCounter)
            fpsText.Visible = true
        else
            fpsText.Visible = false
        end
        
        -- Update Ping
        if showPing then
            local pingStat = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]
            local ping = pingStat and math.floor(pingStat:GetValue()) or 0
            msText.Text = "Ping: " .. ping .. " ms"
            
            if ping <= 60 then
                msText.Color = Color3.fromRGB(0, 255, 0)
            elseif ping <= 120 then
                msText.Color = Color3.fromRGB(255, 165, 0)
            else
                msText.Color = Color3.fromRGB(255, 0, 0)
            end
            msText.Visible = true
        else
            msText.Visible = false
        end
        
        fpsCounter = 0
        fpsLastUpdate = tick()
    end
end)

-- FPS + Ping Toggles
misc:CreateToggle({
    Name = "Show FPS",
    Default = true,
    Callback = function(val)
        showFPS = val
        fpsText.Visible = val
    end
})

misc:CreateToggle({
    Name = "Show Ping (ms)",
    Default = true,
    Callback = function(val)
        showPing = val
        msText.Visible = val
    end
})

misc:CreateButton({
    Name = "FPS Boost",
    Callback = function()
        pcall(function()
            -- Lower rendering quality
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            
            -- Disable lighting effects
            Lighting.Brightness = 0
            Lighting.FogEnd = 100
            Lighting.GlobalShadows = false
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0
            Lighting.ClockTime = 14
            Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
            
            -- Terrain settings
            local terrain = workspace:FindFirstChildOfClass("Terrain")
            if terrain then
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
                terrain.WaterTransparency = 1
            end
            
            -- Disable all effects
            for _, obj in ipairs(Lighting:GetDescendants()) do
                if obj:IsA("PostEffect") or obj:IsA("BloomEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect") or obj:IsA("BlurEffect") then
                    obj.Enabled = false
                end
            end
            
            -- Remove textures and particles
            for _, obj in ipairs(game:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                    obj.Enabled = false
                elseif obj:IsA("Texture") or obj:IsA("Decal") then
                    obj.Transparency = 1
                end
            end
            
            -- Remove shadows on parts
            for _, part in ipairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CastShadow = false
                end
            end
        end)
        print("✅ FPS Boost Applied")
    end
})

-- Info Tab
tabs.info:AddLabel("Welcome to 99 Nights in Forest Cheat Script")
tabs.info:AddLabel("This script provides various cheats and utilities for the game.")
tabs.info:AddLabel("Features include:")
tabs.info:AddList("• ESP for players and NPCs", {
    "• Player ESP",
    "• Fairy ESP",
    "• Wolf ESP",
    "• Bunny ESP",
    "• Cultist ESP",
    "• Pelt Trader ESP"
})
tabs.info:AddList("• Teleport functions", {
    "• Teleport to Camp",
    "• Teleport to Trader"
})
tabs.info:AddList("• Item bringing functions", {
    "• Bring Everything",
    "• Auto Cook Meat",
    "• Bring Logs",
    "• Bring Coal",
    "• Bring Meat",
    "• Bring Specific Items"
})
tabs.info:AddList("• Misc features", {
    "• Speed Hack",
    "• FPS/Ping Display",
    "• FPS Boost"
})

-- Teleport Tab
teleport:CreateButton({
    Name = "Teleport to Camp",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(
                13.287363052368164, 3.999999761581421, 0.36212217807769775,
                0.6022269129753113, -2.275036159460342e-08, 0.7983249425888062,
                6.430457055728311e-09, 1, 2.364672191390582e-08,
                -0.7983249425888062, -9.1070981866892e-09, 0.6022269129753113
            )
        end
    end
})

teleport:CreateButton({
    Name = "Teleport to Trader",
    Callback = function()
        local pos = Vector3.new(-37.08, 3.98, -16.33)
        local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        hrp.CFrame = CFrame.new(pos)
    end
})

-- Bring Items Tab
bring:CreateButton({
    Name = "Bring Everything",
    Callback = function()
        for _, item in ipairs(workspace.Items:GetChildren()) do
            local part = item:FindFirstChildWhichIsA("BasePart") or item:IsA("BasePart") and item
            if part then
                part.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
})

-- Auto Cook Meat
local campfirePos = Vector3.new(1.87, 4.33, -3.67)
local function bringMeat()
    for _, item in pairs(workspace.Items:GetChildren()) do
        if item:IsA("Model") or item:IsA("BasePart") then
            local name = item.Name:lower()
            if name:find("meat") then
                local part = item:FindFirstChildWhichIsA("BasePart") or item
                if part then
                    part.CFrame = CFrame.new(campfirePos + Vector3.new(math.random(-2,2), 0.5, math.random(-2,2)))
                end
            end
        end
    end
end

bring:CreateButton({
    Name = "Auto Cook Meat",
    Callback = bringMeat
})

-- Bring Logs
bring:CreateButton({
    Name = "Bring Logs",
    Callback = function()
        local lp = game:GetService("Players").LocalPlayer
        local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local count = 0
        
        for _, item in pairs(workspace.Items:GetChildren()) do
            if item.Name:lower():find("log") and item:IsA("Model") then
                local main = item:FindFirstChildWhichIsA("BasePart")
                if main then
                    main.CFrame = root.CFrame * CFrame.new(math.random(-5,5), 0, math.random(-5,5))
                    count = count + 1
                end
            end
        end
        
        print("✅ Brought " .. count .. " logs to you.")
    end
})

-- Bring Coal
bring:CreateButton({
    Name = "Bring Coal",
    Callback = function()
        local lp = game:GetService("Players").LocalPlayer
        local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local count = 0
        
        for _, item in pairs(workspace.Items:GetChildren()) do
            if item.Name:lower():find("coal") and item:IsA("Model") then
                local main = item:FindFirstChildWhichIsA("BasePart")
                if main then
                    main.CFrame = root.CFrame * CFrame.new(math.random(-5,5), 0, math.random(-5,5))
                    count = count + 1
                end
            end
        end
        
        print("✅ Brought " .. count .. " coal to you.")
    end
})

-- Bring Meat (Raw + Cooked)
bring:CreateButton({
    Name = "Bring Meat (Raw + Cooked)",
    Callback = function()
        local lp = game:GetService("Players").LocalPlayer
        local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local count = 0
        
        for _, item in pairs(workspace.Items:GetChildren()) do
            local name = item.Name:lower()
            if (name:find("meat") or name:find("cooked")) and item:IsA("Model") then
                local main = item:FindFirstChildWhichIsA("BasePart")
                if main then
                    main.CFrame = root.CFrame * CFrame.new(math.random(-5,5), 0, math.random(-5,5))
                    count = count + 1
                end
            end
        end
        
        print("✅ Brought " .. count .. " meat items to you.")
    end
})

local function bringItemsByName(name)
    for _, item in ipairs(workspace.Items:GetChildren()) do
        if item.Name:lower():find(name:lower()) then
            local part = item:FindFirstChildWhichIsA("BasePart") or item:IsA("BasePart") and item
            if part then
                part.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
end

bring:CreateButton({
    Name = "Bring Flashlight",
    Callback = function()
        bringItemsByName("Flashlight")
    end
})

bring:CreateButton({
    Name = "Bring Nails",
    Callback = function()
        bringItemsByName("Nails")
    end
})

bring:CreateButton({
    Name = "Bring Fan",
    Callback = function()
        bringItemsByName("Fan")
    end
})

bring:CreateButton({
    Name = "Bring Ammo",
    Callback = function()
        local keywords = {"ammo"}
        local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        for _, item in ipairs(workspace.Items:GetChildren()) do
            for _, word in ipairs(keywords) do
                if item.Name:lower():find(word) then
                    local part = item:FindFirstChildWhichIsA("BasePart") or item:IsA("BasePart") and item
                    if part then
                        part.CFrame = root.CFrame + Vector3.new(math.random(-5,5), 0, math.random(-5,5))
                    end
                end
            end
        end
    end
})

bring:CreateButton({
    Name = "Bring Sheet Metal",
    Callback = function()
        local keyword = "sheet metal"
        local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        for _, item in ipairs(workspace.Items:GetChildren()) do
            if item.Name:lower():find(keyword) then
                local part = item:FindFirstChildWhichIsA("BasePart") or item:IsA("BasePart") and item
                if part then
                    part.CFrame = root.CFrame + Vector3.new(math.random(-5,5), 0, math.random(-5,5))
                end
            end
        end
    end
})

-- Bring Fuel Canister
bring:CreateButton({
    Name = "Bring Fuel Canister",
    Callback = function()
        local keyword = "fuel canister"
        local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        for _, item in ipairs(workspace.Items:GetChildren()) do
            if item.Name:lower():find(keyword) then
                local part = item:FindFirstChildWhichIsA("BasePart") or (item:IsA("BasePart") and item)
                if part then
                    part.CFrame = root.CFrame + Vector3.new(math.random(-5,5), 0, math.random(-5,5))
                end
            end
        end
    end
})

-- Bring Tyre
bring:CreateButton({
    Name = "Bring Tyre",
    Callback = function()
        local keyword = "tyre"
        local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        for _, item in ipairs(workspace.Items:GetChildren()) do
            if item.Name:lower():find(keyword) then
                local part = item:FindFirstChildWhichIsA("BasePart") or (item:IsA("BasePart") and item)
                if part then
                    part.CFrame = root.CFrame + Vector3.new(math.random(-5,5), 0, math.random(-5,5))
                end
            end
        end
    end
})

bring:CreateButton({
    Name = "Bring Bandage",
    Callback = function()
        local lp = game.Players.LocalPlayer
        local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        for _, item in ipairs(workspace.Items:GetChildren()) do
            if item:IsA("Model") and item.Name:lower():find("bandage") then
                local part = item:FindFirstChildWhichIsA("BasePart")
                if part then
                    part.CFrame = root.CFrame + Vector3.new(0, 2, 0)
                end
            end
        end
    end
})

bring:CreateButton({
    Name = "Bring Lost Child",
    Callback = function()
        for _, model in ipairs(workspace:GetDescendants()) do
            if model:IsA("Model") and model.Name:lower():find("lost") and model:FindFirstChild("HumanoidRootPart") then
                model:PivotTo(game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0))
            end
        end
    end
})

bring:CreateButton({
    Name = "Bring Revolver",
    Callback = function()
        for _, item in ipairs(workspace.Items:GetChildren()) do
            if item:IsA("Model") and item.Name:lower():find("revolver") then
                local part = item:FindFirstChildWhichIsA("BasePart")
                if part then
                    part.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
                end
            end
        end
    end
})

-- Hitbox Settings
local hitboxSettings = {
    Wolf = false,
    Bunny = false,
    Cultist = false,
    Show = false,
    Size = 10
}

-- Update matching NPC hitboxes
local function updateHitboxForModel(model)
    local root = model:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local name = model.Name:lower()
    local shouldResize =
        (hitboxSettings.Wolf and (name:find("wolf") or name:find("alpha"))) or
        (hitboxSettings.Bunny and name:find("bunny")) or
        (hitboxSettings.Cultist and (name:find("cultist") or name:find("cross")))
    
    if shouldResize then
        root.Size = Vector3.new(hitboxSettings.Size, hitboxSettings.Size, hitboxSettings.Size)
        root.Transparency = hitboxSettings.Show and 0.5 or 1
        root.Color = Color3.fromRGB(255, 255, 255)
        root.Material = Enum.Material.Neon
        root.CanCollide = false
    end
end

-- Loop to scan and apply hitbox updates every 2 seconds
task.spawn(function()
    while true do
        for _, model in ipairs(workspace:GetDescendants()) do
            if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") then
                updateHitboxForModel(model)
            end
        end
        task.wait(2)
    end
end)

-- UI Controls
hitbox:CreateToggle({
    Name = "Expand Wolf Hitbox",
    Default = false,
    Callback = function(val)
        hitboxSettings.Wolf = val
    end
})

hitbox:CreateToggle({
    Name = "Expand Bunny Hitbox",
    Default = false,
    Callback = function(val)
        hitboxSettings.Bunny = val
    end
})

hitbox:CreateToggle({
    Name = "Expand Cultist Hitbox",
    Default = false,
    Callback = function(val)
        hitboxSettings.Cultist = val
    end
})

hitbox:CreateSlider({
    Name = "Hitbox Size",
    Min = 2,
    Max = 30,
    Default = 10,
    Rounding = 1,
    Suffix = "Size",
    Callback = function(val)
        hitboxSettings.Size = val
    end
})

hitbox:CreateToggle({
    Name = "Show Hitbox (Transparency)",
    Default = false,
    Callback = function(val)
        hitboxSettings.Show = val
    end
})