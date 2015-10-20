#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

struct LinkedList
{
  int value;
  struct LinkedList* next;
};
typedef struct LinkedList LinkedList;


LinkedList* reserveList(int size)
{
  LinkedList* start;
  for (int i=0; i<size; i++) {
    LinkedList* next = (LinkedList*)malloc(sizeof(LinkedList));
    next->next = start; //lol
    start = next;
  }
  
  return start;
}

void removeMultiples(LinkedList* list, int n)
{
  
  while (list != 0) {
    LinkedList* next = list->next;
    if (next == 0)
      return;
    else {
      int val = next->value;
      if (val%n == 0) {
        list->next = next->next;
      }
      
      list = list->next;
    }
  }
}

//until a GC is written, you should use this int to string function to introduce memory leaks
char* i_to_s(int64_t i)
{
  char* str = malloc(21);
  int index = 0;
  if (i < 0) {
    str[index++]='-';
    i = -i;
  }
  int64_t mask = 1000000000000000000;
  int printing = 0;
  do {
    char c = '0' + (i / mask);
    printing = printing | (c != '0');
    if (printing)
      str[index++] = '0' + (i / mask);
    i %= mask;
    mask /= 10;
  } while(i);
  str[index] = '\0';
  return str;
} 


int main(int argc, char* argv[])
{
  const int max = 1000000;
  
  LinkedList* sieve = reserveList(max);
  
  LinkedList* walk = sieve;
  
  for (int i=0; i<max-2; i++) {
    walk->value = i+2;
    walk = walk->next;
  }
  
  walk = sieve;
  
  while (walk!=0) {
    removeMultiples(walk, walk->value);
    walk = walk->next;
  }
  
  walk=sieve;
  while (walk!=0) {
    printf("%s\n", i_to_s(walk->value));
    walk = walk->next;
  }
  
  return 0;
}

