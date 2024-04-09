pub const k_gleam_: String = "gleam_"

pub const k_gleam_ignore: String = "type gleam_ignore gleam_:Ignore;"

pub const k_final_: String = "final "

pub const k_var_: String = "var "

pub const k_var: String = "var"

pub const k_ignore_var: String = "_ = "

pub const k_function_: String = "function "

pub const k_return_: String = "return "

pub const k_return_main: String = "return gleam_:mainReturn("

pub const k__returns_error: String = " returns error?"

pub const k__returns_: String = " returns "

pub const k__returns_nil: String = " returns ()"

pub const k_public_: String = "public "

pub const k_final_var_: String = "final var "

pub const k_div_int: String = "gleam_:divideInt("

pub const k_rem_int: String = "gleam_:remainderInt("

pub const k_div_float: String = "gleam_:divideFloat("

pub const k_type_: String = "type "

pub const k_function: String = "function"

pub const k_import_: String = "import "

pub const k_const_: String = "const "

pub const k_arr_s: String = "[*]"

pub const max: Int = 101

pub fn bal_var(str: String) -> String {
   case str {
      "Nil" -> "()"
      "True" -> "true"
      "False" -> "false"
      "abstract"
      | "any"
      | "anydata"
      | "async"
      | "boolean"
      | "break"
      | "byte"
      | "check"
      | "checkpanic"
      | "class"
      | "const"
      | "continue"
      | "decimal"
      | "declare"
      | "distinct"
      | "enum"
      | "error"
      | "export"
      | "float"
      | "foreach"
      | "from"
      | "function"
      | "future"
      | "handle"
      | "if"
      | "import"
      | "in"
      | "int"
      | "interface"
      | "is"
      | "isolated"
      | "json"
      | "let"
      | "map"
      | "module"
      | "namespace"
      | "never"
      | "new"
      | "null"
      | "panic"
      | "readonly"
      | "return"
      | "service"
      | "string"
      | "trap"
      | "type"
      | "typedesc"
      | "var"
      | "where"
      | "xml" -> "'" <> str
      _ -> str
   }
}

pub fn bal_type(name: String) -> String {
   case name {
      // 64 bit 
      "Int" -> "int"
      "Float" -> "float"
      "Bool" -> "boolean"
      "Nil" -> "()"
      "String" -> "string"
      "Result" -> "gleam_:" <> name
      _ -> name
   }
}
