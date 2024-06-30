local replicatedstorage = game:GetService("ReplicatedStorage")
local uis = game:GetService("UserInputService")

local events = replicatedstorage:WaitForChild("Events")
local characterevents = events.CharacterEvents

local character = script.Parent

local humanoid = character:WaitForChild("Humanoid") :: Humanoid
local animator = humanoid.Animator :: Animator

local crouchingkey = "C"
local speed = 10
local crouchingrunninganimationid = 15279444176

local runningevent

function QuickCreateAnimation(id)
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://"..id

	return animator:LoadAnimation(animation)
end

local crouchingrunningtrack = QuickCreateAnimation(crouchingrunninganimationid)

function crouch(active)
	if character:GetAttribute("Sprinting") == false then
		if active == true then
			characterevents:Fire("ChangeCharacterSpeed", humanoid.WalkSpeed - speed)
			
			crouchingrunningtrack:Play()
			crouchingrunningtrack:AdjustSpeed(0)
			
			runningevent = humanoid.Running:Connect(function(speedvelo)
				if speedvelo > 0 then
					crouchingrunningtrack:AdjustSpeed(1)
				else
					crouchingrunningtrack:AdjustSpeed(0)
				end
			end)
		else
			characterevents:Fire("ChangeCharacterSpeed", humanoid.WalkSpeed + speed)
			crouchingrunningtrack:Stop()
			
			runningevent:Disconnect()
			runningevent = nil
		end
	end
end

uis.InputBegan:Connect(function(input, gpe)
	if gpe or humanoid.Health <= 0 then return end
	 
	if input.KeyCode == Enum.KeyCode[crouchingkey] then
		if character:GetAttribute("Downed") == false then
			crouch(true)
		end
	end
end)

uis.InputEnded:Connect(function(input, gpe)
	if gpe or humanoid.Health <= 0 then return end
	
	if input.KeyCode == Enum.KeyCode[crouchingkey] then
		crouch(false)
	end
end)