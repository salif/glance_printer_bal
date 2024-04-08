import srcs.gleam_ as gleam_;
import srcs.gleam_io as io;

type gleam_ignore gleam_:Ignore;

public function main() returns gleam_:MainReturn {
    return gleam_:mainReturn(io:println("This is qualified"));
}
