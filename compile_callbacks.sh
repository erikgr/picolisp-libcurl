gcc -c -Wall -Werror -fpic callbacks.c				\
	&& gcc -shared -o pilcurl_callbacks.so callbacks.o	\
	&& rm callbacks.o