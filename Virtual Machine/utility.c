#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char* argv[])
{
   return run();
}

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
         str[i]=0;
         return;
      }   
}

