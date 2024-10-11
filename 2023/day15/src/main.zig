const std = @import("std");

fn hash(str: []const u8) u64 {
    var res: u64 = 0;
    for (str) |ch| {
        const incr: u64 = @intCast(ch);
        res += incr;
        res *= 17;
        res %= 256;
    }
    return res;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var res: u64 = 0;
    const sequence = std.mem.trimRight(u8, buffer, "\n");
    var iter = std.mem.splitScalar(u8, sequence, ',');
    while (iter.next()) |cur| {
        res += hash(cur);
    }

    std.debug.print("Summations is: {d}\n", .{res});
}
