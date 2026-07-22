--[[
    ====================================================================
    [!] NOS [🦇] FORSAKEN HUB - GUEST 1337 ABILITY & NO-LAG GUI
    [!] ฟังก์ชัน: GUI สวยงาม, ระบบแพ็กเก็ตบล็อกต้านทานดาเมจ, โหมด No-Lag / FPS Booster
    ====================================================================
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ค้นหา RemoteEvent ของเกมจากแพ็กเก็ตที่คุณให้มา
local RemoteEvent = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent")

-- [ 1. ฟังก์ชันความสามารถพิเศษ: บล็อกป้องกัน (Resistance Block / Guest 1337) ]
local function TriggerResistanceBlock()
    pcall(function()
        -- ส่งสัญญาณความสามารถบล็อกป้องกัน (UseActorAbility -> Block)
        firesignal(RemoteEvent.OnClientEvent, 
            "UseActorAbility",
            {
                (function(bytes)
                    local b = buffer.create(#bytes)
                    for i = 1, #bytes do buffer.writeu8(b, i - 1, bytes[i]) end
                    return b
                end)({ 3, 5, 0, 0, 0, 66, 108, 111, 99, 105 })
            }
        )

        -- ส่งสัญญาณเพิ่มสถานะต้านทาน (Resistance Status)
        firesignal(RemoteEvent.OnClientEvent, 
            5,
            {
                (function(bytes)
                    local b = buffer.create(#bytes)
                    for i = 1, #bytes do buffer.writeu8(b, i - 1, bytes[i]) end
                    return b
                end)({ 3, 10, 0, 0, 0, 82, 101, 115, 105, 115, 116, 97, 110, 99, 105 })
            }
        )

        -- ส่งแพ็กเก็ตยืนยันสถานะความต้านทานระดับ 20%
        firesignal(RemoteEvent.OnClientEvent, 
            3,
            {
                (function(bytes)
                    local b = buffer.create(#bytes)
                    for i = 1, #bytes do buffer.writeu8(b, i - 1, bytes[i]) end
                    return b
                end)({ 3, 10, 0, 0, 0, 82, 101, 115, 105, 115, 116, 97, 110, 99, 105 }),
                {
                    Removed = (function(bytes) local b = buffer.create(#bytes) for i=1,#bytes do buffer.writeu8(b, i-1, bytes[i]) end return b end)({ 0 }),
                    Data = {
                        MaxLevel = (function(bytes) local b = buffer.create(#bytes) for i=1,#bytes do buffer.writeu8(b, i-1, bytes[i]) end return b end)({ 2, 0, 0, 0, 0, 0, 0, 36, 64 }),
                        Description = (function(bytes) local b = buffer.create(#bytes) for i=1,#bytes do buffer.writeu8(b, i-1, bytes[i]) end return b end)({ 3, 99, 0, 0, 0, 77, 97, 107, 101, 115, 32, 121, 111, 117, 32, 108, 101, 115, 115, 32, 115, 117, 115, 99, 101, 112, 116, 105, 98, 108, 101, 32, 116, 111, 32, 100, 97, 109, 97, 103, 101, 46, 10, 69, 118, 101, 114, 121, 32, 108, 101, 118, 101, 108, 32, 111, 10f, 32, 116, 104, 105, 115, 32, 115, 116, 97, 116, 117, 115, 32, 109, 97, 107, 101, 115, 32, 121, 111, 117, 32, 114, 101, 99, 101, 101, 118, 101, 32, 50, 48, 37, 32, 108, 101, 115, 115, 32, 100, 97, 109, 97, 103, 101, 46 }),
                        Duration = (function(bytes) local b = buffer.create(#bytes) for i=1,#bytes do buffer.writeu8(b, i-1, bytes[i]) end return b end)({ 2, 0, 0, 0, 0, 0, 0, 240, 63 }),
                        Stackable = (function(bytes) local b = buffer.create(#bytes) for i=1,#bytes do buffer.writeu8(b, i-1, bytes[i]) end return b end)({ 1, 0 }),
                        Level = (function(bytes) local b = buffer.create(#bytes) for i=1,#bytes do buffer.writeu8(b, i-1, bytes[i]) end return b end)({ 2, 0, 0, 0, 0, 0, 0, 20, 64 })
                    },
                    Character = LocalPlayer.Character,
                    Player = LocalPlayer,
                    TimePast = (function(bytes) local b = buffer.create(#bytes) for i=1,#bytes do buffer.writeu8(b, i-1, bytes[i]) end return b end)({ 2, 0, 0, 0, 0, 0, 0, 0, 0 }),
                    Applied = (function(bytes) local b = buffer.create(#bytes) for i=1,#bytes do buffer.writeu8(b, i-1, bytes[i]) end return b end)({ 0 }),
                    Level = (function(bytes) local b = buffer.create(#bytes) for i=1,#bytes do buffer.writeu8(b, i-1, bytes[i]) end return b end)({ 2, 0, 0, 0, 0, 0, 0, 20, 64 }),
                    AppliedFrom = (function(bytes) local b = buffer.create(#bytes) for i=1,#bytes do buffer.writeu8(b, i-1, bytes[i]) end return b end)({ 3, 4, 0, 0, 0, 78, 111, 110, 101 }),
                    TimeRequired = (function(bytes) local b = buffer.create(#bytes) for i=1,#bytes do buffer.writeu8(b, i-1, bytes[i]) end return b end)({ 2, 0, 0, 0, 0, 0, 0, 240, 63 })
                },
                {
                    MaxLevel = (function(bytes) local b = buffer.create(#bytes) for i=1,#bytes do buffer.writeu8(b, i-1, bytes[i]) end return b end)({ 2, 0, 0, 0, 0, 0, 0, 36, 64 }),
                    Description = (function(bytes) local b = buffer.create(#bytes) for i=1,#bytes do buffer.writeu8(b, i-1, bytes[i]) end return b end)({ 3, 99, 0, 0, 0, 77, 97, 107, 101, 115, 32, 121, 111, 117, 32, 108, 101, 115, 115, 32, 115, 117, 115, 99, 101, 112, 116, 105, 98, 108, 101, 32, 116, 111, 32, 100, 97, 109, 97, 103, 101, 46, 10, 69, 118, 101, 114, 121, 32, 108, 101, 118, 101, 108, 32, 111, 102, 32, 116, 104, 105, 115, 32, 115, 116, 97, 116, 117, 115, 32, 109, 97, 107, 101, 115, 32, 121, 111, 117, 32, 114, 101, 101, 115, 110, 100, 32, 50, 48, 37 }),
                    Duration = (function(bytes) local b = buffer.create(#bytes) for i=1,#bytes do buffer.writeu8(b, i-1, bytes[i]) end return b end)({ 2, 0, 0, 0, 0, 0, 0, 240, 63 }),
                    Stackable = (function(bytes) local b = buffer.create(#bytes) for i=1,#bytes do buffer.writeu8(b, i-1, bytes[i]) end return b end)({ 1, 0 }),
                    Level = (function(bytes) local b = buffer.create(#bytes) for i=1,#bytes do buffer.writeu8(b, i-1, bytes[i]) end return b end)({ 2, 0, 0, 0, 0, 0, 0, 20, 64 })
                }
            }
        )
    end)
end

-- [ 2. ฟังก์ชัน No-Lag / FPS Booster ]
local function EnableNoLag(state)
    pcall(function()
        local Lighting = game:GetService("Lighting")
        local Terrain = workspace:FindFirstChildOfClass("Terrain")

        if state then
            -- ปิดเอฟเฟกต์แสงเงาและบรรยากาศเพื่อเพิ่ม FPS
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 999999
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
                    v.Enabled = false
                end
            end
            if Terrain then
                Terrain.WaterWaveSize = 0
                Terrain.WaterTransparency = 1
                Terrain.WaterReflectance = 0
            end
            -- ลบเงาและวัสดุหนักๆ ของโมเดลในเกม
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.CastShadow = false
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                    obj.Enabled = false
                end
            end
        else
            Lighting.GlobalShadows = true
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
                    v.Enabled = true
                end
            end
        end
    end)
end

-- [ 3. สร้าง UI เมนู (NOS THEME) ]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NOS_ForsakenHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 280)
MainFrame.Position = UDim2.new(0.5, -170, 0.4, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundTransparency = 1
TitleBar.Text = "  [NOS 🦇] FORSAKEN HUB"
TitleBar.TextColor3 = Color3.fromRGB(240, 240, 245)
TitleBar.Font = Enum.Font.GothamBold
TitleBar.TextSize = 13
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Parent = MainFrame

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -20, 1, -55)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Parent = Container

-- ปุ่มกด: เปิดใช้งานสกิลบล็อกป้องกัน (Guest 1337 Resistance)
local BlockBtn = Instance.new("TextButton")
BlockBtn.Size = UDim2.new(1, 0, 0, 45)
BlockBtn.BackgroundColor3 = Color3.fromRGB(45, 60, 110)
BlockBtn.Text = "🛡️ ใช้สกิลบล็อกป้องกัน (Guest 1337)"
BlockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BlockBtn.Font = Enum.Font.GothamBold
BlockBtn.TextSize = 12
BlockBtn.Parent = Container

local BlockCorner = Instance.new("UICorner")
BlockCorner.CornerRadius = UDim.new(0, 6)
BlockCorner.Parent = BlockBtn

BlockBtn.MouseButton1Click:Connect(function()
    TriggerResistanceBlock()
    BlockBtn.Text = "✅ ส่งคำสั่งบล็อกป้องกันแล้ว!"
    task.wait(1.5)
    BlockBtn.Text = "🛡️ ใช้สกิลบล็อกป้องกัน (Guest 1337)"
end)

-- ปุ่มกด: เปิด/ปิดโหมด No-Lag (FPS Booster)
local NoLagState = false
local NoLagBtn = Instance.new("TextButton")
NoLagBtn.Size = UDim2.new(1, 0, 0, 45)
NoLagBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
NoLagBtn.Text = "⚡ เปิดโหมด No-Lag (ลดแลค: ปิด)"
NoLagBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
NoLagBtn.Font = Enum.Font.GothamBold
NoLagBtn.TextSize = 12
NoLagBtn.Parent = Container

local NoLagCorner = Instance.new("UICorner")
NoLagCorner.CornerRadius = UDim.new(0, 6)
NoLagCorner.Parent = NoLagBtn

NoLagBtn.MouseButton1Click:Connect(function()
    NoLagState = not NoLagState
    EnableNoLag(NoLagState)
    if NoLagState then
        NoLagBtn.Text = "⚡ เปิดโหมด No-Lag (ลดแลค: เปิด)"
        NoLagBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        NoLagBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        NoLagBtn.Text = "⚡ เปิดโหมด No-Lag (ลดแลค: ปิด)"
        NoLagBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
        NoLagBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    end
end)

-- ปุ่มลอย (Toggle Menu Button)
local ToggleMenu = Instance.new("TextButton")
ToggleMenu.Size = UDim2.new(0, 45, 0, 45)
ToggleMenu.Position = UDim2.new(0.05, 0, 0.15, 0)
ToggleMenu.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
ToggleMenu.Text = "NOS"
ToggleMenu.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleMenu.Font = Enum.Font.GothamBold
ToggleMenu.TextSize = 11
ToggleMenu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(1, 0)
MenuCorner.Parent = ToggleMenu

ToggleMenu.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

print("[NOS Forsaken]: โหลดหน้าต่าง GUI และระบบบล็อกป้องกัน Guest 1337 สำเร็จ!")
