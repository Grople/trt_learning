#include<iostream>


using namespace std;

int main(int argc, char const *argv[])
{
    int a = 7;
    int b = 9;
    const int * const p1 = &a;
    int const* const p2 = &b;

    cout<< p1<<"\t" <<*p1 <<endl;
    cout<< p2<< "\t" << *p2 <<endl;

    /* code */
    return 0;
}
