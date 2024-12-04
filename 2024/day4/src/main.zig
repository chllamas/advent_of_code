const std = @import("std");
const xmas = "XMAS";

fn wordExistsLeft(puzzle: [][]const u8, x: usize, y: usize) u32 {
    var t: usize = x;
    for (1..4) |dx| {
        if (t == 0) return 0 else t -= 1;
        if (puzzle[y][t] != xmas[dx]) return 0;
    }
    return 1;
}

fn wordExistsRight(puzzle: [][]const u8, x: usize, y: usize) u32 {
    var t: usize = x;
    for (1..4) |dx| {
        if (t == puzzle[0].len - 1) return 0 else t += 1;
        if (puzzle[y][t] != xmas[dx]) return 0;
    }
    return 1;
}

fn wordExistsUp(puzzle: [][]const u8, x: usize, y: usize) u32 {
    var t: usize = y;
    for (1..4) |dy| {
        if (t == 0) return 0 else t -= 1;
        if (puzzle[t][x] != xmas[dy]) return 0;
    }
    return 1;
}

fn wordExistsDown(puzzle: [][]const u8, x: usize, y: usize) u32 {
    var t: usize = y;
    for (1..4) |dy| {
        if (t == puzzle.len - 1) return 0 else t += 1;
        if (puzzle[t][x] != xmas[dy]) return 0;
    }
    return 1;
}

fn wordExistsUpLeft(puzzle: [][]const u8, x: usize, y: usize) u32 {
    var m: usize = x;
    var n: usize = y;
    for (1..4) |diff| {
        if (m == 0 or n == 0) {
            return 0;
        } else {
            m -= 1;
            n -= 1;
        }
        if (puzzle[n][m] != xmas[diff]) return 0;
    }
    return 1;
}

fn wordExistsUpRight(puzzle: [][]const u8, x: usize, y: usize) u32 {
    var m: usize = x;
    var n: usize = y;
    for (1..4) |diff| {
        if (m == puzzle[0].len - 1 or n == 0) {
            return 0;
        } else {
            m += 1;
            n -= 1;
        }
        if (puzzle[n][m] != xmas[diff]) return 0;
    }
    return 1;
}

fn wordExistsDownLeft(puzzle: [][]const u8, x: usize, y: usize) u32 {
    var m: usize = x;
    var n: usize = y;
    for (1..4) |diff| {
        if (m == 0 or n == puzzle.len - 1) {
            return 0;
        } else {
            m -= 1;
            n += 1;
        }
        if (puzzle[n][m] != xmas[diff]) return 0;
    }
    return 1;
}

fn wordExistsDownRight(puzzle: [][]const u8, x: usize, y: usize) u32 {
    var m: usize = x;
    var n: usize = y;
    for (1..4) |diff| {
        if (m == puzzle[0].len - 1 or n == puzzle.len - 1) {
            return 0;
        } else {
            m += 1;
            n += 1;
        }
        if (puzzle[n][m] != xmas[diff]) return 0;
    }
    return 1;
}

fn part1(puzzle: [][]const u8) !void {
    var count: u32 = 0;
    for (0.., puzzle) |y, row| {
        for (0.., row) |x, ch| {
            if (ch == 'X') {
                // Disgusting little hard coder
                count +=
                    wordExistsLeft(puzzle, x, y) +
                    wordExistsRight(puzzle, x, y) +
                    wordExistsUp(puzzle, x, y) +
                    wordExistsDown(puzzle, x, y) +
                    wordExistsUpLeft(puzzle, x, y) +
                    wordExistsUpRight(puzzle, x, y) +
                    wordExistsDownLeft(puzzle, x, y) +
                    wordExistsDownRight(puzzle, x, y);
            }
        }
    }
    std.debug.print("Result: {}\n", .{count});
}

fn part2(puzzle: [][]const u8) !void {
    var count: u32 = 0;
    for (0.., puzzle) |y, row| {
        for (0.., row) |x, ch| {
            if (ch == 'A') {
                // NOTE: Wowza
                if (x >= 1 and y >= 1 and x <= row.len - 2 and y <= puzzle.len - 2 and ((puzzle[y - 1][x - 1] == 'M' and puzzle[y + 1][x + 1] == 'S') or (puzzle[y - 1][x - 1] == 'S' and puzzle[y + 1][x + 1] == 'M')) and ((puzzle[y - 1][x + 1] == 'M' and puzzle[y + 1][x - 1] == 'S') or (puzzle[y - 1][x + 1] == 'S' and puzzle[y + 1][x - 1] == 'M'))) {
                    count += 1;
                }
            }
        }
    }
    std.debug.print("Result: {}\n", .{count});
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("test.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var list = std.ArrayList([]const u8).init(allocator);
    var iter = std.mem.splitScalar(u8, buffer, '\n');
    while (iter.next()) |line| {
        if (line.len == 0) continue;
        try list.append(line);
    }

    const puzzle = try list.toOwnedSlice();
    defer allocator.free(puzzle);

    try part2(puzzle);
}
