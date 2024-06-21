local constrainthandler = require(script.ConstraintHandler)

local ragdoll = {}

function IsRagdolled(character)
	return character:GetAttribute("Ragdolled")
end

function ragdoll:Ragdoll(character : Model, addedvelo)
	if IsRagdolled(character) == false then
		character:SetAttribute("Ragdolled", true)
		character:SetAttribute("RagdollTick", tick())
		
		--/Setting humanoid state to "Ragdoll"
		local humanoid = character:WaitForChild("Humanoid") :: Humanoid
		
		print(humanoid:GetState())

		--/Adding extra velocity
		if addedvelo ~= nil then
			local hrp = character:WaitForChild("HumanoidRootPart")

			local attachment0 = Instance.new("Attachment")
			attachment0.Parent = hrp
			attachment0.Name = "RagdollVelocityAttachment"

			local angularvelocity = Instance.new("AngularVelocity")
			angularvelocity.Parent = hrp
			angularvelocity.Attachment0 = attachment0

			angularvelocity.MaxTorque = math.huge
			angularvelocity.AngularVelocity = Vector3.new(addedvelo,0,addedvelo)
		end	

		--/An extra precaution to ensure the character isn't ragdolled forever
		task.delay(14, function()
			local timewaited = tick() - character:GetAttribute("RagdollTick")

			if character:GetAttribute("Ragdolled") == true and timewaited >= 14 then
				warn("[ragdoll_sys]: ensure that there is a point in your script that will unragdoll the player after a certain amount of time")
			end
		end)
		
		--/Limb movement
		for _,v in pairs(character:GetDescendants()) do
			if v:IsA("Motor6D") then
				constrainthandler:ReplaceJointWithBallSocketContraint(v)
			end
		end
	end
end

function ragdoll:UnRagdoll(character)
	if IsRagdolled(character) == true then
		--/Setting humanoid state back to normal
		character:SetAttribute("Ragdolled", false)

		--/Setting character joints back to normal
		constrainthandler:RevertRagdollConstraintChanges(character)
		
		local humanoidrootpart = character:WaitForChild("HumanoidRootPart")
		humanoidrootpart.CFrame = humanoidrootpart.CFrame * CFrame.new(0,7,0)
	end
end

function ragdoll:RemoveAddedRagdollVelocity(character : Model)
	if IsRagdolled(character) == true then
		local hrp = character:WaitForChild("HumanoidRootPart")

		for _,v in pairs(character:GetDescendants()) do
			if v:IsA("AngularVelocity") then
				v:Destroy()

				local veloattachment = hrp:FindFirstChild("RagdollVelocityAttachment")
				if veloattachment then
					veloattachment:Destroy()
				end
			end
		end
	end
end

return ragdoll