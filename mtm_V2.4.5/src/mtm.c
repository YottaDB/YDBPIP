/*
*	mtm.c 
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	UNIX:	Sara G. Walters - 07 March 1995
*
*	DESC:	MTM Control Message API
*
*   $Id: mtm.c,v 1.1 2000/06/01 00:45:35 lyh Exp lyh $
*   $Log:	mtm.c,v $
 * Revision 2.10  07/02/09  thoniyim ()
 * Modified MTMCntrl() to parse through the parameters character by character
 * instead of using memchr. The memchr seem to give problems with GTM5.0
 * and higher.
 *
 * Revision 2.9  05/12/06  paulj ()
 * Modified the MTMCntrl() to handle STARTSTAT,STOPSTAT and GETSTAT messages
 *
 * Revision 2.8  04/06/12  thoniyim ()
 * Modified the MTMCntrl() to close the MTMFifoFd, after each request.
 *
 * Revision 2.8  04/06/12  thoniyim ()
 * The message queue creation is changed to use IPC_PRIVATE.
 * MTM now writes the queue id information to a .qid file and
 * the server programs reads the queue info from the .qid file.
 * The user can specify an environment variable, MTM_DIR, with
 * the directory info for the MTM files (.info,.lock,...)
 *
 * Revision 2.7  00/07/07  11:55:30  11:55:30  lyh ()
 * added string.h for strlen() function - resolve compiler warning when port
 * porting to other platform
 * 
 * Revision 2.6  00/07/06  17:15:47  17:15:47  lyh ()
 * Removed certain restrictions for tcp client (MTM v2.0.1)
 * 
 * Revision 2.5  00/06/02  13:20:54  13:20:54  lyh ()
 * Changes as a result of porting to other platforms.
 * 
 * Revision 2.4  00/03/27  15:55:40  15:55:40  lyh ()
 * wogm release
 * 
 * Revision 2.3  00/03/13  14:20:00  14:20:00  lyh ()
 * Check pointer to avoid segment violation error
 * 
 * Revision 2.2  00/03/03  15:09:02  15:09:02  lyh ()
 * Use a common alarm routine.
 * 
 * Revision 2.1  00/01/17  11:16:07  11:16:07  lyh ()
 * storm trooper release
 * 
 * Revision 1.2  99/12/28  11:12:58  11:12:58  lyh ()
 * added 3 new control messages: SENDMSG, GETVER, GETPARAM
 * 
 * Revision 1.1  99/12/27  15:57:30  15:57:30  lyh ()
 * Initial revision
 * 
 * Revision 1.11  98/09/20  (David Gitlin)
 * Greystone M v4.0 changed the manner in which it handles signals. As a
 * result, any external routine which makes system calls may find that
 * its behavior has been effected.  Essentially, signal sensitive system
 * calls may be interrupted before successfull completion, producing an
 * unknown state. Two changes were made to handle this. 1) A new
 * object file (/SCA/sca_gtm/shlib/shlib.o) was created with calls
 * such as sca_xxx where xxx is the equivalent system call. For example
 * sca_write, sca_open etc.  These calls handle the signal issue.
 * They were then substituted for the equivalent system call in the
 * source code. 2) The manner in which system calls like printf,
 * which have a variable number of arguments, were called
 * was directly changed in the source code. The changes are noted.
 *
 * Revision 1.7  96/04/10  17:20:37  17:20:37  zengf (Fan Zeng)
 * General cleaning up
 * 
 * Revision 1.6  96/03/21  15:03:18  15:03:18  zengf (Fan Zeng)
 * Collapsed directories and replaced signals with fifos.
 * 
 * Revision 1.5  96/03/13  10:05:12  10:05:12  zengf (Fan Zeng)
 * prepare for removing signals
 * 
 * Revision 1.4  95/08/11  14:39:49  14:39:49  rcs ()
 * Benchmark bug fixes
 * 
 * Revision 1.3  95/07/19  14:31:07  14:31:07  rcs ()
 * Bug Fixes as a result of MTM System Test
 * 
 * Revision 1.2  95/05/22  14:52:35  14:52:35  sca ()
 * sgI VMS
 * 
*   $Revision: 2.7 $
*
*/
#include	<ctype.h>
#include	<stdio.h>
#include	<errno.h>
#include	<time.h>
#include	<signal.h>
#include	<limits.h>
#include	<unistd.h>
#include	<sys/ipc.h>
#include	<sys/sem.h>
#include	<sys/msg.h>
#include	<sys/socket.h>
#include	<stdlib.h>
#include	<string.h>
#include	"./scatype.h"
#include	"./mtm.h"
#include	"./mtmapi.h"

