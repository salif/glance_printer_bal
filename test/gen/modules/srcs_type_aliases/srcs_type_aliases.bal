import srcs.gleam_ as gleam_;
import srcs.gleam_io as io;

type gleam_ignore gleam_:Ignore;

public type UserId
    int;

public function main() returns gleam_:MainReturn {
    final UserId one = 1;
    final int two = 2;
    return gleam_:mainReturn(io:debug(one == two));
}
