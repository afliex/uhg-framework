local uis = game:GetService("UserInputService")
local runservice = game:GetService("RunService")
local tweenservice = game:GetService("TweenService")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid") :: Humanoid
local hrp = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

local mouselockkey = "LeftControl"
local mouselockicon = "rbxassetid://16955020049"
local mouselockoffset = Vector3.new(1.75, 0, 0)
local mouselockresponsiveness = 0.35
local mouselockopeningtime = 0.25

local oldoffset = CFrame.new()
local savedcursoricon = nil

local usingmouselock = false

function IsInFirstPerson()
	if character.Head.LocalTransparencyModifier == 1 then
		return true
	else
		return false
	end
end

function mouselock(active)
	local function camlock()
		if humanoid then
			uis.MouseBehavior = Enum.MouseBehavior.LockCenter
			
			local ti = TweenInfo.new(
				mouselockresponsiveness,
				Enum.EasingStyle.Quart,
				Enum.EasingDirection.Out
			)
			
			local _,y = camera.CFrame.Rotation:ToEulerAnglesYXZ()
			tweenservice:Create(hrp, ti, {CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0,y,0)}):Play()
		end
		
		if IsInFirstPerson() then
			mouselock(false)
		end
	end
	
	if active then
		usingmouselock = true
		oldoffset = humanoid.CameraOffset
		
		local ti = TweenInfo.new(
			mouselockopeningtime,
			Enum.EasingStyle.Quint,
			Enum.EasingDirection.Out
		)
		
		tweenservice:Create(humanoid, ti, {CameraOffset = mouselockoffset}):Play()

		humanoid.AutoRotate = false
		
		savedcursoricon = uis.MouseIcon
		uis.MouseIcon = mouselockicon
		
		runservice:BindToRenderStep("MouseLock", Enum.RenderPriority.Character.Value, camlock)
	else
		usingmouselock = false
		uis.MouseBehavior = Enum.MouseBehavior.Default
		runservice:UnbindFromRenderStep("MouseLock", Enum.RenderPriority.Character.Value, camlock)
		
		local ti = TweenInfo.new(
			mouselockopeningtime,
			Enum.EasingStyle.Quint,
			Enum.EasingDirection.Out
		)

		tweenservice:Create(humanoid, ti, {CameraOffset = oldoffset}):Play()
		
		humanoid.AutoRotate = true
		
		uis.MouseIcon = savedcursoricon
		savedcursoricon = nil
	end
end

uis.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	
	if input.KeyCode == Enum.KeyCode[mouselockkey] then
		if usingmouselock == false then
			if not IsInFirstPerson() then
				mouselock(true)
			end
		else
			mouselock(false)
		end
	end
end)