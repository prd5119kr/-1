local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- ==========================================
-- [0파트] 화이트리스트 설정
-- ==========================================
-- 여기에 허용할 플레이어의 닉네임(Name)이나 UserID를 적어주세요.
local whitelist = {
    "v_cxvz0",
}

local function isWhitelisted(plr)
    -- 화이트리스트가 비어있거나(전체 허용), 목록에 포함된 경우 true 반환
    if #whitelist == 0 then return true end
    
    for _, allowed in ipairs(whitelist) do
        if type(allowed) == "string" and plr.Name == allowed then
            return true
        elseif type(allowed) == "number" and plr.UserId == allowed then
            return true
        end
    end
    return false
end

-- 화이트리스트에 없는 플레이어는 스크립트 실행 중지
if not isWhitelisted(player) then
    warn("[System] 이 스크립트를 사용할 수 있는 권한이 없습니다.")
    return
end

local playerGui = player:WaitForChild("PlayerGui")
local Terrain = workspace.Terrain

-- ==========================================
-- [1파트] 원본 우주 하늘 배경 및 조명 세팅 (완전 복원)
-- ==========================================

-- 1. 방해되는 기존 3D 구름/대기/하늘 삭제
for _, v in ipairs(Terrain:GetChildren()) do
    if v:IsA("Clouds") then v:Destroy() end
end

for _, v in ipairs(Lighting:GetChildren()) do
    if v:IsA("Clouds") or v:IsA("Sky") or v:IsA("Atmosphere") then
        v:Destroy()
    end
end

-- 2. 원래 사용하시던 우주 Skybox ID로 복원
local sky = Instance.new("Sky")
sky.Name = "Sky"

sky.SkyboxBk = "rbxassetid://81858382098344"
sky.SkyboxDn = "rbxassetid://138472117789684"
sky.SkyboxFt = "rbxassetid://95687237979398"
sky.SkyboxLf = "rbxassetid://84924000207295"
sky.SkyboxRt = "rbxassetid://99961685452126"
sky.SkyboxUp = "rbxassetid://104038404823203"

sky.SunTextureId = "rbxassetid://6196665106"
sky.MoonTextureId = "rbxassetid://6444320592"

sky.StarCount = 5000
sky.SunAngularSize = 11
sky.MoonAngularSize = 11
sky.CelestialBodiesShown = true
sky.Parent = Lighting

-- 밝고 선명하게 낮 시간대로 설정
Lighting.ClockTime = 12
Lighting.Brightness = 1.0
Lighting.ExposureCompensation = 0.1
Lighting.GlobalShadows = false
Lighting.OutdoorAmbient = Color3.fromRGB(150, 135, 160)
Lighting.Ambient = Color3.fromRGB(100, 90, 110)

-- 색 보정 효과 준비
local colorCorrection = Lighting:FindFirstChild("UIToggleColorCorrection")
if not colorCorrection then
    colorCorrection = Instance.new("ColorCorrectionEffect")
    colorCorrection.Name = "UIToggleColorCorrection"
    colorCorrection.Parent = Lighting
end

-- ==========================================
-- [2파트] 파란색 강도 조절 UI 생성
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LightingControlGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 95)
frame.Position = UDim2.new(0.02, 0, 0.72, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundTransparency = 1
title.Text = "🔵 파란색 강도 조절 (0%)"
title.TextColor3 = Color3.fromRGB(240, 240, 240)
title.TextSize = 12
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- 슬라이더 배경 바
local sliderBar = Instance.new("Frame")
sliderBar.Size = UDim2.new(0.85, 0, 0, 8)
sliderBar.Position = UDim2.new(0.075, 0, 0.42, 0)
sliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
sliderBar.BorderSizePixel = 0
sliderBar.Parent = frame

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(1, 0)
barCorner.Parent = sliderBar

-- 채워지는 파란색 바
local fillBar = Instance.new("Frame")
fillBar.Size = UDim2.new(0, 0, 1, 0)
fillBar.BackgroundColor3 = Color3.fromRGB(40, 130, 255)
fillBar.BorderSizePixel = 0
fillBar.Parent = sliderBar

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = fillBar

-- 노브 (손잡이)
local knob = Instance.new("ImageButton")
knob.Size = UDim2.new(0, 18, 0, 18)
knob.AnchorPoint = Vector2.new(0.5, 0.5)
knob.Position = UDim2.new(0, 0, 0.5, 0)
knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
knob.BorderSizePixel = 0
knob.Parent = sliderBar

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = knob

-- 리셋 버튼
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0.85, 0, 0, 24)
resetBtn.Position = UDim2.new(0.075, 0, 0.65, 0)
resetBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
resetBtn.Text = "기본 색상으로 리셋"
resetBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
resetBtn.Font = Enum.Font.Gotham
resetBtn.TextSize = 11
resetBtn.Parent = frame

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 5)
resetCorner.Parent = resetBtn

