local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Initialize shared environment
if not getgenv().shared then
    getgenv().shared = {}
end

if not getgenv().DYHUB_loaded then
    getgenv().DYHUB_loaded = true
else
    local suc = pcall(function()
        shared.DYHUB_InkGame_Library:Unload()
    end)
    if not suc then
        return 
    end
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- Player references
local lplr = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Script state
local Script = {
    ESPTable = {
        Player = {},
        Seeker = {},
        Hider = {},
        Guard = {},
        Door = {},
        None = {},
        Key = {},
    },
    Temp = {},
    Connections = {},
    Functions = {},
    GameState = "unknown"
}

-- Utility functions
function Script.Functions.Alert(message, duration)
    Rayfield:Notify({
        Title = "DYHUB",
        Content = message,
        Duration = duration or 5,
        Actions = {
            Ignore = {
                Name = "Okay",
                Callback = function() end
            },
        },
    })
end

function Script.Functions.Warn(message)
    warn("WARN - DYHUB:", message)
end

-- ESP Functions
function Script.Functions.ESP(args)
    if not args.Object then return Script.Functions.Warn("ESP Object is nil") end

    local ESPManager = {
        Object = args.Object,
        Text = args.Text or "No Text",
        TextParent = args.TextParent,
        Color = args.Color or Color3.new(),
        Offset = args.Offset or Vector3.zero,
        IsEntity = args.IsEntity or false,
        Type = args.Type or "None",
        Highlights = {},
        Humanoid = nil,
        RSConnection = nil,
        Connections = {}
    }

    local tableIndex = #Script.ESPTable[ESPManager.Type] + 1

    if ESPManager.IsEntity and ESPManager.Object.PrimaryPart.Transparency == 1 then
        ESPManager.Object:SetAttribute("Transparency", ESPManager.Object.PrimaryPart.Transparency)
        ESPManager.Humanoid = Instance.new("Humanoid", ESPManager.Object)
        ESPManager.Object.PrimaryPart.Transparency = 0.99
    end

    local highlight = Instance.new("Highlight") do
        highlight.Adornee = ESPManager.Object
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = ESPManager.Color
        highlight.FillTransparency = Script.Temp.ESPFillTransparency or 0.75
        highlight.OutlineColor = ESPManager.Color
        highlight.OutlineTransparency = Script.Temp.ESPOutlineTransparency or 0
        highlight.Enabled = Script.Temp.ESPHighlight == nil and true or Script.Temp.ESPHighlight
        highlight.Parent = ESPManager.Object
    end

    table.insert(ESPManager.Highlights, highlight)
    
    local billboardGui = Instance.new("BillboardGui") do
        billboardGui.Adornee = ESPManager.TextParent or ESPManager.Object
        billboardGui.AlwaysOnTop = true
        billboardGui.ClipsDescendants = false
        billboardGui.Size = UDim2.new(0, 1, 0, 1)
        billboardGui.StudsOffset = ESPManager.Offset
        billboardGui.Parent = ESPManager.TextParent or ESPManager.Object
    end

    local textLabel = Instance.new("TextLabel") do
        textLabel.BackgroundTransparency = 1
        textLabel.Font = Enum.Font.Oswald
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.Text = ESPManager.Text
        textLabel.TextColor3 = ESPManager.Color
        textLabel.TextSize = Script.Temp.ESPTextSize or 22
        textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        textLabel.TextStrokeTransparency = 0.75
        textLabel.Parent = billboardGui
    end

    function ESPManager.SetColor(newColor)
        ESPManager.Color = newColor
        for _, highlight in pairs(ESPManager.Highlights) do
            highlight.FillColor = newColor
            highlight.OutlineColor = newColor
        end
        textLabel.TextColor3 = newColor
    end

    function ESPManager.Destroy()
        if ESPManager.RSConnection then
            ESPManager.RSConnection:Disconnect()
        end

        if ESPManager.IsEntity and ESPManager.Object then
            if ESPManager.Object.PrimaryPart then
                ESPManager.Object.PrimaryPart.Transparency = ESPManager.Object.PrimaryPart:GetAttribute("Transparency")
            end
            if ESPManager.Humanoid then
                ESPManager.Humanoid:Destroy()
            end
        end

        for _, highlight in pairs(ESPManager.Highlights) do
            highlight:Destroy()
        end
        if billboardGui then billboardGui:Destroy() end

        if Script.ESPTable[ESPManager.Type][tableIndex] then
            Script.ESPTable[ESPManager.Type][tableIndex] = nil
        end

        for _, conn in pairs(ESPManager.Connections) do
            pcall(function() conn:Disconnect() end)
        end
    end

    ESPManager.RSConnection = RunService.RenderStepped:Connect(function()
        if not ESPManager.Object or not ESPManager.Object:IsDescendantOf(workspace) then
            ESPManager.Destroy()
            return
        end

        for _, highlight in pairs(ESPManager.Highlights) do
            highlight.Enabled = Script.Temp.ESPHighlight == nil and true or Script.Temp.ESPHighlight
            highlight.FillTransparency = Script.Temp.ESPFillTransparency or 0.75
            highlight.OutlineTransparency = Script.Temp.ESPOutlineTransparency or 0
        end
        textLabel.TextSize = Script.Temp.ESPTextSize or 22

        if Script.Temp.ESPDistance then
            textLabel.Text = string.format("%s\n[%s]", ESPManager.Text, math.floor((camera.CFrame.Position - ESPManager.Object:GetPivot().Position).Magnitude))
        else
            textLabel.Text = ESPManager.Text
        end
    end)

    Script.ESPTable[ESPManager.Type][tableIndex] = ESPManager
    return ESPManager
