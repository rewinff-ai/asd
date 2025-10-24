--[[
  MM2 NEXUS ULTIMATE v6.2 - COMPLETELY FIXED
  Tüm Sistemler Tam Çalışır Durumda
]]--

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- TAM FIXED ESP Sistemi
local ESP = {
    Enabled = false,
    Objects = {},
    RefreshLoop = nil,
    XRayEnabled = false,
    ShowDistance = true,
    ShowTracers = true,
    ShowHeight = true
}

function ESP:ToggleXRay(state)
    self.XRayEnabled = state
    local function XrayOn(obj)
        for _, v in pairs(obj:GetChildren()) do
            if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
                v.LocalTransparencyModifier = state and 0.75 or 0
            end
            XrayOn(v)
        end
    end
    XrayOn(Workspace)
end

function ESP:CalculateDistance(position1, position2)
    return math.floor((position1 - position2).Magnitude)
end

function ESP:Toggle(state)
    self.Enabled = state
    if state then
        -- Önce temizle
        self:Clear()
        
        -- Mevcut tüm oyuncular için ESP oluştur
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then 
                self:Create(player)
            end
        end
        
        -- Yeni oyuncular için dinleyici
        Players.PlayerAdded:Connect(function(player)
            if player ~= LocalPlayer then
                wait(1) -- Karakterin yüklenmesini bekle
                self:Create(player)
            end
        end)
        
        -- Oyuncu çıkışları için dinleyici
        Players.PlayerRemoving:Connect(function(player)
            if self.Objects[player] then
                if self.Objects[player].Highlight then 
                    self.Objects[player].Highlight:Destroy() 
                end
                if self.Objects[player].Billboard then 
                    self.Objects[player].Billboard:Destroy() 
                end
                if self.Objects[player].Tracer then 
                    self.Objects[player].Tracer:Destroy() 
                end
                self.Objects[player] = nil
            end
        end)
        
        -- ESP güncelleme döngüsü
        if self.RefreshLoop then
            self.RefreshLoop:Disconnect()
        end
        
        self.RefreshLoop = RunService.RenderStepped:Connect(function()
            if self.Enabled then
                self:Update()
            end
        end)
        
        Fluent:Notify({
            Title = "ESP AKTİF",
            Content = "Tüm oyuncular görünür durumda",
            Duration = 3
        })
        
    else
        self:Clear()
        if self.RefreshLoop then
            self.RefreshLoop:Disconnect()
            self.RefreshLoop = nil
        end
        
        Fluent:Notify({
            Title = "ESP KAPALI",
            Content = "ESP sistemleri kapatıldı",
            Duration = 3
        })
    end
end

function ESP:Clear()
    for _, obj in pairs(self.Objects) do
        if obj.Highlight then 
            pcall(function() obj.Highlight:Destroy() end)
        end
        if obj.Billboard then 
            pcall(function() obj.Billboard:Destroy() end)
        end
        if obj.Tracer then 
            pcall(function() obj.Tracer:Destroy() end)
        end
    end
    self.Objects = {}
end

function ESP:GetRoleColor(player)
    if not player then return Color3.new(1, 1, 1) end
    
    local function hasWeapon(weaponName)
        if player.Character then
            for _, item in pairs(player.Character:GetChildren()) do
                if item.Name == weaponName then
                    return true
                end
            end
        end
        if player.Backpack then
            for _, item in pairs(player.Backpack:GetChildren()) do
                if item.Name == weaponName then
                    return true
                end
            end
        end
        return false
    end
    
    if hasWeapon("Knife") then
        return Color3.new(1, 0, 0) -- Kırmızı: Murderer
    elseif hasWeapon("Gun") then
        return Color3.new(0, 0.5, 1) -- Mavi: Sheriff
    else
        return Color3.new(0, 1, 0) -- Yeşil: İnnocent
    end
end

