repeat
	wait()
until game:IsLoaded()

local player = game.Players.LocalPlayer
local playergui = player.PlayerGui

local character = player.Character or player.CharacterAdded:Wait()

local coreinfo = playergui:WaitForChild("CoreGame")
local limbhealth = coreinfo.LimbHealth

--Limb CoreGUI
for _,v in pairs(character:GetChildren()) do
	if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
		v:GetAttributeChangedSignal("Health"):Connect(function()
			local health = v:GetAttribute("Health")
			local maxhealth = v:GetAttribute("MaxHealth")
			
			local limbframe = limbhealth:FindFirstChild(v.Name) :: Frame
			
			if limbframe then
				limbframe.BackgroundColor3 = Color3.new(1, 0.447059, 0.447059):Lerp(Color3.new(0.54902, 1, 0.564706), health / maxhealth)
			end
		end)
	end
end