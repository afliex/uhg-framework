local atd = {
	LimbDamageMultiplier = 1.34
}

function atd:DealDamageToCharacter(character, dmg, limbname)
	if limbname ~= "HumanoidRootPart" then
		local humanoid = character:FindFirstChild("Humanoid")
		
		if humanoid then
			humanoid:TakeDamage(dmg)
			
			if string.match(limbname, ",") then
				local limbs = string.split(limbname, ",")
				
				for _,name in pairs(limbs) do
					local limb = character:FindFirstChild(name) :: BasePart

					if limb and limb:IsA("BasePart") then
						local currentlimbhealth = limb:GetAttribute("Health")
						dmg = math.clamp(dmg, 0, limb:GetAttribute("MaxHealth"))

						local newhealth = currentlimbhealth - (dmg * atd.LimbDamageMultiplier)
						limb:SetAttribute("Health", newhealth)
					end
				end
			else
				local limb = character:FindFirstChild(limbname) :: BasePart

				if limb and limb:IsA("BasePart") then
					local currentlimbhealth = limb:GetAttribute("Health")
					dmg = math.clamp(dmg, 0, limb:GetAttribute("MaxHealth"))

					local newhealth = currentlimbhealth - (dmg * atd.LimbDamageMultiplier)
					limb:SetAttribute("Health", newhealth)

					print("limb", limb:GetAttribute("Health"))
				end
			end
		else
			return
		end
	else
		return
	end
end

return atd
