#include <stdlib.h>
#include <stdio.h>

long seed = 42;
// max is the number you want * 1000000
int random(long max)
{
  seed = (seed * 3877 + 29573) % 139968;
  return (seed * max) / 139968000000;
}

struct Frequency
{
  char c;
  int p;
};

void makeCumulative (struct Frequency frequencies[], int length)
{
  int total = 0;
  for (int i=0; i<length; i++) {
    total+=frequencies[i].p;
    frequencies[i].p=total;
  }
}

char selectRandom (struct Frequency frequencies[], int length)
{
  int r = random(10000000000); //10000

  for (int i=0; i<length; i++)
    if (r<frequencies[i].p)
      return frequencies[i].c;
  return frequencies[length-1].c;
}

void makeRandomFasta (struct Frequency frequencies[], int length, int n)
{
  int index = 0;
  int m = 0;
  char* buffer = malloc(1024);
  while (n > 0) {
    if (n < 60)
      m = n;
    else
      m = 60;

    for (int i=0; i<m; i++) {
      buffer[index] = selectRandom(frequencies, length);
      index++;
    }

    if (964 <= index) { //1024 <= index + 60
      buffer[index] = '\0';
      printf("%s\n", buffer);
      index = 0;
    }
    else if (n - 60 > 0) {
      buffer[index] = '\n';
      index++;
    }
    n-=60;
  }

  if (index!=0) {
    buffer[index] = '\0';
    printf("%s\n", buffer);
  }
}


void makeRepeatFasta(char alu[], int length, int n)
{
  char* buffer = malloc(1024);
  int index = 0;
  int m = 0;
  int k = 0;

  while (n > 0) {
    if (n < 60)
      m = n;
    else
      m = 60;
    
    for (int i=0; i<m; i++) {
      if (k == length)
        k = 0;

      buffer[index] = alu[k];
      index++;
      k++;
    }

    if (964 <= index) { //1024 <= index + 60
      buffer[index] = '\0';
      printf("%s\n", buffer);
      index = 0;
    }
    else if (n - 60 > 0) {
      buffer[index] = '\n';
      index++;
    }
    n -= 60;
  }

  if (index != 0) {
    buffer[index] = '\0';
    printf("%s\n", buffer);
  }
}

int main()
{
  struct Frequency HomoSapiens[4];
  HomoSapiens[0].c = 'a'; HomoSapiens[0].p = 3030;
  HomoSapiens[1].c = 'c'; HomoSapiens[1].p = 1980;
  HomoSapiens[2].c = 'g'; HomoSapiens[2].p = 1975;
  HomoSapiens[3].c = 't'; HomoSapiens[3].p = 3015;
  struct Frequency IUB[15];
  IUB[0].c = 'a'; IUB[0].p = 2700;
  IUB[1].c = 'c'; IUB[1].p = 1200;
  IUB[2].c = 'g'; IUB[2].p = 1200;
  IUB[3].c = 't'; IUB[3].p = 2700;
  IUB[4].c = 'B'; IUB[4].p = 200;
  IUB[5].c = 'D'; IUB[5].p = 200;
  IUB[6].c = 'H'; IUB[6].p = 200;
  IUB[7].c = 'K'; IUB[7].p = 200;
  IUB[8].c = 'M'; IUB[8].p = 200;
  IUB[9].c = 'N'; IUB[9].p = 200;
  IUB[10].c = 'R'; IUB[10].p = 200;
  IUB[11].c = 'S'; IUB[11].p = 200;
  IUB[12].c = 'V'; IUB[12].p = 200;
  IUB[13].c = 'W'; IUB[13].p = 200;
  IUB[14].c = 'Y'; IUB[14].p = 200;
  char ALU[] = "GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGGGAGGCCGAGGCGGGCGGATCACCTGAGGTCAGGAGTTCGAGACCAGCCTGGCCAACATGGTGAAACCCCGTCTCTACTAAAAATACAAAAATTAGCCGGGCGTGGTGGCGCGCGCCTGTAATCCCAGCTACTCGGGAGGCTGAGGCAGGAGAATCGCTTGAACCCGGGAGGCGGAGGTTGCAGTGAGCCGAGATCGCGCCACTGCACTCCAGCCTGGGCGACAGAGCGAGACTCCGTCTCAAAAA"; //has length 287
  

  makeCumulative(HomoSapiens, 4);
  makeCumulative(IUB, 15);

  char* text = ">ONE Homo sapiens alu";
  printf("%s\n", text);
  makeRepeatFasta(ALU, 287, 50000000); //n*2

  text = ">TWO IUB ambiguity codes";
  printf("%s\n", text);
  makeRandomFasta(IUB, 15, 75000000); //n*3

  text = ">THREE Homo sapiens frequency";
  printf("%s\n", text);
  makeRandomFasta(HomoSapiens, 4, 125000000); //n*5
}
