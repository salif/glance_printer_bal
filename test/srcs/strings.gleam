import gleam/io

pub fn main() {
   io.debug("👩‍💻 こんにちは Gleam 🏳️‍🌈")
   io.debug(
      "multi
  line
  string",
   )
   io.debug("\u{1F600}")

   io.println("\"X\" marks the spot")

   io.debug("One " <> "Two")
}
