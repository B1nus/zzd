const std = @import("std");
const flag_parser = @import("flags.zig");
const stdin = std.io.getStdIn();
const stdout = std.io.getStdOut().writer();
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

const ReadError = error{
    OutOfMemory,
    OffsetTooFar,
};

// Don't forget to defer!
pub fn read_all(allocator: std.mem.Allocator, file: std.fs.File, offset: usize, max: ?usize) ReadError!std.ArrayList(u8) {
    const reader = file.reader();
    const max_append_size = max orelse std.math.maxInt(usize);
    var bytes = std.ArrayList(u8).init(allocator);

    reader.skipBytes(offset, .{}) catch {
        return ReadError.OffsetTooFar;
    };

    reader.readAllArrayList(&bytes, max_append_size) catch |e| switch (e) {
        std.mem.Allocator.Error.OutOfMemory => return ReadError.OutOfMemory,
        else => {},
    };

    return bytes;
}
// const red = "\x1b[91m";
// const bold = "\x1b[1m";
// const green = "\x1b[32m";
// const yellow = "\x1b[33m";
// const reset = "\x1b[0m";
pub fn main() !void {
    const allocator = arena.allocator();
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const flags = try flag_parser.parse_flags(args[2..]);
    var max_bytes: usize = std.math.maxInt(usize);

    if (flags.lines != null) {
        max_bytes = (flags.lines.?) * flags.cols;
    }

    var file = stdin;
    if (stdin.isTty()) {
        if (args.len < 2) {
            try stdout.print("zzd is missing the file argument. Please write like so `$ zzd file`", .{});
            std.process.exit(0);
        }

        const argfile = std.fs.cwd().openFile(args[1], .{}) catch |e| switch (e) {
            std.fs.File.OpenError.FileNotFound => {
                try stdout.print("zzd could not find the file {s}", .{args[1]});
                return e;
            },
            else => return e,
        };

        file = argfile;
    }

    const bytes = try read_all(allocator, file, flags.offset, max_bytes);
    try stdout.print("{any}", .{bytes});
}
