const std = @import("std");

pub fn main() !void {
    var allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("test.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var list = std.ArrayList(*[]u8).init(allocator);
    var iter = std.mem.splitScalar(u8, buffer, '\n');
    var cur = iter.next();
    while (cur != null) : (cur = iter.next()) {
        var arr = try allocator.alloc(u8, cur.?.len);
        try list.append(&arr);
    }
}
