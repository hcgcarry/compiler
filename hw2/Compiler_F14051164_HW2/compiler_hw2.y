/*	Definition section */
%{

void print_INT_LIT(int num);


#define YYDEBUG 1
#include <stdio.h>
#include <string.h>
#include "common.h" //Extern variables that communicate with lex
extern int yylineno;
extern int yylex();
extern FILE *yyin;
extern char* yytext;   // Get current token from lex
extern char buf[256];  // Get current code line from lex
int symbol_table_s;

#define hash_bucket_num 7

// symbol_table
#define total_symbol_table_scope_level_num 10
int symbol_table_scope=0;
struct symbol_table_entry{
	int index;
	char name[20];
	char type[20];
	int address;
	int lineno;
	char element_type[20];
    struct symbol_table_entry* next;
};

typedef struct symbol_table_entry* symbol_table_entry_ptr;
struct total_scope_symbol_table{
    struct symbol_table_entry** scope_table[total_symbol_table_scope_level_num];
    int symbol_table_length[total_symbol_table_scope_level_num];
    int global_address;
} symbol_table;

/* Symbol table function - you can add new function if needed. */
//int lookup_symbol();
void create_symbol();
void insert_symbol(char* name,char* Type,char* element_type);
void dump_symbol(int scope);
symbol_table_entry_ptr CreateSymbolTableEntry(int index,char* name,char* Type,int address,int lineno,char* element_type, int scope);
symbol_table_entry_ptr lookup_symbol(char* name,int scope);
int hash_symbol_table_entry(char* name);
void printVariable(char* name);

//yyerror
void yyerror(char const *s)
{
    printf("\n|-----------------------------------------------|\n");
    printf("| Error found in line %d\n", yylineno +1 );
    printf("| %s", s);
    printf("\n|-----------------------------------------------|\n\n");
}

//test
void printInt(int num);

void printString(char* name);

%}
%union {
    int i_val;
    float f_val;
    char *s_val;
    /* ... */
}



%define parse.error verbose
//%define parse.lac full
%token PRINT PRINTLN
%token IF ELSE FOR
%token '=' ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN QUO_ASSIGN REM_ASSIGN
%token '(' ')' '{' '}' '[' ']' ',' '"'
%token TRUE FALSE RETURN
%token VOID INT FLOAT STRING BOOL
%token VAR NEWLINE

%token LOR
%token LAND 
%left GEQ LEQ EQL NEQ '>' '<' 
%left '+' '-' 
%left '*' '/' '%'
%left INC DEC

/* Token with return, which need to sepcify type */
%token <s_val>IDENTIFIER
%token <s_val> STRING_LIT
%token <i_val> INT_LIT
%token <f_val> FLOAT_LIT
%type <s_val> unary_op binary_op add_op mul_op Boolean cmp_op


/* Nonterminal with return, which need to sepcify type */
%type <s_val> Type TypeName ArrayType 

/* Yacc will start at this nonterminal */
%start Program

/* Grammar section */
%%



Program
    : StatementList {dump_symbol(symbol_table_scope);}
;

DeclarationStmt 
    : VAR IDENTIFIER TypeName  { insert_symbol($2,$3,"-");}
    | VAR IDENTIFIER TypeName  '=' Expression  { insert_symbol($2,$3,"-");}
    | VAR IDENTIFIER ArrayType { insert_symbol($2,"array",$3);}
    | VAR IDENTIFIER ArrayType  '=' Expression { insert_symbol($2,"array",$3);}
;
Type
    : TypeName
    | ArrayType
;


TypeName 
    : INT { $$ = "int32"; }
    | FLOAT { $$ = "float32"; }
    | BOOL  { $$ = "bool"; }
    | STRING { $$ = "string"; }
;


ArrayType 
    : '[' Expression ']' Type  {$$ = $4;}
;


UnaryExpr 
    : PrimaryExpr 
    | unary_op UnaryExpr {printf("%s\n",$1);}
;

IncDecStmt
    : Expression  INC {printf("INC\n");}
    | Expression  DEC {printf("DEC\n");}
