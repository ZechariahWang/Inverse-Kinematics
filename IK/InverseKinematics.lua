local RunService = game:GetService("RunService")
local origin = workspace.Origin_IK -- Arm
local target = workspace.Target_IK -- Target
local target_secondary = workspace.Target_Secondary_IK

local mt = {
	__index = function(t, k)
		if k == "Head" then
			return (t.part.CFrame * CFrame.new(0, 0, -2.5)).Position
		elseif k == "Tail" then
			return (t.part.CFrame * CFrame.new(0, 0, 2.5)).Position
		else
			return t.part[k]
		end
	end,
	__newindex = function(t, k, v)
		t.part[k] = v
	end
}

local segmentsA = {}
for i = 1, 5 do
	segmentsA[i] = Instance.new("Part")
	segmentsA[i].Size = Vector3.new(1, 1, 5)
	segmentsA[i].Anchored = true
	segmentsA[i].CFrame = origin.CFrame * CFrame.new(0, 0, (i-1) * -5 - 2.5)
	segmentsA[i].Parent = workspace
	segmentsA[i] = setmetatable({part = segmentsA[i]}, mt)
end

-- Moving segment to target pos
local function move_segment(segment, target_pos)
	segment.CFrame = CFrame.lookAt(segment.Tail, target_pos)
	segment.CFrame *= CFrame.new(0, 0, -(target_pos - segment.Head).Magnitude)
end

-- Move arm in real time
local function move_arm_to_target_pos(target_pos)
	for i = 1, 5 do
		move_segment(segmentsA[5], target_pos)
		move_segment(segmentsA[4], segmentsA[5].Tail)
		move_segment(segmentsA[3], segmentsA[4].Tail)
		move_segment(segmentsA[2], segmentsA[3].Tail)
		move_segment(segmentsA[1], segmentsA[2].Tail)
		
		local offset = (segmentsA[1].Tail - origin.Position)
		for i = 1, 5 do
			segmentsA[i].Position -= offset
		end
	end
end

local function lerp(a, b, alpha)
	return a + (b - a) * alpha
end

local function flip(flip_val)
	return 1 - flip_val
end

local t                       = 0
local beta                    = 3
local exponential_compensator = 12
while wait() do
	t += wait()
	local target_pos = lerp(target_secondary.Position, target.Position, flip(flip(t / beta)^exponential_compensator)) -- Current time / 3, figures out how many seconds we are in the current interpolation, then move that amount to target 1 and 2
	-- local target_pos = target.Position
	move_arm_to_target_pos(target_pos)
	if t > beta then
		t = 0
	end
end