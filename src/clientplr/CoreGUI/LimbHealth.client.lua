repeat
	wait()
until game:IsLoaded()

local player = game.Players.LocalPlayer
local playergui = player.PlayerGui

local character = player.Character or player.CharacterAdded:Wait()

local coreinfo = playergui:WaitForChild("CoreGame")
local limbhealth = coreinfo.LimbHealth

local sequence = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 73, 76)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(253, 175, 130)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 255, 114))
}

function returnsequencepoint(x)
	if x == 0 then return sequence.Keypoints[1].Value end
	if x == 1 then return sequence.Keypoints[#sequence.Keypoints].Value end

	for i = 1, #sequence.Keypoints - 1 do
		local current = sequence.Keypoints[i]
		local next = sequence.Keypoints[i + 1]
		
		if x >= current.Time and x < next.Time then
			local alpha = (x - current.Time) / (next.Time - current.Time)
			return current.Value:Lerp(next.Value, alpha)
		end
	end
end

for _,v in pairs(character:GetChildren()) do
	if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
		v:GetAttributeChangedSignal("Health"):Connect(function()
			local health = v:GetAttribute("Health")
			local maxhealth = v:GetAttribute("MaxHealth")
			
			local limbframe = limbhealth:FindFirstChild(v.Name) :: Frame
			
			if limbframe then
				print("ye")
				local sequencepoint = returnsequencepoint(math.clamp(health/maxhealth, 0, 1)) 
				print(sequencepoint)
				limbframe.BackgroundColor3 = sequencepoint
			end
		end)
	end
end