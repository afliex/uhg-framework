local startergui = game:GetService("StarterGui")

startergui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)

local player = game.Players.LocalPlayer
local playergui = player.PlayerGui

local character = player.Character or player.CharacterAdded:Wait() :: Model
local humanoid = character:WaitForChild("Humanoid") :: Humanoid

local coreinfo = playergui.CoreGame

local healthframe = coreinfo.Health
local healthamount = healthframe.Amount
local healthbar = healthframe.HealthBar
local healthdifference = healthframe.HealthBarDifference

local staminaframe = coreinfo.Stamina
local staminaamount = staminaframe.Amount
local staminabar = staminaframe.StaminaBar
local staminadifference = staminaframe.StaminaBarDifference

function updateBarSize(bar : Frame, ratio)
	ratio = math.clamp(ratio, 0, 1)
	local newsize = UDim2.fromScale(ratio, 1)

	bar.Size = newsize
end

--Bar sizes
humanoid.HealthChanged:Connect(function(health)
	updateBarSize(healthbar, (health - 30) / (humanoid.MaxHealth - 30))
	healthamount.Text = math.floor(health - 30).."%"
end)

character:GetAttributeChangedSignal("Stamina"):Connect(function()
	local stamina = character:GetAttribute("Stamina")

	updateBarSize(staminabar, stamina / 100)
	staminaamount.Text = math.floor(stamina).."%"
end)