#define NUMBER_TYPE uint64_t
#define INSTRUCTION_TYPE uint32_t

//strings
struct lua_string
{
    uint32_t length;
    char* start;
};

struct lua_string lua_string_alloc(uint32_t length);

void lua_string_free(struct lua_string string);

//functions
struct lua_function; //break cyclic dependancy
struct lua_function
{
    struct lua_string name;
    uint32_t start_line;
    uint32_t end_line;
    char upvalues;
    char parameters;
    char is_vararg;
    char stack_size;

    uint32_t code_length;
    INSTRUCTION_TYPE* code;

    uint32_t constant_length;
    struct lua_type* constants;

    uint32_t function_length;
    struct lua_function* functions;
};

#define VARARG_HASARG 1
#define VARARG_ISVARARG 2
#define VARARG_NEEDSARG 4

//types in general
struct lua_type //TODO: should have used unions here, duh!
{
    char type;
    union
    {
        NUMBER_TYPE number;
        struct lua_string string;
        struct lua_function function;
    } value;
};
#define TNIL 0
#define TBOOLEAN 1
#define TNUMBER 3
#define TSTRING 4
