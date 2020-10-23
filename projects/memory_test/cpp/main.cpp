#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <inttypes.h>	
#include <stdlib.h>

#define MTEST 93
#define MHEIGHT 50
#define MWIDTH  25
#define MAX_NDIM 2

#define F_RANGE 2.5f
#define QUANT_BITS 8

#define SUBBYTE (QUANT_BITS <= 4)

extern uint32_t uart_recv(); // returns 0xffffffff when empty
extern void uart_send(uint8_t data);



#if QUANT_BITS == 8
	typedef int8_t value;
	typedef int16_t multiplier;
#endif

float float_range;
float float_max;

value invscale;
value zeropoint;

value multmax;
value multmin;

value addmax;
value addmin;

float get_qrange()
{	
	float qrange;
	if (QUANT_BITS == 8) qrange = UINT8_MAX;
	else 
	{
		printf("Invalid Fixed Bit Size");
		exit(1);
	}
	printf("Float range: %f\n", float_range);
	printf("Quantized range: %f\n", qrange);
	return qrange;
}

value get_invscale()
{
	double q_range = (double) get_qrange();
	printf("Quantized Inverse Scale: %f\n", q_range/float_range); 
	value qinvscale = (value) (q_range/float_range);
	printf("Quantized Inverse Scale: %d\n", qinvscale);
	return qinvscale;
}

value get_zeropoint(value qinvscale)
{
	double qmax = (double) float_max;
	#if QUANT_BITS == 8
		qmax = INT8_MAX;
	#endif
	printf("Float max: %f\n", float_max);
	printf("Quantized max: %f\n", qmax);
	double subtrahend = (double)((double)float_max*qinvscale);
	
	printf("Quantized Zeropoint Subtrahend: %f\n", subtrahend);
	double qzeropoint =  qmax - subtrahend;
	printf("Quantized Zeropoint: %f\n", qzeropoint);
	value vzeropoint = (value) qzeropoint;
	
	printf("Value Zeropoint: %" PRId8 "\n", vzeropoint);
	return vzeropoint;
}


value quantize(float val)
{
	//if (test < 5) printf("qq sigmoidf %f \n", val);
#if SUBBYTE
	double scaled = (double) ((double)invscale.val * (double)val);
	value quantized = {(multiplier) (scaled + zeropoint.val)};
#else
	double scaled = (double) ((double)invscale * (double)val);
	value quantized = (value) (scaled + zeropoint);
#endif
	
	//if (test < 5) printf("qqq sigmoidf %f \n", scaled);
	return quantized;
}

float dequantize(value val)
{
#if SUBBYTE
	float adjusted = (float)val.val - (float)zeropoint.val;
	float dequantized = (float) adjusted / invscale.val;
#else
	float adjusted = (float)((float)val - (float)zeropoint);
	float dequantized = (float) adjusted / invscale;
#endif
	return dequantized;
}

value quantized_add(value x, value y)
{
	//multxy = 2*max(xscale,yscale)
	//multx = 2
#if SUBBYTE
	multiplier xterm = (multiplier)x.val - zeropoint.val;
	xterm = (xterm) / 2;
	multiplier yterm = (multiplier)y.val - zeropoint.val; 
	yterm = (yterm) / 2;
	multiplier scaled = (xterm + yterm);
	scaled = scaled * 2;

	value sum = {(multiplier) scaled + zeropoint.val};
	// if (sum > addmax) addmax = sum;
	// if (sum < addmin) addmin = sum;
#else
	multiplier xterm = (multiplier)x - zeropoint;
	xterm = (xterm) / 2;
	multiplier yterm = (multiplier)y - zeropoint; 
	yterm = (yterm) / 2;
	multiplier scaled = (xterm + yterm);
	scaled = scaled * 2;

	value sum = (value) scaled + zeropoint;
	if (sum > addmax) addmax = sum;
	if (sum < addmin) addmin = sum;
#endif
	// if (SATURATE && SIGNED)
	// {
		// //if (isSignedAddOverflow(x, y, sum)) return (value) sum;
		// if (isSignedAddOverflow(sum)) return quantize(S_MINMAX);
		// //else if (isSignedAddUnderflow(x, y, sum)) return (value) sum;//quantize(-float_max);
		// else if (isSignedAddUnderflow(sum)) return quantize(-S_MINMAX);
	// }
	return sum;
	
}

