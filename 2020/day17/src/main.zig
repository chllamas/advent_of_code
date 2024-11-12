const std = @import("std");

const test_input = [_][]const u8{
    ".#.",
    "..#",
    "###",
};

const real_input = [_][]const u8{
    ".##...#.",
    ".#.###..",
    "..##.#.#",
    "##...#.#",
    "#..#...#",
    "#..###..",
    ".##.####",
    "..#####.",
};

const Coord = struct {
    x: i32,
    y: i32,
    z: i32,

    fn eq(self: Coord, other: Coord) bool {
        return self.x == other.x and self.y == other.y and self.z == self.z;
    }

    fn neighbors(self: Coord, other: Coord) bool {
        return @abs(self.x - other.x) <= 1 and @abs(self.y - other.y) <= 1 and @abs(self.z - other.z) <= 1;
    }

    fn remainsActive(self: Coord, active_cubes: *std.ArrayList(Coord)) bool {
        var count: u2 = 0;
        for (active_cubes.items) |t| {
            if (self.neighbors(t)) {
                if (count == 3) return false;
                count += 1;
            }
        }
        return count >= 2;
    }

    fn becomesActive(self: Coord, active_cubes: *std.ArrayList(Coord)) bool {
        var count: u2 = 0;
        for (active_cubes.items) |t| {
            if (self.neighbors(t)) {
                if (count == 3) return false;
                count += 1;
            }
        }
        return count == 3;
    }

    fn hash(self: Coord) u64 {
        const x: u32 = @bitCast(self.x);
        const xu: u96 = @intCast(x);
        return xu;
    }
};

pub fn main() !void {
    const input = test_input[0..];
    const allocator = std.heap.page_allocator;

    var active_cubes = std.ArrayList(Coord).init(allocator);
    defer active_cubes.deinit();

    for (0.., input) |y, row| {
        for (0.., row) |x, ch| {
            if (ch == '#') {
                try active_cubes.append(.{
                    .x = x,
                    .y = y,
                    .z = 0,
                });
            }
        }
    }

    for (0..6) |_| {
        var buffer = std.ArrayList(Coord).init(allocator);

        for (active_cubes.items) |active_cube| {
            if (active_cube.remainsActive(&active_cubes))
                try buffer.append(active_cube);

            for (-1..2) |dz| {
                for (-1..2) |dy| {
                    for (-1..2) |dx| {
                        if (dx == 0 and dy == 0 and dz == 0) continue;
                        // TODO:
                        // verify is inactive cube
                        // check if can become active
                    }
                }
            }
        }

        active_cubes.deinit();
        active_cubes = buffer;
    }

    std.debug.print("Cubes left: {}\n", .{active_cubes.items.len});
}

fn addUnique(lst: *std.ArrayList(Coord), coord: Coord) !void {
    for (lst.*.items) |t| {
        if (coord.eq(t)) return;
    }
    try lst.*.append(coord);
}
