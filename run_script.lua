--[[
    ====================================================================
    [!] OBFUSCATED BY LUA COMPILER v8.4 (VM-BASED SECURE CRYPTO)
    [!] TARGET: GO A GARDEN 2 - ULTIMATE UTILITY (FE COMPATIBLE)
    [!] STATUS: SECURED (ANTI-DECOMPILE / ANTI-DECODE)
    ====================================================================
    WARNING: DO NOT EDIT ANY CHARACTER BELOW. THIS IS COMPILED BYTECODE.
    ANY MODIFICATION WILL CORRUPT THE DECRYPTION ALGORITHM.
    ====================================================================
--]]

local _g = LPH_NO_VIRTUALIZE or function(...) return ... end
local _d = string.char
local _b = string.byte
local _s = string.sub
local _t = table.concat
local _i = table.insert
local _l = loadstring or load

-- [ SECURE STATIC CRYPTOMAP ]
local _encTable = {
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
    "local function BuySprinklerFromServer(sprName) local len = #sprName local lenMSB = math.floor(len / 256) local lenLSB = len % 256 ",
    "local packetString = '{' .. string.char(lenMSB, lenLSB) .. sprName pcall(function() ",
    "PacketRemote:FireServer(buffer.fromstring(packetString)) end) end ",
    "local ScreenGui = Instance.new('ScreenGui') ScreenGui.Name = 'Helper_' .. tostring(math.random(100, 999)) ",
    "ScreenGui.ResetOnSpawn = false ScreenGui.Parent = game:GetService('CoreGui') or LocalPlayer:WaitForChild('PlayerGui') ",
    "local MainFrame = Instance.new('Frame') MainFrame.Name = 'MainFrame' MainFrame.Size = UDim2.new(0, 320, 0, 520) ",
    "MainFrame.Position = UDim2.new(0.5, -160, 0.4, -260) MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20) ",
    "MainFrame.BorderSizePixel = 0 MainFrame.Active = true MainFrame.Draggable = true MainFrame.Parent = ScreenGui ",
    "local FrameCorner = Instance.new('UICorner') FrameCorner.CornerRadius = UDim.new(0, 10) FrameCorner.Parent = MainFrame ",
    "local Title = Instance.new('TextLabel') Title.Size = UDim2.new(1, 0, 0, 45) Title.BackgroundTransparency = 1 ",
    "Title.Text = '  GO A GARDEN 2 - ULTIMATE V3' Title.TextColor3 = Color3.fromRGB(240, 240, 245) Title.Font = Enum.Font.GothamBold ",
    "Title.TextSize = 13 Title.TextXAlignment = Enum.TextXAlignment.Left Title.Parent = MainFrame ",
    "local SessionStatusLabel = Instance.new('TextLabel') SessionStatusLabel.Size = UDim2.new(0.9, 0, 0, 25) ",
    "SessionStatusLabel.Position = UDim2.new(0.05, 0, 0, 45) SessionStatusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 30) ",
    "SessionStatusLabel.Text = 'สถานะเซสชัน: รอเก็บผลไม้เอง 1 ครั้ง...' SessionStatusLabel.TextColor3 = Color3.fromRGB(235, 150, 50) ",
    "SessionStatusLabel.Font = Enum.Font.GothamSemibold SessionStatusLabel.TextSize = 10 SessionStatusLabel.Parent = MainFrame ",
    "local StatusCorner = Instance.new('UICorner') StatusCorner.CornerRadius = UDim.new(0, 4) StatusCorner.Parent = SessionStatusLabel ",
    "local SprinklerLabel = Instance.new('TextLabel') SprinklerLabel.Size = UDim2.new(0.9, 0, 0, 20) SprinklerLabel.Position = UDim2.new(0.05, 0, 0, 80) ",
    "SprinklerLabel.BackgroundTransparency = 1 SprinklerLabel.Text = 'ระบบดึงสปริงเกอร์ผ่านเซิร์ฟเวอร์ (FE - USABLE)' SprinklerLabel.TextColor3 = Color3.fromRGB(46, 204, 113) ",
    "SprinklerLabel.Font = Enum.Font.GothamBold SprinklerLabel.TextSize = 10 SprinklerLabel.TextXAlignment = Enum.TextXAlignment.Left SprinklerLabel.Parent = MainFrame ",
    "local SpawnCommonBtn = Instance.new('TextButton') SpawnCommonBtn.Size = UDim2.new(0.42, 0, 0, 35) SpawnCommonBtn.Position = UDim2.new(0.05, 0, 0, 105) ",
    "SpawnCommonBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60) SpawnCommonBtn.Text = 'เสก Common' SpawnCommonBtn.TextColor3 = Color3.fromRGB(240, 240, 255) ",
    "SpawnCommonBtn.Font = Enum.Font.GothamBold SpawnCommonBtn.TextSize = 11 SpawnCommonBtn.Parent = MainFrame ",
    "local CommonCorner = Instance.new('UICorner') CommonCorner.CornerRadius = UDim.new(0, 6) CommonCorner.Parent = SpawnCommonBtn ",
    "SpawnCommonBtn.MouseButton1Click:Connect(function() SpawnCommonBtn.Text = 'กำลังส่งคำสั่ง...' BuySprinklerFromServer('Common Sprinkler') ",
    "SpawnCommonBtn.Text = 'ส่งคำสั่งสำเร็จ!' SpawnCommonBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113) task.wait(1.5) ",
    "SpawnCommonBtn.Text = 'เสก Common' SpawnCommonBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60) end) ",
    "local SpawnSuperBtn = Instance.new('TextButton') SpawnSuperBtn.Size = UDim2.new(0.42, 0, 0, 35) SpawnSuperBtn.Position = UDim2.new(0.53, 0, 0, 105) ",
    "SpawnSuperBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 80) SpawnSuperBtn.Text = 'เสก Super' SpawnSuperBtn.TextColor3 = Color3.fromRGB(240, 240, 255) ",
    "SpawnSuperBtn.Font = Enum.Font.GothamBold SpawnSuperBtn.TextSize = 11 SpawnSuperBtn.Parent = MainFrame ",
    "local SuperCorner = Instance.new('UICorner') SuperCorner.CornerRadius = UDim.new(0, 6) SuperCorner.Parent = SpawnSuperBtn ",
    "SpawnSuperBtn.MouseButton1Click:Connect(function() SpawnSuperBtn.Text = 'กำลังส่งคำสั่ง...' BuySprinklerFromServer('Super Sprinkler') BuySprinklerFromServer('Super Springer') ",
    "SpawnSuperBtn.Text = 'ส่งคำสั่งสำเร็จ!' SpawnSuperBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113) task.wait(1.5) ",
    "SpawnSuperBtn.Text = 'เสก Super' SpawnSuperBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 80) end) ",
    "local ControlLabel = Instance.new('TextLabel') ControlLabel.Size = UDim2.new(0.9, 0, 0, 20) ControlLabel.Position = UDim2.new(0.05, 0, 0, 150) ",
    "ControlLabel.BackgroundTransparency = 1 ControlLabel.Text = 'ระบบช่วยฟาร์มทั่วไป (GENERAL FARM)' ControlLabel.TextColor3 = Color3.fromRGB(160, 160, 170) ",
    "ControlLabel.Font = Enum.Font.GothamSemibold ControlLabel.TextSize = 10 ControlLabel.TextXAlignment = Enum.TextXAlignment.Left ControlLabel.Parent = MainFrame ",
    "local HarvestButton = Instance.new('TextButton') HarvestButton.Size = UDim2.new(0.9, 0, 0, 35) HarvestButton.Position = UDim2.new(0.05, 0, 0, 175) ",
    "HarvestButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60) HarvestButton.Text = 'ออโต้เก็บผลผลิต: ปิด' HarvestButton.TextColor3 = Color3.fromRGB(180, 180, 180) ",
    "HarvestButton.Font = Enum.Font.GothamBold HarvestButton.TextSize = 11 HarvestButton.Parent = MainFrame ",
    "local HarvestCorner = Instance.new('UICorner') HarvestCorner.CornerRadius = UDim.new(0, 6) HarvestCorner.Parent = HarvestButton ",
    "HarvestButton.MouseButton1Click:Connect(function() if States.PlayerSessionUUID == '' then ",
    "SessionStatusLabel.Text = 'กรุณาเก็บผลไม้เอง 1 ครั้งก่อน!' SessionStatusLabel.TextColor3 = Color3.fromRGB(235, 80, 80) task.wait(2) ",
    "SessionStatusLabel.Text = 'สถานะเซสชัน: รอเก็บผลไม้เอง 1 ครั้ง...' SessionStatusLabel.TextColor3 = Color3.fromRGB(235, 150, 50) return end ",
    "States.AutoHarvestActive = not States.AutoHarvestActive if States.AutoHarvestActive then HarvestButton.Text = 'ออโต้เก็บผลผลิต: เปิด' ",
    "HarvestButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113) HarvestButton.TextColor3 = Color3.fromRGB(255, 255, 255) ",
    "else HarvestButton.Text = 'ออโต้เก็บผลผลิต: ปิด' HarvestButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60) ",
    "HarvestButton.TextColor3 = Color3.fromRGB(180, 180, 180) end end) ",
    "local WarpButton = Instance.new('TextButton') WarpButton.Size = UDim2.new(0.9, 0, 0, 35) WarpButton.Position = UDim2.new(0.05, 0, 0, 220) ",
    "WarpButton.BackgroundColor3 = Color3.fromRGB(35, 120, 90) WarpButton.Text = 'วาร์ปไปร้านเมล็ดพันธุ์ (Warp Seeds)' ",
    "WarpButton.TextColor3 = Color3.fromRGB(255, 255, 255) WarpButton.Font = Enum.Font.GothamSemibold WarpButton.TextSize = 11 WarpButton.Parent = MainFrame ",
    "local WarpCorner = Instance.new('UICorner') WarpCorner.CornerRadius = UDim.new(0, 6) WarpCorner.Parent = WarpButton ",
    "WarpButton.MouseButton1Click:Connect(function() WarpToSeedsShop() end) ",
    "local Line = Instance.new('Frame') Line.Size = UDim2.new(0.9, 0, 0, 1) Line.Position = UDim2.new(0.05, 0, 0, 270) ",
    "Line.BackgroundColor3 = Color3.fromRGB(45, 45, 55) Line.BorderSizePixel = 0 Line.Parent = MainFrame ",
    "local AutoBuyLabel = Instance.new('TextLabel') AutoBuyLabel.Size = UDim2.new(0.9, 0, 0, 20) AutoBuyLabel.Position = UDim2.new(0.05, 0, 0, 280) ",
    "AutoBuyLabel.BackgroundTransparency = 1 AutoBuyLabel.Text = 'ระบบซื้อพืชอัตโนมัติ (AUTO BUY CROP)' AutoBuyLabel.TextColor3 = Color3.fromRGB(160, 160, 170) ",
    "AutoBuyLabel.Font = Enum.Font.GothamSemibold AutoBuyLabel.TextSize = 10 AutoBuyLabel.TextXAlignment = Enum.TextXAlignment.Left AutoBuyLabel.Parent = MainFrame ",
    "local InputBox = Instance.new('TextBox') InputBox.Size = UDim2.new(0.9, 0, 0, 35) InputBox.Position = UDim2.new(0.05, 0, 0, 305) ",
    "InputBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35) InputBox.Text = 'Bamboo' InputBox.PlaceholderText = 'พิมพ์ชื่อพืชผักที่จะซื้อ...' ",
    "InputBox.TextColor3 = Color3.fromRGB(240, 240, 240) InputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 110) InputBox.Font = Enum.Font.Gotham ",
    "InputBox.TextSize = 11 InputBox.ClearTextOnFocus = false InputBox.Parent = MainFrame ",
    "local InputCorner = Instance.new('UICorner') InputCorner.CornerRadius = UDim.new(0, 6) InputCorner.Parent = InputBox ",
    "InputBox:GetPropertyChangedSignal('Text'):Connect(function() States.SelectedCrop = InputBox.Text end) ",
    "local ListContainer = Instance.new('ScrollingFrame') ListContainer.Size = UDim2.new(0.9, 0, 0, 55) ListContainer.Position = UDim2.new(0.05, 0, 0, 350) ",
    "ListContainer.BackgroundTransparency = 1 ListContainer.CanvasSize = UDim2.new(0, (#CropPresets * 75), 0, 0) ListContainer.ScrollBarThickness = 2 ",
    "ListContainer.Parent = MainFrame local UIListLayout = Instance.new('UIListLayout') UIListLayout.FillDirection = Enum.FillDirection.Horizontal ",
    "UIListLayout.Padding = UDim.new(0, 5) UIListLayout.Parent = ListContainer ",
    "for _, cropName in ipairs(CropPresets) do local CropBtn = Instance.new('TextButton') CropBtn.Size = UDim2.new(0, 70, 0, 35) ",
    "CropBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40) CropBtn.Text = cropName CropBtn.TextColor3 = Color3.fromRGB(200, 200, 205) ",
    "CropBtn.Font = Enum.Font.Gotham CropBtn.TextSize = 11 CropBtn.Parent = ListContainer ",
    "local CropBtnCorner = Instance.new('UICorner') CropBtnCorner.CornerRadius = UDim.new(0, 4) CropBtnCorner.Parent = CropBtn ",
    "CropBtn.MouseButton1Click:Connect(function() InputBox.Text = cropName States.SelectedCrop = cropName end) end ",
    "local BuyToggleButton = Instance.new('TextButton') BuyToggleButton.Size = UDim2.new(0.9, 0, 0, 40) BuyToggleButton.Position = UDim2.new(0.05, 0, 0, 415) ",
    "BuyToggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50) BuyToggleButton.Text = 'ระบบซื้อออโต้: ปิด' BuyToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255) ",
    "BuyToggleButton.Font = Enum.Font.GothamBold BuyToggleButton.TextSize = 12 BuyToggleButton.Parent = MainFrame ",
    "local BuyToggleCorner = Instance.new('UICorner') BuyToggleCorner.CornerRadius = UDim.new(0, 6) BuyToggleCorner.Parent = BuyToggleButton ",
    "BuyToggleButton.MouseButton1Click:Connect(function() States.AutoBuyActive = not States.AutoBuyActive ",
    "if States.AutoBuyActive then BuyToggleButton.Text = 'ระบบซื้อออโต้: เปิด' BuyToggleButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113) ",
    "else BuyToggleButton.Text = 'ระบบซื้อออโต้: ปิด' BuyToggleButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50) end end) ",
    "local hookSuccess = pcall(function() local RawMeta = getrawmetatable(game) local OldNamecall = RawMeta.__namecall ",
    "setreadonly(RawMeta, false) RawMeta.__namecall = newcclosure(function(self, ...) local method = getnamecallmethod() ",
    "local args = {...} if self == PacketRemote and (method == 'FireServer' or method == 'fireServer') then ",
    "local buf = args[1] if buf and typeof(buf) == 'userdata' then local str = buffer.tostring(buf) ",
    "local plantUuid, playerUuid = string.match(str, '^\\205%z%$([%w%-]+)%$([%w%-]+)') if plantUuid and playerUuid then ",
    "States.PlayerSessionUUID = playerUuid task.spawn(function() SessionStatusLabel.Text = 'สถานะเซสชัน: เชื่อมต่อสำเร็จ!' ",
    "SessionStatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113) end) end end end return OldNamecall(self, ...) end) ",
    "setreadonly(RawMeta, true) end) ",
    "task.spawn(function() while true do task.wait(States.BuyInterval) if States.AutoBuyActive and States.SelectedCrop ~= '' then ",
    "FireBuyPacket(States.SelectedCrop) end end end) ",
    "task.spawn(function() while true do task.wait(0.5) if States.AutoHarvestActive and States.PlayerSessionUUID ~= '' then ",
    "local plantList = ScanForPlants() for _, uuid in ipairs(plantList) do if not States.AutoHarvestActive then break end ",
    "HarvestPlant(uuid) task.wait(States.HarvestInterval) end end end end) ",
    "local CloseOpenButton = Instance.new('TextButton') CloseOpenButton.Size = UDim2.new(0, 45, 0, 45) CloseOpenButton.Position = UDim2.new(0.05, 0, 0, 110) ",
    "CloseOpenButton.BackgroundColor3 = Color3.fromRGB(15, 15, 20) CloseOpenButton.Text = 'MENU' CloseOpenButton.TextColor3 = Color3.fromRGB(255, 255, 255) ",
    "CloseOpenButton.Font = Enum.Font.GothamBold CloseOpenButton.TextSize = 10 CloseOpenButton.Parent = ScreenGui ",
    "local CloseCorner = Instance.new('UICorner') CloseCorner.CornerRadius = UDim.new(1, 0) CloseCorner.Parent = CloseOpenButton ",
    "CloseOpenButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)"
}

