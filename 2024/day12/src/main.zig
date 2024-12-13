const std = @import("std");

const Graph = []const []const u8;

const Shape = struct {
    shape_type: u8,
    area: u64,
    perimeter: u64,

    fn calcPrice(self: Shape) u64 {
        return self.area * self.perimeter;
    }

    fn add(self: *Shape, other: Shape) void {
        std.debug.assert(self.shape_type == other.shape_type);
        self.*.area += other.area;
        self.*.perimeter += other.perimeter;
    }

    fn increasePerimeter(self: *Shape) void {
        self.*.perimeter += 1;
    }
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

fn dfs(graph: Graph, visited: *[]bool, x: usize, y: usize) Shape {
    const idx: usize = (graph[0].len * y) + x;
    visited.*[idx] = true;

    var result = Shape{ .shape_type = graph[y][x], .area = 1, .perimeter = 0 };

    if (x == 0 or graph[y][x - 1] != graph[y][x])
        result.increasePerimeter()
    else if (!visited.*[idx - 1])
        result.add(dfs(graph, visited, x - 1, y));

    if (y == 0 or graph[y - 1][x] != graph[y][x])
        result.increasePerimeter()
    else if (!visited.*[idx - graph[0].len])
        result.add(dfs(graph, visited, x, y - 1));

    if (x == graph[0].len - 1 or graph[y][x + 1] != graph[y][x])
        result.increasePerimeter()
    else if (!visited.*[idx + 1])
        result.add(dfs(graph, visited, x + 1, y));

    if (y == graph.len - 1 or graph[y + 1][x] != graph[y][x])
        result.increasePerimeter()
    else if (!visited.*[idx + graph[0].len])
        result.add(dfs(graph, visited, x, y + 1));

    return result;
}

fn part1(allocator: std.mem.Allocator, buffer: []const u8) !void {
    const graph = try createGraph(allocator, buffer);
    defer allocator.free(graph);

    var visited = try allocator.alloc(bool, graph.len * graph[0].len);
    for (visited) |*b| b.* = false;
    defer allocator.free(visited);

    var sum: u64 = 0;
    for (0..visited.len) |i| {
        if (!visited[i])
            sum += dfs(
                graph,
                &visited,
                @mod(i, graph[0].len),
                @divFloor(i, graph[0].len),
            ).calcPrice();
    }

    std.debug.print("Result: {}\n", .{sum});
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