void readfloatfromfile(float* float_array, char* filename, size_t length)
{
	printf("Reading floats from file %s \n", filename);
	FILE * fp;
	fp = fopen(filename, "r");
	if (fp == NULL) {
		printf("File not found: %s", filename);
		exit(1);
	}
	for (size_t i = 0; i < length; i++) {
		if (fscanf(fp, "%e", &float_array[i]) != 1) {
			printf("Access error in %s array index %zu : input not valid.", filename, i);
			exit(1);
		}
		// else 
		// {
			// printf("%e ", float_array[i]);
		// }
	}
	fclose(fp);
}

void quantize_arr(float* ff_array, value* val_array, size_t len)
{
	printf("Quantizing Array...\n");
	for (size_t i = 0; i < len; i++)
	{	
		//if (len == 10000 && i == 0 && test < 5) printf("q sigmoidf %f \n", (ff_array[i]));
		val_array[i] = quantize(ff_array[i]);
		//if (len == 10000 && i == 0 && test < 5) printf("sigmoid %"PRId8" \n", (val_array[i]));
		//printf("%d", val_array[i]);
	}
}


void send_array(value* val_array, size_t len)
{
	printf("Sending Array...");

	for (size_t i = 0; i < len; i++)
	{
		//printf("Array value: %" PRId8 "\n", val_array[i]);
		uart_send(val_array[i]);
		
	}
	
	
	printf("Array sent.\n");
}


// void send_array_reorder(value* val_array, size_t len, size_t units, size_t in_width)
// {
	// printf("Re-ordering and Sending Array...");

	// for (size_t i = 0; i < 4; i++)
	// {
		// for (size_t j = 0; j < units; j++) 
		// {
			// for (size_t k = 0; k < in_width; k++)
			// {
				// uart_send(val_array[k*units+j]);
			// }
		// }
	// }	
	
	// printf("Array sent.\n");
// }





