import srcs.gleam_ as gleam_;
import srcs.gleam_io as io;

type gleam_ignore gleam_:Ignore;

public function main() returns gleam_:MainReturn {
    final var x = "Original";
    _ = io:debug(x);
    final var y = x;
    return gleam_:mainReturn(io:debug(y));
}
