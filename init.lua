local Requirements = loadstring(game:HttpGet('https://raw.githubusercontent.com/xrvili/Solar-Hub/refs/heads/main/Modules/requirements.lua'))()
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Missing = {}

for i, v in pairs(Requirements[game.GameId]) do
    if typeof(i) == "string" then
        local found
        for ii, vv in ipairs(v) do
            if getgenv()[vv] and typeof(getgenv()[vv]) == "function" then
                found = true
                break
            end
        end
        if not found then
            table.insert(Missing, i)
        end
        continue
    end

    if not getgenv()[v] or typeof(getgenv()[v]) ~= "function" then
        table.insert(Missing, v)
    end
end

if #Missing >= 1 then
    Players.LocalPlayer:Kick()
    CoreGui.RobloxPromptGui:WaitForChild("promptOverlay"):WaitForChild("ErrorPrompt")
    CoreGui.RobloxPromptGui.promptOverlay.ErrorPrompt.TitleFrame.ErrorTitle.Text = "Unsupported Executor"
    CoreGui.RobloxPromptGui.promptOverlay.ErrorPrompt.MessageArea.ErrorFrame.ErrorMessage.Text = "Your executor is missing the following functions required for Solar Hub to run properly: "..table.concat(Missing, ", ").. ".\n\n Please review our recommended executors in our discord server."
    CoreGui.RobloxPromptGui.promptOverlay.ErrorPrompt.MessageArea.ErrorFrame.ErrorMessage.TextScaled = true
    return
end
