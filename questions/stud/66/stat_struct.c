#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>

int main(void)
{
	struct stat stat;
	printf("st_dev\t%ldbytes\n", sizeof(stat.st_dev));
	printf("st_ino\t%ldbytes\n", sizeof(stat.st_ino));
	printf("st_nlink\t%ldbytes\n", sizeof(stat.st_nlink));
	printf("st_mode\t%ldbytes\n", sizeof(stat.st_mode));
	printf("st_uid\t%ldbytes\n", sizeof(stat.st_uid));
	printf("st_gid\t%ldbytes\n", sizeof(stat.st_gid));
	printf("__pad0\t%ldbytes\n", sizeof(stat.__pad0));
	printf("st_rdev\t%ldbytes\n", sizeof(stat.st_rdev));
	printf("st_size\t%ldbytes\n", sizeof(stat.st_size));
	printf("st_blksize\t%ldbytes\n", sizeof(stat.st_blksize));
	printf("st_blocks\t%ldbytes\n", sizeof(stat.st_blocks));
	printf("st_atim.tv_sec\t%ldbytes\n", sizeof(stat.st_atim.tv_sec));
	printf("st_atim.tv_nsec\t%ldbytes\n", sizeof(stat.st_atim.tv_nsec));
	printf("__glibc_reserved[0]\t%ldbytes\n", sizeof(stat.__glibc_reserved[0]));
	return EXIT_SUCCESS;
}

