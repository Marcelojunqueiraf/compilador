/***************************************************************************
Code Generator
***************************************************************************/
/*-------------------------------------------------------------------------
Data Segment
-------------------------------------------------------------------------*/
int data_offset = 0;
/* Initial offset
 */
int data_location()
/* Reserves a data location
 */
{
  return data_offset++;
}
/*-------------------------------------------------------------------------
Code Segment
-------------------------------------------------------------------------*/
int code_offset = 0;
/* Initial offset
 */
int gen_label()
{
  return code_offset;
} /* Returns current offset */

int reserve_loc()
{
  return code_offset++;
} /* Reserves a code location */

/* Generates code at current location*/
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

/*-------------------------------------------------------------------------
Print Code to stdio
-------------------------------------------------------------------------*/
void print_code()
{
  int i = 0;
  while (i < code_offset)
  {
    if ((int)code[i].op <= DIV)
    {
      // RO - opcode r,s,t
      printf("%3ld: %-10s %ld, %ld, %ld\n", i, op_name[(int)code[i].op], code[i].arg[0], code[i].arg[1], code[i].arg[2]);
    }
    else
    {
      // RM - opcode r,d(s)
      printf("%3ld: %-10s %ld, (%ld) %ld\n", i, op_name[(int)code[i].op], code[i].arg[0], code[i].arg[1], code[i].arg[2]);
    }
    i++;
  }
}