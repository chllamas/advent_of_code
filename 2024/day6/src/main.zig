const std = @import("std");

const Direction = enum { up, left, down, right };

const Coordinate = struct {
    x: usize,
    y: usize,
};

const Guard = struct {
    pos: Coordinate,
    dir: Direction,
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

fn findStartPosition(graph: []const []const u8) Coordinate {
    for (0.., graph) |y, row| {
        for (0.., row) |x, ch| {
            if (ch == '^') {
                return Coordinate{
                    .x = x,
                    .y = y,
                };
            }
        }
    }
    @panic("Unreachable: Start position not found\n");
}

fn nextStep(graph: []const []const u8, guard: Guard) ?Guard {
    switch (guard.dir) {
        .up => if (guard.pos.y == 0)
            return null
        else
            return if (graph[guard.pos.y - 1][guard.pos.x] == '#')
                nextStep(graph, .{ .pos = guard.pos, .dir = Direction.right })
            else
                .{
                    .pos = .{ .x = guard.pos.x, .y = guard.pos.y - 1 },
                    .dir = guard.dir,
                },

        .down => if (guard.pos.y == graph.len - 1)
            return null
        else
            return if (graph[guard.pos.y + 1][guard.pos.x] == '#')
                nextStep(graph, .{ .pos = guard.pos, .dir = Direction.left })
            else
                .{
                    .pos = .{ .x = guard.pos.x, .y = guard.pos.y + 1 },
                    .dir = guard.dir,
                },

        .left => if (guard.pos.x == 0)
            return null
        else
            return if (graph[guard.pos.y][guard.pos.x - 1] == '#')
                nextStep(graph, .{ .pos = guard.pos, .dir = Direction.up })
            else
                .{
                    .pos = .{ .x = guard.pos.x - 1, .y = guard.pos.y },
                    .dir = guard.dir,
                },

        .right => if (guard.pos.x == graph[0].len - 1)
            return null
        else
            return if (graph[guard.pos.y][guard.pos.x + 1] == '#')
                nextStep(graph, .{ .pos = guard.pos, .dir = Direction.down })
            else
                .{
                    .pos = .{ .x = guard.pos.x + 1, .y = guard.pos.y },
                    .dir = guard.dir,
                },
    }
}

fn part1(allocator: std.mem.Allocator, buffer: []const u8) !void {
    var count: u32 = 0;

    const graph = try createGraph(allocator, buffer);
    defer allocator.free(graph);

    var visited = try allocator.alloc(bool, graph.len * graph[0].len);
    defer allocator.free(visited);

    var _guard: ?Guard = Guard{ .pos = findStartPosition(graph), .dir = Direction.up };
    while (_guard) |guard| {
        defer _guard = nextStep(graph, guard);
        const index = (guard.pos.y * graph.len) + guard.pos.x;
        if (!visited[index]) {
            visited[index] = true;
            count += 1;
        }
    }

    std.debug.print("Visited: {}\n", .{count});
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
