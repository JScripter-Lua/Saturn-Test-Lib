--!nonstrict

--[[
    @author Jorsan
    @rework JScripter
]]

-- Libraries
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Maid = loadstring(game:HttpGet('https://raw.githubusercontent.com/Quenty/NevermoreEngine/refs/heads/main/src/maid/src/Shared/Maid.lua'))()
local Signal = loadstring(game:HttpGet('https://raw.githubusercontent.com/stravant/goodsignal/refs/heads/master/src/init.lua'))()
local ESP = loadstring(game:HttpGet('https://kiriot22.com/releases/ESP.lua'))()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Global State
if not shared._InkGameScriptState then
    shared._InkGameScriptState = {
        IsScriptExecuted = false,
        IsScriptReady = false,
        ScriptReady = Signal.new(),
        Cleanup = function() end
    }
end

local GlobalScriptState = shared._InkGameScriptState

-- Handle re-execution
if GlobalScriptState.IsScriptExecuted then
    if not GlobalScriptState.IsScriptReady then
        GlobalScriptState.ScriptReady:Wait()
        if GlobalScriptState.IsScriptReady then return end
    end
    GlobalScriptState.Cleanup()
end

GlobalScriptState.IsScriptExecuted = true

-- Main
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Initialize Rayfield
local Window = Rayfield:CreateWindow({
    Name = "Saturn Hub",
    Icon = "108632720139222",
    LoadingTitle = "Ink Game script",
    LoadingSubtitle = "Loading done in 5 sec...",
    ConfigurationSaving = {
        Enabled = false
    }
})

-- Features
local Features = {
    RedLightGreenLight = {
        Active = false,
        Toggle = nil,
        LastCFrame = nil,
        IsGreenLight = nil
    },
    
    Dalgona = {
        Active = false,
        Toggle = nil
    },
    
    TugOfWar = {
        Active = false,
        Toggle = nil
    },
    
    GlassBridge = {
        Active = false,
        Toggle = nil
    },
    
    Mingle = {
        Active = false,
        Toggle = nil
    },
    
    HideAndSeek = {
        Active = false,
        HiderToggle = nil,
        HunterToggle = nil
    },
    
    Player = {
        WalkSpeed = {
            Active = false,
            Toggle = nil,
            Slider = nil
        },
        Noclip = {
            Active = false,
            Toggle = nil
        }
    }
}

-- Create tabs
local MainTab = Window:CreateTab("Main")
local PlayerTab = Window:CreateTab("Player")
local SettingsTab = Window:CreateTab("Settings")

-- Create sections
local RoundCheatsSection = MainTab:CreateSection("Round Cheats")
local VisualsSection = MainTab:CreateSection("Visuals")
local PlayerModsSection = PlayerTab:CreateSection("Player Modifications")
local MenuSettingsSection = SettingsTab:CreateSection("Menu Settings")

-- Round Cheats
Features.RedLightGreenLight.Toggle = RoundCheatsSection:CreateToggle({
    Name = "Red Light God Mode",
    CurrentValue = false,
    Callback = function(Value)
        Features.RedLightGreenLight.Active = Value
    end
})

Features.TugOfWar.Toggle = RoundCheatsSection:CreateToggle({
    Name = "Tug of War Auto Pull",
    CurrentValue = false,
    Callback = function(Value)
        Features.TugOfWar.Active = Value
    end
})

Features.Dalgona.Toggle = RoundCheatsSection:CreateToggle({
    Name = "Dalgona Auto Complete",
    CurrentValue = false,
    Callback = function(Value)
        Features.Dalgona.Active = Value
        if Value then CompleteDalgona() end
    end
})

Features.Mingle.Toggle = RoundCheatsSection:CreateToggle({
    Name = "Mingle Auto Minigame Solver",
    CurrentValue = false,
    Callback = function(Value)
        Features.Mingle.Active = Value
    end
})

-- Visuals
Features.HideAndSeek.HiderToggle = VisualsSection:CreateToggle({
    Name = "Hider ESP",
    CurrentValue = false,
    Callback = function(Value)
        ESP.Hiders = Value
    end
})

Features.HideAndSeek.HunterToggle = VisualsSection:CreateToggle({
    Name = "Hunter ESP",
    CurrentValue = false,
    Callback = function(Value)
        ESP.Hunters = Value
    end
})

Features.GlassBridge.Toggle = VisualsSection:CreateToggle({
    Name = "Glass Bridge ESP",
    CurrentValue = false,
    Callback = function(Value)
        Features.GlassBridge.Active = Value
        UpdateGlassBridgeESP(Value)
    end
})

-- Player Mods
Features.Player.WalkSpeed.Toggle = PlayerModsSection:CreateToggle({
    Name = "Enable WalkSpeed",
    CurrentValue = false,
    Callback = function(Value)
        Features.Player.WalkSpeed.Active = Value
        UpdateWalkSpeed()
    end
})

