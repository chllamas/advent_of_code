const std = @import("std");

const FlipFlopT = enum { sender, inverter };
const FlipFlop = union(FlipFlopT) {
    sender: [][]const u8,
    inverter: [][]const u8,
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("test1.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    const bc = "broadcast";
    var flip_flops = std.StringHashMap(FlipFlop).init(allocator);
    defer flip_flops.deinit();

    var lines = std.mem.splitScalar(u8, buffer, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) break;
        var iter = std.mem.splitSequence(u8, line, " -> ");
        const name = iter.next().?;
        var nodes = std.mem.splitSequence(u8, iter.next().?, ", ");
        var arr = std.ArrayList([]const u8).init(allocator);
        while (nodes.next()) |node| {
            try arr.append(node);
        }
        switch (name[0]) {
            '%' => try flip_flops.putNoClobber(name[1..], .{ .sender = try arr.toOwnedSlice() }),
            '&' => try flip_flops.putNoClobber(name[1..], .{ .inverter = try arr.toOwnedSlice() }),
            else => try flip_flops.putNoClobber(bc[0..], .{ .sender = try arr.toOwnedSlice() }),
        }
    }

    // free the arrays that are the values of the hashmap of "flip_flops"
}
