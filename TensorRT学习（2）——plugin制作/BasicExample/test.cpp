#include<stdio.h>
#include<typeinfo>
#include<iostream>




#include "./AddScalarPlugin.h"
 
// #define WHERE_AM_I(X, Y) ( (X) + (Y))


int main(int argc, char const *argv[])
{


    /* code */
    printf("hello world \n");
    printf("%s \n", PLUGIN_NAME);

    int a = 1;
    int b = 2;

    // printf(" %d \n", a);
    // printf(" %d \n", b);
    
    WHERE_AM_I();
    

    std::cout << a << std::endl;
    std::cout <<  a << b << std::endl;
    // std::cout << typeid(c).name() << std::endl;

    return 0;
}

