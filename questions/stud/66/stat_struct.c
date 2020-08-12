#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>

int main(void)
{
	struct stat stat;
	printf("st_dev\t%ldbytes\n", sizeof(stat.st_dev));
	return EXIT_SUCCESS;
}

