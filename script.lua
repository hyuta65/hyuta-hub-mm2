-- HYUTA HUB v3.0 - MM2 Cheat (Auto Farm: Orijinal Script + Toggle)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Settings
local ESPOn = false
local MurdererESPOn = false
local SheriffESPOn = false
local SpeedOn = false
local SpeedVal = 50
local FlyOn = false
local FlyVal = 50
local NoclipOn = false
local FollowOn = false
local FollowTarget = nil
local KillAllOn = false
local AutoKillOn = false
local AutoAimOn = false
local AutoShootOn = false

-- Auto Farm Variables
local IsFarming = false
local FarmingThread = nil
local TimerThread = nil
local CoinsCollected = 0
local StartTime = 0

-- Key tracking for fly
local keysDown = {}
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        keysDown[input.KeyCode] = true
    end
end)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        keysDown[input.KeyCode] = nil
    end
end)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Name = "HyutaHub"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.Size = UDim2.new(0, 300, 0, 950)
Main.Position = UDim2.new(0.5, -150, 0.3, -350)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Title.Text = "HYUTA HUB v1"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Toggle Function
local function Toggle(name, y, callback)
    local frame = Instance.new("Frame")
    frame.Parent = Main
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(0.85, 0, 0.25, 0)
    btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = btn

    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.BackgroundColor3 = on and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
        callback(on)
    end)
end

-- Toggles
Toggle("Player ESP (All)", 50, function(v) ESPOn = v end)
Toggle("Murderer ESP Only", 95, function(v) MurdererESPOn = v end)
Toggle("Sheriff ESP Only", 140, function(v) SheriffESPOn = v end)

Toggle("Speed Hack", 195, function(v)
    SpeedOn = v
    if not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

Toggle("Fly Mode", 285, function(v)
    FlyOn = v
    if v then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.PlatformStand = true
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for _, c in pairs(LocalPlayer.Character.HumanoidRootPart:GetChildren()) do
                if c:IsA("BodyVelocity") or c:IsA("BodyGyro") then c:Destroy() end
            end
        end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.PlatformStand = false
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
end)

Toggle("Noclip", 375, function(v) NoclipOn = v end)

Toggle("Fly Follow", 465, function(v)
    FollowOn = v
    if not v then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for _, c in pairs(LocalPlayer.Character.HumanoidRootPart:GetChildren()) do
                if c:IsA("BodyPosition") or c:IsA("BodyGyro") then c:Destroy() end
            end
        end
    end
end)

Toggle("Kill All", 510, function(v) KillAllOn = v end)
Toggle("Auto Kill (Murderer)", 555, function(v) AutoKillOn = v end)

Toggle("Auto Aim (Sheriff)", 600, function(v) AutoAimOn = v end)
Toggle("Auto Shoot (Sheriff)", 645, function(v) AutoShootOn = v end)

-- Auto Farm Toggle
Toggle("Auto Farm", 690, function(v)
    IsFarming = v
    if v then
        StartFarming()
    else
        StopFarming()
    end
end)

-- Farm Stats Labels
local CoinsLabel = Instance.new("TextLabel")
CoinsLabel.Parent = Main
CoinsLabel.Size = UDim2.new(1, -20, 0, 30)
CoinsLabel.Position = UDim2.new(0, 10, 0, 735)
CoinsLabel.BackgroundTransparency = 1
CoinsLabel.Text = "Coins: 0"
CoinsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CoinsLabel.Font = Enum.Font.GothamBold
CoinsLabel.TextSize = 14
CoinsLabel.TextXAlignment = Enum.TextXAlignment.Left

local CPHLabel = Instance.new("TextLabel")
CPHLabel.Parent = Main
CPHLabel.Size = UDim2.new(1, -20, 0, 30)
CPHLabel.Position = UDim2.new(0, 10, 0, 770)
CPHLabel.BackgroundTransparency = 1
CPHLabel.Text = "CPH: 0"
CPHLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CPHLabel.Font = Enum.Font.GothamBold
CPHLabel.TextSize = 14
CPHLabel.TextXAlignment = Enum.TextXAlignment.Left

local TimerLabel = Instance.new("TextLabel")
TimerLabel.Parent = Main
TimerLabel.Size = UDim2.new(1, -20, 0, 30)
TimerLabel.Position = UDim2.new(0, 10, 0, 805)
TimerLabel.BackgroundTransparency = 1
TimerLabel.Text = "Time: 00:00"
TimerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TimerLabel.Font = Enum.Font.GothamBold
TimerLabel.TextSize = 14
TimerLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Speed Input
local SpeedBox = Instance.new("TextBox")
SpeedBox.Parent = Main
SpeedBox.Size = UDim2.new(0.6, -10, 0, 35)
SpeedBox.Position = UDim2.new(0, 10, 0, 240)
SpeedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedBox.BorderSizePixel = 0
SpeedBox.Text = "50"
SpeedBox.PlaceholderText = "Speed"
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.Font = Enum.Font.Gotham
SpeedBox.TextSize = 14
SpeedBox.ClearTextOnFocus = false

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 5)
SpeedCorner.Parent = SpeedBox

