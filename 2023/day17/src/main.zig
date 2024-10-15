const std = @import("std");

const Direction = enum { up, left, right, down };

const Node = struct {
    pos: .{ u32, u32 },
    px: usize,
    py: usize,
    dir: ?Direction,
    streak: u8,
};

fn nextToVisit(to_visit: []Node) ?u64 {
    var result: ?u64 = null;
    var res_dist: u64 = 0;
    for (0.., to_visit) |i, node| {
        if (node.dist != null and (result == null or node.dist.? < res_dist)) {
            result = i;
            res_dist = node.dist.?;
        }
    }
    return result;
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

    const distances = try allocator.alloc([]?u32, map.len);
    defer allocator.free(distances);
    for (0..distances.len) |i|
        distances[i] = try allocator.alloc(?u32, map[0].len);

    const visited = std.ArrayList(Node).init(allocator);
    defer visited.deinit();

    const non_visited = std.ArrayList(Node).init(allocator);
    defer non_visited.deinit();

    for (0..map.len) |y| {
        for (0..map[0].len) |x| {
            try non_visited.append(.{
                .pos = .{},
                .dir = null,
                .dist = null,
                .streak = null,
            });
            const t = non_visited.items[0];
            const y = t.pos;
        }
    }

    non_visited.items[0] = .{
        .pos = .{ .x = 0, .y = 0 },
        .dir = null,
        .dist = @intCast(map[0][0]),
        .streak = 1,
    };

    while (nextToVisit(non_visited)) |i| {
        const node = visited.swapRemove(i);
        if (node.pos.x > 0) {}
        try visited.append(node);
    }

    for (distances) |d|
        allocator.free(d);
}
