import srcs.gleam_ as gleam_;
import srcs.gleam_io as io;

type gleam_ignore gleam_:Ignore;

public function main() returns error? {
    _ = io:debug(1 + 1);
    _ = io:debug(5 - 1);
    _ = io:debug(gleam_:divideInt(5, 2));
    _ = io:debug(3 * 3);
    _ = io:debug(gleam_:remainderInt(5, 2));
    _ = io:debug(2 > 1);
    _ = io:debug(2 < 1);
    _ = io:debug(2 >= 1);
    _ = io:debug(2 <= 1);
    _ = io:debug(1 == 1);
    _ = io:debug(2 == 1);
    return gleam_:mainReturn(());
}
