local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Main Window
local Window = Rayfield:CreateWindow({
    Name = "Saturn Hub | Doors",
    LoadingTitle = "Loading Saturn Hub...",
    LoadingSubtitle = "By JScripter",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SaturnHubDoors",
        FileName = "Config"
    }
})

-- Variables
local Active = {
    Esp = {
        Door = false, HidingSpots = false, Items = false, Coins = false,
        Chest = false, Books = false, Monster = false, TimerLever = false, Generator = false
    },
    Features = {
        Speed = false, MonsterAlert = false, NoCooldown = false, FullBright = false,
        FOV = false, AutoInteract = false, BigPrompt = false, CanJump = false,
        InfOxygen = false, NoEyes = false, NoScreech = false, NoDupe = false
    },
    Settings = {
        Speed = 16, FOV = 80, LimitRange = 100, DisableRangeLimit = false,
        ShowDistance = false, SelectedTheme = "Default"
    },
    Monsters = {}
}

-- Functions
local function CreateESP(target, color, text)
    if not target or not target.PrimaryPart then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = target
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.Parent = target

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Adornee = target.PrimaryPart
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.Parent = target.PrimaryPart

    local label = Instance.new("TextLabel")
    label.Text = text
    label.TextColor3 = color
    label.TextScaled = true
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Parent = billboard

    return {Highlight = highlight, Billboard = billboard}
end

local function RemoveESP(target)
    if target:FindFirstChild("ESP_Highlight") then
        target.ESP_Highlight:Destroy()
    end
    if target.PrimaryPart and target.PrimaryPart:FindFirstChild("ESP") then
        target.PrimaryPart.ESP:Destroy()
    end
end

local function NotifyMonster(name)
    Rayfield:Notify({
        Title = "Monster Alert",
        Content = name.." has spawned!",
        Duration = 3,
        Image = 6023426925
    })
end

-- Main Tab
local MainTab = Window:CreateTab("Main", 4483362458)
MainTab:CreateToggle({
    Name = "Monster Spawn Alert",
    CurrentValue = false,
    Callback = function(state)
        Active.Features.MonsterAlert = state
    end
})

MainTab:CreateDropdown({
    Name = "Select Monsters",
    Options = {"Rush","Seek","Figure","Sally","Eyes","LookMan","BackdoorRush","Giggle","GloombatSwarm","Ambush","A-60","A-120"},
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(options)
        Active.Monsters = options
    end
})

MainTab:CreateToggle({
    Name = "Instant Prompt",
    CurrentValue = false,
    Callback = function(state)
        Active.Features.NoCooldown = state
    end
})

MainTab:CreateToggle({
    Name = "Auto Interact",
    CurrentValue = false,
    Callback = function(state)
        Active.Features.AutoInteract = state
    end
})

MainTab:CreateToggle({
    Name = "Big Distance Prompt",
    CurrentValue = false,
    Callback = function(state)
        Active.Features.BigPrompt = state
    end
})

-- Player Tab
local PlayerTab = Window:CreateTab("Player", 4483362458)
PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {0, 21},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = Active.Settings.Speed,
    Callback = function(value)
        Active.Settings.Speed = value
        if Active.Features.Speed then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Enable Speed",
    CurrentValue = false,
    Callback = function(state)
        Active.Features.Speed = state
        if state then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Active.Settings.Speed
        else
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
})

PlayerTab:CreateSlider({
    Name = "Field of View",
    Range = {70, 120},
    Increment = 1,
    Suffix = "FOV",
    CurrentValue = Active.Settings.FOV,
    Callback = function(value)
        Active.Settings.FOV = value
        if Active.Features.FOV then
            game.Workspace.Camera.FieldOfView = value
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Enable FOV",
    CurrentValue = false,
    Callback = function(state)
        Active.Features.FOV = state
        if state then
            game.Workspace.Camera.FieldOfView = Active.Settings.FOV
        else
            game.Workspace.Camera.FieldOfView = 70
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Can Jump",
    CurrentValue = false,
    Callback = function(state)
        Active.Features.CanJump = state
    end
})

PlayerTab:CreateToggle({
    Name = "Infinite Oxygen",
    CurrentValue = false,
    Callback = function(state)
        Active.Features.InfOxygen = state
    end
})

-- ESP Tab
local ESPTab = Window:CreateTab("ESP", 4483362458)
ESPTab:CreateToggle({
    Name = "Door ESP",
    CurrentValue = false,
    Callback = function(state)
        Active.Esp.Door = state
    end
})

ESPTab:CreateToggle({
    Name = "Hiding Spots ESP",
    CurrentValue = false,
    Callback = function(state)
        Active.Esp.HidingSpots = state
    end
})

ESPTab:CreateToggle({
    Name = "Items ESP",
    CurrentValue = false,
    Callback = function(state)
        Active.Esp.Items = state
    end
})

