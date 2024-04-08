import gleam/list
import gleam/int
import gleam/string
import gleam/result
import gleam/option.{type Option, None, Some}
import glance as g
import glam/doc.{type Document}
import glance_printer_bal/internal/doc_extras as de
import glance_printer_bal/internal/bal

/// Pretty print a glance module
pub fn print(module module: g.Module, module_name module_name: String) -> String {
   let g.Module(
      imports,
      custom_types,
      type_aliases,
      constants,
      _external_types,
      _external_functions,
      functions,
   ): g.Module = module

   // Everything elses gets separated by an empty line (2 line breaks)
   let the_rest: List(Document) =
      [
         list.map(custom_types, pretty_custom_type),
         list.map(type_aliases, pretty_type_alias),
         list.map(constants, pretty_constant),
         list.map(functions, pretty_function),
      ]
      |> list.filter(fn(lst) { !list.is_empty(lst) })
      |> list.map(list.reverse)
      |> list.map(doc.join(_, doc.lines(2)))

   // Handle imports separately because they're joined with only on line break
   let imports_to_doc: Document =
      imports
      |> list.reverse
      |> list.prepend(g.Definition([], g.Import(bal.k_gleam_, Some(bal.k_gleam_), [], [])))
      |> list.map(pretty_import(_, module_name))
      |> list.append(pretty_unqualified_imports(imports))
      |> doc.join(doc.line)

   let ignore_type: Document = doc.from_string(bal.k_gleam_ignore)

   [imports_to_doc, ignore_type, ..the_rest]
   |> doc.join(doc.lines(2))
   |> doc.to_string(bal.max)
   |> string.trim
   <> "\n"
}

fn pretty_definition(
   definition: g.Definition(inner),
   inner_to_doc: fn(inner) -> Document,
) -> Document {
   let g.Definition(attributes, definition) = definition
   attributes
   |> list.map(pretty_attribute)
   |> list.append([inner_to_doc(definition)])
   |> doc.join(with: doc.line)
}

fn pretty_attribute(attribute: g.Attribute) -> Document {
   panic as "implement pretty_attribute"
   let g.Attribute(name, arguments) = attribute
   let arguments =
      arguments
      |> list.map(pretty_expression)
      |> de.comma_separated_in_parentheses
   [doc.from_string("@" <> name), arguments]
   |> doc.concat
}

/// Pretty print a top level function.
fn pretty_function(function: g.Definition(g.Function)) -> Document {
   use g.Function(name, publicity, parameters, return, statements, _) <- pretty_definition(function)

   let parameters =
      parameters
      |> list.map(pretty_function_parameter)
      |> de.comma_separated_in_parentheses

   let statements = case statements {
      [] -> doc.empty
      _ ->
         [de.nbsp(), pretty_block(statements, name == "main")]
         |> doc.concat
   }

   [
      pretty_public(publicity),
      doc.from_string(bal.k_function_ <> name),
      parameters,
      pretty_return_signature(return, name == "main"),
      statements,
   ]
   |> doc.concat
}

// Pretty print a parameter of a top level function
// For printing an anonymous function paramater, see `pretty_fn_parameter`
fn pretty_function_parameter(parameter: g.FunctionParameter) -> Document {
   let g.FunctionParameter(label, name, type_) = parameter
   let label_to_doc: Document = case label {
      Some(l) -> {
         panic as "implement pretty_function_parameter"
         doc.from_string(l <> " ")
      }
      None -> doc.empty
   }

   [label_to_doc, pretty_type_annotation(type_, False), pretty_assignment_name(name)]
   |> doc.concat
}

/// Pretty print a statement
fn pretty_statement(statement: g.Statement, last: Bool, is_main: Bool) -> Document {
   case statement {
      g.Expression(expression) ->
         doc.concat([
            case last, is_main {
               True, False -> doc.from_string(bal.k_return_)
               True, True -> doc.from_string(bal.k_return_main)
               False, _ -> doc.from_string(bal.k_ignore_var)
            },
            pretty_expression(expression),
            case is_main {
               True -> doc.from_string(")")
               False -> doc.empty
            },
         ])

      g.Assignment(kind, pattern, annotation, value) -> {
         let _let_declaration = case kind {
            g.Let -> doc.from_string(bal.k_var_)
            g.Assert -> {
               panic as "implement let assert"
               doc.from_string("let assert ")
            }
         }

         [
            // let_declaration,
            pretty_type_annotation(annotation, True),
            pretty_pattern(pattern),
            doc.from_string(" = "),
            pretty_expression(value),
         ]
         |> doc.concat
      }
      g.Use(patterns, function) -> {
         panic as "implement use"
         let patterns =
            patterns
            |> list.map(pretty_pattern)
            |> doc.join(with: doc.from_string(", "))

         [doc.from_string("use "), patterns, doc.from_string(" <- "), pretty_expression(function)]
         |> doc.concat
      }
   }
   |> doc.append(de.semicolon())
}

