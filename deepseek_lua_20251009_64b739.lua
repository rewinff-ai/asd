-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local TweenService = game:GetService("TweenService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create the window
local Window = Rayfield:CreateWindow({
    Name = "Rivals Hack Suite",
    LoadingTitle = "Rivals Hack Suite",
    LoadingSubtitle = "by github.com/yourusername",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "RivalsHacks",
        FileName = "Config.json"
    },
    Discord = {
        Enabled = true,
        Invite = "discord.gg/example", -- Your Discord invite code
        RememberJoins = true
    },
    KeySystem = false, -- Set to true if you want a key system
})

-- Variables
local silentAimActive = true
local espActive = true
local healthBarActive = true
local teamCheckActive = true
local autoShootActive = false
local noClipActive = false
local unlimitedJumpActive = false
local teleportSystemActive = false
local shootDelay = 0.1 -- Default delay in seconds
local espList = {} -- Keep track of ESP drawings
local autoShootConnection = nil -- To track the auto shoot connection
local noClipConnection = nil -- To track the no clip connection
local teleportSystemConnection = nil -- To track the teleport system connection
local originalGravity = nil -- Store original gravity

-- Teleport GUI Variables
local teleportWindow = nil
local teleportTarget = nil
local originalPosition = nil

-- Function to check if player is on our team
local function isEnemy(player)
    if not teamCheckActive then return true end -- If team check is off, everyone is an enemy
    
    -- Check if game has teams
    if #Teams:GetTeams() > 0 then
        return player.Team ~= LocalPlayer.Team
    else
        -- If no teams, everyone is an enemy except ourselves
        return player ~= LocalPlayer
    end
end

