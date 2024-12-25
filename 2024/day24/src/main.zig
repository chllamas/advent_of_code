const std = @import("std");

const Operator = enum { AND, OR, XOR };

const Instruction = struct {
    r1: []const u8,
    r2: []const u8,
    op: Operator,
    r3: []const u8,
};

const allocator = std.heap.page_allocator;

// why a u46? because out input has max z45 so we use that hard coded oh well
fn part1(file_name: []const u8) !u46 {
    const _buffer = try readFile(file_name);
    const buffer = std.mem.trimRight(u8, _buffer, "\n");
    defer allocator.free(buffer);

    var memory = std.StringHashMap(u1).init(allocator);
    defer memory.deinit();

    var input_split = std.mem.splitSequence(u8, buffer, "\n\n");
    var initial_state_iter = std.mem.splitScalar(u8, input_split.next().?, '\n');
    while (initial_state_iter.next()) |state|
        try memory.putNoClobber(state[0..3], @intCast(state[state.len - 1] - '0'));

    var instructions = std.ArrayList(Instruction).init(allocator);
    var instructions_iter = std.mem.splitScalar(u8, input_split.next().?, '\n');
    while (instructions_iter.next()) |instr| {
        var instr_iter = std.mem.splitScalar(u8, instr, ' ');
        try instructions.append(.{
            .r1 = instr_iter.next().?,
            .op = switch (instr_iter.next().?[0]) {
                'A' => .AND,
                'X' => .XOR,
                'O' => .OR,
                else => unreachable,
            },
            .r2 = instr_iter.next().?,
            .r3 = temp: {
                _ = instr_iter.next().?;
                break :temp instr_iter.next().?;
            },
        });
    }

    while (instructions.popOrNull()) |instr| {
        const r1 = memory.get(instr.r1);
        const r2 = memory.get(instr.r2);
        if (r1 == null or r2 == null) {
            try instructions.append(instr);
            continue;
        }

        try memory.put(instr.r3, switch (instr.op) {
            .AND => r1.? & r2.?,
            .XOR => r1.? ^ r2.?,
            .OR => r1.? | r2.?,
        });
    }

    var result: u46 = 0;
    var i: u6 = 0;
    var z = formatZName(i);
    while (memory.get(z[0..])) |b| {
        if (b == 1)
            result |= @as(u46, 1) << i;
        i += 1;
        z = formatZName(i);
    }

    return result;
}

pub fn main() !void {
    std.debug.assert(try part1("test_small.txt"[0..]) == 4);
    std.debug.print("Example 1 passed\n", .{});
    std.debug.assert(try part1("test_large.txt"[0..]) == 2024);
    std.debug.print("Example 2 passed\n", .{});
    std.debug.print("Part 1 Result: {}\n", .{try part1("input.txt"[0..])});
}

fn formatZName(z: u8) [3]u8 {
    return [3]u8{ 'z', '0' + @divFloor(z, 10), '0' + @mod(z, 10) };
}

fn readFile(file_name: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);
    _ = try file.readAll(buffer);

    return buffer;
}
