#include <stdio.h>

int fib(int n);

int main(int argc, char** argv){
	printf("%d\n",fib(20));
	return 0;
}

int fib(int n){
        if(n <= 0) return 0;
        if(1 == n) return 1;
        return fib(n-1) + fib(n-2);
}
