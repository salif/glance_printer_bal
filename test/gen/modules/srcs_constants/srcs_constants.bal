import srcs.gleam_ as gleam_;
import srcs.gleam_io as io;

type gleam_ignore gleam_:Ignore;

const int[*] ints = [1, 2, 3];

const floats = [1.0, 2.0, 3.0];

public function main() returns error? {
    _ = io:debug(ints);
    _ = io:debug(ints == [1, 2, 3]);
    _ = io:debug(floats);
    return gleam_:mainReturn(io:debug(floats == [1.0, 2.0, 3.0]));
}