/// Pretty print a "pattern" (anything that could go in a pattern match branch)
fn pretty_pattern(pattern: g.Pattern) -> Document {
   case pattern {
      // Basic patterns
      g.PatternInt(val) | g.PatternFloat(val) -> doc.from_string(val)

      g.PatternVariable(val) -> doc.from_string(bal.bal_var(val))

      g.PatternString(val) -> doc.from_string("\"" <> val <> "\"")

      // A discarded value should start with an underscore
      g.PatternDiscard(_) -> doc.from_string("_")

      // TODO: this
      // A tuple pattern
      g.PatternTuple(elements) ->
         elements
         |> list.map(pretty_pattern)
         |> pretty_tuple

      // A list pattern
      g.PatternList(elements, tail) ->
         pretty_list(
            of: list.map(elements, pretty_pattern),
            with_tail: option.map(tail, pretty_pattern),
         )

      // Pattern for renaming something with "as"
      g.PatternAssignment(pattern, name) -> {
         [pretty_pattern(pattern), pretty_as(Some(name))]
         |> doc.concat
      }

      // Pattern for pulling off the front end of a string
      g.PatternConcatenate(left, right) -> {
         [doc.from_string("\"" <> left <> "\" <> "), pretty_assignment_name(right)]
         |> doc.concat
      }

      g.PatternBitString(segments) -> pretty_bitstring(segments, pretty_pattern)

      g.PatternConstructor(module, constructor, arguments, with_spread) -> {
         let module =
            module
            |> option.map(doc.from_string)
            |> option.unwrap(or: doc.empty)

         let arguments = list.map(arguments, pretty_field(_, pretty_pattern))

         let arguments =
            case with_spread {
               True -> list.append(arguments, [doc.from_string("..")])
               False -> arguments
            }
            |> de.comma_separated_in_parentheses

         [module, doc.from_string(constructor), arguments]
         |> doc.concat
      }
   }
}

// Pretty print a constant
fn pretty_constant(constant: g.Definition(g.Constant)) -> Document {
   panic as "implement pretty_constant"
   use g.Constant(name, publicity, annotation, value) <- pretty_definition(constant)

   [
      pretty_public(publicity),
      doc.from_string("const " <> name),
      pretty_type_annotation(annotation, False),
      doc.from_string(" ="),
      doc.space,
      pretty_expression(value),
   ]
   |> doc.concat
}

/// Pretty print a block of statements
fn pretty_block(statements: List(g.Statement), is_main: Bool) -> Document {
   // Statements are separated by a single line
   let statements =
      case list.reverse(statements) {
         [last, ..rest] -> {
            let rest = list.map(rest, pretty_statement(_, False, False))
            let last = pretty_statement(last, True, is_main)
            [last, ..rest]
            |> list.reverse
         }
         _ -> list.map(statements, pretty_statement(_, True, False))
      }
      |> doc.join(with: doc.line)

   // A block gets wrapped in squiggly brackets and indented
   doc.concat([doc.from_string("{"), doc.line])
   |> doc.append(statements)
   |> de.nest
   |> doc.append_docs([doc.line, doc.from_string("}")])
}

// Pretty print a tuple of types, expressions, or patterns
fn pretty_tuple(with elements: List(Document)) -> Document {
   panic as "implement pretty_tuple"
   let comma_separated_elements =
      elements
      |> doc.join(with: doc.concat([doc.from_string(","), doc.space]))

   doc.concat([doc.from_string("#("), doc.soft_break])
   |> doc.append(comma_separated_elements)
   |> de.nest
   |> doc.append(doc.concat([de.trailing_comma(), doc.from_string(")")]))
   |> doc.group
}

// Pretty print a list of expressions or patterns
fn pretty_list(of elements: List(Document), with_tail tail: Option(Document)) -> Document {
   panic as "implement pretty_list"
   let tail =
      tail
      |> option.map(doc.prepend(_, doc.from_string("..")))

   let comma_separated_items =
      elements
      |> list.append(option.values([tail]))
      |> doc.concat_join([doc.from_string(","), doc.space])

   doc.concat([doc.from_string("["), doc.soft_break])
   |> doc.append(comma_separated_items)
   |> de.nest
   |> doc.append_docs([doc.soft_break, doc.from_string("]")])
   |> doc.group
}

