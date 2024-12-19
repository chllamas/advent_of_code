const std = @import("std");

const file_input = "input.txt";
const Trial = struct {
    str: []u8,
    idx: usize,

    fn canFit(self: Trial, patterns: []const []const u8, expr: []const u8) ?Trial {
        for (patterns) |pattern| {
            if (expr.len - self.idx >= pattern.len and std.mem.eql(u8, expr[self.idx .. self.idx + pattern.len], pattern)) {
                std.mem.copyForwards(u8, self.str[self.idx..], pattern);
                return .{ .str = self.str, .idx = self.idx + pattern.len };
            }
        }
        return null;
    }
};

fn isPossible(trials: *std.ArrayList(Trial), patterns: []const []const u8, expr: []const u8) !bool {
    defer trials.clearAndFree();
    while (trials.popOrNull()) |trial| {
        if (trial.idx == trial.str.len) return true;
        if (trial.canFit(patterns, expr)) |t| try trials.append(t);
    }
    return false;
}

fn part1(allocator: std.mem.Allocator, buffer: []const u8) !void {
    var list = std.ArrayList(Trial).init(allocator);
    defer list.deinit();

    var iter = std.mem.splitSequence(u8, buffer, "\n\n");

    var patterns_list = std.ArrayList([]const u8).init(allocator);
    var patterns_iter = std.mem.splitSequence(u8, iter.next().?, ", ");
    while (patterns_iter.next()) |pat| try patterns_list.append(pat);
    const patterns = try patterns_list.toOwnedSlice();

    var count: u32 = 0;
    var lines = std.mem.splitScalar(u8, iter.next().?, '\n');
    while (lines.next()) |expr| {
        for (patterns) |pattern| {
            if (expr.len >= pattern.len and std.mem.eql(u8, expr[0..pattern.len], pattern)) {
                const str = try allocator.alloc(u8, expr.len);
                std.mem.copyForwards(u8, str, pattern);
                try list.append(.{ .str = str, .idx = pattern.len });
            }
        }

        if (try isPossible(&list, patterns, expr))
            count += 1;
    }
    std.debug.print("Result: {}\n", .{count});
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile(file_input[0..], .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    try part1(allocator, std.mem.trimRight(u8, buffer, "\n"));
    // try part2(allocator, std.mem.trimRight(u8, buffer, "\n"));
}
