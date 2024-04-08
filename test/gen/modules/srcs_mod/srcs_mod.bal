import srcs.gleam_ as gleam_;
import srcs.srcs_hello_world as hello_world;

type gleam_ignore gleam_:Ignore;

public function hello_world_string() returns string {
    return hello_world:hello_world_string();
}