local SpeedApply = Instance.new("TextButton")
SpeedApply.Parent = Main
SpeedApply.Size = UDim2.new(0.35, -10, 0, 35)
SpeedApply.Position = UDim2.new(0.65, 0, 0, 240)
SpeedApply.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
SpeedApply.BorderSizePixel = 0
SpeedApply.Text = "Apply"
SpeedApply.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedApply.Font = Enum.Font.GothamBold
SpeedApply.TextSize = 13
SpeedApply.AutoButtonColor = false
local SpeedApplyCorner = Instance.new("UICorner")
SpeedApplyCorner.CornerRadius = UDim.new(0, 5)
SpeedApplyCorner.Parent = SpeedApply

SpeedApply.MouseButton1Click:Connect(function()
    local val = tonumber(SpeedBox.Text)
    if val then
        SpeedVal = math.clamp(val, 16, 500)
        if SpeedOn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = SpeedVal
        end
    end
end)

-- Fly Speed Input
local FlyBox = Instance.new("TextBox")
FlyBox.Parent = Main
FlyBox.Size = UDim2.new(0.6, -10, 0, 35)
FlyBox.Position = UDim2.new(0, 10, 0, 330)
FlyBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FlyBox.BorderSizePixel = 0
FlyBox.Text = "50"
FlyBox.PlaceholderText = "Fly Speed"
FlyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyBox.Font = Enum.Font.Gotham
FlyBox.TextSize = 14
FlyBox.ClearTextOnFocus = false

local FlyCorner = Instance.new("UICorner")
FlyCorner.CornerRadius = UDim.new(0, 5)
FlyCorner.Parent = FlyBox

local FlyApply = Instance.new("TextButton")
FlyApply.Parent = Main
FlyApply.Size = UDim2.new(0.35, -10, 0, 35)
FlyApply.Position = UDim2.new(0.65, 0, 0, 330)
FlyApply.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
FlyApply.BorderSizePixel = 0
FlyApply.Text = "Apply"
FlyApply.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyApply.Font = Enum.Font.GothamBold
FlyApply.TextSize = 13
FlyApply.AutoButtonColor = false
local FlyApplyCorner = Instance.new("UICorner")
FlyApplyCorner.CornerRadius = UDim.new(0, 5)
FlyApplyCorner.Parent = FlyApply

FlyApply.MouseButton1Click:Connect(function()
    local val = tonumber(FlyBox.Text)
    if val then FlyVal = math.clamp(val, 10, 300) end
end)

