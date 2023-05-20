local origin = workspace.Origin_RR
local target = workspace.Target_RR

local up_dir = Vector3.new(0, 1, 0)
local forward_dir = Vector3.new(0, 0, -1)
local target_dir = ((target.Position - origin.Position) * Vector3.new(0, 1, 1)).Unit
local angle = math.deg(math.acos(target_dir:Dot(up_dir)))

if target_dir:Dot(up_dir) < 0 then
	angle = 360 - angle
end

print(angle)

while wait() do
	local x = math.cos(math.rad(angle))
	local y = math.sin(math.rad(angle))
	target.Position = origin.Position + Vector3.new(0, y, -x) * 25
	angle += 3
	angle = angle % 360
end