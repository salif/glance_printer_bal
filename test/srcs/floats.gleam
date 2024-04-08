import gleam/io

pub fn main() -> Nil {
   io.debug(1.0 +. 1.5)
   io.debug(5.0 -. 1.5)
   io.debug(5.0 /. 2.5)
   io.debug(3.0 *. 3.5)

   io.debug(2.2 >. 1.3)
   io.debug(2.2 <. 1.3)
   io.debug(2.2 >=. 1.3)
   io.debug(2.2 <=. 1.3)

   io.debug(1.1 == 1.1)
   io.debug(2.1 == 1.2)

   io.debug(3.14 /. 0.0)

   Nil
}
