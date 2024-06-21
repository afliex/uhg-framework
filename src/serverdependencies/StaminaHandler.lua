local serverstorage = game:GetService("ServerStorage")

local serverdependencies = serverstorage.ServerDependencies
local servertoolbox = require(serverdependencies.ServerToolbox) --This is gonna show up as an error in vs code but ignore it the code still functions

local staminaregendelay = 2

local handler = {}
local onexaustionevent = Instance.new("BindableEvent")

handler.OnExaustion = onexaustionevent.Event

function handler:KillRunningFunction(functionname, character)
	if functionname == "StaminaDepletion" then
		character:SetAttribute("StaminaDepletion", false)
		servertoolbox:UnbindFromHeartBeat("StaminaDepletion_"..character.Name)
	elseif functionname == "StaminaRegen" then
		character:SetAttribute("StaminaRegen", false)
		servertoolbox:UnbindFromHeartBeat("StaminaRegen_"..character.Name)
	end
end

function handler:RemoveStamina(character : Model, amount)
	if character:IsA("Model") then
		local stamina = character:GetAttribute("Stamina")
		
		if character:GetAttribute("StaminaRegen") == true then
			handler:KillRunningFunction("StaminaRegen", character)
		end
		
		if stamina > 0 then
			if stamina - amount > 0 then
				character:SetAttribute("Stamina", stamina - amount)
			else
				character:SetAttribute("Stamina", 0)
				onexaustionevent:Fire(character, character:GetAttribute("Sprinting"))
			end
			
			character:SetAttribute("StaminaRemovalRunTick", tick())
		end
	end
end

function handler:AddStamina(character : Model, amount)
	if character:IsA("Model") then
		local stamina = character:GetAttribute("Stamina")

		if stamina < 100 then
			if stamina + amount < 100 then
				character:SetAttribute("Stamina", stamina + amount)
			else
				character:SetAttribute("Stamina", 100)
			end
		end
	end
end

function handler:DepleteStamina(character, rate)
	if character:GetAttribute("StaminaDepletion") == false and character:GetAttribute("StaminaRegen") == false then
		character:SetAttribute("StaminaDepletion", true)
		
		local function deplete(deltatime)
			if character:GetAttribute("Stamina") > 0 then
				handler:RemoveStamina(character, rate * deltatime)
			else
				handler:KillRunningFunction("StaminaDepletion", character)
			end
		end
		
		servertoolbox:BindToHeartBeat("StaminaDepletion_"..character.Name, deplete)
	end
end

function handler:RegenerateStamina(character, rate)
	if character:GetAttribute("StaminaRegen") == false and character:GetAttribute("StaminaDepletion") == false then
		local function regen(deltatime)
			if character:GetAttribute("Stamina") < 100 then
				handler:AddStamina(character, rate * deltatime)
			else
				handler:KillRunningFunction("StaminaRegen", character)
			end
		end

		task.delay(staminaregendelay, function()
			local timenow = tick()
			local timeelasped = timenow - character:GetAttribute("StaminaRemovalRunTick")
			
			if character:GetAttribute("StaminaDepletion") == false and timeelasped >= staminaregendelay then
				servertoolbox:BindToHeartBeat("StaminaRegen_"..character.Name, regen)
				character:SetAttribute("StaminaRegen", true)
			end
		end)
	end
end

return handler