ESPTab:CreateToggle({
    Name = "Coins ESP",
    CurrentValue = false,
    Callback = function(state)
        Active.Esp.Coins = state
    end
})

ESPTab:CreateToggle({
    Name = "Chest ESP",
    CurrentValue = false,
    Callback = function(state)
        Active.Esp.Chest = state
    end
})

ESPTab:CreateToggle({
    Name = "Books ESP",
    CurrentValue = false,
    Callback = function(state)
        Active.Esp.Books = state
    end
})

ESPTab:CreateToggle({
    Name = "Monster ESP",
    CurrentValue = false,
    Callback = function(state)
        Active.Esp.Monster = state
    end
})

ESPTab:CreateToggle({
    Name = "Timer Lever ESP",
    CurrentValue = false,
    Callback = function(state)
        Active.Esp.TimerLever = state
    end
})

ESPTab:CreateToggle({
    Name = "Generator ESP",
    CurrentValue = false,
    Callback = function(state)
        Active.Esp.Generator = state
    end
})

-- Monster Tab
local MonsterTab = Window:CreateTab("Monsters", 4483362458)
MonsterTab:CreateToggle({
    Name = "Disable Eyes",
    CurrentValue = false,
    Callback = function(state)
        Active.Features.NoEyes = state
    end
})

MonsterTab:CreateToggle({
    Name = "Disable Screech",
    CurrentValue = false,
    Callback = function(state)
        Active.Features.NoScreech = state
    end
})

MonsterTab:CreateToggle({
    Name = "Disable Dupe",
    CurrentValue = false,
    Callback = function(state)
        Active.Features.NoDupe = state
    end
})

-- Settings Tab
local SettingsTab = Window:CreateTab("Settings", 4483362458)
SettingsTab:CreateSlider({
    Name = "ESP Range Limit",
    Range = {25, 1000},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = Active.Settings.LimitRange,
    Callback = function(value)
        Active.Settings.LimitRange = value
    end
})

SettingsTab:CreateToggle({
    Name = "Disable Range Limit",
    CurrentValue = false,
    Callback = function(state)
        Active.Settings.DisableRangeLimit = state
    end
})

SettingsTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = false,
    Callback = function(state)
        Active.Settings.ShowDistance = state
    end
})

SettingsTab:CreateDropdown({
    Name = "UI Theme",
    Options = {"Default", "Dark", "Light", "Amethyst", "Aqua"},
    CurrentOption = Active.Settings.SelectedTheme,
    Callback = function(option)
        Active.Settings.SelectedTheme = option
        Window:ChangeTheme(option)
    end
})

SettingsTab:CreateButton({
    Name = "Unload Script",
    Callback = function()
        Rayfield:Destroy()
    end
})

-- Main Loops
game:GetService("RunService").Heartbeat:Connect(function()
    -- Speed Control
    if Active.Features.Speed and game.Players.LocalPlayer.Character then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Active.Settings.Speed
    end
    
    -- FOV Control
    if Active.Features.FOV then
        game.Workspace.Camera.FieldOfView = Active.Settings.FOV
    end
    
    -- Full Bright
    if Active.Features.FullBright then
        game.Lighting.Brightness = 2
        game.Lighting.Ambient = Color3.new(1, 1, 1)
    end
    
    -- Monster Disables
    if Active.Features.NoEyes then
        game:GetService("ReplicatedStorage").GameData.EntityDisableEyes.Value = true
    end
    if Active.Features.NoScreech then
        game:GetService("ReplicatedStorage").GameData.EntityDisableScreech.Value = true
    end
    if Active.Features.NoDupe then
        game:GetService("ReplicatedStorage").GameData.EntityDisableDupe.Value = true
    end
    
    -- Jump/Oxygen
    if Active.Features.CanJump and game.Players.LocalPlayer.Character then
        game.Players.LocalPlayer.Character:SetAttribute("CanJump", true)
    end
    if Active.Features.InfOxygen and game.Players.LocalPlayer.Character then
        game.Players.LocalPlayer.Character:SetAttribute("Oxygen", 100)
    end
end)

-- ESP Management
game:GetService("Workspace").DescendantAdded:Connect(function(descendant)
    -- Monster Alerts
    if Active.Features.MonsterAlert and table.find(Active.Monsters, descendant.Name) then
        NotifyMonster(descendant.Name)
    end
    
    -- Auto Interact
    if Active.Features.AutoInteract and descendant:IsA("ProximityPrompt") then
        fireproximityprompt(descendant)
    end
end)

-- Prompt Modifications
game:GetService("Workspace").DescendantAdded:Connect(function(descendant)
    if descendant:IsA("ProximityPrompt") then
        if Active.Features.NoCooldown then
            descendant.HoldDuration = 0
        end
        if Active.Features.BigPrompt then
            descendant.MaxActivationDistance = 25
        end
    end
end)

Rayfield:Notify({
    Title = "Saturn Hub Loaded",
    Content = "Doors script activated!",
    Duration = 5,
    Image = 6023426925
})