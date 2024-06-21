local replicatedstorage = game:GetService("ReplicatedStorage")
local serverstorage = game:GetService("ServerStorage")
local players = game:GetService("Players")

local remotevents = replicatedstorage.RemoteEvents

local changespeed = remotevents.ChangeCharacterSpeed

local sprintingvalues = {
	["depletionrate"] = 12,
	["regenrate"] = 12
}

local crouchingvalues = {
	["minimumcrouchingspeed"] = 12
}

local serverdependencies = serverstorage.ServerDependencies
local staminahandler = require(serverdependencies.StaminaHandler)

function FinishedSprinting(character)
	if character:GetAttribute("Sprinting") == true then
		staminahandler:KillRunningFunction("StaminaDepletion", character)
		character:SetAttribute("Sprinting", false)
	end

	if character:GetAttribute("Stamina") < 100 then
		staminahandler:RegenerateStamina(character, sprintingvalues.regenrate)
	end
end

function ChangeSpeedRequest(player : Player, speed)
	local character = player.Character
	
	if speed <= character:GetAttribute("MaxSpeed") and character:GetAttribute("Downed") == false then
		if speed > 16 and character:GetAttribute("Stamina") >= character:GetAttribute("MinimumStaminaRequirement") and character:GetAttribute("Crouching") == false then --Sprinting
			character:SetAttribute("Sprinting", true)
			
			if character:GetAttribute("StaminaRegen") == true then
				staminahandler:KillRunningFunction("StaminaRegen", character)
			end

			local humanoid = character.Humanoid
			humanoid.WalkSpeed = speed

			staminahandler:DepleteStamina(character, sprintingvalues.depletionrate)
			
		elseif speed == 16 then --Stopped sprinting
			local humanoid = character.Humanoid
			
			humanoid.WalkSpeed = speed
			character:SetAttribute("Crouching", false)
			
			FinishedSprinting(character)
		
		elseif speed <= crouchingvalues.minimumcrouchingspeed and character:GetAttribute("Downed") == false then --Crouching
			local humanoid = character.Humanoid :: Humanoid
			
			humanoid.WalkSpeed = speed
			character:SetAttribute("Crouching", true)
			
			FinishedSprinting(character)
		end
	end
end

function OnExaustion(character, was_sprinting)
	local player = players:GetPlayerFromCharacter(character)
	
	if was_sprinting == true then
		ChangeSpeedRequest(player, 16)
	end
end

changespeed.OnServerEvent:Connect(ChangeSpeedRequest)
staminahandler.OnExaustion:Connect(OnExaustion)