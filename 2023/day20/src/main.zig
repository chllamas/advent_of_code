const std = @import("std");

const FF = [2]u8;
const FlipFlopT = enum { sender, inverter, broadcaster };
const FlipFlop = union(FlipFlopT) {
    sender: []FF,
    inverter: []FF,
    broadcaster: []FF,
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("test1.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var flip_flops = std.StringHashMap(FlipFlop).init(allocator);
    defer flip_flops.deinit();

    var lines = std.mem.splitScalar(u8, buffer, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) break;
        switch (line[0]) {
            '%' => {},
            '&' => {},
            else => {
                const broadcaster = line[15..];
                // split these and then grab their names to place on a flip flop
            },
        }
    }
}