/*
*	timer related functions
*/
extern void sca_SetupTimer(void *, st_timeout *, void *);
extern void sca_CancelTimer(void *, st_timeout *);
extern int sca_AlarmSetup(int);

/*
*	message queue related functions
*/
/*
extern int sca_msgsnd(SLONG, struct msgbuf *, size_t, int, st_timeout *, SLONG *);
extern int sca_msgrcv(SLONG, struct msgbuf *, size_t, long int, int, st_timeout *, SLONG *);
*/

char	*MTMMsgBuffer;
int	MTMFifoFd = DISCONNECTED;
st_timeout CtrlTimeout;

void ctrl_signal_catcher(int);

/*
*	MTMCntrl:
*	[module number i.e. Future] [module name]
*
*	Description:
*	$ZCall to allow a PROFILE MUMPS process to exhange a message with
*	an MTM Process.
*
*	Returns:
*/
void
MTMCntrl(	int 			count,
		char 			*cmd,
		STR_DESCRIPTOR 		*params,
		char			*mtm_id,
		char 			**reply,
		SLONG 			*return_code)
{
	RETURNSTATUS    rc = SUCCESS;
	MTM_CNTRL_MSG  	msg_cntrl_buffer;
	SLONG		mtm_cntrl_qid = 0;
	char		mtm_process_name[MAX_NAME_LEN];
/*	char		*ptr = (char *)NULL; */
	char		*separator;
	char		parameters[MAX_MSG_SIZE];
	int register	i=0;
	int		save_cmd;
	SLONG 		mtm_process_id;
	SLONG		current_process_pid;
	key_t		ipc_key;
	char		key_file[_POSIX_PATH_MAX + 1];
	char		fifo_name[_POSIX_PATH_MAX + 1];
	char            qid_file[_POSIX_PATH_MAX + 1];
	int		value;
	MTM_MSG_HEADER	*pHeader;
	FILE *          qid_fp;
        char            buffer[200];
        char            option[80];
        char            cvalue[80];
	char		*env_val;
	char		mtm_env[MAX_NAME_LEN];
	int		paramindex, index;

	memset(mtm_env,0,MAX_NAME_LEN);
	env_val = getenv ("MTM_DIR");
 
        if (env_val != NULL)
                strcpy (mtm_env, env_val);
        else
                sprintf(mtm_env,"%s",MTM_TMP_DIR);

	CtrlTimeout.type = sca_AlarmSetup(1);

	*reply = ""; 
	

/*dag Sep 18 98 to take care of signal handler conflict in gtm 4.0*/ 
	do {
	 	value = sprintf (mtm_process_name, "MTM_%s", mtm_id);
	}
        while (value < 0 && errno == EINTR);

/*dag Sep 18 98 to take care of signal handler conflict in gtm 4.0*/ 
	do {
		value = sprintf(key_file,"%s/%s.lock",mtm_env,mtm_process_name);
	}
        while (value < 0 && errno == EINTR);

/* MKT 060104 - qid file */
        do {
                value = sprintf(qid_file,"%s/%s.qid",mtm_env,mtm_process_name);
        }
        while (value < 0 && errno == EINTR);

#ifdef DEBUG
	fprintf (stdout, "\nMTMCntrl: key_file = %s\n", key_file);
	fprintf (stdout, "\nMTMCntrl: qid_file = %s\n", qid_file);
	fflush (stdout);
#endif

	mtm_get_mtm_pid (key_file, &mtm_process_id, return_code);
	if (*return_code != SUCCESS)
		return;

	current_process_pid = getpid();

#ifdef DEBUG
	(void)fprintf(stdout,"MTM Process Id %d\n",mtm_process_id);
	(void)fflush(stdout);
#endif

	if(MTMMsgBuffer == (char *)NULL)
		MTMMsgBuffer = (char *) malloc (MAX_MSG_SIZE+sizeof(MTM_MSG_HEADER)+10);
if (MTMMsgBuffer == NULL)
	{
		MTM_LOG(0);
		*return_code = rc;
		return;
	} 

	/*
	 * Open fifo as a one way channel to send message to MTM
	 */
	if (MTMFifoFd == DISCONNECTED)
	{

/*dag Sep 18 98 to take care of signal handler conflict in gtm 4.0*/ 
		do {
			value = sprintf(fifo_name,"%s/%s.fifo",mtm_env,mtm_process_name);
		}
        	while (value < 0 && errno == EINTR);

		if ((MTMFifoFd = sca_open (fifo_name, O_WRONLY)) == FAILURE)
		{
			MTM_LOG(errno);
			*return_code = errno;
			return;
		}
	}

/*** MKT 060104 - qid file ***/
	/*
	*	Get the MTM Control Queue Id
	*/
 
        qid_fp = fopen(qid_file,"r");
        if (qid_fp != (FILE *)NULL)
        {
           for (;;)
           {
              option[0] = '\0';
              cvalue[0] = '\0';
              memset(buffer, 0, 200);
 
              if (fgets(buffer,200,qid_fp) == NULL)
                 break;
 
              if (buffer[0] == '*')
                 continue;
 
              sscanf(buffer,"%[^=]=%s",option,cvalue);
 
              if (strcmp(option,"Server_Control_QID") == 0)
              {
                 mtm_cntrl_qid = strtoul(cvalue,NULL,10);
		 break;
              }
           }
        }
        else
        {
           MTM_LOG(errno);
           *return_code = errno;
           return;
        }

	fclose(qid_fp);

	/*
	*	Get command parameters
	*/
	if(params->length > 0)
	{
		memcpy (parameters, params->str, params->length);
		parameters[params->length] = RECORD_DELIMITER;

/*		ptr = parameters; */

#ifdef DEBUG
	(void)fprintf(stdout,"params->str %s\n",params->str);
	(void)fprintf(stdout,"params->length %d\n",params->length);
	(void)fprintf(stdout,"parameters %s\n",parameters);
	(void)LV(params->length, params->str);
	(void)LV(params->length + 1, parameters);
	(void)fflush(stdout);
#endif

        paramindex = 0; 
        index = 0; 
	if (index < params->length)
	{
        	while ((msg_cntrl_buffer.param1[paramindex++] = parameters[index++]) != RECORD_DELIMITER); 
        	msg_cntrl_buffer.param1[paramindex - 1] = '\0'; 
	}

	if (index < params->length)
	{
		paramindex = 0; 
		while ((msg_cntrl_buffer.param2[paramindex++] = parameters[index++]) != RECORD_DELIMITER); 
		msg_cntrl_buffer.param2[paramindex - 1] = '\0'; 
	}

	if (index < params->length)
	{
		paramindex = 0; 
		while ((msg_cntrl_buffer.param3[paramindex++] = parameters[index++]) != RECORD_DELIMITER); 
		msg_cntrl_buffer.param3[paramindex - 1] = '\0'; 
		msg_cntrl_buffer.param3Length = params->length - strlen(msg_cntrl_buffer.param1) - strlen(msg_cntrl_buffer.param2) - 2;
	}

/* Old Code - thoniyilm 02/09/2007 */
/*****
		for (i = 1; i <=3; i++)
		{
			if ((separator = (char *) memchr (ptr, RECORD_DELIMITER,(params->length+1))) == (char *)NULL)
			{
#ifdef DEBUG
	(void)fprintf(stdout,"break:separator = %s\n",separator);
	(void)fprintf(stdout,"break:ptr[0] = %c\n",ptr[0]);
	(void)fprintf(stdout,"break:prt[1] = %x\n",ptr[1]);
	(void)fflush(stdout);
#endif
				break;
			}
			
#ifdef DEBUG
	(void)fprintf(stdout,"separator %s\n",separator);
	(void)fflush(stdout);
#endif
			*separator = '\0';
			switch (i)
			{
				case 1:
					strcpy (msg_cntrl_buffer.param1, ptr);
					break;
				case 2:
					strcpy (msg_cntrl_buffer.param2, ptr);
					break;
				case 3:
					msg_cntrl_buffer.param3Length = params->length - strlen(msg_cntrl_buffer.param1) - strlen(msg_cntrl_buffer.param2) - 2;
					memcpy (msg_cntrl_buffer.param3, ptr, msg_cntrl_buffer.param3Length);
					break;
				default:
					break;
			}
			ptr = separator + 1;
		} 
*****/		/* end of for loop */

#ifdef DEBUG
	(void)LV(msg_cntrl_buffer.param3Length,msg_cntrl_buffer.param3);
	(void)fprintf(stdout,"Parameter1 %s\n",msg_cntrl_buffer.param1);
	(void)fprintf(stdout,"Parameter2 %s\n",msg_cntrl_buffer.param2);
	(void)fprintf(stdout,"Parameter3 %s\n",msg_cntrl_buffer.param3);
	(void)fprintf(stdout,"Parameter3 Length = %d\n",msg_cntrl_buffer.param3Length);
	(void)fflush(stdout);
#endif

	}

	if((rc = strcmp(cmd,"STOP")) == 0)
		msg_cntrl_buffer.cmd = STOP;
	else if((rc = strcmp(cmd,"ADDSRV")) == 0)
		msg_cntrl_buffer.cmd = ADDSRV;
	else if((rc = strcmp(cmd,"DELSRV")) == 0)
		msg_cntrl_buffer.cmd = DELSRV;
	else if((rc = strcmp(cmd,"JRNL")) == 0)
		msg_cntrl_buffer.cmd = JRNL;
	else if((rc = strcmp(cmd,"PEND")) == 0)
		msg_cntrl_buffer.cmd = PEND;
	else if((rc = strcmp(cmd,"CLSTAT")) == 0)
		msg_cntrl_buffer.cmd = CLSTAT;
	else if((rc = strcmp(cmd,"SVSTAT")) == 0)
		msg_cntrl_buffer.cmd = SVSTAT;
	else if((rc = strcmp(cmd,"SENDMSG")) == 0)
		msg_cntrl_buffer.cmd = SENDMSG;
	else if((rc = strcmp(cmd,"GETVER")) == 0)
		msg_cntrl_buffer.cmd = GETVER;
	else if((rc = strcmp(cmd,"GETPARAM")) == 0)
		msg_cntrl_buffer.cmd = GETPARAM;
	else if((rc = strcmp(cmd,"SVCLEAN")) == 0)
		msg_cntrl_buffer.cmd = SVCLEAN;
	else if((rc = strcmp(cmd,"STARTSTAT")) == 0)
		msg_cntrl_buffer.cmd = STARTSTAT;
	else if((rc = strcmp(cmd,"STOPSTAT")) == 0)
		msg_cntrl_buffer.cmd = STOPSTAT;
	else if((rc = strcmp(cmd,"GETSTAT")) == 0)
		msg_cntrl_buffer.cmd = GETSTAT;
	else
	{
                MTM_LOG(EINVAL);
                *return_code = -1;
                return;
	}

	save_cmd = msg_cntrl_buffer.cmd;

#ifdef DEBUG
	(void)fprintf(stdout,"Cmd %d\n",save_cmd);
	(void)fflush(stdout);
#endif

	/*
	*	Send  message.
	*/
	msg_cntrl_buffer.header.mtype.unix_pid = mtm_process_id;
	msg_cntrl_buffer.header.pid = current_process_pid;
	msg_cntrl_buffer.header.srv_type = OPERATOR;

#ifdef DEBUG
	(void)fprintf(stdout,"MtmCntrl: PID = %d\n",msg_cntrl_buffer.header.mtype.unix_pid);
        (void)LV(strlen(msg_cntrl_buffer.param1) + 1, msg_cntrl_buffer.param1);
	(void)fflush(stdout);
#endif

	CtrlTimeout.value = 10;

	sca_SetupTimer((void *)MTMCntrl, &CtrlTimeout, (void *)ctrl_signal_catcher);

	rc = sca_msgsnd(mtm_cntrl_qid,
		(struct msgbuf *)&msg_cntrl_buffer,
		sizeof(MTM_CNTRL_MSG),
		(int)0,
		&CtrlTimeout,
		return_code);

	sca_CancelTimer((void *)MTMCntrl, &CtrlTimeout);

	if (rc < 0)
	{
		if (*return_code != ETIME)
			MTM_LOG(*return_code);
		return;
	}

	/*
	*	Signal the MTM Process that a service control message is pending.
	*/
#ifdef DEBUG
	(void)fprintf(stdout,"MTMCntrl: Signalling %d\n",mtm_process_id);
	(void)fflush(stdout);
#endif
	if ((rc = sca_write (	MTMFifoFd,
				MTM_CONTROL_MSG_FLAG,
				MTM_MSG_FLAG_SIZE)) == FAILURE)
	{
		MTM_LOG(errno);
		*return_code = errno;
		return;
	}

	/*
	*	Get reply message header.
	*/
#ifdef DEBUG
	(void)fprintf(stdout,"MtmCntrl: PID = %d\n",current_process_pid);
	(void)fflush(stdout);
#endif
	CtrlTimeout.value = 10;

	sca_SetupTimer((void *)MTMCntrl, &CtrlTimeout, (void *)ctrl_signal_catcher);

	rc = sca_msgrcv(mtm_cntrl_qid,
		(struct msgbuf *)MTMMsgBuffer,
		(MAX_MSG_SIZE+sizeof(MTM_MSG_HEADER)),
		(long)current_process_pid,
		(int)0,
		&CtrlTimeout,
		return_code);

	sca_CancelTimer((void *)MTMCntrl, &CtrlTimeout);

	if (rc < 0)
	{
		if (*return_code != ETIME)
			MTM_LOG(errno);
		return;
	}

	/*
	*	Check if message header is usable
	*/
	pHeader = (MTM_MSG_HEADER *)MTMMsgBuffer;
	if (pHeader == NULL)
	{
		*return_code = EFAULT;
		MTM_LOG(*return_code);
		return;
	}

#ifdef DEBUG
	(void)fprintf(stdout,"Return code %d\n",pHeader->return_code);
	(void)fprintf(stdout,"Reason code %d\n",pHeader->reason_code);
	(void)fflush(stdout);
#endif

	/*
	*	If the first byte of the message is the character 0, SUCCESS
	*/
	if(pHeader->return_code == SUCCESS)
	{
		switch(save_cmd)
		{
			case SVSTAT:
			case CLSTAT:
			case GETVER:
			case GETPARAM:
			case SVCLEAN:
			case PEND:
			case GETSTAT:
				*reply = (MTMMsgBuffer+sizeof(MTM_MSG_HEADER));
#ifdef DEBUG
	(void)fprintf(stdout,"Reply length = %d \n",pHeader->length);
	(void)fprintf(stdout,"Reply = %s \n",*reply);
	(void)fprintf(stdout,"Reply Str Length = %d \n",strlen(*reply));
	(void)fflush(stdout);
#endif
				break;
			default:
				break;
		}
	}
	else
	{
		*return_code = pHeader->reason_code;
	}
	
#ifdef DEBUG
	(void)fprintf(stdout,"Returning from MTMCntrl\n");
	(void)fflush(stdout);
#endif

	if (MTMFifoFd != DISCONNECTED)
	{
		close (MTMFifoFd);
		MTMFifoFd = DISCONNECTED;
	}
	return;
}

