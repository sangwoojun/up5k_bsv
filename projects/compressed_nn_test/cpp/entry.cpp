#include <stdio.h>
#include <unistd.h>
#include <stdint.h>

extern void* hwmain(void* arg);

int main() {
	hwmain(NULL);
	return 0;
}

