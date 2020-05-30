#include <stdint.h>
#include <stdio.h>
#include <pthread.h>

#include <queue>

pthread_mutex_t g_mutex;
std::queue<uint8_t> sw2hwq;
std::queue<uint8_t> hw2swq;
bool g_initialized = false;

pthread_t g_thread;
extern void *hwmain(void* arg);
extern "C" void bdpiSwInit() {
	if ( g_initialized ) return;
	pthread_mutex_init(&g_mutex, NULL);
	pthread_create(&g_thread, NULL, hwmain, NULL);
	g_initialized = true;
}

uint8_t g_outidx = 0xff;
extern "C" uint32_t bdpiUartGet(uint8_t idx) {
	bdpiSwInit();

	uint32_t data = 0xffffffff;
	pthread_mutex_lock(&g_mutex);
	if ( idx != g_outidx && !sw2hwq.empty() ) {
		// get new data
		data = sw2hwq.front();
		sw2hwq.pop();
		//printf( "uart get %d %d %d -> %x\n", idx, g_outidx, sw2hwq.size(), data&0xff );
		g_outidx = ((int)g_outidx+1)&0xff;
	}
	pthread_mutex_unlock(&g_mutex);
	return data;
}

uint8_t g_inidx = 0xff;
extern "C" void bdpiUartPut(uint32_t d) {
	bdpiSwInit();

	uint8_t idx = 0xff&(d>>8);
	uint8_t data = 0xff&d;
	if ( idx != g_inidx ) {
		g_inidx = idx;
		//printf( "--%d, %d\n",idx, data );
		pthread_mutex_lock(&g_mutex);
		hw2swq.push(data);
		pthread_mutex_unlock(&g_mutex);
	}
}

uint32_t uart_recv() {
	bdpiSwInit();
	uint32_t r = 0xffffffff;

	pthread_mutex_lock(&g_mutex);
	if ( !hw2swq.empty() ) {
		r = hw2swq.front();
		hw2swq.pop();
	}
	pthread_mutex_unlock(&g_mutex);
	return r;
}
void uart_send(uint8_t data) {
	bdpiSwInit();

	pthread_mutex_lock(&g_mutex);
	sw2hwq.push(data);
	pthread_mutex_unlock(&g_mutex);
}


