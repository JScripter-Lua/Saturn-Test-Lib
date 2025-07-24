-- Saturn Hub - Doors Script Reworked for Rayfield Renewed from Outdate version of it :] 
-- Credit: JScripter

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- Variables
local ActiveStates = {
    EspDoor = false,
    SpeedBoost = false,
    EspHidingSpots = false,
    EspItems = false,
    EspCoins = false,
    MonsterSpawnAlert = false,
    NoCooldownPrompt = false,
    FullBright = false,
    ModifiedFieldOfView = false,
    EspChest = false,
    EspBooks = false,
    EspMonster = false,
    EspTimerLever = false,
    EspGen = false,
    AutoInteract = false,
    CanJump = false,
    InfOxygen = false,
    BigPrompt = false,
    DistanceEsp = false,
    NoEyes = false,
    NoScreech = false,
    NoDupe = false
}

local Settings = {
    LimitRangerEsp = 100,
    DisableLimitRangerEsp = false,
    ValueSpeed = 16,
    ValueFieldOfView = 80
}

local OptionNotif = {}

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "Saturn Hub (.gg/6UaRDjBY42)",
    LoadingTitle = "Saturn Hub Loading...",
    LoadingSubtitle = "Credit: JScripter",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SaturnHub",
        FileName = "DoorsConfig"
    }
})

-- Create Tabs
local InfoTab = Window:CreateTab("Info", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local GameTab = Window:CreateTab("Game", 4483362458)
local EspTab = Window:CreateTab("ESP", 4483362458)
local MonstersTab = Window:CreateTab("Monsters", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- Notification Function
local function NotifyMonsterSpawned(monsterName, duration)
    Rayfield:Notify({
        Title = "Monster Spawned!",
        Content = monsterName .. " has spawned!",
        Duration = duration or 3,
        Image = 4483362458
    })
end

-- ESP Creation Function
local function CreateEsp(char, color, text, parent)
    if not char or not parent then return end
    if char:FindFirstChild("ESP") and char:FindFirstChildOfClass("Highlight") then return end

    local highlight = char:FindFirstChildOfClass("Highlight") or Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = char
    highlight.FillColor = color
    highlight.FillTransparency = 1
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = false
    highlight.Parent = char

    local billboard = char:FindFirstChild("ESP") or Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Size = UDim2.new(0, 50, 0, 25)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, -2, 0)
    billboard.Adornee = parent
    billboard.Enabled = false
    billboard.Parent = parent

    local label = billboard:FindFirstChildOfClass("TextLabel") or Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextScaled = true
    label.Parent = billboard

    task.spawn(function()
        local Camera = Workspace.CurrentCamera
        while highlight and billboard and parent and parent.Parent do
            local cameraPosition = Camera and Camera.CFrame.Position
            if cameraPosition and parent and parent:IsA("BasePart") then
                local distance = (cameraPosition - parent.Position).Magnitude
                
                if ActiveStates.DistanceEsp then
                    label.Text = text .. " (" .. math.floor(distance + 0.5) .. " m)"
                else
                    label.Text = text
                end

                if not Settings.DisableLimitRangerEsp then
                    local withinRange = distance <= Settings.LimitRangerEsp
                    highlight.Enabled = withinRange
                    billboard.Enabled = withinRange
                else
                    billboard.Enabled = true
                    highlight.Enabled = true
                end
            end
            RunService.Heartbeat:Wait()
        end
    end)
end

local function RemoveEsp(char, parent)
    if char and char:FindFirstChildOfClass("Highlight") and parent:FindFirstChildOfClass("BillboardGui") then
        char:FindFirstChildOfClass("Highlight"):Destroy()
        parent:FindFirstChildOfClass("BillboardGui"):Destroy()
    end
end

local function OnPromptShown(prompt)
    if prompt and prompt.MaxActivationDistance > 0 then
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration or 0)
        prompt:InputHoldEnd()
    end
