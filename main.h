int main(int argc, char* argv[]);

struct lua_function parse_function(FILE* file);

struct lua_string parse_string(FILE* file);

uint32_t endian_convert32(uint32_t in);

uint64_t endian_convert64(uint64_t in);
