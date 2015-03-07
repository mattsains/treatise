#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

void print(char* str)
{
   printf(str);
}

void read_line(char* str, int len)
{
   if (fgets(str, len, stdin)==NULL)
      exit(1);

   for (int i=0; i<len; i++)
      if (str[i]=="\n")
      {
         str[i] = 0;
         return;
      }   
}

// Returns -1 if failure, else size of file in bytes
int file_to_memory(char* filename)
{
   FILE *f = fopen(filename, "rb");
   if (f==NULL)
      return NULL;

   fseek(f, 0, SEEK_END);
   int size = ftell(f);
   fseek(f, 0, SEEK_SET);

   char* memory = malloc(size+1);

   if (fread(memory, sizeof(char), size, f)!=size)
   {
      free(memory);
      return NULL; //read failed
   }

   fclose(f);
   memory[size] = 0;
   return memory;
}
