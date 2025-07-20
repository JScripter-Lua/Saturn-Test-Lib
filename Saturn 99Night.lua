local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "DYHUB | 99 Nights",
    SubTitle = "by DYHUB",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "settings" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
    Bring = Window:AddTab({ Title = "Bring", Icon = "package" }),
    Hitbox = Window:AddTab({ Title = "Hitbox", Icon = "crosshair" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "tool" })
}

-- Main Tab
local MainBox = Tabs.Main:AddLeftGroupbox("Main Features")

MainBox:AddToggle("InfHunger", {
    Title = "Infinite Hunger",
    Description = "Prevents hunger from decreasing",
    Default = false,
    Callback = function(State)
        if State then
            coroutine.wrap(function()
                local RequestConsumeItem = game:GetService("ReplicatedStorage").RemoteEvents.RequestConsumeItem
                while Fluent.Flags.InfHunger do
                    RequestConsumeItem:InvokeServer(Instance.new("Model"))
                    task.wait(1)
                end
            end)()
        end
    end
})

MainBox:AddToggle("AutoTree", {
    Title = "Auto Tree Farm",
    Description = "Automatically farms nearby trees",
    Default = false,
    Callback = function(State)
        if State then
            coroutine.wrap(function()
                local ToolDamageObject = game:GetService("ReplicatedStorage").RemoteEvents.ToolDamageObject
                local LocalPlayer = game:GetService("Players").LocalPlayer
                
                while Fluent.Flags.AutoTree do
                    local trees = {}
                    local map = workspace:FindFirstChild("Map")
                    if map then
                        local landmarks = map:FindFirstChild("Landmarks") or map:FindFirstChild("Foliage")
                        if landmarks then
                            for _, tree in ipairs(landmarks:GetChildren()) do
                                if tree.Name == "Small Tree" and tree:IsA("Model") then
                                    local trunk = tree:FindFirstChild("Trunk") or tree.PrimaryPart
                                    if trunk then table.insert(trees, {tree = tree, trunk = trunk}) end
                                end
                            end
                        end
                    end
                    
                    for _, t in ipairs(trees) do
                        if not Fluent.Flags.AutoTree then break end
                        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp and t.trunk then
                            hrp.CFrame = t.trunk.CFrame + t.trunk.CFrame.RightVector * 3
                            task.wait(0.25)
                            local axe = LocalPlayer.Inventory:FindFirstChild("Old Axe") or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
                            if axe then
                                axe.Parent = char
                                task.wait(0.15)
                                while t.tree.Parent and Fluent.Flags.AutoTree do
                                    pcall(function() axe:Activate() end)
                                    ToolDamageObject:InvokeServer(t.tree, axe, "1_8264699301", t.trunk.CFrame)
                                    task.wait(1)
                                end
                            end
                        end
                        task.wait(0.5)
                    end
                    task.wait(1)
                end
            end)()
        end
    end
})

MainBox:AddSlider("HitSpeed", {
    Title = "Auto Hit Speed",
    Description = "Adjust hit speed for Auto Hit",
    Min = 0.1,
    Max = 2,
    Default = 1,
    Rounding = 1,
    Callback = function(Value) end
})

MainBox:AddToggle("AutoHit", {
    Title = "Auto Hit",
    Description = "Automatically hits objects in front of you",
    Default = false,
    Callback = function(State)
        if State then
            coroutine.wrap(function()
                local player = game.Players.LocalPlayer
                local camera = workspace.CurrentCamera
                while Fluent.Flags.AutoHit do
                    local weapon = player.Inventory:FindFirstChild("Spear") or 
                                 player.Inventory:FindFirstChild("Strong Axe") or 
                                 player.Inventory:FindFirstChild("Good Axe") or 
                                 player.Inventory:FindFirstChild("Old Axe")
                    if weapon then
                        local ray = workspace:Raycast(camera.CFrame.Position, camera.CFrame.LookVector * 15)
                        if ray and ray.Instance and ray.Instance.Name == "Trunk" then
                            game:GetService("ReplicatedStorage").RemoteEvents.ToolDamageObject:InvokeServer(
                                ray.Instance.Parent, weapon, "4_7591937906", CFrame.new(ray.Position))
                        end
                    end
                    task.wait(Fluent.Flags.HitSpeed)
                end
            end)()
        end
    end
})

-- Teleport Tab
local TeleportBox = Tabs.Teleport:AddLeftGroupbox("Locations")

