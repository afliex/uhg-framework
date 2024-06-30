local lighting = game.Lighting
local player = game.Players.LocalPlayer
local playergui = player.PlayerGui

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid") :: Humanoid
local animator = humanoid.Animator :: Animator

local walkingid = 15577580993
local downedspeeddivisor = 18

local bleedoutkey = "Q"
local slowbleedingkey = "E"

local downedlighting = script:WaitForChild("Lighting")

local runningevent
local healthevent

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

function updateBarSize(bar : Frame, ratio)
	ratio = math.clamp(ratio, 0, 1)
	local newsize = UDim2.fromScale(ratio, 1)

	bar.Size = newsize
end

local walkanim = QuickCreateAnimation(walkingid)

character:GetAttributeChangedSignal("Downed"):Connect(function()
	local downed = character:GetAttribute("Downed")
	
	if downed then
		--/Animation
		walkanim:Play()
		walkanim:AdjustSpeed(0)
		
		runningevent = humanoid.Running:Connect(function(speed)
			if speed >= 1 then
				print("ye")
				walkanim:AdjustSpeed(humanoid.WalkSpeed / downedspeeddivisor)
			else
				print("naw")
				walkanim:AdjustSpeed(0)
			end
		end)
		
		--/Screen effects
		for _,fx in pairs(lighting:GetChildren()) do
			if not fx:IsA("Atmosphere") and not fx:IsA("Sky") then
				fx.Enabled = false
			end
		end
		
		for _,fx in pairs(downedlighting:GetChildren()) do
			fx = fx:Clone()
			fx.Name = fx.Name.."-DOWNEDLIGHTING"
			fx.Parent = lighting
		end
		
		--/GUI
		playergui.CoreGame.Enabled = false
		
		local downedgui = playergui.DownedGUI
		downedgui.Enabled = true
		
		local bleedtip = downedgui:WaitForChild("BleedTip")
		bleedtip.KeyFrame.Key.Text = bleedoutkey
		
		local slowtip = downedgui:WaitForChild("SlowTip")
		slowtip.KeyFrame.Key.Text = slowbleedingkey
		
		local downedbar = downedgui:WaitForChild("DownedHealth")
		local healthbar = downedbar.HealthBar
		
		healthevent = humanoid.HealthChanged:Connect(function(health)
			updateBarSize(healthbar, (health) / (30))
		end)
	else
		if runningevent then
			runningevent:Disconnect()
			runningevent = nil
		end

        if healthevent then
            healthevent:Disconnect()
            healthevent = nil
        end

        if playergui.DownedGUI.Enabled == true then
            playergui.DownedGUI.Enabled = false
        end
		
		if playergui.CoreGame.Enabled == false then
			playergui.CoreGame.Enabled = true
		end
		
		for _,fx in pairs(lighting:GetChildren()) do
			local stringmatch = fx.Name:match("-DOWNEDLIGHTING")
			
			if stringmatch then
				fx.Name:Destroy()
			else
				if not fx:IsA("Atmosphere") and not fx:IsA("Sky") then
					fx.Enabled = true
				end
			end
		end
	end
end)