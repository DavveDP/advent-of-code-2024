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

    var count: u64 = 0;
    for (m, 0..) |_, j| {
        count += xmasCount(m[0..], 0, j, 1, 0); //hori
        count += xmasCount(m[0..], j, 0, 0, 1); //vert
        count += xmasCount(m[0..], 0, j, 1, 1); //diag-down
        if (j != 0) count += xmasCount(m[0..], j, 0, 1, 1); //diag-down
        count += xmasCount(m[0..], 0, m.len - 1 - j, 1, -1); //diag-up
        if (j != 0) count += xmasCount(m[0..], j, m.len - 1, 1, -1); //diag-up
    }

    try stdout.print("Count: {d}\n", .{count});

    try bw.flush(); // don't forget to flush!
}

pub fn xmasCount(m: []const []const u8, sx: usize, sy: usize, dx: i8, dy: i8) u64 {
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

test "xmasCount-hori" {
    //const t: []const u8 = "test";
    const m: []const []const u8 = &.{"XMASXMASAMX"};
    try expect(xmasCount(m, 0, 0, 1, 0) == 3);
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
    try expect(xmasCount(m, 9, 0, 0, 1) == 2);
    try expect(xmasCount(m, 0, 9, 1, 0) == 1);
    try expect(xmasCount(m, 3, 9, -1, -1) == 1);
    try expect(xmasCount(m, 5, 9, 1, -1) == 1);
}
