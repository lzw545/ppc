#include <stdio.h>
#include <iostream>

typedef union {
     float f;
     unsigned int u;
} ufloat;
  
using namespace std;
 
int main()
{
    ufloat a;
    
    //cout << "Enter float value: ";
    cin >> a.f;
    printf("%08X", a.u);
}
