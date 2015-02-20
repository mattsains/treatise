#include <stdint.h>
#include <math.h>
#include "opcodes.h"
#include "type.h"

#include "interpreter.h"

#define REGISTERS 256

struct lua_type registers[REGISTERS] ;

void execute(struct lua_function function, struct lua_type* arguments, uint32_t argument_count)
{
    for(int PC=0; PC<function.code_length;)
    {
        uint32_t instruction = function.code[PC++];
        uint8_t opcode = instruction & 0b111111;
        uint8_t A = (instruction & (0xFF << 6))>>6;
        uint16_t C = (instruction & (0x1FF << 14))>>14;
        uint16_t B = (instruction & (0x1FF << 23))>>23;
        uint32_t Bx = (instruction & (0x3FFFF << 14))>>14;
        int32_t sBx=Bx - 131071;

        uint16_t cval;

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
            if (Bx>function.constant_length)
            {
                printf("no constant %d", Bx);
                exit(0);
            }
            registers[A]=function.constants[Bx];
            break;
        case OP_LOADBOOL:
            registers[A].value.number = B;
            registers[A].type = TBOOLEAN;
            if (C)
                PC++; //skip next instruction
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
            registers[A].value.number=register_or_constant_value(B)+register_or_constant_value(C);
            registers[A].type=TNUMBER;
            break;
        case OP_SUB:
            registers[A].value.number=register_or_constant_value(B)-register_or_constant_value(C);
            registers[A].type=TNUMBER;
            break;
        case OP_MUL:
            registers[A].value.number=register_or_constant_value(B)*register_or_constant_value(C);
            registers[A].type=TNUMBER;
            break;
        case OP_DIV:
            cval=register_or_constant_value(C);
            if (cval==0)
            {
                printf("No dividing by zero");
                exit(0);
            }
            registers[A].value.number=register_or_constant_value(B)/cval;
            registers[A].type=TNUMBER;
            break;
        case OP_MOD:
            cval=register_or_constant_value(C);
            if (cval==0)
            {
                printf("no modding by zero");
                exit(0);
            }
            registers[A].value.number=register_or_constant_value(B)%cval;
            registers[A].type=TNUMBER;
            break;
        case OP_POW:
            registers[A].value.number=pow(register_or_constant_value(B),register_or_constant_value(C));
            registers[A].type=TNUMBER;
            break;
        case OP_UNM:
            enforce_type(registers[B], TNUMBER);
            registers[A].value.number=-registers[B].value.number;
            registers[A].type=TNUMBER;
            break;
        case OP_NOT:
            enforce_type(registers[B], TBOOLEAN);
            registers[A].value.number=!registers[B].value.number;
            registers[A].type=TBOOLEAN;
            break;
        case OP_LEN:
            enforce_type(registers[B], TSTRING); //Only works for strings right now
            registers[A].value.number=registers[B].value.string.length;
            registers[A].type=TNUMBER;
            break;
        case OP_CONCAT:;
            uint32_t strlen=0;
            for (uint32_t i=B; i<=C; i++)
            {
                enforce_type(registers[i], TSTRING);
                strlen+=registers[i].value.string.length-1;
            }
            strlen++;
            registers[A].type = TSTRING;
            registers[A].value.string = lua_string_alloc(strlen);
            uint32_t newstrpos=0;
            for (int i=B; i<=C; i++)
            {
                for (int j=0; i<registers[i].value.string.length-1; i++)
                    registers[A].value.string.start[newstrpos++]=registers[i].value.string.start[j];
            }
            registers[A].value.string.start[newstrpos]=0;
            break;
        case OP_JMP:
            PC+=sBx;
            break;
        case OP_CALL:
        case OP_RETURN:
        case OP_TAILCALL:
        case OP_VARARG:
        case OP_SELF:
            //don't understand functions
            break;
        case OP_EQ:
            //only comparisons of integers are allowed
            if ((register_or_constant_value(B)==register_or_constant_value(C))!=A)
                PC++;
            break;
        case OP_LT:
            if ((register_or_constant_value(B)<register_or_constant_value(C))!=A)
                PC++;
            break;
        case OP_LE:
            if ((register_or_constant_value(B)<=register_or_constant_value(C))!=A)
                PC++;
            break;
        case OP_TEST:
            if (registers[A].value.number==C)
                PC++;
            break;
        case OP_TESTSET:
            if (registers[A].value.number!=C)
                registers[A]=registers[B];
            else
                PC++;
            break;
        case OP_FORPREP:
            registers[A].value.number-=registers[A+2].value.number;
            PC+=sBx;
            break;
        case OP_FORLOOP:
            registers[A].value.number+=registers[A+2].value.number;
            if (registers[A+2].value.number>0)
            {
                if (registers[A].value.number<=registers[A+1].value.number)
                {
                    PC+=sBx;
                    registers[A+3]=registers[A];
                }
            } else
            {
                if (registers[A].value.number>=registers[A+1].value.number)
                {
                    PC+=sBx;
                    registers[A+3]=registers[A];
                }
            }
            break;
        case OP_TFORLOOP:
            //function required
        case OP_NEWTABLE:
        case OP_SETLIST:
            //tables
            break;
        case OP_CLOSURE:

            break;
        //todo: rest
        }
    }
}

void enforce_type(struct lua_type var, char type)
{
    if (var.type!=type)
    {
        printf("Type mismatch: expecting %d but given %d", type, var.type);
        exit(0);
    }
}

uint16_t register_or_constant_value (uint16_t operand)
{
    if (operand<REGISTERS)
    {
        enforce_type(registers[operand], TNUMBER);

        return registers[operand].value.number;
    } else
        return operand-REGISTERS; //for now constants are done as integers
}

void dealloc_str(struct lua_type obj) //this should be expanded to handle object types too
{
    //destroys strings marked for deletion (length zero but still string type
    if (obj.type==TSTRING && obj.value.string.length==0)
    {
        free(obj.value.string.start);
        obj.type=TNIL;
    }
}
