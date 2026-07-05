--[[
    ========================================================================
    ROBLOX DRAGGABLE & MINIMIZABLE G-BUTTON SCRIPT (MOBILE-FRIENDLY)
    ========================================================================
    คุณสมบัติ:
    - ปุ่มกด G จำลองการกดคีย์บอร์ดจริงผ่าน VirtualInputManager (ไม่ทำให้ปุ่มเดิน/กระโดดหาย)
    - สามารถลากเคลื่อนย้ายตำแหน่งได้อิสระ (รองรับทั้ง เมาส์ และ ทัชสกรีน)
    - สามารถย่อหน้าต่างให้เล็กลงเหลือเพียงปุ่มลอยขนาดเล็กได้
    - ดีไซน์ Dark Mode ทันสมัย สวยงาม
    ========================================================================
--]]

local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 1. ลบ GUI เดิมที่อาจซ้ำกันอยู่ก่อนหน้าเพื่อป้องกันการซ้อนทับ
if playerGui:FindFirstChild("GButtonModGui") then
    playerGui.GButtonModGui:Destroy()
end

-- 2. สร้าง ScreenGui หลัก
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GButtonModGui"
ScreenGui.Parent = playerGui
ScreenGui.ResetOnSpawn = false -- ตายแล้วปุ่มไม่หาย
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 3. หน้าต่างหลัก (Main Window Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 180, 0, 140)
MainFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- เส้นขอบเรืองแสงเบาๆ (Stroke)
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(80, 80, 100)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- 4. ส่วนหัวของหน้าต่าง (Header/Title Bar สำหรับลาก)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

-- ปิดมุมล่างของ Header เพื่อให้เข้ากับ Frame หลัก
local BottomCover = Instance.new("Frame")
BottomCover.Name = "BottomCover"
BottomCover.Size = UDim2.new(1, 0, 0.5, 0)
BottomCover.Position = UDim2.new(0, 0, 0.5, 0)
BottomCover.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
BottomCover.BorderSizePixel = 0
BottomCover.Parent = Header

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "G-Button Mod"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- 5. ปุ่มย่อหน้าต่าง (Minimize Button)
local MinButton = Instance.new("TextButton")
MinButton.Name = "MinButton"
MinButton.Size = UDim2.new(0, 24, 0, 24)
MinButton.Position = UDim2.new(0.95, -24, 0.5, -12)
MinButton.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
MinButton.Text = "-"
MinButton.TextColor3 = Color3.fromRGB(220, 220, 220)
MinButton.TextSize = 16
MinButton.Font = Enum.Font.GothamBold
MinButton.AutoButtonColor = true
MinButton.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinButton

-- 6. ปุ่มกดตัว G หลัก (The G-Action Button)
local GButton = Instance.new("TextButton")
GButton.Name = "GButton"
GButton.Size = UDim2.new(0.85, 0, 0.55, 0)
GButton.Position = UDim2.new(0.075, 0, 0.35, 0)
GButton.BackgroundColor3 = Color3.fromRGB(98, 0, 234) -- สีม่วงสว่างสวยงาม
GButton.Text = "PRESS G"
GButton.TextColor3 = Color3.fromRGB(255, 255, 255)
GButton.TextSize = 16
GButton.Font = Enum.Font.GothamBold
GButton.AutoButtonColor = true
GButton.Parent = MainFrame

-- ปิดคุณสมบัติแย่งการทัช เพื่อไม่ให้รบกวนปุ่มเดิน/กระโดดของ Roblox บนมือถือ
GButton.Active = false 

local GCorner = Instance.new("UICorner")
GCorner.CornerRadius = UDim.new(0, 8)
GCorner.Parent = GButton

local GStroke = Instance.new("UIStroke")
GStroke.Color = Color3.fromRGB(150, 100, 255)
GStroke.Thickness = 1
GStroke.Parent = GButton

-- 7. ปุ่มลอยย่อส่วน (Mini Floating Button)
local MiniButton = Instance.new("TextButton")
MiniButton.Name = "MiniButton"
MiniButton.Size = UDim2.new(0, 50, 0, 50)
MiniButton.Position = MainFrame.Position
MiniButton.BackgroundColor3 = Color3.fromRGB(98, 0, 234)
MiniButton.Visible = false
MiniButton.Text = "G"
MiniButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniButton.TextSize = 22
MiniButton.Font = Enum.Font.GothamBold
MiniButton.AutoButtonColor = true
MiniButton.Active = true
MiniButton.Parent = ScreenGui

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(0, 25) -- ทำเป็นวงกลม
MiniCorner.Parent = MiniButton

local MiniStroke = Instance.new("UIStroke")
MiniStroke.Color = Color3.fromRGB(255, 255, 255)
MiniStroke.Thickness = 2
MiniStroke.Parent = MiniButton

-- ==========================================
-- ระบบจำลองคีย์บอร์ดเสมือน (ป้องกันปุ่มเดินหาย)
-- ==========================================
local function pressGKey()
    -- ใช้ VirtualInputManager จำลองการกดปุ่ม G ทางระดับ Hardware ของ Roblox
    -- วิธีนี้จะไม่ตัดสิทธิ์การควบคุมหน้าจอสัมผัสของมือถือ
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.G, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.G, false, game)
end

GButton.MouseButton1Click:Connect(pressGKey)
MiniButton.MouseButton1Click:Connect(function()
    -- หากกดที่ปุ่มลอยเล็กขณะย่อส่วน จะทำการขยายหน้าต่างหลักกลับมา
    if MiniButton.Visible then
        MainFrame.Position = MiniButton.Position
        MiniButton.Visible = false
        MainFrame.Visible = true
    end
end)

-- ==========================================
-- ระบบ ย่อ / ขยาย หน้าต่าง (Minimize System)
-- ==========================================
MinButton.MouseButton1Click:Connect(function()
    MiniButton.Position = MainFrame.Position
    MainFrame.Visible = false
    MiniButton.Visible = true
end)

-- ==========================================
-- ระบบลากเคลื่อนย้าย (Draggable System)
-- รองรับทั้งเมาส์ และระบบสัมผัสของมือถืออย่างสมบูรณ์
-- ==========================================
local function setupDraggable(frame, dragHandle)
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        
        -- ทำแอนิเมชันตอนลากเพื่อให้ดูนุ่มนวลขึ้น
        local tween = TweenService:Create(frame, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = newPos})
        tween:Play()
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- เปิดใช้งานระบบลากสำหรับหน้าต่างหลัก (ลากผ่านส่วนหัว Header) และปุ่มย่อเล็ก (ลากตัวมันเองได้เลย)
setupDraggable(MainFrame, Header)
setupDraggable(MiniButton, MiniButton)
