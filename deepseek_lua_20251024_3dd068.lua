local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Alive = workspace:WaitForChild("Alive")
local Remote
local ParrySuccess
local pps = 0
local BallFolder = workspace:WaitForChild("Balls")
local player = Players.LocalPlayer
local Parried = false
local IsSpamming = false
local ScriptDisabled = false
local ScriptStarted = false
local cam = workspace.CurrentCamera
local NEVERLOSE = loadstring(game:HttpGet("https://raw.githubusercontent.com/arnoldcpp/aaassd/refs/heads/main/Yeni%20Metin%20Belgesi.txt"))()
local RandomPlayerChosen
local ltick = tick()
local lptick = tick() + 100000
local llptick = tick()
local HasManualSpamTPEnabled = false
local mscoroutine
local animationConnection
local BallSpeed = 0

local Hash1 = nil
local Hash2 = nil

-- Gelişmiş parry sistemleri için yeni değişkenler
local LastParryTime = 0
local LastBallVelocity = Vector3.new(0,0,0)
local BallAcceleration = Vector3.new(0,0,0)
local PredictionHistory = {}
local AveragePredictionError = 0
local LastSuccessfulParry = 0
local ParryCooldown = false
local DynamicSensitivity = 5

-- Yeni konfigürasyon ayarları
local AdvancedParryConfig = {
    BaseReactionTime = 0.05, -- Daha hızlı tepki süresi
    MaxPredictionTime = 0.3, -- Daha uzun tahmin süresi
    VelocityMultiplier = 1.5, -- Hız çarpanı
    MinDistance = 15, -- Minimum parry mesafesi
    MaxDistance = 60, -- Maksimum parry mesafesi
    CurveCompensation = 1.2, -- Eğri top telafisi
    PingCompensation = 1.3, -- Ping telafisi
    AdvancedPrediction = true, -- Gelişmiş tahmin sistemi
    PredictionSmoothing = 0.7, -- Tahmin yumuşatma
    DynamicSensitivity = true, -- Dinamik hassasiyet
    PerfectTimingWindow = 0.1, -- Mükemmel zamanlama penceresi
    EarlyParryWindow = 0.15, -- Erken parry penceresi
    LateParryWindow = 0.1 -- Geç parry penceresi
}

local AdvancedSpamConfig = {
    BaseSpamCount = 3, -- Temel spam sayısı
    DynamicSpamCount = true, -- Dinamik spam sayısı
    MaxSpamCount = 8, -- Maksimum spam sayısı
    SpamDelay = 0.03, -- Spam gecikmesi
    VelocityBasedSpam = true, -- Hıza dayalı spam
    SpamVelocityThreshold = 100, -- Spam hız eşiği
    AntiPatternSpam = true, -- Anti-patern spam
    SpamPattern = {1, 2, 1, 3}, -- Spam paterni
    HumanLikeRandomness = 0.2, -- İnsan benzeri rastgelelik
    SmartSpamCooldown = true -- Akıllı spam bekleme süresi
}

function GetPing()
    return game.Stats.PerformanceStats.Ping:GetValue() / 1000
end

function TeleportToServer(player, id)
    game:GetService("TeleportService"):Teleport(id, player)
end

function remote_found()
    return Remote and Hash1 and Hash2
end

function parry_remote(object, arguments)
    return arguments[1] == '3gTmOK'
end

function GetArguments()
    local remote = Instance.new('RemoteEvent')

    local __hookfunction
    __hookfunction = hookfunction(remote.FireServer, function(self, ...)
        local arguments = {...}

        if not remote_found() and parry_remote(self, arguments) then
            Remote = self
            Hash1 = arguments[1]
            Hash2 = arguments[2]
        end

        return __hookfunction(self, ...)
    end)
end

GetArguments()

NEVERLOSE:Theme({
    Main = Color3.fromRGB(175, 225, 175),  -- Açık su yeğili
    Background = Color3.fromRGB(200, 240, 200),
    Text = Color3.new(1, 0.874509, 0.874509),
    -- Diğer renk öğeleri...
})

local Notification = NEVERLOSE:Notification()
Notification:Notify("success", "SUCCESS!", "Successfully started script.\nJoin the discord! https://discord.gg/MsgpjgZ2GK", 4)

local Visualiser = Instance.new("Part")
Visualiser.Shape = Enum.PartType.Ball
Visualiser.Material = Enum.Material.ForceField
Visualiser.Size = Vector3.new(30, 30, 30)
Visualiser.Color = Color3.new(1, 1, 1)
Visualiser.CastShadow = false
Visualiser.Anchored = true
Visualiser.CanCollide = false
Visualiser.CanTouch = false
Visualiser.CanQuery = false
Visualiser.Parent = workspace

local DebugVisualiser = Instance.new("Part")
DebugVisualiser.Shape = Enum.PartType.Ball
DebugVisualiser.Material = Enum.Material.ForceField
DebugVisualiser.Size = Vector3.new(30, 30, 30)
DebugVisualiser.Color = Color3.new(0.5, 1, 0.5)
DebugVisualiser.CastShadow = false
DebugVisualiser.Anchored = true
DebugVisualiser.CanCollide = false
DebugVisualiser.CanTouch = false
DebugVisualiser.CanQuery = false
DebugVisualiser.Transparency = 0
DebugVisualiser.Parent = workspace

local Highlight = Instance.new("Highlight")
Highlight.Parent = Visualiser
Highlight.Adornee = Visualiser
Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
Highlight.FillTransparency = 1
Highlight.OutlineTransparency = 0
Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)

local ESPHighlight = Instance.new("Highlight")
ESPHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
ESPHighlight.FillTransparency = 0.5
ESPHighlight.OutlineColor = Color3.fromRGB(223, 106, 106)
ESPHighlight.FillColor = Color3.fromRGB(255, 125, 125)
ESPHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
ESPHighlight.Name = "ESP Highlight"

local ESPGui = Instance.new("BillboardGui")
ESPGui.ExtentsOffset = Vector3.new(0, 5, 0)
ESPGui.AlwaysOnTop = true

local ESPFrame = Instance.new("Frame")
ESPFrame.Parent = ESPGui
ESPFrame.Size = UDim2.fromScale(1, 1)
ESPFrame.BackgroundTransparency = 1

local ESPText = Instance.new("TextLabel")
ESPText.Parent = ESPFrame
ESPText.Size = UDim2.fromScale(1, 1)
ESPText.BackgroundTransparency = 1
ESPText.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPText.TextScaled = true
ESPText.TextXAlignment = Enum.TextXAlignment.Center

local HubData = {
    Combat = {
        AutoParry = true,
        AutoSpam = false,
        ManualSpamEnabled = false, -- Yeni eklenen
        AutoParryV2 = false,
        AutoSpamV2 = false,
        Visualiser = false,
        AntiCurve = false,
        QuickSpamWin = false,
        SpamCount = 2,
        SpamSensitivity = 5,
        ParryDistance1 = 20,
        ParryDistance2 = 50,
        TargetingMethod = "Selective",
        CurveType = "Camera",
        CurveRandomization = 0
    },
    Misc = {
        LookAtBall = false,
        MoveToBall = false,
        PlayerCharLookAtBall = false,
        ViewBall = false,
        DebugMode = false,
        StatueMode = false,
        AutoStartManualSpam = false,
    },
    Player = {
        PlayerChangesEnabled = false,
        WalkSpeed = 35,
        JumpPower = 50,
        FieldOfView = 70
    },
    ESP = {
        BallESP = false,
        PlayerESP = false,
        TargetESP = false,
    },
    Trolls = {
        FollowBall = false,
        FollowBallDistanceDivider = 1,
        FollowDistance = 15,
        FollowType = "Around",
        DynamicDistance = false
    }
}

local OtherTable = {
    Fun = {
        NoAnimations = false
    }
}

local OldHubData

local configFile = "RONIX_HUB_BLADE_BALL.json"

local function SaveConfig()
    local encoded = game:GetService('HttpService'):JSONEncode(HubData)
    writefile(configFile, encoded)
end

function GetBall()
    for _, v in pairs(workspace:FindFirstChild("Balls"):GetChildren()) do
        if v:GetAttribute("realBall") then
            return v
        end
    end
end

