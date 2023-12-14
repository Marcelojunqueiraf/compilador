%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ST.h"
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
int context_check( char *sym_name )
{
  symrec *identifier;
  identifier = getsym( sym_name );
  if ( identifier == 0 )
  { 
    errors++;
    printf( "%s", sym_name );
    printf( "%s\n", " is an undeclared identifier" );
  }
  else
    return identifier->offset;
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
/* Simple integer */
%token <id>
IDENTIFIER
/* Simple identifier */
%token <lbls>
IF WHILE
/* For backpatching labels */
%token SKIP THEN ELSE FI DO END
%token INTEGER READ WRITE LET IN
%token ASSGNOP
%token PAUSE
/*=========================================================================
OPERATOR PRECEDENCE
=========================================================================*/
%left '-' '+'
%left '*' '/'
%left UMINUS

%%
program : LET { initializeProgram(); }
    declarations
  IN 
    commands
  END { YYACCEPT; }
  ;
declarations
  : /* empty */
  | INTEGER id_seq IDENTIFIER '.' { install( $3 ); }
  ;
id_seq: /* empty */
  | id_seq IDENTIFIER ',' { install( $2 );}
  ;
commands: /* empty */
  | commands command ';'
  ;
command: PAUSE { gen_code( HALT, 0, 0, 0);} 
  | SKIP { copy(t1, t1);}
  | READ IDENTIFIER {
    gen_code(IN_OP, t1, 0, 0);
    int address = context_check( $2 );
    gen_code(LDC, t2, address, 0);
    gen_code(ST, t1, 0, t2); 
  }
  | WRITE exp {
    pop_stack();
    gen_code(OUT, t1, 0, 0); }
  | IDENTIFIER ASSGNOP exp {
      int address = context_check($1);
      pop_stack();
      gen_code(LDC, t2, address, 0);
      gen_code(ST, t1, 0, t2);
    }
  | IF exp {
      $1 = (struct lbs *) newlblrec();
      pop_stack(); // valor de exp em t1
      gen_code(LDC, t2, 0, 0); // t2 = 0
      $1->for_jmp_false = reserve_loc(); // reserva espaço para o JEQ para o else
    }
    THEN commands {
      gen_code(LDC, t1, 0, 0); // t1 = 0
      $1->for_goto = reserve_loc();
    }
    ELSE {
      back_patch( $1->for_jmp_false, JEQ, t1, gen_label(), t2 );
    }
      commands
    FI { // label fi
      back_patch( $1->for_goto, JEQ, t1, gen_label(), t1);
    }
  | WHILE {
      $1 = (struct lbs *) newlblrec();
      $1->for_goto = gen_label(); // onde vai ficar o jump
    }
      exp {
        pop_stack(); // t1 = valor da expressão
        gen_code(LDC, t2, 0, 0); // t2 = 0
        $1->for_jmp_false = reserve_loc();
      }
    DO
      commands
    END {
      gen_code(LDC, t1, 0, 0); // t1 = 0
      gen_code( JEQ, t1, $1->for_goto, t1); // GOTO começo do while

      back_patch( $1->for_jmp_false, JEQ, t1, gen_label(), t2);
    }
  ;
exp:
  | subexp '<' subexp { 
    operate(SUB);
    pop_stack();
    copy(t1, t2);
    gen_code(LDC, t1, 0, 0); // t1 = 0
    gen_code(JGE, t2, 1, pc); // se t1 for diferente de 0 pular para pc+2
    gen_code(LDC, t1, 1, 0); // t1 = 1
    push_stack();
  }
  | subexp '=' subexp {
    operate(SUB);
    pop_stack();
    copy(t1, t2);
    gen_code(LDC, t1, 0, 0); // t1 = 0
    gen_code(JNE, t2, 1, pc); // se t1 for diferente de 0 pular para pc+2
    gen_code(LDC, t1, 1, 0); // t1 = 1
    push_stack();
  }
  | subexp '>' subexp { 
    operate(SUB);
    pop_stack();
    copy(t1, t2);
    gen_code(LDC, t1, 0, 0); // t1 = 0
    gen_code(JLE, t2, 1, pc); // se t1 for diferente de 0 pular para pc+2
    gen_code(LDC, t1, 1, 0); // t1 = 1
    push_stack();
  }
  | '(' exp ')'
  | subexp
  ;
subexp
  :NUMBER {
    gen_code( LDC, t1, $1, 0);
    push_stack();
  }
  | IDENTIFIER { 
    int address = context_check( $1 );
    gen_code(LDC, t1, address, 0);
    gen_code(LD, t1, 0, t1);
    push_stack();
  }
  | subexp '+' subexp { operate(ADD); }
  | subexp '-' subexp { operate(SUB); }
  | subexp '*' subexp { operate(MUL); }
  | subexp '/' subexp { operate(DIV); }
  | '(' subexp ')'
  | '-' subexp %prec UMINUS {
    gen_code(LDC, t1,-1,0);
    push_stack();
    operate(MUL);
  }
  ;
%%


int main( int argc, char *argv[] )
{ 
  extern FILE *yyin;
  ++argv;
  --argc;
  yyin = fopen( argv[0], "r" );
  // yydebug = 1;
  errors = 0;
  yyparse ();
  if (errors == 0)
  { 
    print_code ();
    // fetch_execute_cycle();
  }
}

int yyerror ( char *s ) /* Called by yyparse on error */
{
  errors++;
  printf ("%s\n", s);
}

