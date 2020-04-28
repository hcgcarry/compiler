/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    PRINT = 258,
    PRINTLN = 259,
    IF = 260,
    ELSE = 261,
    FOR = 262,
    ADD_ASSIGN = 263,
    SUB_ASSIGN = 264,
    MUL_ASSIGN = 265,
    QUO_ASSIGN = 266,
    REM_ASSIGN = 267,
    TRUE = 268,
    FALSE = 269,
    RETURN = 270,
    VOID = 271,
    INT = 272,
    FLOAT = 273,
    STRING = 274,
    BOOL = 275,
    VAR = 276,
    NEWLINE = 277,
    LOR = 278,
    LAND = 279,
    GEQ = 280,
    LEQ = 281,
    EQL = 282,
    NEQ = 283,
    INC = 284,
    DEC = 285,
    IDENTIFIER = 286,
    STRING_LIT = 287,
    INT_LIT = 288,
    FLOAT_LIT = 289
  };
#endif
/* Tokens.  */
#define PRINT 258
#define PRINTLN 259
#define IF 260
#define ELSE 261
#define FOR 262
#define ADD_ASSIGN 263
#define SUB_ASSIGN 264
#define MUL_ASSIGN 265
#define QUO_ASSIGN 266
#define REM_ASSIGN 267
#define TRUE 268
#define FALSE 269
#define RETURN 270
#define VOID 271
#define INT 272
#define FLOAT 273
#define STRING 274
#define BOOL 275
#define VAR 276
#define NEWLINE 277
#define LOR 278
#define LAND 279
#define GEQ 280
#define LEQ 281
#define EQL 282
#define NEQ 283
#define INC 284
#define DEC 285
#define IDENTIFIER 286
#define STRING_LIT 287
#define INT_LIT 288
#define FLOAT_LIT 289

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 65 "compiler_hw2.y" /* yacc.c:1909  */

    int i_val;
    float f_val;
    char *s_val;
    /* ... */

#line 129 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
