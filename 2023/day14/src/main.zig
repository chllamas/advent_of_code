const std = @import("std");

fn shift_north(graph: [][]u8) void {
    for (0.., graph) |y, row| {
        for (0.., row) |x, ch| {
            if (ch == 'O') {
                var height = y;
                while (height > 0 and graph[height - 1][x] == '.') : (height -= 1) {}
                if (height != y) {
                    graph[height][x] = 'O';
                    graph[y][x] = '.';
                }
            }
        }
    }
}

fn shift_south(graph: [][]u8) void {
    var y: i64 = @intCast(graph.len);
    y -= 1;
    while (y >= 0) : (y -= 1) {
        for (0.., graph[@intCast(y)]) |x, ch| {
            if (ch == 'O') {
                var height: usize = @intCast(y);
                while (height < graph.len - 1 and graph[height + 1][x] == '.') : (height += 1) {}
                if (height != y) {
                    graph[height][x] = 'O';
                    graph[@intCast(y)][x] = '.';
                }
            }
        }
    }
}

fn shift_west(graph: [][]u8) void {
    for (0.., graph) |y, row| {
        for (0.., row) |x, ch| {
            if (ch == 'O') {
                var depth = x;
                while (depth > 0 and graph[y][depth - 1] == '.') : (depth -= 1) {}
                if (depth != x) {
                    graph[y][depth] = 'O';
                    graph[y][x] = '.';
                }
            }
        }
    }
}

fn shift_east(graph: [][]u8) void {
    for (0.., graph) |y, row| {
        var x: i64 = @intCast(row.len);
        x -= 1;
        while (x >= 0) : (x -= 1) {
            if (graph[y][@intCast(x)] == 'O') {
                var depth: usize = @intCast(x);
                while (depth < row.len - 1 and graph[y][depth + 1] == '.') : (depth += 1) {}
                if (depth != x) {
                    graph[y][depth] = 'O';
                    graph[y][@intCast(x)] = '.';
                }
            }
        }
    }
}

fn do_cycle(graph: [][]u8) void {
    shift_north(graph);
    shift_west(graph);
    shift_south(graph);
    shift_east(graph);
}

fn print_graph(graph: []const []const u8) void {
    for (graph) |row| {
        std.debug.print("{s}\n", .{row});
    }
}

fn calc_graph(graph: []const []const u8) usize {
    var result: usize = 0;

    for (0.., graph) |y, row| {
        for (row) |ch| {
            if (ch == 'O') {
                result += graph.len - y;
            }
        }
    }

    return result;
}

fn find_cycle(allocator: std.mem.Allocator, graph: [][]u8) !u64 {
    var seen_states = std.StringHashMap(u64).init(allocator);
    defer seen_states.deinit();

    const max_cycles: u64 = 1_000_000_000;
    var cycle: u64 = 0;
    while (cycle < max_cycles) : (cycle += 1) {
        const serialized_graph = try std.mem.join(allocator, "", graph);
        const k = seen_states.get(serialized_graph);
        if (k != null) {
            return cycle - k.?;
        }

        try seen_states.put(serialized_graph, cycle);

        do_cycle(graph);
    }

    return 0;
}

pub fn main() !void {
    var allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("test.txt", .{});
    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);
    file.close();

    var list = std.ArrayList([]u8).init(allocator);
    var iter = std.mem.splitScalar(u8, buffer, '\n');
    while (iter.next()) |cur| {
        if (cur.len > 0) {
            const arr = try allocator.dupe(u8, cur);
            try list.append(arr);
        }
    }

    const graph = try list.toOwnedSlice();
    defer allocator.free(graph);
    list.deinit();

    const temp = try allocator.alloc([]u8, graph.len);
    for (0.., graph) |i, arr| {
        temp[i] = try allocator.dupe(u8, arr);
    }

    const cycle = try find_cycle(allocator, temp);
    for (temp) |arr| {
        allocator.free(arr);
    }
    allocator.free(temp);

    const modulus: u64 = 1_000_000_000 % cycle;

    for (0..modulus) |_| {
        do_cycle(graph);
    }

    std.debug.print("Cycle length: {d}\nOnly have to run {d} times ...\nResulting weight: {d}\n", .{ cycle, modulus, calc_graph(graph) });
}
