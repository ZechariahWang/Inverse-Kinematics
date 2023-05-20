
local RunService = game:GetService("RunService")

local characterA = workspace.CharacterA
local characterB = workspace.CharacterB
local ball = workspace.Ball_Human

-- init arm a segments
local segmentsA = {}
segmentsA[1] = workspace.CharacterA.A_UpperArm
segmentsA[2] = workspace.CharacterA.A_LowerArm
segmentsA[3] = workspace.CharacterA.A_Hand

-- init arm b segments
local segmentsB = {}
segmentsB[1] = workspace.CharacterB.B_UpperArm
segmentsB[2] = workspace.CharacterB.B_LowerArm
segmentsB[3] = workspace.CharacterB.B_Hand

local function lerp(a, b, t)
	return Vector3.new(
		a.X + (b.X - a.X) * t^3,
		a.Y + (b.Y - a.Y) * t,
		a.Z + (b.Z - a.Z) * t
	)
end

local function flip(x)
	return 1 - x
end

local function move(segment, target)
	segment.CFrame = CFrame.lookAt(
		(segment.CFrame * CFrame.new(0, 0, 2.5)).Position, target
	)
	segment.Position += (segment.CFrame.LookVector * ((target - segment.Position).Magnitude - 2.5))
end

local function moveSegmentsA(target)
	for i = 1, 5 do
		move(segmentsA[3], target)
		move(segmentsA[2], (segmentsA[3].CFrame * CFrame.new(0, 0, 2.5)).Position)
		move(segmentsA[1], (segmentsA[2].CFrame * CFrame.new(0, 0, 2.5)).Position)

		local offset = (segmentsA[1].CFrame * CFrame.new(0, 0, 2.5)).Position - characterA.Body.CFrame.Position

		segmentsA[1].CFrame -= offset
		segmentsA[2].CFrame -= offset
		segmentsA[3].CFrame -= offset
	end
end

local function moveSegmentsB(target)
	for i = 1, 5 do
		move(segmentsB[3], target)
		move(segmentsB[2], (segmentsB[3].CFrame * CFrame.new(0, 0, 2.5)).Position)
		move(segmentsB[1], (segmentsB[2].CFrame * CFrame.new(0, 0, 2.5)).Position)

		local offset = (segmentsB[1].CFrame * CFrame.new(0, 0, 2.5)).Position - characterB.Body.CFrame.Position

		segmentsB[1].CFrame -= offset
		segmentsB[2].CFrame -= offset
		segmentsB[3].CFrame -= offset
	end
end


while true do
	-- put ball in arm a
	ball.CFrame = segmentsA[3].CFrame * CFrame.new(0, 0, -2.5)

	-- arm a throw
	local ballDir = (ball.Position - characterA.Body.Position).Unit
	local upDir = Vector3.new(0, 1, 0).Unit
	local forwardDir = Vector3.new(0, 0, -1).Unit
	local angle = math.acos(ballDir:Dot(upDir))
	if (ballDir:Dot(forwardDir) > 0) then
		angle = 360 - math.deg(angle)
	else
		angle = math.deg(angle)
	end

	local angleLeft = angle + 360
	local target = ball.Position
	local p
	local dt
	local lastPosition = target
	while true do
		dt = RunService.Heartbeat:Wait()
		local angle = angleLeft % 360
		local newTarget
		do
			local x = math.cos(math.rad(angle)+math.pi/2)
			local y = math.sin(math.rad(angle)+math.pi/2)
			newTarget = characterA.Body.Position + Vector3.new(0, y, -x).Unit * 25
		end
		target = lerp(target, newTarget, .25)
		moveSegmentsA(target)
		ball.Position = target
		if angleLeft < 4 then
			break
		end
		lastPosition = target
		angleLeft -= 8
	end

	local dx = target - lastPosition
	local velo = dx / dt
	velo += Vector3.new(math.random() * 40 - 20, 0, 0)

	-- find where ball hits B arm zone
	local currentPosition = ball.Position
	local positions = {}
	local targetB

	while true do
		currentPosition += velo * dt
		if #positions > 0 and (currentPosition - characterB.Body.Position).Magnitude > (positions[#positions] - characterB.Body.Position).Magnitude then
			targetB = positions[#positions]
			break
		end

		table.insert(positions, currentPosition)
		if (currentPosition - characterB.Body.Position).Magnitude < 25 then
			targetB = currentPosition
			break
		end
		velo += (Vector3.new(0, -196, 0) * dt)
	end

	local startTargetB = segmentsB[3].CFrame * CFrame.new(0, 0, -2.5)

	-- ball travel in air and B move to catch
	for i = 1, #positions do
		RunService.Heartbeat:Wait()
		local alpha = i / #positions
		local currentTargetB = lerp(startTargetB.Position, targetB, flip(flip(alpha)^7))
		moveSegmentsB(currentTargetB)
		ball.Position = positions[i]
	end

	-- put ball in arm b
	ball.Position = (segmentsB[3].CFrame * CFrame.new(0, 0, -2.5)).Position

	-- arm b throw
	local ballDir = (ball.Position - characterB.Body.Position).Unit
	local upDir = Vector3.new(0, 1, 0).Unit
	local forwardDir = Vector3.new(0, 0, 1).Unit
	local angle = math.acos(ballDir:Dot(upDir))
	if (ballDir:Dot(forwardDir) > 0) then
		angle = 360 - math.deg(angle)
	else
		angle = math.deg(angle)
	end
	
	
	local angleLeft = angle + 360
	local target = ball.Position
	local p
	local dt
	local lastPosition = target
	while true do
		dt = RunService.Heartbeat:Wait()
		local angle = angleLeft % 360
		local newTarget
		do
			local x = math.cos(math.rad(angle)+math.pi/2)
			local y = math.sin(math.rad(angle)+math.pi/2)
			newTarget = characterB.Body.Position + Vector3.new(0, y, -x).Unit * 25
		end
		target = lerp(target, newTarget, .25)
		moveSegmentsB(target)
		ball.Position = target
		if angleLeft < 110 + 4 then
			break
		end
		lastPosition = target
		angleLeft -= 8
	end

	local dx = target - lastPosition
	local velo = dx / dt
	velo += Vector3.new(math.random() * 40 - 20, 0, 0)

	-- find where ball hits A arm zone
	local currentPosition = ball.Position
	local positions = {}
	local targetB

	while true do
		currentPosition += velo * dt

		if #positions > 0 and (currentPosition - characterA.Body.Position).Magnitude > (positions[#positions] - characterA.Body.Position).Magnitude then
			targetB = positions[#positions]
			break
		end

		table.insert(positions, currentPosition)
		if (currentPosition - characterA.Body.Position).Magnitude < 25 then
			targetB = currentPosition
			break
		end
		
		velo += (Vector3.new(0, -196, 0) * dt)
	end

	local startTargetB = segmentsA[3].CFrame * CFrame.new(0, 0, -2.5)

	-- ball travel in air and A move to catch
	for i = 1, #positions do
		RunService.Heartbeat:Wait()
		local alpha = i / #positions
		local currentTargetB = lerp(startTargetB.Position, targetB, flip(flip(alpha)^7))
		moveSegmentsA(currentTargetB)
		ball.Position = positions[i]
	end
end
