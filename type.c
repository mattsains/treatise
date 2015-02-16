#include <stdbool.h>
#include <stdint.h>

#include "type.h"

//strings
struct lua_string lua_string_alloc(uint32_t length)
{
    struct lua_string result;
    result.length=length;
    result.start=malloc(length);
    return result;
}

void lua_string_free(struct lua_string str)
{
    free(str.start);
    str.length=0;
}

char* lua_string_to_string(struct lua_string str)
{
    return str.start;
}


//functions

