--[[
    ====================================================================
    [!] NOS [🦇] FORSAKEN HUB - LOADER MODULE
    ====================================================================
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- สร้างปุ่มเปิด/ปิดเมนูลอย (NOS Toggle)
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "NOS_ForsakenHub"

local Toggle = Instance.new("TextButton", ScreenGui)
Toggle.Size = UDim2.new(0, 40, 0, 40)
Toggle.Position = UDim2.new(0.05, 0, 0.15, 0)
Toggle.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
Toggle.Text = "NOS"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 10
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1, 0)

-- ส่งข้อมูลข้ามไฟล์ผ่านตัวแปรกลาง getgenv()
getgenv().NOS_GUI_Parent = ScreenGui
getgenv().NOS_ToggleBtn = Toggle

print("[NOS Loader]: โหลดโมดูลหลักสำเร็จ!")

--[[
    ====================================================================
    [!] NOS [🦇] FORSAKEN HUB - CONFIG & CORE LOGIC
    ====================================================================
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer
local RemoteEvent = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent")

local function createBuf(bytes)
    local b = buffer.create(#bytes)
    for i = 1, #bytes do buffer.writeu8(b, i - 1, bytes[i]) end
    return b
end

getgenv().NOS_Core = {
    TriggerBlock = function()
        pcall(function()
            firesignal(RemoteEvent.OnClientEvent, "UseActorAbility", { createBuf({3, 5, 0, 0, 0, 66, 108, 111, 99, 105}) })
            firesignal(RemoteEvent.OnClientEvent, 5, { createBuf({3, 10, 0, 0, 0, 82, 101, 115, 105, 115, 116, 97, 110, 99, 105}) })
            
            local payloadData = {
                MaxLevel = createBuf({2, 0, 0, 0, 0, 0, 0, 36, 64}),
                Description = createBuf({3, 99, 0, 0, 0, 77, 97, 107, 101, 115, 32, 121, 111, 117, 32, 108, 101, 115, 115, 32, 115, 117, 115, 99, 101, 112, 116, 105, 98, 108, 101, 32, 116, 111, 32, 100, 97, 109, 97, 103, 101, 46}),
                Duration = createBuf({2, 0, 0, 0, 0, 0, 0, 240, 63}),
                Stackable = createBuf({1, 0}),
                Level = createBuf({2, 0, 0, 0, 0, 0, 0, 20, 64})
            }
            
            firesignal(RemoteEvent.OnClientEvent, 3, {
                createBuf({3, 10, 0, 0, 0, 82, 101, 115, 105, 115, 116, 97, 110, 99, 105}),
                {
                    Removed = createBuf({0}),
                    Data = payloadData,
                    Character = LocalPlayer.Character,
                    Player = LocalPlayer,
                    TimePast = createBuf({2, 0, 0, 0, 0, 0, 0, 0, 0}),
                    Applied = createBuf({0}),
                    Level = createBuf({2, 0, 0, 0, 0, 0, 0, 20, 64}),
                    AppliedFrom = createBuf({3, 4, 0, 0, 0, 78, 111, 110, 101}),
                    TimeRequired = createBuf({2, 0, 0, 0, 0, 0, 0, 240, 63})
                },
                payloadData
            })
        end)
    end,

    ToggleNoLag = function(state)
        pcall(function()
            local Lighting = game:GetService("Lighting")
            Lighting.GlobalShadows = not state
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.Material = state and Enum.Material.SmoothPlastic or Enum.Material.Plastic
                    obj.CastShadow = not state
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                    obj.Enabled = not state
                end
            end
        end)
    end
}

print("[NOS Config]: โหลดฟังก์ชันแกนหลักสำเร็จ!")

--[[
    ====================================================================
    [!] NOS [🦇] FORSAKEN HUB - UI MODULE
    ====================================================================
--]]

local ScreenGui = getgenv().NOS_GUI_Parent
local ToggleBtn = getgenv().NOS_ToggleBtn
local Core = getgenv().NOS_Core

if not ScreenGui or not Core then
    warn("[NOS UI]: กรุณารัน Loader และ Config ก่อนเปิด UI")
    return
end

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 170)
Main.Position = UDim2.new(0.5, -130, 0.4, -85)
Main.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
Main.Active, Main.Draggable = true, true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "  [NOS 🦇] FORSAKEN"
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12

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

local BlockBtn = Instance.new("TextButton", Main)
BlockBtn.BackgroundColor3 = Color3.fromRGB(45, 60, 110)
BlockBtn.Text = "🛡️ บล็อกป้องกัน (Guest 1337)"
styleBtn(BlockBtn)
BlockBtn.MouseButton1Click:Connect(function()
    Core.TriggerBlock()
end)

local NoLagBtn = Instance.new("TextButton", Main)
NoLagBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
NoLagBtn.Text = "⚡ No-Lag Mode: OFF"
styleBtn(NoLagBtn)
local lagState = false
NoLagBtn.MouseButton1Click:Connect(function()
    lagState = not lagState
    Core.ToggleNoLag(lagState)
    NoLagBtn.Text = lagState and "⚡ No-Lag Mode: ON" or "⚡ No-Lag Mode: OFF"
    NoLagBtn.BackgroundColor3 = lagState and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(35, 40, 55)
end)

ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

print("[NOS UI]: โหลดหน้าต่างเมนูสำเร็จ!")
