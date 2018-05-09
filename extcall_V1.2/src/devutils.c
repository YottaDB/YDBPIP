/*
*	devutils.c 
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	UNIX:	Sara G. Walters - 28 April 1995
*
*	DESC:	This routine performs the associated UNIX service calls
*			to provide the functionality as provided by the GT.M
*			call $ZGETDVI.
*
*   $Id$
*   $Log:	devutils.c,v $
 * Revision 1.1  95/07/24  11:25:26  11:25:26  rcs ()
 * Initial revision
 * 
 * Revision 1.1  95/05/22  15:01:39  15:01:39  sca ()
 * sgI VMS
 * 
*   $Revision: 1.1 $
*
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/statfs.h>
#include <sys/vfs.h>
#include <termio.h>
#include <fcntl.h>
#include "extcall.h"

void getfreeblk(int count, char *device, SLONG *return_code)
{
	RETURNSTATUS 	rc = SUCCESS;
	struct statfs 	buf;

	*return_code = MUMPS_SUCCESS;

	if((rc = statfs(device,&buf)) == FAILURE)
	{
		*return_code = errno;
		return;
	}

	*return_code = buf.f_bfree;

	return;
}

void getcharset(int count,SLONG *return_code)
{
	RETURNSTATUS	rc = SUCCESS;
	struct termio	tty_setting;
	int 			fd = 0;
	char *ptr = (char *)NULL;

	ptr = (char *)getenv(TTY);

	if((fd = sca_open(ptr,O_RDONLY)) == FAILURE)
	{
		*return_code = errno;
		return;
	}
	
	do {
		rc = ioctl(fd,TCGETA,&tty_setting);
	} while (rc == -1 && errno == EINTR);

	if (rc == -1) {
		*return_code = errno;
		return;
	}

	if(tty_setting.c_cflag & CS8)
		*return_code = 1;
	else
		*return_code = 0;

	return;
}

void
getdevclass(int count,
			char *device,
			STR_DESCRIPTOR *response,
			SLONG *return_code)
{
	RETURNSTATUS 	rc = SUCCESS;
	struct statfs 	buf;
	char			dev_hdr[24];
	char 			*ptr = (char *)NULL;

	*return_code = MUMPS_SUCCESS;

	ptr = device;
	response->str[0] = '\0';

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"getdevclass: device %s\n",device);
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif

	(void)strncpy(dev_hdr,device,strlen("/dev/"));
	dev_hdr[strlen("/dev/")]='\0';
	if((rc = strcmp(dev_hdr,"/dev/")) == 0)
	{
#ifdef DEBUG
	do {
		(void)fprintf(stdout,"getdevclass: strcmp dev_hdr %s\n",dev_hdr);
	} while (errno == EINTR);

	(void)sca_fflush(stdout);
#endif
		ptr += strlen(dev_hdr);

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"getdevclass: tty ptr %s\n",ptr);
	} while (errno == EINTR);

	(void)sca_fflush(stdout);
#endif
		(void)strncpy(dev_hdr,ptr,strlen("tty"));
		dev_hdr[strlen("tty")]='\0';
#ifdef DEBUG
	do {
		(void)fprintf(stdout,"getdevclass: tty dev_hdr %s\n",dev_hdr);
	} while (errno == EINTR);

	(void)sca_fflush(stdout);
#endif
		 if(((rc = strcmp(dev_hdr,"tty")) == 0) || ((rc = strcmp(dev_hdr,"pts")) == 0) || ((rc = strcmp(dev_hdr,"lat")) == 0) || ((rc = strcmp(dev_hdr,"pty")) == 0))
		{
#ifdef DEBUG
	do {
		(void)fprintf(stdout,"getdevclass: strcmp dev_hdr %s\n",dev_hdr);
	} while (errno == EINTR);

	(void)sca_fflush(stdout);
#endif
			/*
			*	Device is a	TTY
			*/
			(void)strcpy(response->str,"TRM");

		} 
		else if((rc = strcmp(dev_hdr,"rmt")) == 0)
		{
#ifdef DEBUG
	do {
		(void)fprintf(stdout,"getdevclass: rmt dev_hdr %s\n",dev_hdr);
	} while (errno == EINTR);

	(void)sca_fflush(stdout);
#endif
			/*
			*	Device is a	Tape Drive
			*/
			(void)strcpy(response->str,"MT");
		}
	}

	if(response->str[0] == '\0')
	{
		/*
		*	Device is a	FILE
		*/
		(void)strcpy(response->str,"FILE");
	}

	response->length = strlen(response->str);

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"getdevclass: response %s\n",response->str);
	} while (errno == EINTR);
	do {
		(void)fprintf(stdout,"getdevclass: length %d\n",response->length);
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif

	return;
}

void
getmaxblk(	int count,
			char *device,
			SLONG *return_code)
{
	RETURNSTATUS 	rc = SUCCESS;
	struct statfs 	buf;

	*return_code = MUMPS_SUCCESS;

	if((rc = statfs(device,&buf)) == FAILURE)
	{
		*return_code = errno;
		return;
	}

	*return_code = buf.f_blocks;

	return;
}