TeleportBox:AddButton("Camp", {
    Title = "Teleport to Camp",
    Description = "Teleports you to the camp location",
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

TeleportBox:AddButton("Trader", {
    Title = "TP to NPC Trader",
    Description = "Teleports you to the trader NPC",
    Callback = function()
        local pos = Vector3.new(-37.08, 3.98, -16.33)
        local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        hrp.CFrame = CFrame.new(pos)
    end
})

TeleportBox:AddButton("RandomTree", {
    Title = "TP to Random Tree",
    Description = "Teleports you to a random tree location",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local map = workspace:FindFirstChild("Map")
        if not map then return end
        
        local foliage = map:FindFirstChild("Foliage") or map:FindFirstChild("Landmarks")
        if not foliage then return end

        local trees = {}
        for _, obj in ipairs(foliage:GetChildren()) do
            if obj.Name == "Small Tree" and obj:IsA("Model") then
                local trunk = obj:FindFirstChild("Trunk") or obj.PrimaryPart
                if trunk then table.insert(trees, trunk) end
            end
        end

        if #trees > 0 then
            local trunk = trees[math.random(1, #trees)]
            hrp.CFrame = trunk.CFrame + trunk.CFrame.RightVector * 3
        end
    end
})

-- Bring Tab
local BringBox = Tabs.Bring:AddLeftGroupbox("Items")

local function bringItemsByName(name)
    for _, item in ipairs(workspace.Items:GetChildren()) do
        if item.Name:lower():find(name:lower()) then
            local part = item:FindFirstChildWhichIsA("BasePart") or (item:IsA("BasePart") and item)
            if part then
                part.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
end

BringBox:AddButton("Everything", {
    Title = "Bring Everything",
    Description = "Brings all nearby items to you",
    Callback = function()
        for _, item in ipairs(workspace.Items:GetChildren()) do
            local part = item:FindFirstChildWhichIsA("BasePart") or (item:IsA("BasePart") and item)
            if part then
                part.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
})

local itemButtons = {
    {Title = "Auto Cook Meat", Keyword = "meat", Special = true},
    {Title = "Bring Logs", Keyword = "log"},
    {Title = "Bring Coal", Keyword = "coal"},
    {Title = "Bring Meat", Keyword = "meat"},
    {Title = "Bring Flashlight", Keyword = "flashlight"},
    {Title = "Bring Nails", Keyword = "nails"},
    {Title = "Bring Fan", Keyword = "fan"},
    {Title = "Bring Ammo", Keyword = "ammo"},
    {Title = "Bring Sheet Metal", Keyword = "sheet metal"},
    {Title = "Bring Fuel Canister", Keyword = "fuel canister"},
    {Title = "Bring Tyre", Keyword = "tyre"},
    {Title = "Bring Bandage", Keyword = "bandage"},
    {Title = "Bring Lost Child", Keyword = "lost"},
    {Title = "Bring Revolver", Keyword = "revolver"}
}

for _, button in ipairs(itemButtons) do
    BringBox:AddButton(button.Title:gsub("%s", ""), {
        Title = button.Title,
        Description = "Brings " .. button.Keyword .. " to your location",
        Callback = function()
            if button.Special then
                local campfirePos = Vector3.new(1.87, 4.33, -3.67)
                for _, item in pairs(workspace.Items:GetChildren()) do
                    if (item:IsA("Model") or item:IsA("BasePart")) and item.Name:lower():find("meat") then
                        local part = item:FindFirstChildWhichIsA("BasePart") or item
                        if part then
                            part.CFrame = CFrame.new(campfirePos + Vector3.new(math.random(-2,2), 0.5, math.random(-2,2))
                        end
                    end
                end
            elseif button.Title == "Bring Lost Child" then
                for _, model in ipairs(workspace:GetDescendants()) do
                    if model:IsA("Model") and model.Name:lower():find("lost") and model:FindFirstChild("HumanoidRootPart") then
                        model:PivotTo(game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0))
                    end
                end
            else
                bringItemsByName(button.Keyword)
            end
        end
    })
end

-- Hitbox Tab
local HitboxBox = Tabs.Hitbox:AddLeftGroupbox("Hitbox Settings")

local hitboxSettings = {
    Wolf = false,
    Bunny = false,
    Cultist = false,
    Show = false,
    Size = 10
}

local function updateHitboxes()
    for _, model in ipairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") then
            local root = model:FindFirstChild("HumanoidRootPart")
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
    end
end

HitboxBox:AddToggle("WolfHB", {
    Title = "Expand Wolf Hitbox",
    Description = "Increases wolf hitbox size",
    Default = false,
    Callback = function(State)
        hitboxSettings.Wolf = State
        updateHitboxes()
    end
})

HitboxBox:AddToggle("BunnyHB", {
    Title = "Expand Bunny Hitbox",
    Description = "Increases bunny hitbox size",
    Default = false,
    Callback = function(State)
        hitboxSettings.Bunny = State
        updateHitboxes()
    end
})

HitboxBox:AddToggle("CultistHB", {
    Title = "Expand Cultist Hitbox",
    Description = "Increases cultist hitbox size",
    Default = false,
    Callback = function(State)
        hitboxSettings.Cultist = State
        updateHitboxes()
    end
})

HitboxBox:AddSlider("HitboxSize", {
    Title = "Hitbox Size",
    Description = "Adjusts the size of expanded hitboxes",
    Min = 2,
    Max = 30,
    Default = 10,
    Rounding = 1,
    Callback = function(Value)
        hitboxSettings.Size = Value
        updateHitboxes()
    end
})

HitboxBox:AddToggle("ShowHB", {
    Title = "Show Hitbox",
    Description = "Makes hitboxes visible",
    Default = false,
    Callback = function(State)
        hitboxSettings.Show = State
        updateHitboxes()
    end
})

-- Misc Tab
local MiscBox = Tabs.Misc:AddLeftGroupbox("Miscellaneous")

MiscBox:AddToggle("SpeedHack", {
    Title = "Speed Hack",
    Description = "Increases your movement speed",
    Default = false,
    Callback = function(State)
        local char = game.Players.LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum.WalkSpeed = State and Fluent.Flags.SpeedValue or 16
            end
        end
    end
})

MiscBox:AddSlider("SpeedValue", {
    Title = "Speed Value",
    Description = "Adjust your movement speed",
    Min = 16,
    Max = 600,
    Default = 28,
    Rounding = 1,
    Callback = function(Value)
        if Fluent.Flags.SpeedHack then
            local char = game.Players.LocalPlayer.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then hum.WalkSpeed = Value end
            end
        end
    end
})

local fpsText, msText
local showFPS, showPing = true, true

MiscBox:AddToggle("ShowFPS", {
    Title = "Show FPS",
    Description = "Displays current FPS counter",
    Default = true,
    Callback = function(State)
        showFPS = State
        if fpsText then fpsText.Visible = State end
    end
})

MiscBox:AddToggle("ShowPing", {
    Title = "Show Ping",
    Description = "Displays current network ping",
    Default = true,
    Callback = function(State)
        showPing = State
        if msText then msText.Visible = State end
    end
})

MiscBox:AddButton("FPSBoost", {
    Title = "FPS Boost",
    Description = "Optimizes game for better performance",
    Callback = function()
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            local lighting = game:GetService("Lighting")
            lighting.Brightness = 0
            lighting.FogEnd = 100
            lighting.GlobalShadows = false
            lighting.EnvironmentDiffuseScale = 0
            lighting.EnvironmentSpecularScale = 0
            lighting.ClockTime = 14
            lighting.OutdoorAmbient = Color3.new(0, 0, 0)
            
            local terrain = workspace:FindFirstChildOfClass("Terrain")
            if terrain then
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
                terrain.WaterTransparency = 1
            end
            
            for _, obj in ipairs(lighting:GetDescendants()) do
                if obj:IsA("PostEffect") then obj.Enabled = false end
            end
            
            for _, obj in ipairs(game:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                    obj.Enabled = false
                elseif obj:IsA("Texture") or obj:IsA("Decal") then
                    obj.Transparency = 1
                end
            end
            
            for _, part in ipairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") then part.CastShadow = false end
            end
        end)
        Window:Dialog({
            Title = "Success",
            Content = "FPS Boost applied successfully",
            Buttons = {
                {
                    Title = "OK",
                    Callback = function() end
                }
            }
        })
    end
})

-- Initialize FPS/Ping display
coroutine.wrap(function()
    fpsText = Drawing.new("Text")
    msText = Drawing.new("Text")
    
    fpsText.Size = 16
    fpsText.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X - 100, 10)
    fpsText.Color = Color3.fromRGB(0, 255, 0)
    fpsText.Outline = true
    fpsText.Visible = showFPS
    
    msText.Size = 16
    msText.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X - 100, 30)
    msText.Color = Color3.fromRGB(0, 255, 0)
    msText.Outline = true
    msText.Visible = showPing
    
    local fpsCounter, fpsLastUpdate = 0, tick()
    
    game:GetService("RunService").RenderStepped:Connect(function()
        fpsCounter += 1
        if tick() - fpsLastUpdate >= 1 then
            if showFPS then
                fpsText.Text = "FPS: " .. tostring(fpsCounter)
                fpsText.Visible = true
            else
                fpsText.Visible = false
            end
            
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
end)()

-- Initialize hitbox updater
coroutine.wrap(function()
    while true do
        updateHitboxes()
        task.wait(2)
    end
end)()

-- Save/Load configuration
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("DYHUB99Nights")
SaveManager:SetFolder("DYHUB99Nights/config")

Window:SelectTab(1)

Fluent:Notify({
    Title = "DYHUB",
    Content = "Script loaded successfully!",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
