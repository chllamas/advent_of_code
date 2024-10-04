const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("test.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var i: usize = 1;
    var patterns = std.mem.splitSequence(u8, buffer, "\n\n");
    var pattern = patterns.next();
    while (pattern != null) : (pattern = patterns.next()) {
        std.debug.print("Pattern {d}:\n--\n{s}--\n", .{ i, pattern.? });
        i += 1;
    }
}
