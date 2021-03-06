{
  open Parser
  exception LexError of string

  let verify_escape s =
  if String.length s = 1 then (String.get s 0)
  else
  match s with
     "\\n" -> '\n'
   | "\\t" -> '\t'
   | "\""  -> '"'
   | c     -> raise (Failure("unsupported character " ^ c))
}

(* Regular Definitions *)

let digit = ['0'-'9']
let decimal = ((digit+ '.' digit*) | ('.' digit+))

(* Regular Rules *)

rule token = parse
   | eof                       { EOF }
   | [" " "\n" "\t"]           { token lexbuf }
   | ";"                       { TERMINATION }
   | ";;"                      { block_comment lexbuf }

   | "("                       { LPAREN }
   | ")"                       { RPAREN }
   | "{"                       { LBRACE }
   | "}"                       { RBRACE }
   | "]"                       { RBRACKET }
   | "["                       { LBRACKET }

   | "+"                       { PLUS }
   | "-"                       { MINUS }
   | "*"                       { TIMES }
   | "/"                       { DIVIDE }
   | "%"                       { MOD }

   | ":"                       { COLON }
   | ","                       { COMMA }
   | "="                       { ASSIGN }
   | "->"                      { ARROW }
   | "^"                       { CONCAT }
   | "."                       { ACCESS }

   | "=="                      { EQ }
   | "!="                      { NEQ }
   | "<"                       { LT }
   | "<="                      { LEQ }
   | ">"                       { GT }
   | ">="                      { GEQ }
   | "!"                       { NOT }
   | "&&"                      { AND }
   | "||"                      { OR }

   | "if"                      { IF }
   | "else"                    { ELSE }

   | "map"                     { MAP }
   | "find_many"               { FINDMANY }

   | "fn"                      { FUNCTION}
   | "return"                  { RETURN }

   | "in"                      { IN }

   | "^+"                      { GRAPH_INSERT }
   | "^-"                      { GRAPH_REMOVE }
   | "[+]"                     { DATA_INSERT }
   | "[-]"                     { DATA_REMOVE }
   | "neighbors"               { NEIGHBORS }

   | "Graph"                   { GRAPH }
   | "Rel"                     { REL }
   | "Node"                    { NODE }
   | "List"                    { LIST }
   | "Int"                     { INT }
   | "Double"                  { DOUBLE }
   | "String"                  { STRING }
   | "Bool"                    { BOOL }
   | "Void"                    { VOID }
   | "_"                       { ANY }

   | digit+ as lit             { INT_LITERAL(int_of_string lit) }
   | decimal as lit            { DOUBLE_LITERAL(float_of_string lit) }
   | '"' ([^'"']* as lit) '"'  { STRING_LITERAL(lit) }
   | ("true" | "false") as lit { BOOL_LITERAL(bool_of_string lit) }

   | ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']* as lit { ID(lit) }  (*every ID should start with a letter*)
   | _ as char { raise (Failure("illegal character " ^ Char.escaped char)) }

and block_comment = parse
  | ";;" { token lexbuf }
  | eof  { raise (LexError("unterminated block_comment!")) }
  | _    { block_comment lexbuf }