-- Function to get the nearest target's head
local function getNearestHead()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if isEnemy(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end

    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
        return closestPlayer.Character.Head
    end

    return nil
end

-- Function to get all enemy players
local function getEnemyPlayers()
    local enemies = {}
    for _, player in pairs(Players:GetPlayers()) do
        if isEnemy(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(enemies, player)
        end
    end
    return enemies
end

-- Function to get random enemy
local function getRandomEnemy()
    local enemies = getEnemyPlayers()
    if #enemies > 0 then
        return enemies[math.random(1, #enemies)]
    end
    return nil
end

-- Function to simulate shooting
local function shootAtTarget()
    local targetHead = getNearestHead()
    if targetHead then
        local aimPosition = targetHead.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPosition)
        ReplicatedStorage.Remotes.Attack:FireServer(targetHead)
    end
end

-- Silent aim functionality with headshots
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and silentAimActive then
        shootAtTarget()
    end
end)

-- Auto shoot functionality
local function toggleAutoShoot(enable)
    if enable then
        if autoShootConnection then
            autoShootConnection:Disconnect()
        end
        autoShootConnection = RunService.Heartbeat:Connect(function()
            if autoShootActive then
                shootAtTarget()
                wait(shootDelay)
            end
        end)
    else
        if autoShootConnection then
            autoShootConnection:Disconnect()
            autoShootConnection = nil
        end
    end
end

-- No Clip functionality
local function toggleNoClip(enable)
    if enable then
        if noClipConnection then
            noClipConnection:Disconnect()
        end
        
        noClipConnection = RunService.Stepped:Connect(function()
            if noClipActive and LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noClipConnection then
            noClipConnection:Disconnect()
            noClipConnection = nil
        end
    end
end

-- Unlimited Jump functionality
local function toggleUnlimitedJump(enable)
    if enable then
        -- Store original gravity
        if Workspace:FindFirstChild("Gravity") then
            originalGravity = Workspace.Gravity
        end
        
        -- Make player jump higher by reducing gravity
        Workspace.Gravity = 50 -- Very low gravity for high jumps
        
        -- Alternatively, you can modify the character's jump power
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = 100
        end
        
        -- Connect to character added to apply to new characters
        LocalPlayer.CharacterAdded:Connect(function(character)
            wait(1) -- Wait for character to load
            if unlimitedJumpActive and character:FindFirstChild("Humanoid") then
                character.Humanoid.JumpPower = 100
            end
        end)
    else
        -- Restore original gravity
        if originalGravity then
            Workspace.Gravity = originalGravity
        else
            Workspace.Gravity = 196.2 -- Default Roblox gravity
        end
        
        -- Restore normal jump power
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = 50
        end
    end
end

-- Teleport System functionality (Auto teleport to different enemies)
local function toggleTeleportSystem(enable)
    if enable then
        if teleportSystemConnection then
            teleportSystemConnection:Disconnect()
        end
        
        teleportSystemConnection = RunService.Heartbeat:Connect(function()
            if teleportSystemActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local randomEnemy = getRandomEnemy()
                if randomEnemy and randomEnemy.Character and randomEnemy.Character:FindFirstChild("HumanoidRootPart") then
                    -- Store original position if not already stored
                    if not originalPosition then
                        originalPosition = LocalPlayer.Character.HumanoidRootPart.Position
                    end
                    
                    -- Calculate position behind enemy (closer position)
                    local targetCFrame = randomEnemy.Character.HumanoidRootPart.CFrame
                    local behindPosition = targetCFrame.Position - targetCFrame.LookVector * 3 -- 3 studs behind
                    
                    -- Teleport behind enemy
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(behindPosition)
                    
                    -- Wait a bit
                    wait(0.5)
                    
                    -- Teleport back to original position
                    if originalPosition then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(originalPosition)
                    end
                    
                    -- Wait before next teleport
                    wait(0.5)
                end
            end
        end)
    else
        if teleportSystemConnection then
            teleportSystemConnection:Disconnect()
            teleportSystemConnection = nil
        end
        originalPosition = nil
    end
end

-- Manual Teleport GUI functionality
local function createTeleportGUI()
    if teleportWindow then
        teleportWindow:Destroy()
        teleportWindow = nil
    end
    
    -- Create small teleport window
    teleportWindow = Rayfield:CreateWindow({
        Name = "Quick Teleport",
        LoadingTitle = "Quick Teleport",
        LoadingSubtitle = "Teleport behind players",
        ConfigurationSaving = {
            Enabled = false,
        }
    })
    
    local TeleportTab = teleportWindow:CreateTab("Teleport", 4483362458)
    
    -- Create player list
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isEnemy(player) then
            TeleportTab:CreateButton({
                Name = "Teleport: " .. player.Name,
                Callback = function()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and 
                       LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        
                        -- Store original position
                        originalPosition = LocalPlayer.Character.HumanoidRootPart.Position
                        
                        -- Calculate position behind player (closer)
                        local targetCFrame = player.Character.HumanoidRootPart.CFrame
                        local behindPosition = targetCFrame.Position - targetCFrame.LookVector * 3
                        
                        -- Teleport behind player
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(behindPosition)
                        
                        teleportTarget = player
                        
                        Rayfield:Notify({
                            Title = "Teleport Success",
                            Content = "Teleported behind " .. player.Name .. " for 2 seconds",
                            Duration = 2,
                            Image = 4483362458,
                        })
                        
                        -- Wait 2 seconds then teleport back
                        wait(2)
                        
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and originalPosition then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(originalPosition)
                            
                            Rayfield:Notify({
                                Title = "Teleport Complete",
                                Content = "Returned to original position",
                                Duration = 2,
                                Image = 4483362458,
                            })
                        end
                        
                        teleportTarget = nil
                        originalPosition = nil
                    else
                        Rayfield:Notify({
                            Title = "Teleport Failed",
                            Content = "Character not found",
                            Duration = 2,
                            Image = 4483362458,
                        })
                    end
                end,
            })
        end
    end
    
    -- Refresh button to update player list
    TeleportTab:CreateButton({
        Name = "Refresh List",
        Callback = function()
            createTeleportGUI()
        end,
    })
    
    -- Close button
    TeleportTab:CreateButton({
        Name = "Close",
        Callback = function()
            if teleportWindow then
                teleportWindow:Destroy()
                teleportWindow = nil
            end
        end,
    })
end

-- ESP Function for a player
local function createESP(player)
    if player ~= LocalPlayer then
        -- Main ESP Box
        local espBox = Drawing.new("Quad")
        espBox.Thickness = 2
        espBox.Color = Color3.fromRGB(0, 0, 255) -- Blue color for ESP
        espBox.Transparency = 1
        espBox.Visible = espActive
        
        -- Health bar background
        local healthBarBG = Drawing.new("Quad")
        healthBarBG.Thickness = 1
        healthBarBG.Color = Color3.fromRGB(50, 50, 50)
        healthBarBG.Transparency = 1
        healthBarBG.Visible = healthBarActive and espActive
        
        -- Health bar fill
        local healthBar = Drawing.new("Quad")
        healthBar.Thickness = 1
        healthBar.Color = Color3.fromRGB(0, 255, 0)
        healthBar.Transparency = 1
        healthBar.Visible = healthBarActive and espActive
        
        -- Player name text
        local nameText = Drawing.new("Text")
        nameText.Text = player.Name
        nameText.Color = Color3.fromRGB(255, 255, 255)
        nameText.Size = 13
        nameText.Outline = true
        nameText.Visible = espActive
        
        -- Health text
        local healthText = Drawing.new("Text")
        healthText.Color = Color3.fromRGB(255, 255, 255)
        healthText.Size = 12
        healthText.Outline = true
        healthText.Visible = healthBarActive and espActive
        
        espList[player.Name] = {
            box = espBox,
            healthBarBG = healthBarBG,
            healthBar = healthBar,
            nameText = nameText,
            healthText = healthText,
            player = player
        }

        local connection
        connection = RunService.RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                local rootPart = player.Character.HumanoidRootPart
                local head = player.Character:FindFirstChild("Head")
                local humanoid = player.Character.Humanoid
                
                if rootPart and head then
                    local rootPos, rootVisible = Camera:WorldToViewportPoint(rootPart.Position)
                    local headPos, headVisible = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    
                    if rootVisible and headVisible then
                        -- Calculate health percentage
                        local healthPerc = humanoid.Health / humanoid.MaxHealth
                        local healthColor = Color3.fromRGB(255 * (1 - healthPerc), 255 * healthPerc, 0)
                        
                        -- ESP Box
                        espBox.PointA = Vector2.new(rootPos.X - 15, rootPos.Y + 30)
                        espBox.PointB = Vector2.new(rootPos.X + 15, rootPos.Y + 30)
                        espBox.PointC = Vector2.new(headPos.X + 15, headPos.Y)
                        espBox.PointD = Vector2.new(headPos.X - 15, headPos.Y)
                        espBox.Visible = espActive
                        espBox.Color = isEnemy(player) and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                        
                        -- Name text
                        nameText.Position = Vector2.new(headPos.X, headPos.Y - 25)
                        nameText.Visible = espActive
                        
                        if healthBarActive and espActive then
                            -- Health bar background (left side)
                            local barWidth = 3
                            local barLength = 30
                            local barOffset = 20
                            
                            healthBarBG.PointA = Vector2.new(rootPos.X - barOffset, rootPos.Y + 30)
                            healthBarBG.PointB = Vector2.new(rootPos.X - barOffset - barWidth, rootPos.Y + 30)
                            healthBarBG.PointC = Vector2.new(rootPos.X - barOffset - barWidth, rootPos.Y + 30 - barLength)
                            healthBarBG.PointD = Vector2.new(rootPos.X - barOffset, rootPos.Y + 30 - barLength)
                            healthBarBG.Visible = true
                            
                            -- Health bar fill
                            local fillLength = barLength * healthPerc
                            healthBar.PointA = Vector2.new(rootPos.X - barOffset, rootPos.Y + 30)
                            healthBar.PointB = Vector2.new(rootPos.X - barOffset - barWidth, rootPos.Y + 30)
                            healthBar.PointC = Vector2.new(rootPos.X - barOffset - barWidth, rootPos.Y + 30 - fillLength)
                            healthBar.PointD = Vector2.new(rootPos.X - barOffset, rootPos.Y + 30 - fillLength)
                            healthBar.Color = healthColor
                            healthBar.Visible = true
                            
                            -- Health text
                            healthText.Text = math.floor(humanoid.Health).."/"..math.floor(humanoid.MaxHealth)
                            healthText.Position = Vector2.new(rootPos.X - barOffset - 25, rootPos.Y + 30 - barLength/2 - 6)
                            healthText.Visible = true
                        else
                            healthBarBG.Visible = false
                            healthBar.Visible = false
                            healthText.Visible = false
                        end
                    else
                        espBox.Visible = false
                        nameText.Visible = false
                        healthBarBG.Visible = false
                        healthBar.Visible = false
                        healthText.Visible = false
                    end
                else
                    espBox.Visible = false
                    nameText.Visible = false
                    healthBarBG.Visible = false
                    healthBar.Visible = false
                    healthText.Visible = false
                end
            else
                espBox.Visible = false
                nameText.Visible = false
                healthBarBG.Visible = false
                healthBar.Visible = false
                healthText.Visible = false
            end
        end)

        -- Clean up when player leaves
        player:GetPropertyChangedSignal("Parent"):Connect(function()
            if not player.Parent then
                if espList[player.Name] then
                    for _, drawing in pairs(espList[player.Name]) do
                        if typeof(drawing) == "userdata" and drawing.Remove then
                            drawing:Remove()
                        end
                    end
                    espList[player.Name] = nil
                end
                if connection then
                    connection:Disconnect()
                end
            end
        end)
    end
end

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    createESP(player)
end

Players.PlayerAdded:Connect(function(player)
    createESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    if espList[player.Name] then
        for _, drawing in pairs(espList[player.Name]) do
            if typeof(drawing) == "userdata" and drawing.Remove then
                drawing:Remove()
            end
        end
        espList[player.Name] = nil
    end
end)

-- Create the main tab
local MainTab = Window:CreateTab("Main", 4483362458) -- Replace with your preferred icon ID

-- Create toggle for Silent Aim
local SilentAimToggle = MainTab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = silentAimActive,
    Flag = "SilentAimToggle",
    Callback = function(Value)
        silentAimActive = Value
        Rayfield:Notify({
            Title = "Silent Aim",
            Content = Value and "Enabled" or "Disabled",
            Duration = 1.5,
            Image = 4483362458,
            Actions = {
                Ignore = {
                    Name = "Okay",
                    Callback = function()
                    end
                },
            },
        })
    end,
})

