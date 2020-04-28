/* Definition section */
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #define YY_NO_UNPUT
    #define YY_NO_INPUT

    int line_num = 0;
    int comment_num = 0;
    int recordCommentLineAdd=-1;
%}

%x C_Comment_Condition
/* Define regular expression label */
letter [a-zA-Z_]
digit [0-9]
id {letter}+({letter}|{digit})*
inumber {digit}+
fnumber ({digit}*\.{digit}+)
identifier {letter}+({letter}|{digit})*
StringConst \".*\"

CPlusPlus_Comment "//".*
C_Comment "/*"


/* Rules section */
%%

"+"         { printf("%-8s \t %s\n", yytext, "ADD"); }
"-"         { printf("%-8s \t %s\n", yytext, "SUB"); }
"*"         { printf("%-8s \t %s\n", yytext, "MUL"); }
"/"         { printf("%-8s \t %s\n", yytext, "QUO"); }
"%"         { printf("%-8s \t %s\n", yytext, "REM"); }
"++"         { printf("%-8s \t %s\n", yytext, "INC"); }
"--"         { printf("%-8s \t %s\n", yytext, "DEC"); }
">"         { printf("%-8s \t %s\n", yytext, "GTR"); }
"<"         { printf("%-8s \t %s\n", yytext, "LSS"); }
">="         { printf("%-8s \t %s\n", yytext, "GEQ"); }
"<="         { printf("%-8s \t %s\n", yytext, "LEQ"); }
"=="         { printf("%-8s \t %s\n", yytext, "EQL"); }
"!="         { printf("%-8s \t %s\n", yytext, "NEQ"); }
"="         { printf("%-8s \t %s\n", yytext, "ASSIGN"); }
"+="         { printf("%-8s \t %s\n", yytext, "ADD_ASSIGN"); }
"-="         { printf("%-8s \t %s\n", yytext, "SUB_ASSIGN"); }
"*="         { printf("%-8s \t %s\n", yytext, "MUL_ASSIGN"); }
"/="         { printf("%-8s \t %s\n", yytext, "QUO_ASSIGN"); }
"%="         { printf("%-8s \t %s\n", yytext, "REM_ASSIGN"); }
"&&"         { printf("%-8s \t %s\n", yytext, "LAND"); }
"||"         { printf("%-8s \t %s\n", yytext, "LOR"); }
"!"         { printf("%-8s \t %s\n", yytext, "NOT"); }
"("         { printf("%-8s \t %s\n", yytext, "LPAREN"); }
")"         { printf("%-8s \t %s\n", yytext, "RPAREN"); }
"["         { printf("%-8s \t %s\n", yytext, "LBRACK"); }
"]"         { printf("%-8s \t %s\n", yytext, "RBRACK"); }
"{"         { printf("%-8s \t %s\n", yytext, "LBRACE"); }
"}"         { printf("%-8s \t %s\n", yytext, "RBRACE"); }
";"         { printf("%-8s \t %s\n", yytext, "SEMICOLON"); }
","         { printf("%-8s \t %s\n", yytext, "COMMA"); }
"\""         { printf("%-8s \t %s\n", yytext, "QUOTA"); }
"print"         { printf("%-8s \t %s\n", yytext, "PRINT"); }
"println"         { printf("%-8s \t %s\n", yytext, "PRINTLN"); }
"if"         { printf("%-8s \t %s\n", yytext, "IF"); }
"else"         { printf("%-8s \t %s\n", yytext, "ELSE"); }
"for"         { printf("%-8s \t %s\n", yytext, "FOR"); }
"int32"         { printf("%-8s \t %s\n", yytext, "INT"); }
"float32"         { printf("%-8s \t %s\n", yytext, "FLOAT"); }
"string"         { printf("%-8s \t %s\n", yytext, "STRING"); }
"bool"         { printf("%-8s \t %s\n", yytext, "BOOL"); }
"true"         { printf("%-8s \t %s\n", yytext, "TRUE"); }
"false"         { printf("%-8s \t %s\n", yytext, "FALSE"); }
"var"         { printf("%-8s \t %s\n", yytext, "VAR"); }
[ \t]         {;}
"\n"         {printf("%-8s \t %s\n"," ","NEWLINE" );line_num++;}
{inumber}         { printf("%-8s \t %s\n", yytext, "INT_LIT"); }
{fnumber}         { printf("%-8s \t %s\n", yytext, "FLOAT_LIT"); }
{identifier}         { printf("%-8s \t %s\n", yytext, "IDENT"); }
{CPlusPlus_Comment}         {   
                                printf("%-8s \t %s\n", yytext, "C++ Comment");
                                if(line_num!= recordCommentLineAdd ) {
                                    comment_num++;
                                    recordCommentLineAdd=line_num;
                                }
                            }
{C_Comment}         { BEGIN  C_Comment_Condition;printf("%s", yytext); }
<C_Comment_Condition>"*/" {
                                printf("%-8s \t %s\n",yytext,"C Comment");
                                BEGIN INITIAL ;
                                if(line_num!= recordCommentLineAdd ) {
                                    comment_num++;
                                    recordCommentLineAdd=line_num;
                                }
                          }
<C_Comment_Condition>\n { 
                            printf("%-8s \t %s\n",yytext,"C Comment"); 
                            if(line_num!= recordCommentLineAdd ) {
                                comment_num++;
                                recordCommentLineAdd=line_num;
                            }
                            //這個要放在這邊如果放在上面,會造成＼n的line_num變成夏衣行的
                        
                            line_num++;
                        }
<C_Comment_Condition>. { printf("%s", yytext); }

{StringConst}		{ 
				yytext[strlen(yytext)-1]='\0';
				yytext++;
				printf("\" \t QUOTA\n");
				printf("%s \t STR_CONST\n", yytext); 
				printf("\" \t QUOTA\n");
				
}


<<EOF>>     { line_num++; yyterminate(); }
.           {;}

%%

/*  C Code section */
int yywrap(void)
{
    return 1;
}

int main(int argc, char *argv[])
{
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }
    yylex();
    printf("\nFinish scanning,\n");
    printf("total line: %d\n", line_num);
    printf("comment line: %d\n", comment_num);
    fclose(yyin);
    return 0;
}
