local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Terrain = workspace.Terrain

-- ==========================================
-- [1파트] 하늘 배경 및 조명 세팅
-- ==========================================

-- 1. 기존 하늘/대기 요소 제거
for _, v in ipairs(Terrain:GetChildren()) do
    if v:IsA("Clouds") then v:Destroy() end
end

for _, v in ipairs(Lighting:GetChildren()) do
    if v:IsA("Clouds") or v:IsA("Sky") or v:IsA("Atmosphere") then
        v:Destroy()
    end
end

-- 2. 스카이박스 적용
local sky = Instance.new("Sky")
sky.Name = "Sky"

sky.SkyboxBk = "rbxassetid://169210090"
sky.SkyboxDn = "rbxassetid://169210108"
sky.SkyboxFt = "rbxassetid://169210121"
sky.SkyboxLf = "rbxassetid://169210133"
sky.SkyboxRt = "rbxassetid://169210143"
sky.SkyboxUp = "rbxassetid://169210149"

sky.MoonTextureId = "rbxasset://sky/moon.jpg"
sky.SunTextureId = "rbxassetid://6196665106"

sky.StarCount = 5000
sky.SunAngularSize = 11
sky.MoonAngularSize = 11
sky.CelestialBodiesShown = true
sky.Parent = Lighting

-- 기본 낮 조명
Lighting.ClockTime = 12
Lighting.Brightness = 1.0
Lighting.ExposureCompensation = 0.1
Lighting.GlobalShadows = false

-- 기본 환경광
local baseOutdoor = Color3.fromRGB(150, 135, 160)
local baseAmbient = Color3.fromRGB(100, 90, 110)
Lighting.OutdoorAmbient = baseOutdoor
Lighting.Ambient = baseAmbient

-- 색 보정 효과
local colorCorrection = Lighting:FindFirstChild("UIToggleColorCorrection")
if not colorCorrection then
    colorCorrection = Instance.new("ColorCorrectionEffect")
    colorCorrection.Name = "UIToggleColorCorrection"
    colorCorrection.Parent = Lighting
end

