const std = @import("std");

const mask_offset: usize = 7;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("test.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    // TODO: Update my const to val
    const mask: u36 = std.math.maxInt(u36);
    var memory = std.AutoHashMap(usize, u36).init(allocator);
    defer memory.deinit();

    var lines = std.mem.splitScalar(u8, buffer, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) break;
        if (std.mem.startsWith(u8, line, "mem[")) {
            var iter = std.mem.splitSequence(u8, line, "] = ");
            const index = try std.fmt.parseInt(usize, iter.next().?[4..], 10);
            const preprocessed_val = try std.fmt.parseInt(u36, iter.next().?, 10);
            try memory.put(index, preprocessed_val & mask);
        } else {
            // TODO: update our mask
        }
    }

    var sum: u64 = 0;
    var iter = memory.valueIterator();
    while (iter.next()) |val| {
        sum += val.?;
    }

    std.debug.print("Result: {}\n", .{sum});
}
