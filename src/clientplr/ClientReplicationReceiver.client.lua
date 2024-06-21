local replicatedstorage = game:GetService("ReplicatedStorage")
local startergui = game:GetService("StarterGui")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid") :: Humanoid

local events = replicatedstorage.Events
local remotevents = replicatedstorage.RemoteEvents

local sendnotification = remotevents.SendNotification
local changespeed = remotevents.ChangeCharacterSpeed
local returnaccuratehumanoidstate = remotevents.ReturnAccurateHumanoidState
local listenforhumanoidstate = remotevents.ListenForHumanoidState

local characterevents = events.CharacterEvents

local listenedhumanoidstates = {}

function NotificationRequest(notifparams)
	startergui:SetCore("SendNotification", notifparams)
end

function OnReturnAccurateHumanoidState()
	returnaccuratehumanoidstate:FireServer(humanoid:GetState())
end

function OnListenForHumanoidState(state, active)
	if active == true then
		if not listenedhumanoidstates[state] then
			if state == "Jumping" then
				local funct = humanoid.Jumping:Connect(function(jumping)
					if jumping == true then
						listenforhumanoidstate:FireServer(state)
					end
				end)
				
				listenedhumanoidstates[state] = funct
			end
		end
	elseif active == false then
		if listenedhumanoidstates[state] then
			listenedhumanoidstates[state]:Disconnect()
			listenedhumanoidstates[state] = nil
		end
	end
end

sendnotification.OnClientEvent:Connect(NotificationRequest)
returnaccuratehumanoidstate.OnClientEvent:Connect(OnReturnAccurateHumanoidState)
listenforhumanoidstate.OnClientEvent:Connect(OnListenForHumanoidState)

characterevents.Event:Connect(function(eventname, ...)
	if eventname == "SendNotification" then
		NotificationRequest(...)
	else
		if eventname == "ChangeCharacterSpeed" then
			local args = {...}
			
			if args[1] <= character:GetAttribute("MaxSpeed") then
				changespeed:FireServer(args[1])
			else
				warn("[error]: the speed parameters given for event "..eventname.." exceeds the max speed limit for the character.")
			end
		end
	end
end)