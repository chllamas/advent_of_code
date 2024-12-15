const std = @import("std");

const Graph = [][]u8;

const Coord = struct {
    x: usize,
    y: usize,
};

fn createMutableGraph(allocator: std.mem.Allocator, buffer: []const u8) !Graph {
    var list = std.ArrayList([]u8).init(allocator);
    var iter = std.mem.splitScalar(u8, buffer, '\n');
    while (iter.next()) |line| {
        if (line.len == 0) continue;
        try list.append(try allocator.dupe(u8, line));
    }
    return try list.toOwnedSlice();
}

fn freeGraph(allocator: std.mem.Allocator, graph: Graph) void {
    for (graph) |g| allocator.free(g);
    allocator.free(graph);
}

fn initMap(graph: Graph) Coord {
    for (0.., graph) |y, row| {
        for (0.., row) |x, ch| {
            if (ch == '@') return .{ .x = x, .y = y };
        }
    }

    @panic("Unreachable code");
}

fn calculateGoods(map: Graph) usize {
    var sum: usize = 0;
    for (0.., map) |y, row| {
        for (0.., row) |x, ch| {
            if (ch == 'O') sum += (100 * y) + x;
        }
    }
    return sum;
}

fn swap(map: Graph, a: Coord, b: Coord) void {
    const t = map[a.y][a.x];
    map[a.y][a.x] = map[b.y][b.x];
    map[b.y][b.x] = t;
}

fn findFirstDot(map: Graph, pos: Coord, dx: i2, dy: i2) ?Coord {
    var new_coord = pos;
    while (map[new_coord.y][new_coord.x] != '#') : (new_coord = .{
        .x = switch (dx) {
            -1 => new_coord.x - 1,
            1 => new_coord.x + 1,
            else => new_coord.x,
        },
        .y = switch (dy) {
            -1 => new_coord.y - 1,
            1 => new_coord.y + 1,
            else => new_coord.y,
        },
    }) switch (map[new_coord.y][new_coord.x]) {
        '.' => return .{ .x = new_coord.x, .y = new_coord.y },
        else => continue,
    };
    return null;
}

fn part1(allocator: std.mem.Allocator, buffer: []const u8) !void {
    var map_split = std.mem.splitSequence(u8, buffer, "\n\n");

    const map = try createMutableGraph(allocator, map_split.next().?);
    defer freeGraph(allocator, map);

    var r = initMap(map);

    const instructions = map_split.next().?;
    for (instructions) |instr| switch (instr) {
        '<' => {
            switch (map[r.y][r.x - 1]) {
                '.' => {
                    swap(map, .{ .x = r.x - 1, .y = r.y }, r);
                    r = .{ .x = r.x - 1, .y = r.y };
                },
                'O' => {
                    // TODO: First check that there is a dot to swap with, then swap robot with dot
                    swap(map, .{ .x = r.x - 1, .y = r.y }, r);
                    r = .{ .x = r.x - 1, .y = r.y };
                },
                else => {},
            }
        },
        '^' => {},
        'v' => {},
        '>' => {},
        else => {},
    };

    std.debug.print("Result: {}\n", .{calculateGoods(map)});
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
