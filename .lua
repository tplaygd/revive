--[=[
    █████   ████   ████  █████   █████     █████  █████ █     █ █ █     █ █████     █████  █    █ █████  █████ █████
    █    █ █    █ █    █ █    █ █          █    █ █     █     █ █ █     █ █         █    █ █    █ █    █ █     █    █
    █    █ █    █ █    █ █████  █          █████  █████  █   █  █  █   █  █████     █    █ █    █ █████  █████ █████
    █    █ █    █ █    █ █ █     ████      █ █    █      █   █  █  █   █  █         █    █ █    █ █      █     █ █
    █    █ █    █ █    █ █  █        █     █  █   █       █ █   █   █ █   █         █    █ █    █ █      █     █  █
    █████   ████   ████  █   █  █████      █   █  █████    █    █    █    █████     █████   ████  █      █████ █   █
    
    BY @TPLAYGD

    MORE OPTIMIZED THAN REVIVE DUPER BY UPIO AND REVIVE DUMPER BY RHYAN57
]=]

receiver = receiver or "" -- who will receive all revives from sender
sender = sender or "" -- who will send all revives to receiver
revives = revives or 1000 -- amount of revives to send
destroylaggystuff = destroylaggystuff or revives >= 1000 -- destroy captions on both accounts and replica_setvalue on alt to prevent lags

-- source code below, u can do anything with it if yk what r u doing

local cloneref = cloneref or function(...) return ... end
local Players = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local LatestRoom = ReplicatedStorage:WaitForChild("GameData"):WaitForChild("LatestRoom")
local RemotesFolder = ReplicatedStorage:WaitForChild("RemotesFolder")
local player = Players.LocalPlayer
local obtain = RemotesFolder:WaitForChild("ObtainGiftedRevive")
local send = RemotesFolder:WaitForChild("ReviveFriend")
local caption = destroylaggystuff and RemotesFolder:FindFirstChild("Caption")
local setvalue = destroylaggystuff and ReplicatedStorage:WaitForChild("ReplicaRemoteEvents"):FindFirstChild("Replica_ReplicaSetValue")

local ismain, isalt = player.Name == receiver, player.Name == sender
local mainp, altp = Players:FindFirstChild(receiver), Players:FindFirstChild(sender)

print(receiver, sender)
print(ismain, isalt)
print(mainp, altp)
print(mainp and mainp.Character, altp and altp.Character)

if not mainp or not altp then
	print("NO PLAYER")
	return
end

if mainp == altp then
	print("SAME PLAYER")
	return
end

if not mainp.Character or not altp.Character then
	print("NO CHARACTER")
	return
end

if caption and (ismain or isalt) then
	caption:Destroy()
end

if setvalue and not ismain and isalt then
	setvalue:Destroy()
end

local hint = Instance.new("Hint", workspace)

if not ismain and isalt then
	local mainHuman = mainp.Character:WaitForChild("Humanoid", 60)
	if mainHuman.Health > 0 then
		hint.Text = "Waiting for receiver to die..."
		local dead = false
		local c;c = mainHuman:GetPropertyChangedSignal("Health"):Connect(function()
			dead = mainHuman.Health <= 0
			c:Disconnect()
		end)
		while not dead do task.wait() end
	end
	for i = 1,3 do
		hint.Text = `Sending all requests in {4-i} seconds (DONT DO ANYTHING)...`
		task.wait(1)
	end
	hint.Text = "Sending requests!"
	game.Debris:AddItem(hint, 5)
	for _ = 1,revives do
		task.spawn(function()game.ReplicatedStorage.RemotesFolder.ReviveFriend:FireServer(receiver)end)
	end
elseif ismain and not isalt then
	local function obtainFunc()
		if receivedRevives >= revives then return false end
		task.spawn(function()
			receivedRevives += 1
			hint.Text = `Received revive requests: {receivedRevives}`
		end)
		while receivedRevives < revives do
			task.wait(3)
		end
		task.spawn(function()
			acceptedRevives += 1
			hint.Text = `Accepted revive requests: {acceptedRevives}`
			if acceptedRevives == receivedRevives then
				hint.Text = "All requests accepted! (DON'T LEAVE YET IF YOU DIDN'T RECEIVED ALL REVIVES)"
				game.Debris:AddItem(hint, 5)
			end
		end)
		return true
	end

	if hookmetamethod then
		local h;h = hookmetamethod(game, "__newindex", function(self, key, ...)
			if not checkcaller() and self == obtain and key == "OnClientInvoke" then
				return
			end
			return h(self, key, ...)
		end)
		obtain.OnClientInvoke = obtainFunc
	else
		task.spawn(function()
			while task.wait() do
				obtain.OnClientInvoke = obtainFunc
			end
		end)
	end
	local receivedRevives = 0
	local acceptedRevives = 0
	local first = false
	for i = 1,3 do
		hint.Text = `Dying in {4-i} seconds (DONT DO ANYTHING)...`
		task.wait(1)
	end
	hint.Text = "Waiting for sender to sent revives..."
	player.Character.Humanoid.Health = 0 -- for some reason this method now works again (just like replicatesignal(game.Players.LocalPlayer.Kill))
end
