--Credit to xz#1111 for source
local Ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/drillygzzly/Roblox-UI-Libs/main/Abyss%20Lib/Abyss%20Lib%20Source.lua"))()
local Ui = Library

local LoadTime = tick()

local Loader = Library.CreateLoader(
    "MM2 Ultimate Script", 
    Vector2.new(300, 300)
)

local Window = Library.Window(
    "Murder Mystery 2", 
    Vector2.new(500, 620)
)

Window.SendNotification(
    "Normal", -- Normal, Warning, Error 
    "Press RightShift to open menu and close menu!", 
    10
)

Window.Watermark(
    "MM2 Ultimate v2.0"
)

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- ESP Sistemi
local ESP = {
    Enabled = false,
    Objects = {},
    RefreshLoop = nil
}

function ESP:Toggle(state)
    self.Enabled = state
    if state then
        -- Mevcut oyuncuları ekle
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then 
                self:Create(player)
            end
        end
        
        -- Yeni oyuncuları dinle
        Players.PlayerAdded:Connect(function(player)
            if self.Enabled then
                self:Create(player)
            end
        end)
        
        -- Sürekli güncelleme döngüsü
        self.RefreshLoop = RunService.Heartbeat:Connect(function()
            if self.Enabled then
                self:Update()
            end
        end)
        
    else
        -- ESP'yi kapat
        self:Clear()
        if self.RefreshLoop then
            self.RefreshLoop:Disconnect()
            self.RefreshLoop = nil
        end
    end
end

function ESP:Clear()
    for _, obj in pairs(self.Objects) do
        if obj.Highlight then 
            obj.Highlight:Destroy() 
        end
        if obj.Billboard then 
            obj.Billboard:Destroy() 
        end
    end
    self.Objects = {}
end

function ESP:GetRoleColor(player)
    if player.Character then
        if player.Character:FindFirstChild("Knife") or (player.Backpack and player.Backpack:FindFirstChild("Knife")) then
            return Color3.new(1, 0, 0) -- Kırmızı: Murderer
        elseif player.Character:FindFirstChild("Gun") or (player.Backpack and player.Backpack:FindFirstChild("Gun")) then
            return Color3.new(0, 0, 1) -- Mavi: Sheriff
        end
    end
    return Color3.new(0, 1, 0) -- Yeşil: Innocent
end

function ESP:Update()
    for player, obj in pairs(self.Objects) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local humanoidRootPart = character.HumanoidRootPart
            
            -- Mesafeyi hesapla
            local distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude)
            
            -- Billboard'ı güncelle
            if obj.Billboard and obj.Billboard:FindFirstChild("TextLabel") then
                obj.Billboard.TextLabel.Text = player.Name .. " | " .. distance .. "m"
            end
            
            -- Highlight rengini güncelle
            if obj.Highlight then
                obj.Highlight.FillColor = self:GetRoleColor(player)
            end
            
        else
            -- Karakter yoksa ESP'yi temizle
            if obj.Highlight then obj.Highlight:Destroy() end
            if obj.Billboard then obj.Billboard:Destroy() end
            self.Objects[player] = nil
        end
    end
end

function ESP:Create(player)
    if self.Objects[player] then return end
    
    -- Karakterin yüklenmesini bekle
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
    if not humanoidRootPart then return end
    
    local roleColor = self:GetRoleColor(player)
    
    -- Highlight oluştur
    local highlight = Instance.new("Highlight")
    highlight.FillColor = roleColor
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.Parent = character
    
    -- Billboard oluştur
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Adornee = humanoidRootPart
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.Parent = character
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.Text = player.Name
    label.TextColor3 = roleColor
    label.Parent = billboard
    
    self.Objects[player] = {
        Highlight = highlight, 
        Billboard = billboard
    }
    
    -- Silah değişikliklerini dinle
    character.ChildAdded:Connect(function(child)
        if child.Name == "Knife" or child.Name == "Gun" then
            wait(0.1)
            if self.Objects[player] and self.Objects[player].Highlight then
                local newColor = self:GetRoleColor(player)
                self.Objects[player].Highlight.FillColor = newColor
                if self.Objects[player].Billboard and self.Objects[player].Billboard:FindFirstChild("TextLabel") then
                    self.Objects[player].Billboard.TextLabel.TextColor3 = newColor
                end
            end
        end
    end)
    
    if player.Backpack then
        player.Backpack.ChildAdded:Connect(function(child)
            if child.Name == "Knife" or child.Name == "Gun" then
                wait(0.1)
                if self.Objects[player] and self.Objects[player].Highlight then
                    local newColor = self:GetRoleColor(player)
                    self.Objects[player].Highlight.FillColor = newColor
                    if self.Objects[player].Billboard and self.Objects[player].Billboard:FindFirstChild("TextLabel") then
                        self.Objects[player].Billboard.TextLabel.TextColor3 = newColor
                    end
                end
            end
        end)
    end
