#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

// Create a length 624 array to store the state of the generator
unsigned int MT[624];
int index = 0;

void initialize_generator(int seed);
unsigned int extract_number();
void generate_numbers();

int main()
{
  initialize_generator(5489);
  for (long i=0; i<100000000L; i++) {
    printf("%d\n", extract_number());
  }
  return 0;
}
      
// Initialize the generator from a seed
void initialize_generator(int seed) {
  index = 0;
  MT[0] = seed;
  for (int i=1; i<=623; i++) { // loop over each element
    MT[i] = 0xffffffff & (1812433253 * (MT[i-1] ^ (MT[i-1]>>30)) + i); // 0x6c078965
  }
}

// Extract a tempered pseudorandom number based on the index-th value,
// calling generate_numbers() every 624 numbers
unsigned int extract_number() {
  if (index == 0) {
    generate_numbers();
  }

  unsigned int y = MT[index];
  y = y ^ (y>>11);
  y = y ^ (((long)y<<11) & 2636928640); // 0x9d2c5680
  y = y ^ (((long)y<<15) & 4022730752); // 0xefc60000
  y = y ^ ((y>>18));
  index = (index + 1) % 624;
  return y;
}

// Generate an array of 624 untempered numbers
void generate_numbers() {
  for (int i=0; i<=623; i++) {
    unsigned int y = (MT[i] & 0x80000000)                       // bit 31 (32nd bit) of MT[i]
      + (MT[(i+1) % 624] & 0x7fffffff);   // bits 0-30 (first 31 bits) of MT[...]
    MT[i] = MT[(i + 397) % 624] ^ (y>>1);
    if ((y % 2) != 0) { // y is odd
        MT[i] = MT[i] ^ 2567483615; // 0x9908b0df
      }
  }
}