function StartManualSpam()
    if mscoroutine then
        coroutine.close(mscoroutine)
    end
    mscoroutine = coroutine.create(function()
        game.Players.LocalPlayer.CameraMaxZoomDistance = math.huge
        local UserInputService = game:GetService("UserInputService")
        local RunService = game:GetService("RunService")
        local plr = game:GetService("Players").LocalPlayer
        local Alive = workspace:WaitForChild("Alive")
        local cam = workspace.CurrentCamera

        local services = {
            game:GetService('AnimationFromVideoCreatorService'),
            game:GetService('AdService'),
            game:GetService('BadgeService'),
            game:GetService('CookiesService')
        }

        local Remote = nil
        local Hash1 = nil
        local Hash2 = nil

        local IsSpamming = false
        local ScriptDisabled = false
        local Balls = workspace:FindFirstChild("Balls") -- :: Folder kısmını kaldırın

        function remote_found()
            return Remote and Hash
        end

        function parry_remote(object, arguments)
            return arguments[1] == '3gTmOK'
        end

        function GetArguments()
            local remote = Instance.new('RemoteEvent')

            local __hookfunction
            __hookfunction = hookfunction(remote.FireServer, function(self, ...)
                local arguments = {...}

                if not remote_found() and parry_remote(self, arguments) then
                    Remote = self
                    Hash1 = arguments[1]
                    Hash2 = arguments[2]
                end

                return __hookfunction(self, ...)
            end)
        end

        GetArguments()

        local function GetPlayersScreenPositions()
            local positions = {}
            for _, player in pairs(Alive:GetChildren()) do
                local humanoidRootPart = player and player:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    positions[player.Name] = cam:WorldToScreenPoint(humanoidRootPart.Position)
                end
            end
            return positions
        end

        function GetBalls()
            local realball, otherball
            for _, v in pairs(Balls:GetChildren()) do
                if v:GetAttribute("realBall") then
                    realball = v
                elseif not v:GetAttribute("realBall") then
                    otherball = v
                end
            end
            return realball, otherball
        end

        local function GetMousePosition()
            local mousepos = {}
            local mouse = plr:GetMouse()
            mousepos[1] = mouse.X
            mousepos[2] = mouse.Y
            return mousepos
        end

        local function GetCameraCFrame()
            return cam.CFrame
        end

        local function CheckRemote()
            if not Remote then
                if game:GetService("AdService"):FindFirstChildOfClass("RemoteEvent") then
                    Remote = game:GetService("AdService"):FindFirstChildOfClass("RemoteEvent")
                end
            end
        end

        local function Parry(playerpositions)
            local args = {
                Hash1,
                Hash2,
                0.5,
                GetCameraCFrame(),
                GetPlayersScreenPositions(),
                GetMousePosition(),
                false
            }
            CheckRemote()
            if remote_found() then
                Remote:FireServer(unpack(args))
            else
                mouse1click()
            end
        end

        local function OnRenderStep()
            local _realball, _otherball = GetBalls()
            if not ScriptDisabled then
                if UserInputService:IsKeyDown(Enum.KeyCode.KeypadPlus) and Alive:FindFirstChild(plr.Name) then
                    IsSpamming = true
                    Parry()
                    plr.PlayerGui.Hotbar.Block.UIGradient.Offset = Vector2.new(0, -0.5)
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or HasManualSpamTPEnabled then
                        plr.Character:FindFirstChild("HumanoidRootPart").Position = _otherball.Position
                    end
                else
                    IsSpamming = false
                end
            end
        end

        coroutine.resume(coroutine.create(function()
            RunService.Heartbeat:Connect(OnRenderStep)
        end))

        plr.PlayerGui.Hotbar.Block.UIGradient:GetPropertyChangedSignal("Offset"):Connect(function()
            if IsSpamming and Alive:FindFirstChild(plr.Name) and plr.PlayerGui.Hotbar.Block.UIGradient.Offset == Vector2.new(0, -0.5) then
                Parry()
            end
        end)
    end)
    coroutine.resume(mscoroutine)
end

-- Gelişmiş top tahmini fonksiyonu
local function AdvancedBallPrediction(ball, playerChar, deltaTime)
    if not ball or not playerChar then return 0, Vector3.new(0,0,0) end
    
    local hrp = playerChar:FindFirstChild("HumanoidRootPart")
    if not hrp then return 0, Vector3.new(0,0,0) end
    
    -- Topun mevcut pozisyonu ve hızı
    local ballPos = ball.Position
    local ballVel = ball.Velocity
    local ballSpeed = ballVel.Magnitude
    
    -- İvme hesaplama
    BallAcceleration = (ballVel - LastBallVelocity) / deltaTime
    LastBallVelocity = ballVel
    
    -- Oyuncu pozisyonu
    local playerPos = hrp.Position
    local toPlayer = (playerPos - ballPos).Unit
    
    -- Temel mesafe ve süre hesaplama
    local distance = (ballPos - playerPos).Magnitude
    local timeToHit = distance / math.max(ballSpeed, 1)
    
    -- Gelişmiş tahmin sistemi
    if AdvancedParryConfig.AdvancedPrediction then
        -- Eğri top telafisi
        local curveFactor = AdvancedParryConfig.CurveCompensation * (1 + math.abs(BallAcceleration.Magnitude) / 100)
        
        -- Ping telafisi
        local ping = GetPing()
        local pingFactor = AdvancedParryConfig.PingCompensation * (1 + ping * 0.5)
        
        -- Dinamik hassasiyet ayarı
        if AdvancedParryConfig.DynamicSensitivity then
            DynamicSensitivity = math.clamp(5 + ballSpeed / 50, 3, 10)
        end
        
        -- Tahmin süresini ayarla
        timeToHit = timeToHit * curveFactor * pingFactor
        
        -- Tahmin geçmişini kaydet
        table.insert(PredictionHistory, timeToHit)
        if #PredictionHistory > 10 then
            table.remove(PredictionHistory, 1)
        end
        
        -- Ortalama tahmin hatası
        if #PredictionHistory > 0 then
            local sum = 0
            for _, v in ipairs(PredictionHistory) do
                sum = sum + v
            end
            AveragePredictionError = sum / #PredictionHistory
        end
        
        -- Yumuşatılmış tahmin süresi
        timeToHit = timeToHit * AdvancedParryConfig.PredictionSmoothing + 
                   AveragePredictionError * (1 - AdvancedParryConfig.PredictionSmoothing)
    end
    
    -- Tahmin edilen pozisyon
    local predictedPos = ballPos + ballVel * timeToHit + 
                         BallAcceleration * (timeToHit * timeToHit * 0.5)
    
    -- Mesafe ve pozisyonu döndür
    return timeToHit, predictedPos
end

-- Gelişmiş parry kontrol fonksiyonu
local function ShouldParry(ball, playerChar)
    if not ball or not playerChar or ParryCooldown then return false end
    
    local hrp = playerChar:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    -- Delta zaman hesaplama
    local currentTime = tick()
    local deltaTime = currentTime - LastParryTime
    LastParryTime = currentTime
    
    -- Top tahmini
    local timeToHit, predictedPos = AdvancedBallPrediction(ball, playerChar, deltaTime)
    
    -- Mesafe hesaplama
    local distance = (predictedPos - hrp.Position).Magnitude
    local ballSpeed = ball.Velocity.Magnitude
    
    -- Dinamik parry mesafesi
    local dynamicDistance = math.clamp(
        AdvancedParryConfig.MinDistance + 
        (ballSpeed * AdvancedParryConfig.VelocityMultiplier * 0.1),
        AdvancedParryConfig.MinDistance,
        AdvancedParryConfig.MaxDistance
    )
    
    -- Ping telafisi
    local ping = GetPing()
    dynamicDistance = dynamicDistance * (1 + ping * 0.2)
    
    -- Parry zamanlama kontrolü
    local perfectTiming = timeToHit < AdvancedParryConfig.PerfectTimingWindow
    local earlyTiming = timeToHit < AdvancedParryConfig.EarlyParryWindow
    local lateTiming = timeToHit < AdvancedParryConfig.LateParryWindow
    
    -- Parry koşulları
    local shouldParry = (distance < dynamicDistance) and 
                       (perfectTiming or earlyTiming or lateTiming) and
                       (ball:GetAttribute("target") == player.Name)
    
    -- Mükemmel zamanlama bonusu
    if perfectTiming and shouldParry then
        DynamicSensitivity = math.max(DynamicSensitivity - 0.5, 3)
    end
    
    return shouldParry, timeToHit, predictedPos
