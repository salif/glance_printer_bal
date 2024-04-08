import srcs.gleam_ as gleam_;
import srcs.gleam_bytes_builder as bytes_builder;
type BytesBuilder bytes_builder:BytesBuilder;

type gleam_ignore gleam_:Ignore;

public function main() returns gleam_:MainReturn {
    final bytes_builder:BytesBuilder _ = bytes_builder:'new();
    final BytesBuilder _ = bytes_builder:'new();
    return gleam_:mainReturn(());
}
