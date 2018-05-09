/*
*	mtmutils.c - Sanchez Message Transport Manager for UNIX
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	ORIG:	Sara G. Walters - 11 Jan 1995
*
*	DESC:	
*		Utility routines for the MTM.
*
*   $Id: mtmutils.c,v 1.2 2000/06/02 15:31:35 lyh Exp lyh $
*   $Log:	mtmutils.c,v $
 * Revision 2.16  07/02/15  thoniyim
 * Added an error message to the mtm_msgs[] array at index 50 to 
 * indicate MTM_STATS_RUNNING
 *
 * Revision 2.15  05/12/06  paulj
 * Added an error message to the mtm_msgs[] array at index 46 to 
 * indicate MTM_NO_STATS
 *
 * Revision 2.14  05/01/18  thoniyim
 * Modified to send an unsolicited message to a connected client in ASYNC MTM
 * (MTM V2.4.1)
 *
 * Revision 2.13  04/03/10  thoniyim
 * Changed the flags to counters for the messages from server
 * (MTM V2.1.0)
 *
 * Revision 2.12  00/07/06  17:18:20  17:18:20  lyh ()
 * Removed certain restrictions for tcp client (MTM v2.0.1)
 * 
 * Revision 2.11  00/06/02  13:32:15  13:32:15  lyh ()
 * Changes as a result of porting to other platforms.
 * 
 * Revision 2.10  00/05/24  14:02:51  14:02:51  lyh ()
 * Syntax fix as a result of porting to HPUX
 * In section get_version, declare temp as
 * char *temp
 * instead of
 * unsigned char *temp
 * 
 * Revision 2.9  00/05/11  09:14:09  09:14:09  lyh ()
 * Changed the declaration of returned value in mtm_enable_sd
 * and mtm_disable_sd from SLONG to int as a result of Linux port.
 * 
 * Revision 2.8  00/04/25  17:16:48  17:16:48  lyh ()
 * Bug fix as a result of linux port
 * 
 * Revision 2.7  00/04/06  15:25:42  15:25:42  lyh ()
 * correct section mtm_efd - no wonder errors are not logging... ugh!
 * 
 * Revision 2.6  00/03/29  16:05:43  16:05:43  lyh ()
 * wogm release.
 * 
 * Revision 2.5  00/03/27  15:57:03  15:57:03  lyh ()
 * wogm release
 * 
 * Revision 2.4  00/03/23  10:46:39  10:46:39  lyh ()
 * Reworked connected_clients() function
 * Added mtm_disable_sd() and mtm_enable_sd() functions
 * 
 * Revision 2.3  00/03/03  15:12:41  15:12:41  lyh ()
 * sand comber release
 * 
 * Revision 2.2  00/01/20  13:24:20  13:24:20  lyh ()
 * added client get and send message apis
 * 
 * Revision 2.1  00/01/17  11:16:12  11:16:12  lyh ()
 * storm trooper release
 * 
 * Revision 1.3  99/12/28  13:21:56  13:21:56  lyh ()
 * remove the tab character in version string
 * 
 * Revision 1.2  99/12/28  11:14:31  11:14:31  lyh ()
 * added 3 new control messages: SENDMSG, GETVER, GETPARAM
 * 
 * Revision 1.1  99/12/27  16:00:29  16:00:29  lyh ()
 * Initial revision
 * 
 * Revision 1.3  96/03/21  15:04:23  15:04:23  zengf (Fan Zeng)
 * Collapsed directories and replaced signals with fifos.
 * 
 * Revision 1.2  96/03/13  10:02:18  10:02:18  zengf (Fan Zeng)
 * prepare for removing signals
 * 
 * Revision 1.1  96/02/28  17:28:45  17:28:45  zengf (Fan Zeng)
 * Initial revision
 * 
 * Revision 1.4  95/08/11  11:10:20  11:10:20  rcs ()
 * Removed reference to _FILE_ and _LINE_
 * 
 * Revision 1.3  95/07/19  14:27:24  14:27:24  rcs ()
 * Bug fixes as a result of MTM System test.
 * 
 * Revision 1.2  95/05/22  15:16:39  15:16:39  sca ()
 * I VMS
 * 
*   $Revision: 2.12 $
*
*/

#include	<time.h>
#include	<stdio.h>
#include	<errno.h>
#include 	<stdarg.h>
#include	<sys/types.h>
#include	<sys/socket.h>
#include	<sys/socketvar.h>
#include	<sys/ioctl.h>
#include    	"./scatype.h"
#include	"./mtmerrno.h"
#include	"./mtmmsgs.h"
#include	"./mtm.h"
#include	"./mtmext.h"

