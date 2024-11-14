local Coord = require("coord")

local input = {
	".#.",
	"..#",
	"###",
}

local _ = {
	".##...#.",
	".#.###..",
	"..##.#.#",
	"##...#.#",
	"#..#...#",
	"#..###..",
	".##.####",
	"..#####.",
}

for y = 1, #input do
	local row = input[y]
	for x = 1, row:len() do
		local ch = row:sub(x, x)
		if ch == "#" then
			table.insert(ActiveCubes, Coord.new(x, y, 0))
		end
	end
end

for _ = 1, 6 do
	local ac_buffer = {}
end
