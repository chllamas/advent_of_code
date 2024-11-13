local test_input = {
	".#.",
	"..#",
	"###",
}

local real_input = {
	".##...#.",
	".#.###..",
	"..##.#.#",
	"##...#.#",
	"#..#...#",
	"#..###..",
	".##.####",
	"..#####.",
}

local input = test_input

local function remainsActive(coord)
	local count = 0
	for _, active_cube in ipairs(ActiveCubes) do
	end
	return false
end

ActiveCubes = {}
for y = 1, #input do
	local row = input[y]
	for x = 1, row:len() do
		local ch = row:sub(x, x)
		if ch == "#" then
			table.insert(ActiveCubes, { x, y, 0 })
		end
	end
end

for _ = 1, 6 do
	local buffer = {}

	for _, cube in ipairs(active_cubes) do
	end

	active_cubes = buffer
end
