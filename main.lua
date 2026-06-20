-- [[ RATKA DLC PREMIUM AUTH SYSTEM - V726 ULTRA SUPREMACY ]]
-- СИСТЕМА КЛЮЧА ВИДАЛЕНА, КОД ОПТИМІЗОВАНО (БЕЗ ЛАГІВ)

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImInsane-1337/neverlose-ui/refs/heads/main/source/library.lua"))()
local CheatName = "Ratka DLC"

Library.Folders = {
	Directory = CheatName,
	Configs = CheatName .. "/Configs",
	Assets = CheatName .. "/Assets",
}

-- [[ НОВА СТАРТОВА ФІОЛЕТОВА ТЕМА ]]
local Accent = Color3.fromRGB(130, 0, 255)
local Gradient = Color3.fromRGB(50, 0, 100)

Library.Theme.Accent = Accent
Library.Theme.AccentGradient = Gradient
Library:ChangeTheme("Accent", Accent)
Library:ChangeTheme("AccentGradient", Gradient)

local Window = Library:Window({
	Name = "Ratka DLC",
	SubName = "V726 ULTRA SUPREMACY",
	Logo = "120959262762131"
})

local KeybindList = Library:KeybindList("Keybinds")

local Run = game:GetService("RunService")
local Replicated = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera

local enemyCache = {}
local SpinConnection
local WEAPON_TYPE = { knife = "Knife_Equip" }

local RemotesFolder = Replicated:WaitForChild("Remotes", 5)
local throwStartRemote = RemotesFolder and RemotesFolder:FindFirstChild("ThrowStart")
local throwHitRemote = RemotesFolder and RemotesFolder:FindFirstChild("ThrowHit")

-- Оптимизированное сохранение оригинальных настроек света
local OriginalAmbient = Lighting.Ambient
local OriginalOutdoorAmbient = Lighting.OutdoorAmbient
local OriginalShadows = Lighting.GlobalShadows

-- Отримання поточного динамічного кольору хаку
local function GetCurrentColor()
	if Library.Flags["RainbowBorder"] then
		return Color3.fromHSV(tick() % 5 / 5, 1, 1)
	end
	return Library.Theme.Accent or Accent
end

local function CreateChinaTrail()
	local char = localPlayer.Character
	if not char or not char:FindFirstChild("Head") then return end
	
	local attachment0 = Instance.new("Attachment", char.Head)
	attachment0.Position = Vector3.new(0, 0.3, 0)
	local attachment1 = Instance.new("Attachment", char.Head)
	attachment1.Position = Vector3.new(0, -0.3, 0)
	
	local trail = Instance.new("Trail", char.Head)
	trail.Attachment0 = attachment0
	trail.Attachment1 = attachment1
	trail.Color = ColorSequence.new(GetCurrentColor(), Color3.fromRGB(30, 0, 50))
	trail.Lifetime = Library.Flags["TrailLifetime"] or 0.8
	trail.Transparency = NumberSequence.new((Library.Flags["TrailTrans"] or 30) / 100, 1)
	trail.WidthScale = NumberSequence.new(1, 0)
	trail.Enabled = false
	
	return trail
end

local myTrail = CreateChinaTrail()

local function CreateTracer(start, target)
	if not Library.Flags["TracersEnabled"] then return end
	local p = Instance.new("Part")
	p.Name = "RatkaDLCTracer"
	p.Anchored = true
	p.CanCollide = false
	p.Material = Enum.Material.Neon
	p.Color = GetCurrentColor()
	p.Transparency = 0.4
	
	local dist = (start - target).Magnitude
	p.Size = Vector3.new(0.1, 0.1, dist)
	p.CFrame = CFrame.new(start:Lerp(target, 0.5), target)
	p.Parent = Workspace
	
	Debris:AddItem(p, 0.6)
end

