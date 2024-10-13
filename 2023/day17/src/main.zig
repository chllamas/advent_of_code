const std = @import("std");

const Coord = struct { x: usize, y: usize };

const Node = struct {
    last: ?Coord,
    pos: Coord,
    streak: u8,
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var array = std.ArrayList([]const u8).init(allocator);
    defer array.deinit();

    var iter = std.mem.splitScalar(u8, buffer, '\n');
    while (iter.next()) |line| {
        if (line.len > 0)
            try array.append(line);
    }

    const map = try array.toOwnedSlice();
    const queue = std.DoublyLinkedList(Node){};
}
