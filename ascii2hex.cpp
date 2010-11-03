#include <stdio.h>
#include <stdlib.h>

int main()
{
  unsigned int str[80];
  unsigned int x, count = 0;

  while( scanf("%x", &x) )
  {
    str[count++] = x;
  }

  printf("%s\n", (char *) str);

  for( count ; count > 0 ; count-- )
    printf("%x\n", str[count]);

  return 0;
}