static char *VERSION[] = 
{
        "LINUX MTM V2.4.5 12 Mar 2007",
	"Stats from Messages queues can be collected for sync messages",
	"Server can send messages to connected Async clients",
	"Supports 1MB Strings/Data",
	"Message queues are created as IPC_PRIVATE",
	"User can set $MTM_DIR to specify a directory other than /tmp/MTM",
        "The server message flags are changed to counters",
        "Also from previous version:",
	"  1. The restriction of one and only client in async mode is removed.",
	"  2. Use repeat count to connect to foreign host multiple times.",
	"  3. Specify host IP and port number in SENDMSG control message.",
	"  Please refer to release documentation for complete detail.",
	NULL
};

static char *mtm_msgs[] =
{
		"SCAMTM ERROR:		Invalid reason code.",
		"SCAMTM ERROR:		Received control message with invalid command field.",
		"SCAMTM NOTIFICATION:	Stop command successfully processed.",
		"SCAMTM NOTIFICATION:	Shutdown is pending.",
		"SCAMTM ERROR:		Duplicate connection",
		"SCAMTM ERROR:		Connection attempted. Maximum number of servers already running.",
		"SCAMTM NOTIFICATION:	Server connected successfully.",
		"SCAMTM ERROR:		Received control message with invalid Server ID field.",
		"SCAMTM ERROR:		Server did not Reply to Client Request",
		"SCAMTM NOTIFICATION:	Server disconnected successfully.",
		"SCAMTM NOTIFICATION:	Server journaling is on.",
		"SCAMTM NOTIFICATION:	Server journaling is off.",
		"SCAMTM ERROR:		No journal file exist.",
		"SCAMTM NOTIFICATION:	No Servers are currently connected.",
		"SCAMTM NOTIFICATION:	No clients are currently connected.",
		"SCAMTM ERROR:		Received control message with invalid journal flag.",
		"SCAMTM NOTIFICATION:	Client Pending Messages command successfully processed.",
		"SCAMTM NOTIFICATION:	Client Statistics command successfully processed.",
		"SCAMTM NOTIFICATION:	Server Statistics command successfully processed.",
		"SCAMTM NOTIFICATION:	No active servers.",
		"SCAMTM NOTIFICATION:	Received control message with invalid server type field.",
		"SCAMTM ERROR:		Usage: mtm -lLOGFILE  sMAXMSGSIZE -cVALIDCLIENTS.",
		"SCAMTM NOTIFICATION:	MTM startup is successful.",
		"SCAMTM ERROR:		Client state is invalid.",
		"SCAMTM ERROR:		Client Table is full.",
		"SCAMTM ERROR:		Active message table is full.",
		"SCAMTM NOTIFICATION:	MTM startup is successful.",
		"SCAMTM ERROR:		Client Routing Table is full.",
		"SCAMTM NOTIFICATION:	Client is already connected.",
		"SCAMTM ERROR:		Remote host is not configured.",
		"SCAMTM NOTIFICATION:	Client is not connected.",
		"SCAMTM ERROR:		Invalid control message.",
		"SCAMTM ERROR:          All Servers deleted.",
		"SCAMTM ERROR:          Message is too big.",
		"SCAMTM ERROR:          Invalid Message.",
		"SCAMTM ERROR:          Server disconnected.",
		"SCAMTM ERROR:          Server type does not exist.",
		"SCAMTM ERROR:          MTM send failed.",
		"SCAMTM ERROR:          No MTM is running.",
		"SCAMTM ERROR:          Unauthorize client connection attempted.",
		"SCAMTM ERROR:          MTM started.",
		"SCAMTM ERROR:          Control message SENDMSG failed.",
		"SCAMTM ERROR:          Control message GETVER failed.",
		"SCAMTM ERROR:          Control message GETPARAM failed."
		"SCAMTM ERROR:			",
		"SCAMTM ERROR:           ",
		"SCAMTM ERROR:           ",
		"SCAMTM ERROR:          MTM Stats is not running.",
		"SCAMTM ERROR:           ",
		"SCAMTM ERROR:           ",
		"SCAMTM ERROR:           ",
		"SCAMTM ERROR:          MTM Stats already running."

};

static SLONG	NumberLogErrors = 0;
static SLONG	FileIndex = 1;

