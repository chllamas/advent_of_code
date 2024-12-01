const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var num_count = std.AutoHashMap(u64, u64).init(allocator);
    defer num_count.deinit();

    var list = std.ArrayList(u64).init(allocator);

    var lines = std.mem.splitScalar(u8, buffer, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var iter = std.mem.splitSequence(u8, line, "   ");
        const left_num = try std.fmt.parseInt(u64, iter.next().?, 10);
        const right_num = try std.fmt.parseInt(u64, iter.next().?, 10);

        try list.append(left_num);

        if (num_count.get(right_num)) |count| {
            try num_count.put(right_num, count + 1);
        } else {
            try num_count.put(right_num, 1);
        }
    }

    var sum: u64 = 0;
    for (list.items) |t| {
        if (num_count.get(t)) |count| {
            sum += t * count;
        }
    }

    std.debug.print("Result: {}\n", .{sum});
}
