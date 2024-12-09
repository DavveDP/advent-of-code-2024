const std = @import("std");
const expect = std.testing.expect;
const INPUT_SIZE = 140;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();


    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const stdin_file = std.io.getStdIn().reader();
    var br = std.io.bufferedReader(stdin_file);
    const stdin = br.reader();

    var m: [INPUT_SIZE][]u8 = undefined;
    var i: u8 = 0; while(i < INPUT_SIZE) {
        m[i] = try stdin.readUntilDelimiterAlloc(allocator, '\n', 150);
        i+=1;
    }

    const count = xMasSquareCount(m[0..]);

    try stdout.print("Count: {d}\n", .{count});

    try bw.flush(); // don't forget to flush!
}

pub fn xMasSquareCount(m: []const []const u8) u64 {
    var count: u64 = 0;
    for(m[0..m.len - 2], 0..) |_, i| {
        for(m[0..m.len - 2], 0..) |_, j| {
            if (isXmasSquare([_][3]u8 {
                m[i][j..][0..3].*,
                m[i+1][j..][0..3].*,
                m[i+2][j..][0..3].*,
                })) {
                count+=1;
            }
        }
    }
    return count;
}

pub fn isXmasSquare(m: [3][3]u8) bool {
    const d = [_]u8 {m[0][0], m[1][1], m[2][2]};
    const u = [_]u8 {m[0][2], m[1][1], m[2][0]};
    return 
        (std.mem.eql(u8, d[0..], "SAM") or std.mem.eql(u8, d[0..], "MAS")) and
        (std.mem.eql(u8, u[0..], "SAM") or std.mem.eql(u8, u[0..], "MAS"));
}

pub fn xmasStringCount(m: []const []const u8) u64 {
    var count: u64 = 0;
    for (m, 0..) |_, j| {
        count += _xmasStringCount(m[0..], 0, j, 1, 0); //hori
        count += _xmasStringCount(m[0..], j, 0, 0, 1); //vert
        count += _xmasStringCount(m[0..], 0, j, 1, 1); //diag-down
        if (j != 0) count += _xmasStringCount(m[0..], j, 0, 1, 1); //diag-down
        count += _xmasStringCount(m[0..], 0, m.len - 1 - j, 1, -1); //diag-up
        if (j != 0) count += _xmasStringCount(m[0..], j, m.len - 1, 1, -1); //diag-up
    }
    return count;
}

pub fn _xmasStringCount(m: []const []const u8, sx: usize, sy: usize, dx: i8, dy: i8) u64 {
    var x = sx; var y = sy;
    var count: u64 = 0;
    outer: while(y < m.len and x < m[y].len) {
        var target: [4]u8 = undefined;
        for (target, 0..) |_, i| {
            const nx: i16 = @as(i16, @intCast(x)) + @as(i16,@intCast(i))*dx;
            const ny: i16 = @as(i16, @intCast(y)) + @as(i16,@intCast(i))*dy;
            if (ny < 0 or ny >= m.len or nx < 0 or nx >= m[@intCast(ny)].len) {
                break :outer;
            }
            target[i] = m[@intCast(ny)][@intCast(nx)];
        }
        if (std.mem.eql(u8, "XMAS", target[0..]) or std.mem.eql(u8, "SAMX", target[0..])) {
            count += 1;
        }
        x = @intCast(@as(i16, @intCast(x)) + dx);
        y = @intCast(@as(i16, @intCast(y)) + dy);
    }

           return count;
}

test "xmas" {
    const m: [3][3]u8 = [_][3]u8 {
        "M.S".*,
        ".A.".*,
        "M.S".*,
    };
    try expect(isXmasSquare(m));
}

test "xmasCount" {
    const m: []const []const u8 = &.{
        ".M.S......",
        "..A..MSMS.",
        ".M.S.MAA..",
        "..A.ASMSM.",
        ".M.S.M....",
        "..........",
        "S.S.S.S.S.",
        ".A.A.A.A..",
        "M.M.M.M.M.",
        "..........",
    };
    try expect(xMasSquareCount(m) == 9);
}

test "xmasCount-hori" {
    //const t: []const u8 = "test";
    const m: []const []const u8 = &.{"XMASXMASAMX"};
    try expect(_xmasStringCount(m, 0, 0, 1, 0) == 3);
}

test "xmasCount-vert" {
    //const t: []const u8 = "test";
    const m: []const []const u8 = &.{
        "....XXMAS.",
        ".SAMXMS...",
        "...S..A...",
        "..A.A.MS.X",
        "XMASAMX.MM",
        "X.....XA.A",
        "S.S.S.S.SS",
        ".A.A.A.A.A",
        "..M.M.M.MM",
        ".X.X.XMASX",
    };
    try expect(_xmasStringCount(m, 9, 0, 0, 1) == 2);
    try expect(_xmasStringCount(m, 0, 9, 1, 0) == 1);
    try expect(_xmasStringCount(m, 3, 9, -1, -1) == 1);
    try expect(_xmasStringCount(m, 5, 9, 1, -1) == 1);
}