end

-- Info Tab
InfoTab:CreateParagraph({Title = "Saturn Hub", Content = "Welcome to Saturn Hub! This script provides various features for Doors including ESP, speed modifications, and monster alerts."})
InfoTab:CreateParagraph({Title = "Version", Content = "Current Version: V.1.0 - Reworked for Rayfield Renewed"})
InfoTab:CreateParagraph({Title = "Credit", Content = "Script by: JScripter | Reworked by: Community"})

-- Player Tab
local SpeedSlider = PlayerTab:CreateSlider({
    Name = "Player Speed",
    Range = {0, 21},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "PlayerSpeed",
    Callback = function(Value)
        Settings.ValueSpeed = Value
    end
})

PlayerTab:CreateToggle({
    Name = "Speed Boost",
    CurrentValue = false,
    Flag = "SpeedBoost",
    Callback = function(Value)
        ActiveStates.SpeedBoost = Value
        if Value then
            task.spawn(function()
                while ActiveStates.SpeedBoost do
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.ValueSpeed
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

local FOVSlider = PlayerTab:CreateSlider({
    Name = "Field of View",
    Range = {80, 120},
    Increment = 1,
    Suffix = "FOV",
    CurrentValue = 80,
    Flag = "FOV",
    Callback = function(Value)
        Settings.ValueFieldOfView = Value
    end
})

PlayerTab:CreateToggle({
    Name = "Modify FOV",
    CurrentValue = false,
    Flag = "ModifyFOV",
    Callback = function(Value)
        ActiveStates.ModifiedFieldOfView = Value
        if Value then
            task.spawn(function()
                while ActiveStates.ModifiedFieldOfView do
                    if Workspace.Camera then
                        Workspace.Camera.FieldOfView = Settings.ValueFieldOfView
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Can Jump",
    CurrentValue = false,
    Flag = "CanJump",
    Callback = function(Value)
        ActiveStates.CanJump = Value
        if Value then
            task.spawn(function()
                while ActiveStates.CanJump do
                    if LocalPlayer.Character then
                        LocalPlayer.Character:SetAttribute("CanJump", true)
                    end
                    task.wait(0.1)
                end
                if LocalPlayer.Character then
                    LocalPlayer.Character:SetAttribute("CanJump", false)
                end
            end)
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Infinite Oxygen",
    CurrentValue = false,
    Flag = "InfOxygen",
    Callback = function(Value)
        ActiveStates.InfOxygen = Value
        if Value then
            task.spawn(function()
                while ActiveStates.InfOxygen do
                    if LocalPlayer.Character then
                        LocalPlayer.Character:SetAttribute("Oxygen", 99999)
                    end
                    task.wait(0.1)
                end
                if LocalPlayer.Character then
                    LocalPlayer.Character:SetAttribute("Oxygen", 100)
                end
            end)
        end
    end
})

-- Game Tab
GameTab:CreateToggle({
    Name = "Full Bright",
    CurrentValue = false,
    Flag = "FullBright",
    Callback = function(Value)
        ActiveStates.FullBright = Value
        if Value then
            task.spawn(function()
                while ActiveStates.FullBright do
                    if Lighting then
                        Lighting.Brightness = 5
                        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
                    end
                    task.wait(0.01)
                end
            end)
        end
    end
})

GameTab:CreateToggle({
    Name = "Instant Prompt",
    CurrentValue = false,
    Flag = "InstantPrompt",
    Callback = function(Value)
        ActiveStates.NoCooldownPrompt = Value
        if Value then
            task.spawn(function()
                while ActiveStates.NoCooldownPrompt do
                    for _, prompt in pairs(Workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt.HoldDuration ~= 0 then
                            prompt:SetAttribute("HoldDurationOld", prompt.HoldDuration)
                            prompt.HoldDuration = 0
                        end
                    end
                    task.wait(0.1)
                end
                for _, prompt in pairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt:GetAttribute("HoldDurationOld") then
                        prompt.HoldDuration = prompt:GetAttribute("HoldDurationOld")
                    end
                end
            end)
        end
    end
})

GameTab:CreateToggle({
    Name = "Auto Interact",
    CurrentValue = false,
    Flag = "AutoInteract",
    Callback = function(Value)
        ActiveStates.AutoInteract = Value
        if Value then
            task.spawn(function()
                while ActiveStates.AutoInteract do
                    for _, prompt in pairs(Workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt.Name ~= "HidePrompt" then
                            task.spawn(function()
                                OnPromptShown(prompt)
                            end)
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

GameTab:CreateToggle({
    Name = "Big Prompt Distance",
    CurrentValue = false,
    Flag = "BigPrompt",
    Callback = function(Value)
        ActiveStates.BigPrompt = Value
        if Value then
            task.spawn(function()
                while ActiveStates.BigPrompt do
                    for _, prompt in pairs(Workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt.MaxActivationDistance ~= 13 then
                            prompt:SetAttribute("MaxActivationDistanceOld", prompt.MaxActivationDistance)
                            prompt.MaxActivationDistance = 13
                        end
                    end
                    task.wait(0.1)
                end
                for _, prompt in pairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt:GetAttribute("MaxActivationDistanceOld") then
                        prompt.MaxActivationDistance = prompt:GetAttribute("MaxActivationDistanceOld")
                    end
                end
            end)
        end
    end
})

-- ESP Tab
EspTab:CreateToggle({
    Name = "Door ESP",
    CurrentValue = false,
    Flag = "DoorESP",
    Callback = function(Value)
        ActiveStates.EspDoor = Value
        if Value then
            task.spawn(function()
                while ActiveStates.EspDoor do
                    if Workspace:FindFirstChild("CurrentRooms") then
                        for _, room in pairs(Workspace.CurrentRooms:GetChildren()) do
                            if room:IsA("Model") and room:FindFirstChild("Door") then
                                local door = room.Door
                                if not door:FindFirstChildOfClass("Highlight") and door.PrimaryPart then
                                    local signText = "Door"
                                    if door:FindFirstChild("Sign") then
                                        local sign = door.Sign
                                        if sign:FindFirstChild("Stinker") and sign.Stinker.Text ~= "" then
                                            signText = sign.Stinker.Text
                                        elseif sign:FindFirstChild("SignText") then
                                            signText = sign.SignText.Text
                                        end
                                    end
                                    
                                    local isLocked = room:FindFirstChild("Assets") and room.Assets:FindFirstChild("KeyObtain")
                                    local displayText = "Door " .. signText .. (isLocked and " (Locked)" or "")
                                    
                                    CreateEsp(door, Color3.fromRGB(0, 255, 0), displayText, door.PrimaryPart)
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
                -- Cleanup
                if Workspace:FindFirstChild("CurrentRooms") then
                    for _, room in pairs(Workspace.CurrentRooms:GetChildren()) do
                        if room:IsA("Model") and room:FindFirstChild("Door") then
                            RemoveEsp(room.Door, room.Door.PrimaryPart)
                        end
                    end
                end
            end)
        end
    end
})

EspTab:CreateToggle({
    Name = "Hiding Spots ESP",
    CurrentValue = false,
    Flag = "HidingSpotsESP",
    Callback = function(Value)
        ActiveStates.EspHidingSpots = Value
        if Value then
            task.spawn(function()
                while ActiveStates.EspHidingSpots do
                    if Workspace:FindFirstChild("CurrentRooms") then
                        for _, room in pairs(Workspace.CurrentRooms:GetChildren()) do
                            if room:IsA("Model") and room:FindFirstChild("Assets") then
                                for _, asset in pairs(room.Assets:GetChildren()) do
                                    local validHidingSpots = {"Bed", "Wardrobe", "Backdoor_Wardrobe", "Locker_Large", "Rooms_Locker"}
                                    if asset:IsA("Model") and table.find(validHidingSpots, asset.Name) then
                                        if not asset:FindFirstChildOfClass("Highlight") and asset.PrimaryPart then
                                            CreateEsp(asset, Color3.fromRGB(0, 255, 255), asset.Name, asset.PrimaryPart)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

EspTab:CreateToggle({
    Name = "Items ESP",
    CurrentValue = false,
    Flag = "ItemsESP",
    Callback = function(Value)
        ActiveStates.EspItems = Value
        if Value then
            task.spawn(function()
                while ActiveStates.EspItems do
                    local itemNames = {"KeyObtain", "LeverForGate", "Battery", "Flashlight", "Lighter", "Bandage", "Crucifix", "Vitamins", "Lockpick", "Candle", "AlarmClock", "LibraryHintPaper", "Smoothie", "FuseObtain", "BatteryPack", "Glowsticks", "StarVial", "Shakelight", "SkeletonKey"}
                    for _, item in pairs(Workspace:GetDescendants()) do
                        if item:IsA("Model") and table.find(itemNames, item.Name) then
                            if not item:FindFirstChildOfClass("Highlight") and item.PrimaryPart then
                                CreateEsp(item, Color3.fromRGB(255, 255, 0), item.Name, item.PrimaryPart)
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

EspTab:CreateToggle({
    Name = "Coins ESP",
    CurrentValue = false,
    Flag = "CoinsESP",
    Callback = function(Value)
        ActiveStates.EspCoins = Value
        if Value then
            task.spawn(function()
                while ActiveStates.EspCoins do
                    for _, item in pairs(Workspace:GetDescendants()) do
                        if item:IsA("Model") and item.Name == "GoldPile" then
                            if not item:FindFirstChildOfClass("Highlight") and item.PrimaryPart then
                                CreateEsp(item, Color3.fromRGB(255, 215, 0), "Gold", item.PrimaryPart)
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

EspTab:CreateToggle({
    Name = "Chest ESP",
    CurrentValue = false,
    Flag = "ChestESP",
    Callback = function(Value)
        ActiveStates.EspChest = Value
        if Value then
            task.spawn(function()
                while ActiveStates.EspChest do
                    for _, item in pairs(Workspace:GetDescendants()) do
                        if item:IsA("Model") and (item.Name == "ChestBoxLocked" or item.Name == "ChestBox") then
                            if not item:FindFirstChildOfClass("Highlight") and item.PrimaryPart then
                                CreateEsp(item, Color3.fromRGB(255, 255, 0), item.Name, item.PrimaryPart)
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

EspTab:CreateToggle({
    Name = "Books ESP",
    CurrentValue = false,
    Flag = "BooksESP",
    Callback = function(Value)
        ActiveStates.EspBooks = Value
        if Value then
            task.spawn(function()
                while ActiveStates.EspBooks do
                    for _, item in pairs(Workspace:GetDescendants()) do
                        if item:IsA("Model") and item.Name == "LiveHintBook" then
                            if not item:FindFirstChildOfClass("Highlight") and item.PrimaryPart then
                                CreateEsp(item, Color3.fromRGB(0, 150, 150), "Book", item.PrimaryPart)
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

EspTab:CreateToggle({
    Name = "Monsters ESP",
    CurrentValue = false,
    Flag = "MonstersESP",
    Callback = function(Value)
        ActiveStates.EspMonster = Value
        if Value then
            task.spawn(function()
                while ActiveStates.EspMonster do
                    local monsterNames = {"FigureRig", "SallyMoving", "RushMoving", "Eyes", "SeekMovingNewClone", "BackdoorLookman", "BackdoorRush", "GloombatSwarm", "GiggleCeiling", "AmbushMoving", "A60", "A120"}
                    for _, monster in pairs(Workspace:GetDescendants()) do
                        if monster:IsA("Model") and table.find(monsterNames, monster.Name) then
                            if not monster:FindFirstChildOfClass("Highlight") and monster.PrimaryPart then
                                monster.PrimaryPart.Transparency = 0
                                CreateEsp(monster, Color3.fromRGB(255, 0, 0), monster.Name, monster.PrimaryPart)
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

EspTab:CreateToggle({
    Name = "Timer Lever ESP",
    CurrentValue = false,
    Flag = "TimerLeverESP",
    Callback = function(Value)
        ActiveStates.EspTimerLever = Value
        if Value then
            task.spawn(function()
                while ActiveStates.EspTimerLever do
                    for _, item in pairs(Workspace:GetDescendants()) do
                        if item:IsA("Model") and item.Name == "TimerLever" then
                            if not item:FindFirstChildOfClass("Highlight") and item.PrimaryPart then
                                CreateEsp(item, Color3.fromRGB(0, 150, 150), "Timer Lever", item.PrimaryPart)
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

EspTab:CreateToggle({
    Name = "Generator ESP",
    CurrentValue = false,
    Flag = "GeneratorESP",
    Callback = function(Value)
        ActiveStates.EspGen = Value
        if Value then
            task.spawn(function()
                while ActiveStates.EspGen do
                    for _, item in pairs(Workspace:GetDescendants()) do
                        if item:IsA("Model") and item.Name == "MinesGenerator" then
                            if not item:FindFirstChildOfClass("Highlight") and item.PrimaryPart then
                                CreateEsp(item, Color3.fromRGB(255, 255, 0), "Generator", item.PrimaryPart)
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

-- Monsters Tab
local MonsterDropdown = MonstersTab:CreateDropdown({
    Name = "Monster Spawn Alerts",
    Options = {"Rush", "Seek", "Figure", "Sally", "Eyes", "LookMan", "BackdoorRush", "Giggle", "GloombatSwarm", "Ambush", "A-60", "A-120"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "MonsterAlerts",
    Callback = function(Options)
        OptionNotif = {}
        local monsterMap = {
            ["Rush"] = "RushMoving",
            ["Seek"] = "SeekMovingNewClone",
            ["Figure"] = "FigureRig",
            ["Sally"] = "SallyMoving",
            ["Eyes"] = "Eyes",
            ["LookMan"] = "BackdoorLookman",
            ["BackdoorRush"] = "BackdoorRush",
            ["Giggle"] = "GiggleCeiling",
            ["GloombatSwarm"] = "GloombatSwarm",
            ["Ambush"] = "AmbushMoving",
            ["A-60"] = "A60",
            ["A-120"] = "A120"
        }
        
        for _, option in pairs(Options) do
            if monsterMap[option] then
                table.insert(OptionNotif, monsterMap[option])
            end
        end
    end
})

MonstersTab:CreateToggle({
    Name = "Monster Spawn Alert",
    CurrentValue = false,
    Flag = "MonsterSpawnAlert",
    Callback = function(Value)
        ActiveStates.MonsterSpawnAlert = Value
    end
})

MonstersTab:CreateToggle({
    Name = "No Eyes",
    CurrentValue = false,
    Flag = "NoEyes",
    Callback = function(Value)
        ActiveStates.NoEyes = Value
        if Value then
            task.spawn(function()
                while ActiveStates.NoEyes do
                    if ReplicatedStorage:FindFirstChild("GameData") and ReplicatedStorage.GameData:FindFirstChild("EntityDisableEyes") then
                        ReplicatedStorage.GameData.EntityDisableEyes.Value = true
                    end
                    task.wait(0.1)
                end
                if ReplicatedStorage:FindFirstChild("GameData") and ReplicatedStorage.GameData:FindFirstChild("EntityDisableEyes") then
                    ReplicatedStorage.GameData.EntityDisableEyes.Value = false
                end
            end)
        end
    end
})

MonstersTab:CreateToggle({
    Name = "No Screech",
    CurrentValue = false,
    Flag = "NoScreech",
    Callback = function(Value)
        ActiveStates.NoScreech = Value
        if Value then
            task.spawn(function()
                while ActiveStates.NoScreech do
                    if ReplicatedStorage:FindFirstChild("GameData") and ReplicatedStorage.GameData:FindFirstChild("EntityDisableScreech") then
                        ReplicatedStorage.GameData.EntityDisableScreech.Value = true
                    end
                    task.wait(0.1)
                end
                if ReplicatedStorage:FindFirstChild("GameData") and ReplicatedStorage.GameData:FindFirstChild("EntityDisableScreech") then
                    ReplicatedStorage.GameData.EntityDisableScreech.Value = false
                end
            end)
        end
    end
})

MonstersTab:CreateToggle({
    Name = "No Dupe",
    CurrentValue = false,
    Flag = "NoDupe",
    Callback = function(Value)
        ActiveStates.NoDupe = Value
        if Value then
            task.spawn(function()
                while ActiveStates.NoDupe do
                    if ReplicatedStorage:FindFirstChild("GameData") and ReplicatedStorage.GameData:FindFirstChild("EntityDisableDupe") then
                        ReplicatedStorage.GameData.EntityDisableDupe.Value = true
                    end
                    task.wait(0.1)
                end
                if ReplicatedStorage:FindFirstChild("GameData") and ReplicatedStorage.GameData:FindFirstChild("EntityDisableDupe") then
                    ReplicatedStorage.GameData.EntityDisableDupe.Value = false
                end
            end)
        end
    end
})

-- Settings Tab
local RangeSlider = SettingsTab:CreateSlider({
    Name = "ESP Range Limit",
    Range = {25, 1000},
    Increment = 1,
    Suffix = "Range",
    CurrentValue = 100,
    Flag = "ESPRange",
    Callback = function(Value)
        Settings.LimitRangerEsp = Value
    end
})

SettingsTab:CreateToggle({
    Name = "Disable ESP Range Limit",
    CurrentValue = false,
    Flag = "DisableESPRange",
    Callback = function(Value)
        Settings.DisableLimitRangerEsp = Value
    end
})

SettingsTab:CreateToggle({
    Name = "Show Distance in ESP",
    CurrentValue = false,
    Flag = "ShowDistance",
    Callback = function(Value)
        ActiveStates.DistanceEsp = Value
    end
})

local ThemeDropdown = SettingsTab:CreateDropdown({
    Name = "Theme",
    Options = {"Default", "AmberGlow", "Amethyst", "Bloom", "DarkBlue", "Green", "Light", "Ocean", "Serenity"},
    CurrentOption = {"Default"},
    Flag = "Theme",
    Callback = function(Option)
        Window:SetTheme(Option[1])
    end
})

-- Monster Spawn Detection
Workspace.ChildAdded:Connect(function(child)
    if ActiveStates.MonsterSpawnAlert and table.find(OptionNotif, child.Name) then
        local monsterNames = {
            ["RushMoving"] = "Rush",
            ["SeekMovingNewClone"] = "Seek",
            ["FigureRig"] = "Figure",
            ["SallyMoving"] = "Sally",
            ["Eyes"] = "Eyes",
            ["BackdoorLookman"] = "LookMan",
            ["BackdoorRush"] = "Blitz",
            ["GloombatSwarm"] = "Gloombat Swarm",
            ["GiggleCeiling"] = "Giggle",
            ["AmbushMoving"] = "Ambush",
            ["A60"] = "A-60",
            ["A120"] = "A-120"
        }
        
        local displayName = monsterNames[child.Name] or child.Name
        NotifyMonsterSpawned(displayName, 3)
    end
end)

-- Initial notification
Rayfield:Notify({
    Title = "Saturn Hub",
    Content = "Successfully loaded! Version 1.0",
    Duration = 3,
    Image = 4483362458
})