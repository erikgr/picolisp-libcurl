#!/bin/bash

gcc -c -Wall -Werror -fpic pil_libcurl_callbacks.c				\
	&& gcc -shared -o pil_libcurl_callbacks.so pil_libcurl_callbacks.o	\
	&& rm pil_libcurl_callbacks.o
