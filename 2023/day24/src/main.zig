const std = @import("std");

const CoordNum = f64;

const Coord = struct {
    x: CoordNum,
    y: CoordNum,
    z: CoordNum,
};

const Vector = struct {
    position: Coord,
    direction: Coord,
};

// assumes buffer is formatted as "%d, %d, %d"
fn parseCoord(buffer: []const u8) !Coord {
    var iter = std.mem.splitSequence(u8, buffer, ", ");
    return Coord{
        .x = try std.fmt.parseInt(CoordNum, iter.next().?, 10),
        .y = try std.fmt.parseInt(CoordNum, iter.next().?, 10),
        .z = try std.fmt.parseInt(CoordNum, iter.next().?, 10),
    };
}

// assumes buffer is formatted as "%d, %d, %d @ %d, %d, %d"
fn parseVector(buffer: []const u8) !Vector {
    var iter = std.mem.splitSequence(u8, buffer, " @ ");
    return Vector{
        .position = try parseCoord(iter.next().?),
        .direction = try parseCoord(iter.next().?),
    };
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("test.txt", .{});
    defer file.close();

    const buffer = try allocator.alloc(u8, try file.getEndPos());
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var vectors_list = std.ArrayList(Vector).init(allocator);

    var lines = std.mem.splitScalar(u8, buffer, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        try vectors_list.append(try parseVector(line));
    }

    const vectors = try vectors_list.toOwnedSlice();
}
