#include <stdbool.h>
#include <stdio.h>

void buffercopy(char* buffer, char* buffer2, int length);
void permute(char* buffer, int length);
void rotate(char* buffer, int lastindex, int start);

int main(int argc, char *argv[])
{
    int length = 11;
    char buffer[length];
    char buffer2[length];
    int max = 0;
    int sign = 1;
    int checksum = 0;
    int count = 0;

    //setup
    int i;
    for (i = 0; i < length; i++) {
        buffer[i] = i;
    }

    //copy buffer so we can get the next permutation from the last
    buffercopy(buffer, buffer2, length);
    
    while(buffer[0] != 127)
    {
        while(true)
        {
            char firstchar = buffer2[0];
            if(firstchar == 0)
                break;
            else
            {
                rotate(buffer2, firstchar, 0);
                count++;
            }
        }

        if (count > max)
            max = count;

        permute(buffer, length);
        buffercopy(buffer, buffer2, length);

        checksum += count * sign;
        sign *= -1;
        count = 0;
    }

    printf("%d\n", max);
    printf("%d", checksum);
    return 0;
}

//in stdlib
void buffercopy(char* buffer, char* buffer2, int length)
{
    int i;
    for (i = 0; i < length; i++) {
        buffer2[i] = buffer[i];
    }
}

void permute(char* buffer, int length)
{
    int start;
    int lastindex = length - 1;
    int k = length - 1;
    char k_value;
    char k_plus_one_value;
    
 //Find the largest index k such that a[k] < a[k + 1]. If no such index exists, the permutation is the last permutation.
    do {
        k = k - 1; //start looking at the second last place
        if (k < 0) 
            goto doneperms;
        k_value = buffer[k];
        k_plus_one_value = buffer[k+1];
    } while(k_value >= k_plus_one_value); //should give us the largest kval

 //Find the largest index l greater than k such that a[k] < a[l].
    int l = k + 1;
    start = k + 1;
    int savedl = l;    
    while(true){
        if (l == lastindex)
            goto swaprotate;
        l += 1;
        char l_value = buffer[l];
        if (l_value > k_value)
            savedl = l;
    }
      
doneperms:
    buffer[0] = 127; //randomly chosen 127 to mark end of perms
    goto end;
    
swaprotate:;
    //Swap the value of a[k] with that of a[l].
    char temp = buffer[start - 1];
    buffer[start - 1] = buffer[savedl];
    buffer[savedl] = temp;
    //Reverse the sequence from a[k + 1] up to and including the final element a[n].
    rotate(buffer, length - 1, start);    
    
end:
    return;
}

void rotate(char* buffer, int lastindex, int start)
{
    int length = lastindex - start + 1;
    length /= 2;

    while(length > 0) {
        length--;
        char temp = buffer[start];
        buffer[start] = buffer[lastindex];
        buffer[lastindex] = temp;
        start++;
        lastindex--;
    }
}
