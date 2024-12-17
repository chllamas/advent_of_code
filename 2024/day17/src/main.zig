const std = @import("std");

const Registers = struct {
    a: u32,
    b: u32 = 0,
    c: u32 = 0,
    i: usize = 0,

    fn literal(self: Registers, combo: u3) u32 {
        return switch (combo) {
            0, 1, 2, 3 => @intCast(combo),
            4 => self.a,
            5 => self.b,
            6 => self.c,
            else => unreachable,
        };
    }

    fn next(self: *Registers) void {
        self.i += 2;
    }

    fn dv(self: *Registers, combo: u3) u32 {
        return @divTrunc(self.a, std.math.pow(u32, 2, self.literal(combo)));
    }

    fn adv(self: *Registers, combo: u3) void {
        self.a = self.dv(combo);
        self.next();
    }

    fn bdv(self: *Registers, combo: u3) void {
        self.b = self.dv(combo);
        self.next();
    }

    fn cdv(self: *Registers, combo: u3) void {
        self.c = self.dv(combo);
        self.next();
    }

    fn bxl(self: *Registers, combo: u3) void {
        self.b ^= self.literal(combo);
        self.next();
    }

    fn bst(self: *Registers, combo: u3) void {
        self.b = @mod(self.literal(combo), 8);
        self.next();
    }

    fn jnz(self: *Registers, combo: u3) void {
        if (self.a != 0 and self.literal(combo) != 3) {
            self.i = @intCast(self.literal(combo));
        } else {
            self.next();
        }
    }

    fn bxc(self: *Registers) void {
        self.b ^= self.c;
        self.next();
    }

    fn out(self: *Registers, combo: u3) void {
        std.debug.print("{},", .{@mod(self.literal(combo), 8)});
        self.next();
    }
};

fn solve(_registers: Registers, program: []const u3) void {
    var registers = _registers;
    while (registers.i < program.len) {
        const i = registers.i;
        switch (program[i]) {
            0 => registers.adv(program[i + 1]),
            1 => registers.bxl(program[i + 1]),
            2 => registers.bst(program[i + 1]),
            3 => registers.jnz(program[i + 1]),
            4 => registers.bxc(),
            5 => registers.out(program[i + 1]),
            6 => registers.bdv(program[i + 1]),
            7 => registers.cdv(program[i + 1]),
        }
    }
    std.debug.print("\n", .{});
}

pub fn main() !void {
    const t = [_]u3{ 2, 4, 1, 3, 7, 5, 1, 5, 0, 3, 4, 3, 5, 5, 3, 0 };
    solve(.{ .a = 47006051 }, t[0..]);
}
