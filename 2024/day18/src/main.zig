const std = @import("std");

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

// start by queuing 0,0 then going until we find 'E'
// returns number of steps
// avoids '#' can only traverse on '.'
fn bfs(allocator: std.mem.Allocator, graph: []const []const u8) !u32 {
    const visited = try allocator.alloc(bool, graph.len * graph[0].len);
    defer allocator.free(visited);

    var stack = std.ArrayList(Coord).init(allocator);
    try stack.append(.{ .x = 0, .y = 0 });
    defer stack.deinit();

    // ok
}

fn part1(allocator: std.mem.Allocator, buffer: []const u8) !void {
    const graph = try createEmptyGraph(allocator, 7, 7); // for test its 7 for real its 71
    defer freeGraph(allocator, graph);

    var points = std.mem.splitScalar(u8, buffer, '\n');
    for (0..12) |_| {
        var iter = std.mem.splitScalar(u8, points.next().?, ',');
        const x = try std.fmt.parseInt(usize, iter.next().?, 10);
        const y = try std.fmt.parseInt(usize, iter.next().?, 10);
        graph[y][x] = '#';
    }
    graph[7][7] = 'E';

    std.debug.print("Result: {}\n", .{bfs(graph)});
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
