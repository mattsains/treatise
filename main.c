#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include "type.h"
#include "main.h"


int main(int argc, char* argv[])
{
    if (argc==0)
    {
        printf("Please provide an input binary");
    }

    //FILE* file = fopen(argv[0],"rb");
    FILE* file = fopen("C:\\Users\\Matthew\\Desktop\\varsity working folder\\Treatise\\lua\\littlefactorial.out","rb");

    uint32_t signature;
    fread(&signature, 4, 1, file);
    if (endian_convert32(signature) != 0x1B4C7561) //magic flag converted to big endian
    {
        printf("not a lua bytecode\n");
    }

    uint8_t byte = fgetc(file);
    printf("Lua version: %X\n",byte);

    byte = fgetc(file);
    if (byte)
        printf("Not official version\n");
    else
        printf("Official version\n");

    byte = fgetc(file);
    if (byte)
        printf("Little endian\n");
    else
        printf("Big endian\n");

    byte = fgetc(file);
    printf("Int has size %d\n",byte);

    byte = fgetc(file);
    printf("size_t has size %d\n",byte);

    byte = fgetc(file);
    printf("instructions have size %d\n",byte);

    byte = fgetc(file);
    printf("Lua Numbers have size %d\n",byte);

    byte = fgetc(file);
    if (byte)
        printf("Working in Integer mode\n");
    else
        printf("Working in float mode\n");

    //from now on, standard values for the above are assumed.

    struct lua_function main_func = parse_function(file);

    fclose(file);

    execute(main_func);
    return 0;
}

struct lua_function parse_function(FILE* file)
{
    struct lua_function result;

    result.name = parse_string(file);
    printf("Function: %s\n", result.name.start);

    fread(&(result.start_line), sizeof(result.start_line), 1, file);
    fread(&(result.end_line), sizeof(result.end_line), 1, file);
    printf("  starts line %d and ends line %d\n", result.start_line, result.end_line);

    result.upvalues = fgetc(file);
    result.parameters = fgetc(file);
    result.is_vararg = fgetc(file);
    result.stack_size = fgetc(file);
    printf("  has %d upvalues and %d parameters, max stack is %d\n", result.upvalues, result.parameters, result.stack_size);

    fread(&(result.code_length), sizeof(result.code_length), 1, file);
    result.code = malloc(sizeof(INSTRUCTION_TYPE)*result.code_length);
    fread(result.code, sizeof(INSTRUCTION_TYPE), result.code_length, file);

    fread(&(result.constant_length), sizeof(result.constant_length), 1, file);
    result.constants = malloc(sizeof(struct lua_type)*result.constant_length);
    for (uint32_t i=0; i<result.constant_length; i++)
    {
        result.constants[i].type = fgetc(file);
        if (result.constants[i].type==TNIL)
            continue;
        else if (result.constants[i].type==TNUMBER)
            fread(&(result.constants[i].value), sizeof(NUMBER_TYPE), 1, file);
        else if (result.constants[i].type==TBOOLEAN)
            result.constants[i].value=fgetc(file);
        else if (result.constants[i].type==TSTRING)
            result.constants[i].str = parse_string(file);
    }

    fread(&(result.function_length), sizeof(uint32_t), 1, file);
    result.functions = malloc(sizeof(struct lua_function)*result.function_length);
    for (uint32_t i=0; i<result.function_length; i++)
    {
        result.functions[i]=parse_function(file);
    }

    //debugging stuff that I don't care about
    //source line position list
    uint32_t skip;
    fread(&skip, sizeof(uint32_t), 1, file);
    fseek(file, skip*4, SEEK_CUR);
    //local list
    fread(&skip, sizeof(uint32_t), 1, file);
    for (uint32_t i=0; i<skip; i++)
    {
        uint32_t skip2;
        fread(&skip2, sizeof(uint32_t), 1, file);
        fseek(file, skip2+8, SEEK_CUR);
    }
    //upvalue list
    fread(&skip, sizeof(uint32_t), 1, file);
    for (uint32_t i=0; i<skip; i++)
    {
        uint32_t skip2;
        fread(&skip2, sizeof(uint32_t), 1, file);
        fseek(file, skip2, SEEK_CUR);
    }
    return result;
}

struct lua_string parse_string(FILE* file)
{
    uint32_t length;
    fread(&length, sizeof(uint32_t), 1, file);
    //length = endian_convert32(length); not needed? I don't even

    struct lua_string result = lua_string_alloc(length);
    fread(result.start, 1, result.length, file);

    return result;
}

uint32_t endian_convert32(uint32_t in)
{
    return ((in&0xFF000000) >> 24)|
           ((in&0x00FF0000) >> 8)|
           ((in&0x0000FF00) << 8)|
           ((in&0x000000FF) << 24);
}
uint64_t endian_convert64(uint64_t in)
{
    return endian_convert32((uint32_t)((in&0xFFFF0000)>>8))|
           (endian_convert32((uint32_t)(in&0xFFFF))<<8);
}