end

-- Game functions
function Script.Functions.CompleteDalgonaGame()
    game:GetService("ReplicatedStorage"):WaitForChild("Replication"):WaitForChild("Event"):FireServer("Clicked")
    local args = {{Completed = true}}
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DALGONATEMPREMPTE"):FireServer(unpack(args))
end

function Script.Functions.PullRope(perfect)
    local args = {{PerfectQTE = true}}
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("TemporaryReachedBindable"):FireServer(unpack(args))
end

function Script.Functions.RevealGlassBridge()
    local glassHolder = workspace:FindFirstChild("GlassBridge") and workspace.GlassBridge:FindFirstChild("GlassHolder")
    if not glassHolder then return end

    for _, tilePair in pairs(glassHolder:GetChildren()) do
        for _, tileModel in pairs(tilePair:GetChildren()) do
            if tileModel:IsA("Model") and tileModel.PrimaryPart then
                local primaryPart = tileModel.PrimaryPart
                local isBreakable = primaryPart:GetAttribute("exploitingisevil") == true
                local targetColor = isBreakable and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                
                for _, part in pairs(tileModel:GetDescendants()) do
                    if part:IsA("BasePart") then
                        TweenService:Create(part, TweenInfo.new(0.5), {
                            Transparency = 0.5,
                            Color = targetColor
                        }):Play()
                    end
                end

                local highlight = Instance.new("Highlight")
                highlight.FillColor = targetColor
                highlight.FillTransparency = 0.7
                highlight.OutlineTransparency = 0.5
                highlight.Parent = tileModel
            end
        end
    end
end

function Script.Functions.BypassRagdoll()
    local character = lplr.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("Motor6D") and part.Name ~= "Neck" then
            part.MaxVelocity = 0.1
        end
    end
    
    if character:FindFirstChild("Ragdoll") then
        character.Ragdoll:Destroy()
    end
end

function Script.Functions.WinRLGL()
    if not lplr.Character then return end
    lplr.Character:PivotTo(CFrame.new(Vector3.new(-100.8, 1030, 115)))
end

function Script.Functions.TeleportSafe()
    if not lplr.Character then return end
    lplr.Character:PivotTo(CFrame.new(Vector3.new(-108, 329.1, 462.1)))
end

function Script.Functions.WinGlassBridge()
    if not lplr.Character then return end
    lplr.Character:PivotTo(CFrame.new(Vector3.new(-203.9, 520.7, -1534.3485)))
end

function Script.Functions.FixCamera()
    if workspace.CurrentCamera then
        pcall(function() workspace.CurrentCamera:Destroy() end)
    end
    local new = Instance.new("Camera")
    new.Parent = workspace
    workspace.CurrentCamera = new
    new.CameraType = Enum.CameraType.Custom
    if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
        new.CameraSubject = lplr.Character.Humanoid
    end
end

function Script.Functions.JoinDiscordServer()
    request({
        Url = "http://127.0.0.1:6463/rpc?v=1",
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Origin"] = "https://discord.com"
        },
        Body = HttpService:JSONEncode({
            cmd = "INVITE_BROWSER",
            args = {code = "dyhub"},
            nonce = HttpService:GenerateGUID(false)
        })
    })
    setclipboard("dsc.gg/dyhub")
    Script.Functions.Alert("Discord invite copied to clipboard!", 5)
end

-- Create Rayfield window
local Window = Rayfield:CreateWindow({
    Name = "DYHUB - Ink Game | Version: 2.0",
    LoadingTitle = "DYHUB Loading...",
    LoadingSubtitle = "by DYHUB Team",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "DYHUB_linoria/ink_game",
        FileName = "settings.json"
    },
    Discord = {
        Enabled = true,
        Invite = "dsc.gg/dyhub",
        RememberJoins = true
    }
})

-- Create tabs
local MainTab = Window:CreateTab("Main")
local VisualsTab = Window:CreateTab("Visuals")
local SettingsTab = Window:CreateTab("UI Settings")

