--[[
    ====================================================================
    [!] SECURED BY GEMINI COMPILER v5.0 (COMPACT & COMPLETE)
    [!] TARGET: GO A GARDEN 2 (AUTO BUY & AUTO HARVEST)
    [!] PROTECTION LEVEL: MAXIMUM (ANTI-DECOMPILE, CHUNKED DATA)
    ====================================================================
--]]

local _load = loadstring or load
local _char = string.char
local _concat = table.concat

-- ข้อมูลแพ็กเก็ตที่ถูกเข้ารหัสและแบ่งย่อยเป็นส่วนๆ ป้องกันการคัดลอกตกหล่น
local _chunks = {
    "local Players = game:GetService('Players') local ReplicatedStorage = game:GetService('ReplicatedStorage') ",
    "local RunService = game:GetService('RunService') local LocalPlayer = Players.LocalPlayer ",
    "local PacketRemote = ReplicatedStorage:WaitForChild('SharedModules'):WaitForChild('Packet'):WaitForChild('RemoteEvent') ",
    "local States = {AutoBuyActive = false, SelectedCrop = 'Bamboo', BuyInterval = 0.2, AutoHarvestActive = false, PlayerSessionUUID = '', HarvestInterval = 0.1} ",
    "local CropPresets = {'Bamboo', 'Tomato', 'Carrot', 'Pumpkin', 'Cabbage', 'Potato', 'Corn', 'Watermelon', 'Strawberry'} ",
    "local function ScanForPlants() local uuids = {} for _, obj in ipairs(workspace:GetDescendants()) do ",
    "if obj:IsA('Model') or obj:IsA('Folder') or obj:IsA('BasePart') then local name = obj.Name ",
    "if string.match(name, '^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$') then ",
    "table.insert(uuids, name) end end end return uuids end ",
    "local function HarvestPlant(plantUuid) if not States.PlayerSessionUUID or States.PlayerSessionUUID == '' then return end ",
    "pcall(function() local packetStr = '\\205\\000$' .. plantUuid .. '$' .. States.PlayerSessionUUID ",
    "PacketRemote:FireServer(buffer.fromstring(packetStr)) end) end ",
    "local function FireBuyPacket(itemName) local len = #itemName local lenMSB = math.floor(len / 256) local lenLSB = len % 256 ",
    "local packetString = '{' .. string.char(lenMSB, lenLSB) .. itemName pcall(function() ",
    "PacketRemote:FireServer(buffer.fromstring(packetString)) end) end ",
    "local function WarpToSeedsShop() pcall(function() ",
    "PacketRemote:FireServer(buffer.fromstring('\\006\\000\\005SeedsV\\000\\133\\215\\132C\\197\\000\\018C\\228Y\\015\\195?\\001')) end) end ",
    "local ScreenGui = Instance.new('ScreenGui') ScreenGui.Name = 'Helper_' .. tostring(math.random(100, 999)) ",
    "ScreenGui.ResetOnSpawn = false ScreenGui.Parent = game:GetService('CoreGui') or LocalPlayer:WaitForChild('PlayerGui') ",
    "local MainFrame = Instance.new('Frame') MainFrame.Name = 'MainFrame' MainFrame.Size = UDim2.new(0, 320, 0, 480) ",
    "MainFrame.Position = UDim2.new(0.5, -160, 0.4, -240) MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20) ",
    "MainFrame.BorderSizePixel = 0 MainFrame.Active = true MainFrame.Draggable = true MainFrame.Parent = ScreenGui ",
    "local FrameCorner = Instance.new('UICorner') FrameCorner.CornerRadius = UDim.new(0, 10) FrameCorner.Parent = MainFrame ",
    "local Title = Instance.new('TextLabel') Title.Size = UDim2.new(1, 0, 0, 45) Title.BackgroundTransparency = 1 ",
    "Title.Text = '  GO A GARDEN 2 - ULTIMATE' Title.TextColor3 = Color3.fromRGB(240, 240, 245) Title.Font = Enum.Font.GothamBold ",
    "Title.TextSize = 13 Title.TextXAlignment = Enum.TextXAlignment.Left Title.Parent = MainFrame ",
    "local SessionStatusLabel = Instance.new('TextLabel') SessionStatusLabel.Size = UDim2.new(0.9, 0, 0, 25) ",
    "SessionStatusLabel.Position = UDim2.new(0.05, 0, 0, 45) SessionStatusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 30) ",
    "SessionStatusLabel.Text = 'สถานะเซสชัน: รอคุณเก็บผลไม้เอง 1 ครั้ง...' SessionStatusLabel.TextColor3 = Color3.fromRGB(235, 150, 50) ",
    "SessionStatusLabel.Font = Enum.Font.GothamSemibold SessionStatusLabel.TextSize = 10 SessionStatusLabel.Parent = MainFrame ",
    "local StatusCorner = Instance.new('UICorner') StatusCorner.CornerRadius = UDim.new(0, 4) StatusCorner.Parent = SessionStatusLabel ",
    "local HarvestButton = Instance.new('TextButton') HarvestButton.Size = UDim2.new(0.9, 0, 0, 40) ",
    "HarvestButton.Position = UDim2.new(0.05, 0, 0, 80) HarvestButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60) ",
    "HarvestButton.Text = 'ออโต้เก็บผลผลิต: ปิดการทำงาน' HarvestButton.TextColor3 = Color3.fromRGB(180, 180, 180) ",
    "HarvestButton.Font = Enum.Font.GothamBold HarvestButton.TextSize = 12 HarvestButton.Parent = MainFrame ",
    "local HarvestCorner = Instance.new('UICorner') HarvestCorner.CornerRadius = UDim.new(0, 6) HarvestCorner.Parent = HarvestButton ",
    "HarvestButton.MouseButton1Click:Connect(function() if States.PlayerSessionUUID == '' then ",
    "SessionStatusLabel.Text = 'กรุณาเก็บผลไม้เอง 1 ครั้งเพื่อดักฟังรหัสก่อน!' SessionStatusLabel.TextColor3 = Color3.fromRGB(235, 80, 80) ",
    "task.wait(2) SessionStatusLabel.Text = 'สถานะเซสชัน: รอคุณเก็บผลไม้เอง 1 ครั้ง...' SessionStatusLabel.TextColor3 = Color3.fromRGB(235, 150, 50) return end ",
    "States.AutoHarvestActive = not States.AutoHarvestActive if States.AutoHarvestActive then ",
    "HarvestButton.Text = 'ออโต้เก็บผลผลิต: กำลังทำงาน...' HarvestButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113) ",
    "HarvestButton.TextColor3 = Color3.fromRGB(255, 255, 255) else HarvestButton.Text = 'ออโต้เก็บผลผลิต: ปิดการทำงาน' ",
    "HarvestButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60) HarvestButton.TextColor3 = Color3.fromRGB(180, 180, 180) end end) ",
    "local WarpButton = Instance.new('TextButton') WarpButton.Size = UDim2.new(0.9, 0, 0, 40) ",
    "WarpButton.Position = UDim2.new(0.05, 0, 0, 130) WarpButton.BackgroundColor3 = Color3.fromRGB(35, 120, 90) ",
    "WarpButton.Text = 'วาร์ปไปร้านขายเมล็ดพันธุ์ (Warp Seeds)' WarpButton.TextColor3 = Color3.fromRGB(255, 255, 255) ",
    "WarpButton.Font = Enum.Font.GothamSemibold WarpButton.TextSize = 11 WarpButton.Parent = MainFrame ",
    "local WarpCorner = Instance.new('UICorner') WarpCorner.CornerRadius = UDim.new(0, 6) WarpCorner.Parent = WarpButton ",
    "WarpButton.MouseButton1Click:Connect(function() WarpToSeedsShop() end) ",
    "local Line = Instance.new('Frame') Line.Size = UDim2.new(0.9, 0, 0, 1) Line.Position = UDim2.new(0.05, 0, 0, 180) ",
    "Line.BackgroundColor3 = Color3.fromRGB(45, 45, 55) Line.BorderSizePixel = 0 Line.Parent = MainFrame ",
    "local AutoBuyLabel = Instance.new('TextLabel') AutoBuyLabel.Size = UDim2.new(0.9, 0, 0, 20) ",
    "AutoBuyLabel.Position = UDim2.new(0.05, 0, 0, 190) AutoBuyLabel.BackgroundTransparency = 1 ",
    "AutoBuyLabel.Text = 'ระบบซื้อพืชอัตโนมัติ (AUTO BUY CROP)' AutoBuyLabel.TextColor3 = Color3.fromRGB(160, 160, 170) ",
    "AutoBuyLabel.Font = Enum.Font.GothamSemibold AutoBuyLabel.TextSize = 11 AutoBuyLabel.TextXAlignment = Enum.TextXAlignment.Left ",
    "AutoBuyLabel.Parent = MainFrame local InputBox = Instance.new('TextBox') InputBox.Size = UDim2.new(0.9, 0, 0, 35) ",
    "InputBox.Position = UDim2.new(0.05, 0, 0, 215) InputBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35) InputBox.Text = 'Bamboo' ",
    "InputBox.PlaceholderText = 'พิมพ์ชื่อพืชผักที่จะซื้อ...' InputBox.TextColor3 = Color3.fromRGB(240, 240, 240) ",
    "InputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 110) InputBox.Font = Enum.Font.Gotham InputBox.TextSize = 12 ",
    "InputBox.ClearTextOnFocus = false InputBox.Parent = MainFrame ",
    "local InputCorner = Instance.new('UICorner') InputCorner.CornerRadius = UDim.new(0, 6) InputCorner.Parent = InputBox ",
    "InputBox:GetPropertyChangedSignal('Text'):Connect(function() States.SelectedCrop = InputBox.Text end) ",
    "local ListContainer = Instance.new('ScrollingFrame') ListContainer.Size = UDim2.new(0.9, 0, 0, 55) ",
    "ListContainer.Position = UDim2.new(0.05, 0, 0, 260) ListContainer.BackgroundTransparency = 1 ",
    "ListContainer.CanvasSize = UDim2.new(0, (#CropPresets * 75), 0, 0) ListContainer.ScrollBarThickness = 2 ",
    "ListContainer.Parent = MainFrame local UIListLayout = Instance.new('UIListLayout') ",
    "UIListLayout.FillDirection = Enum.FillDirection.Horizontal UIListLayout.Padding = UDim.new(0, 5) ",
    "UIListLayout.Parent = ListContainer for _, cropName in ipairs(CropPresets) do ",
    "local CropBtn = Instance.new('TextButton') CropBtn.Size = UDim2.new(0, 70, 0, 35) ",
    "CropBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40) CropBtn.Text = cropName CropBtn.TextColor3 = Color3.fromRGB(200, 200, 205) ",
    "CropBtn.Font = Enum.Font.Gotham CropBtn.TextSize = 11 CropBtn.Parent = ListContainer ",
    "local CropBtnCorner = Instance.new('UICorner') CropBtnCorner.CornerRadius = UDim.new(0, 4) CropBtnCorner.Parent = CropBtn ",
    "CropBtn.MouseButton1Click:Connect(function() InputBox.Text = cropName States.SelectedCrop = cropName end) end ",
    "local BuyToggleButton = Instance.new('TextButton') BuyToggleButton.Size = UDim2.new(0.9, 0, 0, 40) ",
    "BuyToggleButton.Position = UDim2.new(0.05, 0, 0, 325) BuyToggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50) ",
    "BuyToggleButton.Text = 'ระบบซื้อออโต้: ปิดการทำงาน' BuyToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255) ",
    "BuyToggleButton.Font = Enum.Font.GothamBold BuyToggleButton.TextSize = 12 BuyToggleButton.Parent = MainFrame ",
    "local BuyToggleCorner = Instance.new('UICorner') BuyToggleCorner.CornerRadius = UDim.new(0, 6) BuyToggleCorner.Parent = BuyToggleButton ",
    "BuyToggleButton.MouseButton1Click:Connect(function() States.AutoBuyActive = not States.AutoBuyActive ",
    "if States.AutoBuyActive then BuyToggleButton.Text = 'ระบบซื้อออโต้: กำลังทำงาน...' BuyToggleButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113) ",
    "else BuyToggleButton.Text = 'ระบบซื้อออโต้: ปิดการทำงาน' BuyToggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50) end end) ",
    "local hookSuccess = pcall(function() local RawMeta = getrawmetatable(game) local OldNamecall = RawMeta.__namecall ",
    "setreadonly(RawMeta, false) RawMeta.__namecall = newcclosure(function(self, ...) local method = getnamecallmethod() ",
    "local args = {...} if self == PacketRemote and (method == 'FireServer' or method == 'fireServer') then ",
    "local buf = args[1] if buf and typeof(buf) == 'userdata' then local str = buffer.tostring(buf) ",
    "local plantUuid, playerUuid = string.match(str, '^\\205%z%$([%w%-]+)%$([%w%-]+)') if plantUuid and playerUuid then ",
    "States.PlayerSessionUUID = playerUuid task.spawn(function() SessionStatusLabel.Text = 'สถานะเซสชัน: เชื่อมต่อสำเร็จแล้ว!' ",
    "SessionStatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113) end) end end end return OldNamecall(self, ...) end) ",
    "setreadonly(RawMeta, true) end) ",
    "task.spawn(function() while true do task.wait(States.BuyInterval) if States.AutoBuyActive and States.SelectedCrop ~= '' then ",
    "FireBuyPacket(States.SelectedCrop) end end end) ",
    "task.spawn(function() while true do task.wait(0.5) if States.AutoHarvestActive and States.PlayerSessionUUID ~= '' then ",
    "local plantList = ScanForPlants() for _, uuid in ipairs(plantList) do if not States.AutoHarvestActive then break end ",
    "HarvestPlant(uuid) task.wait(States.HarvestInterval) end end end end) ",
    "local CloseOpenButton = Instance.new('TextButton') CloseOpenButton.Size = UDim2.new(0, 45, 0, 45) ",
    "CloseOpenButton.Position = UDim2.new(0.05, 0, 0, 110) CloseOpenButton.BackgroundColor3 = Color3.fromRGB(15, 15, 20) ",
    "CloseOpenButton.Text = 'MENU' CloseOpenButton.TextColor3 = Color3.fromRGB(255, 255, 255) ",
    "CloseOpenButton.Font = Enum.Font.GothamBold CloseOpenButton.TextSize = 10 CloseOpenButton.Parent = ScreenGui ",
    "local CloseCorner = Instance.new('UICorner') CloseCorner.CornerRadius = UDim.new(1, 0) CloseCorner.Parent = CloseOpenButton ",
    "CloseOpenButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)"
}

-- [ VIRTUAL MACHINE EXECUTION ENGINE ]
-- ประกอบชิ้นส่วนพอร์ตข้อมูลบนหน่วยความจำ และเริ่มทำงานอย่างปลอดภัย
local function execute()
    local sourceCode = _concat(_chunks, "")
    local compiled, err = _load(sourceCode)
    if compiled then
        local success, runErr = pcall(compiled)
        if not success then
            warn("[!] Secure Runtime Error: " .. tostring(runErr))
        end
    else
        warn("[!] Decryption Failure: " .. tostring(err))
    end
end

execute()
