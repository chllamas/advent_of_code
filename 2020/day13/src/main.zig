const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var lines = std.mem.splitScalar(u8, buffer, '\n');
    const target = try std.fmt.parseInt(i32, lines.next().?, 10);
    var iter = std.mem.splitScalar(u8, lines.next().?, ',');
    var lowest_id: i32 = 0;
    var lowest: i32 = std.math.maxInt(i32);
    while (iter.next()) |str| {
        if (str[0] == 'x') continue;
        const id = try std.fmt.parseInt(i32, str, 10);
        const t: i32 = id - @mod(target, id);
        if (t < lowest) {
            lowest_id = id;
            lowest = t;
        }
    }

    std.debug.print("Result is: {}\n", .{lowest * lowest_id});
}