end

-- Auto Shot Murderer Sistemi
local AutoShot = {
    Enabled = false,
    Shooting = false,
    FireButton = nil
}

function AutoShot:CreateFireButton()
    if self.FireButton then 
        self.FireButton:Destroy() 
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoShotGUI"
    screenGui.Parent = game:GetService("CoreGui")
    
    local fireButton = Instance.new("ImageButton")
    fireButton.Name = "FireButton"
    fireButton.Size = UDim2.new(0, 60, 0, 60)
    fireButton.Position = UDim2.new(1, -80, 1, -160)
    fireButton.BackgroundColor3 = Color3.new(1, 0, 0)
    fireButton.BackgroundTransparency = 0.3
    fireButton.Image = "rbxassetid://3570695787"
    fireButton.ScaleType = Enum.ScaleType.Slice
    fireButton.SliceCenter = Rect.new(100, 100, 100, 100)
    fireButton.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = fireButton
    
    local buttonLabel = Instance.new("TextLabel")
    buttonLabel.Size = UDim2.new(1, 0, 1, 0)
    buttonLabel.BackgroundTransparency = 1
    buttonLabel.Text = "FIRE"
    buttonLabel.TextColor3 = Color3.new(1, 1, 1)
    buttonLabel.TextStrokeTransparency = 0
    buttonLabel.TextSize = 12
    buttonLabel.Font = Enum.Font.GothamBold
    buttonLabel.Parent = fireButton
    
    fireButton.MouseButton1Click:Connect(function()
        self:ShootMurderer()
    end)
    
    self.FireButton = screenGui
end

function AutoShot:FindMurderer()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hasKnife = player.Character:FindFirstChild("Knife") or 
                           (player.Backpack and player.Backpack:FindFirstChild("Knife"))
            if hasKnife and player.Character:FindFirstChild("HumanoidRootPart") then
                return player
            end
        end
    end
    return nil
end

function AutoShot:ShootMurderer()
    if self.Shooting then return end
    
    self.Shooting = true
    
    local murderer = self:FindMurderer()
    
    if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
        local gun = LocalPlayer.Character:FindFirstChild("Gun") or 
                   (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Gun"))
        
        if gun then
            if gun.Parent == LocalPlayer.Backpack then
                LocalPlayer.Character.Humanoid:EquipTool(gun)
                wait(0.2)
            end
            
            local targetPos = murderer.Character.HumanoidRootPart.Position
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
                LocalPlayer.Character.HumanoidRootPart.Position,
                Vector3.new(targetPos.X, LocalPlayer.Character.HumanoidRootPart.Position.Y, targetPos.Z)
            )
            
            wait(0.1)
            
            local gunEvent = game:GetService("ReplicatedStorage"):FindFirstChild("GunEvent")
            if gunEvent then
                gunEvent:FireServer(murderer)
                Window.SendNotification("Normal", "Murderer'a ateş edildi: " .. murderer.Name, 3)
            end
        else
            Window.SendNotification("Error", "Silah bulunamadı!", 3)
        end
    else
        Window.SendNotification("Warning", "Murderer bulunamadı!", 3)
    end
    
    self.Shooting = false
end

