local runservice = game:GetService("RunService")
local replicatedstorage = game:GetService("ReplicatedStorage")

local remotevents = replicatedstorage:WaitForChild("RemoteEvents")
local returnaccuratehumanoidstate = remotevents.ReturnAccurateHumanoidState
local listenforhumanoidstate = remotevents.ListenForHumanoidState

local toolbox = {}

local rahs_waitlist = {}
local HeartBeatFunctions = {}
local humanoidstateslisteningfor = {}

returnaccuratehumanoidstate.OnServerEvent:Connect(function(player, state)
	local pos = table.find(rahs_waitlist, player)
	
	if rahs_waitlist[pos] == player then
		table.remove(rahs_waitlist, pos)
		player:SetAttribute("AccurateCurrentState", state)
	end
end)

function toolbox:BindToHeartBeat(key, funct)
	if not HeartBeatFunctions[key] then
		if type(funct) == "function" then
			funct = runservice.Heartbeat:Connect(funct)
			
			HeartBeatFunctions[key] = funct
		end
	else
		warn("[svr_toolbox]: key given is invalid as it is already in use.")
	end
end

function toolbox:UnbindFromHeartBeat(key)
	local funct = HeartBeatFunctions[key]
	
	if funct then
		funct:Disconnect()
		HeartBeatFunctions[key] = nil
	else
		warn("[svr_toolbox]: key given is invalid as it does not exist.")
	end
end

function toolbox:IsHeartBeatFunctionBinded(key)
	if HeartBeatFunctions[key] ~= nil then
		return true
	else
		return false
	end
end

function toolbox:GetAccurateHumanoidState(player)
	local state = nil
	
	returnaccuratehumanoidstate:FireClient(player)
	table.insert(rahs_waitlist, player)
	
	local timewaiting = tick()
	
	toolbox:BindToHeartBeat("WaitingForHumanoidStateResponse", function()
		local timenow = tick()
		local timeelasped = timenow - timewaiting

		if timeelasped >= 5 then
			local pos = table.find(rahs_waitlist, player)
			table.remove(rahs_waitlist, pos)

			warn("[svr_toolbox]: timeout! client took too long to respond.")
			
			toolbox:UnbindFromHeartBeat("WaitingForHumanoidStateResponse")
		end

		if player:GetAttribute("AccurateCurrentState") ~= nil then
			state = player:GetAttribute("AccurateCurrentState")
			player:SetAttribute("AccurateCurrentState", nil)
			
			toolbox:UnbindFromHeartBeat("WaitingForHumanoidStateResponse")
		end
	end)
	
	repeat 
		wait() 
	until toolbox:IsHeartBeatFunctionBinded("WaitingForHumanoidStateResponse") == false
	
	return state
end

function toolbox:ListenForHumanoidState(player, state, active, functiontorunonstate)
	listenforhumanoidstate:FireClient(player, state, active)
	
	if active == true then
		local funct = listenforhumanoidstate.OnServerEvent:Connect(function()
			functiontorunonstate()
		end)
		
		humanoidstateslisteningfor[state] = funct
	else
		local statefunct = humanoidstateslisteningfor[state]
		
		if statefunct ~= nil then
			statefunct:Disconnect()
			humanoidstateslisteningfor[state] = nil
		end
	end
end

return toolbox