Features.Player.WalkSpeed.Slider = PlayerModsSection:CreateSlider({
    Name = "Walk Speed",
    Range = {1, 100},
    Increment = 1,
    Suffix = "studs/s",
    CurrentValue = 16,
    Callback = function(Value)
        if Features.Player.WalkSpeed.Active then
            UpdateWalkSpeed()
        end
    end
})

Features.Player.Noclip.Toggle = PlayerModsSection:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(Value)
        Features.Player.Noclip.Active = Value
    end
})

-- Settings
SettingsTab:CreateButton({
    Name = "Unload Script",
    Callback = function()
        Rayfield:Destroy()
        GlobalScriptState.Cleanup()
    end
})

-- Initialize ESP
ESP.Players = true
ESP:Toggle(false)

-- Feature Functions
local function CompleteDalgona()
    if not Features.Dalgona.Active then return end
    
    local DalgonaClientModule = game.ReplicatedStorage.Modules.Games.DalgonaClient
    for _, Value in ipairs(getreg()) do
        if typeof(Value) == "function" and islclosure(Value) then
            if getfenv(Value).script == DalgonaClientModule then
                if getinfo(Value).nups == 73 then
                    setupvalue(Value, 31, 9e9)
                    break
                end
            end
        end
    end
end

local function UpdateGlassBridgeESP(Enabled)
    local GlassHolder = workspace.GlassBridge.GlassHolder
    for _, PanelPair in ipairs(GlassHolder:GetChildren()) do
        for _, Panel in ipairs(PanelPair:GetChildren()) do
            local GlassPart = Panel:FindFirstChild("glasspart")
            if GlassPart then
                if Enabled then
                    local Color = GlassPart:GetAttribute("exploitingisevil") and Color3.fromRGB(248, 87, 87) or Color3.fromRGB(28, 235, 87)
                    GlassPart.Color = Color
                    GlassPart.Transparency = 0
                    GlassPart.Material = Enum.Material.Neon
                else
                    GlassPart.Color = Color3.fromRGB(106, 106, 106)
                    GlassPart.Transparency = 0.45
                    GlassPart.Material = Enum.Material.SmoothPlastic
                end
            end
        end
    end
end

local function UpdateWalkSpeed()
    local Character = Players.LocalPlayer.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return end
    
    Humanoid.WalkSpeed = Features.Player.WalkSpeed.Slider.CurrentValue
end

-- Game Detection
local GameState = workspace.Values
local CurrentGame = nil
local FeatureConnections = Maid.new()

local function SetupRedLightGreenLight()
    local Client = Players.LocalPlayer
    local TrafficLightImage = Client.PlayerGui:WaitForChild("ImpactFrames"):WaitForChild("TrafficLightEmpty")
    
    Features.RedLightGreenLight.IsGreenLight = TrafficLightImage.Image == ReplicatedStorage.Effects.Images.TrafficLights.GreenLight.Image
    Features.RedLightGreenLight.LastCFrame = Client.Character and Client.Character:FindFirstChild("HumanoidRootPart") and Client.Character.HumanoidRootPart.CFrame
    
    FeatureConnections:GiveTask(ReplicatedStorage.Remotes.Effects.OnClientEvent:Connect(function(EffectsData)
        if EffectsData.EffectName ~= "TrafficLight" then return end
        Features.RedLightGreenLight.IsGreenLight = EffectsData.GreenLight == true
        Features.RedLightGreenLight.LastCFrame = Client.Character and Client.Character:FindFirstChild("HumanoidRootPart") and Client.Character.HumanoidRootPart.CFrame
    end))
    
    local OriginalNamecall
    OriginalNamecall = hookfunction(getrawmetatable(game).__namecall, newcclosure(function(Instance, ...)
        local Args = {...}
        if getnamecallmethod() == "FireServer" and Instance.ClassName == "RemoteEvent" and Instance.Name == "rootCFrame" then
            if Features.RedLightGreenLight.Active and not Features.RedLightGreenLight.IsGreenLight and Features.RedLightGreenLight.LastCFrame then
                Args[1] = Features.RedLightGreenLight.LastCFrame
                return OriginalNamecall(Instance, unpack(Args))
            end
        end
        return OriginalNamecall(Instance, ...)
    end))
    
    FeatureConnections:GiveTask(function()
        hookfunction(getrawmetatable(game).__namecall, OriginalNamecall)
    end)
end

local function SetupTugOfWar()
    local TemporaryReachedBindableRemote = ReplicatedStorage.Remotes.TemporaryReachedBindable
    local PULL_RATE = 0.025
    local VALID_PULL_DATA = { ["PerfectQTE"] = true }
    
    FeatureConnections:GiveTask(task.spawn(function()
        while task.wait(PULL_RATE) do
            if Features.TugOfWar.Active then
                TemporaryReachedBindableRemote:FireServer(VALID_PULL_DATA)
            end
        end
    end))
end

