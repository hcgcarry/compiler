#ifndef COMMON_H
#define COMMON_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* struct ... */
struct token{
    char *tokenType;
    char *tokenValue;
    char *type;
};

typedef struct token* tokenPtr;

#endif /* COMMON_H */