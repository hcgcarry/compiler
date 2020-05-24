/*	Definition section */
%{
#define YYDEBUG 1
//#define dbug 1
#include "common.h" //Extern variables that communicate with lex
#include <string.h>
int HAS_ERROR = 0;
FILE *file;
//for one param
int for_oneParam_index[10];
int for_oneParam_level=0;

//for three param
int for_threeParam_level=0;
int for_threeParam_index[10];


int if_exit_index[10];
int if_false_index[10];
int if_lable_level=0;
void for_threeParam_end();
void for_threeParam_AfterPostStmt();
void for_threeParam_AfterconditionStmt();
void for_threeParam_AfterInitStmt();
void for_oenParam_end();
void for_oneParam_afterCondition();
void for_oneParam_head();
int check_is_literal(char* tokenType);
void forAfterCondition();
void forEnd();
void forBegin();
void if_array_print(tokenPtr operand);
void printDeclarAssign(tokenPtr LHS,char* operator,tokenPtr RHS);
void filePrintToken(tokenPtr token);
void printToken(tokenPtr token);
void ifAfterCondition();
void ifEnd();
void ifAfterBlock();
void debugPrintString(char* name);
int check_is_relation_operator(char* operator);
void printBinaryOperator();
void initialClassWrite();
void endClassWrite();
void print_assign_to_literal(char* type,char* operator);
int check_symbol_presence(char * name,int scope);
void print_INT_LIT(int num);
char* identifierGetType(char* name,int scope);
char* binary_typecheck(tokenPtr operand1,char* operator,tokenPtr operand2);
void printConversionType(char* convertTo,char* convertFrom);
void clean_symbol_table(int scope);
void checkTypeBool(char* type);
void printPrint(char* printOrPrintln,char* type);
void printIndexExpr(tokenPtr identifier,tokenPtr index);
void printVariableDeclarationStmt(tokenPtr identifier,char* type);
void printRelationCode(char* operator,char* type);
void printArrayDeclarationStmt(tokenPtr identifier,char* type);
void printOperatorCode(char* operator,char* type);
void printIncDecStmt(tokenPtr operand,char* operator);
void printAssign(tokenPtr LHS,char* operator,tokenPtr RHS);
void printUnaryOperator(char* operator,tokenPtr token_ptr);
void printBinaryOperator(tokenPtr operand1,char* operator,tokenPtr operand2);
void printStoreVariable(char* variableName);
int getVariableGlobalAddress(char* variableName);
void printLoadVariable(char* variableName);
void printLoadOperand(tokenPtr token_ptr);
void endClassWrite();
void initialClassWrite();

//#define dbug
extern int yylineno;
extern int yylex();
extern FILE *yyin;
extern char* yytext;   // Get current token from lex
extern char buf[256];  // Get current code line from lex
int symbol_table_s;
int jump_label_index=0;
#define hash_bucket_num 7
int if_exit_index[10];
int if_false_index[10];

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
/*
%union {
    int i_val;
    float f_val;
    char *s_val;
}

*/


%union {
    char *s_val;
    tokenPtr token_ptr;
}



%define parse.error verbose
//%define parse.lac full
%token PRINT PRINTLN
%token IF ELSE FOR
%token '=' ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN QUO_ASSIGN REM_ASSIGN
%token '(' ')' '{' '}' '[' ']' ',' '"'
%token RETURN
%token VOID INT FLOAT STRING BOOL
%token VAR NEWLINE

%left <s_val> LOR
%left <s_val> LAND 
%left <s_val> GEQ LEQ EQL NEQ '>' '<' 
%left <s_val> '+' '-' 
%left <s_val> '*' '/' '%'
%left INC DEC

/* Token with return, which need to sepcify type */
%token <token_ptr>IDENTIFIER TRUE FALSE
%token <token_ptr> STRING_LIT
%token <token_ptr> INT_LIT
%token <token_ptr> FLOAT_LIT
%type <token_ptr> Boolean Expression UnaryExpr PrimaryExpr Operand Literal IndexExpr 


/* Nonterminal with return, which need to sepcify type */
%type <s_val> Type TypeName ArrayType unary_op assign_op

/* Yacc will start at this nonterminal */
%start Program

/* Grammar section */
%%



Program
    : StatementList {dump_symbol(symbol_table_scope);}
;

DeclarationStmt 
    : VAR IDENTIFIER TypeName  { insert_symbol($2->tokenValue,$3,"-");printVariableDeclarationStmt($2,$3);}
    | VAR IDENTIFIER TypeName  '=' Expression  { insert_symbol($2->tokenValue,$3,"-");printDeclarAssign($2,"ASSIGN",$5);}
    | VAR IDENTIFIER ArrayType { insert_symbol($2->tokenValue,"array",$3);printArrayDeclarationStmt($2,$3);}
;
Type
    : TypeName 
    | ArrayType
;


TypeName 
    : INT { $$ = "int32";}
    | FLOAT { $$ = "float32"; }
    | BOOL  { $$ = "bool"; }
    | STRING { $$ = "string"; }
;


ArrayType 
    : '[' Expression ']' Type  {$$ = $4;}
;


UnaryExpr 
    : PrimaryExpr {$$=$1;}
    | unary_op UnaryExpr {$$=$2;
     ;printUnaryOperator($1,$2);debugPrintString($1);}
;

IncDecStmt
    : Expression  INC {printIncDecStmt($1,"INC");debugPrintString("INC");}
    | Expression  DEC {printIncDecStmt($1,"DEC");debugPrintString("DEC");}
;

Expression 
    : UnaryExpr {$$=$1;if_array_print($1);}
    | Expression LAND Expression {
    $$->type=binary_typecheck($1,"LAND",$3);printBinaryOperator($1,"LAND",$3);}
    | Expression LOR Expression {
    $$->type=binary_typecheck($1,"LOR",$3);printBinaryOperator($1,"LOR",$3);}

    | Expression EQL Expression {
    binary_typecheck($1,"EQL",$3);printBinaryOperator($1,"EQL",$3);$$->type="bool";}
    | Expression NEQ Expression {
    binary_typecheck($1,"NEQ",$3);printBinaryOperator($1,"NEQ",$3);$$->type="bool";}
    | Expression GEQ Expression {
    binary_typecheck($1,"GEQ",$3);printBinaryOperator($1,"GEQ",$3);$$->type="bool";}
    | Expression LEQ Expression {
    binary_typecheck($1,"LEQ",$3);printBinaryOperator($1,"LEQ",$3);$$->type="bool";}
    | Expression '<' Expression {
    binary_typecheck($1,"LSS",$3);printBinaryOperator($1,"LSS",$3);$$->type="bool";}
    | Expression '>' Expression {
    binary_typecheck($1,"GTR",$3);printBinaryOperator($1,"GTR",$3);$$->type="bool";}

    | Expression '+' Expression {
    $$->type=binary_typecheck($1,"ADD",$3);printBinaryOperator($1,"ADD",$3);}
    | Expression '-' Expression {
    $$->type=binary_typecheck($1,"SUB",$3);printBinaryOperator($1,"SUB",$3);}
    | Expression '*' Expression {
    $$->type=binary_typecheck($1,"MUL",$3);printBinaryOperator($1,"MUL",$3);}
    | Expression '/' Expression {
    $$->type=binary_typecheck($1,"QUO",$3);printBinaryOperator($1,"QUO",$3);}
    | Expression '%' Expression {
    $$->type=binary_typecheck($1,"REM",$3);printBinaryOperator($1,"REM",$3);}


;



unary_op 
    : '+' {$$="POS";}
    | '-' {$$="NEG";}
    | '!' {$$="NOT";}
;

PrimaryExpr 
    : Operand {$$=$1;}
    | IndexExpr {$$=$1;}
;


Operand 
    : Literal {$$=$1;printLoadOperand($1);}
    | IDENTIFIER {$$=$1;
    $$->type=identifierGetType($1->tokenValue,symbol_table_scope);
    printVariable($$->tokenValue);
    if(strcmp($$->type,"notDefine")){printLoadOperand($1);};}
    | Boolean {$$=$1;printLoadOperand($1);}
    | '(' Expression ')' {$$=$2;}
;

Boolean
    : TRUE {$$=$1;}
    | FALSE {$$=$1;}
;

Literal 
    : INT_LIT 
    | FLOAT_LIT 
    | STRING_LIT 
;

/* prinmaryexpr 換成IDENTIFIER比較好*/
IndexExpr 
    : PrimaryExpr '[' Expression ']' {$$=$1;}
;


Expression
    : Type '(' Expression ')' {printConversionType($1,$3->type);$$=$3;$$->type=$1;}
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
    : UnaryExpr assign_op Expression {binary_typecheck($1,$2,$3);printAssign($1,$2,$3);}
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
    : If_condition {ifEnd();}
    | If_condition ELSE IfStmt 
    | If_condition ELSE {if_lable_level++;} Block {if_lable_level--;ifEnd();}

;

If_condition
    : IF Condition {ifAfterCondition();if_lable_level++;} Block {if_lable_level--;ifAfterBlock();}
 
Condition 
    : Expression {checkTypeBool($1->type);}
;

ForClause 
    : InitStmt {for_threeParam_AfterInitStmt();} 
    ';' Condition {for_threeParam_AfterconditionStmt();}';' 
    PostStmt {for_threeParam_AfterPostStmt();}
;

ForStmt 
    : ForHead Condition {for_oneParam_afterCondition();for_oneParam_level++;} 
    Block {for_oneParam_level--; for_oenParam_end();}
    | ForHead ForClause {for_threeParam_level++;} 
    Block {for_threeParam_level--; for_threeParam_end();}
;
ForHead
    : FOR {for_oneParam_head();}

InitStmt 
    : SimpleStmt
;
PostStmt 
    : SimpleStmt
;

PrintStmt 
    : PRINT '(' Expression ')' {printPrint("print",$3->type);}
    | PRINTLN '(' Expression ')' {printPrint("println",$3->type);}
;





%%
int main(int argc, char** argv)
{
    file=fopen("hw3.j","w");
    initialClassWrite();

    # if YYDEBUG
        yydebug=1;
    # endif
    yylineno = 0;
    create_symbol();

    yyparse();

    if (HAS_ERROR) {
        remove("hw3.j");
    }

    endClassWrite();
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
        HAS_ERROR=1;
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

;}

void dump_symbol(int scope) {
    /*
    printf("> Dump symbol table (scope level: %d)\n", scope);
    printf("%-10s%-10s%-10s%-10s%-10s%s\n",
           "Index", "Name", "Type", "Address", "Lineno", "Element type");
    */
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
        /*
        printf("%-10d%-10s%-10s%-10d%-10d%s\n",
        tmp->index,tmp->name,tmp->type,tmp->address,tmp->lineno,tmp->element_type);
        */
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
        HAS_ERROR=1;
    }
    else{
        printf("IDENT (name=%s, address=%d)\n",tmp->name,tmp->address);
    }
}