;

Expression 
    : UnaryExpr 
    | Expression binary_op Expression {printf("%s\n",$2);}
;


binary_op 
    : LAND {$$="LAND";}
    | LOR {$$="LOR";}
    | cmp_op 
    | add_op 
    | mul_op 
;
cmp_op 
    : EQL {$$="EQL";}
    | NEQ {$$="NEQ";}
    | '<' {$$="LSS";}
    | LEQ {$$="LEQ";}
    | '>' {$$="GTR";}
    | GEQ {$$="GEQ";}
;
add_op 
    : '+' {$$="ADD";}
    | '-' {$$="SUB";}
;
mul_op 
    : '*' {$$="MUL";}
    | '/' {$$="QUO";}
    | '%' {$$="REM";}
;
unary_op 
    : '+' {$$="POS";}
    | '-' {$$="NEG";}
    | '!' {$$="NOT";}
;

PrimaryExpr 
    : Operand 
    | IndexExpr 
    | ConversionExpr 
;


Operand 
    : Literal 
    | IDENTIFIER {printVariable($1);}
    | Boolean
    | '(' Expression ')'
;

Boolean
    : TRUE {printf("TRUE\n");}
    | FALSE {printf("FALSE\n");}
;

Literal 
    : INT_LIT {printf("INT_LIT %d\n",$1);}
    | FLOAT_LIT {printf("FLOAT_LIT %f\n",$1);}
    | STRING_LIT {printf("STRING_LIT %s\n",$1);}
;

/* prinmaryexpr 換成IDENTIFIER比較好*/
IndexExpr 
    : PrimaryExpr '[' Expression ']'
;


ConversionExpr 
    : Type '(' Expression ')';
;

Statement 
    : DeclarationStmt NEWLINE
    | SimpleStmt NEWLINE
    | Block NEWLINE
    | IfStmt NEWLINE
    | ForStmt NEWLINE
    | PrintStmt NEWLINE
    | NEWLINE
;


SimpleStmt 
    : AssignmentStmt 
    | Expression
    | IncDecStmt
;


/* 這邊老師assume LHS input只會有可以存值的 不會有常數之類的*/
AssignmentStmt 
    : Expression assign_op Expression
;

assign_op 
    : '=' 
    | ADD_ASSIGN 
    | SUB_ASSIGN 
    | MUL_ASSIGN 
    | QUO_ASSIGN 
    | REM_ASSIGN
;



Block 
    : '{'  { symbol_table_scope ++; }
    StatementList '}' {dump_symbol(symbol_table_scope); symbol_table_scope --;}
;

StatementList 
    :  Statement 
    |  StatementList Statement
;

IfStmt 
    : IF Condition Block 
    | IF Condition Block  Else_stmt 
    | IF Condition Block ElseIfList 
    | IF Condition Block ElseIfList Else_stmt 

;
ElseIfList
    : ELSE IF Condition Block
    | ELSE IF Condition Block ElseIfList
;
Else_stmt
    : ELSE Block
;


Condition 
    : Expression
;


ForStmt 
    : FOR Condition Block
    | FOR ForClause  Block
;
ForClause 
    : InitStmt ';' Condition ';' PostStmt
;

InitStmt 
    : SimpleStmt
;
PostStmt 
    : SimpleStmt
;

PrintStmt 
    : PRINT '(' Expression ')'
    | PRINTLN '(' Expression ')'
;





%%

/* C code section */

int main(int argc, char** argv)
{
    # if YYDEBUG
        yydebug=1;
    # endif
    yylineno = 0;
    create_symbol();

    yyparse();
	printf("Total lines: %d \n",yylineno);

    return 0;
}


// 用hash table
void create_symbol() { 
    for(int i=0;i<total_symbol_table_scope_level_num;i++){
        symbol_table.scope_table[i]=malloc(sizeof(symbol_table_entry_ptr)*hash_bucket_num);
        for(int j=0;j<hash_bucket_num;j++){
            symbol_table.scope_table[i][j]=NULL;
        }
    }
    symbol_table.global_address=0;

}

