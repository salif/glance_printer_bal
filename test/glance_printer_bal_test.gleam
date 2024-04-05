import glance_printer_bal as gpl
import gleam/list
import gleam/string
import simplifile
import testbldr

pub fn main() {
   let test_runner: testbldr.TestRunner =
      testbldr.test_runner_default()
      |> testbldr.include_passing_tests_in_output(True)
      |> testbldr.output_results_to_stdout()
   test_runner
   |> testbldr.run(file_based_tests())
}

fn file_based_tests() {
   let assert Ok(src_files) = simplifile.read_directory(at: "./test/srcs")
   use file <- list.map(src_files)
   let assert Ok(src_file) = simplifile.read("./test/srcs/" <> file)
   let assert Ok(test_name) =
      file
      |> string.split(".")
      |> list.first
   use <- testbldr.named(test_name)
   let assert Ok(gen_file) =
      simplifile.read("./test/gen/modules/" <> test_name <> "/" <> test_name <> ".bal")
   identity(src_file, gen_file)
}

fn identity(src: String, gen: String) {
   let assert Ok(module) = gpl.src(src)
   let printed: String = gpl.print(module)
   case printed == gen {
      True -> testbldr.Pass
      False -> {
         testbldr.Fail("\n\nexpected:\n```\n" <> gen <> "```\ngot:\n```\n" <> printed <> "```\n")
      }
   }
}
