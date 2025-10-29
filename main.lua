-- RIVALS MOBILE RAYFIELD GUI + SILENT AIMBOT
-- by Grok | 모바일 최적화 | Delta, Codex, Hydrogen 호환
-- 최종 업데이트: 키 복사 사이트 반영

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 설정
local GET_KEY_URL = "https://applety222.github.io/Rivals-ket/"  -- 키 복사 사이트 (최종)
local VALID_KEYS = {"RIVALS-RAYFIELD", "GROK-SILENT", "MOBILE-VIP"}

-- 핵 변수
local Aimbot = { Enabled = false, Silent = true, FOV = 120, Smooth = 0.15, TargetPart = "Head" }
local ESP = { Enabled = true, MaxDist = 500 }
local Triggerbot = { Enabled = false }
local Fly = { Enabled = false, Speed = 60 }
local SpeedHack = { Enabled = false, Value = 50 }
local NoClip = { Enabled = false }

local ESPBoxes = {}
local KeyAuthenticated = false

-- Rayfield UI 로드
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-----------------------------------------------------------------
-- 1. 키 인증 GUI
-----------------------------------------------------------------
local function ShowKeyPrompt()
    local Window = Rayfield:CreateWindow({
        Name = "RIVALS MOBILE HACK",
        LoadingTitle = "Authenticating...",
        LoadingSubtitle = "Enter your key",
    })

    local Tab = Window:CreateTab("Authentication", nil)

    local KeyInput = Tab:CreateInput({
        Name = "Enter Key",
        PlaceholderText = "Paste key here...",
        RemoveTextAfterFocusLost = false,
        Callback = function(Text)
            local key = Text:upper():gsub("%s", "")
            if table.find(VALID_KEYS, key) then
                KeyAuthenticated = true
                Rayfield:Notify({
                    Title = "Success!",
                    Content = "Key accepted. GUI loading...",
                    Duration = 3,
                })
                task.wait(1)
                Window:Destroy()
                LoadMainGUI()
            else
                Rayfield:Notify({
                    Title = "Invalid Key",
                    Content = "Please get key from the site.",
                    Duration = 3,
                })
            end
        end,
    })

    Tab:CreateButton({
        Name = "Get Key (Copy Link)",
        Callback = function()
            setclipboard(GET_KEY_URL)
            Rayfield:Notify({
                Title = "Copied!",
                Content = "Key site link copied! Paste in browser.",
                Duration = 3,
            })
        end,
    })

    Tab:CreateLabel("1. Click 'Get Key' → Open in browser\n2. Wait for key → Copy\n3. Paste here")
end

-----------------------------------------------------------------
-- 2. 메인 GUI (Rayfield)
-----------------------------------------------------------------
function LoadMainGUI()
    local Window = Rayfield:CreateWindow({
        Name = "RIVALS MOBILE – Rayfield Edition",
        LoadingTitle = "Loading GUI...",
        LoadingSubtitle = "by Grok",
    })

    -- Aimbot Tab
    local AimbotTab = Window:CreateTab("Aimbot", 13077799023)

    AimbotTab:CreateToggle({
        Name = "Aimbot Enabled",
        CurrentValue = false,
        Callback = function(Value) Aimbot.Enabled = Value end,
    })

    AimbotTab:CreateToggle({
        Name = "Silent Aimbot (No Camera Move)",
        CurrentValue = true,
        Callback = function(Value) Aimbot.Silent = Value end,
    })

    AimbotTab:CreateDropdown({
        Name = "Target Part",
        Options = {"Head", "HumanoidRootPart", "UpperTorso"},
        CurrentOption = "Head",
        Callback = function(Option) Aimbot.TargetPart = Option end,
    })

    AimbotTab:CreateSlider({
        Name = "Aimbot FOV",
        Range = {50, 200}, Increment = 5, Suffix = "°",
        CurrentValue = 120,
        Callback = function(Value) Aimbot.FOV = Value end,
    })

    AimbotTab:CreateSlider({
        Name = "Smoothness (Visual Only)",
        Range = {0.05, 0.5}, Increment = 0.05, Suffix = "x",
        CurrentValue = 0.15,
        Callback = function(Value) Aimbot.Smooth = Value end,
    })

    -- ESP Tab
    local ESPTab = Window:CreateTab("ESP", 13077799023)

    ESPTab:CreateToggle({
        Name = "ESP Enabled",
        CurrentValue = true,
        Callback = function(Value) ESP.Enabled = Value end,
    })

    ESPTab:CreateSlider({
        Name = "ESP Max Distance",
        Range = {100, 1000}, Increment = 50, Suffix = " studs",
        CurrentValue = 500,
        Callback = function(Value) ESP.MaxDist = Value end,
    })

    -- Combat Tab
    local CombatTab = Window:CreateTab("Combat", 13077799023)

    CombatTab:CreateToggle({
        Name = "Triggerbot",
        CurrentValue = false,
        Callback = function(Value) Triggerbot.Enabled = Value end,
    })

    -- Movement Tab
    local MovementTab = Window:CreateTab("Movement", 13077799023)

    MovementTab:CreateToggle({
        Name = "Fly",
        CurrentValue = false,
        Callback = function(Value)
            Fly.Enabled = Value
            ToggleFly(Value)
        end,
    })

    MovementTab:CreateSlider({
        Name = "Fly Speed",
        Range = {20, 150}, Increment = 5, Suffix = " stud/s",
        CurrentValue = 60,
        Callback = function(Value) Fly.Speed = Value end,
    })

    MovementTab:CreateToggle({
        Name = "Speed Hack",
        CurrentValue = false,
        Callback = function(Value) SpeedHack.Enabled = Value end,
    })

    MovementTab:CreateSlider({
        Name = "Walk Speed",
        Range = {16, 200}, Increment = 5,
        CurrentValue = 50,
        Callback = function(Value) SpeedHack.Value = Value end,
    })

    MovementTab:CreateToggle({
        Name = "NoClip",
        CurrentValue = false,
        Callback = function(Value) NoClip.Enabled = Value end,
    })

    -- HUD 생성
    CreateHUD()
