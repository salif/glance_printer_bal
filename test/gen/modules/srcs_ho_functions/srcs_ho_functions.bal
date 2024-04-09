import srcs.gleam_ as gleam_;
import srcs.gleam_io as io;

type gleam_ignore gleam_:Ignore;

public function main() returns error? {
    _ = io:debug(twice(1, add_one));
    final var my_function = add_one;
    return gleam_:mainReturn(io:debug(my_function(100)));
}

function twice(int argument, function (int) returns int passed_function) returns int {
    return passed_function(passed_function(argument));
}

function add_one(int argument) returns int {
    return argument + 1;
}
