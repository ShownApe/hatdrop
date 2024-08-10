-- drops all ur hats wherever you ran the script
-- made as a proof of concept and resource for how to use the hats (animations, fling, whatever) for your own script
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

local allhats = {}
for i,v in pairs(character:GetChildren()) do
    if v:IsA("Accessory") then
        table.insert(allhats,v)
    end
end

local locks = {}
for i,v in pairs(allhats) do
    table.insert(locks,v.Changed:Connect(function(p)
        if p == "BackendAccoutrementState" then
            updatestate(v,0)
        end
    end))
    updatestate(v,2)
end

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
        hrp.Velocity = Vector3.new(0,25,0) -- 10 is the original for r6
        hrp.RotVelocity = Vector3.new(0,0,0)
        game:GetService("RunService").Heartbeat:wait()
    end
end)

task.wait(.25)
character.Humanoid:ChangeState(15)
torso.AncestryChanged:wait()

for i,v in pairs(locks) do
    v:Disconnect()
end
for i,v in pairs(allhats) do
    updatestate(v,4)
end

spawn(function()
    plr.CharacterAdded:wait():WaitForChild("HumanoidRootPart",10).CFrame = start
    workspace.FallenPartsDestroyHeight = fph
end)

local dropped = false
repeat
    local foundhandle = false
    for i,v in pairs(allhats) do
        if v:FindFirstChild("Handle") then
            foundhandle = true
            if v.Handle.CanCollide then
                dropped = true
                break
            end
        end
    end
    if not foundhandle then
        break
    end
    task.wait()
until plr.Character ~= character or dropped

if dropped then
    print("dropped")
    workspace.CurrentCamera.CameraSubject = campart
    for i,v in pairs(character:GetChildren()) do
        if v:IsA("Accessory") and v:FindFirstChild("Handle") and v.Handle.CanCollide then
            spawn(function()
                for i = 1,10 do
                    v.Handle.CFrame = start
                    v.Handle.Velocity = Vector3.new(0,50,0)
                    task.wait()
                end
            end)
        end
    end
else
    print("failed to drop")
end
