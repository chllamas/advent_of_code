const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var lst = std.ArrayList(u32).init(allocator);

    var lines = std.mem.splitScalar(u8, buffer, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) break;
        const t = try std.fmt.parseInt(u32, line, 10);
        try lst.append(t);
    }

    var adapters = try lst.toOwnedSlice();
    defer allocator.free(adapters);

    std.mem.sort(u32, adapters[0..], {}, comptime std.sort.asc(u32));

    var st: u32 = 0;
    var one: u32 = 0;
    var two: u32 = 0;
    var three: u32 = 1;

    for (adapters) |x| {
        const diff: u32 = x - st;
        st = x;
        switch (diff) {
            1 => one += 1,
            2 => two += 1,
            3 => three += 1,
            else => @panic("Idk"),
        }
    }

    std.debug.print("one: {d}\ntwo: {d}\nthree: {d}\n", .{ one, two, three });
}
