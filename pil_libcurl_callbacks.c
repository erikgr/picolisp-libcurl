/*
 * Provides callback functions for libcurl.
 */


#include <stdlib.h>
#include <stdio.h>
#include <string.h>


typedef size_t (*callback_t)(char *, size_t, size_t, void*);

typedef struct s_simple_buffer {
    int size;
    int used;
    char *data;
} simple_buffer;


simple_buffer *buffer_new (size_t initial_size) {

    simple_buffer *ptr;

    ptr = (simple_buffer *) malloc(sizeof(simple_buffer));
    ptr->size = initial_size;
    ptr->used = 0;
    ptr->data = malloc(initial_size * sizeof(char));

    return ptr;
}


/*
 * Writes incoming bytes to simple buffer.
 * Expands buffer to fit incoming data.
 */
size_t write_callback_simple_buffer (char *in_data,
					size_t size,
					size_t nmemb,
					void *dst_buffer) {

    simple_buffer *buffer = (simple_buffer *) dst_buffer;
    int total_size = size + nmemb -1;

    if((buffer->size - buffer->used) < total_size) {
	int newsize = (buffer->size + (2*total_size));
	buffer->data = realloc(buffer->data, newsize);
	buffer->size = newsize;
    }

    memcpy(buffer->data + buffer->used, in_data, total_size);
    buffer->used += total_size;
    *(buffer->data + buffer->used) = 0;

    return size * nmemb;
}


/*
 * Returns a callback function
 */
callback_t get_callback (void) {
	return write_callback_simple_buffer;
} 


int * get_int_arr (size_t n_elements){
    int *ptr = malloc(n_elements * sizeof(int));
    return ptr;
}

long * get_long_arr (size_t n_elements){
    long *ptr = malloc(n_elements * sizeof(long));
    return ptr;
}
