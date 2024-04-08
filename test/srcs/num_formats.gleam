import gleam/io

pub fn main() -> Nil {
   io.debug(1_000_000)
   io.debug(10_000.01)

   io.debug(0xF)

   io.debug(7.0e7)
   io.debug(3.0e-4)
   Nil
}
