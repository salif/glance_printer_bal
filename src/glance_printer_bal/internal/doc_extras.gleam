//// Not usually big on util files like this, but I figured it would be good
//// to separate out helpers that don't actually have anything
//// to do with glance.

import glam/doc.{type Document}
import gleam/option.{type Option, None, Some}

/// The indent for nesting is always 2 spaces, so we don't
/// need to keep typing it all the time.
pub fn nest(input: Document) -> Document {
   doc.nest(input, 4)
}

/// A comma that only prints when the 
/// group is broken
pub fn trailing_comma() -> Document {
   doc.break("", ",")
}

/// A non breaking space
pub fn nbsp() -> Document {
   doc.from_string(" ")
}

pub fn semicolon() -> Document {
   doc.from_string(";")
}

/// Take a list of documents, separate them with commas, and wrap
/// them in parentheses. Provides a trailing comma on breaking.
pub fn comma_separated_in_parentheses(arguments: List(Document)) -> Document {
   let comma_separated_arguments: Document =
      arguments
      |> doc.concat_join([doc.from_string(","), doc.space])

   doc.concat([doc.from_string("("), doc.soft_break])
   |> doc.append(comma_separated_arguments)
   |> nest
   |> doc.append_docs([trailing_comma(), doc.from_string(")")])
   |> doc.group
}

pub fn gen_uimport(
   mp: String,
   name: String,
   alias: Option(String),
   ty: String,
   op: String,
) -> Document {
   doc.from_string(
      ty
      <> case alias {
         Some(val) -> val
         None -> name
      }
      <> op
      <> mp
      <> ":"
      <> name
      <> ";",
   )
}
