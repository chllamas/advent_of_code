const std = @import("std");

fn part1(buffer: []const u8) !void {
    var sum: u32 = 0;
    var iter = std.mem.splitSequence(u8, buffer, "mul(");
    iter_loop: while (iter.next()) |str| {
        var first_num = true;
        var num_a: u32 = 0;
        var num_b: u32 = 0;
        for (str) |ch| {
            if (first_num) {
                if (ch >= '0' and ch <= '9') {
                    const val: u32 = @intCast(ch - '0');
                    num_a = num_a * 10 + val;
                } else if (ch == ',') {
                    first_num = false;
                } else {
                    continue :iter_loop;
                }
            } else {
                if (ch >= '0' and ch <= '9') {
                    const val: u32 = @intCast(ch - '0');
                    num_b = num_b * 10 + val;
                } else {
                    if (ch == ')')
                        sum += num_a * num_b;
                    continue :iter_loop;
                }
            }
        }
    }
    std.debug.print("Result: {}\n", .{sum});
}

fn part2(buffer: []const u8) !void {
    var sum: u64 = 0;
    var ignore = false;
    var dont_iter = std.mem.splitSequence(u8, buffer, "don't()");
    while (dont_iter.next()) |dont_section| {
        defer ignore = true;
        var do_iter = std.mem.splitSequence(u8, dont_section, "do()");
        while (do_iter.next()) |do_section| {
            defer ignore = false;
            var mul_iter = std.mem.splitSequence(u8, do_section, "mul(");
            iter_loop: while (mul_iter.next()) |str| {
                if (ignore) continue;

                var first_num = true;
                var num_a: u32 = 0;
                var num_b: u32 = 0;
                for (str) |ch| {
                    if (first_num) {
                        if (ch >= '0' and ch <= '9') {
                            const val: u32 = @intCast(ch - '0');
                            num_a = num_a * 10 + val;
                        } else if (ch == ',') {
                            first_num = false;
                        } else {
                            continue :iter_loop;
                        }
                    } else {
                        if (ch >= '0' and ch <= '9') {
                            const val: u32 = @intCast(ch - '0');
                            num_b = num_b * 10 + val;
                        } else {
                            if (ch == ')') {
                                std.debug.print("{} * {}\n", .{ num_a, num_b });
                                sum += num_a * num_b;
                            }
                            continue :iter_loop;
                        }
                    }
                }
            }
        }
    }
    std.debug.print("Result: {}\n", .{sum});
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    try part2(buffer);
}
