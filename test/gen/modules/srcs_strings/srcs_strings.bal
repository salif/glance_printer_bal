import srcs.gleam_ as gleam_;
import srcs.gleam_io as io;

type gleam_ignore gleam_:Ignore;

public function main() returns error? {
    _ = io:debug("👩‍💻 こんにちは Gleam 🏳️‍🌈");
    _ = io:debug("multi\n  line\n  string");
    _ = io:debug("\u{1F600}");
    _ = io:println("\"X\" marks the spot");
    return gleam_:mainReturn(io:debug("One " + "Two"));
}