end

-- Gelişmiş spam fonksiyonu
local function AdvancedSpam(ball, playerChar)
    if not ball or not playerChar then return end
    
    -- Spam sayısını belirle
    local spamCount = AdvancedSpamConfig.BaseSpamCount
    
    if AdvancedSpamConfig.DynamicSpamCount then
        local ballSpeed = ball.Velocity.Magnitude
        spamCount = math.clamp(
            math.floor(ballSpeed / AdvancedSpamConfig.SpamVelocityThreshold * 2),
            AdvancedSpamConfig.BaseSpamCount,
            AdvancedSpamConfig.MaxSpamCount
        )
    end
    
    -- Anti-patern spam
    if AdvancedSpamConfig.AntiPatternSpam then
        local patternIndex = (tick() % #AdvancedSpamConfig.SpamPattern) + 1
        spamCount = spamCount + AdvancedSpamConfig.SpamPattern[patternIndex]
    end
    
    -- İnsan benzeri rastgelelik ekle
    if AdvancedSpamConfig.HumanLikeRandomness > 0 then
        spamCount = spamCount * (1 + (math.random() * 2 - 1) * AdvancedSpamConfig.HumanLikeRandomness)
        spamCount = math.clamp(math.floor(spamCount), 1, AdvancedSpamConfig.MaxSpamCount)
    end
    
    -- Spam yürütme
    for i = 1, spamCount do
        if Remote and Hash1 and Hash2 then
            local args = {
                Hash1,
                Hash2,
                0.5,
                cam.CFrame,
                GetPlayersScreenPositions(),
                GetMousePosition(),
                false
            }
            Remote:FireServer(unpack(args))
        else
            mouse1click()
        end
        
        -- Akıllı spam bekleme süresi
        if AdvancedSpamConfig.SmartSpamCooldown and i < spamCount then
            local delay = AdvancedSpamConfig.SpamDelay * (1 + math.random() * 0.2)
            task.wait(delay)
        end
    end
    
    -- Spam sonrası bekleme süresi
    if AdvancedSpamConfig.SmartSpamCooldown then
        ParryCooldown = true
        task.delay(0.2, function()
            ParryCooldown = false
        end)
    end
end

-- Ana parry kontrol döngüsü
local function ParryCheckLoop()
    while task.wait() do
        if not ScriptDisabled and player.Character and HubData.Combat.AutoParry then
            local ball = GetBall()
            if ball and ball:GetAttribute("target") == player.Name then
                local shouldParry, timeToHit, predictedPos = ShouldParry(ball, player.Character)
                
                if shouldParry then
                    -- Parry yürüt
                    PlayAnimation("13772445960")
                    
                    if HubData.Combat.AutoSpam then
                        AdvancedSpam(ball, player.Character)
                    else
                        if Remote and Hash1 and Hash2 then
                            local args = {
                                Hash1,
                                Hash2,
                                0.5,
                                cam.CFrame,
                                GetPlayersScreenPositions(),
                                GetMousePosition(),
                                false
                            }
                            Remote:FireServer(unpack(args))
                        else
                            mouse1click()
                        end
                    end
                    
                    -- Başarılı parry kaydı
                    LastSuccessfulParry = tick()
                    
                    -- Dinamik hassasiyet ayarı
                    if AdvancedParryConfig.DynamicSensitivity then
                        DynamicSensitivity = math.clamp(DynamicSensitivity + 0.1, 3, 10)
                    end
                end
            end
        end
    end
end

-- Döngüyü başlat
coroutine.wrap(ParryCheckLoop)()

function CreateGui()
    local Window = NEVERLOSE:AddWindow("NEXUS")

    local Main = Window:AddTab("Main", "home")
    local Other = Window:AddTab("Other", "list")
    local Funny = Window:AddTab("Fun", "ads")
    local Credits = Window:AddTab("Credits", "locked")
    local Servers = Window:AddTab("Servers", "folder")

    local AP = Main:AddSection("AUTO PARRY", "left")
    local AS = Main:AddSection("Auto Spam", "left")
    local OTHER = Main:AddSection("OTHER", "mouse")
    local Misc = Main:AddSection("MISC", "right")
    local Trolling = Main:AddSection("TELEPORTING", "right")
    local PlayerSection = Main:AddSection("PLAYER", "right")

    local Stop = Other:AddSection("STOP", "right")
    local Info = Other:AddSection("INFO", "left")
    local Debug = Other:AddSection("DEBUG", "right")
    local Discord = Other:AddSection("DISCORD (Updates, configs, etc.)", "left")
    local Reset = Other:AddSection("RESET", "right")
    local EmergencyLeave = Other:AddSection("EMERGENCY LEAVE", "left")
    local ManualSpam = Other:AddSection("MANUAL SPAM", "left")

    local AnimationStuff = Funny:AddSection("ANIMATION", "right")
    local MiscFun = Funny:AddSection("MISC", "left")
    local Other = Funny:AddSection("OTHER", "left")

    local CreditsTo = Credits:AddSection("CREDITS", "left")

    local ServersTo = Servers:AddSection("SERVERS", "left")

    -- For fixing stuffs
    Stop:AddButton("Close and stop script", function()
        ScriptDisabled = true
        Visualiser:Destroy()
        DebugVisualiser:Destroy()
        Window:Delete()
    end)
    
    Reset:AddButton("Reset Config", function()
        HubData = OldHubData
        SaveConfig()
        Notification:Notify("success", "Config", "Configuration reset successfully.\nPlease re-execute to fix any errors.", 3)
    end)
    
    Stop:AddButton("Stop Spamming", function()
        IsSpamming = false
        Visualiser.Color = Color3.new(1, 1, 1)
    end)

    -- Auto Parry
    APToggle = AP:AddToggle("Auto Parry", HubData.Combat.AutoParry, function(val)
        HubData.Combat.AutoParry = val
        SaveConfig()
    end)

    ACToggle = AP:AddToggle("Anti Curve", HubData.Combat.AntiCurve, function(val)
        HubData.Combat.AntiCurve = val
        SaveConfig()
    end)

    TMDrowpdown = AP:AddDropdown("Targeting Method", {"Selective", "Random", "Closest", "Farthest"}, HubData.Combat.TargetingMethod, function(val)
        HubData.Combat.TargetingMethod = val
        SaveConfig()
    end)

    PD1Slider = AP:AddSlider("Base Distance", 1, 30, HubData.Combat.ParryDistance1, function(val)
        HubData.Combat.ParryDistance1 = val
        SaveConfig()
    end)

    PD2Slider = AP:AddSlider("Velocity Relevance", 1, 100, HubData.Combat.ParryDistance2, function(val)
        HubData.Combat.ParryDistance2 = val
        SaveConfig()
    end)

    -- Auto Spam
    ASToggle = AS:AddToggle("Auto Spam", HubData.Combat.AutoSpam, function(val)
        HubData.Combat.AutoSpam = val
        SaveConfig()
    end)

    APV2Toggle = AP:AddToggle("Auto Parry V2", HubData.Combat.AutoParryV2, function(val)
        HubData.Combat.AutoParryV2 = val
        SaveConfig()
        
        if val then
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/2VQuiet/AutoParryBladeBall/refs/heads/main/Auto%20Parry%20Script"))()
            end)
            
            if not success then
                Notification:Notify("error", "LOAD ERROR", "Failed to load Auto Parry V2: "..tostring(err), 5)
                APV2Toggle:SetState(false)
            end
        end
    end)

    ASV2Toggle = AS:AddToggle("Auto Spam V2 (BETA)", HubData.Combat.AutoSpamV2, function(val)
        HubData.Combat.AutoSpamV2 = val
        SaveConfig()
    end)

    QWToggle = AS:AddToggle("Teleport Spam (BLATANT)", HubData.Combat.QuickSpamWin, function(val)
        HubData.Combat.QuickSpamWin = val
        SaveConfig()
    end)

    SpamCountSlider = AS:AddSlider("Spam Count", 1, 10, HubData.Combat.SpamCount, function(val)
        HubData.Combat.SpamCount = val
        SaveConfig()
    end)

    SpamSensitivitySlider = AS:AddSlider("Spam Sensitivity", 1, 10, HubData.Combat.SpamSensitivity, function(val)
        HubData.Combat.SpamSensitivity = val
        SaveConfig()
    end)

    -- Other
    VSToggle = OTHER:AddToggle("Visualiser", HubData.Combat.Visualiser, function(val)
        HubData.Combat.Visualiser = val
        SaveConfig()
    end)

    CurveType = OTHER:AddDropdown("Curve Type", {"Camera", "Random", "Closest", "Farthest", "Up", "Down", "Left", "Right", "Forwards", "Backwards", "Smart"}, HubData.Combat.CurveType, function(val)
        HubData.Combat.CurveType = val
        SaveConfig()
    end)

    CurveRandomizationSlider = OTHER:AddSlider("Curve Randomization", 0, 10, HubData.Combat.CurveRandomization, function(val)
        HubData.Combat.CurveRandomization = val
        SaveConfig()
    end)
    
    -- Info
    Info:AddLabel("High spam count can cause high ping.")
    Info:AddLabel("Recommended count is 3.")
    Info:AddLabel("If you have issues, Reset the config.")
    Info:AddLabel("If the issue persists, Make a ticket in the discord.")
    
    -- Misc
    LABToggle = Misc:AddToggle("Look at the Ball", HubData.Misc.LookAtBall, function(val)
        HubData.Misc.LookAtBall = val
        SaveConfig()
    end)
    
    MOToggle = Misc:AddToggle("Follow Ball", HubData.Misc.MoveToBall, function(val)
        HubData.Misc.MoveToBall = val
        SaveConfig()
    end)
    
    PFBToggle = Misc:AddToggle("Face Ball", HubData.Misc.PlayerCharLookAtBall, function(val)
        HubData.Misc.PlayerCharLookAtBall = val
        SaveConfig()
    end)

    VBToggle = Misc:AddToggle("View Ball", HubData.Misc.ViewBall, function(val)
        HubData.Misc.ViewBall = val
        SaveConfig()
    end)

    -- Trolling
    Trolling:AddToggle("Teleport Enabled", HubData.Trolls.FollowBall, function(val)
        HubData.Trolls.FollowBall = val
        for _, v in pairs(workspace:WaitForChild("Map"):GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
                v.CanCollide = not val
            end
        end
        SaveConfig()
    end)

    Trolling:AddToggle("Dynamic Distance", HubData.Trolls.DynamicDistance, function(val)
        HubData.Trolls.DynamicDistance = val
        SaveConfig()
    end)

    Trolling:AddSlider("Distance", 10, 100, HubData.Trolls.FollowDistance, function(val)
        HubData.Trolls.FollowDistance = val
        SaveConfig()
    end)

    Trolling:AddDropdown("Teleport Type", {"Around", "Above", "Below", "Y Locked", "All Around", "Predictive", "Pred | Y Locked"}, HubData.Trolls.FollowType, function(val)
        HubData.Trolls.FollowType = val
        SaveConfig()
    end)
    
    -- Other stuffs
    Other:AddButton("Infinite Yield", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end)

    Other:AddButton("DEX Explorer", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
    end)
    
    Discord:AddButton("Copy Discord Invite", function()
        setclipboard("discord.gg/ronix")
        Notification:Notify("success", "SUCCESS!", "Successfully copied discord invite.")
    end)
    
    EmergencyLeave:AddButton("Emergency Leave", function()
        game:GetService("Players").LocalPlayer:Kick("Emergency Leave")
    end)
    
    ManualSpam:AddButton("Manual Spam", function()
        StartManualSpam()
    end)

    ManualSpam:AddToggle("Auto Start", HubData.Misc.AutoStartManualSpam, function(val)
        HubData.Misc.AutoStartManualSpam = val
        SaveConfig()
    end)
    
    ManualSpam:AddToggle("Teleport Enabled", false, function(val)
        HasManualSpamTPEnabled = val
    end)
    
    -- Debug
    Debug:AddToggle("Debug Mode", HubData.Misc.DebugMode, function(val)
        HubData.Misc.DebugMode = val
        SaveConfig()
    end)
    
    ParriesPerSecond = Debug:AddLabel("Parries Per Second: "..pps)
    LastTick = Debug:AddLabel("Last Tick: "..tostring(math.round((tick() - lptick) * 100) / 100))
    isSpamming = Debug:AddLabel("Spamming: "..tostring(IsSpamming))
    ballSpeedCounter = Debug:AddLabel("Ball Speed: "..tostring(math.round(BallSpeed * 10) / 10))

    -- Player
    PCEToggle = PlayerSection:AddToggle("Changes Enabled", HubData.Player.PlayerChangesEnabled, function(val)
        HubData.Player.PlayerChangesEnabled = val
        SaveConfig()
    end)

    WSSlider = PlayerSection:AddSlider("Walk Speed", 35, 200, HubData.Player.WalkSpeed, function(val)
        HubData.Player.WalkSpeed = val
        SaveConfig()
    end)

    JPSlider = PlayerSection:AddSlider("Jump Power", 50, 200, HubData.Player.JumpPower, function(val)
        HubData.Player.JumpPower = val
        SaveConfig()
    end)

    FOVSlider = PlayerSection:AddSlider("Field Of View", 70, 120, HubData.Player.FieldOfView, function(val)
        HubData.Player.FieldOfView = val
        SaveConfig()
    end)

    -- Fun
    AnimationStuff:AddToggle("No Animations", HubData.Misc.StatueMode, function(val)
        HubData.Misc.StatueMode = val
        SaveConfig()
    end)

    MiscFun:AddButton("Remove Map", function()
        local part = Instance.new("Part")
        part.Parent = workspace
        part.Anchored = true
        part.CanCollide = true
        part.Size = Vector3.new(2000, 1, 2000)
        part.Name = "UnderMapPart"
        local partpos
        for _, v in pairs(workspace.Map:GetChildren()) do
            if v:IsA("Model") then
                partpos = v:FindFirstChild("BALLSPAWN").Position
            end
        end
        part.Position = partpos - Vector3.new(0, 19, 0)
        workspace.Map:FindFirstChildOfClass("Model"):Destroy()
    end)

    MiscFun:AddButton("Remove Part", function()
        workspace:FindFirstChild("UnderMapPart"):Destroy()
    end)

    MiscFun:AddButton("Rejoin", function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game:GetService("Players").LocalPlayer)
    end)

    MiscFun:AddSlider("FPS (x10)", 3, 24, 24, function(val)
        setfpscap(val * 10)
    end)

    Main:AddSection("", "left"):AddLabel("\n")
    Main:AddSection("", "right"):AddLabel("\n")
    Main:AddSection("", "left"):AddLabel("\n")
    Main:AddSection("", "right"):AddLabel("\n")

    CreditsTo:AddLabel("CREDITS TO")
    CreditsTo:AddLabel("Rewin & Arnold")

    ServersTo:AddButton("PRO Server", function()
        TeleportToServer(game.Players.LocalPlayer, 14732610803)
    end)

    ServersTo:AddButton("VC Server", function()
        TeleportToServer(game.Players.LocalPlayer, 15131065025)
    end)

    ServersTo:AddButton("Mobile Server", function()
        TeleportToServer(game.Players.LocalPlayer, 15509350986)
    end)
