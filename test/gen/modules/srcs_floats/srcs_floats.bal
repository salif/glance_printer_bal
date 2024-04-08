import srcs.gleam_ as gleam_;
import srcs.gleam_io as io;

type gleam_ignore gleam_:Ignore;

public function main() returns gleam_:MainReturn {
    _ = io:debug(1.0 + 1.5);
    _ = io:debug(5.0 - 1.5);
    _ = io:debug(gleam_:divideFloat(5.0, 2.5));
    _ = io:debug(3.0 * 3.5);
    _ = io:debug(2.2 > 1.3);
    _ = io:debug(2.2 < 1.3);
    _ = io:debug(2.2 >= 1.3);
    _ = io:debug(2.2 <= 1.3);
    _ = io:debug(1.1 == 1.1);
    _ = io:debug(2.1 == 1.2);
    _ = io:debug(gleam_:divideFloat(3.14, 0.0));
    return gleam_:mainReturn(());
}
