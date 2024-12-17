const std = @import("std");

const Graph = []const []const u8;

const Coord = struct {
    x: i32,
    y: i32,
};

const Node = struct {
    position: Coord,
    direction: Coord,
    running_score: u64,
};

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
            return .{ .x = @intCast(x), .y = @intCast(y) };
    }
    unreachable;
}

fn launchNode(graph: Graph, queue: *std.ArrayList(Node), pos: Coord, dir: Coord) !void {
    if (graph[@intCast(pos.y)][@intCast(pos.x)] == '.') {
        try queue.append(.{
            .position = pos,
            .direction = dir,
            .running_score = 1,
        });
    }
}

fn part1(allocator: std.mem.Allocator, buffer: []const u8) !void {
    const graph = try createGraph(allocator, buffer);
    defer allocator.free(graph);

    const visited = try allocator.alloc(bool, graph.len * graph[0].len);
    defer allocator.free(visited);

    var queue = std.ArrayList(Node).init(allocator);
    defer queue.deinit();

    const strt = findStartNode(graph);
    try launchNode(graph, &queue, .{ .x = strt.x + 1, .y = strt.y }, .{ .x = 1, .y = 0 });
    try launchNode(graph, &queue, .{ .x = strt.x - 1, .y = strt.y }, .{ .x = -1, .y = 0 });
    try launchNode(graph, &queue, .{ .x = strt.x, .y = strt.y + 1 }, .{ .x = 0, .y = 1 });
    try launchNode(graph, &queue, .{ .x = strt.x, .y = strt.y - 1 }, .{ .x = 0, .y = -1 });
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
