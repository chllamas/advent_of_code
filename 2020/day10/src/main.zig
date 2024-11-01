const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("test.txt", .{});
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
    // var one: u32 = 0;
    // var two: u32 = 0;
    // var three: u32 = 1;
    var divergences: u32 = 0;

    for (0.., adapters) |i, x| {
        var count: u32 = 0;

        if (x - st <= 3)
            count += 1;

        if (i < adapters.len - 1 and adapters[i + 1] - st <= 3)
            count += 1;

        if (i < adapters.len - 2 and adapters[i + 2] - st <= 3)
            count += 1;

        divergences += count - 1;

        st = x;
    }

    std.debug.print("result: {d}\n", .{divergences});
}