-- Create toggle for ESP
local ESPToggle = MainTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = espActive,
    Flag = "ESPToggle",
    Callback = function(Value)
        espActive = Value
        -- Update all ESP elements
        for _, espData in pairs(espList) do
            espData.box.Visible = Value
            espData.nameText.Visible = Value
            -- Only show health bars if both ESP and health bars are enabled
            local showHealth = Value and healthBarActive
            espData.healthBarBG.Visible = showHealth
            espData.healthBar.Visible = showHealth
            espData.healthText.Visible = showHealth
        end
        Rayfield:Notify({
            Title = "Player ESP",
            Content = Value and "Enabled" or "Disabled",
            Duration = 1.5,
            Image = 4483362458,
            Actions = {
                Ignore = {
                    Name = "Okay",
                    Callback = function()
                    end
                },
            },
        })
    end,
})

-- Create toggle for Team Check
local TeamCheckToggle = MainTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = teamCheckActive,
    Flag = "TeamCheckToggle",
    Callback = function(Value)
        teamCheckActive = Value
        -- Update ESP colors based on team status
        for _, espData in pairs(espList) do
            espData.box.Color = isEnemy(espData.player) and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
        end
        Rayfield:Notify({
            Title = "Team Check",
            Content = Value and "Enabled" or "Disabled",
            Duration = 1.5,
            Image = 4483362458,
            Actions = {
                Ignore = {
                    Name = "Okay",
                    Callback = function()
                    end
                },
            },
        })
    end,
})

