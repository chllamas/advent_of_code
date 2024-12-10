const std = @import("std");

const Coord = struct {
    x: usize,
    y: usize,
};

fn createGraph(allocator: std.mem.Allocator, buffer: []const u8) ![]const []const u8 {
    var list = std.ArrayList([]const u8).init(allocator);
    var iter = std.mem.splitScalar(u8, buffer, '\n');
    while (iter.next()) |line| {
        if (line.len == 0) continue;
        try list.append(line);
    }
    return try list.toOwnedSlice();
}

fn calculateScore(allocator: std.mem.Allocator, graph: []const []const u8, start_point: Coord) !u8 {
    // TODO: Maybe we need to check if the 9 was visited before
    var count: u8 = 0;
    var stack = std.ArrayList(Coord).init(allocator);
    try stack.append(start_point);
    defer stack.deinit();
    while (stack.popOrNull()) |node| {
        if (graph[node.y][node.x] == '9') {
            count += 1;
            continue;
        }
        const x: usize = node.x;
        const y: usize = node.y;
        if (x > 0 and graph[y][x - 1] == graph[y][x] + 1)
            try stack.append(.{ .x = x - 1, .y = y });
        if (y > 0 and graph[y - 1][x] == graph[y][x] + 1)
            try stack.append(.{ .x = x, .y = y - 1 });
        if (y < graph.len - 1 and graph[y + 1][x] == graph[y][x] + 1)
            try stack.append(.{ .x = x, .y = y + 1 });
        if (x < graph[0].len - 1 and graph[y][x + 1] == graph[y][x] + 1)
            try stack.append(.{ .x = x + 1, .y = y });
    }
    std.debug.print("Trailhead of score: {}\n", .{count});
    return count;
}

fn part1(allocator: std.mem.Allocator, buffer: []const u8) !void {
    var count: u32 = 0;
    const graph = try createGraph(allocator, buffer);
    for (0.., graph) |y, row| {
        for (0.., row) |x, ch| {
            if (ch == '0')
                count += try calculateScore(allocator, graph, .{ .x = x, .y = y });
        }
    }
    std.debug.print("Result: {}\n", .{count});
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("test.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    try part1(allocator, std.mem.trimRight(u8, buffer, "\n"));
    // try part2(allocator, std.mem.trimRight(u8, buffer, "\n"));
}