-- Player List
local function UpdatePlayerList()
    for _, child in pairs(Main:GetChildren()) do
        if child:IsA("TextButton") and child.Name == "PlayerBtn" then child:Destroy() end
    end
    local yPos = 840
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local b = Instance.new("TextButton")
            b.Name = "PlayerBtn"
            b.Parent = Main
            b.Size = UDim2.new(1, -20, 0, 30)
            b.Position = UDim2.new(0, 10, 0, yPos)
            b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            b.BorderSizePixel = 0
            b.Text = player.Name
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.Font = Enum.Font.Gotham
            b.TextSize = 12
            b.AutoButtonColor = false
            local bc = Instance.new("UICorner")
            bc.CornerRadius = UDim.new(0, 5)
            bc.Parent = b
            b.MouseButton1Click:Connect(function()
                FollowTarget = player
            end)
            yPos = yPos + 35
        end
    end
end
UpdatePlayerList()

-- AUTO FARM (Orijinal Script Mantığı)
local function GetParts()
    local Char = LocalPlayer.Character
    if Char then
        local Root = Char:FindFirstChild("HumanoidRootPart")
        local Hum = Char:FindFirstChild("Humanoid")
        if Root and Hum then
            return Root, Hum
        end
    end
    return nil, nil
end

local function GetMap()
    while true do
        for _, Obj in ipairs(workspace:GetChildren()) do
            if Obj:GetAttribute("MapID") and Obj:FindFirstChild("CoinContainer") then
                return Obj
            end
        end
        task.wait()
    end
end

local function GetNearest(Root)
    if not Root then return nil end
    local Map = GetMap()
    local Closest, Dist = nil, math.huge
    for _, Coin in ipairs(Map.CoinContainer:GetChildren()) do
        local Visual = Coin:FindFirstChild("CoinVisual")
        if Visual and not Visual:GetAttribute("Collected") then
            local D = (Root.Position - Coin.Position).Magnitude
            if D < Dist then
                Closest = Coin
                Dist = D
            end
        end
    end
    return Closest
end

local function MoveTo(Root, Hum, Target)
    if not Root or not Hum then return end
    Hum:ChangeState(11)
    local D = (Root.Position - Target.Position).Magnitude
    local Tween = TweenService:Create(Root, TweenInfo.new(D / 25, Enum.EasingStyle.Linear), {CFrame = Target.CFrame})
    Tween:Play()
    Tween.Completed:Wait()
end

function StartFarming()
    if FarmingThread then return end

    CoinsCollected = 0
    StartTime = os.time()
    CoinsLabel.Text = "0"
    CPHLabel.Text = "0"
    TimerLabel.Text = "00:00"

    TimerThread = task.spawn(function()
        while IsFarming do
            local Elapsed = os.time() - StartTime
            local Minutes = string.format("%02d", math.floor(Elapsed / 60))
            local Seconds = string.format("%02d", Elapsed % 60)
            if TimerLabel and TimerLabel.Parent then
                TimerLabel.Text = Minutes .. ":" .. Seconds
            end
            task.wait(1)
        end
    end)

    FarmingThread = task.spawn(function()
        while IsFarming do
            local Success, Err = pcall(function()
                while IsFarming do
                    local Root, Hum = GetParts()
                    if not Root or not Hum or not LocalPlayer:GetAttribute("Alive") then
                        task.wait(0.5)
                        continue
                    end

                    local Target = GetNearest(Root)
                    if Target then
                        MoveTo(Root, Hum, Target)

                        local Visual = Target:FindFirstChild("CoinVisual")
                        local CollectedByUs = false

                        if Visual and not Visual:GetAttribute("Collected") then
                            while Visual and not Visual:GetAttribute("Collected") and Visual.Parent and IsFarming do
                                if not LocalPlayer:GetAttribute("Alive") or not GetParts() then break end
                                local Next = GetNearest(Root)
                                if Next and Next ~= Target then
                                    break
                                end
                                task.wait()
                            end

                            if not Visual or not Visual.Parent or Visual:GetAttribute("Collected") then
                                CollectedByUs = true
                            end
                        end

                        if CollectedByUs then
                            CoinsCollected = CoinsCollected + 1
                            if CoinsLabel and CoinsLabel.Parent then
                                CoinsLabel.Text = tostring(CoinsCollected)
                            end
                        end

                        local Elapsed = os.time() - StartTime
                        if Elapsed > 0 then
                            local Cph = math.floor((CoinsCollected / Elapsed) * 3600)
                            if CPHLabel and CPHLabel.Parent then
                                CPHLabel.Text = tostring(Cph)
                            end
                        else
                            if CPHLabel and CPHLabel.Parent then
                                CPHLabel.Text = "0"
                            end
                        end
                    else
                        task.wait(0.5)
                    end
                end
            end)

            if not IsFarming then break end
            if Err then
                warn("Farming error: " .. tostring(Err))
                task.wait(1)
            end
        end
    end)
