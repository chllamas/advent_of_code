const std = @import("std");
const allocator = std.heap.page_allocator;

// returns a count
fn part1(file_name: []const u8) !u32 {
    const _buffer = try readFile(file_name);
    const buffer = std.mem.trimRight(u8, _buffer, "\n");
    defer allocator.free(buffer);

    // NOTE: Remember to free the arraylists later
    var graph = std.ArrayHashMap(u16, []const u16).init(allocator);
    var connections = std.mem.splitScalar(u8, buffer, '\n');
    defer graph.deinit();
    while (connections.next()) |conn| {}

    return 0;
}

test "example_part1" {
    std.debug.assert(try part1("test.txt"[0..]) == 7);
}

test "part1" {
    std.debug.print("Part 1 Result: {}\n", .{try part1("input.txt"[0..])});
}

fn append(arr: []const u16, val: u16) ![]const u16 {
    const new_arr = try allocator.alloc(u16, arr.len + 1);
    std.mem.copyForwards(u16, new_arr, arr);
    new_arr[arr.len] = val;
    allocator.free(arr);
    return new_arr;
}

fn encodeComputer(computer: [2]u8) u16 {
    const a: u16 = @intCast(computer[0]);
    const b: u16 = @intCast(computer[1]);
    return (a << 8) & b;
}

fn readFile(file_name: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);
    _ = try file.readAll(buffer);

    return buffer;
}
