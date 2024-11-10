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

    var mask: []const u8 = undefined;
    var num_floating_bits: usize = 0;

    var mask_buffer = try allocator.alloc(u8, 36);
    defer allocator.free(mask_buffer);

    var memory = std.AutoHashMap(usize, u36).init(allocator);
    defer memory.deinit();

    var lines = std.mem.splitScalar(u8, buffer, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) break;
        if (std.mem.startsWith(u8, line, "mem[")) {
            var iter = std.mem.splitSequence(u8, line, "] = ");
            const index = try std.fmt.parseInt(usize, iter.next().?[4..], 10);
            var val = try std.fmt.parseInt(u36, iter.next().?, 10);

            // apply all masks to index and push the val to all indices
            for (0..std.math.pow(usize, 2, num_floating_bits)) |_mapping| {
                var mapping = _mapping;
                std.mem.copyForwards(u8, mask_buffer[0..], mask[0..36]);
                var i: usize = 0;
                for (0..num_floating_bits) |_| {
                    while (mask_buffer[i] != 'x') : (i += 1) {}
                    mask_buffer = mapping & 1;
                    mapping >>= 1;
                }
            }

            var i: usize = 35;
            while (true) : (i -= 1) {
                const shift_len: u6 = @intCast(35 - i);
                switch (mask[i]) {
                    '1' => val |= @as(u36, 1) << shift_len,
                    '0' => val &= ~(@as(u36, 1) << shift_len),
                    else => {},
                }

                if (i == 0) break;
            }

            try memory.put(index, val);
        } else {
            mask = line[7..];
            num_floating_bits = 0;
            for (mask) |ch| {
                if (ch == 'x') num_floating_bits += 1;
            }
        }
    }

    var sum: u64 = 0;
    var iter = memory.valueIterator();
    while (iter.next()) |val| {
        sum += val.*;
    }

    std.debug.print("Result: {}\n", .{sum});
}
