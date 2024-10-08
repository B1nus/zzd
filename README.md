# zzd
A xxd clone made in zig. The name is from a [Low Level Learning video](https://www.youtube.com/watch?v=pnnx1bkFXng).

# Usage
Use `$ zig build-exe zzd.zig` to build the executable and use `$ ./zzd [filename]` to make a hex dump. There are 7 flags available in `zzd`:
`````
zzd -r [filename]               Revert hex dump to binary.
zzd [filename] -u               Upper-case hex letters.
zzd [filename] -c [columns]     Bytes per line. Defaults to 16.
zzd [filename] -g [group_size]  Bytes per group. Defaults to 2.
zzd [filename] -s [offset]      Start dump at byte offset.
zzd [filename] -l [lines]       Stop after dumping lines.
zzd [filename] -e               Use little endian.
`````
