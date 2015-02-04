#include <stdbool.h>
#include <stdint.h>
//right now this type is only for nil and string, will update when needed
struct lua_type
{
    bool nil;
    uint32_t value;
};
