/*	Definition section */
%{

void print_assign_to_literal(char* type,char* operator);
int check_symbol_presence(char * name,int scope);
void print_INT_LIT(int num);
char* identifierGetType(char* name,int scope);
char* binary_typecheck(char* type1,char* operator,char* type2);
void printConversionType(char* convertTo,char* convertFrom);
void clean_symbol_table(int scope);
void checkTypeBool(char* type);

#define YYDEBUG 0
//#define dbug
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
symbol_table_entry_ptr lookup_symbol_multiScope(char *name,int scope);
void insert_symbol(char* name,char* Type,char* element_type);
void dump_symbol(int scope);
symbol_table_entry_ptr CreateSymbolTableEntry(int index,char* name,char* Type,int address,int lineno,char* element_type, int scope);
symbol_table_entry_ptr lookup_symbol(char* name,int scope);
void sort_symbol_table_by_index(symbol_table_entry_ptr *sortArray,int scope,int entry_count);
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

%left <s_val> LOR
%left <s_val> LAND 
%left <s_val> GEQ LEQ EQL NEQ '>' '<' 
%left <s_val> '+' '-' 
%left <s_val> '*' '/' '%'
%left INC DEC

/* Token with return, which need to sepcify type */
%token <s_val>IDENTIFIER
%token <s_val> STRING_LIT
%token <i_val> INT_LIT
%token <f_val> FLOAT_LIT
%type <s_val> unary_op Boolean Expression UnaryExpr PrimaryExpr Operand Literal IndexExpr ConversionExpr assign_op


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
    : PrimaryExpr {$$=$1;}
    | unary_op UnaryExpr {printf("%s\n",$1);$$=$2;}
;

IncDecStmt
    : Expression  INC {printf("INC\n");}
    | Expression  DEC {printf("DEC\n");}
;

Expression 
    : UnaryExpr {$$=$1;}
    | Expression LAND Expression {$$=binary_typecheck($1,"LAND",$3);printf("LAND\n");}
    | Expression LOR Expression {$$=binary_typecheck($1,"LOR",$3);printf("LOR\n");}
    | Expression EQL Expression {$$="bool";binary_typecheck($1,"EQL",$3);printf("EQL\n");}
    | Expression NEQ Expression {$$="bool";binary_typecheck($1,"NEQ",$3);printf("NEQ\n");}
    | Expression GEQ Expression {$$="bool";binary_typecheck($1,"GEQ",$3);printf("GEQ\n");}
    | Expression LEQ Expression {$$="bool";binary_typecheck($1,"LEQ",$3);printf("LEQ\n");}
    | Expression '<' Expression {$$="bool";binary_typecheck($1,"LSS",$3);printf("LSS\n");}
    | Expression '>' Expression {$$="bool";binary_typecheck($1,"GTR",$3);printf("GTR\n");}
    | Expression '+' Expression {$$=binary_typecheck($1,"ADD",$3);printf("ADD\n");}
    | Expression '-' Expression {$$=binary_typecheck($1,"SUB",$3);printf("SUB\n");}
    | Expression '*' Expression {$$=binary_typecheck($1,"MUL",$3);printf("MUL\n");}
    | Expression '/' Expression {$$=binary_typecheck($1,"QUO",$3);printf("QUO\n");}
    | Expression '%' Expression {$$=binary_typecheck($1,"REM",$3);printf("REM\n");}
;


unary_op 
    : '+' {$$="POS";}
    | '-' {$$="NEG";}
    | '!' {$$="NOT";}
;

PrimaryExpr 
    : Operand {$$=$1;}
    | IndexExpr {$$=$1;}
    | ConversionExpr {$$=$1;}
;


Operand 
    : Literal {$$=$1;}
    | IDENTIFIER {printVariable($1);$$=identifierGetType($1,symbol_table_scope);}
    | Boolean {$$="bool";}
    | '(' Expression ')' {$$=$2;}
;

Boolean
    : TRUE {printf("TRUE\n");}
    | FALSE {printf("FALSE\n");}
;

Literal 
    : INT_LIT {printf("INT_LIT %d\n",$1);$$="int32";}
    | FLOAT_LIT {printf("FLOAT_LIT %f\n",$1);$$="float32";}
    | STRING_LIT {printf("STRING_LIT %s\n",$1);$$="string";}
;

/* prinmaryexpr 換成IDENTIFIER比較好*/
IndexExpr 
    : PrimaryExpr '[' Expression ']' {$$=$1;}
;


ConversionExpr 
    : Type '(' Expression ')' {printConversionType($1,$3);$$=$1;}
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
    : Expression assign_op Expression {binary_typecheck($1,$2,$3); printf("%s\n",$2);}
    | Literal assign_op Expression {print_assign_to_literal($1,$2);}
;

assign_op 
    : '=' {$$="ASSIGN";}
    | ADD_ASSIGN {$$="ADD_ASSIGN";}
    | SUB_ASSIGN {$$="SUB_ASSIGN";}
    | MUL_ASSIGN {$$="MUL_ASSIGN";}
    | QUO_ASSIGN {$$="QUO_ASSIGN";}
    | REM_ASSIGN {$$="REM_ASSIGN";}

;



Block 
    : '{'  {symbol_table_scope ++; }
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

;
ElseIfList
    : ELSE IF Condition Block
    | ELSE IF Condition Block Else_stmt
    | ELSE IF Condition Block ElseIfList
;

Else_stmt
    : ELSE Block
;

 
Condition 
    : Expression {checkTypeBool($1);}
;


ForStmt 
    : FOR Condition Block
    | FOR ForClause Block
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
    : PRINT '(' Expression ')' {printf("PRINT %s\n",$3);}
    | PRINTLN '(' Expression ')' {printf("PRINTLN %s\n",$3);}
;





%%
int main(int argc, char** argv)
{
    # if YYDEBUG
        yydebug=1;
    # endif
    yylineno = 0;
    create_symbol();

    yyparse();
	printf("Total lines: %d\n",yylineno);

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
    symbol_table_entry_ptr tmp;
    tmp=lookup_symbol(name,symbol_table_scope);
    if(tmp!=NULL){
        printf("error:%d: %s redeclared in this block. previous declaration at line %d\n",yylineno,name,tmp->lineno);
    }
    else{
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
}
int check_symbol_presence(char * name,int scope){
    symbol_table_entry_ptr tmp;
    tmp=lookup_symbol(name,scope);
    if(tmp==NULL){
        return 0;
    }
    return 1;
}
int check_symbol_presence_multiScope(char * name,int scope){
    symbol_table_entry_ptr tmp;
    for(int i=scope;i>=0;i--){
        tmp=lookup_symbol(name,scope);
        if(tmp!=NULL){
            return 1;
        }
    }
    return 0;
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
    tmp=symbol_table.scope_table[scope][hash_num];
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
    #ifdef dbug
        printf("---------------symbol not found name:%s scope:%d---------------\n",name,scope);
    #endif
    return NULL;
}
symbol_table_entry_ptr lookup_symbol_multiScope(char *name,int scope){
    symbol_table_entry_ptr tmp;
    for(int i=symbol_table_scope;i>=0;i--){
        tmp=lookup_symbol(name,i);
        if(tmp!=NULL) break;
    }
    if(tmp!=NULL){
        return tmp;
    }
    #ifdef dbug
        printf("!!!!!!!!!!!!variable not define\n");
    #endif
    return NULL;

}

/*
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
    clean_symbol_table(scope);
}
*/
void dump_symbol(int scope) {
    printf("> Dump symbol table (scope level: %d)\n", scope);
    printf("%-10s%-10s%-10s%-10s%-10s%s\n",
           "Index", "Name", "Type", "Address", "Lineno", "Element type");
    symbol_table_entry_ptr tmp;
    symbol_table_entry_ptr sortArray[50];
    int stack_top=0;
    
    for(int i=0;i<hash_bucket_num;i++){
        tmp=symbol_table.scope_table[scope][i];
        while(tmp != NULL){

            sortArray[stack_top++]=tmp;
            tmp=tmp->next;
        }
        
    }
    sort_symbol_table_by_index(sortArray,scope,stack_top);
    for(int i=0;i<stack_top;i++){
        tmp=sortArray[i];
        printf("%-10d%-10s%-10s%-10d%-10d%s\n",
        tmp->index,tmp->name,tmp->type,tmp->address,tmp->lineno,tmp->element_type);
        tmp=tmp->next;
    }
    clean_symbol_table(scope);
    symbol_table.symbol_table_length[symbol_table_scope]=0;

}

void sort_symbol_table_by_index(symbol_table_entry_ptr *sortArray,int scope,int entry_count){
    symbol_table_entry_ptr tmp;
    int key_entry_index,compare_entry_index;
    for(int i=1;i<entry_count;i++){
        key_entry_index = sortArray[i]->index;
        for(int j=i-1;j>=0;j--){
            compare_entry_index=sortArray[j]->index;
            if(key_entry_index < compare_entry_index){
                //swap
                tmp=sortArray[j];
                sortArray[j]=sortArray[j+1];
                sortArray[j+1]=tmp;
            }
            else{
                break;
            }
        }
    }
}
void clean_symbol_table(int scope){
    for(int i=0;i<hash_bucket_num;i++){
        symbol_table.scope_table[scope][i]=NULL;
    }
}

void printVariable(char * name){

    symbol_table_entry_ptr tmp;
    tmp=lookup_symbol_multiScope(name,symbol_table_scope);
    if(tmp==NULL){
        printf("error:%d: undefined: %s\n",yylineno+1,name);
    }
    else{
        printf("IDENT (name=%s, address=%d)\n",tmp->name,tmp->address);
    }
}


char* binary_typecheck(char* type1,char* operator,char* type2){
    //assign check if left hand sign is literal
    /*
    if(strcmp(operator,"ASSIGN")==0){
        if(strcmp(type1,"float32")!=0 && strcmp(type1,"int32")!=0){
            convert_LIT_to_type(type1);
            printf("error:%d: cannot assign to %s",yylineno,type1);
            return "LHS is literal";
        }

    }
    */

    char* result=malloc(20*sizeof(char));
    //general case
    //printf("type1:%s operator:%s type2:%s\n",type1,operator,type2);
    if(strcmp(type1,"notDefine") == 0 || strcmp(type2,"notDefine")==0){
        return "notDefine";
    }
    if(strcmp(operator,"REM")==0){
        if(strcmp(type1,"float32") == 0 || strcmp(type2,"float32")==0){
            printf("error:%d: invalid operation: (operator REM not defined on float32)\n",yylineno);
            strcpy(result,"REM error");
        }
        else{
            strcpy(result,"int32");
        }
    }
    else if(strcmp(operator,"LOR")==0){
        if(strcmp(type1,"bool") != 0 || strcmp(type2,"bool")!=0){
            printf("error:%d: invalid operation: (operator LOR not defined on int32)\n",yylineno);
            strcpy(result,"LOR error");
        }
        else{
            strcpy(result,"bool");
        }
    }
    else if(strcmp(operator,"LAND")==0){
        if(strcmp(type1,"bool") != 0 || strcmp(type2,"bool")!=0){
            printf("error:%d: invalid operation: (operator LAND not defined on int32)\n",yylineno);
            strcpy(result,"LAND error");
        }
        else{
            strcpy(result,"bool");
        }
    }
    else{
        if(strcmp(type1,type2)==0){
            strcpy(result,type1); 
        }
        else{
            printf("error:%d: invalid operation: %s (mismatched types %s and %s)\n",yylineno,operator,type1,type2);
            strcpy(result,"type error");
        }
    }
    return result;
}


char* identifierGetType(char* name,int scope){
    symbol_table_entry_ptr tmp;
    //printf("name:%s\n",name);
    tmp=lookup_symbol_multiScope(name,scope);
    if(tmp!=NULL){
        char *result;
        if(strcmp(tmp->type,"array")==0){
            result = tmp->element_type;
        }
        else{
            result=tmp->type;
        }
        return result;
    }
    #ifdef dbug
        printf("!!!!!!!!!!!!!!symbol not found type check failed\n");
    #endif
    return "notDefine";
    
}


void printConversionType(char* convertTo,char* convertFrom){
    /*
    convert_LIT_to_type(convertTo);
    convert_LIT_to_type(convertFrom);
    */
    char to[10],from[10]; 
    if(strcmp(convertTo,"float32")==0){
        strcpy(to,"F");
    }
    else if(strcmp(convertTo,"int32")==0){
        strcpy(to,"I");
    }
    if(strcmp(convertFrom,"float32")==0){
        strcpy(from,"F");
    }
    if(strcmp(convertFrom,"int32")==0){
        strcpy(from,"I");
    }
    printf("%s to %s\n",from,to);
}
void checkTypeBool(char * type){
    if(strcmp(type,"bool")!=0){
        printf("error:%d: non-bool (type %s) used as for condition\n",yylineno+1,type);
    }
}

/*
void convert_LIT_to_type(char* LIT){
    if(strcmp(LIT,"INT_LIT")){
        strcpy(LIT,"int32");
    }
    if(strcmp(LIT,"FLOAT_LIT")){
        strcpy(LIT,"float32");
    }
    if(strcmp(LIT,"STRING_LIT")){
        strcpy(LIT,"string");
    }
}
*/

void print_assign_to_literal(char* type,char* operator){
    //printf("error:%d: cannot %s to %s\n",yylineno,operator,type);
    printf("error:%d: cannot assign to %s\n",yylineno,type);
    printf("%s\n",operator);

}
//error:6: cannot assign to int32