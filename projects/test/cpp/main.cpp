#include <stdio.h>
#include <unistd.h>
#include <stdint.h>

extern uint32_t uart_recv(); // returns 0xffffffff when empty
extern void uart_send(uint8_t data);

typedef union {
	float f;
	uint8_t c[4];
} FloatBit8;

void send_data(float value) {
	FloatBit8 b;
	b.f = value;
	uart_send(b.c[0]);
	uart_send(b.c[1]);
	uart_send(b.c[2]);
	uart_send(b.c[3]);
}

float recv_result() {
	FloatBit8 b;
	for ( int i = 0; i < 4; i++ ) {
		uint32_t res = uart_recv();
		while ( res > 0xff ) res = uart_recv();
		b.c[i] = res;
	}
	return b.f;
}

void* hwmain(void* arg) {
	for ( int i = 0; i < 32; i++ ) {
		#ifdef DEBUG
		//printf( "!!! %d\n", uart_recv() );
		#else
		//printf( ">> %d\n", uart_recv() );
		#endif
		//sleep(1);
		send_data((float)i);
		printf("sent %f\n",(float)i);
	}
	while (true) {
		float d = recv_result();
		// if ( (d>>8)==0 ) printf( "Received %d\n", d);
		printf("received %f\n", d);
		if((int)d == 31)
			break;
	}
	
	return NULL;
}