end

function StopFarming()
    IsFarming = false
    if FarmingThread then
        FarmingThread = nil
    end
    if TimerThread then
        TimerThread = nil
    end
end

-- Role Detection
local COLOR_MURDERER = Color3.fromRGB(255, 0, 0)
local COLOR_SHERIFF  = Color3.fromRGB(0, 120, 255)
local COLOR_INNOCENT = Color3.fromRGB(0, 255, 100)

local function GetRole(player)
    local character = player.Character
    local backpack = player:FindFirstChild("Backpack")

    local function checkItem(itemName)
        if character and character:FindFirstChild(itemName) then return true end
        if backpack and backpack:FindFirstChild(itemName) then return true end
        return false
    end

    if checkItem("Knife") then return "Murderer"
    elseif checkItem("Gun") or checkItem("Revolver") then return "Sheriff"
    else return "Innocent" end
end

local function GetRoleColor(role)
    if role == "Murderer" then return COLOR_MURDERER
    elseif role == "Sheriff" then return COLOR_SHERIFF
    else return COLOR_INNOCENT end
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if not char or not hum then return end

        -- Speed
        if SpeedOn and not FlyOn then
            hum.WalkSpeed = SpeedVal
        end

        -- Noclip
        if NoclipOn then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end

        -- Fly Mode
        if FlyOn then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local bv = root:FindFirstChild("FlyVel")
                local bg = root:FindFirstChild("FlyGyro")
                if not bv then
                    bv = Instance.new("BodyVelocity")
                    bv.Name = "FlyVel"
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bv.Parent = root
                end
                if not bg then
                    bg = Instance.new("BodyGyro")
                    bg.Name = "FlyGyro"
                    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    bg.P = 10000
                    bg.Parent = root
                end
                bg.CFrame = Camera.CFrame
                local dir = Vector3.zero
                if keysDown[Enum.KeyCode.W] then dir += Camera.CFrame.LookVector end
                if keysDown[Enum.KeyCode.S] then dir -= Camera.CFrame.LookVector end
                if keysDown[Enum.KeyCode.A] then dir -= Camera.CFrame.RightVector end
                if keysDown[Enum.KeyCode.D] then dir += Camera.CFrame.RightVector end
                if keysDown[Enum.KeyCode.Space] then dir += Vector3.new(0,1,0) end
                if keysDown[Enum.KeyCode.LeftShift] or keysDown[Enum.KeyCode.RightShift] then dir -= Vector3.new(0,1,0) end
                if dir.Magnitude > 0 then dir = dir.Unit * FlyVal end
                bv.Velocity = dir
            end
        end

        -- Fly Follow
        if FollowOn and FollowTarget and FollowTarget.Character and FollowTarget.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = FollowTarget.Character.HumanoidRootPart
            local myRoot = char:FindFirstChild("HumanoidRootPart")
            if myRoot then
                local targetPos = targetRoot.Position + Vector3.new(0,5,0)
                local bp = myRoot:FindFirstChild("FollowBP")
                if not bp then
                    bp = Instance.new("BodyPosition")
                    bp.Name = "FollowBP"
                    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bp.P = 10000
                    bp.D = 1000
                    bp.Parent = myRoot
                end
                bp.Position = targetPos
                local bg = myRoot:FindFirstChild("FollowBG")
                if not bg then
                    bg = Instance.new("BodyGyro")
                    bg.Name = "FollowBG"
                    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    bg.P = 10000
                    bg.Parent = myRoot
                end
                bg.CFrame = CFrame.lookAt(myRoot.Position, targetRoot.Position)
            end
        end

        -- Kill All
        if KillAllOn then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                    local targetHum = player.Character.Humanoid
                    if targetHum.Health > 0 then
                        targetHum:TakeDamage(9999)
                        if targetHum.Health > 0 then
                            targetHum.Health = 0
                        end
                        for _, part in pairs(player.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part:BreakJoints()
                            end
                        end
                    end
                end
            end
        end

        -- Auto Kill (Murderer only)
        if AutoKillOn then
            local myRole = GetRole(LocalPlayer)
            if myRole == "Murderer" then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                        local targetHum = player.Character.Humanoid
                        if targetHum.Health > 0 then
                            targetHum:TakeDamage(9999)
                            if targetHum.Health > 0 then
                                targetHum.Health = 0
                            end
                        end
                    end
                end
            end
        end

        -- Auto Aim + Auto Shoot (Sheriff)
        if AutoAimOn or AutoShootOn then
            local nearestMurderer = nil
            local minDist = math.huge
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and GetRole(player) == "Murderer" and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local d = (player.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                    if d < minDist then
                        minDist = d
                        nearestMurderer = player
                    end
                end
            end

            if nearestMurderer then
                local targetHead = nearestMurderer.Character:FindFirstChild("Head")
                local targetRoot = nearestMurderer.Character:FindFirstChild("HumanoidRootPart")
                local aimPart = targetHead or targetRoot

                if aimPart then
                    if AutoAimOn then
                        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, aimPart.Position)
                    end

                    if AutoShootOn then
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then
                            tool:Activate()
                        end
                    end
                end
            end
        end
    end)
