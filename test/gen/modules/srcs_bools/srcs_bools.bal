import srcs.gleam_ as gleam_;
import srcs.gleam_io as io;

type gleam_ignore gleam_:Ignore;

public function main() returns gleam_:MainReturn {
    _ = io:debug(true && false);
    _ = io:debug(true && true);
    _ = io:debug(false || false);
    _ = io:debug(false || true);
    return gleam_:mainReturn(());
}
