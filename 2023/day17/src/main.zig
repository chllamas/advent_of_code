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

fn updatedState(state: State, neighbor_state: ?State, flowing_direction: Direction) ?State {
    if (state.direction != flowing_direction or state.streak != 3) {
        if (neighbor_state == null or state.dist + 1 < neighbor_state.?.dist)
            return State{
                .dist = state.dist + 1,
                .direction = flowing_direction,
                .streak = if (state.direction == flowing_direction or state.direction == Direction.any) state.streak + 1 else 1,
            };
    }
    return neighbor_state;
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
        .dist = @intCast(map[0][0] - '0'),
        .streak = 1,
    };

    while (nextToVisit(not_visited.items, states_table)) |i| {
        const node = not_visited.swapRemove(i);
        const state = states_table[node.y][node.x].?;

        // left node
        if (node.x > 0 and (state.direction != Direction.left or state.streak != 3)) {
            if (states_table[node.y][node.x - 1]) |*left_node| {
                if (state.dist + 1 < left_node.*.dist)
                    left_node.* = .{
                        .dist = state.dist + 1,
                        .direction = Direction.left,
                        .streak = if (state.direction == Direction.left or state.direction == Direction.any) state.streak + 1 else 1,
                    };
            } else {
                states_table[node.y][node.x - 1] = State{
                    .dist = state.dist + 1,
                    .direction = Direction.left,
                    .streak = if (state.direction == Direction.left or state.direction == Direction.any) state.streak + 1 else 1,
                };
            }
        }

        // right node
        if (node.x < map[0].len - 1 and (state.direction != Direction.right or state.streak != 3)) {
            if (states_table[node.y][node.x + 1]) |*right_node| {
                if (state.dist + 1 < right_node.*.dist)
                    right_node.* = .{
                        .dist = state.dist + 1,
                        .direction = Direction.right,
                        .streak = if (state.direction == Direction.right or state.direction == Direction.any) state.streak + 1 else 1,
                    };
            } else {
                states_table[node.y][node.x + 1] = State{
                    .dist = state.dist + 1,
                    .direction = Direction.right,
                    .streak = if (state.direction == Direction.right or state.direction == Direction.any) state.streak + 1 else 1,
                };
            }
        }

        // up node
        // down node
    }

    const target_state = states_table[states_table.len - 1][states_table[0].len - 1];
    if (target_state) |result|
        std.debug.print("Shortest path to bottom left is: {d}\n", .{result.dist})
    else
        std.debug.print("Unfinished algorithm\n", .{});

    for (states_table) |d|
        allocator.free(d);
}
