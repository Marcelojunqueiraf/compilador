%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ST.h"
#include "SM.h"
#include "CG.h"
#define YYDEBUG 1
int errors;

struct lbs
/* Labels for data, if and while
*/
{
int for_goto;
int for_jmp_false;
};
struct lbs * newlblrec() /* Allocate space for the labels
*/
{
return (struct lbs *) malloc(sizeof(struct lbs));
}
/*-------------------------------------------------------------------------
Install identifier & check if previously defined.
-------------------------------------------------------------------------*/
void install ( char *sym_name )
{
  symrec *s;
  s = getsym (sym_name);
  if (s == 0)
    s = putsym (sym_name);
  else { errors++;
    printf( "%s is already defined\n", sym_name );
  }
}
/*-------------------------------------------------------------------------
If identifier is defined, generate code
-------------------------------------------------------------------------*/
context_check( enum code_ops operation, char *sym_name )
{
  symrec *identifier;
  identifier = getsym( sym_name );
  if ( identifier == 0 )
  { 
    errors++;
    printf( "%s", sym_name );
    printf( "%s\n", " is an undeclared identifier" );
  }
  else gen_code( operation, identifier->offset );
}
/*=========================================================================
SEMANTIC RECORDS
=========================================================================*/
%}
%union semrec
/* The Semantic Records
*/
{
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
}
/*=========================================================================
TOKENS
=========================================================================*/
%start program
%token <intval> NUMBER
/* Simple integer
*/
48%token <id>
IDENTIFIER
/* Simple identifier
*/
%token <lbls>
IF WHILE
/* For backpatching labels
*/
%token SKIP THEN ELSE FI DO END
%token INTEGER READ WRITE LET IN
%token ASSGNOP
/*=========================================================================
OPERATOR PRECEDENCE
=========================================================================*/
%left '-' '+'
%left '*' '/'
%right '^'
/*=========================================================================
GRAMMAR RULES for the Simple language
=========================================================================*/
%%
program : LET
declarations
IN { gen_code( DATA, data_location() - 1 ); }
commands
END { gen_code( HALT, 0 ); YYACCEPT; };
declarations
  : /* empty */
  | INTEGER id_seq IDENTIFIER '.' { install( $3 ); }
  ;
id_seq
  : /* empty */
  | id_seq IDENTIFIER ',' { install( $2 );}
  ;
commands
  : /* empty */
  | commands command ';'
  ;
command
  : SKIP
  | READ IDENTIFIER { context_check( READ_INT, $2 ); }
  | WRITE exp {   ( WRITE_INT, 0 ); }               
  | IDENTIFIER ASSGNOP exp { context_check( STORE, $1 ); }
  | IF exp
    THEN commands
    ELSE { back_patch( $1->for_jmp_false, JMP_FALSE, gen_label() ); }
      commands
    FI { back_patch( $1->for_goto, GOTO, gen_label() ); }
  | WHILE
    // { back_patch( $1->for_goto, GOTO, gen_label() ); }
    // { $1 = (struct lbs *) newlblrec();
    // $1->for_goto = gen_label(); }
    exp
    // { $1->for_jmp_false = reserve_loc();
    // }
    DO
      commands
    END
      // { gen_code( GOTO, $1->for_goto );
      // back_patch( $1->for_jmp_false,
      // JMP_FALSE,
      // gen_label() );
      // }
  ;
exp
  : NUMBER { gen_code( LD_INT, $1 ); }
  | IDENTIFIER { context_check( LD_VAR, $1 ); }
  | exp '<' exp { gen_code( LT, 0 ); }
  | exp '=' exp { gen_code( EQ, 0 ); }
  | exp '>' exp { gen_code( GT, 0 ); }
  | exp '+' exp { gen_code( ADD, 0 ); }
  | exp '-' exp { gen_code( SUB, 0 ); }
  | exp '*' exp { gen_code( MULT, 0 ); }
  | exp '/' exp { gen_code( DIV, 0 ); }
  | exp '^' exp { gen_code( PWR, 0 ); }
  | '(' exp ')'
  ;
%%

main( int argc, char *argv[] )
{ 
  extern FILE *yyin;
  ++argv;
  --argc;
  yyin = fopen( argv[0], "r" );
  // yydebug = 1;
  errors = 0;
  yyparse ();
  printf ( "Parse Completed\n" );
  if (errors == 0)
  { 
    print_code ();
    // fetch_execute_cycle();
  }
}

yyerror ( char *s ) /* Called by yyparse on error */
{
  errors++;
  printf ("%s\n", s);
}