end

local function LoadConfig()
    local standarddata = table.clone(HubData)
    OldHubData = standarddata
    if isfile(configFile) then
        local success, decoded = pcall(function()
            return Game:GetService("HttpService"):JSONDecode(readfile(configFile))
        end)
        print(success, decoded)
        if success and decoded then
            HubData = decoded
            Notification:Notify("success", "Config", "Configuration loaded successfully.", 3)
        else
            warn("Failed to decode configuration data.")
            Notification:Notify("error", "Config", "Failed to decode configuration data.", 3)
            HubData = OldHubData
        end
    else
        warn("Configuration file not found. Using default settings.")
        Notification:Notify("warning", "Config", "Configuration file not found. Using default settings.", 3)
    end
end

LoadConfig()
CreateGui()

local function Stop()
    Visualiser.Color = Color3.new(1, 1, 1)
    for i = 1, 10, 1 do
        IsSpamming = false
        task.wait(1 / 20)
        workspace.CurrentCamera.CameraSubject = player.Character:FindFirstChild("Humanoid")
    end
end

if HubData.Misc.AutoStartManualSpam then
    StartManualSpam()
end

BallFolder.ChildAdded:Connect(Stop)
BallFolder.ChildRemoved:Connect(Stop)

local function getclosestplr()
    local bot_position = workspace.CurrentCamera.Focus.Position

    local distance = math.huge
    local closest_player_character = nil

    for i, player in pairs(Alive:GetChildren()) do
        if player:FindFirstChild("Humanoid") and player.Name ~= Players.LocalPlayer.Name then
            local player_position = player.HumanoidRootPart.Position
            local distance_from_bot = (bot_position - player_position).magnitude
        
            if distance_from_bot < distance then
                distance = distance_from_bot
                closest_player_character = player
            end
        end
    end

    return closest_player_character
