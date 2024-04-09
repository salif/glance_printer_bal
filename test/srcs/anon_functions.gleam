import gleam/io

pub fn main() {
   let add_one = fn(a: Int) -> Int { a + 1 }
   io.debug(twice(1, add_one))

   io.debug(twice(1, fn(a: Int) -> Int { a * 2 }))
}

fn twice(argument: Int, my_function: fn(Int) -> Int) -> Int {
   my_function(my_function(argument))
}
