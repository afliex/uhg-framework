local constraint = {}

function constraint:ReplaceJointWithBallSocketContraint(motor6D : Motor6D)
	local socket = Instance.new("BallSocketConstraint")
	local a0 = Instance.new("Attachment")
	local a1 = Instance.new("Attachment")
	
	a0.Parent = motor6D.Part0
	a1.Parent = motor6D.Part1
	
	a0.CFrame = motor6D.C0
	a1.CFrame = motor6D.C1
	
	socket.Parent = motor6D.Parent
	socket.Name = motor6D.Part1.Name.."BallSocketConstraint"
	socket.Attachment0 = a0
	socket.Attachment1 = a1
	
	socket.LimitsEnabled = true
	socket.TwistLimitsEnabled = true
	
	motor6D.Enabled = false
end

function constraint:RevertRagdollConstraintChanges(character : Model)
	for _,v in pairs(character:GetDescendants()) do
		if v:IsA("BallSocketConstraint") then
			v.Attachment0:Destroy()
			v.Attachment1:Destroy()
			
			v:Destroy()
		elseif v:IsA("Motor6D") then
			v.Enabled = true
		end
	end
end

return constraint