-- Create toggle for Health Bars
local HealthBarToggle = MainTab:CreateToggle({
    Name = "Health Bars",
    CurrentValue = healthBarActive,
    Flag = "HealthBarToggle",
    Callback = function(Value)
        healthBarActive = Value
        -- Update all health bars only if ESP is also enabled
        local showHealth = Value and espActive
        for _, espData in pairs(espList) do
            espData.healthBarBG.Visible = showHealth
            espData.healthBar.Visible = showHealth
            espData.healthText.Visible = showHealth
        end
        Rayfield:Notify({
            Title = "Health Bars",
            Content = Value and "Enabled" or "Disabled",
            Duration = 1.5,
            Image = 4483362458,
            Actions = {
                Ignore = {
                    Name = "Okay",
                    Callback = function()
                    end
                },
            },
        })
    end,
})

-- Create toggle for Auto Shoot
local AutoShootToggle = MainTab:CreateToggle({
    Name = "Auto Shoot",
    CurrentValue = autoShootActive,
    Flag = "AutoShootToggle",
    Callback = function(Value)
        autoShootActive = Value
        toggleAutoShoot(Value)
        Rayfield:Notify({
            Title = "Auto Shoot",
            Content = Value and "Enabled" or "Disabled",
            Duration = 1.5,
            Image = 4483362458,
            Actions = {
                Ignore = {
                    Name = "Okay",
                    Callback = function()
                    end
                },
            },
        })
    end,
})

