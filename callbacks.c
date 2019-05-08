/*
 * WIP:
 *
 * Provides callback functions for libcurl.
 */


#include <stdlib.h>
#include <stdio.h>
#include <string.h>


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
 * Writes incoming data to simple buffer.
 * Expands buffer to fit incoming data.
 */
extern size_t write_callback_simple_buffer (char *in_data,
					size_t size,
					size_t nmemb,
					void *dst_buffer) {

    simple_buffer *buffer = (simple_buffer *) dst_buffer;
    int total_size = size + nmemb;

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
 * work in progress.
 */
int main () {

    simple_buffer *buf = buffer_new(20);

    char copydata[] = "123456789";

    write_callback_simple_buffer(copydata, sizeof(char), strlen(copydata)-1, buf);
    write_callback_simple_buffer(copydata, sizeof(char), strlen(copydata)-1, buf);
    write_callback_simple_buffer(copydata, sizeof(char), strlen(copydata)-1, buf);
    write_callback_simple_buffer(copydata, sizeof(char), strlen(copydata)-1, buf);

    printf("got data: %s\nbuffersize: %d\nbufferused: %d\n",
	buf->data,
	buf->size,
	buf->used);

    free(buf->data);
    free(buf);

    return 0;
}