void
mtm_efd(SLONG reason_code, char *source_file, SLONG source_line)
{
	va_list args;
	va_list va_alist;

	FILE	*fp;
	time_t	cal_time;
	char temp[MAX_NAME_LEN];

	/*
	 *	Use stand output if log file is not open yet
	 */
	if (MTMLogFp == NULL)
		fp = stdout;
	else
	{
		fp = MTMLogFp;

		/*
		*	Should we switch log file?
		*/
		if (NumberLogErrors > MAX_LOG_ERRORS)
		{
#ifdef DEBUG
	fprintf(stdout,"mtm_efd: Number of errors so far: %d\n",NumberLogErrors);
	fflush(stdout);
#endif
			NumberLogErrors = 0;
			/*
			*	start a new log file
			*/
			memset(temp,0,sizeof(temp));
			sprintf(temp,"%s%d",MTMLogFileName,FileIndex++);
			if ( (fp = fopen(temp,"a")) == NULL )
			{
				/* 
				*	oh well, we tried but it's not there
				*/
				fp = MTMLogFp;
			}
			else
			{
				fprintf(MTMLogFp,"------------------------\n");
				fprintf(MTMLogFp,"Starting new log file: %s\n",
						temp);
				fprintf(MTMLogFp,"------------------------\n");
				fflush(MTMLogFp);
				fclose(MTMLogFp);
				MTMLogFp = fp;
			}
		}
	}


	NumberLogErrors++;
	(void)fprintf(fp,"\nMTM error count: %d\n",NumberLogErrors);
	if(reason_code > 0)
	{
		(void)fprintf(fp,"SYSTEM ERROR:\tReason Code: %d\n",reason_code);
		(void)fprintf(fp,"ERROR:\tMessage: %s\n",strerror(reason_code));
	}
	else
	{
		(void)fprintf(fp,"SCA ERROR:\tReason Code: %d\n",reason_code);
		if(reason_code < 0)
			(void)fprintf(fp,"ERROR:\tMessage: %s\n",mtm_msgs[abs(reason_code)]);
	}
	time (&cal_time);
	fprintf(fp,"ERROR:\tFile: %s Line: %d\n", source_file, source_line);
	fprintf(fp,"ERROR:\tTimestamp: %s\n", ctime (&cal_time));
	fflush(fp);
}

/*
 *	mtm_get_server_type
 *
 *	Description
 *		Get the array index of a given server type name if it exists on MTM
 *		or assign a new index to the name if it does not exist and if there
 *		are empty slots.
 *
 *	Return
 *		Return index of in the server table if sucess, otherwise return
 *		FAILURE.
 */
SLONG
mtm_get_server_type (char *srv_type_name, short reg)
{
	int			i;

#ifdef DEBUG
	fprintf (stdout, "mtm_get_server_type: srv_type_name is %s\n", srv_type_name);
	fflush(stdout);
#endif

	/*
	 * find a matching server type
	 */
	for (i = 0; i < MAX_SRV_TYPES; i++)
		if (strcmp (MTMSrvTbl[i].srv_type_name, srv_type_name) == 0)
			return (i);

	/*
	 * register this new server type?
	 */
	if (reg == FALSE)
		return (FAILURE);

	/*
	 *	Server type does not exist, find an empty slot
	 */
	for (i = 0; i < MAX_SRV_TYPES; i++)
		if (MTMSrvTbl[i].srv_type_name[0] == '\0')
			break;

#ifdef DEBUG
	fprintf (stdout, "mtm_get_server_type: srv_type is %d\n", i);
	fflush(stdout);
#endif

	if (i == MAX_SRV_TYPES)
		return (FAILURE);
	else
	{
		strcpy (MTMSrvTbl[i].srv_type_name, srv_type_name);
		return (i);
	}
}


void
mtm_fcntl (int fd, int flags, int opt)
{
	int	val;

	if ( (val = fcntl (fd, F_GETFL, 0)) < 0)
	{
		MTM_EFD (errno);
	}

	/* set of clear the flags according to the value of opt */
	if (opt)
		val |= flags;
	else 
		val &= ~flags;

	if (fcntl (fd, F_SETFL, val) < 0)
	{
		MTM_EFD (errno);
	}
}


/*
 *	mtm_find_any_server
 *
 *	Description
 *		Loop thru the server table and find a valid one.
 *
 *	Return
 *		Return index of in the server table if sucess, otherwise return
 *		FAILURE.
 */
