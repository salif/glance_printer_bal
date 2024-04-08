import srcs.gleam_ as gleam_;

type gleam_ignore gleam_:Ignore;

public function main() returns error? {
    final var _ = 1000;
    return gleam_:mainReturn(());
}
