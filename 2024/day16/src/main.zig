const std = @import("std");

const Coord = struct {
    x: i32,
    y: i32,
};

const Node = struct {
    position: Coord,
    direction: Coord,
    running_score: u64,
};

const Graph = []const []const u8;

fn createGraph(allocator: std.mem.Allocator, buffer: []const u8) !Graph {
    var list = std.ArrayList([]const u8).init(allocator);
    var iter = std.mem.splitScalar(u8, buffer, '\n');
    while (iter.next()) |line| {
        if (line.len == 0) continue;
        try list.append(line);
    }
    return try list.toOwnedSlice();
}

fn findStartNode(graph: Graph) Coord {
    for (0.., graph) |y, row| {
        for (0.., row) |x, ch| if (ch == 'S')
            return .{ .x = x, .y = y };
    }
    unreachable;
}

fn part1(allocator: std.mem.Allocator, buffer: []const u8) !void {
    const graph = try createGraph(allocator, buffer);
    defer allocator.free(graph);

    var visited = try allocator.alloc(bool, graph.len * graph[0].len);
    defer allocator.free(visited);

    var queue = std.ArrayList(Node).init(allocator);
    defer queue.deinit();
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    try part1(allocator, std.mem.trimRight(u8, buffer, "\n"));
    // try part2(allocator, std.mem.trimRight(u8, buffer, "\n"));
}
