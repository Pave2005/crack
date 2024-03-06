#include <stdio.h>
#include <stdlib.h>

char* ReadText (FILE* file, long size)
{
    char* buf = (char*)calloc (size + 1, sizeof (char));
    fread (buf, sizeof (char), size, file);
    return buf;
}

long FileSize (FILE* file)
{
    fseek (file, 0, SEEK_END);
    long size = ftell (file);
    fseek (file, 0, SEEK_SET);
    return size;
}
