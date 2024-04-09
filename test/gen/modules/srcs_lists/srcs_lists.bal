import srcs.gleam_ as gleam_;
import srcs.gleam_io as io;

type gleam_ignore gleam_:Ignore;

public function main() returns error? {
    final var ints = [1, 2, 3];
    _ = io:debug(ints);
    _ = io:debug([-1, 0, ...ints]);
    return gleam_:mainReturn(io:debug(ints));
}
