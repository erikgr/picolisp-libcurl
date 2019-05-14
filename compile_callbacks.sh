gcc -c -Wall -Werror -fpic callbacks.c			\
	&& gcc -shared -o callbacks.so callbacks.o	\
	&& rm callbacks.o