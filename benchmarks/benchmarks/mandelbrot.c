#include <stdlib.h>
#include <stdio.h>

void main() {
    const int SCALE = 1000;
    int width = 16000;
    int height = width;
    int maxiter = 50;
    int limit = 4 * SCALE * SCALE;
    int x, y;
    int index;
    int size = (width+7)/8 * height + 15;

    char* output = (char*) malloc(size);
    index = 0;
    output[index++] = 'P';
    output[index++] = '4';
    output[index++] = '\r';
    output[index++] = '1';
    output[index++] = '6';
    output[index++] = '0';
    output[index++] = '0';
    output[index++] = '0';
    output[index++] = ' ';
    output[index++] = '1';
    output[index++] = '6';
    output[index++] = '0';
    output[index++] = '0';
    output[index++] = '0';
    output[index++] = '\r';

    for (y = 0; y < height; y++)
    {
        int bits = 0;
        int Ci = 2*SCALE*y/height - SCALE;

        for (x = 0; x < width; )
        {
            int Zr = 0;//r3
            int Zi = 0;//r4
            int Cr = 2*SCALE*x/width - (SCALE + SCALE/2);
            int i = maxiter;

            bits = bits << 1;
            do
            {
                int temp = 2*Zr*Zi/SCALE + Ci; //this line changed from original to be closer to benchmark
                int Tr = (Zr*Zr - Zi*Zi)/SCALE + Cr;
                Zi = temp;
                Zr = Tr;
                if (Zr*Zr + Zi*Zi > limit)
                {
                    bits |= 1;
                    break;
                }
            } while (--i > 0);
            x++;

            if ((x & 0x07) == 0)
            {
                output[index++] = (char) (bits ^ 0xff);
                bits = 0;
            }
        }
        if ((x & 0x07) != 0)
        {
            output[index++] = (char) (bits ^ 0xff);
            bits = 0;
        }
    }

    fwrite(output, 1, index, stdout);
}
