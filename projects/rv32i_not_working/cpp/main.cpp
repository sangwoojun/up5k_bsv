#include <stdio.h>
#include <unistd.h>
#include <stdint.h>

extern uint32_t uart_recv(); // returns 0xffffffff when empty
extern void uart_send(uint8_t data);

void* hwmain(void* arg) {
	for ( int i = 0; i < 32; i++ ) {
		#ifdef DEBUG
		//printf( "!!! %d\n", uart_recv() );
		#else
		//printf( ">> %d\n", uart_recv() );
		#endif
		//sleep(1);
		uart_send(i);
		uint32_t d = uart_recv();
		if ( (d>>8)==0 ) printf( ">>> %x\n", d);
	}
	return NULL;
}