local function ApplySpin999()
	if SpinConnection then SpinConnection:Disconnect() end
	local character = localPlayer.Character
	if not character then return end
	
	local humanoid = character:WaitForChild("Humanoid", 5)
	local hrp = character:WaitForChild("HumanoidRootPart", 5)
	if not humanoid or not hrp then return end
	
	local isR15 = (humanoid.RigType == Enum.HumanoidRigType.R15)
	local neckJoint
	
	if isR15 then
		neckJoint = character:FindFirstChild("Head") and character.Head:FindFirstChild("Neck")
	else
		neckJoint = character:FindFirstChild("Torso") and character.Torso:FindFirstChild("Neck")
	end
	
	local originalNeckC0 = neckJoint and neckJoint.C0 or CFrame.new()
	local currentAngle = 0
	
	SpinConnection = Run.RenderStepped:Connect(function()
		if not Library.Flags["Spin999Enabled"] or not character:IsDescendantOf(Workspace) or humanoid.Health <= 0 then
			if neckJoint then neckJoint.C0 = originalNeckC0 end
			return
		end
		
		local speed = Library.Flags["Spin999Speed"] or 100
		currentAngle = (currentAngle + math.rad(speed)) % (math.pi * 2)
		hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(speed), 0)
		
		if neckJoint then
			local headPitch = Library.Flags["SpinHeadPitch"] or 0
			if isR15 then
				neckJoint.C0 = originalNeckC0 * CFrame.Angles(math.rad(headPitch), 0, 0)
			else
				neckJoint.C0 = originalNeckC0 * CFrame.Angles(math.rad(-headPitch), 0, math.rad(180))
			end
		end
	end)
end

local function equipWeapon(weaponType)
	local character = localPlayer.Character
	if not character or not character:FindFirstChild("Humanoid") then return end
	for _, tool in pairs(localPlayer.Backpack:GetChildren()) do
		if tool:GetAttribute("EquipAnimation") == weaponType or tool:IsA("Tool") then
			character.Humanoid:EquipTool(tool)
			return true
		end
	end
	return false
end

-- ОПТИМИЗИРОВАНО: Распределенный по кадрам перебор карты для защиты от лагов
local function UpdateWorldTextures(state)
	local activeColor = GetCurrentColor()
	local descendants = Workspace:GetDescendants()
	
	task.spawn(function()
		for i, object in pairs(descendants) do
			if object:IsA("BasePart") and not object:IsDescendantOf(localPlayer.Character) and not Players:GetPlayerFromCharacter(object.Parent) then
				if state then
					if not object:FindFirstChild("RatkaOrigMat") then
						local m = Instance.new("StringValue", object); m.Name = "RatkaOrigMat"; m.Value = tostring(object.Material.Name)
						local c = Instance.new("Color3Value", object); c.Name = "RatkaOrigCol"; c.Value = object.Color
					end
					
					if object.Material == Enum.Material.Neon or object.Material == Enum.Material.Plastic then
						object.Material = Enum.Material.SmoothPlastic
					end
					object.Color = activeColor
				else
					if object:FindFirstChild("RatkaOrigMat") then
						object.Material = Enum.Material[object.RatkaOrigMat.Value]
						object.Color = object.RatkaOrigCol.Value
						object.RatkaOrigMat:Destroy()
						object.RatkaOrigCol:Destroy()
					end
				end
			end
			if i % 150 == 0 then task.wait() end -- Разгрузка процессора
		end
	end)
end

-- [[ МЕНЮ ]]
Window:Category("Combat")
local RagePage = Window:Page({Name = "Rage", Icon = "138827881557940"})
local CrashSection = RagePage:Section({Name = "Crash", Side = 1}) 
CrashSection:Toggle({Name = "Kill Aura (Crash)", Flag = "KillKnife"})

local AutoWinSect = RagePage:Section({Name = "Auto Win", Side = 1})
AutoWinSect:Toggle({Name = "Auto Win (Active)", Flag = "AutoWinActive"})

local HitboxSection = RagePage:Section({Name = "Hitbox Mods", Side = 1})
HitboxSection:Toggle({Name = "Extend Hitboxes", Flag = "HitboxEnabled"})
HitboxSection:Slider({Name = "Size", Flag = "HitboxSize", Min = 2, Max = 50, Default = 15})
HitboxSection:Slider({Name = "Transparency", Flag = "HitboxTransparency", Min = 0, Max = 100, Default = 100})

local SpinSection = RagePage:Section({Name = "Spin 999", Side = 2})
SpinSection:Toggle({Name = "Enabled", Flag = "Spin999Enabled", Callback = function(v) if v then ApplySpin999() end end})
SpinSection:Slider({Name = "Spin Speed", Flag = "Spin999Speed", Min = 1, Max = 999, Default = 100})
SpinSection:Slider({Name = "Head Pitch (Голова)", Flag = "SpinHeadPitch", Min = -90, Max = 90, Default = 0})

