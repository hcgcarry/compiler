literal
 : INT_LIT { printf ("type %s value %d" , "int32" , $<i_val >1); }
 | FLOAT_LIT { printf ("type %s value %f" , "float32" , $<f_val >1); }
;


Type = TypeName | ArrayType
TypeName = "int32" | "float32" | "string" | "bool"
ArrayType = "[" Expression "]" Type


Expression = UnaryExpr | Expression binary_op Expression
UnaryExpr = PrimaryExpr | unary_op UnaryExpr
binary_op = "||" | "&&" | cmp_op | add_op | mul_op
cmp_op = "==" | "!=" | "<" | "<=" | ">" | ">="
add_op = "+" | "-"
mul_op = "*" | "/" | "%"
unary_op = "+" | "-" | "!"


PrimaryExpr = Operand | IndexExpr | ConversionExpr
Operand = Literal | identifier | "(" Expression ")"
Literal = int_lit | float_lit | bool_lit | string_lit

IndexExpr = PrimaryExpr "[" Expression "]"

ConversionExpr = Type "(" Expression ")"

Statement =
 DeclarationStmt NEWLINE
 | SimpleStmt NEWLINE
 | Block NEWLINE
 | IfStmt NEWLINE
 | ForStmt NEWLINE
 | PrintStmt NEWLINE
 | NEWLINE
SimpleStmt = AssignmentStmt | ExpressionStmt | IncDecStmt

DeclarationStmt = "var" identifier Type [ "=" Expression ]


AssignmentStmt = Expression assign_op Expression
assign_op = "=" | "+=" | "-=" | "*=" | "/=" | "%="

ExpressionStmt = Expression

IncDecStmt = Expression ( "++" | "--" )
Block = "{" StatementList "}"
StatementList = { Statement }

IfStmt = "if" Condition Block [ "else" ( IfStmt | Block ) ]
Condition = Expression

ForStmt = "for" ( Condition | ForClause ) Block
ForClause = InitStmt ";" Condition ";" PostStmt
InitStmt = SimpleStmt
PostStmt = SimpleStmt

PrintStmt = ( "print" | "println" ) "(" Expression ")"
