#include <stdio.h>
#include <stdlib.h>
#include "password_2.0.h"

int main ()
{
    FILE* file = fopen ("PASSWORD.com", "rb");
    long size = FileSize (file);
    char* bin_buf = ReadText (file, size);

    bin_buf[offset] = 0xeb;                         // заменили jne --> jmp
                                                    //          75h     EBh
    fclose (file);
    file = fopen ("PASSWORD.com", "wb");
    fwrite (bin_buf, sizeof (char), size, file);

    fclose (file);
    free (bin_buf);
}