-- ==========================================
-- [2파트] 삼색(노랑/주황/파랑) 조절 UI 생성
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LightingControlGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 190)
frame.Position = UDim2.new(0.02, 0, 0.58, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = frame

-- 슬라이더 상태 값 (0~1)
local intensities = {
    Yellow = 0,
    Orange = 0,
    Blue = 0
}

-- 슬라이더 매개변수 정의
local slidersData = {
    { Key = "Yellow", Name = "🟡 노랑 강도", Color = Color3.fromRGB(255, 210, 40), YOffset = 10 },
    { Key = "Orange", Name = "🟠 주황 강도", Color = Color3.fromRGB(255, 120, 30), YOffset = 55 },
    { Key = "Blue",   Name = "🔵 파랑 강도", Color = Color3.fromRGB(40, 130, 255), YOffset = 100 }
}

local sliderElements = {}

local function updateLighting()
    local yA = intensities.Yellow
    local oA = intensities.Orange
    local bA = intensities.Blue
    
    -- 각 색상 목표값 연산 (합산 및 제한)
    local targetOutdoorR = math.clamp(baseOutdoor.R + (yA * 0.4) + (oA * 0.41) - (bA * 0.35), 0, 1)
    local targetOutdoorG = math.clamp(baseOutdoor.G + (yA * 0.35) + (oA * 0.12) - (bA * 0.1), 0, 1)
    local targetOutdoorB = math.clamp(baseOutdoor.B - (yA * 0.2) - (oA * 0.2) + (bA * 0.4), 0, 1)
    Lighting.OutdoorAmbient = Color3.new(targetOutdoorR, targetOutdoorG, targetOutdoorB)

    local targetAmbientR = math.clamp(baseAmbient.R + (yA * 0.35) + (oA * 0.39) - (bA * 0.3), 0, 1)
    local targetAmbientG = math.clamp(baseAmbient.G + (yA * 0.3) + (oA * 0.1) - (bA * 0.1), 0, 1)
    local targetAmbientB = math.clamp(baseAmbient.B - (yA * 0.15) - (oA * 0.15) + (bA * 0.35), 0, 1)
    Lighting.Ambient = Color3.new(targetAmbientR, targetAmbientG, targetAmbientB)

    local tintR = math.clamp(1 + (yA * 0.1) + (oA * 0.1) - (bA * 0.4), 0, 1)
    local tintG = math.clamp(1 + (yA * 0.05) - (oA * 0.15) - (bA * 0.2), 0, 1)
    local tintB = math.clamp(1 - (yA * 0.3) - (oA * 0.3) + (bA * 0.1), 0, 1)
    colorCorrection.TintColor = Color3.new(tintR, tintG, tintB)
    
    colorCorrection.Saturation = (yA * 0.25) + (oA * 0.3) + (bA * 0.35)
end

local activeDraggingKey = nil

for _, data in ipairs(slidersData) do
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18)
    label.Position = UDim2.new(0, 0, 0, data.YOffset)
    label.BackgroundTransparency = 1
    label.Text = string.format("%s (0%%)", data.Name)
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextSize = 11
    label.Font = Enum.Font.GothamBold
    label.Parent = frame

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(0.85, 0, 0, 6)
    sliderBar.Position = UDim2.new(0.075, 0, 0, data.YOffset + 22)
    sliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = frame

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = sliderBar

    local fillBar = Instance.new("Frame")
    fillBar.Size = UDim2.new(0, 0, 1, 0)
    fillBar.BackgroundColor3 = data.Color
    fillBar.BorderSizePixel = 0
    fillBar.Parent = sliderBar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fillBar

    local knob = Instance.new("ImageButton")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(0, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = sliderBar

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    sliderElements[data.Key] = {
        Label = label,
        Bar = sliderBar,
        Fill = fillBar,
        Knob = knob,
        Name = data.Name
    }

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            activeDraggingKey = data.Key
        end
    end)
end

-- 리셋 버튼
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0.85, 0, 0, 22)
resetBtn.Position = UDim2.new(0.075, 0, 0, 155)
resetBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
resetBtn.Text = "모든 색상 초기화"
resetBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
resetBtn.Font = Enum.Font.Gotham
resetBtn.TextSize = 11
resetBtn.Parent = frame

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 5)
resetCorner.Parent = resetBtn

local function updateSliderValue(key, alpha)
    alpha = math.clamp(alpha, 0, 1)
    intensities[key] = alpha
    
    local elem = sliderElements[key]
    elem.Fill.Size = UDim2.new(alpha, 0, 1, 0)
    elem.Knob.Position = UDim2.new(alpha, 0, 0.5, 0)
    elem.Label.Text = string.format("%s (%d%%)", elem.Name, math.floor(alpha * 100))
    
    updateLighting()
end

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        activeDraggingKey = nil
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if activeDraggingKey and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local elem = sliderElements[activeDraggingKey]
        local barAbsPos = elem.Bar.AbsolutePosition.X
        local barAbsSize = elem.Bar.AbsoluteSize.X
        local mouseX = input.Position.X
        local alpha = (mouseX - barAbsPos) / barAbsSize
        updateSliderValue(activeDraggingKey, alpha)
    end
end)

resetBtn.MouseButton1Click:Connect(function()
    for key, _ in pairs(intensities) do
        updateSliderValue(key, 0)
    end
end)

-- 초기화 실행
for key, _ in pairs(intensities) do
    updateSliderValue(key, 0)
end

-- ==========================================
-- [3파트] 검정+회색 바다 생성
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

    -- 검은 회색(다크 차콜 톤) 바다 세팅
    Terrain.WaterWaveSize = 0.6
    Terrain.WaterWaveSpeed = 8
    Terrain.WaterReflectance = 0.6
    Terrain.WaterTransparency = 0.08
    Terrain.WaterColor = Color3.fromRGB(28, 30, 35)
end)