-- Create slider for Auto Shoot Delay
local AutoShootDelaySlider = MainTab:CreateSlider({
    Name = "Auto Shoot Delay",
    Range = {0.05, 1},
    Increment = 0.05,
    Suffix = "s",
    CurrentValue = shootDelay,
    Flag = "AutoShootDelay",
    Callback = function(Value)
        shootDelay = Value
    end,
})

-- Create toggle for No Clip
local NoClipToggle = MainTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = noClipActive,
    Flag = "NoClipToggle",
    Callback = function(Value)
        noClipActive = Value
        toggleNoClip(Value)
        Rayfield:Notify({
            Title = "No Clip",
            Content = Value and "Enabled" or "Disabled",
            Duration = 1.5,
            Image = 4483362458,
            Actions = {
                Ignore = {
                    Name = "Okay",
                    Callback = function()
                    end
                },
            },
        })
    end,
})

-- Create toggle for Unlimited Jump
local UnlimitedJumpToggle = MainTab:CreateToggle({
    Name = "Unlimited Jump",
    CurrentValue = unlimitedJumpActive,
    Flag = "UnlimitedJumpToggle",
    Callback = function(Value)
        unlimitedJumpActive = Value
        toggleUnlimitedJump(Value)
        Rayfield:Notify({
            Title = "Unlimited Jump",
            Content = Value and "Enabled" or "Disabled",
            Duration = 1.5,
            Image = 4483362458,
            Actions = {
                Ignore = {
                    Name = "Okay",
                    Callback = function()
                    end
                },
            },
        })
    end,
})

-- Create toggle for Teleport System (Auto)
local TeleportSystemToggle = MainTab:CreateToggle({
    Name = "Teleport System",
    CurrentValue = teleportSystemActive,
    Flag = "TeleportSystemToggle",
    Callback = function(Value)
        teleportSystemActive = Value
        toggleTeleportSystem(Value)
        Rayfield:Notify({
            Title = "Teleport System",
            Content = Value and "Enabled" or "Disabled",
            Duration = 1.5,
            Image = 4483362458,
            Actions = {
                Ignore = {
                    Name = "Okay",
                    Callback = function()
                    end
                },
            },
        })
    end,
})

