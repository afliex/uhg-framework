local constrainthandler = require(script.ConstraintHandler)

local ragdoll = {}

function IsRagdolled(character)
	return character:GetAttribute("Ragdolled")
end

function ragdoll:Ragdoll(character : Model, addedvelo)
	if IsRagdolled(character) == false then
		local humanoid = character:WaitForChild("Humanoid") :: Humanoid
		humanoid.AutoRotate = false

		character:SetAttribute("Ragdolled", true)
		character:SetAttribute("RagdollTick", tick())

		for _,v in pairs(character:GetDescendants()) do
			if v:IsA("Motor6D") then
				constrainthandler:ReplaceJointWithBallSocketContraint(v)
			elseif v:IsA("BasePart") then
				v:SetNetworkOwner(nil)
			end
		end

		humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)

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
		
		task.delay(14, function()
			local timewaited = tick() - character:GetAttribute("RagdollTick")

			if character:GetAttribute("Ragdolled") == true and timewaited >= 14 then
				warn("[ragdoll_sys]: ensure that there is a point in your script that will unragdoll the player after a certain amount of time")
			end
		end)
	end
end

function ragdoll:UnRagdoll(character)
	if IsRagdolled(character) == true then
		local humanoid = character:WaitForChild("Humanoid") :: Humanoid
		humanoid.AutoRotate = true

		character:SetAttribute("Ragdolled", false)

		constrainthandler:RevertRagdollConstraintChanges(character)
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

		for _,v in pairs(character:GetDescendants()) do
			if v:IsA("BasePart") then
				v:SetNetworkOwner(game:GetService("Players"):GetPlayerFromCharacter(character))
			end
		end
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