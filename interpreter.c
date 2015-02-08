#include <stdint.h>
#include <math.h>

#include "opcodes.h"
#include "type.c"

#define REGISTERS 256

struct lua_type registers[REGISTERS] ;

void execute(uint32_t* instructions)
{
    for(;;instructions++)
    {
        uint32_t instruction = *instructions;
        uint8_t opcode = instruction & 0b111111;
        uint8_t A = instruction & (0xFF << 6);
        uint16_t C = instruction & (0x1FF << 14);
        uint16_t B = instruction & (0x1FF << 23);
        uint32_t Bx = instruction & (0x3FFFF << 14);

        switch (opcode)
        {
        case OP_MOVE:
            registers[A] = registers[B];
            break;
        case OP_LOADNIL:
            for (int i=A; i <= B; i++)
                registers[i].type = TNIL;
            break;
        case OP_LOADK:
            registers[A].value = Bx; //LOADK just loads the constant number as an int for now
            registers[A].type = TNUMBER;
            break;
        case OP_LOADBOOL:
            registers[A].value = B;
            registers[A].type = TBOOLEAN;
            if (C)
                instructions++; //skip next instruction
            break;
        case OP_GETGLOBAL:
        case OP_SETGLOBAL:
        case OP_GETUPVAL:
        case OP_SETUPVAL:
        case OP_GETTABLE:
        case OP_SETTABLE:
            //too tired to implement now
            break;
        case OP_ADD:
            registers[A].value=register_or_constant_value(B)+register_or_constant_value(C);
            registers[A].type=TNUMBER;
            break;
        case OP_SUB:
            registers[A].value=register_or_constant_value(B)-register_or_constant_value(C);
            registers[A].type=TNUMBER;
            break;
        case OP_MUL:
            registers[A].value=register_or_constant_value(B)*register_or_constant_value(C);
            registers[A].type=TNUMBER;
            break;
        case OP_DIV:
            uint16_t cval=register_or_constant_value(C);
            if (cval==0)
            {
                printf("No dividing by zero");
                exit();
            }
            registers[A].value=register_or_constant_value(B)/cval;
            registers[A].type=TNUMBER;
            break;
        case OP_MOD:
            uint16_t cval=register_or_constant_value(C);
            if (cval==0)
            {
                printf("no modding by zero");
                exit();
            }
            registers[A].value=register_or_constant_value(B)%cval;
            registers[A].type=TNUMBER;
            break;
        case OP_POW:
            registers[A].value=pow(register_or_constant_value(B),register_or_constant_value(C));
            registers[A].type=TNUMBER;
            break;
        //todo: rest
        }
    }
}

uint16_t register_or_constant_value (uint16_t operand)
{
    if (operand<REGISTERS)
    {
        if (registers[operand].type==TNIL)
        {
            printf("Error - trying to perform operation on nil");
            exit();
        }
        return registers[operand].value;
    } else
        return operand-REGISTERS; //for now constants are done as integers
}