end

local function getfarthestplr()
    local bot_position = workspace.CurrentCamera.Focus.Position

    local distance = 0
    local farthest_player_character = nil

    for i, player in pairs(Alive:GetChildren()) do
        if player:FindFirstChild("Humanoid") and player.Name ~= Players.LocalPlayer.Name then
            local player_position = player.HumanoidRootPart.Position
            local distance_from_bot = (bot_position - player_position).magnitude
        
            if distance_from_bot > distance then
                distance = distance_from_bot
                farthest_player_character = player
            end
        end
    end

    return farthest_player_character
end

local function isAerodynamicSlash(ball)
    local currentVel = ball.AssemblyLinearVelocity
    local verticalSpeed = math.abs(currentVel.Y)
    local horizontalSpeed = (Vector3.new(currentVel.X, 0, currentVel.Z)).Magnitude
    local cframeYChange = math.abs(ball.CFrame.Y)
    return verticalSpeed > 200 and horizontalSpeed < verticalSpeed / 2 and cframeYChange > 70
end

local function lerp(start, _end, alpha)
    return (1 - alpha) * start + alpha * _end
end

function GetClosestPlayerDistance(plr)
    local a = plr.Character:FindFirstChild("HumanoidRootPart").Position - getclosestplr():FindFirstChild("HumanoidRootPart").Position
    return a.Magnitude
end

function GetFarthestPlayerDistance(plr)
    local a = plr.Character:FindFirstChild("HumanoidRootPart").Position - getfarthestplr():FindFirstChild("HumanoidRootPart").Position
    return a.Magnitude
end

local function GetBallSpeed(ball, plr)
    if ball:GetAttribute("realBall") then
        local vel = ball.Velocity
        local speed = vel.Magnitude
        return speed + (speed * GetPing())
    end
end

local function GetZoomiesMagnitude(ball, plr)
    if ball:GetAttribute("realBall") and ball:FindFirstChild("zoomies") then
        local vel = zoomies.VectorVelocity
        local speed = vel.Magnitude
        return speed + (speed * plr:GetNetworkPing())
    end
end

local function GetBallVelocity(ball, plr)
    local vel = ball.Velocity
    return vel + (vel * plr:GetNetworkPing())
end

local function GetBallPosition(ball)
    return ball.Position
end

local function PredictBallPosition(ball, factor)
    local vel = ball.Velocity.Unit
    factor = factor or 1
    return ball.Position + vel * factor
end

local function PredictBallPosition2(ball, factor)
    local vel = ball.Velocity
    factor = factor or 1
    return ball.Position + vel * factor
end

local function CheckRemote()
    if not Remote then
        if game:GetService("AdService"):FindFirstChildOfClass("RemoteEvent") then
            Remote = game:GetService("AdService"):FindFirstChildOfClass("RemoteEvent")
        end
    end
end

local function CheckRemote2()
    if not ParrySuccess then
        if game:GetService("ReplicatedStorage"):WaitForChild("Remotes") then
            ParrySuccess = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ParrySuccess")
        end
    end
end

