const std = @import("std");

const Coord = struct {
    x: i64,
    y: i64,
};

const Node = struct {
    pos: Coord,
    dir: Coord,
};

fn createMap(allocator: std.mem.Allocator, buffer: []const u8) ![][]const u8 {
    var arr = std.ArrayList([]const u8).init(allocator);
    defer arr.deinit();

    var iter = std.mem.splitScalar(u8, buffer, '\n');
    while (iter.next()) |line| {
        if (line.len > 0) {
            try arr.append(line);
        }
    }

    const result = try arr.toOwnedSlice();
    return result;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("test.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    const map = try createMap(allocator, buffer);
    defer allocator.free(map);

    const visited = try allocator.alloc(bool, map.len * map[0].len);
    defer allocator.free(visited);
    for (0..visited.len) |i| {
        visited[i] = false;
    }

    var nodes = std.ArrayList(Node).init(allocator);
    defer nodes.deinit();
    try nodes.append(.{ .pos = .{ .x = 0, .y = 0 }, .dir = .{ .x = 1, .y = 0 } });

    var res: u32 = 0;

    while (nodes.popOrNull()) |node| {
        node_loop: while (true) {
            const len_y: usize = @intCast(node.pos.y);
            const len_x: usize = @intCast(node.pos.x);
            const id: usize = (len_y * map[0].len) + len_x;
            if (!visited[id]) {
                visited[id] = true;
                res += 1;
            }
            switch (map[@intCast(node.pos.y)][@intCast(node.pos.x)]) {
                '|' => if (node.dir.x != 0) {
                    if (node.pos.y > 0) {
                        try nodes.append(.{
                            .pos = .{
                                .x = node.pos.x,
                                .y = node.pos.y - 1,
                            },
                            .dir = .{
                                .x = 0,
                                .y = -1,
                            },
                        });
                    }
                    if (node.pos.y < map.len - 1) {
                        try nodes.append(.{
                            .pos = .{
                                .x = node.pos.x,
                                .y = node.pos.y + 1,
                            },
                            .dir = .{
                                .x = 0,
                                .y = 1,
                            },
                        });
                    }
                    break :node_loop;
                },
                '-' => if (node.dir.y != 0) {
                    if (node.pos.x > 0) {
                        try nodes.append(.{
                            .pos = .{
                                .x = node.pos.x - 1,
                                .y = node.pos.y,
                            },
                            .dir = .{
                                .x = -1,
                                .y = 0,
                            },
                        });
                    }
                    if (node.pos.x < map[0].len - 1) {
                        try nodes.append(.{
                            .pos = .{
                                .x = node.pos.x + 1,
                                .y = node.pos.y,
                            },
                            .dir = .{
                                .x = 1,
                                .y = 0,
                            },
                        });
                    }
                    break :node_loop;
                },
                '/' => {
                    node = .{};
                },
                '\\' => {
                    const t = &node.dir;
                    t.*.x = node.dir.x + node.dir.y;
                    t.*.y = node.dir.x - node.dir.y;
                    t.*.x = node.dir.x - node.dir.y;
                    t.*.x *= -1;
                    t.*.y *= -1;
                },
                '.' => {},
                else => @compileError("Unhandled character case"),
            }
            if ((node.pos.x == 0 and node.dir.x == -1) or
                (node.pos.x == map[0].len - 1 and node.dir.x == 1) or
                (node.pos.y == 0 and node.dir.y == -1) or
                (node.pos.y == map.len - 1 and node.dir.y == 1)) break;
            node.pos.x += node.dir.x;
            node.pos.y += node.dir.y;
        }
    }

    std.debug.print("Energized tiles: {d}\n", .{res});
}
