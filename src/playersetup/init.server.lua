local players = game.Players
local replicatedstorage = game:GetService("ReplicatedStorage")
local serverstorage = game:GetService("ServerStorage")

local remotevents = replicatedstorage:WaitForChild("RemoteEvents")
local sendnotification = remotevents.SendNotification

local defaultmaxplayerspeed = 23
local minimumstaminarequirement = 10
local jumpstaminacost = 10
local walkspeedlostforeachlegbroken = 6

local serverdependencies = serverstorage.ServerDependencies
local staminahandler = require(serverdependencies.StaminaHandler)
local servertoolbox = require(serverdependencies.ServerToolbox)
local ragdollsys = require(serverdependencies.RagdollSystem)

local methods = script.methods
local falldamage = require(methods.FallDamage)
local downsystem = require(methods.DownSystem)

local limbtojoint = {
	["Left Leg"] = "Left Hip",
	["Right Leg"] = "Right Hip",
	["Left Arm"] = "Left Shoulder",
	["Right Arm"] = "Right Shoulder"
}

function RectifyPlayer(player)
	player:LoadCharacter()

	sendnotification:FireClient(player, {
		Title = "|| SUSPICIOUS ACTIVITY DETECTED ||",
		Text = "User was rectified for possibility of speedhacks.",
		Duration = 12
	})
end

function RagdollWithControlledVelocity(character)
	ragdollsys:Ragdoll(character, 7.2)
	task.wait(.15)
	ragdollsys:RemoveAddedRagdollVelocity(character)
end

players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid") :: Humanoid

		humanoid.BreakJointsOnDeath = false
		humanoid.RequiresNeck = false
		
		humanoid.MaxHealth = 100
		humanoid.Health = humanoid.MaxHealth
		
		--/Attributes (ik theres alot lol)
		character:SetAttribute("MaxSpeed", defaultmaxplayerspeed)
		character:SetAttribute("Sprinting", false)
		character:SetAttribute("Stamina", 100)
		character:SetAttribute("StaminaDepletion", false)
		character:SetAttribute("StaminaRegen", false)
		character:SetAttribute("StaminaRemovalRunTick", 0)
		character:SetAttribute("FreefallTick", 0)
		character:SetAttribute("MinimumStaminaRequirement", minimumstaminarequirement)
		character:SetAttribute("Crouching", false)
		character:SetAttribute("PositionBeforeFreefall", Vector3.new(0,0,0))
		character:SetAttribute("Ragdolled", false)
		character:SetAttribute("RagdollTick", 0)
		character:SetAttribute("Freefalling", false)
		character:SetAttribute("CanDealTouchedDamage", true)
		character:SetAttribute("Downed", false)
		character:SetAttribute("DownedDegenRate", 0)
		
		local lastparttouched = Instance.new("ObjectValue")
		lastparttouched.Parent = player
		lastparttouched.Name = "LastPartTouched"
		
		--Stamina jump costs
		servertoolbox:ListenForHumanoidState(player, "Jumping", true, function()
			staminahandler:RemoveStamina(character, jumpstaminacost)
			staminahandler:RegenerateStamina(character, 12)
		end)
		
		--Events for methods/BindableEvents
		humanoid.FreeFalling:Connect(function(active)
			falldamage.OnFreefall(active, character)
		end)
		
		humanoid.Touched:Connect(function(tp, hp)
			falldamage.OnTouched(tp, hp, character)
		end)
		
		humanoid.HealthChanged:Connect(function(newhealth)
			if newhealth <= 30 then
				downsystem.OnDowned(character)
			end
		end)
		
		humanoid.Died:Connect(function()
			RagdollWithControlledVelocity(character)
		end)
		
		--Limb health assignment
		for _,v in pairs(character:GetChildren()) do
			if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
				v:SetAttribute("Health", 100)
				v:SetAttribute("MaxHealth", 100)
				
				v:GetAttributeChangedSignal("Health"):Connect(function()
					local health = v:GetAttribute("Health")
					
					if health <= 0 then
						v:SetAttribute("Health", 0) --In case the health is set to a number thats below zero (shouldn't really happen but just in case)
						
						if v.Name == "Head" or v.Name == "Torso" then
							humanoid.Health = 0
						else
							local torso = character:WaitForChild("Torso")
							local joint = torso:FindFirstChild(limbtojoint[v.Name]) :: Motor6D
							
							if joint then
								joint.C1 = joint.C1 * CFrame.Angles(joint.C1.Rotation.X,math.rad(joint.C1.Rotation.Y + math.random(-50,43)),joint.C1.Rotation.Z)
								
								if v.Name == "Left Leg" or v.Name == "Right Leg" then
									humanoid.WalkSpeed -= walkspeedlostforeachlegbroken
								end
							end
						end
					end
				end)
			end
		end
	end)

	--/unloading
	player.CharacterRemoving:Connect(function(character)
		task.wait()
		character:Destroy()
	end)
	
	player:LoadCharacter()
end)

players.PlayerRemoving:Connect(function(player)
	task.wait()
	player:Destroy()
end)