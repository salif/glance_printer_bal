import srcs.gleam_ as gleam_;
import srcs.gleam_io as io;

type gleam_ignore gleam_:Ignore;

public function main() returns error? {
    _ = io:debug(1000000);
    _ = io:debug(10000.01);
    _ = io:debug(0xF);
    _ = io:debug(7.0e7);
    _ = io:debug(3.0e-4);
    return gleam_:mainReturn(());
}
