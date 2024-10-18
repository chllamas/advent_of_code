const std = @import("std");

const Direction = enum { up, left, right, down, any };
const Node = struct { x: usize, y: usize };
const State = struct {
    direction: Direction = Direction.any,
    streak: u2 = 0,
    dist: u32,
};

fn nextToVisit(unvisited_nodes: []const Node, distance_table: []const []const ?State) ?usize {
    var index: ?usize = null;
    var res_dist: u32 = std.math.maxInt(u32);
    for (0.., unvisited_nodes) |i, node| {
        const state = distance_table[node.y][node.x];
        if (state != null and (index == null or state.?.dist < res_dist)) {
            index = i;
            res_dist = state.?.dist;
        }
    }
    return index;
}

fn updatedState(state: State, neighbor_state: ?State, neighbor_heat: u32, flowing_direction: Direction) ?State {
    if (state.direction != flowing_direction or state.streak != 3) {
        if (neighbor_state == null or state.dist + neighbor_heat < neighbor_state.?.dist)
            return State{
                .dist = state.dist + neighbor_heat,
                .direction = flowing_direction,
                .streak = if (state.direction == flowing_direction or state.direction == Direction.any) state.streak + 1 else 1,
            };
    }
    return neighbor_state;
}

fn printStates(states_table: []const []const ?State) void {
    for (states_table) |row| {
        for (row) |state| {
            if (state != null) {
                std.debug.print(" ({s},{d:3}) ", .{ switch (state.?.direction) {
                    Direction.left => " < ",
                    Direction.right => " > ",
                    Direction.up => " ^ ",
                    Direction.down => " v ",
                    else => " # ",
                }, state.?.dist });
            } else {
                std.debug.print(" (???,???) ", .{});
            }
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n\n====\n\n", .{});
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("test.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var array = std.ArrayList([]const u8).init(allocator);
    defer array.deinit();

    var iter = std.mem.splitScalar(u8, buffer, '\n');
    while (iter.next()) |line| {
        if (line.len > 0)
            try array.append(line);
    }

    const map = try array.toOwnedSlice();
    defer allocator.free(map);

    var states_table = try allocator.alloc([]?State, map.len);
    defer allocator.free(states_table);
    for (states_table) |*t| {
        t.* = try allocator.alloc(?State, map[0].len);
        for (t.*) |*u|
            u.* = null;
    }

    var not_visited = std.ArrayList(Node).init(allocator);
    defer not_visited.deinit();

    for (0..map.len) |y| {
        for (0..map[0].len) |x| {
            try not_visited.append(.{ .x = x, .y = y });
        }
    }

    not_visited.items[0] = .{ .x = 0, .y = 0 };
    states_table[0][0] = .{
        .dist = 0,
        .streak = 1,
    };

    while (nextToVisit(not_visited.items, states_table)) |i| {
        const node = not_visited.swapRemove(i);
        const state = states_table[node.y][node.x].?;

        if (node.x > 0) {
            const left_node = &states_table[node.y][node.x - 1];
            left_node.* = updatedState(state, left_node.*, map[node.y][node.x - 1] - '0', Direction.left);
        }

        if (node.x < map[0].len - 1) {
            const right_node = &states_table[node.y][node.x + 1];
            right_node.* = updatedState(state, right_node.*, map[node.y][node.x + 1] - '0', Direction.right);
        }

        if (node.y > 0) {
            const up_node = &states_table[node.y - 1][node.x];
            up_node.* = updatedState(state, up_node.*, map[node.y - 1][node.x] - '0', Direction.up);
        }

        if (node.y < map.len - 1) {
            const down_node = &states_table[node.y + 1][node.x];
            down_node.* = updatedState(state, down_node.*, map[node.y + 1][node.x] - '0', Direction.down);
        }

        printStates(states_table);
    }

    const target_state = states_table[states_table.len - 1][states_table[0].len - 1];
    if (target_state) |result|
        std.debug.print("Shortest path to bottom left is: {d}\n", .{result.dist})
    else
        std.debug.print("Unfinished algorithm\n", .{});

    for (states_table) |d|
        allocator.free(d);
}