// Expression -------------------------------------

// TODO: Implement pretty_expression
fn pretty_expression(expression: g.Expression) -> Document {
   case expression {
      g.Variable(str) -> doc.from_string(bal.bal_var(str))
      g.Int(str) | g.Float(str) ->
         doc.from_string(case string.contains(str, "_") {
            True -> string.replace(str, "_", "")
            False -> str
         })

      // A string literal needs to bee wrapped in quotes
      g.String(val) ->
         doc.from_string(
            "\""
            <> case string.contains(val, "\n") {
               True -> string.replace(val, "\n", "\\n")
               False -> val
            }
            <> "\"",
         )

      // Negate int gets a - in front
      g.NegateInt(expr) ->
         [doc.from_string("-"), pretty_expression(expr)]
         |> doc.concat

      // Negate bool gets a ! in front
      g.NegateBool(expr) ->
         [doc.from_string("!"), pretty_expression(expr)]
         |> doc.concat

      // A block of statements
      g.Block(statements) -> pretty_block(statements, False)

      // Pretty print a panic
      g.Panic(msg) -> {
         case msg {
            Some(str) -> doc.from_string("panic as \"" <> str <> "\"")
            None -> doc.from_string("panic")
         }
      }

      // Pretty print a todo
      g.Todo(msg) -> {
         case msg {
            Some(str) -> doc.from_string("todo as \"" <> str <> "\"")
            None -> doc.from_string("todo")
         }
      }

      // Pretty print a tuple
      g.Tuple(expressions) ->
         expressions
         |> list.map(pretty_expression)
         |> pretty_tuple

      // Pretty print a list
      g.List(elements, rest) ->
         pretty_list(list.map(elements, pretty_expression), option.map(rest, pretty_expression))

      // Pretty print a function
      g.Fn(arguments, return, body) -> pretty_fn(arguments, return, body)

      // Pretty print a record update expression
      g.RecordUpdate(module, constructor, record, fields) -> {
         let module = case module {
            Some(str) -> doc.from_string(str)
            None -> doc.empty
         }

         let record =
            [doc.from_string(".."), pretty_expression(record)]
            |> doc.concat

         let fields =
            list.map(fields, fn(field) {
               let #(name, expr) = field
               [doc.from_string(name <> ": "), pretty_expression(expr)]
               |> doc.concat
            })
            |> list.prepend(record)
            |> de.comma_separated_in_parentheses

         [module, doc.from_string(constructor), fields]
         |> doc.concat
      }

      g.FieldAccess(container, label) -> {
         [pretty_expression(container), doc.from_string(":" <> bal.bal_var(label))]
         |> doc.concat
      }

      g.Call(function, arguments) -> {
         let arguments =
            arguments
            |> list.map(pretty_field(_, pretty_expression))
            |> de.comma_separated_in_parentheses
         [pretty_expression(function), arguments]
         |> doc.concat
      }

      g.TupleIndex(tuple, index) -> {
         [pretty_expression(tuple), doc.from_string("." <> int.to_string(index))]
         |> doc.concat
      }

      g.FnCapture(label, function, arguments_before, arguments_after) -> {
         let arguments_before = list.map(arguments_before, pretty_field(_, pretty_expression))
         let arguments_after = list.map(arguments_after, pretty_field(_, pretty_expression))
         let placeholder = case label {
            Some(str) -> doc.from_string(str <> ": _")
            None -> doc.from_string("_")
         }
         let in_parens =
            arguments_before
            |> list.append([placeholder])
            |> list.append(arguments_after)
            |> de.comma_separated_in_parentheses

         [pretty_expression(function), in_parens]
         |> doc.concat
      }
      g.BitString(segments) -> pretty_bitstring(segments, pretty_expression)
      g.Case(subjects, clauses) -> {
         let subjects =
            subjects
            |> list.map(pretty_expression)
            |> doc.join(with: doc.from_string(", "))

         let clauses =
            {
               use g.Clause(lolo_patterns, guard, body) <- list.map(clauses)

               let lolo_patterns = list.map(lolo_patterns, list.map(_, pretty_pattern))

               let lolo_patterns =
                  list.map(lolo_patterns, doc.join(_, with: doc.from_string(", ")))
                  |> doc.join(with: doc.from_string(" | "))

               let guard =
                  option.map(guard, pretty_expression)
                  |> option.map(doc.prepend(_, doc.from_string(" if ")))
                  |> option.unwrap(or: doc.empty)

               [lolo_patterns, guard, doc.from_string(" -> "), pretty_expression(body)]
               |> doc.concat
            }
            |> doc.join(with: doc.line)

         doc.from_string("case ")
         |> doc.append(subjects)
         |> doc.append_docs([doc.from_string(" {"), doc.line])
         |> doc.append(clauses)
         |> de.nest
         |> doc.append_docs([doc.line, doc.from_string("}")])
      }
      g.BinaryOperator(name, left, right) -> {
         case name == g.DivInt || name == g.RemainderInt || name == g.DivFloat {
            False ->
               [
                  pretty_expression(left),
                  de.nbsp(),
                  pretty_binary_operator(name),
                  de.nbsp(),
                  pretty_expression(right),
               ]
               |> doc.concat
            True -> pretty_div_rem_operator(name, pretty_expression(left), pretty_expression(right))
         }
      }
   }
}