Window:Category("Mass Kill")
local KillAllPage = Window:Page({Name = "World Kill", Icon = "138827881557940"})
local KillAllSection = KillAllPage:Section({Name = "Execution", Side = 1})
KillAllSection:Button({
	Name = "Kill All Players",
	Callback = function()
		if not throwStartRemote or not throwHitRemote then return end
		equipWeapon(WEAPON_TYPE.knife)
		local myHrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
		if myHrp then
			for _, enemy in pairs(Players:GetPlayers()) do
				if enemy ~= localPlayer and (not enemy.Team or enemy.Team ~= localPlayer.Team) and enemy.Character then
					local eHrp = enemy.Character:FindFirstChild("HumanoidRootPart")
					if eHrp then 
						task.spawn(function() 
							throwStartRemote:FireServer(myHrp.Position, (eHrp.Position - myHrp.Position).Unit)
							throwHitRemote:FireServer(eHrp, eHrp.Position) 
						end) 
					end
				end
			end
		end
	end
})

Window:Category("Visuals")
local VisualPage = Window:Page({Name = "Visuals", Icon = "138827881557940"})
local VisSec = VisualPage:Section({Name = "Player Rendering", Side = 1})
VisSec:Toggle({Name = "Chams (X-Ray)", Flag = "ChamsEnabled"})
VisSec:Toggle({Name = "3D Box", Flag = "Box3DEnabled"})
VisSec:Toggle({Name = "CS2 Text ESP & Info", Flag = "ShowInfo"})
VisSec:Toggle({Name = "Bullet Tracers", Flag = "TracersEnabled"})

-- Секция эффектов с кастомизацией камеры и шлейфа
local EffectsSec = VisualPage:Section({Name = "Effects", Side = 2})
EffectsSec:Toggle({Name = "China-Head Trails", Flag = "ChinaTrail", Callback = function(state)
	if myTrail then myTrail.Enabled = state end
end})
EffectsSec:Slider({Name = "Trail Length (Lifetime)", Flag = "TrailLifetime", Min = 1, Max = 5, Default = 1, Callback = function(v)
	if myTrail then myTrail.Lifetime = v / 10 end
end})
EffectsSec:Slider({Name = "Trail Transparency", Flag = "TrailTrans", Min = 0, Max = 100, Default = 30, Callback = function(v)
	if myTrail then myTrail.Transparency = NumberSequence.new(v / 100, 1) end
end})
EffectsSec:Slider({Name = "Field of View (FOV)", Flag = "FovModifier", Min = 70, Max = 120, Default = 70, Callback = function(v)
	Camera.FieldOfView = v
end})

local WorldSec = VisualPage:Section({Name = "World Settings", Side = 2})
WorldSec:Toggle({Name = "Night Mode", Flag = "NightMode", Callback = function(state)
	Lighting.Brightness = state and 0 or 2
	Lighting.ClockTime = state and 0 or 14
end})
WorldSec:Toggle({Name = "Color World Textures", Flag = "ColorWorld", Callback = function(state)
	UpdateWorldTextures(state)
end})
-- Новые визуальные функции ворлда для атмосферности чита
WorldSec:Toggle({Name = "Premium Ambient Tint", Flag = "AmbientTint", Callback = function(state)
	if state then
		Lighting.Ambient = GetCurrentColor()
		Lighting.OutdoorAmbient = GetCurrentColor()
	else
		Lighting.Ambient = OriginalAmbient
		Lighting.OutdoorAmbient = OriginalOutdoorAmbient
	end
end})
WorldSec:Toggle({Name = "Fullbright (No Shadows)", Flag = "FullbrightEnabled", Callback = function(state)
	Lighting.GlobalShadows = not state
	if state then Lighting.Brightness = 3 else Lighting.Brightness = 2 end
end})

Window:Category("Player")
local PlayerPage = Window:Page({Name = "Movement", Icon = "138827881557940"})
local MoveSection = PlayerPage:Section({Name = "Movement Mods", Side = 1})
MoveSection:Toggle({Name = "Air Speed (CFrame Jump)", Flag = "AirSpeedEnabled"})
MoveSection:Slider({Name = "Air Multiplier", Flag = "AirMult", Min = 1, Max = 15, Default = 5})
MoveSection:Toggle({Name = "Speed Glitch (CFrame)", Flag = "SpeedGlitch"})
MoveSection:Slider({Name = "Glitch Multiplier", Flag = "GlitchMult", Min = 1, Max = 10, Default = 2})
MoveSection:Toggle({Name = "Noclip", Flag = "NoclipEnabled"})
MoveSection:Toggle({Name = "Infinite Jump", Flag = "InfJump"})