-- Main Tab Elements
local AutowinSection = MainTab:CreateSection("Auto Win")
local AutowinToggle = MainTab:CreateToggle({
    Name = "Auto Win (All)",
    CurrentValue = false,
    Callback = function(Value)
        Script.Temp.AutoWin = Value
        if Value then
            Script.Functions.Alert("Autowin enabled!", 3)
            -- Add autowin logic here
        else
            Script.Functions.Alert("Autowin disabled!", 3)
        end
    end,
})

local PlayerSection = MainTab:CreateSection("Player")
local SpeedToggle = MainTab:CreateToggle({
    Name = "Speed",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            Script.Temp.OldSpeed = lplr.Character.Humanoid.WalkSpeed
            lplr.Character.Humanoid.WalkSpeed = Script.Temp.SpeedValue or 50
        else
            lplr.Character.Humanoid.WalkSpeed = Script.Temp.OldSpeed or 16
        end
    end,
})

local SpeedSlider = MainTab:CreateSlider({
    Name = "Speed Value",
    Range = {16, 300},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 50,
    Callback = function(Value)
        Script.Temp.SpeedValue = Value
        if SpeedToggle.CurrentValue then
            lplr.Character.Humanoid.WalkSpeed = Value
        end
    end,
})

local NoclipToggle = MainTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            Script.Temp.NoclipConnection = RunService.Stepped:Connect(function()
                if lplr.Character then
                    for _, part in pairs(lplr.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if Script.Temp.NoclipConnection then
                Script.Temp.NoclipConnection:Disconnect()
            end
        end
    end,
})

-- Visuals Tab
local ESPToggle = VisualsTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Callback = function(Value)
        Script.Temp.ESPHighlight = Value
        for _, espType in pairs(Script.ESPTable) do
            for _, esp in pairs(espType) do
                if esp then
                    for _, highlight in pairs(esp.Highlights) do
                        highlight.Enabled = Value
                    end
                end
            end
        end
    end,
})

local ESPDistance = VisualsTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = false,
    Callback = function(Value)
        Script.Temp.ESPDistance = Value
    end,
})

local ESPTextSize = VisualsTab:CreateSlider({
    Name = "ESP Text Size",
    Range = {16, 26},
    Increment = 1,
    CurrentValue = 22,
    Callback = function(Value)
        Script.Temp.ESPTextSize = Value
    end,
})

-- Settings Tab
local UnloadButton = SettingsTab:CreateButton({
    Name = "Unload",
    Callback = function()
        Rayfield:Destroy()
        for _, conn in pairs(Script.Connections) do
            pcall(function() conn:Disconnect() end)
        end
    end,
})

local DiscordButton = SettingsTab:CreateButton({
    Name = "Join Discord",
    Callback = function()
        Script.Functions.JoinDiscordServer()
    end,
})

-- Initialize
Script.Functions.Alert("DYHUB Loaded! Join our Discord: dsc.gg/dyhub", 10)

-- Character effects
local function applyEffects(character)
    local torso = character:WaitForChild("Torso", 5)
    if not torso then return end

    local nametag = torso:WaitForChild("Player_Nametag", 5)
    if not nametag then return end

    local levelText = nametag:WaitForChild("LevelText", 5)
    local displayName = nametag:WaitForChild("DisplayName", 5)
    if not levelText or not displayName then return end

    local isOwner = (lplr.Name == "Yolmar_43")
    levelText.Text = isOwner and "[ DYHUB - OWNER ]" or "[ DYHUB - MEMBER ]"

    local messages = {
        "DYHUB THE BEST (dsc.gg/dyhub)",
        "@" .. lplr.Name .. " (dsc.gg/dyhub)"
    }
    local msgIndex = 1
    displayName.Text = messages[msgIndex]

    task.spawn(function()
        while character.Parent do
            msgIndex = (msgIndex % #messages) + 1
            displayName.Text = messages[msgIndex]
            task.wait(2)
        end
    end)

    local wave, rainbowHue = 0, 0
    RunService.RenderStepped:Connect(function(deltaTime)
        wave = (wave + deltaTime * 2) % (2 * math.pi)
        rainbowHue = (rainbowHue + deltaTime * 0.2) % 1

        if isOwner then
            local brightness = (math.sin(wave) + 1) / 2
            levelText.TextColor3 = Color3.new(1, brightness, brightness)
        else
            local brightness = (math.sin(wave) + 1) / 2
            levelText.TextColor3 = Color3.new(brightness, 1, brightness)
        end

        displayName.TextColor3 = Color3.fromHSV(rainbowHue, 1, 1)
    end)

    levelText:GetPropertyChangedSignal("Text"):Connect(function()
        local correctText = isOwner and "[ DYHUB - OWNER ]" or "[ DYHUB - MEMBER ]"
        if levelText.Text ~= correctText then
            levelText.Text = correctText
        end
    end)
end

if lplr.Character then
    applyEffects(lplr.Character)
end
lplr.CharacterAdded:Connect(applyEffects)

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
lplr.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
end)