-- 조명 보정 실시간 연동
local dragging = false

local function updateBlueIntensity(alpha)
    alpha = math.clamp(alpha, 0, 1)

    fillBar.Size = UDim2.new(alpha, 0, 1, 0)
    knob.Position = UDim2.new(alpha, 0, 0.5, 0)
    title.Text = string.format("🔵 파란색 강도 조절 (%d%%)", math.floor(alpha * 100))

    local baseOutdoor = Color3.fromRGB(150, 135, 160)
    local maxOutdoor  = Color3.fromRGB(30, 90, 255)
    Lighting.OutdoorAmbient = baseOutdoor:Lerp(maxOutdoor, alpha)

    local baseAmbient = Color3.fromRGB(100, 90, 110)
    local maxAmbient  = Color3.fromRGB(10, 40, 200)
    Lighting.Ambient = baseAmbient:Lerp(maxAmbient, alpha)

    local baseTint = Color3.fromRGB(255, 255, 255)
    local maxTint  = Color3.fromRGB(130, 180, 255)
    colorCorrection.TintColor = baseTint:Lerp(maxTint, alpha)

    colorCorrection.Saturation = alpha * 0.35
end

local function processInput(input)
    local barAbsPos = sliderBar.AbsolutePosition.X
    local barAbsSize = sliderBar.AbsoluteSize.X
    local mouseX = input.Position.X
    local alpha = (mouseX - barAbsPos) / barAbsSize
    updateBlueIntensity(alpha)
end

knob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        processInput(input)
    end
end)

resetBtn.MouseButton1Click:Connect(function()
    updateBlueIntensity(0)
end)

updateBlueIntensity(0)

-- ==========================================
-- [3파트] 바다 오브젝트 및 지형 생성 (안전 실행)
-- ==========================================
task.spawn(function()
    pcall(function()
        if workspace.Map.AlwaysHereTweenedObjects.Ocean.Object:FindFirstChild("ObjectModel") then
            for _, prt in pairs(workspace.Map.AlwaysHereTweenedObjects.Ocean.Object.ObjectModel:GetChildren()) do 
                if prt:IsA("Part") then 
                    prt.Transparency = 1
                end
            end
        end
    end)

    local oceanSize = 8000
    local oceanDepth = 20
    local oceanLevel = -14
    local chunkSize = 1000

    local spawnPosition = Vector3.new(0, oceanLevel - (oceanDepth / 2), 0)
    local spawnClearSize = Vector3.new(750, oceanDepth, 750)

    local steps = math.ceil(oceanSize / chunkSize)
    local startOffset = -oceanSize / 2

    for x = 0, steps - 1 do
        for z = 0, steps - 1 do
            local xPos = startOffset + (x * chunkSize) + (chunkSize / 2)
            local zPos = startOffset + (z * chunkSize) + (chunkSize / 2)

            local centerPos = Vector3.new(xPos, oceanLevel - (oceanDepth / 2), zPos)
            local size = Vector3.new(chunkSize, oceanDepth, chunkSize)

            Terrain:FillBlock(CFrame.new(centerPos), size, Enum.Material.Water)
            task.wait()
        end
    end

    Terrain:FillBlock(CFrame.new(spawnPosition), spawnClearSize, Enum.Material.Air)

    Terrain.WaterWaveSize = 0.7
    Terrain.WaterWaveSpeed = 9
    Terrain.WaterReflectance = 1
    Terrain.WaterTransparency = 0.07
    Terrain.WaterColor = Color3.fromRGB(0, 100, 200)
end)
