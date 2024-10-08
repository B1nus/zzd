const std = @import("std");
const flag_parser = @import("flags.zig");
const parse_flags = flag_parser.parse_flags;
const stdout = std.io.getStdOut().writer();
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

pub fn main() !void {
    const args = try std.process.argsAlloc(arena.allocator());
    defer std.process.argsFree(arena.allocator(), args);

    // Check argument amounts
    const flags = parse_flags(args[1..]);

    std.debug.print("{any}\n", .{flags});

    return;

    // // Get file handle
    // const path = args[1];
    // const file = std.fs.cwd().openFile(path, .{ .mode = .read_only }) catch |err| switch (err) {
    //     error.FileNotFound => {
    //         std.debug.print("File '{s}' not found: \n", .{path});
    //         return zzdError.FileNotFound;
    //     },
    //     else => return err,
    // };
    //
    // // Read
    // const reader = file.reader();
    // const stat = try file.stat();
    // const buffer = try arena.allocator().alloc(u8, stat.size);
    // _ = try reader.read(buffer);
    // defer arena.allocator().free(buffer);
    // var lines = std.mem.window(u8, buffer, chunk_size * columns, chunk_size * columns);
    //
    // // const red = "\x1b[91m";
    // const bold = "\x1b[1m";
    // const green = "\x1b[32m";
    // const yellow = "\x1b[33m";
    // const reset = "\x1b[0m";
    //
    // var line_i: usize = 0;
    // while (lines.next()) |line| {
    //     try stdout.print("{x:0>8}: {s}", .{ line_i * chunk_size * columns, bold });
    //
    //     var empy = false;
    //     for (0..(chunk_size * columns)) |i| {
    //         // Column
    //         if (i % chunk_size == 0 and i > 0) {
    //             try stdout.print(" ", .{});
    //         }
    //
    //         if (empy) {
    //             try stdout.print("  ", .{});
    //         } else {
    //             // End of file
    //             empy = (i + line_i * chunk_size * columns + 1 >= stat.size);
    //
    //             const array = [1]u8{line[i]};
    //             const as_hex = std.fmt.bytesToHex(array, case);
    //             if (line[i] == '\n') {
    //                 try stdout.print("{s}{s}", .{ yellow, as_hex });
    //             } else {
    //                 try stdout.print("{s}{s}", .{ green, as_hex });
    //             }
    //         }
    //     }
    //
    //     try stdout.print("  ", .{});
    //
    //     for (line) |c| switch (c) {
    //         '\n' => std.debug.print("{s}.", .{yellow}),
    //         '\r' => std.debug.print("{s}.", .{green}),
    //         '\t' => std.debug.print("{s}.", .{green}),
    //         else => std.debug.print("{s}{c}", .{ green, c }),
    //     };
    //     try stdout.print("\n{s}", .{reset});
    //     line_i += 1;
    // }
}

pub fn bytes(file: []const u8) []u8 {
    return file;
}
