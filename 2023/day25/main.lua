local file = io.open("test.txt", "r")
if not file then
	error("Cannot open file")
end

local graph = {}

for line in file:lines() do
	local center = line:sub(1, 3)
	if not graph[center] then
		graph[center] = {}
	end
	for node in line:sub(6):gmatch("%S+") do
		if not graph[node] then
			graph[node] = {}
		end
		table.insert(graph[center], node)
		table.insert(graph[node], center)
	end
end

file:close()

for k, arr in pairs(graph) do
	print(k .. " |", unpack(arr))
end