local function SetupMingle()
    local Client = Players.LocalPlayer
    
    local function OnCharacterAdded(Character)
        local RemoteForQTE = Character:WaitForChild("RemoteForQTE")
        FeatureConnections:GiveTask(task.spawn(function()
            while task.wait(0.5) do
                if not RemoteForQTE or not RemoteForQTE.Parent then break end
                if Features.Mingle.Active then
                    RemoteForQTE:FireServer()
                end
            end
        end))
    end
    
    FeatureConnections:GiveTask(Client.CharacterAdded:Connect(OnCharacterAdded))
    if Client.Character then
        task.spawn(OnCharacterAdded, Client.Character)
    end
end

local function SetupHideAndSeek()
    local ROLES_DATA = {
        IsHider = {Name = "Hider", Color = Color3.fromRGB(0, 255, 230), Flag = "Hiders"},
        IsHunter = {Name = "Hunter", Color = Color3.fromRGB(251, 0, 0), Flag = "Hunters"}
    }
    
    local Client = Players.LocalPlayer
    
    local function OnPlayerAdded(Player)
        if Player == Client then return end
        
        local function OnCharacterAdded(Character)
            local RootPart = Character:WaitForChild("HumanoidRootPart")
            
            local function OnRoleAdded(Role)
                local RoleData = ROLES_DATA[Role]
                ESP:Add(Character, {
                    Name = "Role: " .. RoleData.Name .. " | " .. "Player Name: " .. Player.Name,
                    Color = RoleData.Color,
                    PrimaryPart = RootPart,
                    IsEnabled = RoleData.Flag,
                })
            end
            
            for _, Attribute in ipairs({"IsHider", "IsHunter"}) do
                FeatureConnections:GiveTask(Player:GetAttributeChangedSignal(Attribute):Connect(function()
                    if Player:GetAttribute(Attribute) == true then
                        OnRoleAdded(Attribute)
                    end
                }))
                
                if Player:GetAttribute(Attribute) == true then
                    task.spawn(OnRoleAdded, Attribute)
                end
            end
        end
        
        FeatureConnections:GiveTask(Player.CharacterAdded:Connect(OnCharacterAdded))
        if Player.Character then
            task.spawn(OnCharacterAdded, Player.Character)
        end
    end
    
    FeatureConnections:GiveTask(Players.PlayerAdded:Connect(OnPlayerAdded))
    for _, Player in ipairs(Players:GetPlayers()) do
        task.spawn(OnPlayerAdded, Player)
    end
    
    ESP:Toggle(true)
end

local function CleanupFeatures()
    FeatureConnections:DoCleaning()
    ESP:Toggle(false)
end

local function OnGameChanged()
    CleanupFeatures()
    
    CurrentGame = GameState.CurrentGame.Value
    
    if CurrentGame == "RedLightGreenLight" then
        SetupRedLightGreenLight()
    elseif CurrentGame == "TugOfWar" then
        SetupTugOfWar()
    elseif CurrentGame == "Dalgona" then
        CompleteDalgona()
    elseif CurrentGame == "Mingle" then
        SetupMingle()
    elseif CurrentGame == "HideAndSeek" then
        SetupHideAndSeek()
    elseif CurrentGame == "GlassBridge" then
        UpdateGlassBridgeESP(Features.GlassBridge.Active)
    end
end

-- Noclip handler
local NoclipMaid = Maid.new()
local function HandleNoclip()
    NoclipMaid:DoCleaning()
    
    if not Features.Player.Noclip.Active then return end
    
    local Character = Players.LocalPlayer.Character
    if not Character then return end
    
    local Parts = {}
    for _, Descendant in ipairs(Character:GetDescendants()) do
        if Descendant:IsA("BasePart") then
            table.insert(Parts, Descendant)
        end
    end
    
    NoclipMaid:GiveTask(Character.DescendantAdded:Connect(function(Descendant)
        if Descendant:IsA("BasePart") then
            table.insert(Parts, Descendant)
        end
    end))
    
    NoclipMaid:GiveTask(RunService.Stepped:Connect(function()
        if not Features.Player.Noclip.Active then return end
        for _, Part in ipairs(Parts) do
            Part.CanCollide = false
        end
    end))
end

FeatureConnections:GiveTask(Players.LocalPlayer.CharacterAdded:Connect(HandleNoclip))
if Players.LocalPlayer.Character then
    task.spawn(HandleNoclip)
end

-- Initialize
FeatureConnections:GiveTask(GameState.CurrentGame:GetPropertyChangedSignal("Value"):Connect(OnGameChanged))
OnGameChanged()

-- Global cleanup
GlobalScriptState.Cleanup = function()
    CleanupFeatures()
    NoclipMaid:DoCleaning()
    Rayfield:Destroy()
    GlobalScriptState.IsScriptReady = false
    GlobalScriptState.IsScriptExecuted = false
end

-- Mark as ready
GlobalScriptState.IsScriptReady = true
GlobalScriptState.ScriptReady:Fire()

Rayfield:Notify({
    Title = "Saturn Hub",
    Content = "Script loaded successfully!",
    Duration = 6.5,
    Image = nil
})