end)

-- ESP System (Highlight)
local ESPHighlights = {}

local function UpdateHighlightForPlayer(player)
    local highlight = ESPHighlights[player]
    if not highlight then return end

    local role = GetRole(player)
    local shouldShow = false

    if ESPOn then
        shouldShow = true
    elseif MurdererESPOn and role == "Murderer" then
        shouldShow = true
    elseif SheriffESPOn and role == "Sheriff" then
        shouldShow = true
    end

    if shouldShow and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        highlight.Enabled = true
        highlight.FillColor = GetRoleColor(role)
    else
        highlight.Enabled = false
    end
end

local function SetupHighlightForPlayer(player)
    if player == LocalPlayer then return end

    local function CreateHighlight(character)
        if ESPHighlights[player] then
            ESPHighlights[player]:Destroy()
        end

        local highlight = Instance.new("Highlight")
        highlight.Name = "RoleHighlight"
        highlight.FillColor = COLOR_INNOCENT
        highlight.FillTransparency = 0.4
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Enabled = false
        highlight.Parent = character

        ESPHighlights[player] = highlight
    end

    if player.Character then
        CreateHighlight(player.Character)
    end

    player.CharacterAdded:Connect(function()
        wait(0.2)
        CreateHighlight(player.Character)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    SetupHighlightForPlayer(player)
end
Players.PlayerAdded:Connect(SetupHighlightForPlayer)

RunService.RenderStepped:Connect(function()
    pcall(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                UpdateHighlightForPlayer(player)
            end
        end
    end)
end)

-- Refresh player list
RunService.Heartbeat:Connect(function()
    if os.clock() % 5 < 0.03 then UpdatePlayerList() end
end)

print("HYUTA HUB v3.0 loaded - Auto Farm Toggle ile hazır!")
