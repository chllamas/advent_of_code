const std = @import("std");

const Matrix2x1 = struct {
    x: f64,
    y: f64,
};

const Matrix2x2 = struct {
    a: f64,
    b: f64,
    c: f64,
    d: f64,

    fn inv(self: Matrix2x2) ?Matrix2x2 {
        const d = self.det();

        return if (d == 0)
            null
        else
            .{
                .a = self.d / d,
                .b = (-self.b) / d,
                .c = (-self.c) / d,
                .d = self.a / d,
            };
    }

    fn det(self: Matrix2x2) f64 {
        return (self.a * self.d) - (self.b * self.c);
    }

    fn mult(self: Matrix2x2, other: Matrix2x1) Matrix2x1 {
        return .{
            .x = (self.a * other.x) + (self.b * other.y),
            .y = (self.c * other.x) + (self.d * other.y),
        };
    }
};

const Coord = struct {
    x: f64,
    y: f64,
    // z: f64,
};

const Vector = struct {
    position: Coord,
    direction: Coord,
};

// assumes buffer is formatted as "%d, %d, %d"
fn parseCoord(buffer: []const u8) !Coord {
    var iter = std.mem.splitSequence(u8, buffer, ", ");
    const x = std.mem.trim(u8, iter.next().?, " ");
    const y = std.mem.trim(u8, iter.next().?, " ");
    return Coord{
        .x = try std.fmt.parseFloat(f64, x),
        .y = try std.fmt.parseFloat(f64, y),
        // .z = try std.fmt.parseInt(f64, iter.next().?, 10),
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

    // answer is between 12k and 18k
    const file = try std.fs.cwd().openFile("input.txt", .{});
    const min_max = Coord{ .x = 200000000000000, .y = 400000000000000 }; // NOTE: change for test or input
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
    var count: u64 = 0;

    // NOTE: Not iterating to last one since last one doesn't match with any other after
    for (0..vectors.len - 1) |i| {
        const vec1 = vectors[i];

        for (vectors[i + 1 ..]) |vec2| {
            const p1 = vec1.position;
            const p2 = vec2.position;
            const d1 = vec1.direction;
            const d2 = vec2.direction;

            const a_inverse =
                (Matrix2x2{ .a = d1.x, .b = (-d2.x), .c = d1.y, .d = (-d2.y) })
                .inv();

            if (a_inverse == null) continue;

            const t_s = a_inverse.?
                .mult(.{ .x = p2.x - p1.x, .y = p2.y - p2.x });

            if (t_s.x < 0 or t_s.y < 0) continue;

            const intersection = Matrix2x1{ .x = p1.x + (d1.x * t_s.x), .y = p1.y + (d1.y * t_s.x) };

            if (intersection.x >= min_max.x and intersection.x <= min_max.y and intersection.y >= min_max.x and intersection.y <= min_max.y)
                count += 1;
        }
    }

    std.debug.print("Final count: {}\n", .{count});
}
