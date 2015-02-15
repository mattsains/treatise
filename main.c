#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include "main.h"

int main(int argc, char* argv[])
{
    if (argc==0)
    {
        printf("Please provide an input binary");
    }

    //FILE* file = fopen(argv[0],"rb");
    FILE* file = fopen("C:\\Users\\Matthew\\Desktop\\varsity working folder\\Treatise\\lua\\luac.out","rb");

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

    parse_function(file);

    fclose(file);
    return 0;
}

void parse_function(FILE* file)
{

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
