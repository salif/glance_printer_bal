import gleam/io

pub type UserId =
   Int

pub fn main() {
   let one: UserId = 1
   let two: Int = 2

   io.debug(one == two)
}
