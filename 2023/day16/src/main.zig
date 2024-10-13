const std = @import("std");

const Coord = struct {
    x: i64,
    y: i64,
};

const Node = struct {
    pos: Coord,
    dir: Coord,
};

fn printVisitMap(map: [][]const u8, visited: []const u8, current_pos: Coord) void {
    for (0.., map) |y, row| {
        for (0.., row) |x, _| {
            const id: usize = (y * map[0].len) + x;
            if (x == current_pos.x and y == current_pos.y)
                std.debug.print("O", .{})
            else if (visited[id] > 0)
                std.debug.print("#", .{})
            else
                std.debug.print(".", .{});
        }
        std.debug.print("\n", .{});
    }
}

fn swapAndNegate(pt: Coord) Coord {
    return Coord{
        .x = -pt.y,
        .y = -pt.x,
    };
}

fn swap(pt: Coord) Coord {
    return Coord{
        .x = pt.y,
        .y = pt.x,
    };
}

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

fn runConfig(allocator: std.mem.Allocator, map: [][]const u8, start_node: Node) !u64 {
    var res: u64 = 0;
    const visited = try allocator.alloc(u8, map.len * map[0].len);
    defer allocator.free(visited);
    for (0..visited.len) |i| {
        visited[i] = 0;
    }

    var nodes = std.ArrayList(Node).init(allocator);
    defer nodes.deinit();
    try nodes.append(start_node);

    while (nodes.popOrNull()) |obj| {
        var pos = obj.pos;
        var dir = obj.dir;
        node_loop: while (true) {
            const px: usize = @intCast(pos.x);
            const py: usize = @intCast(pos.y);
            const id: usize = (py * map[0].len) + px;

            if (visited[id] == 0)
                res += 1;
            visited[id] += 1;

            switch (map[py][px]) {
                '|' => if (px != 0) {
                    if (visited[id] <= 1) {
                        if (py > 0) try nodes.append(.{
                            .pos = .{
                                .x = pos.x,
                                .y = pos.y - 1,
                            },
                            .dir = .{
                                .x = 0,
                                .y = -1,
                            },
                        });
                        if (py < map[0].len - 1) try nodes.append(.{
                            .pos = .{
                                .x = pos.x,
                                .y = pos.y + 1,
                            },
                            .dir = .{
                                .x = 0,
                                .y = 1,
                            },
                        });
                    }
                    break :node_loop;
                },
                '-' => if (py != 0) {
                    if (visited[id] <= 1) {
                        if (px > 0) try nodes.append(.{
                            .pos = .{
                                .x = pos.x - 1,
                                .y = pos.y,
                            },
                            .dir = .{
                                .x = -1,
                                .y = 0,
                            },
                        });
                        if (px < map[0].len - 1) try nodes.append(.{
                            .pos = .{
                                .x = pos.x + 1,
                                .y = pos.y,
                            },
                            .dir = .{
                                .x = 1,
                                .y = 0,
                            },
                        });
                    }
                    break :node_loop;
                },
                '/' => dir = swapAndNegate(dir),
                '\\' => dir = swap(dir),
                '.' => {},
                else => {
                    std.debug.print("Unhandled character: {c}\n", .{map[py][px]});
                    @panic("Unhandled character case");
                },
            }

            if ((pos.x == 0 and dir.x == -1) or
                (pos.x == map[0].len - 1 and dir.x == 1) or
                (pos.y == 0 and dir.y == -1) or
                (pos.y == map.len - 1 and dir.y == 1))
            {
                break :node_loop;
            }

            pos = .{
                .x = pos.x + dir.x,
                .y = pos.y + dir.y,
            };
        }
    }

    return res;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    const map = try createMap(allocator, buffer);
    defer allocator.free(map);

    var largest: u64 = 0;
    const map_xend: i64 = @intCast(map[0].len);
    const map_yend: i64 = @intCast(map.len);
    const top_left = Coord{ .x = 0, .y = 0 };
    const top_right = Coord{ .x = map_xend - 1, .y = 0 };
    const bot_left = Coord{ .x = 0, .y = map_yend - 1 };
    const bot_right = Coord{ .x = map_xend - 1, .y = map_yend - 1 };

    largest = @max(largest, try runConfig(allocator, map, .{ .pos = top_left, .dir = .{ .x = 1, .y = 0 } }));
    largest = @max(largest, try runConfig(allocator, map, .{ .pos = top_left, .dir = .{ .x = 0, .y = 1 } }));
    largest = @max(largest, try runConfig(allocator, map, .{ .pos = top_right, .dir = .{ .x = -1, .y = 0 } }));
    largest = @max(largest, try runConfig(allocator, map, .{ .pos = top_right, .dir = .{ .x = 0, .y = 1 } }));
    largest = @max(largest, try runConfig(allocator, map, .{ .pos = bot_left, .dir = .{ .x = 1, .y = 0 } }));
    largest = @max(largest, try runConfig(allocator, map, .{ .pos = bot_left, .dir = .{ .x = 0, .y = -1 } }));
    largest = @max(largest, try runConfig(allocator, map, .{ .pos = bot_right, .dir = .{ .x = -1, .y = 0 } }));
    largest = @max(largest, try runConfig(allocator, map, .{ .pos = bot_right, .dir = .{ .x = 0, .y = -1 } }));
    var y: i64 = 1;
    while (y < map_yend - 1) : (y += 1) {
        const left_node = Node{ .pos = .{ .x = 0, .y = y }, .dir = .{ .x = 1, .y = 0 } };
        const right_node = Node{ .pos = .{ .x = map_xend - 1, .y = y }, .dir = .{ .x = -1, .y = 0 } };
        largest = @max(largest, try runConfig(allocator, map, left_node));
        largest = @max(largest, try runConfig(allocator, map, right_node));
    }

    var x: i64 = 1;
    while (x < map_xend - 1) : (x += 1) {
        const top_node = Node{ .pos = .{ .x = x, .y = 0 }, .dir = .{ .x = 0, .y = 1 } };
        const bot_node = Node{ .pos = .{ .x = x, .y = map_yend - 1 }, .dir = .{ .x = 0, .y = -1 } };
        largest = @max(largest, try runConfig(allocator, map, top_node));
        largest = @max(largest, try runConfig(allocator, map, bot_node));
    }

    std.debug.print("Energized tiles: {d}\n", .{largest});
}