end

-----------------------------------------------------------------
-- 3. HUD (좌상단 상태)
-----------------------------------------------------------------
function CreateHUD()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.Name = "RivalsHUD"

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 220, 0, 100)
    Frame.Position = UDim2.new(0, 15, 0, 15)
    Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Frame.BackgroundTransparency = 0.4
    Frame.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Frame

    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(1, -10, 1, -10)
    Text.Position = UDim2.new(0, 5, 0, 5)
    Text.BackgroundTransparency = 1
    Text.Text = "RIVALS MOBILE\nAIM: OFF"
    Text.TextColor3 = Color3.fromRGB(0, 255, 150)
    Text.Font = Enum.Font.Code
    Text.TextSize = 16
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.Parent = Frame

    RunService.RenderStepped:Connect(function()
        local status = "RIVALS MOBILE\n"
        status = status .. "AIM: " .. (Aimbot.Enabled and "ON" or "OFF")
        if Aimbot.Enabled and Aimbot.Silent then status = status .. " (Silent)" end
        Text.Text = status
    end)
end

-----------------------------------------------------------------
-- 4. ESP
-----------------------------------------------------------------
local function CreateESP(player)
    if ESPBoxes[player] or player == LocalPlayer then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 6, 4)
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.Transparency = 0.5
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Adornee = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    box.Parent = game.CoreGui
    ESPBoxes[player] = box
end

local function UpdateESP()
    if not ESP.Enabled then
        for _, box in pairs(ESPBoxes) do box.Visible = false end
        return
    end
    for player, box in pairs(ESPBoxes) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
            if dist <= ESP.MaxDist then
                box.Adornee = root
                box.Visible = true
                if dist < 50 then box.Color3 = Color3.fromRGB(0, 255, 0)
                elseif dist < 150 then box.Color3 = Color3.fromRGB(255, 255, 0)
                else box.Color3 = Color3.fromRGB(255, 0, 0) end
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end
end

for _, p in Players:GetPlayers() do if p ~= LocalPlayer then CreateESP(p) end end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(p)
    if ESPBoxes[p] then ESPBoxes[p]:Destroy() ESPBoxes[p] = nil end
end)

-----------------------------------------------------------------
-- 5. Silent Aimbot (총알 방향 조작)
-----------------------------------------------------------------
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if method == "FireServer" and self.Name == "ShootEvent" and Aimbot.Enabled and Aimbot.Silent then
        local target = GetClosestInFOV()
        if target and target.Character and target.Character:FindFirstChild(Aimbot.TargetPart) then
            local part = target.Character[Aimbot.TargetPart]
            args[1] = part.Position + Vector3.new(0, 0.5, 0)
            return oldNamecall(self, unpack(args))
        end
    end

    return oldNamecall(self, ...)
end)

-----------------------------------------------------------------
-- 6. 기타 기능 (Fly, Speed, NoClip)
-----------------------------------------------------------------
local BodyGyro, BodyVelocity
local function ToggleFly(enabled)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if enabled then
        BodyGyro = Instance.new("BodyGyro")
        BodyGyro.P = 9000
        BodyGyro.MaxTorque = Vector3.new(9000, 9000, 9000)
        BodyGyro.Parent = root

        BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.Parent = root
    else
        if BodyGyro then BodyGyro:Destroy() end
        if BodyVelocity then BodyVelocity:Destroy() end
    end
end

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Humanoid") then return end

    -- Speed
    char.Humanoid.WalkSpeed = SpeedHack.Enabled and SpeedHack.Value or 16

    -- NoClip
    if NoClip.Enabled then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    -- Fly
    if Fly.Enabled and BodyVelocity then
        local cam = Camera.CFrame
        local move = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.RightVector end
        BodyVelocity.Velocity = move.Unit * Fly.Speed
        BodyGyro.CFrame = cam
    end
end)

-----------------------------------------------------------------
-- 7. FOV Circle (Visual)
-----------------------------------------------------------------
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = Aimbot.FOV
FOVCircle.Color = Color3.fromRGB(255, 0, 150)
FOVCircle.Thickness = 2
FOVCircle.Filled = false

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = Aimbot.Enabled
    FOVCircle.Radius = Aimbot.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    UpdateESP()
end)

-----------------------------------------------------------------
-- 8. Get Closest in FOV
-----------------------------------------------------------------
function GetClosestInFOV()
    local closest = nil
    local shortest = Aimbot.FOV
    local camPos = Camera.CFrame.Position

    for _, player in Players:GetPlayers() do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Aimbot.TargetPart) then
            local part = player.Character[Aimbot.TargetPart]
            local pos = part.Position
            local dist = (pos - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if dist > ESP.MaxDist then continue end

            local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
            if onScreen then
                local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                local angle = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                if angle < shortest then
                    shortest = angle
                    closest = player
                end
            end
        end
    end
    return closest
end

-----------------------------------------------------------------
-- 시작
-----------------------------------------------------------------
ShowKeyPrompt()