SLONG
mtm_find_any_server()
{
	int			i;

	/*
	 * Return the first "valid" server.
	 * This can be modified to return a random server.
	 * However, it's a little bit difficult because we
	 * can't be sure if all servers are active at this
	 * time.
	 */
	for (i = 0; i < MAX_SRV_TYPES; i++)
		if (MTMSrvTbl[i].srv_type_name[0] != '\0')
			return (i);

	/*
	 * none found, give up!!!
	 */
	return (FAILURE);

}


/*
 *	get_version
 *
 *	Description
 *		Simply return VERSION.
 *
 *	Return
 *		Return character pointer to the string VERSION
 *		defined in mtm.h
 */
char * get_version()
{
	static int index = 0;
	char *temp;

	temp = VERSION[index];
	if (temp == NULL)
		index = 0;
	else
		index++;

	return(temp);
}



/*
 *	connected_clients
 *
 *	Description
 *		Returns the number of clients currently connected.
 *
 */
int connected_clients()
{
	int count = 0;
	int i;

	for (i = 0; i < MTMMaxClient; i++)
	{
		if (MTMRoutingTbl[i].sd == DISCONNECTED)
			continue;
		else
			count++;
	}

	return(count);
}

/*
*       mtm_skt_active
*       [module number i.e. Future] [module name]
*
*       Description:
*       Perform a select() on an individual socket descriptor to see if it's
*       active.
*
*       Returns:
*       TRUE    socket is active
*       FALSE   socket is not active (error pending or abandoned connection)
*/
SLONG
mtm_skt_active(int sd)
{
	fd_set          exceptlist;
	struct timeval  nowait;
	int             rc;
 
	/*
	*	Init exception mask
	*/
	FD_ZERO(&exceptlist);

	/*
	*	Set exception mask with current socket descriptor
	*/
	FD_SET(sd, &exceptlist);

	/*
	*	Zero out timer because we want to return immediately
	*/
	memset(&nowait, 0, sizeof(nowait));

	/*
	*	Call select() to poll the status of the socket
	*/
	rc = select(FD_SETSIZE,
			(fd_set *)NULL,
			(fd_set *)NULL,
			&exceptlist,
			&nowait);

	/*
	*	If rc is 0 (meaning socket is ready), return TRUE.
	*	If rc is < 0 (meaning select() failed), return TRUE if
	*	errno is EINTR, FALSE otherwise.
	*	If rc is > 0 (meaning socket has an exception), return FALSE.
	*/
	if (rc == 0)
		return TRUE;
	else if (rc < 0)
		return (errno == EINTR ? TRUE : FALSE);
	return(FALSE);
}


/*
*       mtm_proc_active
*       [module number i.e. Future] [module name]
*
*       Description:
*       Perform a ps command and grep on process id to see if it's still in
*	the process table.
*
*       Returns:
*       TRUE    process is active
*       FALSE   process is not active (not existed on in zombie state)
*	FAILURE	can not determine process status (probably due to a broken 
*		pipe error)
*/
int
mtm_proc_active(pid_t pid)
{

	FILE	*fpin;
	char	cmd[80];
	char	line[80];
	char	stat;
	pid_t	temp;
	int	active;	/* value to be returned */

#ifdef DEBUG
	fprintf(stdout,"mtm_proc_active: is process %d active?\n",pid);
	fflush(stdout);
#endif

	/*
	*	Init
	*/
	active = FALSE;
	memset(line, 0, sizeof(line));

	/*
	*	Format command: ps -ef | grep pid
	*/
	sprintf(cmd, "ps -e -o pid,stat | grep %d", pid);
#ifdef DEBUG
	fprintf(stdout,"\t cmd is %s\n",cmd);
	fflush(stdout);
#endif

	/*
	*	Create pipe and execute command
	*/
	if ( (fpin = popen(cmd, "r")) == NULL )
		return(FAILURE);

	/*
	*	Read the pipe stream
	*/
	while (fgets(line, sizeof(line), fpin) != NULL)
	{
#ifdef DEBUG
	fprintf(stdout,"\t fgets result: %s\n",line);
	fflush(stdout);
#endif
		/*
		*	line format: PID ST
		*	strip PID and ST from line
		*/
		sscanf(line, "%d %c", &temp, &stat);
#ifdef DEBUG
	fprintf(stdout,"\t temp is %d, stat is %c\n",temp,stat);
	fflush(stdout);
#endif
		if ((temp == pid) && 
		    (stat != 'O') &&
		    (stat != 'T') &&
		    (stat != 'Z'))
		{
			/*
			*	Yep, process is still active
			*/
			active = TRUE;
			break;
		}
	}

	/*
	*	All done - close the pipe and return active
	*/
	pclose(fpin);

#ifdef DEBUG
	fprintf(stdout,"mtm_proc_active: end of routine - returning active = %d\n",active);
	fflush(stdout);
#endif
	return(active);
}

