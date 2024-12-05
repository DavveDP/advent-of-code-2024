const std = @import("std");
const expect = std.testing.expect;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const stdin_file = std.io.getStdIn().reader();
    var br = std.io.bufferedReader(stdin_file);
    const stdin = br.reader();

    var reports = std.ArrayList(std.ArrayList(u8)).init(allocator);
    defer {
        for (reports.items) |list| {
            list.deinit();
        }
        reports.deinit();
    }
    var buf: [24]u8 = undefined;
    while (true) {
        const line = (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')
            orelse break);
        var it = std.mem.splitScalar(u8, line, ' ');

        var report = std.ArrayList(u8).init(allocator);
        while(it.next()) |n_str| {
            const n = std.fmt.parseInt(u8, n_str, 10) catch continue;
            try report.append(n);
        }
        try reports.append(report);
    }

    var valid: u32 = 0;
    for (reports.items) |report| {
        if (isSafe(report.items)) {
            for (report.items) |n| {
                try stdout.print("{d}, ", .{n});
            }
            try stdout.print("safe! \n",.{});
            valid += 1;
        }
    }
    try stdout.print("{d}\n", .{valid});

    try bw.flush(); // don't forget to flush!
}

pub fn isSafe(report: []const u8) bool {
    if (report.len < 2) return true;
    
    const sign: i8 = @as(i8, @intCast(report[1])) - @as(i8, @intCast(report[0]));
    if (sign == 0 or @abs(sign) > 3) return false;
    var prev: u8 = report[1];

    for (report[2..]) |n| {
        const diff: i8 = @as(i8, @intCast(n)) - @as(i8, @intCast(prev));
        const dist = @abs(diff);
        if (dist > 3 or dist == 0) return false;
        if (diff * sign < 0) return false;
        prev = n;
    }
    return true;
}

test "isSafe" {
    // Safe reports
    {
        const r1 = [_]u8{1, 2, 3};
        const r2 = [_]u8{10, 7, 5, 2, 1};
        try expect(isSafe(r1[0..]));
        try expect(isSafe(r2[0..]));
    }

    //Unsafe reports
    {
        const r3 = [_]u8{1, 1, 2};
        const r4 = [_]u8{1, 2, 4, 5, 5};
        const r5 = [_]u8{2, 7};
        const r6 = [_]u8{8, 3};
        const r7 = [_]u8{1, 2, 4, 5, 2, 7};

        try expect(!isSafe(r3[0..]));
        try expect(!isSafe(r4[0..]));
        try expect(!isSafe(r5[0..]));
        try expect(!isSafe(r6[0..]));
        try expect(!isSafe(r7[0..]));
    }

}
