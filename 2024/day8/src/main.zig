const std = @import("std");

const Coord = struct {
    x: i32,
    y: i32,
};

const AntennaHashMap = std.AutoHashMap(u8, []Coord);

fn addAntenna(hashmap: *AntennaHashMap, key: u8, newCoord: Coord) !void {
    if (hashmap.*.get(key)) |arr| {
        var new_arr = try hashmap.*.allocator.alloc(Coord, arr.len + 1);
        std.mem.copyForwards(Coord, new_arr, arr);
        new_arr[new_arr.len - 1] = newCoord;
        hashmap.*.allocator.free(arr);
        try hashmap.*.put(key, new_arr);
    } else {
        var arr = try hashmap.*.allocator.alloc(Coord, 1);
        arr[0] = newCoord;
        try hashmap.*.putNoClobber(key, arr);
    }
}

fn createGraph(allocator: std.mem.Allocator, buffer: []const u8) ![]const []const u8 {
    var list = std.ArrayList([]const u8).init(allocator);
    var iter = std.mem.splitScalar(u8, buffer, '\n');
    while (iter.next()) |line| {
        if (line.len == 0) continue;
        try list.append(line);
    }
    return try list.toOwnedSlice();
}

fn markVisited(graph: []const []const u8, visited: *[]bool, coord: Coord) bool {
    if (coord.x < 0 or coord.y < 0 or coord.x >= graph[0].len or coord.y >= graph.len) return false;
    const x: usize = @abs(coord.x);
    const y: usize = @abs(coord.y);
    const index: usize = (y * graph[0].len) + x;
    if (!visited.*[index]) {
        visited.*[index] = true;
        return true;
    }
    return false;
}

fn part1(allocator: std.mem.Allocator, buffer: []const u8) !void {
    const graph = try createGraph(allocator, buffer);
    defer allocator.free(graph);

    var count: u32 = 0;
    defer std.debug.print("Result: {}\n", .{count});

    var visited = try allocator.alloc(bool, graph.len * graph[0].len);
    defer allocator.free(visited);

    var antennas = AntennaHashMap.init(allocator);
    for (0.., graph) |y, row| {
        for (0.., row) |x, key| {
            if (key != '.')
                try addAntenna(&antennas, key, .{ .x = @intCast(x), .y = @intCast(y) });
        }
    }

    var antennas_iter = antennas.iterator();
    while (antennas_iter.next()) |_batch| {
        const batch = _batch.value_ptr.*;
        for (0.., batch) |n, c1| {
            if (n == batch.len - 1) break;
            for (batch[n + 1 ..]) |c2| {
                const dx: i32 = @intCast(@abs(c1.x - c2.x));
                const dy: i32 = @intCast(@abs(c1.y - c2.y));
                const diffx1: i32 = @divExact(c1.x - c2.x, dx);
                const diffx2: i32 = @divExact(c2.x - c1.x, dx);
                const diffy1: i32 = @divExact(c1.y - c2.y, dy);
                const diffy2: i32 = @divExact(c2.y - c1.y, dy);
                const a1 = Coord{
                    .x = c1.x + (diffx1 * dx),
                    .y = c1.y + (diffy1 * dy),
                };
                const a2 = Coord{
                    .x = c2.x + (diffx2 * dx),
                    .y = c2.y + (diffy2 * dy),
                };

                count += if (markVisited(graph, &visited, a1)) 1 else 0;
                count += if (markVisited(graph, &visited, a2)) 1 else 0;
            }
        }
    }
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    try part1(allocator, buffer);
}