function AutoShot:Toggle(state)
    self.Enabled = state
    if state then
        self:CreateFireButton()
        Window.SendNotification("Normal", "Auto Shot aktif - Ateş butonu görünür", 5)
    elseif self.FireButton then
        self.FireButton:Destroy()
        self.FireButton = nil
    end
end

-- Auto Grabber Sistemi
local AutoGrabber = {
    Enabled = false,
    Collected = {},
    GrabLoop = nil,
    WeaponNames = {"Knife", "Gun", "Sword", "Bat", "Revolver", "Hammer", "CandyCane"}
}

function AutoGrabber:StartGrabbing()
    self.GrabLoop = RunService.Heartbeat:Connect(function()
        if not self.Enabled then return end
        
        for _, weapon in ipairs(Workspace:GetChildren()) do
            if table.find(self.WeaponNames, weapon.Name) and not self.Collected[weapon] then
                local pickupEvent = game:GetService("ReplicatedStorage"):FindFirstChild("PickupEvent")
                if pickupEvent then
                    pickupEvent:FireServer(weapon)
                    self.Collected[weapon] = true
                end
            end
        end
        
        for weapon, _ in pairs(self.Collected) do
            if not weapon or not weapon.Parent then
                self.Collected[weapon] = nil
            end
        end
    end)
end

function AutoGrabber:StopGrabbing()
    if self.GrabLoop then
        self.GrabLoop:Disconnect()
        self.GrabLoop = nil
    end
    self.Collected = {}
end

function AutoGrabber:Toggle(state)
    self.Enabled = state
    if state then
        self:StartGrabbing()
        Window.SendNotification("Normal", "Auto Grabber aktif - Silahlar toplanıyor", 5)
    else
        self:StopGrabbing()
    end
end

-- Combat Sistemleri
local Combat = {
    WalkSpeed = 16,
    JumpPower = 50
}

function Combat:KillAll()
    local meleeEvent = game:GetService("ReplicatedStorage"):WaitForChild("MeleeEvent")
    local killed = 0
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            meleeEvent:FireServer(player)
            killed = killed + 1
            task.wait(0.1)
        end
    end
    Window.SendNotification("Normal", killed .. " oyuncu öldürüldü", 5)
end