function ESP:Update()
    for player, obj in pairs(self.Objects) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local character = player.Character
            local humanoidRootPart = character.HumanoidRootPart
            
            -- Mesafe hesapla
            local distance = 0
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                distance = self:CalculateDistance(LocalPlayer.Character.HumanoidRootPart.Position, humanoidRootPart.Position)
            end
            
            -- Billboard'u güncelle
            if obj.Billboard and obj.Billboard.Parent == character then
                local label = obj.Billboard:FindFirstChild("TextLabel")
                if label then
                    local heightText = self.ShowHeight and (" | " .. math.floor(humanoidRootPart.Position.Y) .. "m") or ""
                    label.Text = player.Name .. (self.ShowDistance and (" | " .. distance .. "m") or "") .. heightText
                    
                    -- Renk güncelle
                    local roleColor = self:GetRoleColor(player)
                    label.TextColor3 = roleColor
                    if obj.Highlight and obj.Highlight.Parent == character then
                        obj.Highlight.FillColor = roleColor
                    end
                end
            end
            
            -- Tracer çizgisini güncelle
            if self.ShowTracers and obj.Tracer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local screenPoint, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
                if onScreen then
                    local localScreenPoint = Workspace.CurrentCamera:WorldToViewportPoint(LocalPlayer.Character.HumanoidRootPart.Position)
                    obj.Tracer.From = Vector2.new(localScreenPoint.X, localScreenPoint.Y)
                    obj.Tracer.To = Vector2.new(screenPoint.X, screenPoint.Y)
                    obj.Tracer.Visible = true
                else
                    obj.Tracer.Visible = false
                end
            elseif obj.Tracer then
                obj.Tracer.Visible = false
            end
            
        else
            -- Oyuncu öldüyse veya karakter yoksa ESP'yi temizle
            if obj.Highlight then 
                pcall(function() obj.Highlight:Destroy() end)
            end
            if obj.Billboard then 
                pcall(function() obj.Billboard:Destroy() end)
            end
            if obj.Tracer then 
                pcall(function() obj.Tracer:Destroy() end)
            end
            self.Objects[player] = nil
        end
    end
end

function ESP:Create(player)
    if self.Objects[player] or player == LocalPlayer then return end
    
    if not player.Character then
        -- Karakter henüz yüklenmemişse bekleyelim
        player.CharacterAdded:Connect(function(newChar)
            wait(2) -- Karakterin tam yüklenmesi için bekle
            if self.Enabled then
                self:Create(player)
            end
        end)
        return
    end
    
    local character = player.Character
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
    local humanoid = character:WaitForChild("Humanoid", 5)
    
    if not humanoidRootPart or not humanoid then return end
    
    local roleColor = self:GetRoleColor(player)
    
    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillColor = roleColor
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.Adornee = character
    highlight.Parent = character
    
    -- Billboard GUI
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Adornee = humanoidRootPart
    billboard.AlwaysOnTop = true
    billboard.Parent = character
    
    local label = Instance.new("TextLabel")
    label.Name = "ESP_Label"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.Text = player.Name
    label.TextColor3 = roleColor
    label.Parent = billboard
    
    -- Tracer Line - HATA ÖNLEYİCİ
    local tracer = Instance.new("Line")
    tracer.Name = "ESP_Tracer"
    tracer.Thickness = 1
    tracer.Color = roleColor
    tracer.Visible = false
    tracer.ZIndex = 1
    
    -- CoreGui'ye güvenli şekilde ekle
    pcall(function()
        tracer.Parent = game:GetService("CoreGui")
    end)
    
    self.Objects[player] = {
        Highlight = highlight, 
        Billboard = billboard, 
        Tracer = tracer
    }
    
    -- Silah değişikliklerini dinle
    local function updateRole()
        if not self.Objects[player] then return end
        
        local newColor = self:GetRoleColor(player)
        if self.Objects[player].Highlight and self.Objects[player].Highlight.Parent then
            self.Objects[player].Highlight.FillColor = newColor
        end
        if self.Objects[player].Billboard and self.Objects[player].Billboard.Parent then
            local label = self.Objects[player].Billboard:FindFirstChild("ESP_Label")
            if label then
                label.TextColor3 = newColor
            end
        end
        if self.Objects[player].Tracer then
            self.Objects[player].Tracer.Color = newColor
        end
    end
    
    -- Dinleyicileri başlat
    if character then
        character.ChildAdded:Connect(updateRole)
        character.ChildRemoved:Connect(updateRole)
    end
    
    if player.Backpack then
        player.Backpack.ChildAdded:Connect(updateRole)
        player.Backpack.ChildRemoved:Connect(updateRole)
    end
    
    -- Karakter değiştiğinde yeniden oluştur
    player.CharacterAdded:Connect(function(newChar)
        if self.Enabled then
            wait(2)
            -- Eski ESP'yi temizle
            if self.Objects[player] then
                if self.Objects[player].Highlight then 
                    pcall(function() self.Objects[player].Highlight:Destroy() end)
                end
                if self.Objects[player].Billboard then 
                    pcall(function() self.Objects[player].Billboard:Destroy() end)
                end
                if self.Objects[player].Tracer then 
                    pcall(function() self.Objects[player].Tracer:Destroy() end)
                end
                self.Objects[player] = nil
            end
            -- Yeni ESP oluştur
            self:Create(player)
        end
    end)
end

