local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local chosenSword = "Light" 
local delayAfterDeath = 2
local swordTeleportOffset_Y_CORRDINATE = 20
local luminancePhaseGrindMode = false
local bloodthirstyHelperModeEnabled = true
local bloodthirstyHelperModeSelectedPlayer = "wertezown"


local lumianceGiver = Workspace.SwordStands[string.format("SwordStant [ %s ]",chosenSword)].Giver
local isRBXFocused = true
local enabled = false

local connection



local function returnCurrentlySelectedSword()
    local sword = Players.LocalPlayer.Backpack:GetChildren()
    if #sword == 0 then 
        if Players.LocalPlayer.Character:FindFirstChildOfClass("Tool") then
            return Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
        end
        return nil 
    end
    return sword[1]
end

local function waitForCharacterToLoad()
    repeat task.wait() until Players.LocalPlayer.Character
end

local function teleportCharacter(object)
    waitForCharacterToLoad()
    local character = Players.LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local cf = object.CFrame
        character.HumanoidRootPart.CFrame = CFrame.new(cf.x, cf.y +swordTeleportOffset_Y_CORRDINATE, cf.z)
    end
end

local function characterAdded()
    teleportCharacter(lumianceGiver)
end


local function luminanceGrindMode()
    if returnCurrentlySelectedSword() == nil then characterAdded() return end
    local Character = Players.LocalPlayer.Character
    task.wait(0.5)
    mouse1click()
    task.wait(0.5)
    if returnCurrentlySelectedSword().Name == "???" then
        print("stopping")
        print(returnCurrentlySelectedSword())
        enabled = false
        return
    end
    Character.Humanoid.Health = 0
end

local function bloodthirstyHelperMode()
    local targetPlayer = bloodthirstyHelperModeSelectedPlayer
    Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Players:FindFirstChild(targetPlayer).Character.HumanoidRootPart.CFrame
    local connection
    connection = Players.LocalPlayer.Character.Humanoid.Touched:Connect(function(part)
        if not part.Parent.Name == targetPlayer then return end
        Players.LocalPlayer.Character.Humanoid.Health = 0
        connection:Disconnect()
    end)
end

local function onPromptShown()
    if not enabled then 
        connection:Disconnect()
        return 
    end

    local proxPrompt = lumianceGiver:FindFirstChild("ProximityPrompt")
    if not proxPrompt then return end

    local previousHoldDuration = proxPrompt.HoldDuration
    proxPrompt.HoldDuration = 0
    proxPrompt:InputHoldBegin()
    proxPrompt:InputHoldEnd()
    task.wait(0.1)
    proxPrompt.HoldDuration = previousHoldDuration
    waitForCharacterToLoad()
    task.wait(0.5)
    if luminancePhaseGrindMode then luminanceGrindMode() return end
    if bloodthirstyHelperModeEnabled then bloodthirstyHelperMode() return end
end

connection = lumianceGiver:FindFirstChild("ProximityPrompt").PromptShown:Connect(onPromptShown)

Players.LocalPlayer.Idled:Connect(function() --AntiAfk
    game:GetService("VirtualUser"):Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    task.wait(1)
    game:GetService("VirtualUser"):Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
end)

UserInputService.WindowFocused:Connect(function()
	isRBXFocused = true
end)

UserInputService.WindowFocusReleased:Connect(function()
    isRBXFocused = false
end)

UserInputService.InputBegan:Connect(function(input)
    if isRBXFocused and input.KeyCode == Enum.KeyCode.P then
        enabled = not enabled
        if enabled then
            local connection
            connection = Players.LocalPlayer.CharacterAdded:Connect(function()
                waitForCharacterToLoad()
                if not enabled then connection:Disconnect() return end
                if not returnCurrentlySelectedSword() == nil then return end
                task.wait(delayAfterDeath)
                characterAdded()
            end)
            characterAdded()
        end
    end
end)


