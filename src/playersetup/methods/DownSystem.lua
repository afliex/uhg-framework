local serverstorage = game:GetService("ServerStorage")

local serverdependencies = serverstorage.ServerDependencies
local ragdollsys = require(serverdependencies.RagdollSystem)
local servertoolbox = require(serverdependencies.ServerToolbox)

local downsyst = {
	["RagdollTime"] = 3,
	["DownedWalkSpeed"] = 5,
	["HealthDegenRate"] = 3
}

function downcharacter(character)
	local humanoid = character.Humanoid :: Humanoid

	character:SetAttribute("CanDealTouchedDamage", true)
	ragdollsys:UnRagdoll(character)
	humanoid.WalkSpeed = downsyst.DownedWalkSpeed

	character:SetAttribute("DownedDegenRate", downsyst.HealthDegenRate)

	servertoolbox:BindToHeartBeat("DownedHealthDegen", function(dt)
		humanoid:TakeDamage(character:GetAttribute("DownedDegenRate") * dt)
	end)
end

function RagdollWithControlledVelocity(character)
	ragdollsys:Ragdoll(character, 7.2)
	task.wait(.15)
	ragdollsys:RemoveAddedRagdollVelocity(character)
end

function downsyst.OnDowned(character : Model)
	character:SetAttribute("CanDealTouchedDamage", false)
	character:SetAttribute("Downed", true)
	
	if character:GetAttribute("Ragdolled") == true then
		local timepassed = tick() - character:GetAttribute("RagdollTick")
		
		if timepassed >= downsyst.RagdollTime then
			downcharacter(character)
		else
			task.wait(downsyst.RagdollTime - timepassed)
			downcharacter(character)
		end
	else
		RagdollWithControlledVelocity(character)
		task.wait(downsyst.RagdollTime)
		downcharacter(character)
	end
end

return downsyst
