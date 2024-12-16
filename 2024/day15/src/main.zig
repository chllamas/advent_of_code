const std = @import("std");

const CoordList = []Coord;
const Direction = enum { left, right, up, down };
const Graph = [][]u8;
const Coord = struct {
    x: usize,
    y: usize,

    fn shift(self: Coord, dir: Direction) Coord {
        return switch (dir) {
            .left => .{ .x = self.x - 1, .y = self.y },
            .right => .{ .x = self.x + 1, .y = self.y },
            .up => .{ .x = self.x, .y = self.y - 1 },
            .down => .{ .x = self.x, .y = self.y + 1 },
        };
    }
};

fn createMutableGraph(allocator: std.mem.Allocator, buffer: []const u8) !Graph {
    var list = std.ArrayList([]u8).init(allocator);
    var iter = std.mem.splitScalar(u8, buffer, '\n');
    while (iter.next()) |line|
        try list.append(try allocator.dupe(u8, line));
    return try list.toOwnedSlice();
}

fn createMutableWideGraph(allocator: std.mem.Allocator, buffer: []const u8) !Graph {
    var list = std.ArrayList([]u8).init(allocator);
    var iter = std.mem.splitScalar(u8, buffer, '\n');
    while (iter.next()) |line| {
        var arr = try allocator.alloc(u8, line.len * 2);
        for (0.., line) |_i, ch| {
            const i: usize = _i * 2;
            switch (ch) {
                'O' => {
                    arr[i] = '[';
                    arr[i + 1] = ']';
                },
                '@' => {
                    arr[i] = '@';
                    arr[i + 1] = '.';
                },
                else => {
                    arr[i] = ch;
                    arr[i + 1] = ch;
                },
            }
        }
        try list.append(arr);
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

fn getDependencies(map: Graph, deps: *std.ArrayList(Coord), pos: Coord, dir: Direction) !bool {
    return switch (map[pos.y][pos.x]) {
        '.' => true,
        '#' => false,
        'O' => if (try getDependencies(map, deps, pos.shift(dir), dir)) o_check: {
            try deps.append(pos);
            break :o_check true;
        } else false,
        '[', ']' => wide_check: {
            // TODO: Get the vertical dependencies to close off boxes into a list
            // How do I avoid check upper boxes without checking twice
            break :wide_check true;
        },
        else => unreachable,
    };
}

fn moveRobot(map: Graph, rbt: Coord, dir: Direction) !Coord {
    var list = std.ArrayList(Coord).init(std.heap.page_allocator);
    defer list.deinit();
    if (try getDependencies(map, &list, rbt.shift(dir), dir)) {
        for (list.items) |node|
            swap(map, node, node.shift(dir));
        const nxt = rbt.shift(dir);
        swap(map, rbt, nxt);
        return nxt;
    }
    return rbt;
}

fn part1(allocator: std.mem.Allocator, buffer: []const u8) !void {
    var map_split = std.mem.splitSequence(u8, buffer, "\n\n");

    const map = try createMutableGraph(allocator, map_split.next().?);
    defer freeGraph(allocator, map);

    var rbt = initMap(map);
    const instructions = map_split.next().?;
    for (instructions) |instr| rbt = switch (instr) {
        '<' => try moveRobot(map, rbt, .left),
        '^' => try moveRobot(map, rbt, .up),
        '>' => try moveRobot(map, rbt, .right),
        'v' => try moveRobot(map, rbt, .down),
        else => rbt,
    };

    std.debug.print("Result: {}\n", .{calculateGoods(map)});
}

fn part2(allocator: std.mem.Allocator, buffer: []const u8) !void {
    var map_split = std.mem.splitSequence(u8, buffer, "\n\n");

    const map = try createMutableWideGraph(allocator, map_split.next().?);
    defer freeGraph(allocator, map);

    var rbt = initMap(map);
    const instructions = map_split.next().?;
    for (instructions) |instr| rbt = switch (instr) {
        '<' => moveRobot(map, rbt, .left),
        '^' => moveRobot(map, rbt, .up),
        '>' => moveRobot(map, rbt, .right),
        'v' => moveRobot(map, rbt, .down),
        else => rbt,
    };

    std.debug.print("Result: {}\n", .{calculateGoods(map)});
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