local lastpos
local function TryFollowBall(ball, player)
    local ignore = {
        "OutsidePart",
        "Neon",
        "Cylinder.004",
        "Terrain",
        "Tunnel",
        "BridgeSmall",
        "Rail",
        "Wood",
    }

    if HubData.Trolls.FollowBall and Alive:FindFirstChild(player.Name) then
        local velocity = HubData.Trolls.DynamicDistance and (Visualiser.Size.Y / (HubData.Trolls.FollowDistance / 10)) or (HubData.Trolls.FollowDistance - 5)
        workspace.CurrentCamera.CameraSubject = ball

        if tick() - ltick > 0.1 then
            ltick = tick()
            for _, v in pairs(workspace:FindFirstChild("Map"):GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("UnionOperation") and not (v.CanCollide == table.find(ignore, v.Name)) then
                    v.CanCollide = false
                end
            end
        end

        local function moveCharacter(newCFrame)
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.CFrame = newCFrame
            end
        end

        local ballspawn = workspace.Map:FindFirstChild("BALLSPAWN", true)

        if HubData.Trolls.FollowType == "Around" then
            local newCFrame = ball.CFrame * CFrame.Angles(0, math.rad(math.random(-180, 180)), 0) * CFrame.new(0, 0, velocity)
            moveCharacter(newCFrame)
        elseif HubData.Trolls.FollowType == "Above" then
            moveCharacter(ball.CFrame * CFrame.new(0, velocity, 0))
        elseif HubData.Trolls.FollowType == "Below" then
            moveCharacter(ball.CFrame * CFrame.new(0, -17.5, 0))
        elseif HubData.Trolls.FollowType == "Y Locked" then
            if ballspawn then
                local newCFrame = CFrame.new(ball.Position.X, ballspawn.Position.Y - 15, ball.Position.Z)
                moveCharacter(newCFrame)
            end
        elseif HubData.Trolls.FollowType == "All Around" then
            local randomAngles = CFrame.Angles(
                math.rad(math.random(-180, 180)),
                math.rad(math.random(-180, 180)),
                math.rad(math.random(-180, 180))
            )
            moveCharacter(ball.CFrame * randomAngles * CFrame.new(0, 0, velocity))
        elseif HubData.Trolls.FollowType == "Predictive" and ball:GetAttribute("realBall") then
            local predictedPosition = PredictBallPosition(ball, velocity)
            local newCFrame = CFrame.new(predictedPosition)
            moveCharacter(newCFrame)
        elseif HubData.Trolls.FollowType == "Pred | Y Locked" and ball:GetAttribute("realBall") then
            if ballspawn then
                local predictedPosition = PredictBallPosition2(ball, 0.13333333)
                local newCFrame = CFrame.new(predictedPosition.X, ballspawn.Position.Y - 15, predictedPosition.Z)
                moveCharacter(newCFrame)
            end
        end
    else
        workspace.CurrentCamera.CameraSubject = player.Character:FindFirstChild("Humanoid")
        if tick() - ltick > 0.1 then
            ltick = tick()
            for _, v in pairs(workspace:FindFirstChild("Map"):GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("UnionOperation") and not (v.CanCollide == table.find(ignore, v.Name)) then
                    v.CanCollide = not table.find(ignore, v.Name)
                end
            end
        end
    end
end

local function TryLookAtBall(ball, player)
    if HubData.Misc.LookAtBall and Alive:FindFirstChild(player.Name) then
        local newcf = CFrame.new(workspace.CurrentCamera.CFrame.Position, ball.Position)
        workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(newcf, 0.075)
    end
end

local function TryMoveToBall(ball, player)
    if HubData.Misc.MoveToBall and Alive:FindFirstChild(player.Name) then
        player.Character:FindFirstChild("Humanoid"):MoveTo(ball.Position)
    end
end

local function TryPlayerCharLookAtBall(ball, player)
    if HubData.Misc.PlayerCharLookAtBall and Alive:FindFirstChild(player.Name) then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        local goalpos = ball.Position
        local hrpPos = hrp.Position
        local newcf = CFrame.new(hrpPos, Vector3.new(goalpos.X, hrpPos.Y, goalpos.Z))
        hrp.CFrame = hrp.CFrame:Lerp(newcf, 0.02)
    end
end

local function TryViewBall(ball, player)
    if not HubData.Trolls.FollowBall then
        if HubData.Misc.ViewBall and Alive:FindFirstChild(player.Name) then
            workspace.CurrentCamera.CameraSubject = ball
        else
            workspace.CurrentCamera.CameraSubject = player.Character:FindFirstChild("Humanoid")
        end
    end
end

function GetBallDistance(ball, player)
    local a = ball.Position - player.Character:FindFirstChild("HumanoidRootPart").Position
    return a.Magnitude
end

local function UpdatePlayerStuff(player)
    if player.Character and player.Character:FindFirstChild("Humanoid") and cam then
        local hum = player.Character:FindFirstChild("Humanoid")
        hum.UseJumpPower = true
        if HubData.Player.PlayerChangesEnabled then
            hum.WalkSpeed = HubData.Player.WalkSpeed
            hum.JumpPower = HubData.Player.JumpPower
        end
        cam.FieldOfView = HubData.Player.FieldOfView
    end
end

local function UpdateFunStuff(player)
    local animate = player.Character:FindFirstChild("Animate")
    if animate then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
        
        if HubData.Misc.StatueMode then
            animate.Disabled = true

            if animator then
                if animationConnection then
                    animationConnection:Disconnect()
                end

                animationConnection = animator.AnimationPlayed:Connect(function(anim)
                    anim:Stop()
                end)

                for _, anim in next, animator:GetPlayingAnimationTracks() do
                    anim:Stop()
                end
            end
        else
            animate.Disabled = false

            if animationConnection then
                animationConnection:Disconnect()
                animationConnection = nil
            end
        end
    end
end

local function UpdateBallESPText(ball)
    if ball:FindFirstChild("Ball ESP") and ball:FindFirstChild("Ball ESP"):FindFirstChild("Frame") and ball:FindFirstChild("Ball ESP"):FindFirstChild("Frame"):FindFirstChild("TextLabel") then
        local label = ball:FindFirstChild("Ball ESP"):FindFirstChild("Frame"):FindFirstChild("TextLabel")
        local speed = 10
        label.Text = "BALL • "..tostring(speed)
    end
end

local function TryCreateBallESPGui(ball)
    if not ball:FindFirstChild("Ball ESP") then
        if ball:IsA("BasePart") and ball:GetAttribute("realBall") then
            local Gui = ESPGui:Clone()
            Gui.Parent = ball
            Gui.Name = "Ball ESP"
        end
    end
end

local function AddPps()
    pps = pps + 1  -- Doğru Lua sözdizimi
    task.delay(1, function()
        pps = pps - 1  -- Doğru Lua sözdizimi
    end)
end

local function GetPlayersScreenPositions()
    local positions = {}
    if HubData.Combat.TargetingMethod == "Selective" then
        for _, player in pairs(Alive:GetChildren()) do
            local humanoidRootPart = player and player:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                positions[player.Name] = cam:WorldToScreenPoint(humanoidRootPart.Position)
            end
        end
    elseif HubData.Combat.TargetingMethod == "Closest" then
        local ClosestPlayer = getclosestplr()
        if ClosestPlayer then
            positions[ClosestPlayer.Name] = cam:WorldToScreenPoint(ClosestPlayer:FindFirstChild("HumanoidRootPart").Position)
        end
    elseif HubData.Combat.TargetingMethod == "Farthest" then
        local FarthestPlayer = getfarthestplr()
        if FarthestPlayer then
            positions[FarthestPlayer.Name] = cam:WorldToScreenPoint(FarthestPlayer:FindFirstChild("HumanoidRootPart").Position)
        end
    elseif HubData.Combat.TargetingMethod == "Random" then
        local players = {}
        for _, rndplr in pairs(Alive:GetChildren()) do
            if rndplr.Name ~= player.Name then
                table.insert(players, rndplr)
            end
        end
        RandomPlayerChosen = players[math.random(1, #players)]
        if RandomPlayerChosen then
            positions[RandomPlayerChosen.Name] = cam:WorldToScreenPoint(RandomPlayerChosen:FindFirstChild("HumanoidRootPart").Position)
        end
    end
    return positions
end

local function GetMousePosition()
    local mousepos = {}
    local mouse = player:GetMouse()
    if HubData.Combat.TargetingMethod == "Selective" then
        mousepos[1] = mouse.x
        mousepos[2] = mouse.Y
    elseif HubData.Combat.TargetingMethod == "Closest" then
        local ClosestPlayer = getclosestplr()
        if ClosestPlayer then
            local plrpos = cam:WorldToScreenPoint(ClosestPlayer:FindFirstChild("HumanoidRootPart").Position)
            mousepos[1] = plrpos.X
            mousepos[2] = plrpos.Y
        end
    elseif HubData.Combat.TargetingMethod == "Farthest" then
        local FarthestPlayer = getfarthestplr()
        if FarthestPlayer then
            local plrpos = cam:WorldToScreenPoint(FarthestPlayer:FindFirstChild("HumanoidRootPart").Position)
            mousepos[1] = plrpos.X
            mousepos[2] = plrpos.Y
        end
    elseif HubData.Combat.TargetingMethod == "Random" then
        if RandomPlayerChosen then
            local plrpos = cam:WorldToScreenPoint(RandomPlayerChosen:FindFirstChild("HumanoidRootPart").Position)
            mousepos[1] = plrpos.X
            mousepos[2] = plrpos.Y
        end
    end
    return mousepos
end

local function GetCameraCFrame()
    local rand = Random.new()
    local cf
    local rand1 = rand:NextNumber(-HubData.Combat.CurveRandomization / 10, HubData.Combat.CurveRandomization / 10)
    local rand2 = rand:NextNumber(-HubData.Combat.CurveRandomization / 10, HubData.Combat.CurveRandomization / 10)
    local function randomVector()
        x = rand:NextNumber(-1, 1)
        y = rand:NextNumber(-1, 1)
        z = rand:NextNumber(-1, 1)
        return Vector3.new(x, y, z)
    end
    local function getSmartDirection()
        local lookVector = cam.CFrame.LookVector
        if rand:NextNumber(0, 1) > 0.5 then
            lookVector = -lookVector
        end
        local randdegrees = rand:NextNumber(-12.5, 12.5)
        local randomOffset = math.rad(randdegrees)
        print(randdegrees)
        
        local rotation = CFrame.Angles(0, randomOffset, 0)
        local adjustedLookVector = (rotation * lookVector).Unit
        
        return adjustedLookVector
    end
    if HubData.Combat.CurveType == "Closest" then
        local closestplr = getclosestplr()
        cf = CFrame.new(player.Character:FindFirstChild("HumanoidRootPart").Position, closestplr:FindFirstChild("HumanoidRootPart").Position)
    elseif HubData.Combat.CurveType == "Farthest" then
        local farthestplr = getfarthestplr()
        cf = CFrame.new(player.Character:FindFirstChild("HumanoidRootPart").Position, farthestplr:FindFirstChild("HumanoidRootPart").Position)
    elseif HubData.Combat.CurveType == "Random" then
        local up = randomVector().Unit
        local right = randomVector().Unit
        local look = randomVector().Unit
        
        cf = CFrame.fromMatrix(cam.CFrame.Position, right, up, -look)
    elseif HubData.Combat.CurveType == "Up" then
        cf = CFrame.new(cam.CFrame.Position, cam.CFrame.Position + Vector3.new(rand1, 1, rand2))
    elseif HubData.Combat.CurveType == "Down" then
        cf = CFrame.new(cam.CFrame.Position, cam.CFrame.Position + Vector3.new(rand1, -1, rand2))
    elseif HubData.Combat.CurveType == "Left" then
        cf = CFrame.new(cam.CFrame.Position, cam.CFrame.Position + Vector3.new(-1, rand1, rand2))
    elseif HubData.Combat.CurveType == "Right" then
        cf = CFrame.new(cam.CFrame.Position, cam.CFrame.Position + Vector3.new(1, rand1, rand2))
    elseif HubData.Combat.CurveType == "Forwards" then
        cf = CFrame.new(cam.CFrame.Position, cam.CFrame.Position + Vector3.new(rand1, rand2, 1))
    elseif HubData.Combat.CurveType == "Backwards" then
        cf = CFrame.new(cam.CFrame.Position, cam.CFrame.Position + Vector3.new(rand1, rand2, -1))
    elseif HubData.Combat.CurveType == "Smart" then
        local smartDirection = getSmartDirection()
        cf = CFrame.new(cam.CFrame.Position, cam.CFrame.Position + smartDirection)
    else
        cf = cam.CFrame
    end
    return cf
end

local function parry(playerpositions)
    local args = {
        Hash1,
        Hash2,
        0.5,
        GetCameraCFrame(),
        GetPlayersScreenPositions(),
        GetMousePosition(),
        false
    }
    if remote_found() then
        Remote:FireServer(unpack(args))
    else
        mouse1click()
    end
end

local function GetBallDot(ball, player)
    local ballToPlayerDir = (player.Character:FindFirstChild("HumanoidRootPart").Position - ball.Position).unit
    local dot = ball.Velocity.unit:Dot(ballToPlayerDir)
    if ball:GetAttribute("target") == player.Name and not IsSpamming then
        return math.min(dot * 3, 1)
    else
        return 1
    end
end

local function PlayAnimation(animid)
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://"..string.match(animid, "%d+")
    local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if animator then
        local animation = animator:LoadAnimation(anim)
        animation:Play()
    end
end

local function StopAnimation(animid)
    local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if animator then                
        for _, anim in next, animator:GetPlayingAnimationTracks() do
            if anim.Animation.AnimationId == "rbxassetid://"..string.match(animid, "%d+") then
                anim:Stop()
            end
        end
    end
end

local function PressKey(key)
    game:GetService("VirtualInputManager"):SendKeyEvent(true, key, false, game)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, key, false, game)
end

local lastParryTime = 0
local lastSpamCheck = 0

local function checkProximityToPlayer(ball, player)
    local distance = (ball.Position - Visualiser.Position).Magnitude
    local realBallAttribute = ball:GetAttribute("realBall")
    local target = ball:GetAttribute("target")
    local from = ball:GetAttribute("from")

    local currentTick = tick()
    if currentTick - lastSpamCheck > 0.1 then
        lastSpamCheck = currentTick
        function CheckColor()
            if IsSpamming then
                Visualiser.Color = Visualiser.Color:Lerp(Color3.new(1, 0, 0), 0.0125)
                Highlight.OutlineColor = Visualiser.Color
            else
                Visualiser.Color = Visualiser.Color:Lerp(Color3.new(1, 1, 1), 0.015)
                Highlight.OutlineColor = Visualiser.Color
            end
        end
    end

    TryFollowBall(ball, player)
    TryLookAtBall(ball, player)
    TryMoveToBall(ball, player)
    TryPlayerCharLookAtBall(ball, player)
    TryViewBall(ball, player)
    
    pcall(function()
        ParriesPerSecond:Text(string.format("Parries Per Second: %d", pps))
        isSpamming:Text(string.format("Spamming: %s", tostring(IsSpamming)))
        ballSpeedCounter:Text(string.format("Ball Speed: %d", math.round(GetBallSpeed(ball, player) * 10) / 10))
    end)

    if distance and realBallAttribute and target then
        local ballSpeed = math.max(GetBallSpeed(ball, player) / 3 / 50 * HubData.Combat.ParryDistance2, HubData.Combat.ParryDistance1) * (1 + GetPing())
        local ballDir = GetBallDot(ball, player)
        local spamSpeedRequirement = math.max((GetBallSpeed(ball, player) * (0.15 / 5 * HubData.Combat.SpamSensitivity)), (15 / 5 * HubData.Combat.SpamSensitivity)) * (1 + GetPing())
        local closestPlayerDistance = GetClosestPlayerDistance(player)
        
        if HubData.Combat.AntiCurve then
            ballSpeed = math.max(ballSpeed * ballDir, HubData.Combat.ParryDistance1)
        end

        local function TryParry()
            if HubData.Combat.AutoParry and not Parried then
                Parried = true
                print("Parry")
                PlayAnimation("13772445960")
                parry()

                local signalConnection
                signalConnection = ball:GetAttributeChangedSignal("target"):Connect(function()
                    Parried = false
                    signalConnection:Disconnect()
                end)
                
                local oldTick = tick()
                repeat
                    RunService.PreSimulation:Wait()
                until (tick() - oldTick) >= 0.5 or not Parried
                Parried = false
            end
        end
        
        if (distance / ballSpeed) <= 1 and target == player.Name then
            TryParry()
        end
        
        if HubData.Combat.AutoSpamV2 then
            CheckColor()
            if lptick - llptick <= (0.15 + GetPing()) / 5 * HubData.Combat.SpamSensitivity and tick() - lptick <= (0.15 + GetPing()) / 5 * HubData.Combat.SpamSensitivity and ScriptStarted then
                IsSpamming = true
            else
                IsSpamming = false
            end
        elseif HubData.Combat.AutoSpam then
            CheckColor()
            if distance <= spamSpeedRequirement and closestPlayerDistance <= spamSpeedRequirement and pps >= math.max((10 - HubData.Combat.SpamSensitivity), 3) then
                IsSpamming = true
            elseif distance <= math.clamp(ballSpeed / 2.5, 15, math.huge) and closestPlayerDistance <= Visualiser.Size.Magnitude / 4 and pps >= 3 then
                IsSpamming = true
            else
                IsSpamming = false
            end
        end
        
        if IsSpamming and target == player.Name then
            coroutine.resume(coroutine.create(function()
                for i = 1, HubData.Combat.SpamCount do
                    PlayAnimation("13772445960")
                    parry()
                    player.PlayerGui.Hotbar.Block.UIGradient.Offset = Vector2.new(0, -0.5)
                    if HubData.Combat.QuickSpamWin then
                        player.Character:FindFirstChild("HumanoidRootPart").Position = GetBall().Position
                    end
                    task.wait(1 / 35)
                end
            end))
        end
        
        local visualiserSize
        if not IsSpamming then
            visualiserSize = math.max(ballSpeed - (ball.Velocity.Magnitude * GetPing() / 2) * 2, HubData.Combat.ParryDistance1 + 5)
            Visualiser.Size = Vector3.new(visualiserSize, visualiserSize, visualiserSize) * (1 + GetPing() * 2)
        else
            visualiserSize = spamSpeedRequirement * 2
            Visualiser.Size = Vector3.new(visualiserSize, visualiserSize, visualiserSize)
        end

        local debugSize = math.max(ballSpeed - (ball.Velocity.Magnitude * GetPing() / 2) * 2, HubData.Combat.ParryDistance1 + 5)
        DebugVisualiser.Size = Vector3.new(debugSize, debugSize, debugSize) * 1.6 * (1 + GetPing() * 2)
    end
end

local function checkBallsProximity()
    if not ScriptDisabled then
        Visualiser.Material = Enum.Material.ForceField
        CheckRemote()
        CheckRemote2()
        UpdatePlayerStuff(player)
        UpdateFunStuff(player)
        if player and player.Character then
            Visualiser.Position = player.Character:FindFirstChild("HumanoidRootPart").Position - (player.Character:FindFirstChild("HumanoidRootPart").Velocity / 15)
            DebugVisualiser.Position = player.Character:FindFirstChild("HumanoidRootPart").Position - (player.Character:FindFirstChild("HumanoidRootPart").Velocity / 15)
            if HubData.Combat.Visualiser then
                Visualiser.Transparency = 0
            else
                Visualiser.Transparency = 1
            end
            if HubData.Misc.DebugMode then
                DebugVisualiser.Transparency = 0.5
            else
                DebugVisualiser.Transparency = 1
            end
            for _, ball in ipairs(BallFolder:GetChildren()) do
                if ball:IsA("BasePart") then
                    checkProximityToPlayer(ball, player)
                end
            end
        end
    end
end

RunService.PreRender:Connect(checkBallsProximity)
BallFolder.ChildAdded:Connect(checkBallsProximity)

workspace:WaitForChild("Map").ChildAdded:Connect(function(map)
    for _, v in pairs(map:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
            if HubData.Trolls.FollowBall then
                v.CanCollide = false
            else
                v.CanCollide = true
            end
        end
    end
end)

repeat wait() until ParrySuccess

ParrySuccess.OnClientEvent:Connect(function()
    if not ScriptDisabled then
        StopAnimation("13772445960")
        AddPps()
        LastTick:Text("Last Tick: "..tostring(math.round((tick() - lptick) * 100) / 100))
        llptick = lptick
        lptick = tick()
        print("Updated - "..tostring(lptick))
        task.delay(0.5, function()
            ScriptStarted = true
        end)
    end
end)

-- Nexus yazısını oluştur (SADECE 1 KEZ)
local nexusCreated = false -- Kontrol değişkeni

local function CreateNexusSign()
    if nexusCreated then return end -- Zaten varsa çık
    
    -- Eski yazıları temizle
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name == "NexusSign" then
            obj:Destroy()
        end
    end

    -- Harita konumunu bul
    local ballSpawn = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("BALLSPAWN", true)
    local signPosition = ballSpawn and (ballSpawn.Position + Vector3.new(0, 10, 0)) or Vector3.new(0, 25, 0)

    -- Ana Part
    local signPart = Instance.new("Part")
    signPart.Name = "NexusSign"
    signPart.Size = Vector3.new(25, 8, 1)
    signPart.Position = signPosition
    signPart.Anchored = true
    signPart.CanCollide = false
    signPart.Transparency = 1
    signPart.Parent = workspace

    -- Yüzey GUI
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Adornee = signPart
    surfaceGui.Face = Enum.NormalId.Front
    surfaceGui.AlwaysOnTop = true
    surfaceGui.Parent = signPart

    -- Yazı
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "NEXUS"
    textLabel.Font = Enum.Font.FredokaOne
    textLabel.TextColor3 = Color3.fromRGB(255, 0, 255)
    textLabel.TextScaled = true
    textLabel.TextStrokeColor3 = Color3.new(0.1, 0, 0.1)
    textLabel.TextStrokeTransparency = 0.3
    textLabel.Parent = surfaceGui

    -- Optimize Işık
    local pointLight = Instance.new("PointLight")
    pointLight.Color = Color3.fromRGB(255, 50, 255)
    pointLight.Range = 25
    pointLight.Brightness = 1.5
    pointLight.Parent = signPart

    -- Yavaş Dönüş
    coroutine.wrap(function()
        while task.wait(0.03) and signPart.Parent do
            signPart.CFrame = signPart.CFrame * CFrame.Angles(0, math.rad(0.5), 0)
        end
    end)()

    nexusCreated = true -- İşaretle
end

-- SADECE İLK HARİTA YÜKLENİŞİNDE ÇALIŞSIN
workspace:WaitForChild("Map").ChildAdded:Connect(function(child)
    if child.Name == "BALLSPAWN" then
        task.wait(1)
        if not nexusCreated then
            CreateNexusSign()
        end
    end
end)

-- Oyun başında kontrol
task.wait(3)
if not nexusCreated then
    CreateNexusSign()
end

-- ►►► ZIPLAMA & JUMP DODGE SİSTEMİ ◄◄◄ --
local JumpState = false
local LastJumpTime = 0

game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    
    humanoid.Jumping:Connect(function()
        JumpState = true
        LastJumpTime = tick()
    end)
    
    humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
        if humanoid.FloorMaterial ~= Enum.Material.Air then
            JumpState = false
        end
    end)
end)

-- ►►► GÜNCELLENMİŞ TEXT EFFECT SİSTEMİ ◄◄◄ --
local TextEffects = {
    Enable = true,
    Messages = {
        "DE: TRAJECTORY #", 
        "SUCCESSFUL PARRY!",
        "PERFECT TIMING!",
        "COUNTER ATTACK!",
        "BALL DEFLECTED!",
        "JUMP DODGED!"
    },
    Colors = {
        Color3.new(1, 0.2, 0.2), -- Kırmızı
        Color3.new(0.2, 1, 0.2), -- Yeşil
        Color3.new(0.2, 0.5, 1), -- Mavi
        Color3.new(1, 0.5, 0),   -- Turuncu
        Color3.new(0.8, 0.2, 1)  -- Mor
    },
    ActiveEffects = {},
    Settings = {
        JumpDodge = {
            Cooldown = 1.2,
            VelocityThreshold = 75,
            TimeWindow = 0.35
        }
    }
}

local function CreateTextEffect(player, message)
    if not TextEffects.Enable then return end
    
    -- Eski efekt temizleme
    if TextEffects.ActiveEffects[player] then
        TextEffects.ActiveEffects[player]:Destroy()
        TextEffects.ActiveEffects[player] = nil
    end

    local character = player.Character
    if not character or not character:FindFirstChild("Head") then return end

    -- Efekt ayarları
    local isJumpDodge = (message == "JUMP DODGED!")
    local colorIndex = isJumpDodge and 5 or math.random(1,4)
    
    local textGui = Instance.new("BillboardGui")
    TextEffects.ActiveEffects[player] = textGui
    textGui.Size = isJumpDodge and UDim2.new(5,0,3,0) or UDim2.new(4,0,2,0)
    textGui.StudsOffset = isJumpDodge and Vector3.new(0,5,0) or Vector3.new(0,3,0)
    textGui.Adornee = character.Head
    textGui.Parent = character.Head

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1,0,1,0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = message
    textLabel.Font = Enum.Font.GothamBlack
    textLabel.TextSize = isJumpDodge and 28 or 24
    textLabel.TextColor3 = TextEffects.Colors[colorIndex]
    textLabel.TextStrokeTransparency = 0.5
    textLabel.Parent = textGui

    -- Animasyon
    game:GetService("TweenService"):Create(
        textGui,
        TweenInfo.new(1.5),
        {StudsOffset = textGui.StudsOffset + Vector3.new(0,4,0), TextTransparency = 1}
    ):Play()
    
    game.Debris:AddItem(textGui, 2)
end

-- ►►► TOP VURUŞ ALGILAMA ◄◄◄ --
local LastVelocity = Vector3.new()
workspace.Balls.ChildAdded:Connect(function(ball)
    if ball:GetAttribute("realBall") then
        ball:GetPropertyChangedSignal("Velocity"):Connect(function()
            local velocityChange = (ball.Velocity - LastVelocity).Magnitude
            LastVelocity = ball.Velocity
            
            if velocityChange > TextEffects.Settings.JumpDodge.VelocityThreshold 
                and JumpState 
                and (tick() - LastJumpTime) < TextEffects.Settings.JumpDodge.TimeWindow then
                CreateTextEffect(game.Players.LocalPlayer, "JUMP DODGED!")
            end
        end)
    end
end)

-- ►►► PARRY EVENT GÜNCELLEMESİ ◄◄◄ --
ParrySuccess.OnClientEvent:Connect(function()
    if not ScriptDisabled then
        local randomMessage = TextEffects.Messages[math.random(1, #TextEffects.Messages-1)]
        CreateTextEffect(game.Players.LocalPlayer, randomMessage)
    end
end)

-- ►►► GUI GÜNCELLEMESİ ◄◄◄ --
local DodgeSection = Main:AddSection("JUMP DODGE", "arrow-up")
DodgeSection:AddToggle("Enabled", true, function(val)
    TextEffects.Messages[6] = val and "JUMP DODGED!" or nil
end)

DodgeSection:AddColorpicker("Dodge Color", TextEffects.Colors[5], function(val)
    TextEffects.Colors[5] = val
end)

DodgeSection:AddSlider("Cooldown", 0.5, 3, TextEffects.Settings.JumpDodge.Cooldown, function(val)
    TextEffects.Settings.JumpDodge.Cooldown = val
end)

-- ►►► KARAKTER YÖNETİMİ ◄◄◄ --
game.Players.LocalPlayer.CharacterRemoving:Connect(function()
    if TextEffects.ActiveEffects[game.Players.LocalPlayer] then
        TextEffects.ActiveEffects[game.Players.LocalPlayer]:Destroy()
        TextEffects.ActiveEffects[game.Players.LocalPlayer] = nil
    end
end)

print("NEXUS HUB - Gelişmiş Auto-Parry ve Auto-Spam sistemleri aktif!")