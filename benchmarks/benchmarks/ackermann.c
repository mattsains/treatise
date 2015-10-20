#include <stdio.h>

int A(int n, int m)
{
   if (m==0)
      return n+1;
   if (n==0)
      return A(m-1,1);
   return A(m-1,A(m,n-1));
}

int main(int argc, char* argv[])
{
   //fails because stack is too deep
   printf("%d", A(1,1));
   return 0;
}
