#include <stdio.h>

/*
DECLARATIONS
=========================================================================*/
/* OPERATIONS: Internal Representation */

enum code_ops
{
  HALT,
  IN_OP,
  OUT,
  ADD,
  SUB,
  MUL,
  DIV,
  LD,
  LDA,
  LDC,
  ST,
  JLT,
  JLE,
  JGE,
  JGT,
  JEQ,
  JNE,
};

/* OPERATIONS: External Representation */
char *op_name[] = {
    "HALT",
    "IN",
    "OUT",
    "ADD",
    "SUB",
    "MUL",
    "DIV",
    "LD",
    "LDA",
    "LDC",
    "ST",
    "JLT",
    "JLE",
    "JGE",
    "JGT",
    "JEQ",
    "JNE",
};

struct instruction
{
  enum code_ops op;
  int arg[3];
};
/* CODE Array */
struct instruction code[999];

/*-------------------------------------------------------------------------
Registers
-------------------------------------------------------------------------*/
int pc = 0; // índice do array code apenas para compilação

enum Regs
{
  zero,
  um,
  reg1,
  reg2,
  reg3,
  reg4,
  sp,
  memorypointer,
};

// a=d+reg[s];    ST		dMem[a]=reg[r]
// LD = reg[r]=dMem[a]
void pop_stack()
{
  gen_code(LD, reg1, 0, sp);     //
  gen_code(LDA, reg1, 0, sp);    //
  gen_code(SUB, reg2, reg2, um); //
  gen_code(ST, reg2, 0, sp);     //
}

void push_stack()
{
  gen_code(ST, reg1, 0, sp);     //
  gen_code(LDA, reg2, 0, sp);    //
  gen_code(ADD, reg2, reg2, um); //
  gen_code(ST, reg2, 0, sp);     //
}

void move(enum Regs from, enum Regs to)
{
  gen_code(ADD, from, zero, to);
}

void operate(enum code_ops op)
{
  pop_stack();
  move(reg1, reg3);
  pop_stack();
  gen_code(op, reg1, reg1, reg3);
  push_stack();
}