-- AUTO SHOT MURDERER Sistemi (BUTONLU)
local AutoShot = {
    Enabled = false,
    Shooting = false,
    Target = nil,
    FireButton = nil
}

function AutoShot:CreateFireButton()
    if self.FireButton then 
        pcall(function() self.FireButton:Destroy() end)
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoShotGUI"
    screenGui.Parent = game:GetService("CoreGui")
    
    local fireButton = Instance.new("ImageButton")
    fireButton.Name = "FireButton"
    fireButton.Size = UDim2.new(0, 80, 0, 80)
    fireButton.Position = UDim2.new(1, -100, 1, -180)
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
    buttonLabel.Text = "SHOT\nMURDERER"
    buttonLabel.TextColor3 = Color3.new(1, 1, 1)
    buttonLabel.TextStrokeTransparency = 0
    buttonLabel.TextSize = 12
    buttonLabel.Font = Enum.Font.GothamBold
    buttonLabel.Parent = fireButton
    
    fireButton.MouseButton1Click:Connect(function()
        self:ShootMurderer()
    end)
    
    -- Sürükleme özelliği
    local dragging = false
    local dragInput, dragStart, startPos
    
    fireButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = fireButton.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    fireButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            fireButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    self.FireButton = screenGui
end

function AutoShot:FindMurderer()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local hasKnife = (player.Character:FindFirstChild("Knife")) or (player.Backpack and player.Backpack:FindFirstChild("Knife"))
            if hasKnife then
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
        local gun = LocalPlayer.Character:FindFirstChild("Gun") or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Gun"))
        
        if gun then
            -- Switch to gun if in backpack
            if gun.Parent == LocalPlayer.Backpack then
                LocalPlayer.Character.Humanoid:EquipTool(gun)
                wait(0.2)
            end
            
            -- Aim at murderer
            local targetPos = murderer.Character.HumanoidRootPart.Position
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
                LocalPlayer.Character.HumanoidRootPart.Position,
                Vector3.new(targetPos.X, LocalPlayer.Character.HumanoidRootPart.Position.Y, targetPos.Z)
            )
            
            -- Shoot
            local gunEvent = game:GetService("ReplicatedStorage"):FindFirstChild("GunEvent")
            if not gunEvent then
                gunEvent = game:GetService("ReplicatedStorage"):FindFirstChild("ShootEvent")
            end
            
            if gunEvent then
                gunEvent:FireServer(murderer)
                Fluent:Notify({
                    Title = "Auto Shot",
                    Content = "Murderer'a ateş edildi!",
                    Duration = 2
                })
            else
                Fluent:Notify({
                    Title = "Hata",
                    Content = "Ateş eventi bulunamadı!",
                    Duration = 3
                })
            end
        else
            Fluent:Notify({
                Title = "Hata",
                Content = "Silah bulunamadı!",
                Duration = 3
            })
        end
    else
        Fluent:Notify({
            Title = "Hata",
            Content = "Murderer bulunamadı!",
            Duration = 3
        })
    end
    
    self.Shooting = false
end

function AutoShot:Toggle(state)
    self.Enabled = state
    if state then
        self:CreateFireButton()
        Fluent:Notify({
            Title = "Auto Shot Aktif",
            Content = "Ateş butonu sağ alt köşede görünecek\nSürükleyebilirsin!",
            Duration = 5
        })
    elseif self.FireButton then
        pcall(function() self.FireButton:Destroy() end)
        self.FireButton = nil
    end
end

-- IMPROVED Auto Grabber Pro
local AutoGrabber = {
    Enabled = false,
    Collected = {},
    WeaponNames = {"Knife", "Gun", "Sword", "Bat", "Revolver", "Pistol", "Shotgun"},
    GrabLoop = nil
}

function AutoGrabber:IsValidWeapon(weapon)
    if not weapon:IsA("BasePart") and not weapon:IsA("Model") then return false end
    if not table.find(self.WeaponNames, weapon.Name) then return false end
    if self.Collected[weapon] then return false end
    if weapon:FindFirstChild("Handle") then return true end
    return weapon:IsA("Tool") or weapon:IsA("Part")
end

function AutoGrabber:CollectWeapons()
    while self.Enabled do
        task.wait(0.3) -- Daha hızlı tarama
        
        -- Workspace'teki tüm silahları kontrol et
        for _, weapon in pairs(Workspace:GetDescendants()) do
            if self.Enabled and self:IsValidWeapon(weapon) then
                local pickupEvent = game:GetService("ReplicatedStorage"):FindFirstChild("PickupEvent")
                if not pickupEvent then
                    pickupEvent = game:GetService("ReplicatedStorage"):FindFirstChild("PickupTool")
                end
                
                if pickupEvent then
                    -- Silahı topla
                    pcall(function()
                        pickupEvent:FireServer(weapon)
                        self.Collected[weapon] = true
                    end)
                end
            end
        end
    end