fn pretty_binary_operator(operator: g.BinaryOperator) -> Document {
   case operator {
      g.And -> doc.from_string("&&")
      g.Or -> doc.from_string("||")
      g.Eq -> doc.from_string("==")
      g.NotEq -> doc.from_string("!=")
      g.LtInt -> doc.from_string("<")
      g.LtEqInt -> doc.from_string("<=")
      g.LtFloat -> doc.from_string("<")
      g.LtEqFloat -> doc.from_string("<=")
      g.GtEqInt -> doc.from_string(">=")
      g.GtInt -> doc.from_string(">")
      g.GtEqFloat -> doc.from_string(">=")
      g.GtFloat -> doc.from_string(">")
      g.Pipe -> doc.from_string("|>")
      g.AddInt -> doc.from_string("+")
      g.AddFloat -> doc.from_string("+")
      g.SubInt -> doc.from_string("-")
      g.SubFloat -> doc.from_string("-")
      g.MultInt -> doc.from_string("*")
      g.MultFloat -> doc.from_string("*")
      g.DivInt -> doc.from_string("/")
      g.DivFloat -> doc.from_string("/")
      g.RemainderInt -> doc.from_string("%")
      g.Concatenate -> doc.from_string("+")
   }
}

fn pretty_div_rem_operator(operator: g.BinaryOperator, left: Document, right: Document) -> Document {
   doc.concat([
      doc.from_string(case operator {
         g.DivInt -> bal.k_div_int
         g.RemainderInt -> bal.k_rem_int
         g.DivFloat -> bal.k_div_float
         _ -> ""
      }),
      left,
      doc.from_string(", "),
      right,
      doc.from_string(")"),
   ])
}

