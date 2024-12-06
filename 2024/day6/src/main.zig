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

// returns null when we are leaving the map with this
fn nextStep(graph: []const []const u8, position: Coordinate, direction: Direction) ?Guard {
    switch (direction) {
        .up => if (position.y == 0)
            return null
        else
            return if (graph[position.y - 1][position.x] == '#')
                nextStep(graph, position, Direction.right)
            else
                .{
                    .pos = .{ .x = position.x, .y = position.y - 1 },
                    .dir = Direction.up,
                    // TODO: FIx the Guard retursn
                },
        .down => if (position.y == graph.len - 1)
            return null
        else
            return if (graph[position.y + 1][position.x] == '#')
                nextStep(graph, position, Direction.left)
            else
                .{ .x = position.x, .y = position.y + 1 },
        .left => if (position.x == 0)
            return null
        else
            return if (graph[position.y][position.x - 1] == '#')
                nextStep(graph, position, Direction.up)
            else
                .{ .x = position.x - 1, .y = position.y },
        .right => if (position.x == graph[0].len - 1)
            return null
        else
            return if (graph[position.y][position.x + 1] == '#')
                nextStep(graph, position, Direction.down)
            else
                .{ .x = position.x + 1, .y = position.y },
    }
}

fn part1(graph: []const []const u8) !void {
    var guard = Guard{ .pos = findStartPosition(graph), .dir = Direction.up };
    while (guard.pos) |position| {}
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("test.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    try part1(try createGraph(allocator, buffer));
}