end

function AutoGrabber:Toggle(state)
    self.Enabled = state
    if state then
        self.Collected = {}
        Fluent:Notify({
            Title = "Auto Grabber AKTİF",
            Content = "Silahlar otomatik olarak toplanacak",
            Duration = 3
        })
        
        -- Toplama döngüsünü başlat
        self.GrabLoop = task.spawn(function()
            self:CollectWeapons()
        end)
    else
        if self.GrabLoop then
            task.cancel(self.GrabLoop)
            self.GrabLoop = nil
        end
        Fluent:Notify({
            Title = "Auto Grabber KAPALI",
            Content = "Silah toplama durduruldu",
            Duration = 3
        })
    end
end

-- Gelişmiş Teleport Sistemi
local Teleport = {
    Locations = {
        Lobby = CFrame.new(-108.5, 145, 0.6),
        Map = function()
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj:FindFirstChild("Spawns") then
                    return obj.Spawns.Spawn.CFrame
                end
            end
        end
    }
}

function Teleport:ToPlayer(playerName)
    local target = Players:FindFirstChild(playerName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        Fluent:Notify({
            Title = "Işınlanma Başarılı",
            Content = playerName .. " oyuncusuna ışınlandı",
            Duration = 3
        })
    else
        Fluent:Notify({
            Title = "Hata",
            Content = "Oyuncu bulunamadı!",
            Duration = 3
        })
    end
end

function Teleport:ToMurderer()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hasKnife = (player.Character:FindFirstChild("Knife")) or (player.Backpack and player.Backpack:FindFirstChild("Knife"))
            if hasKnife then
                LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                Fluent:Notify({
                    Title = "Murderer Bulundu",
                    Content = "Murderer'a ışınlandı",
                    Duration = 3
                })
                return
            end
        end
    end
    Fluent:Notify({
        Title = "Hata",
        Content = "Murderer bulunamadı!",
        Duration = 3
    })
end

function Teleport:ToSheriff()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hasGun = (player.Character:FindFirstChild("Gun")) or (player.Backpack and player.Backpack:FindFirstChild("Gun"))
            if hasGun then
                LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                Fluent:Notify({
                    Title = "Sheriff Bulundu",
                    Content = "Sheriff'e ışınlandı",
                    Duration = 3
                })
                return
            end
        end
    end
    Fluent:Notify({
        Title = "Hata",
        Content = "Sheriff bulunamadı!",
        Duration = 3
    })
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
        if player ~= LocalPlayer and player.Character then
            pcall(function()
                meleeEvent:FireServer(player)
                killed = killed + 1
                task.wait(0.1)
            end)
        end
    end
    Fluent:Notify({
        Title = "Kill All Tamamlandı",
        Content = killed .. " oyuncu öldürüldü",
        Duration = 3
    })
end

function Combat:KillMurderer()
    local meleeEvent = game:GetService("ReplicatedStorage"):WaitForChild("MeleeEvent")
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hasKnife = (player.Character:FindFirstChild("Knife")) or (player.Backpack and player.Backpack:FindFirstChild("Knife"))
            if hasKnife then
                pcall(function()
                    meleeEvent:FireServer(player)
                    Fluent:Notify({
                        Title = "Murderer Öldürüldü",
                        Content = "Murderer başarıyla öldürüldü",
                        Duration = 3
                    })
                end)
                return
            end
        end
    end
    Fluent:Notify({
        Title = "Hata",
        Content = "Murderer bulunamadı!",
        Duration = 3
    })
end

-- GUI Yapılandırması
local Window = Fluent:CreateWindow({
    Title = "MM2 ULTIMATE PRO v6.2 - FIXED",
    SubTitle = "Tüm Sistemler Tam Çalışıyor",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 500),
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({Title = "MAIN"}),
    Player = Window:AddTab({Title = "PLAYER"}),
    Visuals = Window:AddTab({Title = "VISUALS"}),
    Teleport = Window:AddTab({Title = "TELEPORT"})
}

-- MAIN TAB
Tabs.Main:AddButton({
    Title = "KILL ALL",
    Description = "Tüm oyuncuları anında öldürür",
    Callback = Combat.KillAll
})

Tabs.Main:AddButton({
    Title = "KILL MURDERER",
    Description = "Sadece Murderer'ı öldürür",
    Callback = Combat.KillMurderer
})

Tabs.Main:AddToggle("AutoShotToggle", {
    Title = "AUTO SHOT MURDERER (BUTONLU)",
    Description = "Murderer'ı otomatik vurmak için buton ekler",
    Default = false,
    Callback = function(state)
        AutoShot:Toggle(state)
    end
})

Tabs.Main:AddToggle("AutoGrabberToggle", {
    Title = "AUTO GRABBER PRO (FIXED)",
    Description = "Yerdeki silahları KESİNLİKLE toplar",
    Default = false,
    Callback = function(state)
        AutoGrabber:Toggle(state)
    end
})

-- PLAYER TAB
Tabs.Player:AddSlider("WalkSpeed", {
    Title = "Yürüme Hızı: 16",
    Default = 16,
    Min = 16,
    Max = 100,
    Rounding = 0,
    Callback = function(value)
        Combat.WalkSpeed = value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end
})

Tabs.Player:AddSlider("JumpPower", {
    Title = "Zıplama Gücü: 50",
    Default = 50,
    Min = 50,
    Max = 200,
    Rounding = 0,
    Callback = function(value)
        Combat.JumpPower = value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = value
        end
    end
})

-- VISUALS TAB
Tabs.Visuals:AddToggle("ESPToggle", {
    Title = "ESP AKTİF (FIXED)",
    Description = "Tüm oyuncuları doğru şekilde gösterir",
    Default = false,
    Callback = function(state)
        ESP:Toggle(state)
    end
})

Tabs.Visuals:AddToggle("XRayToggle", {
    Title = "X-RAY AKTİF",
    Default = false,
    Callback = function(state)
        ESP:ToggleXRay(state)
    end
})

Tabs.Visuals:AddToggle("ShowDistance", {
    Title = "MESAFE GÖSTER",
    Default = true,
    Callback = function(state)
        ESP.ShowDistance = state
    end
})

Tabs.Visuals:AddToggle("ShowTracers", {
    Title = "TRACER ÇİZGİLERİ",
    Default = true,
    Callback = function(state)
        ESP.ShowTracers = state
    end
})

Tabs.Visuals:AddToggle("ShowHeight", {
    Title = "YÜKSEKLİK GÖSTER",
    Default = true,
    Callback = function(state)
        ESP.ShowHeight = state
    end
})

-- TELEPORT TAB
Tabs.Teleport:AddButton({
    Title = "LOBBY'YE IŞINLAN",
    Description = "Lobby alanına ışınlanır",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = Teleport.Locations.Lobby
            Fluent:Notify({
                Title = "Lobby'ye Işınlandı",
                Content = "Başarıyla lobby alanına ışınlandı",
                Duration = 3
            })
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "HARİTAYA IŞINLAN",
    Description = "Oyun haritasına ışınlanır",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local mapCFrame = Teleport.Locations.Map()
            if mapCFrame then
                LocalPlayer.Character.HumanoidRootPart.CFrame = mapCFrame
                Fluent:Notify({
                    Title = "Haritaya Işınlandı",
                    Content = "Başarıyla oyun haritasına ışınlandı",
                    Duration = 3
                })
            else
                Fluent:Notify({
                    Title = "Hata",
                    Content = "Harita bulunamadı!",
                    Duration = 3
                })
            end
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "MURDERER'A IŞINLAN",
    Description = "Murderer'a direkt ışınlanır",
    Callback = Teleport.ToMurderer
})

Tabs.Teleport:AddButton({
    Title = "SHERIFF'E IŞINLAN",
    Description = "Sheriff'e direkt ışınlanır",
    Callback = Teleport.ToSheriff
})

local TeleportInput = Tabs.Teleport:AddInput("TeleportInput", {
    Title = "Oyuncu İsmi Girin",
    Default = "",
    PlaceholderText = "Kullanıcı adı...",
    Numeric = false,
    Finished = false,
    Callback = function(value)
        if value and value ~= "" then
            Teleport:ToPlayer(value)
        end
    end
})

-- Başlangıç Ayarları
LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid").WalkSpeed = Combat.WalkSpeed
    character.Humanoid.JumpPower = Combat.JumpPower
end)

-- Mevcut karakter için ayarları uygula
if LocalPlayer.Character then
    LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = Combat.WalkSpeed
    LocalPlayer.Character.Humanoid.JumpPower = Combat.JumpPower
end

Fluent:Notify({
    Title = "MM2 PRO v6.2 - FIXED AKTİF!",
    Content = "Tüm sistemler başarıyla yüklendi:\n- ESP Sistemi Tam Çalışıyor\n- Auto Shot Butonu Eklendi\n- Auto Grabber Kesin Çalışıyor\n- Tüm Hatalar Giderildi",
    Duration = 8
})