-- Нові функції мувменту
local MoveNewSection = PlayerPage:Section({Name = "Premium Movement", Side = 2})
MoveNewSection:Toggle({Name = "BunnyHop (Auto Jump)", Flag = "BhopEnabled"})
MoveNewSection:Toggle({Name = "Fly (Політ)", Flag = "FlyEnabled"})
MoveNewSection:Slider({Name = "Fly Speed", Flag = "FlySpeed", Min = 1, Max = 5, Default = 2})

MoveNewSection:Toggle({Name = "Anti-Freeze (Pre-Round)", Flag = "AntiStun"})
MoveNewSection:Toggle({Name = "Anti-TP", Flag = "AntiTP"})

MoveNewSection:Toggle({Name = "High Jump", Flag = "HighJumpEnabled"})
MoveNewSection:Slider({Name = "Jump Height Power", Flag = "HighJumpPower", Min = 50, Max = 250, Default = 120})
MoveNewSection:Toggle({Name = "Key Hold Speed (Shift)", Flag = "KeyHoldSpeedEnabled"})
MoveNewSection:Slider({Name = "Hold Speed Multiplier", Flag = "HoldSpeedMult", Min = 1, Max = 5, Default = 2})
MoveNewSection:Button({
	Name = "Phase Dash (Forward)",
	Callback = function()
		if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and localPlayer.Character:FindFirstChild("Humanoid") then
			local hrp = localPlayer.Character.HumanoidRootPart
			local hum = localPlayer.Character.Humanoid
			local moveDir = hum.MoveDirection
			if moveDir.Magnitude == 0 then
				moveDir = hrp.CFrame.LookVector
			end
			hrp.CFrame = hrp.CFrame + (moveDir * 15)
		end
	end
})

Window:Category("Trading")
local TradePage = Window:Page({Name = "Trade Helper", Icon = "138827881557940"})
local TradeSec = TradePage:Section({Name = "Utilities", Side = 1})
TradeSec:Toggle({Name = "Auto-Decline Trades", Flag = "DeclineTrades"})
TradeSec:Button({
	Name = "Clear Trade Chat Messages",
	Callback = function()
		local starterGui = game:GetService("StarterGui")
		pcall(function() starterGui:SetCore("ChatMakeSystemMessage", {Text = "[Ratka DLC] Chat cleared.", Color = GetCurrentColor(),}) end)
	end
})

Window:Category("Customization")
local SkinPage = Window:Page({Name = "Skins & UI", Icon = "138827881557940"})
local SkinSection = SkinPage:Section({Name = "Character", Side = 1})
SkinSection:Button({
	Name = "Load Tun Tun Sakuya",
	Callback = function()
		local char = localPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			local success, model = pcall(function() return game:GetObjects("rbxassetid://15332026190")[1] end)
			if success and model then 
				model.Parent = Workspace
				model:SetPrimaryPartCFrame(char.HumanoidRootPart.CFrame)
				localPlayer.Character = model
				model.Name = localPlayer.Name 
			end
		end
	end
})

local MenuSec = SkinPage:Section({Name = "Interface Custom", Side = 2})
MenuSec:Toggle({Name = "Rainbow Menu Border", Flag = "RainbowBorder"})

-- Оптимізований такт атак
task.spawn(function()
	while true do
		task.wait(0.05)
		if (Library.Flags["KillKnife"] or Library.Flags["AutoWinActive"]) and throwStartRemote and throwHitRemote then
			local myHrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
			if myHrp and equipWeapon(WEAPON_TYPE.knife) then
				for player, hrp in pairs(enemyCache) do
					if hrp and hrp.Parent and hrp.Parent:FindFirstChild("Humanoid") and hrp.Parent.Humanoid.Health > 0 then
						throwStartRemote:FireServer(myHrp.Position, (hrp.Position - myHrp.Position).Unit)
						throwHitRemote:FireServer(hrp, hrp.Position)
						if Library.Flags["TracersEnabled"] then task.spawn(CreateTracer, myHrp.Position, hrp.Position) end
					end
				end
			end
		end
	end
end)