function Combat:KillMurderer()
    local meleeEvent = game:GetService("ReplicatedStorage"):WaitForChild("MeleeEvent")
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and (player.Character:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife")) then
            meleeEvent:FireServer(player)
            Window.SendNotification("Normal", "Murderer öldürüldü: " .. player.Name, 5)
            return
        end
    end
    Window.SendNotification("Warning", "Murderer bulunamadı!", 3)
end

-- Teleport Sistemi
local Teleport = {
    Locations = {
        Lobby = CFrame.new(-108.5, 145, 0.6)
    }
}

function Teleport:ToPlayer(playerName)
    local target = Players:FindFirstChild(playerName)
    if target and target.Character then
        LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        Window.SendNotification("Normal", playerName .. " oyuncusuna ışınlandı", 3)
    else
        Window.SendNotification("Error", "Oyuncu bulunamadı!", 3)
    end
end

function Teleport:ToMurderer()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and (player.Character:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife")) then
            LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
            Window.SendNotification("Normal", "Murderer'a ışınlandı: " .. player.Name, 3)
            return
        end
    end
    Window.SendNotification("Warning", "Murderer bulunamadı!", 3)
end

function Teleport:ToSheriff()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and (player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun")) then
            LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
            Window.SendNotification("Normal", "Sheriff'e ışınlandı: " .. player.Name, 3)
            return
        end
    end
    Window.SendNotification("Warning", "Sheriff bulunamadı!", 3)
end

-- // UI Main \\ --
local MainTab = Window:Tab("Main")
local VisualsTab = Window:Tab("Visuals")
local TeleportTab = Window:Tab("Teleport")
local PlayerTab = Window:Tab("Player")

-- MAIN TAB
local MainSection = MainTab:Section("Combat", "Left")

MainSection:Toggle({
    Title = "Auto Shot Murderer", 
    Flag = "AutoShotToggle",
    Type = "Dangerous",
    Callback = function(v)
        AutoShot:Toggle(v)
    end
})

MainSection:Toggle({
    Title = "Auto Grabber", 
    Flag = "AutoGrabberToggle",
    Callback = function(v)
        AutoGrabber:Toggle(v)
    end
})

MainSection:Button({
    Title = "Kill All",
    Callback = function()
        Combat:KillAll()
    end
})

MainSection:Button({
    Title = "Kill Murderer",
    Callback = function()
        Combat:KillMurderer()
    end
})

-- VISUALS TAB
local VisualsSection = VisualsTab:Section("ESP", "Left")

VisualsSection:Toggle({
    Title = "ESP", 
    Flag = "ESPToggle",
    Callback = function(v)
        ESP:Toggle(v)
    end
}):Keybind({
    Title = "ESP Keybind",
    Flag = "ESPKeybind", 
    Key = Enum.KeyCode.F1, 
    StateType = "Toggle"
})

VisualsSection:Toggle({
    Title = "Show Distance", 
    Flag = "ShowDistance",
    Default = true,
    Callback = function(v)
        -- Mesafe gösterimi ESP içinde entegre
    end
})

-- TELEPORT TAB
local TeleportSection = TeleportTab:Section("Locations", "Left")

TeleportSection:Button({
    Title = "Teleport to Lobby",
    Callback = function()
        if LocalPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = Teleport.Locations.Lobby
            Window.SendNotification("Normal", "Lobby'ye ışınlandı", 3)
        end
    end
})

TeleportSection:Button({
    Title = "Teleport to Murderer",
    Callback = function()
        Teleport:ToMurderer()
    end
})

TeleportSection:Button({
    Title = "Teleport to Sheriff",
    Callback = function()
        Teleport:ToSheriff()
    end
})

local TeleportPlayerSection = TeleportTab:Section("Player Teleport", "Right")

TeleportPlayerSection:Dropdown({
    Title = "Teleport to Player", 
    List = (function()
        local playerList = {}
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                table.insert(playerList, player.Name)
            end
        end
        return playerList
    end)(), 
    Default = "",
    Flag = "PlayerTeleport",
    Callback = function(v)
        if v and v ~= "" then
            Teleport:ToPlayer(v)
        end
    end
})

-- PLAYER TAB
local PlayerSection = PlayerTab:Section("Movement", "Left")

PlayerSection:Slider({
    Title = "Walk Speed", 
    Flag = "WalkSpeed", 
    Symbol = "", 
    Default = 16, 
    Min = 16, 
    Max = 100, 
    Decimals = 0,
    Callback = function(v)
        Combat.WalkSpeed = v
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = v
        end
    end
})

PlayerSection:Slider({
    Title = "Jump Power", 
    Flag = "JumpPower", 
    Symbol = "", 
    Default = 50, 
    Min = 50, 
    Max = 200, 
    Decimals = 0,
    Callback = function(v)
        Combat.JumpPower = v
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = v
        end
    end
})

-- Karakter değişikliklerini dinle
LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid").WalkSpeed = Combat.WalkSpeed
    character.Humanoid.JumpPower = Combat.JumpPower
end)

if LocalPlayer.Character then
    LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = Combat.WalkSpeed
    LocalPlayer.Character.Humanoid.JumpPower = Combat.JumpPower
end

-- Oyuncu listesini güncelle
local function updatePlayerList()
    local playerList = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerList, player.Name)
        end
    end
    Library.Flags.PlayerTeleport.List = playerList
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- Oyun kapatıldığında temizlik
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        ESP:Clear()
        AutoShot:Toggle(false)
        AutoGrabber:Toggle(false)
    end
end)

Window:AddSettingsTab()
Window:SwitchTab(MainTab)
Window.ToggleAnime(false)

LoadTime = math.floor((tick() - LoadTime) * 1000)

Window.SendNotification("Normal", "MM2 Ultimate Script yüklendi! (" .. LoadTime .. "ms)", 8)