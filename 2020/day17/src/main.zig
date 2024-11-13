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
        const y: u32 = @bitCast(self.y);
        const z: u32 = @bitCast(self.z);
        return @as(u96, x) ^ (@as(u96, y) << 32) ^ (@as(u96, z) << 64);
    }

    fn add(self: Coord, other: Coord) Coord {
        return .{
            self.x + other.x,
            self.y + other.y,
            self.z + other.z,
        };
    }
};

pub fn main() !void {
    const input = test_input[0..];
    const allocator = std.heap.page_allocator;

    var actives_cubes_hashmap = std.AutoHashMap(u96, Coord).init(allocator);
    defer actives_cubes_hashmap.deinit();

    for (0.., input) |y, row| {
        for (0.., row) |x, ch| {
            if (ch == '#') {
                const coord = Coord{
                    .x = x,
                    .y = y,
                    .z = 0,
                };
                try actives_cubes_hashmap.putNoClobber(coord.hash(), coord);
            }
        }
    }

    for (0..6) |_| {
        var buf = std.AutoHashMap(u96, Coord).init(allocator);

        var active_iter = actives_cubes_hashmap.valueIterator();
        while (active_iter.next()) |cube| {
            if (cube.*.remainsActive(cube))
                try buf.put(cube.*.hash(), cube.*);

            for (-1..2) |dz| {
                for (-1..2) |dy| {
                    inactive_loop: for (-1..2) |dx| {
                        if (dx == 0 and dy == 0 and dz == 0) continue;
                        const neighbor = cube.*.add(.{
                            .x = @intCast(dx),
                            .y = @intCast(dy),
                            .z = @intCast(dz),
                        });

                        if (!actives_cubes_hashmap.contains(neighbor.hash())) {
                            // TODO:
                            // check if can become active
                        }
                    }
                }
            }
        }

        actives_cubes_hashmap.deinit();
        actives_cubes_hashmap = buf;
    }

    std.debug.print("Cubes left: {}\n", .{active_cubes.items.len});
}

fn addUnique(lst: *std.ArrayList(Coord), coord: Coord) !void {
    for (lst.*.items) |t| {
        if (coord.eq(t)) return;
    }
    try lst.*.append(coord);
}