char* binary_typecheck(tokenPtr operand1,char* operator,tokenPtr operand2){
    char* type1=operand1->type;
    char* type2=operand2->type;

    char* result=malloc(20*sizeof(char));
    //general case
    //printf("type1:%s operator:%s type2:%s\n",type1,operator,type2);
    if(strcmp(type1,"notDefine") == 0 || strcmp(type2,"notDefine")==0){
        HAS_ERROR=1;
        return "notDefine";
    }
    if(strcmp(operator,"REM")==0){
        if(strcmp(type1,"float32") == 0 || strcmp(type2,"float32")==0){
            HAS_ERROR=1;
            printf("error:%d: invalid operation: (operator REM not defined on float32)\n",yylineno);
            strcpy(result,"REM error");
        }
        else{
            strcpy(result,"int32");
        }
    }
    else if(strcmp(operator,"LOR")==0){
        if(strcmp(type1,"bool") != 0 || strcmp(type2,"bool")!=0){
            HAS_ERROR=1;
            printf("error:%d: invalid operation: (operator LOR not defined on int32)\n",yylineno);
            strcpy(result,"LOR error");
        }
        else{
            strcpy(result,"bool");
        }
    }
    else if(strcmp(operator,"LAND")==0){
        if(strcmp(type1,"bool") != 0 || strcmp(type2,"bool")!=0){
            HAS_ERROR=1;
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
            HAS_ERROR=1;
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
        strcpy(to,"f");
    }
    else if(strcmp(convertTo,"int32")==0){
        strcpy(to,"i");
    }
    if(strcmp(convertFrom,"float32")==0){
        strcpy(from,"f");
    }
    if(strcmp(convertFrom,"int32")==0){
        strcpy(from,"i");
    }
    fprintf(file,"%s2%s\n",from,to);
}
void checkTypeBool(char * type){
    if(strcmp(type,"bool")!=0){
        printf("error:%d: non-bool (type %s) used as for condition\n",yylineno+1,type);
    }
}


void print_assign_to_literal(char* type,char* operator){
    //printf("error:%d: cannot %s to %s\n",yylineno,operator,type);
    HAS_ERROR=1;
    printf("error:%d: cannot assign to %s\n",yylineno,type);
    printf("%s\n",operator);

}

///////////////////////////////////old function end
void initialClassWrite(){
    fprintf(file,
            ".source hw3.j\n"
            ".class public Main\n"
            ".super java/lang/Object\n"
            ".method public static main([Ljava/lang/String;)V\n"
            ".limit stack 100 ; Define your storage size.\n"
            ".limit locals 100 ; Define your local space number.\n");


}
void endClassWrite(){
    fprintf(file,
            "return\n"
            ".end method\n");
}


////////////////////////////


///////////////////////////print load operand
void printLoadOperand(tokenPtr token_ptr){
    
    
    if(strcmp(token_ptr->tokenType,"IDENTIFIER") ==0){
        printLoadVariable(token_ptr->tokenValue);
    }
    /*
    else if(strcmp(tokenType,"float32Toint32")==0){
        token_ptr->tokenType="FLOAT_LIT";
        printLoadOperand(token_ptr);
        fputs("f2i");
    }
    else if(strcmp(tokenType,"int32Tofloat32")==0){
        token_ptr->tokenType="INT_LIT";
        printLoadOperand(token_ptr);
        fputs("i2f");
    }
    */
    else if(strcmp(token_ptr->tokenType,"FLOAT_LIT")==0){
        fprintf(file,"ldc %s\n",token_ptr->tokenValue);
    }
    else if(strcmp(token_ptr->tokenType,"INT_LIT")==0){
        fprintf(file,"ldc %s\n",token_ptr->tokenValue);
    }
    else if(strcmp(token_ptr->tokenType,"STRING_LIT")==0){
        fprintf(file,"ldc \"%s\"\n",token_ptr->tokenValue);
    }
    else if(strcmp(token_ptr->tokenType,"FALSE")==0){
        fputs("iconst_0\n",file);
    }
    else if(strcmp(token_ptr->tokenType,"TRUE")==0){
        fputs("iconst_1\n",file);
    }

}


void printLoadVariable(char* variableName){
    int global_address;
    char* type;
    symbol_table_entry_ptr tmp;
    tmp=lookup_symbol_multiScope(variableName,symbol_table_scope);
    global_address=tmp->address;
    type=tmp->type;
    if(strcmp(type,"array")==0){
        fprintf(file,"aload %d\n",global_address);
    }
    if(strcmp(type,"int32")==0){
        fprintf(file,"iload %d\n",global_address);
    }
    else if(strcmp(type,"float32")==0){
        fprintf(file,"fload %d\n",global_address);
    }
    else if(strcmp(type,"string")==0){
        fprintf(file,"aload %d\n",global_address);
    }
    else if(strcmp(type,"bool")==0){
        fprintf(file,"iload %d\n",global_address);
    }
}

int getVariableGlobalAddress(char* variableName){
    int global_address;
    symbol_table_entry_ptr tmp;
    tmp=lookup_symbol_multiScope(variableName,symbol_table_scope);
    global_address=tmp->address;
    return global_address;
}
void printStoreVariable(char* variableName){
    int global_address;
    char* type;
    symbol_table_entry_ptr tmp;
    tmp=lookup_symbol_multiScope(variableName,symbol_table_scope);
    global_address=tmp->address;
    type=tmp->type;
    if(strcmp(type,"int32")==0){
        fprintf(file,"istore %d\n",global_address);
    }
    else if(strcmp(type,"float32")==0){
        fprintf(file,"fstore %d\n",global_address);
    }
    else if(strcmp(type,"string")==0){
        fprintf(file,"astore %d\n",global_address);
    }
    else if(strcmp(type,"bool")==0){
        fprintf(file,"istore %d\n",global_address);
    }
    else if(strcmp(type,"array")==0){

        if(strcmp(tmp->element_type,"int32")==0){
            fprintf(file,"iastore\n");

        }
        else if(strcmp(tmp->element_type,"float32")==0){
            fprintf(file,"fastore\n");
        }
    }
}



///////////////////////////print operator code
void printBinaryOperator(tokenPtr operand1,char* operator,tokenPtr operand2){
    //printLoadOperand(operand1);
    //printLoadOperand(operand2);
    printOperatorCode(operator,operand1->type);

}


void printUnaryOperator(char* operator,tokenPtr token_ptr){
    //printLoadOperand(token_ptr);
    //print operator
    char* type=token_ptr->type;
    if(!strcmp(operator,"NEG") ){
        if( strcmp(type,"int32") ==0){
            fputs("ineg\n",file);
        }
        else if( strcmp(type,"float32") ==0){
            fputs("fneg\n",file);
        }

    }
    else if(strcmp(operator,"NOT") == 0){
        fputs("iconst_1\n",file);
        fputs("ixor\n",file);
    }
}
int check_is_literal(char* tokenType){
    int result=0;
    if(!strcmp(tokenType,"STRING_LIT") || !strcmp(tokenType,"INT_LIT") || !strcmp(tokenType,"FLOAT_LIT")){
        result=1;
    }
    return result;
}
void printAssign(tokenPtr LHS,char* operator,tokenPtr RHS){
    //printLoadOperand(RHS);
    //if LHS is array don't pop
    if(check_is_literal(LHS->tokenType)){
        print_assign_to_literal(LHS->type,operator);
    }
    else{
        symbol_table_entry_ptr tmp;
        tmp=lookup_symbol_multiScope(LHS->tokenValue,symbol_table_scope);
        if(tmp){
            char* type=tmp->type;
            if(strcmp(type,"array") && !strcmp(operator,"ASSIGN")){
                fputs("swap\n",file);
                fputs("pop\n",file);
            }
            //handle operator
            if(!strcmp(operator,"ADD_ASSIGN")){
                printOperatorCode("ADD",RHS->type);
            }
            else if(!strcmp(operator,"SUB_ASSIGN")){
                printOperatorCode("SUB",RHS->type);
            }
            else if(!strcmp(operator,"MUL_ASSIGN")){
                printOperatorCode("MUL",RHS->type);
            }
            else if(!strcmp(operator,"QUO_ASSIGN")){
                printOperatorCode("QUO",RHS->type);
            }
            else if(!strcmp(operator,"REM_ASSIGN")){
                printOperatorCode("REM",RHS->type);
            }
            printStoreVariable(LHS->tokenValue);

        }
    }
    
}



void printIncDecStmt(tokenPtr operand,char* operator){
    //printLoadOperand(operand);
    char* type=operand->type;
    if(!strcmp(type,"int32")){
        fputs("ldc 1\n",file);

    }
    else if(!strcmp(type,"float32")){
        fputs("ldc 1.0\n",file);

    }

    if(strcmp(operator,"INC") == 0){
        printOperatorCode("ADD",operand->type);
    }
    else if(strcmp(operator,"DEC") == 0){
        printOperatorCode("SUB",operand->type);
    }
    printStoreVariable(operand->tokenValue);
}

int check_is_relation_operator(char* operator){
    int result=0;
    if(strcmp(operator,"EQL") == 0){
        result=1;
    }
    else if(strcmp(operator,"NEQ") == 0){
        result=1;
    }
    else if(strcmp(operator,"LEQ") == 0){
        result=1;
    }
    else if(strcmp(operator,"GEQ") == 0){
        result=1;
    }
    else if(strcmp(operator,"LSS") == 0){
        result=1;
    }
    else if(strcmp(operator,"GTR") == 0){
        result=1;
    }
    return result;

}

void printOperatorCode(char* operator,char* type){

    if(strcmp(type,"int32") == 0){
        if(strcmp(operator,"ADD") ==0){
            fprintf(file,"iadd\n");
        }
        else if(strcmp(operator,"SUB") ==0){
            fprintf(file,"isub\n");
        }
        else if(strcmp(operator,"MUL") ==0){
            fprintf(file,"imul\n");
        }
        else if(strcmp(operator,"QUO") ==0){
            fprintf(file,"idiv\n");
        }
        else if(strcmp(operator,"REM") ==0){
            fprintf(file,"irem\n");
        }
    }
    else if(strcmp(type,"float32") == 0){
        if(strcmp(operator,"ADD") ==0){
            fprintf(file,"fadd\n");
        }
        else if(strcmp(operator,"SUB") ==0){
            fprintf(file,"fsub\n");
        }
        else if(strcmp(operator,"MUL") ==0){
            fprintf(file,"fmul\n");
        }
        else if(strcmp(operator,"QUO") ==0){
            fprintf(file,"fdiv\n");
        }
    }
    //////////////logic
    if(strcmp(operator,"LAND") == 0){
        fprintf(file,"iand\n");
    }
    else if(strcmp(operator,"LOR") == 0){
        fprintf(file,"ior\n");
    }

    ////relation
    printRelationCode(operator,type);
}
void printArrayDeclarationStmt(tokenPtr identifier,char* type){
    if(strcmp(type,"int32")==0){
        fprintf(file,"newarray int\n");
    }
    else if(strcmp(type,"float32")==0){
        fprintf(file,"newarray float\n");
    }

    int global_address=getVariableGlobalAddress(identifier->tokenValue);
    fprintf(file,"astore %d\n",global_address);
}

void printRelationCode(char* operator,char* type){
    if(check_is_relation_operator(operator)){
        //fprintf(file,"operator:%s type:%s",operator,type);
        if(strcmp(type,"int32")==0){
            fputs("isub\n",file);
        }
        else if(strcmp(type,"float32")==0){
            fputs("fcmpl\n",file);
        }

        if(strcmp(operator,"EQL") == 0){
            fprintf(file,"ifeq L_cmp_%d\n",jump_label_index++);
        }
        else if(strcmp(operator,"NEQ") == 0){
            fprintf(file,"ifne L_cmp_%d\n",jump_label_index++);
        }
        else if(strcmp(operator,"GEQ") == 0){
            fprintf(file,"ifge L_cmp_%d\n",jump_label_index++);
        }
        else if(strcmp(operator,"LEQ") == 0){
            fprintf(file,"ifle L_cmp_%d\n",jump_label_index++);
        }
        else if(strcmp(operator,"LSS") == 0){
            fprintf(file,"iflt L_cmp_%d\n",jump_label_index++);
        }
        else if(strcmp(operator,"GTR") == 0){
            fprintf(file,"ifgt L_cmp_%d\n",jump_label_index++);
        }

        fputs("iconst_0\n",file);
        fprintf(file,"goto L_cmp_%d\n",jump_label_index++);
        fprintf(file,"L_cmp_%d:\n",jump_label_index-2);
        fputs("iconst_1\n",file);
        fprintf(file,"L_cmp_%d:\n",jump_label_index-1);

    }
}
void printVariableDeclarationStmt(tokenPtr identifier,char* type){
    int global_address=getVariableGlobalAddress(identifier->tokenValue);
    if(strcmp(type,"int32")==0){
        fprintf(file,"ldc 0\n");
        fprintf(file,"istore %d\n",global_address);
    }
    else if(strcmp(type,"float32")==0){
        fprintf(file,"ldc 0.0\n");
        fprintf(file,"fstore %d\n",global_address);
    }
    else if(strcmp(type,"string")==0){
        fprintf(file,"ldc \"\"\n");
        fprintf(file,"astore %d\n",global_address);
    }

}
void printIndexExpr(tokenPtr identifier,tokenPtr index){
    //printLoadOperand(index);
    char* name=identifier->tokenValue;
    int global_address=getVariableGlobalAddress(name);
    fprintf(file,"aload %d\n",global_address);
    //fputs("swap\n",file);
}

void printPrint(char* printOrPrintln,char* type){
    
    if(strcmp(type,"int32")==0){
        fputs("getstatic java/lang/System/out Ljava/io/PrintStream;\n",file);
        fputs("swap\n",file);
        fprintf(file,"invokevirtual java/io/PrintStream/%s(I)V\n",printOrPrintln);
    }
    else if(strcmp(type,"float32")==0){
        fputs("getstatic java/lang/System/out Ljava/io/PrintStream;\n",file);
        fputs("swap\n",file);
        fprintf(file,"invokevirtual java/io/PrintStream/%s(F)V\n",printOrPrintln);
    }
    else if(strcmp(type,"string")==0){
        fputs("getstatic java/lang/System/out Ljava/io/PrintStream;\n",file);
        fputs("swap\n",file);
        fprintf(file,"invokevirtual java/io/PrintStream/%s(Ljava/lang/String;)V\n",printOrPrintln);
    }
    else if(strcmp(type,"bool")==0){
        fprintf(file,"ifne L_cmp_%d\n",jump_label_index++);
        fputs("ldc \"false\"\n",file);
        fprintf(file,"goto L_cmp_%d\n",jump_label_index++);
        fprintf(file,"L_cmp_%d:\n",jump_label_index-2);
        fputs("ldc \"true\"\n",file);
        fprintf(file,"L_cmp_%d:\n",jump_label_index-1);
        fputs("getstatic java/lang/System/out Ljava/io/PrintStream;\n",file);
        fputs("swap\n",file);
        fprintf(file,"invokevirtual java/io/PrintStream/%s(Ljava/lang/String;)V\n",printOrPrintln);
    }

}

void debugPrintString(char* name){
    printf("name: %s\n",name);
}

void printToken(tokenPtr token){
    printf("tokenType:%s tokenValue:%s type:%s\n",token->tokenType,token->tokenValue,token->type);
}
void filePrintToken(tokenPtr token){
    fprintf(file,"tokenType:%s tokenValue:%s type:%s\n",token->tokenType,token->tokenValue,token->type);
}
void printDeclarAssign(tokenPtr LHS,char* operator,tokenPtr RHS){
    //printLoadOperand(RHS);
    //printToken(LHS);
    //fprintf(file,"%s\n",operator);
    //printToken(RHS);
    
    printStoreVariable(LHS->tokenValue);
    
}
void if_array_print(tokenPtr operand){
    //printToken(operand);
    symbol_table_entry_ptr tmp;
    tmp=lookup_symbol_multiScope(operand->tokenValue,symbol_table_scope);
    if(tmp != NULL){
        char* type=tmp->type;
        if(!strcmp(type,"array")){
            if(!strcmp(tmp->element_type,"int32")){
                fprintf(file,"iaload\n");
            }
            else if(!strcmp(tmp->element_type,"float32")){
                fprintf(file,"faload\n");
            }
        }
    }
    
}

void ifAfterCondition(){
    fprintf(file,"ifeq L_if_false_%d_%d\n",if_lable_level,++if_false_index[if_lable_level]);
}


void ifAfterBlock(){
    fprintf(file,"goto L_if_exit_%d_%d\n",if_lable_level,if_exit_index[if_lable_level]);
    fprintf(file,"L_if_false_%d_%d:\n",if_lable_level,if_false_index[if_lable_level]);
}

void ifEnd(){
    fprintf(file,"L_if_exit_%d_%d:\n",if_lable_level,if_exit_index[if_lable_level]++);
}



void for_oneParam_head(){
    fprintf(file,"for_oneParam_begin_%d_%d:\n",for_oneParam_level,++for_oneParam_index[for_oneParam_level]);
}
void for_oneParam_afterCondition(){
    fprintf(file,"ifeq for_oneParam_exit_%d_%d\n",for_oneParam_level,for_oneParam_index[for_oneParam_level]);
}
void for_oenParam_end(){
    fprintf(file,"goto for_oneParam_begin_%d_%d\n",for_oneParam_level,for_oneParam_index[for_oneParam_level]);
    fprintf(file,"for_oneParam_exit_%d_%d:\n",for_oneParam_level,for_oneParam_index[for_oneParam_level]);
}
    

void for_threeParam_AfterInitStmt(){
    fprintf(file,"for_threeParam_begin_%d_%d:\n",for_threeParam_level,++for_threeParam_index[for_threeParam_level]);
}
void for_threeParam_AfterconditionStmt(){
    fprintf(file,"ifeq for_threeParam_exit_%d_%d\n",for_threeParam_level,for_threeParam_index[for_threeParam_level]);
    fprintf(file,"goto for_threeParam_exec_%d_%d\n",for_threeParam_level,for_threeParam_index[for_threeParam_level]);
    fprintf(file,"for_threeParam_postStmt_%d_%d:\n",for_threeParam_level,for_threeParam_index[for_threeParam_level]);

}
void for_threeParam_AfterPostStmt(){
    fprintf(file,"goto for_threeParam_begin_%d_%d\n",for_threeParam_level,for_threeParam_index[for_threeParam_level]);
    fprintf(file,"for_threeParam_exec_%d_%d:\n",for_threeParam_level,for_threeParam_index[for_threeParam_level]);
}
void for_threeParam_end(){
    fprintf(file,"goto for_threeParam_postStmt_%d_%d\n",for_threeParam_level,for_threeParam_index[for_threeParam_level]);
    fprintf(file,"for_threeParam_exit_%d_%d:\n",for_threeParam_level,for_threeParam_index[for_threeParam_level]);
}


/*
ConversionExpr 
    : Type '(' Expression ')' {printConversionType($1,$3->type);$$=$3;$$->type=$1;}
;
*/