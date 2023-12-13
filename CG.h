#include <stdio.h>

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

enum Regs
{
  t1,
  t2,
  t3,
  r1,
  r2,
  sp,
  mp,
  pc,
};

int data_offset = 0;
int data_location()
{
  return data_offset++;
}
int code_offset = 0;

int gen_label()
{
  return code_offset;
}
int reserve_loc()
{
  return code_offset++;
}

void gen_code(enum code_ops operation, int arg0, int arg1, int arg2)
{
  code[code_offset].op = operation;
  code[code_offset].arg[0] = arg0;
  code[code_offset].arg[1] = arg1;
  code[code_offset++].arg[2] = arg2;
}

/* Generates code at a reserved location */
void back_patch(int addr, enum code_ops operation, int arg0, int arg1, int arg2)
{
  code[addr].op = operation;
  code[addr].arg[0] = arg0;
  code[addr].arg[1] = arg1;
  code[addr].arg[2] = arg2;
}

void print_code()
{
  int i = 0;
  while (i < code_offset)
  {
    if ((int)code[i].op <= DIV)
    {
      // RO - opcode r,s,t
      printf("%3d: %-5s %d, %d, %d\n", i, op_name[(int)code[i].op], code[i].arg[0], code[i].arg[1], code[i].arg[2]);
    }
    else
    {
      // RM - opcode r,d(s)
      printf("%3d: %-5s %d, %d (%d)\n", i, op_name[(int)code[i].op], code[i].arg[0], code[i].arg[1], code[i].arg[2]);
    }
    i++;
  }
}

// Helper functions

void initializeProgram()
{
  // Pegar o topo da pilha
  gen_code(LD, sp, 0, t1); // Botar em sp o valor armazenado no endereço 0 da memória (tamanho da memória)
  gen_code(ST, t1, 0, t1); // limpa o endereço 0 da memória
}

// a=d+reg[s];    ST		dMem[a]=reg[r]
// LD = reg[r]=dMem[a]
// LDA => reg[r] = d+reg[s]
void pop_stack()
{
  gen_code(LD, t1, 0, sp);  // poe o valor do topo da pilha em t1
  gen_code(LDA, sp, 1, sp); // incrementa sp em 1
}

void push_stack()
{
  gen_code(LDA, sp, -1, sp); // decrementa sp em 1
  gen_code(ST, t1, 0, sp);   // Bota o valor de t1 no topo da pilha
}

void copy(enum Regs from, enum Regs to)
{
  gen_code(LDA, to, 0, from);
}

void operate(enum code_ops op)
{
  pop_stack();
  copy(t1, t2);
  pop_stack();
  gen_code(op, t1, t1, t2);
  push_stack();
}