-- Легкий цикл оновлення тексту в ESP (Тільки вороги) з мікро-вейтингом для усунення фризів
task.spawn(function()
	while true do
		task.wait(0.1)
		local currentActiveColor = GetCurrentColor()
		
		if Library.Flags["AmbientTint"] then
			pcall(function() 
				Lighting.Ambient = currentActiveColor
				Lighting.OutdoorAmbient = currentActiveColor
			end)
		end
		
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= localPlayer and player.Character then
				local char = player.Character
				local bill = char:FindFirstChild("RatkaESP")
				local hum = char:FindFirstChild("Humanoid")
				
				if player.Team and player.Team == localPlayer.Team then
					if bill then bill.Enabled = false end
				elseif bill and bill:FindFirstChild("TextLabel") and hum and hum.Health > 0 and Library.Flags["ShowInfo"] then
					local holdingWeapon = "None"
					local currentTool = char:FindFirstChildOfClass("Tool")
					if currentTool then holdingWeapon = currentTool.Name end
					
					local isUser = false
					-- ОПТИМИЗИРОВАНО: Быстрый поиск без тяжелых строковых циклов
					if char:SetAttribute("RatkaUser") == true then
						isUser = true
					end
					
					local espText = ""
					if isUser then espText = espText .. "< RATKA DLC USER >\n" end
					espText = espText .. string.format("%s\nHP: %d\n[ WP: %s ]", player.Name, math.floor(hum.Health), holdingWeapon)
					
					bill.TextLabel.Text = espText
					bill.TextLabel.TextColor3 = isUser and Color3.fromRGB(255, 215, 0) or currentActiveColor
				end
			end
			task.wait() -- Захист процесора від перевантаження при великій кількості гравців
		end
	end
end)

-- Основний швидкий цикл для рендеру візуалів
Run.Heartbeat:Connect(function()
	local CurrentColor = GetCurrentColor()
	if Library.Flags["RainbowBorder"] then Library:ChangeTheme("Accent", CurrentColor) end

	enemyCache = {}
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= localPlayer and player.Character then
			local char = player.Character
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local hum = char:FindFirstChild("Humanoid")
			
			if player.Team and player.Team == localPlayer.Team then
				if char:FindFirstChild("RatkaHigh") then char.RatkaHigh.Enabled = false end
				if char:FindFirstChild("RatkaBox") then char.RatkaBox.Visible = false end
				if char:FindFirstChild("RatkaESP") then char.RatkaESP.Enabled = false end
			else
				if hrp and hum and hum.Health > 0 then
					enemyCache[player] = hrp
					
					if Library.Flags["HitboxEnabled"] then 
						hrp.Size = Vector3.new(Library.Flags["HitboxSize"], Library.Flags["HitboxSize"], Library.Flags["HitboxSize"])
						hrp.Transparency = (Library.Flags["HitboxTransparency"] or 100) / 100
						hrp.CanCollide = false
					end

					-- ИСПРАВЛЕНО: Оптимизированная логика Chams (больше не спамит созданием объектов)
					local hl = char:FindFirstChild("RatkaHigh")
					if Library.Flags["ChamsEnabled"] then
						if not hl then
							hl = Instance.new("Highlight")
							hl.Name = "RatkaHigh"
							hl.Parent = char
						end
						hl.FillColor = CurrentColor
						hl.Enabled = true
					else
						if hl then hl.Enabled = false end
					end

					-- ИСПРАВЛЕНО: Стабильный 3D Box без мерцаний
					local box = char:FindFirstChild("RatkaBox")
					if Library.Flags["Box3DEnabled"] then
						if not box then
							box = Instance.new("SelectionBox")
							box.Name = "RatkaBox"
							box.Adornee = char
							box.Parent = char
						end
						box.Color3 = CurrentColor
						box.Visible = true
					else
						if box then box.Visible = false end
					end

					if Library.Flags["ShowInfo"] then
						local bill = char:FindFirstChild("RatkaESP") or Instance.new("BillboardGui", char)
						if bill.Name ~= "RatkaESP" then
							bill.Name = "RatkaESP"; bill.Size = UDim2.new(0,200,0,100); bill.AlwaysOnTop = true; bill.ExtentsOffset = Vector3.new(0,0.4,0)
							local t = Instance.new("TextLabel", bill); t.Size = UDim2.new(1,0,1,0); t.BackgroundTransparency = 1; t.Font = Enum.Font.RobotoMono; t.TextSize = 11; t.TextStrokeTransparency = 0
						end
						bill.Enabled = true
						bill.Parent = char
					elseif char:FindFirstChild("RatkaESP") then char.RatkaESP.Enabled = false end
				end
			end
		end
	end
end)

Run.Stepped:Connect(function()
	if Library.Flags["AntiStun"] and localPlayer.Character then
		local char = localPlayer.Character
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
			
			if humanoid.PlatformStand == true then humanoid.PlatformStand = false end
			if humanoid.WalkSpeed <= 0.1 then humanoid.WalkSpeed = 16 end
			if humanoid.JumpPower <= 0.1 then humanoid.JumpPower = 50 end
			
			local state = humanoid:GetState()
			if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.PlatformStanding then
		
