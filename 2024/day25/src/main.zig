const std = @import("std");

const allocator = std.heap.page_allocator;

fn part1(file_name: []const u8) !u32 {
    const _buffer = try readFile(file_name);
    const buffer = std.mem.trimRight(u8, _buffer, "\n");
    defer allocator.free(_buffer);

    var keys = std.ArrayList([5]u4).init(allocator);
    defer keys.deinit();

    var locks = std.ArrayList([5]u4).init(allocator);
    defer locks.deinit();

    var chunks = std.mem.splitSequence(u8, buffer, "\n\n");
    while (chunks.next()) |chunk| {
        var arr = [5]u4{ 0, 0, 0, 0, 0 };
        var iter = std.mem.splitScalar(u8, chunk, '\n');
        _ = iter.next();
        for (0..5) |_| {
            const map = iter.next().?;
            for (0.., arr[0..]) |i, *t|
                t.* += if (map[i] == '#') 1 else 0;
        }
        if (chunk[0] == '#')
            try locks.append(arr)
        else
            try keys.append(arr);
    }

    var result: u32 = 0;
    for (locks.items[0..]) |lock| {
        key_loop: for (keys.items[0..]) |key| {
            for (0..5) |i| if (lock[i] + key[i] > 5)
                continue :key_loop;
            result += 1;
        }
    }

    return result;
}

pub fn main() !void {
    std.debug.assert(try part1("test.txt"[0..]) == 3);
    std.debug.print("Example passed\n", .{});
    std.debug.print("Part 1 Result: {}\n", .{try part1("input.txt"[0..])});
}

fn readFile(file_name: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);
    _ = try file.readAll(buffer);

    return buffer;
}
