import gleam/io

pub fn main() -> Nil {
   io.debug(1 + 1)
   io.debug(5 - 1)
   io.debug(5 / 2)
   io.debug(3 * 3)
   io.debug(5 % 2)

   io.debug(2 > 1)
   io.debug(2 < 1)
   io.debug(2 >= 1)
   io.debug(2 <= 1)

   io.debug(1 == 1)
   io.debug(2 == 1)

   Nil
}
