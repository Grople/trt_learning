#include<iostream>
#include<stdio.h>

using namespace std;

int main(int argc, char const *argv[])
{
    int m = 0;
    int *m1;

    int b = 42;
    int b1 = 32;

    m = *reinterpret_cast<int* >(&b) ;

    m1 = reinterpret_cast<int* >(&b1) ;

    cout<< m << endl;
    cout<< m1 << endl << *m1 << endl;

    return 0;
}
