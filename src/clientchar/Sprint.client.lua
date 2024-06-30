local tweenservice = game:GetService("TweenService")
local replicatedstorage = game:GetService("ReplicatedStorage")
local uis = game:GetService("UserInputService")

local events = replicatedstorage:WaitForChild("Events")
local characterevents = events.CharacterEvents

local character = script.Parent
local camera = workspace.CurrentCamera
local oldfov = camera.FieldOfView

local humanoid = character:WaitForChild("Humanoid") :: Humanoid
local animator = humanoid.Animator :: Animator
local sprintinganim

local speed = 7
local fovmultiplier = 1.2
local key = "LeftShift"
local sprintingspeeddivisor = 18

function QuickCreateAnimation(id, animspeed)
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://"..id

	local track = animator:LoadAnimation(animation)
	if animspeed ~= nil then
		track:Play()
		track:AdjustSpeed(animspeed)
	end
	
	return track
end

function sprint(active)
	local tweeninfo = TweenInfo.new(
		0.25,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.InOut
	)
	
	if character:GetAttribute("Crouching") == false then
		if active == true then
			if humanoid.MoveDirection.Magnitude > 0 and character:GetAttribute("Stamina") > character:GetAttribute("MinimumStaminaRequirement") then
				tweenservice:Create(camera, tweeninfo, {FieldOfView = camera.FieldOfView * fovmultiplier}):Play()
				
				characterevents:Fire("ChangeCharacterSpeed", humanoid.WalkSpeed + speed)

				sprintinganim = QuickCreateAnimation(16126931010, humanoid.WalkSpeed / sprintingspeeddivisor)
			end
		else
			tweenservice:Create(camera, tweeninfo, {FieldOfView = oldfov}):Play()
			
			characterevents:Fire("ChangeCharacterSpeed", 16)

			if sprintinganim then
				sprintinganim:Stop()
				sprintinganim = nil
			end
		end
	end
end


uis.InputBegan:Connect(function(input, gpe)
	if gpe or humanoid.Health <= 0 then return end
	
	if input.KeyCode == Enum.KeyCode[key] or humanoid.Health <= 0 then
		if character:GetAttribute("Downed") == false then
			sprint(true)
		end
	end
end)

uis.InputEnded:Connect(function(input, gpe)
	if gpe or humanoid.Health <= 0 then return end

	if input.KeyCode == Enum.KeyCode[key] then
		sprint(false)
	end
end)

humanoid.Running:Connect(function(speedvelo)
	if speedvelo <= 0 then
		if humanoid:GetState() ~= Enum.HumanoidStateType.Climbing and character:GetAttribute("Sprinting") == true then
			sprint(false)
		end
	else
		if character:GetAttribute("Stamina") <= 0 then
			sprint(false)
		end
	end
end)