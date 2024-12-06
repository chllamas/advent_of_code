const std = @import("std");

fn part1(allocator: std.mem.Allocator, buffer: []const u8) !void {
    var valid_updates = std.ArrayList([]u32).init(allocator);
    defer valid_updates.deinit();

    // The rules are for what must be in front of the key
    var rules = std.AutoHashMap(u32, []u32).init(allocator);
    defer rules.deinit();

    var chunks = std.mem.splitSequence(u8, buffer, "\n\n");
    var page_ordering_lines = std.mem.splitScalar(u8, chunks.next().?, '\n');
    var update_lines = std.mem.splitScalar(u8, chunks.next().?, '\n');

    while (page_ordering_lines.next()) |rule_str| {
        var iter = std.mem.splitScalar(u8, rule_str, '|');
        const k = try std.fmt.parseInt(u32, iter.next().?, 10);
        const v = try std.fmt.parseInt(u32, iter.next().?, 10);
        if (rules.get(k)) |a| {
            const arr = try allocator.alloc(u32, a.len + 1);
            std.mem.copyForwards(u32, arr, a);
            allocator.free(a);
            arr[arr.len - 1] = v;
            try rules.put(k, arr);
        } else {
            var arr = try allocator.alloc(u32, 1);
            arr[0] = v;
            try rules.put(k, arr);
        }
    }

    update_loop: while (update_lines.next()) |update_str| {
        var visited = std.ArrayList(u32).init(allocator);
        defer visited.deinit();

        if (update_str.len == 0) continue :update_loop;
        var iter = std.mem.splitScalar(u8, update_str, ',');
        while (iter.next()) |str| {
            const val = try std.fmt.parseInt(u32, str, 10);
            try visited.append(val);
            if (rules.get(val)) |my_rules| {
                for (visited.items) |past_page| {
                    for (my_rules) |r| {
                        if (past_page == r)
                            continue :update_loop;
                    }
                }
            }
        }
        try valid_updates.append(try visited.toOwnedSlice());
    }

    var sum: u32 = 0;
    for (valid_updates.items) |valid| {
        const index: usize = @divFloor(valid.len, 2);
        sum += valid[index];
    }
    std.debug.print("Result: {}\n", .{sum});
}

fn part2(allocator: std.mem.Allocator, buffer: []const u8) !void {
    var invalid_updates = std.ArrayList([]u32).init(allocator);
    defer invalid_updates.deinit();

    // The rules are for what must be in front of the key
    var rules = std.AutoHashMap(u32, []u32).init(allocator);
    defer rules.deinit();

    var chunks = std.mem.splitSequence(u8, buffer, "\n\n");
    var page_ordering_lines = std.mem.splitScalar(u8, chunks.next().?, '\n');
    var update_lines = std.mem.splitScalar(u8, chunks.next().?, '\n');

    while (page_ordering_lines.next()) |rule_str| {
        var iter = std.mem.splitScalar(u8, rule_str, '|');
        const k = try std.fmt.parseInt(u32, iter.next().?, 10);
        const v = try std.fmt.parseInt(u32, iter.next().?, 10);
        if (rules.get(k)) |a| {
            const arr = try allocator.alloc(u32, a.len + 1);
            std.mem.copyForwards(u32, arr, a);
            allocator.free(a);
            arr[arr.len - 1] = v;
            try rules.put(k, arr);
        } else {
            var arr = try allocator.alloc(u32, 1);
            arr[0] = v;
            try rules.put(k, arr);
        }
    }

    update_loop: while (update_lines.next()) |update_str| {
        var invalid = false;
        var visited = std.ArrayList(u32).init(allocator);
        defer visited.deinit();

        if (update_str.len == 0) continue :update_loop;
        var iter = std.mem.splitScalar(u8, update_str, ',');
        while (iter.next()) |str| {
            const val = try std.fmt.parseInt(u32, str, 10);
            try visited.append(val);
            if (!invalid) {
                if (rules.get(val)) |my_rules| {
                    for (visited.items) |past_page| {
                        for (my_rules) |r| {
                            if (past_page == r)
                                invalid = true;
                        }
                    }
                }
            }
        }

        if (invalid)
            try invalid_updates.append(try visited.toOwnedSlice());
    }

    // TODO: Fix the invalid arrays

    var sum: u32 = 0;
    for (invalid_updates.items) |valid| {
        const index: usize = @divFloor(valid.len, 2);
        sum += valid[index];
    }
    std.debug.print("Result: {}\n", .{sum});
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("test.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    // try part1(allocator, buffer);
    try part2(allocator, buffer);
}
