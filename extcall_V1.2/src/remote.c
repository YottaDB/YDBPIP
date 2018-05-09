/*
*	remote.c
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	UNIX:	Harsha Lakshmikantha
*
*	DESC:	UNIX System calls
*
*   $Id$
*   $Log:	utils.c,v $
 * Revision 1.2  95/05/22  15:01:53  15:01:53  sca ()
 * sgI VMS
 * 
*   $Revision: 1.2 $
*
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <signal.h>
#include <time.h>
#include "extcall.h"

void
stfstart(int count,char *fep,char *fep_name,SLONG *return_code)
{
	RETURNSTATUS 	rc = SUCCESS;
	FILE 			*fd = (FILE *)NULL;
	char 			cmd[MAX_CMD_LEN];

	*return_code = MUMPS_SUCCESS;

	/*
	*	Build the rsh command
	*/
	(void)sprintf(cmd,"rsh %s -l %s 'source .cshrc ; $HOME/rpc.sh STFSTART < /dev/null | cat'",fep,fep_name);

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"ls: cmd %s\n",cmd);
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif

	/*
	*	Open pipe and execute command
	*/
	if((fd = popen(cmd,"r")) == (FILE *)NULL)
	{
		*return_code = errno;
		return;
	}


	/*
	*	Read the "process_name" process data.
	*/
	if((rc = fread(cmd,MAX_CMD_LEN,1,fd)) == FAILURE)
	{
		*return_code = errno;
		return;
	}

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"ls: cmd %s\n",cmd);
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif

	(void)pclose(fd);

	return;
}

void
stfstop(int count,char *fep,char *fep_name,SLONG *return_code)
{
	RETURNSTATUS 	rc = SUCCESS;
	FILE 			*fd = (FILE *)NULL;
	char 			cmd[MAX_CMD_LEN];

	*return_code = MUMPS_SUCCESS;

	/*
	*	Build the rsh command
	*/
	(void)sprintf(cmd,"rsh %s -l %s 'source .cshrc ; $HOME/rpc.sh STFSTOP < /dev/null | cat'",fep,fep_name);

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"ls: cmd %s\n",cmd);
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif

	/*
	*	Open pipe and execute command
	*/
	if((fd = popen(cmd,"r")) == (FILE *)NULL)
	{
		*return_code = errno;
		return;
	}


	/*
	*	Read the "process_name" process data.
	*/
	if((rc = fread(cmd,MAX_CMD_LEN,1,fd)) == FAILURE)
	{
		*return_code = errno;
		return;
	}

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"ls: cmd %s\n",cmd);
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif

	(void)pclose(fd);

	return;
}

void
mtmbod(int count,char *fep,char *fep_name,char *date,SLONG *return_code)
{
	RETURNSTATUS 	rc = SUCCESS;
	FILE 			*fd = (FILE *)NULL;
	char 			cmd[MAX_CMD_LEN];

	*return_code = MUMPS_SUCCESS;

	/*
	*	Build the rsh command
	*/
	(void)sprintf(cmd,"rsh %s -l %s 'source .cshrc ; $HOME/rpc.sh MTMBOD %s < /dev/null | cat'",fep,fep_name,date);

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"ls: cmd %s\n",cmd);
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif

	/*
	*	Open pipe and execute command
	*/
	if((fd = popen(cmd,"r")) == (FILE *)NULL)
	{
		*return_code = errno;
		return;
	}


	/*
	*	Read the "process_name" process data.
	*/
	if((rc = fread(cmd,MAX_CMD_LEN,1,fd)) == FAILURE)
	{
		*return_code = errno;
		return;
	}

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"ls: cmd %s\n",cmd);
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif

	(void)pclose(fd);

	return;
}