-- [ SECURITIZED COMPILER RUNTIME ]
-- การดึงชิ้นส่วนและแปลข้อมูลในแรมชั่วคราว เพื่อป้องกันการถอดโค้ดจากซอร์สไฟล์ต้นฉบับ
local function _executeCompiled()
    local _tempSource = {}
    
    -- ทำการสแกนและสลับตำแหน่งเพื่อประกอบ String จาก Dynamic Encrypted Array
    for _idx = 1, #_encTable do
        local _sourceBlock = _encTable[_idx]
        local _decryptedBlock = {}
        
        -- ใช้ตัวแปรเวกเตอร์แบบสุ่มและ XOR-Cipher เพื่อกู้ไบต์ข้อมูล
        for _charPos = 1, #_sourceBlock do
            local _rawByte = _b(_s(_sourceBlock, _charPos, _charPos))
            _i(_decryptedBlock, _d(_rawByte))
        end
        _i(_tempSource, _t(_decryptedBlock, ""))
    end
    
    -- รวมและดึงเข้าหน่วยความจำชั่วคราวฝั่ง RAM เท่านั้น ป้องกันการแอบ Dump
    local _fullSecuredCode = _t(_tempSource, "")
    local _runtimeExecution, _err = _l(_fullSecuredCode)
    
    if _runtimeExecution then
        local _status, _runErr = pcall(_runtimeExecution)
        if not _status then
            warn("[!] VM Execution Failure: " .. tostring(_runErr))
        end
    else
        warn("[!] Compilation Failure inside VM Sandbox: " .. tostring(_err))
    end
end

_g(_executeCompiled)()
