local character = script.Parent
local humanoid = character:WaitForChild("Humanoid") :: Humanoid

local canjump = true
local jumpdelay = 2

function OnFreefalling(freefalling)
	if not freefalling then
		if canjump == true then
			canjump = false
			humanoid.JumpHeight = 0

			task.delay(jumpdelay, function()
				if character:GetAttribute("Stamina") >= 10 then
					humanoid.JumpHeight = 4
					canjump = true
				else
					repeat
						wait()
					until character:GetAttribute("Stamina") >= 10
					
					humanoid.JumpHeight = 4
					canjump = true
				end
			end)
		end
	end
end

humanoid.Jumping:Connect(OnFreefalling)