const std = @import("std");

const target_graph = 6;
const bytes_read = 12;
const file_input = "test.txt";

// const target_graph = 70;
// const bytes_read = 1024;
// const file_input = "input.txt";

const Node = struct {
    p: Coord,
    priority: u32,
};

const Coord = struct {
    x: usize,
    y: usize,
};

fn createEmptyGraph(allocator: std.mem.Allocator, x: usize, y: usize) ![][]u8 {
    const graph = try allocator.alloc([]u8, y);
    for (graph) |*row| {
        row.* = try allocator.alloc(u8, x);
        for (row.*) |*ch| ch.* = '.';
    }
    return graph;
}

fn freeGraph(allocator: std.mem.Allocator, graph: []const []const u8) void {
    for (graph) |row| allocator.free(row);
    allocator.free(graph);
}

fn bfs(allocator: std.mem.Allocator, graph: []const []const u8) !u32 {
    const visited = try allocator.alloc(bool, graph.len * graph[0].len);
    for (visited) |*b| b.* = false;
    defer allocator.free(visited);

    var stack = std.PriorityQueue(Node, void, compare).init(allocator, {});
    try stack.add(.{ .p = .{ .x = 0, .y = 0 }, .priority = 0 });
    defer stack.deinit();

    while (stack.removeOrNull()) |node| {
        if (graph[node.p.y][node.p.x] == 'E') return node.priority;
        const idx = (graph[0].len * node.p.y) + node.p.x;
        visited[idx] = true;
        if (node.p.x > 0 and graph[node.p.y][node.p.x - 1] != '#' and !visited[idx - 1])
            try stack.add(.{ .priority = node.priority + 1, .p = .{ .x = node.p.x - 1, .y = node.p.y } });
        if (node.p.x < graph[0].len - 1 and graph[node.p.y][node.p.x + 1] != '#' and !visited[idx + 1])
            try stack.add(.{ .priority = node.priority + 1, .p = .{ .x = node.p.x + 1, .y = node.p.y } });
        if (node.p.y > 0 and graph[node.p.y - 1][node.p.x] != '#' and !visited[idx - graph[0].len])
            try stack.add(.{ .priority = node.priority + 1, .p = .{ .x = node.p.x, .y = node.p.y - 1 } });
        if (node.p.y < graph[0].len - 1 and graph[node.p.y + 1][node.p.x] != '#' and !visited[idx + graph[0].len])
            try stack.add(.{ .priority = node.priority + 1, .p = .{ .x = node.p.x, .y = node.p.y + 1 } });
    }

    return 0;
}

fn part1(allocator: std.mem.Allocator, buffer: []const u8) !void {
    const graph = try createEmptyGraph(allocator, target_graph + 1, target_graph + 1); // for test its 7 for real its 71
    defer freeGraph(allocator, graph);

    var points = std.mem.splitScalar(u8, buffer, '\n');
    for (0..bytes_read) |_| {
        var iter = std.mem.splitScalar(u8, points.next().?, ',');
        const x = try std.fmt.parseInt(usize, iter.next().?, 10);
        const y = try std.fmt.parseInt(usize, iter.next().?, 10);
        graph[y][x] = '#';
    }
    graph[target_graph][target_graph] = 'E';

    std.debug.print("Result: {}\n", .{try bfs(allocator, graph)});
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile(file_input[0..], .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    try part1(allocator, std.mem.trimRight(u8, buffer, "\n"));
    // try part2(allocator, std.mem.trimRight(u8, buffer, "\n"));
}

fn compare(_: void, a: Node, b: Node) std.math.Order {
    return std.math.order(a.priority, b.priority);
}
