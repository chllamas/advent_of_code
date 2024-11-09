const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var memory = std.AutoHashMap(usize, u36).init(allocator);
    defer memory.deinit();

    var mask: u36 = std.math.maxInt(u36);

    var lines = std.mem.splitScalar(u8, buffer, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) break;

        if (std.mem.startsWith(u8, line, "mem")) {
            var iter = std.mem.splitSequence(u8, line, "] = ");
            const idx = try std.fmt.parseInt(usize, iter.next().?[4..], 10);
            const preprocessed_val = try std.fmt.parseInt(u36, iter.next().?, 10);

            try memory.put(idx, preprocessed_val & mask);
        } else {
            const new_mask = line[7..];
        }
    }

    var sum: u64 = 0;
    var vals = memory.valueIterator();
    while (vals.next()) |val| {
        sum += val.*;
    }

    std.debug.print("Result: {}\n", .{sum});
}
