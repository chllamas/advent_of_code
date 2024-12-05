const std = @import("std");

fn part1(allocator: std.mem.Allocator, buffer: []const u8) !void {
    // The rules are for what must be in front of the key
    var rules = std.AutoHashMap(u32, []u32).init(allocator);
    defer rules.deinit();

    var chunks = std.mem.splitSequence(u8, buffer, "\n\n");
    var page_ordering_lines = std.mem.splitScalar(u8, chunks.next().?, '\n');
    // var update_lines = std.mem.splitScalar(u8, chunks.next().?, '\n');

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

    var iter = rules.iterator();
    while (iter.next()) |entry| {
        std.debug.print("{} must be before: ", .{entry.key_ptr.*});
        for (entry.value_ptr.*) |val| {
            std.debug.print("{}, ", .{val});
        }
        std.debug.print("\n", .{});
    }
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("test.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    try part1(allocator, buffer);
}
