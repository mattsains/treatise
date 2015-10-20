#include <stdio.h>
#include <stdlib.h>

int main()
{
  char pairs[128];
  pairs['A'] = 'T';
  pairs['a'] = 'T';
  pairs['C'] = 'G';
  pairs['c'] = 'G';
  pairs['G'] = 'C';
  pairs['g'] = 'C';
  pairs['T'] = 'A';
  pairs['t'] = 'A';
  pairs['U'] = 'A';
  pairs['u'] = 'A';
  pairs['M'] = 'K';
  pairs['m'] = 'K';
  pairs['R'] = 'Y';
  pairs['r'] = 'Y';
  pairs['W'] = 'W';
  pairs['w'] = 'W';
  pairs['S'] = 'S';
  pairs['s'] = 'S';
  pairs['Y'] = 'R';
  pairs['y'] = 'R';
  pairs['K'] = 'M';
  pairs['k'] = 'M';
  pairs['V'] = 'B';
  pairs['v'] = 'B';
  pairs['H'] = 'D';
  pairs['h'] = 'D';
  pairs['D'] = 'H';
  pairs['d'] = 'H';
  pairs['B'] = 'V';
  pairs['b'] = 'V';
  pairs['N'] = 'N';
  pairs['n'] = 'N';
 
  char buffer[256];
  char outbuffer[61];
  char* sequence = malloc(524288000);
  long i=0;
  while (fgets(buffer, 256, stdin)) {
    if (buffer[0]=='>' || buffer[0]=='\n'){
      if (i!=0){
        //reverse and print string
        for (long j=i-1; j>=0; j-=60){
          for (long k=0; k<60; k++)
            if (j-k<0)
              outbuffer[k]='\0';
            else
              outbuffer[k]=sequence[j-k];
          outbuffer[60]='\0';
          printf(outbuffer);
          printf("\n");
        }
        i=0;
      }
      if (buffer[0]=='>'){
        printf(buffer);
      }
      else {
        exit(0);
      }
        
    }
    else {
      int j;
      for (j=0; buffer[j]!='\n'; j++){
        sequence[i+j]=pairs[buffer[j]];
      }
      i+=j;
    }
  }
  return 0;
}
