import gleam/io

pub fn main() {
   let x = "Original"
   io.debug(x)

   let y = x
   io.debug(y)
}
