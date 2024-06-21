local serverstorage = game:GetService("ServerStorage")

local serverdependencies = serverstorage.ServerDependencies
local ragdollsys = require(serverdependencies.RagdollSystem)
local adh = require(serverdependencies.AdvancedDamageHandler)

local fd = {
	["DamagePer10Studs"] = 10,
	["MinimumHeightToDealDamage"] = 12,
	["TimeRagdolledAfterLanding"] = 6
}

function CalculateFallDamage(distancefallen)
	if distancefallen >= fd.MinimumHeightToDealDamage then
		local formula = (distancefallen / 10) * fd.DamagePer10Studs
		return formula
	end
end

function RagdollWithControlledVelocity(character)
	ragdollsys:Ragdoll(character, 7.2)
	task.wait(.15)
	ragdollsys:RemoveAddedRagdollVelocity(character)
end

function FallDamage(character, limb)
	local humanoidrootpart = character.HumanoidRootPart :: Part

	local distancefallen = (character:GetAttribute("PositionBeforeFreefall") - humanoidrootpart.Position).Magnitude
	local dmg = CalculateFallDamage(distancefallen)

	character:SetAttribute("FreefallTick", tick())

	if dmg ~= nil then
		adh:DealDamageToCharacter(character, dmg, limb)
	end

	if distancefallen >= 25 then
		RagdollWithControlledVelocity(character)
	end

	if character:GetAttribute("Ragdolled") == true then
		task.delay(fd.TimeRagdolledAfterLanding, function()
			local freefalltick = character:GetAttribute("FreefallTick")

			if (tick() - freefalltick) >= fd.TimeRagdolledAfterLanding then
				ragdollsys:UnRagdoll(character)
				character:SetAttribute("CanDealTouchedDamage", true)
			end
		end)
	end
end

function fd.OnFreefall(active, character)
	if active then
		local humanoidrootpart = character.HumanoidRootPart :: Part
		local humanoid = character.Humanoid :: Humanoid

		character:SetAttribute("PositionBeforeFreefall", humanoidrootpart.Position)

		task.delay(2.3, function()
			local state = humanoid:GetState()
			
			if state == Enum.HumanoidStateType.Freefall then
				RagdollWithControlledVelocity(character)
			end
		end)
	else
		if character:GetAttribute("Ragdolled") ~= true then
			FallDamage(character, "Left Leg,Right Leg")
			character:SetAttribute("CanDealTouchedDamage", false)
		end
	end
end

function fd.OnTouched(touchingpart, humanoidpart, character)
	if character:GetAttribute("Ragdolled") == true then
		if not touchingpart:IsDescendantOf(character) then
			if character:GetAttribute("CanDealTouchedDamage") == true then
				character:SetAttribute("CanDealTouchedDamage", false)

				local humanoidrootpart = character.HumanoidRootPart :: Part
				FallDamage(character, humanoidpart.Name)

				character:SetAttribute("PositionBeforeFreefall", humanoidrootpart.Position)

				task.wait(.35)
				character:SetAttribute("CanDealTouchedDamage", true)
			end
		end
	end
end

return fd
