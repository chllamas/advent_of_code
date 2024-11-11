const std = @import("std");

// a -> b | c -> d (inclusive)
const Range = struct {
    a: u64,
    b: u64,
    c: u64,
    d: u64,
};

fn parseRanges(ranges: *std.StringHashMap(Range), buffer: []const u8) !void {
    var lines = std.mem.splitScalar(u8, buffer, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) break;
        var iter = std.mem.splitSequence(u8, line, ": ");
        const name = iter.next().?;
        var rangesIter = std.mem.splitSequence(u8, iter.next().?, " or ");
        var r1 = std.mem.splitScalar(u8, rangesIter.next().?, '-');
        var r2 = std.mem.splitScalar(u8, rangesIter.next().?, '-');
        try ranges.*.putNoClobber(name, .{
            .a = try std.fmt.parseInt(u64, r1.next().?, 10),
            .b = try std.fmt.parseInt(u64, r1.next().?, 10),
            .c = try std.fmt.parseInt(u64, r2.next().?, 10),
            .d = try std.fmt.parseInt(u64, r2.next().?, 10),
        });
    }
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("test.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var blocks = std.mem.splitSequence(u8, buffer, "\n\n");

    var ranges = std.StringHashMap(Range).init(allocator);
    try parseRanges(&ranges, blocks.next().?);
    defer ranges.deinit();

    // TODO: Include my ticket now
    _ = blocks.next().?; // ignore the your ticket for now

    // TODO: error_rate not needed anymore
    var error_rate: u64 = 0;

    var nearby_tickets = std.mem.splitScalar(u8, blocks.next().?, '\n');
    _ = nearby_tickets.next(); // ignore "nearby tickets:" line
    while (nearby_tickets.next()) |ticket| {
        if (ticket.len == 0) continue;
        var nums = std.mem.splitScalar(u8, ticket, ',');
        nums_loop: while (nums.next()) |x_str| {
            const x = try std.fmt.parseInt(u64, x_str, 10);
            for (ranges.items) |*range| {
                if ((x >= range.*.a and x <= range.*.b) or (x >= range.*.c and x <= range.*.d)) {
                    continue :nums_loop;
                }
            }
            error_rate += x;
        }
    }

    std.debug.print("Error rate: {}\n", .{error_rate});
}
