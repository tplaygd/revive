--// 
--// Original Revive Duper Script by upio
--// Modified and Optimized by tplaygd
--// Method found by lolcat
--// 

--// ============================================================
--// CONFIGURATION
--// ============================================================
--// MainAccount: Your main account's username (receives the duped revives)
--// DuplicationCount: How many revives to dupe (default 1000)
--// PreventLag: Should script try to prevent lag while duping (default true if 1000+ revives)
--// PreventError266: Should script try bypass error 266 (default true if 100000+ revives)
--// ============================================================

local MainAccount = MainAccount or ""
local DuplicationCount = DuplicationCount or 1000
local PreventLag = PreventLag == nil and DuplicationCount >= 1000 or PreventLag
local PreventError266 = PreventError266 == nil and DuplicationCount >= 100000 or PreventError266

--// Services
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")

if PreventLag and "hey that is anti lag from infinity yield!!11!111" and not getgenv()._NOLAG then
	getgenv()._NOLAG = true
	local Terrain = workspace:FindFirstChildWhichIsA("Terrain")
	Terrain.WaterWaveSize = 0
	Terrain.WaterWaveSpeed = 0
	Terrain.WaterReflectance = 0
	Terrain.WaterTransparency = 1
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 9e9
	Lighting.FogStart = 9e9
	settings().Rendering.QualityLevel = 1
	for _, v in pairs(game:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CastShadow = false
			v.Material = "Plastic"
			v.Reflectance = 0
			v.BackSurface = "SmoothNoOutlines"
			v.BottomSurface = "SmoothNoOutlines"
			v.FrontSurface = "SmoothNoOutlines"
			v.LeftSurface = "SmoothNoOutlines"
			v.RightSurface = "SmoothNoOutlines"
			v.TopSurface = "SmoothNoOutlines"
		elseif v:IsA("Decal") then
			v.Transparency = 1
			v.Texture = ""
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
			v.Lifetime = NumberRange.new(0)
		end
	end
	for _, v in pairs(Lighting:GetDescendants()) do
		if v:IsA("PostEffect") then
			v.Enabled = false
		end
	end
	workspace.DescendantAdded:Connect(function(child)
		task.spawn(function()
			if child:IsA("ForceField") or child:IsA("Sparkles") or child:IsA("Smoke") or child:IsA("Fire") or child:IsA("Beam") then
				RunService.Heartbeat:Wait()
				child:Destroy()
			elseif child:IsA("BasePart") then
				child.CastShadow = false
			end
		end)
	end)
	setfpscap(9e9)
end

--// Remotes
local RemotesFolder = ReplicatedStorage.RemotesFolder
local ReviveFriendEvent = RemotesFolder.ReviveFriend
local ObtainReviveEvent = RemotesFolder.ObtainGiftedRevive
local MotorReplication = RemotesFolder.MotorReplication
local Caption = PreventLag and RemotesFolder:FindFirstChild("Caption")

--// Player Variables
local LocalPlayer = Players.LocalPlayer
local Partner

--// Game Data
local Revives = LocalPlayer.PlayerGui.TopbarUI.Topbar.StatsTopbarHandler.StatModules.Revives.RevivesVal

--// Determine role
local IsMain = (MainAccount ~= "" and LocalPlayer.Name == MainAccount)
local IsAlt = not IsMain

-- Destroying caption event that cause lags (only when PreventLag is enabled)
if Caption and (IsMain or IsAlt) then
	Caption:Destroy()
end

local Title = IsMain and "Revive Dupe (Main)" or "Revive Dupe (Alt)"

--// State
local IsPartnerReady = false
local IsGiftingRevive = false

--// ============================================================
--// COMMUNICATION THROUGH MOTOR REPLICATION
--// ============================================================
local Communication = {
	Packets = {
		"Init",
		"SendReviveStandardToMe"
	},
	Pending = {},
	SendPacket = function(self, number: number)
		if not self.Packets[number] then warn("INVALID PACKET") return end
		task.spawn(function()
			local packetId = `{HttpService:GenerateGUID(false)}_{number}`
			table.insert(self.Pending, packetId)
			local index = table.find(self.Pending, packetId)
			while index and index > 1 do task.wait() end
			if not index then
				return -- the packet was cancelled :(
			end
			MotorReplication:FireServer(0) -- so GetAttributeChangedSignal would fire properly
			task.wait(1/30)
			MotorReplication:FireServer(number*10+100000)
			table.remove(self.Pending, index)
		end)
	end,
	OnPacket = {
		_Event = Instance.new("BindableEvent"),
		Connect = function(self, func: (Player: Player, Packet: string) -> ())
			return self._Event.Event:Connect(func)
		end
	}
}

local function connect(player)
	player:GetAttributeChangedSignal("LVY"):Connect(function()
		if Communication.Packets[player:GetAttribute("LVY")-10000] then
			Communication.OnPacket._Event:Fire(player, Communication.Packets[player:GetAttribute("LVY")-10000])
		end
	end)
end

for _, player in Players:GetPlayers() do
	connect(player)
end
Players.PlayerAdded:Connect(connect)

if true then
	Communication.OnPacket:Connect(function(sender, packetName)
        if sender == LocalPlayer then
            return
        end

        if packetName == "Init" then
            if IsPartnerReady then
                return
            end

            IsPartnerReady = true
            Partner = sender

            Communication:SendPacket(1)

            StarterGui:SetCore("SendNotification", {
                Title = Title,
                Text = `{sender.Name} initialized, starting dupe process...`,
                Duration = 5
            })
        end

        if not IsPartnerReady then
            return
        end

        if packetName == "SendReviveStandardToMe" then
            IsGiftingRevive = true

            if Partner:GetAttribute("Alive") == true then
                StarterGui:SetCore("SendNotification", {
                    Title = Title,
                    Text = "Waiting for the other account to die...",
                    Duration = 5
                })

                Partner:GetAttributeChangedSignal("Alive"):Wait()
            end

            task.wait(2.5)
            ReviveFriendEvent:FireServer(Partner.Name)

            StarterGui:SetCore("SendNotification", {
                Title = Title,
                Text = "Revive sent to alt account. Now rejoin a new game with your alt account.",
                Duration = 5
            })
        end
    end)

    Communication:SendPacket(1)

    StarterGui:SetCore("SendNotification", {
        Title = Title,
        Text = "Waiting for other account to initialize...",
        Duration = 5
    })

    repeat task.wait() until IsPartnerReady
end

--// ============================================================
--// HELPER FUNCTIONS
--// ============================================================
local function AttemptToKillLocalPlayer()
    (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid", 9e9).Health = 0 -- this method works again

    StarterGui:SetCore("SendNotification", {
        Title = Title,
        Text = "Make your alt account try and revive you (click more than once)",
        Duration = 5
    })
end

--// ============================================================
--// MAIN LOGIC
--// ============================================================

--// Alt account needs 1 revive gifted to it first
if Revives.Value == 0 and not IsMain then
    if UseChatFallback then
        Communication:SendPacket(2)
    end

    IsGiftingRevive = true
    AttemptToKillLocalPlayer()

    StarterGui:SetCore("SendNotification", {
        Title = Title,
        Text = "Waiting for main account to gift you a revive...",
        Duration = 5
    })

	local obtained = false

    local function OnObtainRevive(...)
		if obtained then return false end
		obtained = true
        return true
    end

    if hookmetamethod then
        local mtHook; mtHook = hookmetamethod(game, "__newindex", function(...)
			local self, key = ...
    
            if rawequal(self, ObtainReviveEvent) and key == "OnClientInvoke" then
                if not checkcaller() then
                    return
                end
            end
    
            return mtHook(...)
        end)
    else
        task.defer(function()
            while task.wait() do
                ObtainReviveEvent.OnClientInvoke = OnObtainRevive
            end
        end)
    end

	ObtainReviveEvent.OnClientInvoke = OnObtainRevive

	while not obtained do
		task.wait()
	end
	task.wait()
	game:Shutdown()

    return
end

--// Coordination delay to ensure both clients are synced
StarterGui:SetCore("SendNotification", {
    Title = Title,
    Text = "Waiting 5 seconds to sync with the other account...",
    Duration = 5
})
task.wait(5)

--// If we're in the middle of gifting a revive, don't continue
if IsGiftingRevive then
    return
end

--// Main dupe process
if IsMain then
    local ReviveObtainedAmount = 0
	local Hint
    local function OnObtainRevive(...)
        if ReviveObtainedAmount >= DuplicationCount then return false end
        ReviveObtainedAmount += 1
		Hint = Hint or Instance.new("Hint", workspace)
		Hint.Text = `{Title}: Received revive requests: {ReviveObtainedAmount}`
		
		if ReviveObtainedAmount >= DuplicationCount then
			Hint.Text = `{Title}: Accepting all requests please wait`
			Debris:AddItem(Hint, 10)
		end

        while ReviveObtainedAmount < DuplicationCount do
            task.wait(3)
        end

        return true
    end

    if hookmetamethod then
        local mtHook; mtHook = hookmetamethod(game, "__newindex", function(...)
			local self, key = ...
    
            if rawequal(self, ObtainReviveEvent) and key == "OnClientInvoke" then
                if not checkcaller() then
                    return
                end
            end
    
            return mtHook(...)
        end)
    else
        task.defer(function()
            while task.wait() do
                ObtainReviveEvent.OnClientInvoke = OnObtainRevive
            end
        end)
    end

	ObtainReviveEvent.OnClientInvoke = OnObtainRevive

    AttemptToKillLocalPlayer()
else
    if Partner:GetAttribute("Alive") then
        StarterGui:SetCore("SendNotification", {
            Title = Title,
            Text = "Waiting for main account to die...",
            Duration = 5
        })

        Partner:GetAttributeChangedSignal("Alive"):Wait()
    end

    for i = 1, 3 do
        StarterGui:SetCore("SendNotification", {
            Title = Title,
            Text = `Duping in {4 - i} seconds...`,
            Duration = 1
        })
        task.wait(1)
    end

	local Sent = 0
    for i = 1, DuplicationCount do
		Sent = i
        ReviveFriendEvent:FireServer(Partner.Name)
		if PreventError266 and Sent%10000 == 0 then
			for _ = 1,1000 do
				RunService.Heartbeat:Wait()
			end
		end
    end

    StarterGui:SetCore("SendNotification", {
        Title = Title,
        Text = "Duping completed!",
        Duration = 5
    })
end
