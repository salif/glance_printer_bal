import ballerina/io;
import gen.hello_world;

public function main() {
    io:println(hello_world:hello_world_string());
}
