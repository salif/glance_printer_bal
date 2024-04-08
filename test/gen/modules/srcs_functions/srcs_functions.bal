import srcs.gleam_ as gleam_;
import srcs.gleam_io as io;

type gleam_ignore gleam_:Ignore;

public function main() returns error? {
    return gleam_:mainReturn(io:debug(double(10)));
}

function double(int a) returns int {
    return multiply(a, 2);
}

function multiply(int a, int b) returns int {
    return a * b;
}