void insert_symbol(char* name,char* Type,char* element_type) {
    printf("> Insert {%s} into symbol table (scope level: %d)\n", name, symbol_table_scope);
    //printf("name:%s,type:%s,element_type:%s\n",name,Type,element_type);

    //create sumbol_table_entry
    symbol_table_entry_ptr tmp_symbol_table_entry=\
        CreateSymbolTableEntry(symbol_table.symbol_table_length[symbol_table_scope]++,\
        name,Type,symbol_table.global_address++, yylineno,element_type, symbol_table_scope);

    int hash_num=hash_symbol_table_entry(name);
    //insert into symbo_table
    tmp_symbol_table_entry -> next=symbol_table.scope_table[symbol_table_scope][hash_num];
    symbol_table.scope_table[symbol_table_scope][hash_num]=tmp_symbol_table_entry;
    
}
int hash_symbol_table_entry(char* name){
    int hash_num=0;
    char* tmp=name;
    while(*tmp){
        hash_num+=*tmp;
        tmp++;
    }
    hash_num=hash_num%hash_bucket_num;
    return hash_num;
    
}

symbol_table_entry_ptr CreateSymbolTableEntry(int index,char* name,char* Type,int address,
int lineno,char* element_type, int scope){

    symbol_table_entry_ptr tmp_symbol_table_entry=malloc(sizeof(struct symbol_table_entry));
    tmp_symbol_table_entry-> index=index;
    strcpy(tmp_symbol_table_entry-> name,name);
    strcpy(tmp_symbol_table_entry-> type,Type);
    tmp_symbol_table_entry-> address=address;
    tmp_symbol_table_entry-> lineno=lineno;
    strcpy(tmp_symbol_table_entry-> element_type,element_type);
    return tmp_symbol_table_entry;

}

/*
int lookup_symbol(char* name,int scope){

    int hash_num=hash_symbol_table_entry(name);
    symbol_table_entry_ptr tmp;
    tmp=symbol_table[symbol_table_scope][hash_num];
    while(tmp !=NULL){
        if(strcmp(tmp->name,name)){
            return 1;
        }
        else {
            tmp=tmp->next;
        }
    }
    return 0;
}
*/
symbol_table_entry_ptr lookup_symbol(char* name,int scope){
    //printf("enter lookup\n");

    int hash_num=hash_symbol_table_entry(name);
    //printf("enter hash\n");
    symbol_table_entry_ptr tmp;
    tmp=symbol_table.scope_table[symbol_table_scope][hash_num];
    //printf("get tmp \n");
    while(tmp !=NULL){
    //printf("entry while\n");
        if(strcmp(tmp->name,name) == 0){
        //printf("compare \n");
            return tmp;
        }
        else {
            tmp=tmp->next;
        }
    }
    return NULL;
}
void dump_symbol(int scope) {
    printf("> Dump symbol table (scope level: %d)\n", scope);
    printf("%-10s%-10s%-10s%-10s%-10s%s\n",
           "Index", "Name", "Type", "Address", "Lineno", "Element type");
    symbol_table_entry_ptr tmp;
    
    for(int i=0;i<hash_bucket_num;i++){
        tmp=symbol_table.scope_table[scope][i];
        while(tmp != NULL){
            printf("%-10d%-10s%-10s%-10d%-10d%s\n",
            tmp->index,tmp->name,tmp->type,tmp->address,tmp->lineno,tmp->element_type);
            tmp=tmp->next;
        }
    }
}

void printInt(int num){
    printf("------------int : %d\n",num);
}
void printString(char* name){
    printf("***************address:%p***********\n",(void*)name);
    printf("------------name: %s\n",name);
}
void print_INT_LIT(int num){
    printf("INT_LIT %d\n",num);
}
void printVariable(char * name){
    //printf("name:%s\n",name);
    symbol_table_entry_ptr tmp;
    tmp=lookup_symbol(name,symbol_table_scope);
    printf("IDENT (name=%s, address=%d)\n",tmp->name,tmp->address);
}