/*
*	ctrl_signal_catcher
*	[module number i.e. Future] [module name]
*
*	Description:
*
*/
void
ctrl_signal_catcher(int sig)
{
#ifdef DEBUG
	fprintf(stdout,"ctrl_signal_catcher: CTRL PID %d caught signal %d\n",getpid(),sig);
	fflush(stdout);
#endif
	CtrlTimeout.flag = 1;
}




/*
 * MTMRunning
 *
 * Descritption:
 *	$ZCall to determine if a given MTM is running.
 *
 * Return:
 */
void
MTMRunning (	int 	count,
		char	*mtm_id,
		SLONG	*return_code)
{
	int		fd;
	char		pathname[_POSIX_PATH_MAX + 1];
	SLONG		is_alive;
	int		value;
	char		*env_val;
        char            mtm_env[MAX_NAME_LEN];
 
        memset(mtm_env,0,MAX_NAME_LEN);
        env_val = getenv ("MTM_DIR");
 
        if (env_val != NULL)
                strcpy (mtm_env, env_val);
        else
                sprintf(mtm_env,"%s",MTM_TMP_DIR);
 
/*dag Sep 18 98 to take care of signal handler conflict in gtm 4.0*/
        do {
                value = sprintf (pathname, "%s/%s", mtm_env, mtm_id);
        }
        while (value < 0 && errno == EINTR);

	if ((fd = sca_open (pathname, O_RDONLY)) == FAILURE)
	{
		/* 
		 * file does not exist, which means that the MTM to create the file 
		 * does not exist.
		 */
		if (errno == ENOENT)				
			is_alive = FALSE;
		else
		{
			MTM_LOG(errno);
			is_alive = FALSE;
		}
	}
	else
	{
		if (mtm_lock_reg (fd, F_SETLK, F_WRLCK, 0, SEEK_SET, 0) == FAILURE)
		{
			/*
		 	* If the file exists and the MTM is still holding
		 	* the lock, then the MTM is running
		 	*/
			if (errno == EAGAIN || errno == EACCES)
				is_alive = TRUE;
			else
			{
				MTM_LOG(errno);
				is_alive = FALSE;
			}
		}
		else
		{
			is_alive = FALSE;
			/*
			 * release the lock
			 */
			if (mtm_lock_reg (fd, F_SETLK, F_UNLCK, 0, SEEK_SET, 0) == FAILURE)
				MTM_LOG(errno);
		}

		sca_close (fd);
	}

	*return_code = is_alive;
	return;
}
