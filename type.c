#include <stdbool.h>
#include <stdint.h>
//right now this type is only for nil and string, will update when needed
struct lua_type
{
    char type;
    uint32_t value;
};

#define TNIL 0
#define TBOOLEAN 1
#define TNUMBER 3
#define TSTRING 4
