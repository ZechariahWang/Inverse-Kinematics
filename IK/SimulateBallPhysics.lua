task.wait(1)

local ball = workspace.Ball_SP
local gravity = Vector3.new(0, -196, 0)
local velocity = Vector3.new(5, 100, -100)
local positions = {}
local dt = task.wait()
local current_pos = ball.Position
local initial_pos = current_pos

while true do
	while true do
		table.insert(positions, current_pos)
		if current_pos.Y < ball.Position.Y then
			break
		end
		velocity += (gravity * dt)
		current_pos += (velocity * dt)
	end

	for _, position in ipairs(positions) do
		local p = Instance.new("Part")
		p.Anchored = true
		p.Size = Vector3.new(1, 1, 1)
		p.Position = position
		p.Parent = workspace

		ball.Position = position
		task.wait()
	end
	ball.Position = initial_pos
	wait(5)
end