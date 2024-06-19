repeat
	wait()
until script.Parent ~= nil

--/Fixes some ragdoll bugs
local character = script.Parent :: Model
local camera = workspace.CurrentCamera

character:GetAttributeChangedSignal("Ragdolled"):Connect(function()
	local ragdolled = character:GetAttribute("Ragdolled")
	local humanoid = character.Humanoid :: Humanoid
	
	if ragdolled == true then
		camera.CameraSubject = character:WaitForChild("HumanoidRootPart")
		humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	else
		camera.CameraSubject = character:WaitForChild("HumanoidRootPart")
		humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end)