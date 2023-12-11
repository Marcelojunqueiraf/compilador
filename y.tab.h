/* A Bison parser, made by GNU Bison 3.5.1.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2020 Free Software Foundation,
   Inc.

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

/* Undocumented macros, especially those whose name start with YY_,
   are private implementation details.  Do not rely on them.  */

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
    NUMBER = 48,
    IDENTIFIER = 258,
    IF = 259,
    WHILE = 260,
    SKIP = 261,
    THEN = 262,
    ELSE = 263,
    FI = 264,
    DO = 265,
    END = 266,
    INTEGER = 267,
    READ = 268,
    WRITE = 269,
    LET = 270,
    IN = 271,
    ASSGNOP = 272
  };
#endif
/* Tokens.  */
#define NUMBER 48
#define IDENTIFIER 258
#define IF 259
#define WHILE 260
#define SKIP 261
#define THEN 262
#define ELSE 263
#define FI 264
#define DO 265
#define END 266
#define INTEGER 267
#define READ 268
#define WRITE 269
#define LET 270
#define IN 271
#define ASSGNOP 272

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
#line 55 "Simple.y"
union semrec
{
#line 58 "Simple.y"

int
intval;
/* Integer values
*/
char
*id;
/* Identifiers
*/
struct lbs *lbls;
/* For backpatching
*/

#line 108 "y.tab.h"

};
#line 55 "Simple.y"
typedef union semrec YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