-- Create button for Manual Teleport GUI
MainTab:CreateButton({
    Name = "Open Teleport GUI",
    Callback = function()
        createTeleportGUI()
        Rayfield:Notify({
            Title = "Teleport GUI",
            Content = "Teleport window opened",
            Duration = 1.5,
            Image = 4483362458,
        })
    end,
})

-- Create a button to refresh ESP (in case of issues)
MainTab:CreateButton({
    Name = "Refresh ESP",
    Callback = function()
        -- Clean up existing ESP
        for _, espData in pairs(espList) do
            for _, drawing in pairs(espData) do
                if typeof(drawing) == "userdata" and drawing.Remove then
                    drawing:Remove()
                end
            end
        end
        espList = {}
        
        -- Recreate ESP for all players
        for _, player in pairs(Players:GetPlayers()) do
            createESP(player)
        end
        
        Rayfield:Notify({
            Title = "ESP Refreshed",
            Content = "All ESP elements have been refreshed",
            Duration = 1.5,
            Image = 4483362458,
            Actions = {
                Ignore = {
                    Name = "Okay",
                    Callback = function()
                    end
                },
            },
        })
    end,
})

-- Create a section for visual customization
local VisualsTab = Window:CreateTab("Visuals", 4483362458) -- Replace with your preferred icon ID

-- Color picker for ESP color
VisualsTab:CreateColorPicker({
    Name = "Enemy ESP Color",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "EnemyESPColor",
    Callback = function(Value)
        for _, espData in pairs(espList) do
            if isEnemy(espData.player) then
                espData.box.Color = Value
            end
        end
    end
})

-- Color picker for Team ESP color
VisualsTab:CreateColorPicker({
    Name = "Team ESP Color",
    Color = Color3.fromRGB(0, 255, 0),
    Flag = "TeamESPColor",
    Callback = function(Value)
        for _, espData in pairs(espList) do
            if not isEnemy(espData.player) then
                espData.box.Color = Value
            end
        end
    end
})

-- Slider for ESP thickness
VisualsTab:CreateSlider({
    Name = "ESP Thickness",
    Range = {1, 5},
    Increment = 1,
    Suffix = "px",
    CurrentValue = 2,
    Flag = "ESPThickness",
    Callback = function(Value)
        for _, espData in pairs(espList) do
            espData.box.Thickness = Value
        end
    end,
})

-- Create an info tab
local InfoTab = Window:CreateTab("Info", 4483362458) -- Replace with your preferred icon ID

InfoTab:CreateLabel("Rivals Hack Suite v1.4")
InfoTab:CreateLabel("Created by github.com/yourusername")
InfoTab:CreateLabel("Features:")
InfoTab:CreateLabel("- Silent Aim (Headshots)")
InfoTab:CreateLabel("- Player ESP (Boxes)")
InfoTab:CreateLabel("- Health Bars")
InfoTab:CreateLabel("- Team Check")
InfoTab:CreateLabel("- Auto Shoot (Adjustable Delay)")
InfoTab:CreateLabel("- No Clip")
InfoTab:CreateLabel("- Unlimited Jump")
InfoTab:CreateLabel("- Teleport System (Auto)")
InfoTab:CreateLabel("- Quick Teleport GUI (Manual)")

-- Watermark
Rayfield:Notify({
    Title = "Rivals Hack Suite",
    Content = "Successfully loaded with all features!",
    Duration = 5,
    Image = 4483362458,
    Actions = {
        Ignore = {
            Name = "Thanks!",
            Callback = function()
            end
        },
    },
})

print("Enhanced Rivals Hack Suite with all features loaded successfully.")