/*
*	mtm_disable_sd
*
*	Description:
*	Turn on the non-blocking flag for the MTM listening socket.
*	
*/
int mtm_disable_sd()
{
	int	option_val;
	int	rc = SUCCESS;
	time_t	cal_time;

#ifdef DEBUG
	fprintf(stdout,"mtm_disable_sd: Start of routine\n");
	fflush(stdout);
#endif

	/*
	*	Log a message
	*/
	time(&cal_time);
	fprintf(MTMLogFp,"\n?????????????????????????????????\n");
	fprintf(MTMLogFp,"mtm_disable_sd: current time is %s",ctime(&cal_time));
	fprintf(MTMLogFp,"\tDisallowing new client connection requests\n");
	fflush(MTMLogFp);

	/*
	*	Force socket in non-blocking mode
	*/
	option_val = TRUE;
	if((rc = ioctl(MTMListenSd,FIONBIO,&option_val)) == FAILURE)
	{
		MTM_EFD(errno);
	}

	/*
	*	Log another message
	*/
	fprintf(MTMLogFp,"mtm_disable_sd: completed with rc = %d",rc);
	fprintf(MTMLogFp,"\n?????????????????????????????????\n");
	fflush(MTMLogFp);

#ifdef DEBUG
	fprintf(stdout,"mtm_disable_sd: End of routine, rc is %d\n",rc);
	fflush(stdout);
#endif

	return(rc);
}

/*
*	mtm_enable_sd
*
*	Description:
*	Turn off the non-blocking flag for the MTM listening socket.
*	
*/
int mtm_enable_sd()
{
	int	option_val;
	int	rc = SUCCESS;
	time_t	cal_time;

#ifdef DEBUG
	fprintf(stdout,"mtm_enable_sd: Start of routine\n");
	fflush(stdout);
#endif

	/*
	*	Log a message
	*/
	time(&cal_time);
	fprintf(MTMLogFp,"\n?????????????????????????????????\n");
	fprintf(MTMLogFp,"mtm_enable_sd: current time is %s",ctime(&cal_time));
	fprintf(MTMLogFp,"\tAllowing new client connection requests\n");
	fflush(MTMLogFp);

	/*
	*	Force socket in blocking mode
	*/
	option_val = FALSE;
	if((rc = ioctl(MTMListenSd,FIONBIO,&option_val)) == FAILURE)
	{
		MTM_EFD(errno);
	}

	/*
	*	Log another message
	*/
	fprintf(MTMLogFp,"mtm_enable_sd: completed with rc = %d",rc);
	fprintf(MTMLogFp,"\n?????????????????????????????????\n");
	fflush(MTMLogFp);

#ifdef DEBUG
	fprintf(stdout,"mtm_enable_sd: End of routine, rc is %d\n",rc);
	fflush(stdout);
#endif
	return(rc);
}



/*
*       get_proc_st_pcpu
*       [module number i.e. Future] [module name]
*
*       Description:
*       Perform a ps command and grep on process id to see the process status
*	and %cpu time.
*/
void
get_proc_st_pcpu(pid_t pid, char *st, float *cpu)
{

	FILE	*fpin;
	char	cmd[80];
	char	line[80];
	char	stat;
	float	cputime;
	pid_t	temp;
	int	active;	/* value to be returned */

	/*
	*	Init
	*/
	*st = '?';
	*cpu = 0.0;
	memset(line, 0, sizeof(line));

	/*
	*	Format command: ps -ef | grep pid
	*/
	sprintf(cmd, "ps -e -o pid,stat,pcpu | grep %d", pid);

	/*
	*	Create pipe and execute command
	*/
	if ( (fpin = popen(cmd, "r")) == NULL )
		return;

	/*
	*	Read the pipe stream
	*/
	while (fgets(line, sizeof(line), fpin) != NULL)
	{
		/*
		*	line format: PID ST
		*	strip PID and ST from line
		*/
		sscanf(line, "%d %c %f", &temp, &stat, &cputime);
		if (temp == pid)
		{
			/*
			*	Yep, process is still active
			*/
			*st = stat;
			*cpu = cputime;
			break;
		}
	}

	/*
	*	All done - close the pipe and return active
	*/
	pclose(fpin);

	return;
}
