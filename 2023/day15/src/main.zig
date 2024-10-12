const std = @import("std");

const Operation = struct {
    key: []const u8,
    focus: u64,
};

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

fn find_index(arr: std.ArrayList(Operation), key: []const u8) ?usize {
    for (0.., arr.items) |i, t|
        if (std.mem.eql(u8, key, t.key))
            return i;

    return null;
}

fn calc(box_index: u64, slot_number: u64, focal_length: u64) u64 {
    return (1 + box_index) * (1 + slot_number) * focal_length;
}

fn part1(buffer: []const u8) void {
    var res: u64 = 0;
    const sequence = std.mem.trimRight(u8, buffer, "\n");
    var iter = std.mem.splitScalar(u8, sequence, ',');
    while (iter.next()) |cur| {
        res += hash(cur);
    }

    std.debug.print("Summations is: {d}\n", .{res});
}

fn part2(allocator: std.mem.Allocator, buffer: []const u8) !void {
    const map = try allocator.alloc(std.ArrayList(Operation), 256);
    for (0.., map) |i, _|
        map[i] = std.ArrayList(Operation).init(allocator);

    const sequence = std.mem.trimRight(u8, buffer, "\n");
    var iter = std.mem.splitScalar(u8, sequence, ',');
    while (iter.next()) |op| {
        if (op[op.len - 1] == '-') {
            const key = op[0 .. op.len - 1];
            const box_num = hash(key);
            if (find_index(map[box_num], key)) |slot|
                _ = map[box_num].orderedRemove(slot);
        } else {
            var opIter = std.mem.splitScalar(u8, op, '=');
            const key = opIter.next().?;
            const focus: u64 = try std.fmt.parseInt(u64, opIter.next().?, 10);
            const box_num = hash(key);
            if (find_index(map[box_num], key)) |slot|
                map[box_num].items[slot].focus = focus
            else
                try map[box_num].append(.{ .key = key, .focus = focus });
        }
    }

    var res: u64 = 0;
    for (0.., map) |box_num, box| {
        for (0.., box.items) |slot, t| {
            res += calc(@intCast(box_num), @intCast(slot), t.focus);
        }
    }
    std.debug.print("Total power is: {d}\n", .{res});

    for (0.., map) |i, _|
        map[i].deinit();
    allocator.free(map);
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    try part2(allocator, buffer);
}
