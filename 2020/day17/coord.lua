---@class Coord
local coord = {}
coord.__index = coord

--- A global table containing `Coord` objects
--- @type table <number, Coord>
ActiveCubes = {}

--- Create new coord
--- @param x number
--- @param y number
--- @param z number
--- @return Coord
function coord.new(x, y, z)
	local self = {
		x = x,
		y = y,
		z = z,
	}
	return setmetatable(self, coord)
end

--- Checks to see if coords are neighbors
--- @param other Coord
function coord:isNeighbor(other)
	return self[0] == other[0] and self[1] == other[1] and self[2] == other[2]
end

--- Creates a generator for this coord to iterate all of its neighbors using global `ActiveCubes`
function coord:getNeighbors()
	for z = -1, 1 do
		for y = -1, 1 do
			for x = -1, 1 do
				if x == 0 and y == 0 and z == 0 then
					goto continue
				end

				-- TODO: yield neighbors

				::continue::
			end
		end
	end
end

--- Checks global `ActiveCubes` table to see if coord is still active
--- NOTE: Assumes this coord is `active`
---
--- @return boolean
function coord:remainsActive()
	local count = 0
	for _, c in ipairs(ActiveCubes) do
		if self:isNeighbor(c) then
			count = count + 1
			if count > 3 then
				return false
			end
		end
	end
	return count == 2 or count == 3
end

return coord
