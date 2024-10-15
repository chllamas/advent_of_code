const std = @import("std");

const Direction = enum { up, left, right, down };
const Node = struct { x: usize, y: usize };

fn nextToVisit(unvisited_nodes: []const Node, distance_table: []const []const ?u32) ?usize {
    var index: ?usize = null;
    var res_dist: u32 = std.math.maxInt(u32);
    for (0.., unvisited_nodes) |i, node| {
        const node_distance = distance_table[node.pos.y][node.pos.x];
        if (node_distance != null and (index == null or node_distance.? < res_dist)) {
            index = i;
            res_dist = node_distance.?;
        }
    }
    return index;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var array = std.ArrayList([]const u8).init(allocator);
    defer array.deinit();

    var iter = std.mem.splitScalar(u8, buffer, '\n');
    while (iter.next()) |line| {
        if (line.len > 0)
            try array.append(line);
    }

    const map = try array.toOwnedSlice();
    defer allocator.free(map);

    // TODO: This table needs to include direction and its streak
    var distances_table = try allocator.alloc([]?u32, map.len);
    defer allocator.free(distances_table);
    for (0..distances_table.len) |i| {
        distances_table[i] = try allocator.alloc(?u32, map[0].len);
        for (distances_table[i]) |*t|
            t.* = null;
    }

    var visited = std.ArrayList(Node).init(allocator);
    defer visited.deinit();

    var not_visited = std.ArrayList(Node).init(allocator);
    defer not_visited.deinit();

    for (0..map.len) |y| {
        for (0..map[0].len) |x| {
            try not_visited.append(.{
                .pos = .{ .x = x, .y = y }, // TODO: Update to include the new table
                .streak = 0,
                .dir = null,
            });
        }
    }

    not_visited.items[0] = .{
        .pos = .{ .x = 0, .y = 0 },
        .dir = null, // TODO: Update to use the new table
        .streak = 1,
    };
    distances_table[0][0] = @intCast(map[0][0] - '0');

    while (nextToVisit(not_visited.items, distances_table)) |i| {
        const node = not_visited.swapRemove(i);
        // left node
        if (node.pos.x > 0 and (node.dir == null or node.dir.? != Direction.left or node.streak != 3)) {}

        // right node
        // up node
        // down node
        try visited.append(node);
    }

    for (distances_table) |d|
        allocator.free(d);
}
