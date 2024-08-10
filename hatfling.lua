-- MADE TO USE https://www.roblox.com/catalog/18875660360/2048hat, OTHER HATS WILL DO CLOSE TO NOTHING
local fph = workspace.FallenPartsDestroyHeight

local plr = game.Players.LocalPlayer
local character = plr.Character
local hrp = character:WaitForChild("HumanoidRootPart")
local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
local start = hrp.CFrame

local campart = Instance.new("Part",character)
campart.Transparency = 1
campart.CanCollide = false
campart.Size = Vector3.one
campart.Position = start.Position
campart.Anchored = true

local function updatestate(hat,state)
    if sethiddenproperty then
        sethiddenproperty(hat,"BackendAccoutrementState",state)
    elseif setscriptable then
        setscriptable(hat,"BackendAccoutrementState",true)
        hat.BackendAccoutrementState = state
    else
        local success = pcall(function()
            hat.BackendAccoutrementState = state
        end)
        if not success then
            error("executor not supported, sorry!")
        end
    end
end

local targethat
local biggest = 0
for i,v in pairs(character:GetChildren()) do
    if v:IsA("Accessory") and v:FindFirstChild("Handle") then
        if v.Handle.Size.Magnitude > biggest then
            biggest = v.Handle.Size.Magnitude
            targethat = v
        end
    end
end
updatestate(targethat,4) -- just to make sure executor supports, hat should already be in this state
targethat.Handle.CanTouch = false
Instance.new("SelectionBox",targethat.Handle).Adornee = targethat.Handle

workspace.FallenPartsDestroyHeight = 0/0

local function play(id,speed,prio,weight)
    local Anim = Instance.new("Animation")
    Anim.AnimationId = "https"..tostring(math.random(1000000,9999999)).."="..tostring(id)
    local track = character.Humanoid:LoadAnimation(Anim)
    track.Priority = prio
    track:Play()
    track:AdjustSpeed(speed)
    track:AdjustWeight(weight)
    return track
end

local r6fall = 180436148
local r15fall = 507767968

local dropcf = CFrame.new(character.HumanoidRootPart.Position.x,fph-.25,character.HumanoidRootPart.Position.z)
if character.Humanoid.RigType == Enum.HumanoidRigType.R15 then
    dropcf =  dropcf * CFrame.Angles(math.rad(20),0,0)
    character.Humanoid:ChangeState(16)
    play(r15fall,1,5,1).TimePosition = .1
else
    play(r6fall,1,5,1).TimePosition = .1
end

spawn(function()
    while hrp.Parent ~= nil do
        hrp.CFrame = dropcf
        hrp.Velocity = Vector3.new(0,25,0)
        hrp.RotVelocity = Vector3.new(0,0,0)
        game:GetService("RunService").Heartbeat:wait()
    end
end)

task.wait(.25)

local lock = targethat.Changed:Connect(function(p)
    if p == "BackendAccoutrementState" then
        updatestate(targethat,0)
    end
end)
updatestate(targethat,2)

character.Humanoid:ChangeState(15)

torso.AncestryChanged:wait()
lock:Disconnect()
updatestate(targethat,4)

spawn(function()
    plr.CharacterAdded:wait():WaitForChild("HumanoidRootPart",10).CFrame = start
    workspace.FallenPartsDestroyHeight = fph
end)

repeat
    task.wait()
until not targethat:FindFirstChild("Handle") or targethat.Handle.CanCollide or plr.Character ~= character or targethat.Parent == nil

if targethat:FindFirstChild("Handle") and targethat.Handle.CanCollide then
    print("dropped")
    workspace.CurrentCamera.CameraSubject = campart
    targethat.Handle.CanCollide = false
    targethat.Handle.CanTouch = false
    local sine = 0
    spawn(function()
        while plr.Character == character and targethat and targethat.Parent ~= nil do
            sine = sine + 1
            plr.SimulationRadius = 999
            targethat.Handle.Velocity = Vector3.one*1500
            targethat.Handle.RotVelocity = Vector3.one*150000
            targethat.Handle.CFrame = CFrame.new(start.Position) * CFrame.new(math.random(-100,100),math.random(-100,100),math.random(-100,100)) * CFrame.Angles(math.rad(sine*2),math.rad(sine*2),0)
            game:GetService("RunService").Heartbeat:wait()
        end
    end)
else
    print("failed to drop")
end