void
mtmeod(int count,char *fep,char *fep_name,char *uid,char *rd,char *hd,SLONG *return_code)
{
	RETURNSTATUS 	rc = SUCCESS;
	FILE 			*fd = (FILE *)NULL;
	char 			cmd[1000];
	/* char 			cmd[MAX_CMD_LEN]; */

	*return_code = MUMPS_SUCCESS;

	/*
	*	Build the rsh command
	*/
	(void)sprintf(cmd,"rsh %s -l %s 'source .cshrc ; $HOME/rpc.sh MTMEOD %s %s %s < /dev/null | cat'",fep,fep_name,uid,rd,hd);

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"ls: cmd %s\n",cmd);
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif

	/*
	*	Open pipe and execute command
	*/
	if((fd = popen(cmd,"r")) == (FILE *)NULL)
	{
		*return_code = errno;
		return;
	}


	/*
	*	Read the "process_name" process data.
	*/
	if((rc = fread(cmd,MAX_CMD_LEN,1,fd)) == FAILURE)
	{
		*return_code = errno;
		return;
	}

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"ls: cmd %s\n",cmd);
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif

	(void)pclose(fd);

	return;
}





void
clxfr(int count,char *fep,char *fep_name,char *glo,char *glokil,char *mrtns,char *crtns,char *srtns,char *prtns,SLONG *return_code)
{
	RETURNSTATUS 	rc = SUCCESS;
	FILE 			*fd = (FILE *)NULL;
	char 			cmd[1000];
	/* char 			cmd[MAX_CMD_LEN]; */

	*return_code = MUMPS_SUCCESS;

	/*
	*	Build the rsh command
	*/
	(void)sprintf(cmd,"rsh %s -l %s 'source .cshrc ; $HOME/rpc.sh CLXFR %s %s %s %s %s %s %s %s < /dev/null | cat'",fep,fep_name,glo,glokil,mrtns,crtns,srtns,prtns);

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"ls: cmd %s\n",cmd);
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif

	/*
	*	Open pipe and execute command
	*/
	if((fd = popen(cmd,"r")) == (FILE *)NULL)
	{
		*return_code = errno;
		return;
	}


	/*
	*	Read the "process_name" process data.
	*/
	if((rc = fread(cmd,MAX_CMD_LEN,1,fd)) == FAILURE)
	{
		*return_code = errno;
		return;
	}

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"ls: cmd %s\n",cmd);
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif

	(void)pclose(fd);

	return;
}




void
rtnupdat(int count,char *fep,char *fep_name,char *rtnlist,char *cmp,SLONG *return_code)
{
	RETURNSTATUS 	rc = SUCCESS;
	FILE 			*fd = (FILE *)NULL;
	char 			cmd[MAX_CMD_LEN];

	*return_code = MUMPS_SUCCESS;

	/*
	*	Build the rsh command
	*/
	(void)sprintf(cmd,"rsh %s -l %s 'source .cshrc ; $HOME/rpc.sh RTNUPDAT %s %s < /dev/null | cat'",fep,fep_name,rtnlist,cmp);

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"ls: cmd %s\n",cmd);
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif

	/*
	*	Open pipe and execute command
	*/
	if((fd = popen(cmd,"r")) == (FILE *)NULL)
	{
		*return_code = errno;
		return;
	}


	/*
	*	Read the "process_name" process data.
	*/
	if((rc = fread(cmd,MAX_CMD_LEN,1,fd)) == FAILURE)
	{
		*return_code = errno;
		return;
	}

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"ls: cmd %s\n",cmd);
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif

	(void)pclose(fd);

	return;
}




void
feptfile(int count,char *fep,char *fep_name,char *dirnam1,char *rms,SLONG *return_code)
{
	RETURNSTATUS 	rc = SUCCESS;
	FILE 			*fd = (FILE *)NULL;
	char 			cmd[1000];
	/* char 			cmd[MAX_CMD_LEN]; */

	*return_code = MUMPS_SUCCESS;

	/*
	*	Build the rsh command
	*/

	(void)sprintf(cmd,"rsh %s -l %s 'source .cshrc ; $HOME/rpc.sh FEPTFILE %s %s < /dev/null | cat'",fep,fep_name,dirnam1,rms);

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"ls: cmd %s\n",cmd);
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif

	/*
	*	Open pipe and execute command
	*/
	if((fd = popen(cmd,"r")) == (FILE *)NULL)
	{
		*return_code = errno;
		return;
	}


	/*
	*	Read the "process_name" process data.
	*/
	if((rc = fread(cmd,MAX_CMD_LEN,1,fd)) == FAILURE)
	{
		*return_code = errno;
		return;
	}

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"ls: cmd %s\n",cmd);
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif

	(void)pclose(fd);

	return;
}
