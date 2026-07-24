--[[
    ====================================================================
    [!] GEF DYNAMIC BOX SHIELD - LOADER MODULE
    [!] ฟังก์ชัน: สร้างกล่องสี่เหลี่ยมล้อมรอบตัวอัตโนมัติ และขยับตามผู้เล่น
    ====================================================================
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "GEF_BoxShieldGui"

local Toggle = Instance.new("TextButton", ScreenGui)
Toggle.Size = UDim2.new(0, 45, 0, 45)
Toggle.Position = UDim2.new(0.05, 0, 0.2, 0)
Toggle.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
Toggle.Text = "GEF"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 11
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1, 0)

getgenv().GEF_GuiParent = ScreenGui
getgenv().GEF_ToggleBtn = Toggle

print("[GEF Loader]: โหลดโมดูลหลักสำเร็จ!")

--[[
    ====================================================================
    [!] GEF DYNAMIC BOX SHIELD - CORE LOGIC
    ====================================================================
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ค้นหา Event สำหรับสร้างไม้จากโค้ดที่คุณให้มา
local BuildPlankEvent = LocalPlayer:WaitForChild("Backpack"):WaitForChild("Hammer"):WaitForChild("BuildPlank")
local RoadPart = workspace:FindFirstChild("Road") and workspace.Road:GetChildren()[16] or workspace

getgenv().GEF_Core = {
    Active = false,
    BoxSize = 8, -- ขนาดความกว้างของกล่องรอบตัว
    BuildInterval = 0.1, -- ความเร็วในการยิงรีโมทสร้างไม้
    
    StartBuilding = function()
        task.spawn(function()
            while getgenv().GEF_Core.Active do
                pcall(function()
                    local character = LocalPlayer.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        local p = rootPart.Position
                        local size = getgenv().GEF_Core.BoxSize
                        
                        -- คำนวณพิกัดสร้างไม้ 4 ด้านรอบตัวเรา ให้ขยับตามตัวเราแบบ Real-time
                        -- ด้านหน้า -> ด้านหลัง -> ด้านซ้าย -> ด้านขวา
                        local corners = {
                            {Vector3.new(p.X - size, p.Y - 2, p.Z - size), Vector3.new(p.X + size, p.Y - 2, p.Z - size)},
                            {Vector3.new(p.X - size, p.Y - 2, p.Z + size), Vector3.new(p.X + size, p.Y - 2, p.Z + size)},
                            {Vector3.new(p.X - size, p.Y - 2, p.Z - size), Vector3.new(p.X - size, p.Y - 2, p.Z + size)},
                            {Vector3.new(p.X + size, p.Y - 2, p.Z - size), Vector3.new(p.X + size, p.Y - 2, p.Z + size)},
                        }
                        
                        for _, wall in ipairs(corners) do
                            BuildPlankEvent:FireServer(wall[1], wall[2], RoadPart, RoadPart, Vector3.new(0, 1, 0))
                        end
                    end
                end)
                task.wait(getgenv().GEF_Core.BuildInterval)
            end
        end)
    end
}

print("[GEF Config]: โหลดระบบคำนวณพิกัดกล่องตามตัวผู้เล่นสำเร็จ!")

--[[
    ====================================================================
    [!] GEF DYNAMIC BOX SHIELD - UI MODULE
    ====================================================================
--]]

local ScreenGui = getgenv().GEF_GuiParent
local ToggleBtn = getgenv().GEF_ToggleBtn
local Core = getgenv().GEF_Core

if not ScreenGui or not Core then
    warn("[GEF UI]: กรุณารัน Loader และ Config ก่อนเปิด UI")
    return
end

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 150)
Main.Position = UDim2.new(0.5, -130, 0.4, -75)
Main.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
Main.Active, Main.Draggable = true, true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "  GEF DYNAMIC BOX SHIELD"
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 11

local List = Instance.new("UIListLayout", Main)
List.Padding = UDim.new(0, 8)
List.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function styleBtn(btn)
    btn.Size = UDim2.new(0.9, 0, 0, 36)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
end

local ShieldBtn = Instance.new("TextButton", Main)
ShieldBtn.BackgroundColor3 = Color3.fromRGB(45, 60, 110)
ShieldBtn.Text = "🛡️ สร้างกล่องล้อมรอบตัว: ปิด"
styleBtn(ShieldBtn)

ShieldBtn.MouseButton1Click:Connect(function()
    Core.Active = not Core.Active
    if Core.Active then
        ShieldBtn.Text = "🛡️ สร้างกล่องล้อมรอบตัว: เปิด"
        ShieldBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        Core.StartBuilding()
    else
        ShieldBtn.Text = "🛡️ สร้างกล่องล้อมรอบตัว: ปิด"
        ShieldBtn.BackgroundColor3 = Color3.fromRGB(45, 60, 110)
    end
end)

ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

print("[GEF UI]: โหลดหน้าต่างเมนูสำเร็จ!")