fn pretty_bitstring(
   segments: List(#(as_doc, List(g.BitStringSegmentOption(as_doc)))),
   to_doc: fn(as_doc) -> Document,
) -> Document {
   panic as "implement pretty_bitstring"
   let segments =
      {
         use segment <- list.map(segments)
         let #(expr, options) = segment
         let options =
            options
            |> list.map(pretty_bitstring_option(_, to_doc))
            |> doc.join(with: doc.from_string("-"))

         [to_doc(expr), doc.from_string(":"), options]
         |> doc.concat
      }
      |> doc.concat_join([doc.from_string(","), doc.flex_break(" ", "")])

   [doc.from_string("<<"), doc.soft_break]
   |> doc.concat
   |> doc.append(segments)
   |> de.nest
   |> doc.append_docs([de.trailing_comma(), doc.from_string(">>")])
   |> doc.group
}

fn pretty_bitstring_option(
   bitstring_option: g.BitStringSegmentOption(as_doc),
   fun: fn(as_doc) -> Document,
) -> Document {
   panic as "implement pretty_bistring_option"
   case bitstring_option {
      g.BinaryOption -> doc.from_string("binary")
      g.IntOption -> doc.from_string("int")
      g.FloatOption -> doc.from_string("float")
      g.BitStringOption -> doc.from_string("bit_string")
      g.Utf8Option -> doc.from_string("utf8")
      g.Utf16Option -> doc.from_string("utf16")
      g.Utf32Option -> doc.from_string("utf32")
      g.Utf8CodepointOption -> doc.from_string("utf8_codepoint")
      g.Utf16CodepointOption -> doc.from_string("utf16_codepoint")
      g.Utf32CodepointOption -> doc.from_string("utf32_codepoint")
      g.SignedOption -> doc.from_string("signed")
      g.UnsignedOption -> doc.from_string("unsigned")
      g.BigOption -> doc.from_string("big")
      g.LittleOption -> doc.from_string("little")
      g.NativeOption -> doc.from_string("native")
      g.SizeValueOption(n) ->
         [doc.from_string("size("), fun(n), doc.from_string(")")]
         |> doc.concat
      g.SizeOption(n) -> doc.from_string(int.to_string(n))
      g.UnitOption(n) -> doc.from_string("unit(" <> int.to_string(n) <> ")")
   }
}

// Pretty print an anonymous functions.
// For a top level function, see `pretty_function`
fn pretty_fn(
   arguments: List(g.FnParameter),
   return: Option(g.Type),
   body: List(g.Statement),
) -> Document {
   panic as "implement pretty_fn"
   let arguments =
      arguments
      |> list.map(pretty_fn_parameter)
      |> de.comma_separated_in_parentheses

   let body = case body {
      // This never actually happens because the compiler will insert a todo
      [] -> doc.from_string("{}")

      // If there's only one statement, it might be on one line
      [statement] ->
         doc.concat([doc.from_string("{"), doc.space])
         |> doc.append(pretty_statement(statement, False, False))
         |> de.nest
         |> doc.append_docs([doc.space, doc.from_string("}")])
         |> doc.group

      // Multiple statements always break to multiple lines
      multiple_statements -> pretty_block(multiple_statements, False)
   }

   [doc.from_string("fn"), arguments, pretty_return_signature(return, False), de.nbsp(), body]
   |> doc.concat
}

// Pretty print an anonymous function parameter.
// For a top level function parameter, see `pretty_function_parameter`
fn pretty_fn_parameter(fn_parameter: g.FnParameter) -> Document {
   panic as "implement pretty_fn_parameter"
   let g.FnParameter(name, type_) = fn_parameter
   [pretty_type_annotation(type_, False), pretty_assignment_name(name)]
   |> doc.concat
}

// Type Alias -------------------------------------

fn pretty_type_alias(type_alias: g.Definition(g.TypeAlias)) -> Document {
   use g.TypeAlias(name, publicity, parameters, aliased) <- pretty_definition(type_alias)

   let parameters = case parameters {
      [] -> doc.empty
      _ -> {
         panic as "implement parameters"
         parameters
         |> list.map(doc.from_string)
         |> de.comma_separated_in_parentheses
      }
   }

   pretty_public(publicity)
   |> doc.append(doc.from_string(bal.k_type_ <> name))
   |> doc.append(parameters)
   |> doc.append(doc.line)
   |> de.nest
   |> doc.append(pretty_type(aliased))
   |> doc.append(de.semicolon())
}

// Type -------------------------------------------------

// TODO: Implement pretty_type
fn pretty_type(type_: g.Type) -> Document {
   case type_ {
      g.NamedType(name, module, parameters) -> {
         let parameters = case parameters {
            [] -> doc.empty
            _ ->
               parameters
               |> list.map(pretty_type)
               |> de.comma_separated_in_parentheses
         }

         let module =
            module
            |> option.map(fn(mod) { mod <> ":" })
            |> option.map(doc.from_string)

         case module {
            Some(value) ->
               value
               |> doc.append(doc.from_string(name))
               |> doc.append(parameters)

            None ->
               doc.empty
               |> doc.append(doc.from_string(bal.bal_type(name)))
               |> doc.append(parameters)
         }
      }
      g.TupleType(elements) ->
         elements
         |> list.map(pretty_type)
         |> pretty_tuple
      g.FunctionType(parameters, return) -> {
         doc.from_string(bal.k_function)
         |> doc.append(
            parameters
            |> list.map(pretty_type)
            |> de.comma_separated_in_parentheses,
         )
         |> doc.append(pretty_return_signature(Some(return), False))
      }
      g.VariableType(name) -> doc.from_string(name)
   }
}

fn pretty_custom_type(type_: g.Definition(g.CustomType)) -> Document {
   panic as "implement pretty_custom_type"
   use g.CustomType(name, publicity, opaque_, parameters, variants) <- pretty_definition(type_)

   // Opaque or not
   let opaque_ = case opaque_ {
      True -> "opaque "
      False -> ""
   }

   let parameters = case parameters {
      [] -> doc.empty
      _ -> {
         parameters
         |> list.map(doc.from_string)
         |> de.comma_separated_in_parentheses
      }
   }

   // Custom types variants
   let variants =
      variants
      |> list.map(pretty_variant)
      |> doc.join(with: doc.line)

   let type_body =
      doc.concat([doc.from_string("{"), doc.line])
      |> doc.append(variants)
      |> de.nest
      |> doc.append_docs([doc.line, doc.from_string("}")])
      |> doc.group

   [
      pretty_public(publicity),
      doc.from_string(opaque_ <> bal.k_type_ <> name),
      parameters,
      de.nbsp(),
      type_body,
   ]
   |> doc.concat
}

fn pretty_variant(variant: g.Variant) -> Document {
   panic as "implement pretty_variant"
   let g.Variant(name, fields) = variant
   fields
   |> list.map(pretty_field(_, pretty_type))
   |> de.comma_separated_in_parentheses
   |> doc.prepend(doc.from_string(name))
}

fn pretty_field(field: g.Field(a), a_to_doc: fn(a) -> Document) -> Document {
   let g.Field(label, type_) = field
   case label {
      Some(l) -> {
         panic as "implement pretty_field"
         doc.from_string(l <> ": ")
      }
      None -> doc.empty
   }
   |> doc.append(a_to_doc(type_))
}

// Imports --------------------------------------------

// Pretty print an import statement
fn pretty_import(import_: g.Definition(g.Import), module_name: String) -> Document {
   use g.Import(module, alias, _, _) <- pretty_definition(import_)

   let alias_str: Option(String) = case alias {
      Some(_) -> alias
      None -> Some(result.unwrap(list.last(string.split(module, "/")), module))
   }

   doc.from_string(bal.k_import_ <> module_name <> "." <> string.replace(module, "/", "_"))
   |> doc.append(pretty_as(alias_str))
   |> doc.append(de.semicolon())
}

fn pretty_unqualified_imports(imports: List(g.Definition(g.Import))) -> List(Document) {
   imports
   |> list.map(fn(import_) {
      use g.Import(module, _, unqualified_types, unqualified_values) <- pretty_definition(import_)

      let mp: String = result.unwrap(list.last(string.split(module, "/")), module)

      doc.concat([
         unqualified_values
            |> list.map(fn(uq) { de.gen_uimport(mp, uq.name, uq.alias, bal.k_final_var_, " = ") })
            |> doc.join(doc.line),
         unqualified_types
            |> list.map(fn(uq) { de.gen_uimport(mp, uq.name, uq.alias, bal.k_type_, " ") })
            |> doc.join(doc.line),
      ])
   })
   |> list.filter(fn(uq) { doc.to_string(uq, bal.max) != "" })
}

// --------- Little Pieces -------------------------------

// Prints the pub keyword
fn pretty_public(publicity: g.Publicity) -> Document {
   case publicity {
      g.Public -> doc.from_string(bal.k_public_)
      g.Private -> doc.empty
   }
}

// Simply prints an assignment name normally or prefixed with
// an underscore if it is unused
fn pretty_assignment_name(assignment_name: g.AssignmentName) -> Document {
   case assignment_name {
      g.Named(str) -> doc.from_string(str)
      // TODO: "_" <> str
      g.Discarded(str) -> doc.from_string(str)
   }
}

// Pretty prints an optional type annotation
fn pretty_type_annotation(type_: Option(g.Type), is_final: Bool) -> Document {
   let final: Document = case is_final {
      True -> doc.from_string(bal.k_final_)
      False -> doc.empty
   }
   case type_ {
      Some(t) ->
         [final, pretty_type(t), de.nbsp()]
         |> doc.concat
      None ->
         [final, doc.from_string(bal.k_var), de.nbsp()]
         |> doc.concat
   }
}

// Pretty return signature
fn pretty_return_signature(type_: Option(g.Type), is_main: Bool) -> Document {
   // if it's main() function
   case is_main {
      True -> doc.from_string(bal.k__returns_error)
      False ->
         case type_ {
            Some(t) ->
               [doc.from_string(bal.k__returns_), pretty_type(t)]
               |> doc.concat
            None -> {
               panic as "implement pretty_return_signature"
               doc.from_string(bal.k__returns_nil)
            }
         }
   }
}

// Pretty print "as" keyword alias
fn pretty_as(name: Option(String)) -> Document {
   case name {
      Some(str) -> doc.from_string(" as " <> str)
      None -> doc.empty
   }
}
