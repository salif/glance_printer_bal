import gleam/io

pub fn main() -> Nil {
   io.debug(True && False)
   io.debug(True && True)
   io.debug(False || False)
   io.debug(False || True)

   Nil
}
