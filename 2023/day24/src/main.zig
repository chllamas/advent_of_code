const std = @import("std");

const CoordNum = f64;

const Coord = struct {
    x: CoordNum,
    y: CoordNum,
    // z: CoordNum,
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
        // .z = try std.fmt.parseInt(CoordNum, iter.next().?, 10),
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

    // NOTE: Not iterating to last one since last one doesn't match with any other after
    for (0..vectors.len - 1) |i| {
        const vec1 = vectors[i];

        for (vectors[i + 1 ..]) |vec2| {
            const p1 = vec1.position;
            const p2 = vec2.position;
            const d1 = vec1.direction;
            const d2 = vec2.direction;

            const a_matrix = [4]CoordNum{ d1.x, -d2.y, d1.y, -d2.x }; // 2x2 matrix
            const b_matrix = [2]CoordNum{ p2.x - p1.x, p2.y - p1.y }; // 1 x 2 matrix

            const determinant: CoordNum = (a_matrix[0] * a_matrix[2]) - (a_matrix[1] * a_matrix[3]);
            if (determinant == 0)
                continue;

            const a_inverse = [4]CoordNum{ a_matrix[0] / determinant, a_matrix[1] / determinant, a_matrix[2] / determinant, a_matrix[3] / determinant };

            // TODO: Check if they intersect within the thingy
            // Gaussian matrices
            // Matrix inversion just look at what was generated
        }
    }
}
