import srcs.gleam_ as gleam_;
import srcs.gleam_io as io;

type gleam_ignore gleam_:Ignore;

public function main() returns error? {
    final var add_one = function(int a) returns int {
        return a + 1;
    };
    _ = io:debug(twice(1, add_one));
    return gleam_:mainReturn(io:debug(twice(1, function(int a) returns int {
                return a * 2;
            })));
}

function twice(int argument, function (int) returns int my_function) returns int {
    return my_function(my_function(argument));
}