void* hwmain(void* arg) {
	
	float_range = F_RANGE;
	float_max = float_range/2.0f;
	
	
	invscale = get_invscale();
	zeropoint = get_zeropoint(invscale);
	
	// multmax = multmin = addmax = addmin = zeropoint;
	
	printf("Scale Inverse: %" PRId8 "\n", invscale);
	printf("Zero Point: %" PRId8 "\n", zeropoint);
	printf("Quantized Zero: %" PRId8 "\n", quantize(0.0f));
	printf("DeQuantized Zero: %f\n", dequantize(quantize(0.0f)));
	printf("Quantized Max: %" PRId8 "\n", quantize(float_max-0.000000000001));
	printf("DeQuantized Max: %f\n", dequantize(quantize(float_max-0.000000000001)));
		
	printf("DeQuantized 2-1: %f\n", dequantize(quantized_add(quantize(2.0f), quantize(-1.0f))));
	printf("Sigmoid Upper Limit: %" PRId8 "\n", quantize(2.5f));
	printf("Sigmoid Lower Limit: %" PRId8 "\n", quantize(-2.5f));

	printf("Sigmoid Offset: %" PRId8 "\n", quantize(0.5f));
	printf("Sigmoid Alpha: %" PRId8 "\n", quantize(0.2f));

	printf("One: %" PRId8 "\n", quantize(1.0f));

	printf("Loading & Converting Float Input...\n");
	
	value test_input_array[MTEST*MHEIGHT*MWIDTH];
	float test_truth_array[MTEST];
	value test_output_array[MTEST] = {0,};
	
	float ff_input_array[MTEST*MHEIGHT*MWIDTH];
	float ff_truth_array[MTEST];
	
	char input_filename[] = "seq_array_test_last.txt";
	readfloatfromfile(&ff_input_array[0], input_filename, MTEST*MHEIGHT*MWIDTH);
	quantize_arr(&ff_input_array[0], &test_input_array[0], MTEST*MHEIGHT*MWIDTH);
	
	char truth_filename[] = "label_array_test_last.txt";
	readfloatfromfile(&test_truth_array[0], truth_filename, MTEST);
	
	printf("Loading & Converting Float Weights...\n");	
	
	value lstm_1_kernel_array[10000];
	value lstm_1_recurrent_kernel_array[40000];
	value lstm_1_bias_array[400];
	value lstm_2_kernel_array[20000];
	value lstm_2_recurrent_kernel_array[10000];
	value lstm_2_bias_array[200];
	value dense_1_kernel_array[50];
	value dense_1_bias_array[1];
	
	float ff_lstm_1_kernel_array[10000];
	float ff_lstm_1_recurrent_kernel_array[40000];
	float ff_lstm_1_bias_array[400];
	float ff_lstm_2_kernel_array[20000];
	float ff_lstm_2_recurrent_kernel_array[10000];
	float ff_lstm_2_bias_array[200];
	float ff_dense_1_kernel_array[50];
	float ff_dense_1_bias_array[1] = {
		-4.99580391e-02,
	};
	
	char lstm_1_kernel_filename[]  = "lstm_1_kernel.txt";
	readfloatfromfile(&ff_lstm_1_kernel_array[0], lstm_1_kernel_filename, 10000);
	quantize_arr(&ff_lstm_1_kernel_array[0], &lstm_1_kernel_array[0], 10000);
	
	char lstm_1_recurrent_kernel_filename[]  = "lstm_1_recurrent_kernel.txt";
	readfloatfromfile(&ff_lstm_1_recurrent_kernel_array[0], lstm_1_recurrent_kernel_filename, 40000);
	quantize_arr(&ff_lstm_1_recurrent_kernel_array[0], &lstm_1_recurrent_kernel_array[0], 40000);
	
	char lstm_1_bias_filename[]  = "lstm_1_bias.txt";
	readfloatfromfile(&ff_lstm_1_bias_array[0], lstm_1_bias_filename, 400);
	quantize_arr(&ff_lstm_1_bias_array[0], &lstm_1_bias_array[0], 400);
	
	char lstm_2_kernel_filename[]  = "lstm_2_kernel.txt";
	readfloatfromfile(&ff_lstm_2_kernel_array[0], lstm_2_kernel_filename, 20000);
	quantize_arr(&ff_lstm_2_kernel_array[0], &lstm_2_kernel_array[0], 20000);
	
	char lstm_2_recurrent_kernel_filename[]  = "lstm_2_recurrent_kernel.txt";
	readfloatfromfile(&ff_lstm_2_recurrent_kernel_array[0], lstm_2_recurrent_kernel_filename, 10000);
	quantize_arr(&ff_lstm_2_recurrent_kernel_array[0], &lstm_2_recurrent_kernel_array[0], 10000);
	
	char lstm_2_bias_filename[]  = "lstm_2_bias.txt";
	readfloatfromfile(&ff_lstm_2_bias_array[0], lstm_2_bias_filename, 200);
	quantize_arr(&ff_lstm_2_bias_array[0], &lstm_2_bias_array[0], 200);
	
	char dense_1_kernel_filename[]  = "dense_1_kernel.txt";
	readfloatfromfile(&ff_dense_1_kernel_array[0], dense_1_kernel_filename, 50);
	quantize_arr(&ff_dense_1_kernel_array[0], &dense_1_kernel_array[0], 50);
	
	char dense_1_bias_filename[]  = "dense_1_bias.txt";
	readfloatfromfile(&ff_dense_1_bias_array[0], dense_1_bias_filename, 1);
	quantize_arr(&ff_dense_1_bias_array[0], &dense_1_bias_array[0], 1);
	
	float errors[MTEST];

	printf("Transmitting weights...\n");

	send_array(lstm_1_kernel_array, 10000);//, 100, 25);
	send_array(lstm_1_recurrent_kernel_array, 40000);//, 100, 100);
	send_array(lstm_1_bias_array, 400);
	send_array(lstm_2_kernel_array, 20000);//, 50, 100);
	send_array(lstm_2_recurrent_kernel_array, 10000);//, 50, 50);
	send_array(lstm_2_bias_array, 200);
	send_array(dense_1_kernel_array, 50);
	send_array(dense_1_bias_array, 1);
	
	printf("Starting Blue-Predictive-Maintenance...\n");
	
	for (int i = 0; i < MTEST; i++) {//; i++ ) {
		//
		#ifdef DEBUG
		//printf( "!!! %d\n", uart_recv() );
		#else
		//printf( ">> %d\n", uart_recv() );
		#endif
		//sleep(1);
		for (int j = 0; j < MHEIGHT; j++) {
			for (int k = 0; k < MWIDTH; k++) {
				value x = test_input_array[i*MHEIGHT + j*MWIDTH +k];
				uart_send(x);
			}
			
		}
		value d = uart_recv();
		if ( (d>>8)==0 ) printf( ">>> %x\n", d);
		//match d to truth
	}
	
	return NULL;
}