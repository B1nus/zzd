# zzd
zzd is a hex dumper utility made in zig. It's a clone of the [xxd program](https://github.com/vim/vim/blob/master/src/xxd/xxd.c) and the name is from a [Low Level Learning video](https://www.youtube.com/watch?v=pnnx1bkFXng). Consider it my solution to [this coding challenge](https://codingchallenges.fyi/challenges/challenge-xxd/).

# Usage
Use `$ zig build-exe zzd.zig` to build the executable and use `$ ./zzd [filename]` to make a hex dump. There are 8 flags available in `zzd`:
`````
zzd [filename] -h               Print help
zzd [filename] -r               Revert hex dump to binary.
zzd [filename] -u               Upper-case hex letters.
zzd [filename] -c [columns]     Bytes per line. Defaults to 16.
zzd [filename] -g [group_size]  Bytes per group. Defaults to 2.
zzd [filename] -s [offset]      Start dump at byte offset.
zzd [filename] -l [lines]       Stop after dumping lines.
zzd [filename] -e               Use little endian.
`````

# Note to self
- Don't forget invlaid values for flags. I.E. 0, g > c etc.
- Don't forget piping.
- Don't forget coloring with ANSI.
- Don't forget EOF.
- Forget LLL's implementation. Do your own.
