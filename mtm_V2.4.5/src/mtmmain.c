/*
*	mtmmain.c - Sanchez Message Transport Manager for UNIX
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	ORIG:	Sara G. Walters - 11 Jan 1995
*
*	DESC:	
*
*   $Id$
*   $Log:	mtmmain.c,v $
 * Revision 2.12  05/12/06  paulj ()
 * Added MTM_STATS_TABLE to store the MTM Statistics and modified 
 * mtm_initialize() to initialize the structure.
 *
 * Revision 2.11  04/06/12  thoniyim ()
 * The message queue creation is changed to use IPC_PRIVATE.
 * ftok() is not used to create ipc_key information.
 * MTM now writes the queue id information to a .qid file.
 * The user can specify an environment variable, $MTM_DIR, with
 * the directory info for the MTM files (.info,.lock,...)
 * 
 * Revision 2.10  04/02/04  thoniyim ()
 * Changed the flags MTMSignalFlags.cntrl_msg and
 * MTMSignalFlags.server_msg to counters
 *
 * Revision 2.9  00/07/06  17:18:08  17:18:08  lyh ()
 * Removed certain restrictions for tcp client (MTM v2.0.1)
 * 
 * Revision 2.8  00/06/02  13:28:01  13:28:01  lyh ()
 * Changes as a result of porting to other platforms.
 * 
 * Revision 2.7  00/04/25  17:16:29  17:16:29  lyh ()
 * Bug fix as a result of linux port
 * 
 * Revision 2.6  00/03/30  13:42:49  13:42:49  lyh ()
 * Minor correction
 * 
 * Revision 2.5  00/03/29  09:35:26  09:35:26  lyh ()
 * Changed length format to pattern matching instead of using option
 * 
 * Revision 2.4  00/03/23  10:37:50  10:37:50  lyh ()
 * Replaced the call mtm_skt_connect() with mtm_skt_accept()
 * 
 * Revision 2.3  00/03/03  15:11:40  15:11:40  lyh ()
 * sand comber release
 * 
 * Revision 2.2  00/01/20  13:24:02  13:24:02  lyh ()
 * added client get and send message apis
 * 
 * Revision 2.1  00/01/17  11:16:11  11:16:11  lyh ()
 * storm trooper release
 * 
 * Revision 1.3  99/12/29  16:30:19  16:30:19  lyh ()
 * redo the init and shutdown sections
 * 
 * Revision 1.2  99/12/28  11:15:22  11:15:22  lyh ()
 * added 3 new control messages: SENDMSG, GETVER, GETPARAM
 * 
 * Revision 1.1  99/12/27  15:59:48  15:59:48  lyh ()
 * Initial revision
 * 
 * Revision 1.11  96/04/25  16:13:14  16:13:14  zengf (Fan Zeng)
 * fix client message bug.
 * 
 * Revision 1.10  96/04/17  15:16:45  15:16:45  zengf (Fan Zeng)
 * Fixed stats.
 * 
 * Revision 1.9  96/04/10  17:21:28  17:21:28  zengf (Fan Zeng)
 * General cleaning up
 * 
 * Revision 1.8  96/03/21  15:04:18  15:04:18  zengf (Fan Zeng)
 * Collapsed directories and replaced signals with fifos.
 * 
 * Revision 1.7  96/03/13  10:02:17  10:02:17  zengf (Fan Zeng)
 * prepare for removing signals
 * 
 * Revision 1.6  96/02/28  17:28:38  17:28:38  zengf (Fan Zeng)
 * substantially rewrite MTM and the APIs.
 * 
 * Revision 1.5  96/02/05  16:24:05  16:24:05  zengf (Fan Zeng)
 * Replacd function signal() with functions mtm_signal and mtm_signal_intr,
 * which are implemented with reliable signal function sigaction ().
 * 
 * Revision 1.4  96/02/05  15:44:58  15:44:58  zengf (Fan Zeng)
 * Check in the changes that were never logged. These changes were probably 
 * made by Sara G. Walters.
 * 
 * Revision 1.3  95/07/19  14:16:28  14:16:28  rcs ()
 * Bug fixes as a result of MTM System Test
 * 
 * Revision 1.2  95/05/22  14:49:30  14:49:30  sca ()
 * sgI VMS
 * 
*   $Revision: 2.9 $
*
*/

#include	<ctype.h>
#include	<fcntl.h>
#include	<stdio.h>
#include	<stdlib.h>
#include	<time.h>
#include	<sys/time.h>
#include	<errno.h>
#include	<unistd.h>
#include	<signal.h>
#include	<sys/ipc.h>
#include	<sys/sem.h>
#include	<sys/shm.h>
#include	<sys/select.h>
#include	"./scatype.h"
#include	"./mtm.h"

/*
*	Declare Globals for the Message Transport Monitor
*/
MTM_STATS_TABLE     MTMStatsTbl[MAX_SRV_TYPES];
MTM_SIGNAL_FLAGS 		MTMSignalFlags;
MTM_SERVER_TYPE_TABLE		MTMSrvTbl[MAX_SRV_TYPES];
MTM_CLIENT_ROUTING_TABLE 	*MTMRoutingTbl;
char				*MTMValidClients = (char *) NULL;
SLONG 				MTMControlQid = DISCONNECTED;
SLONG 				MTMServerReplyQid = DISCONNECTED;
int				MTMLockFd;
char				MTMLockFileName[MAX_NAME_LEN];
int				MTMFifoFd = DISCONNECTED;
char				MTMFifoName[MAX_NAME_LEN];
FILE 				*MTMLogFp = (FILE *)NULL;
char				MTMLogFileName[MAX_NAME_LEN];
char				MTMProcessName[MAX_NAME_LEN];
SLONG 				MTMProcessId;
SLONG 				MTMMaxMsgSize;
SLONG				MTMInternetPort;
SLONG				MTMMaxClient;
SLONG 				MTMShutDownPending;
SLONG 				TotalActiveReqst;
SLONG 				TotalActiveSrvs;
SLONG 				TotalClientsConnected;
char 				*MTMMsg;
fd_set				MTMReadMask;
SLONG 				MTMListenSd;
char				MTMDebugFileName[MAX_NAME_LEN];
FILE				*MTMFdDebug = (FILE *)NULL;
SLONG				MTMAsyncMode;
st_length			MTMLength;
st_timeout			MTMTimeout;
st_tcpclient			*MTMTcpClient = (st_tcpclient *)NULL;
st_tcpclient			*MTMAsyncClient = (st_tcpclient *)NULL;
int				MTMTcpCount = 0;
char				MTMRootIp[IP_ADDR_LEN+1];

/*
*	Static Prototypes
*/
static RETURNSTATUS mtm_initialize(SLONG,char **);

/*
*	Local prototypes
*/
void mtm_trap_signals();

/*
*	main:
*	[module number i.e. Future] [module name]
*
*	Description:
*	Main C entry point for Message Transport Manager Process
*
*	Returns:
*
*/
main(SLONG  argc, char *argv[])
{
   	RETURNSTATUS	rc = SUCCESS;
	int register	i = 0;

#ifndef MTM_ATTACHED
	/*
   	*	Fork a copy of the Message Transport Manager so that 
	*	return can be given back to MUMPS after a ZSYSTEM call.
   	*/
	if((rc = fork()) == FAILURE)
	{
		MTM_EFD(errno);
		exit(EXIT_FAILURE);
	}
	else if(rc > SUCCESS)
	{
		exit(EXIT_SUCCESS);
	}
#endif

	/*
	*	Trap MTM signals
	*/
	mtm_trap_signals();

	/*
	*	Set up timer related function
	*/
	MTMTimeout.type = sca_AlarmSetup(0);

   	/*
   	*	Initialize the Message Transport
   	*/
   	if((rc = mtm_initialize(argc,argv)) != SUCCESS)
		mtm_shutdown();

	/*
	*	Set up the listen socket.
	*/
	FD_ZERO(&MTMReadMask);

	if(mtm_skt_init() == FAILURE)
	{
		mtm_shutdown();
	}

#ifdef DEBUG
	(void)fprintf(stdout,"%d:MTM Successfully Initialized\n",MTMProcessId);
	(void)fflush(stdout);
#endif

   	/*
   	*	MTM Main Process Loop
   	*/
	for(;;)
	{
		if((MTMSignalFlags.server_msg == 0)
			&& (MTMSignalFlags.cntrl_msg == 0)
    		&& (MTMSignalFlags.connection_reqst == FALSE)
			&& (MTMSignalFlags.client_msg == FALSE))
		{
			mtm_pause();
		}

		/*
		*	Server reply message has highest priority
		*/
		if(MTMSignalFlags.server_msg > 0)
		{
#ifdef DEBUG
	(void)fprintf(stdout,"%d:MTM received server message\n",MTMProcessId);
	(void)fflush(stdout);
#endif
			mtm_server_msg();
			MTMSignalFlags.server_msg--;
		}

		/*
		*	Server Control message 
		*/
		if(MTMSignalFlags.cntrl_msg > 0)
		{
#ifdef DEBUG
	(void)fprintf(stdout,"%d:MTM received control message\n",MTMProcessId);
	(void)fflush(stdout);
#endif
			mtm_control_msg();
			MTMSignalFlags.cntrl_msg--;
		}

		/*
		*	Check for connect or disconnect request
		*/
		if(MTMSignalFlags.connection_reqst == TRUE)
		{
#ifdef DEBUG
	(void)fprintf(stdout,"%d:MTM received client request\n",MTMProcessId);
	(void)fflush(stdout);
#endif
			mtm_skt_accept();
			MTMSignalFlags.connection_reqst = FALSE;
		}

		/*
		*	Check for client message
		*/
		if(MTMSignalFlags.client_msg == TRUE)
		{
#ifdef DEBUG
	(void)fprintf(stdout,"%d:MTM received client message\n",MTMProcessId);
	(void)fflush(stdout);
#endif
			mtm_client_msg();
			MTMSignalFlags.client_msg = FALSE;
		}

		/*
		*	Check the Shutdown reqst pending flag
		*	and Make sure that there are no active reqsts
		*/
		if((MTMShutDownPending == TRUE) && (TotalActiveReqst <= 0))
		{
			mtm_shutdown();
		}

		/*
		*	Check if we need to reconnect as client
		*/
		if (MTMTcpCount)
		{
			tcp_client_connect();
		}
	}
}

/*
*	mtm_initialize
*	[module number i.e. Future] [module name]
*
*	Description:
*	Initializes globals and resources for the Message Transport Monitor Process
*
*	Returns:
*	SUCCESS or FAILURE
*/
static RETURNSTATUS
mtm_initialize(	SLONG  argc,
		char *argv[])
{
	register 	i, j;
   	RETURNSTATUS	rc = SUCCESS;
	MTM_MSG_HEADER	msg_header;
	char		*ptr;
	char		*ptr1;
	char		*envptr;
	struct shmid_ds	shmdata;
	int		errflg = 0;
	char		*host;
	char		*prev;
        FILE		*info_file_ptr;    /*dag*/
        char		info_file_name[80];/*dag*/
        FILE		*qid_file_ptr;    /*mkt*/
        char		qid_file_name[80];/*mkt*/
        time_t		thetime;           /*dag*/
	char		*version_str;
	char		length_str[32];
	char		mtm_env[MAX_NAME_LEN];
	char		*env_val;

	/*
	 * Set MTM run time parameters to default
	 */
	MTMInternetPort = MTM_SERVER_PORT;
	MTMMaxClient = MAX_CLIENTS;
	MTMAsyncMode = FALSE;
	MTMShutDownPending = FALSE;
	TotalActiveReqst = 0;
	TotalActiveSrvs = 0;
	TotalClientsConnected = 0;
	MTMMaxMsgSize = MAX_MSG_SIZE;
	MTMListenSd = DISCONNECTED;
	MTMTcpCount = 0;
	memset(MTMRootIp,0,sizeof(MTMRootIp));
	memset(length_str,'\0',sizeof(length_str));

   	/*
   	*	Get the MTM UNIX Process ID
   	*/
   	MTMProcessId = getpid();

	env_val = getenv ("MTM_DIR");
 
        if (env_val != NULL)
                strcpy (mtm_env, env_val);
        else
		sprintf(mtm_env,"%s",MTM_TMP_DIR);

	MTMLogFileName[0] = '\0';
	MTMProcessName[0] = '\0';
   	/*
   	*    Get the command line options
   	*/
   	while((i = getopt(argc,argv,MTM_CMDLINE_OPTIONS)) != EOF)
		switch(i)
		{
			case MTM_PROCESS_NAME_OPTION:
				strcpy (MTMProcessName, optarg);
				break;
			case MTM_LOGFILE_OPTION:
				(void)strcpy(&MTMLogFileName[0],optarg);
				break;
			case MTM_MAXMSGSIZE_OPTION:
				MTMMaxMsgSize = atoi(optarg);
				break;
			case MTM_VALID_CLIENT_OPTION:
				/*
				 * Add the host ip address to the list
				 */
				prev = host = MTMValidClients;	
				while (host != NULL)
				{
					prev = host;
					host = ((MTM_VALID_CLIENT *)host)->next;
				}

				if ((host = (char *)malloc (sizeof (MTM_VALID_CLIENT))) == NULL)
				{
					MTM_EFD (errno);
					exit(EXIT_FAILURE);
				}
				strcpy (((MTM_VALID_CLIENT *)host)->ip_address, optarg);
				((MTM_VALID_CLIENT *)host)->next = NULL;

				if (prev == NULL)
					MTMValidClients = host;				
				else
					((MTM_VALID_CLIENT *)prev)->next = host;

				break;
			case MTM_MAX_CLIENT_OPTION:
				MTMMaxClient = atoi(optarg);
				break;
			case MTM_SOCKET_PORT_OPTION:
				MTMInternetPort = atoi (optarg);
				break;
			case MTM_ASYNC_MODE_OPTION:
				MTMInternetPort = atoi (optarg);
				MTMAsyncMode = TRUE;
				break;
			case MTM_LENGTH_SIZE_OPTION:
				(void)strcpy(length_str,optarg);
				break;
			case MTM_OTHER_HOST_OPTION:
				if (MTMTcpCount == 0)
					add_tcp_client(optarg);
				break;
			case MTM_ROOT_IP_OPTION:
				(void)strcpy(MTMRootIp,optarg);
				break;
		  	case ':':    /* without arguments */
				fprintf(stdout, "Option -%c requires an argument\n",
						optopt);
				errflg++;
				break;
			default:
				(void)fprintf(stdout, "Usage: mtm -nPROCESSNAME -lLOGFILE -cMAXCLIENT\n");
				(void)fprintf(stdout, "           -pSOCKETPORT [or -aSOCKETPORT] -vVALIDCLIENT -mMAXMSGSIZE\n");
				errflg++;
				break;
		}

	if (errflg || MTMProcessName[0] == '\0')
	{
		MTM_EFD(0);
		exit(EXIT_FAILURE);
	}

	/*
	*	Set to default if MTMMaxClient is more than that
	*/
	if (MTMMaxClient > MAX_CLIENTS)
		MTMMaxClient = MAX_CLIENTS;

	parse_length(length_str,&MTMLength);

	/*
	* Re-direct stdout and stderr to a debug file.
	*/
#ifndef MTM_ATTACHED
	sprintf(MTMDebugFileName,"%s/%s.debug", mtm_env, MTMProcessName);
	if((MTMFdDebug = freopen(MTMDebugFileName,"w",stdout)) == (FILE *)NULL)
	{
		MTM_EFD(errno);
		exit(EXIT_FAILURE);
	}
		
	if((MTMFdDebug = freopen(MTMDebugFileName,"w",stderr)) == (FILE *)NULL)
	{
		MTM_EFD(errno);
		exit(EXIT_FAILURE);
	}
#endif

#ifdef	DEBUG
	(void)fprintf(stdout,	"MTM: child pid %d parent pid %d\n",
		      getpid(),getppid());
	(void)fflush(stdout);
#endif

	/*
	*	open the MTM Log File.
	*/
	if(MTMLogFileName[0] == '\0')
		sprintf (MTMLogFileName, "%s/%s.log", mtm_env, MTMProcessName);
		
   	if ((MTMLogFp = fopen(MTMLogFileName,"a")) == NULL)
	{
		MTM_EFD(errno);
		exit(EXIT_FAILURE);
   	}

   	/*
   	*	Write MTM version
   	*/
	time(&thetime);
	fprintf(MTMLogFp, "----------------------------------------\n");
	fprintf(MTMLogFp, "Starting MTM at %s\n",ctime(&thetime));
	for (;;)
	{
		version_str = get_version();
		if (version_str == NULL)
			break;
		fprintf(MTMLogFp, "%s\n", version_str);
	}

	/*
	*	Write MTM parameters 
	*/
   	(void)fprintf(	MTMLogFp, "Process Name: %s\n", MTMProcessName);
   	(void)fprintf(	MTMLogFp, "Log File: %s\n", MTMLogFileName);
   	(void)fprintf(	MTMLogFp, "Max Msg Size (Default is %d): %d\n",MAX_MSG_SIZE,MTMMaxMsgSize);
   	(void)fprintf(	MTMLogFp, "Valid Clients: %s\n", (MTMValidClients != NULL) ? MTMValidClients : "");
   	(void)fprintf(	MTMLogFp, "Max Clients (Default is %d): %d\n", MAX_CLIENTS, MTMMaxClient);
   	(void)fprintf(	MTMLogFp, "Port Number: %d\n", MTMInternetPort);
   	(void)fprintf(	MTMLogFp, "Async Mode: %d\n", MTMAsyncMode);
   	(void)fprintf(	MTMLogFp, "format: %c\n", MTMLength.format);
   	(void)fprintf(	MTMLogFp, "header: %c\n", MTMLength.header);
   	(void)fprintf(	MTMLogFp, "lsize: %d\n", MTMLength.lsize);
   	(void)fprintf(	MTMLogFp, "hsize: %d\n", MTMLength.hsize);
   	(void)fprintf(	MTMLogFp, "lcount: %d\n", MTMLength.lcount);
   	(void)fprintf(	MTMLogFp, "tcount: %d\n", MTMLength.tcount);
   	(void)fprintf(	MTMLogFp, "----------------------------------------\n");

	/*
	*	open the MTM info file
	*/
	memset  (info_file_name,0,sizeof(info_file_name));
	sprintf (info_file_name,"%s/%s.info",mtm_env,MTMProcessName);
	fprintf(MTMLogFp, "Open info file %s (append mode)\n",info_file_name);
	if ((info_file_ptr = fopen(info_file_name,"a")) == NULL)
	{
		MTM_EFD(errno);
		exit(EXIT_FAILURE);
	}

	/*
	*	open the MTM qid file
	*/
	memset  (qid_file_name,0,sizeof(qid_file_name));
	sprintf (qid_file_name,"%s/%s.qid",mtm_env,MTMProcessName);
	fprintf(MTMLogFp, "Open qid file %s (append mode)\n",qid_file_name);
	if ((qid_file_ptr = fopen(qid_file_name,"w")) == NULL)
	{
		MTM_EFD(errno);
		exit(EXIT_FAILURE);
	}

	/*
	 *	create the file that will be used to determine keys for 
	 * 	message queues and to be used to store MTM processs ID.
	 */
	sprintf (MTMLockFileName, "%s/%s.lock", mtm_env, MTMProcessName);
	fprintf(MTMLogFp, "Unlink lock file %s\n",MTMLockFileName);
	if (unlink (MTMLockFileName) == FAILURE && errno != ENOENT)
	{
		MTM_EFD (errno);
		exit (EXIT_FAILURE);
	}

	fprintf(MTMLogFp, "Open lock file %s (create mode)\n",MTMLockFileName);
	if ((MTMLockFd = open (MTMLockFileName, O_WRONLY | O_CREAT, PERMISSIONS)) == FAILURE)
	{
		MTM_EFD (errno)
		exit (EXIT_FAILURE);
	}

	fprintf(MTMLogFp, "Write process pid to lock file\n");
	if (write (MTMLockFd, (char *) &MTMProcessId, sizeof (SLONG)) == FAILURE)
	{
		MTM_EFD (errno)
		exit (EXIT_FAILURE);
	}
	
	fprintf(MTMLogFp, "Lock a region in the lock file\n");
	if (mtm_lock_reg (MTMLockFd, F_SETLK, F_WRLCK, 0, SEEK_SET, 0) == FAILURE)
	{
		MTM_EFD (errno)
		exit (EXIT_FAILURE);
	}
	
	/*
	*	Create the MT Server Reply Message Queue
	*/
	fprintf(MTMLogFp, "Creating server reply queue\n");
/***
 *	thoniyim - 05/24/2004
 *	On SOLARIS, when ftok is used to created ipc_key and 
 *	the number of MTMs are more, duplicate keys are generated.
 *	This happened at KTB and 2 MTMs were sharing one queue. To
 *	avoid this situation IPC_PRIVATE is used in msgget, to make
 *	sure unique ids are generated.
 ***/
	if((MTMServerReplyQid = msgget(IPC_PRIVATE,
		(PERMISSIONS | IPC_CREAT))) == FAILURE)
	{
		MTM_EFD(errno);
		return FAILURE;
	}

	fprintf(MTMLogFp, "Write Server Reply Qid to qid file\n");
	time(&thetime);
	fprintf (qid_file_ptr,"MTM name: %s %s",MTMProcessName,ctime(&thetime));
	fprintf (qid_file_ptr,"MTM Process ID:%d",MTMProcessId);
	fprintf (qid_file_ptr,"\nServer_Reply_QID=%d", MTMServerReplyQid);

	/*
	*	write reply queue info to info file
	*/
	time(&thetime);
	fprintf (info_file_ptr,"\nMTM name: %s %s",MTMProcessName,ctime(&thetime));
	fprintf (info_file_ptr,
		"Server Reply Mess Queue IPC Key and QID:        %d",
		MTMServerReplyQid);

	/*
	*	Create the MT Server Control Message Queue
	*/
	fprintf(MTMLogFp, "Creating server control queue\n");

	if((MTMControlQid = msgget(IPC_PRIVATE,
		(PERMISSIONS | IPC_CREAT))) == FAILURE)
	{
		MTM_EFD(errno);
		return FAILURE;
	}

	fprintf(MTMLogFp, "Write Control Qid to lock file\n");
	fprintf (qid_file_ptr,"\nServer_Control_QID=%d", MTMControlQid);
	/*
	*	Write Server control mess que id and ipc_key to info file
	*/
	fprintf (info_file_ptr,
		"\nServer Control Mess Queue IPC Key and QID:      %d",
		MTMControlQid);

	/*
	 * allocate memory for MTMMsg
	 */
	fprintf(MTMLogFp, "Allocate memory for message buffer\n");
	if ((MTMMsg = malloc (MTM_MAXMSGSIZE + sizeof (MTM_CNTRL_MSG))) == NULL)
	{
		MTM_EFD(errno);
		return FAILURE;
	}

	/*
	 * Open pipe as one way signal channel from servers to MTM
	 */
	sprintf (MTMFifoName, "%s/%s.fifo", mtm_env, MTMProcessName);
	fprintf(MTMLogFp, "Unlink fifo file %s\n",MTMFifoName);
	if (unlink (MTMFifoName) == FAILURE && errno != ENOENT)
	{
                MTM_EFD (errno);
                exit (EXIT_FAILURE);
	}

	fprintf(MTMLogFp, "Make fifo file %s\n",MTMFifoName);
	if (mkfifo (MTMFifoName, PERMISSIONS) == FAILURE)
	{
		MTM_EFD (errno)
		return FAILURE;
	}

	fprintf(MTMLogFp, "Open fifo file %s (read/write mode)\n",MTMFifoName);
	if ((MTMFifoFd = open (MTMFifoName, O_RDWR)) == FAILURE)
	{
		MTM_EFD (errno)
		return FAILURE;
	}

   	/*
   	*	Set MTM Signal flags as cleared.
   	*/
	MTMSignalFlags.server_msg = 0;
	MTMSignalFlags.client_msg = FALSE;
	MTMSignalFlags.connection_reqst = FALSE;
	MTMSignalFlags.cntrl_msg = 0;
	MTMSignalFlags.sigalrm = FALSE;
	MTMSignalFlags.sigquit = FALSE;
   	MTMSignalFlags.illegal_instr = FALSE;
   	MTMSignalFlags.io_trap_instr = FALSE;
   	MTMSignalFlags.emt_instr = FALSE;
   	MTMSignalFlags.float_pt_excep = FALSE;
   	MTMSignalFlags.seg_violation = FALSE;
   	MTMSignalFlags.bus_err = FALSE;
	MTMSignalFlags.tcp_msg = FALSE;

	/*
	*	Allocate memory for client routing table
	*/
	fprintf(MTMLogFp,"Allocate memory for client routing table\n");
	MTMRoutingTbl = (MTM_CLIENT_ROUTING_TABLE *)malloc(MTMMaxClient * sizeof(MTM_CLIENT_ROUTING_TABLE));
	if (MTMRoutingTbl == NULL)
	{
		MTM_EFD(errno);
		return FAILURE;
	}

	/*
	*	Init the client routing table
	*/
	for (j = 0; j < MTMMaxClient; j++)
	{
		MTMRoutingTbl[j].sd = DISCONNECTED;
		MTMRoutingTbl[j].port = DISCONNECTED;
		MTMRoutingTbl[j].srv_type = DISCONNECTED;
		MTMRoutingTbl[j].cl_tbl_index = DISCONNECTED;
		MTMRoutingTbl[j].time_connected = 0;
		MTMRoutingTbl[j].ip_address[0] = '\0';
	}
	
   	/*
   	*	Initialize Server Information to default state.
   	*/
   	for (i=0; i<MAX_SRV_TYPES; ++i)
   	{
		MTMSrvTbl[i].time_stats_started = 0;
		MTMSrvTbl[i].active_servers = 0;
		MTMSrvTbl[i].current_client_connects = 0;
		MTMSrvTbl[i].total_client_connects = 0;
		MTMSrvTbl[i].active_requests = 0;
		MTMSrvTbl[i].total_client_reqsts = 0;
		MTMSrvTbl[i].total_server_resps= 0;
		MTMSrvTbl[i].total_resp_time = 0;
		MTMSrvTbl[i].min_resp_time = MIN_RESP_DEFAULT;
		MTMSrvTbl[i].max_resp_time = 0;
		MTMSrvTbl[i].jrnl_on = FALSE;
		MTMSrvTbl[i].jrnl_fd = (FILE *)NULL;
		MTMSrvTbl[i].srv_type_name[0] = '\0';

		/*
		*	Create the Request Queue for this server type.
		*/
		fprintf(MTMLogFp, "Create server request queue for slot %d\n",i);
		if((MTMSrvTbl[i].server_type_qid = msgget(IPC_PRIVATE,
		(PERMISSIONS |IPC_CREAT))) == FAILURE)
    		{
			MTM_EFD(errno);
			return FAILURE;
		}

		fprintf(MTMLogFp, "Write Server Type qid(%d) to lock file\n",i);
		fprintf (qid_file_ptr, "\nServer_Request_QID%d=%d", i, MTMSrvTbl[i].server_type_qid);
		/*
		*	Write request queue info in info file
		*/
		fprintf (info_file_ptr,
			"\nServer Request Mess Queue IPC Key and QID:      %d",
			MTMSrvTbl[i].server_type_qid);

		for(j=0;j<MAX_SRV_PROCESSES;j++)
		{
			MTMSrvTbl[i].proc_tbl[j].state = FREE;
			MTMSrvTbl[i].proc_tbl[j].srv_state = PAUSE;
			MTMSrvTbl[i].proc_tbl[j].srv_type = i;
			MTMSrvTbl[i].proc_tbl[j].pid = DISCONNECTED;
			MTMSrvTbl[i].proc_tbl[j].time_connected = 0;
		}

		/*
		* Allocate memory for client table
		*/
		fprintf(MTMLogFp,"Allocate memory for clients in server slot %d\n",i);
		MTMSrvTbl[i].cl_tbl = (MTM_CLIENT_TABLE *)malloc(MTMMaxClient * sizeof(MTM_CLIENT_TABLE));
		if (MTMSrvTbl[i].cl_tbl == NULL)
		{
			MTM_EFD(errno);
			return FAILURE;
		}

		for(j=0;j<MTMMaxClient;j++)
		{
			MTMSrvTbl[i].cl_tbl[j].state = DISCONNECTED;
			MTMSrvTbl[i].cl_tbl[j].time_connected = 0;
			MTMSrvTbl[i].cl_tbl[j].ip_address[0] = '\0';
			MTMSrvTbl[i].cl_tbl[j].sd = DISCONNECTED;
			MTMSrvTbl[i].cl_tbl[j].port = DISCONNECTED;
			MTMSrvTbl[i].cl_tbl[j].srv_pid = 0;
			MTMSrvTbl[i].cl_tbl[j].recv_time = 0;
			MTMSrvTbl[i].cl_tbl[j].microsecs_recv_time = 0;
			MTMSrvTbl[i].cl_tbl[j].total_resp_time = 0;
			MTMSrvTbl[i].cl_tbl[j].min_resp_time = MIN_RESP_DEFAULT;
			MTMSrvTbl[i].cl_tbl[j].max_resp_time = 0;
			MTMSrvTbl[i].cl_tbl[j].reqst_msgs = 0;
		}
	}

	/* Initializes the MTM Stats Table to default values*/
	
	for( i=0;i < MAX_SRV_TYPES; i++)
	{
		MTMStatsTbl[i].mtm_stats_on = FALSE;
		MTMStatsTbl[i].srv_type_name[0] = '\0';
		MTMStatsTbl[i].active_servers = 0;
		MTMStatsTbl[i].start_time[0] = '\0';
		MTMStatsTbl[i].end_time[0] = '\0';
		MTMStatsTbl[i].total_server_reply = 0;
		MTMStatsTbl[i].min_reply_time = 0;
		MTMStatsTbl[i].max_reply_time = 0;
		MTMStatsTbl[i].avg_reply_time = 0.0;
		MTMStatsTbl[i].total_server_req = 0;
		MTMStatsTbl[i].min_req_time = 0;
		MTMStatsTbl[i].max_req_time = 0;
		MTMStatsTbl[i].avg_req_time = 0.0;
	}

	/*
	*	Should this MTM connect in as client?
	*/
	if (MTMTcpCount)
	{
		fprintf(MTMLogFp,"Attempt to connect as TCP client to %d other server(s)\n",MTMTcpCount);
		tcp_client_connect();
	}

	/*
	*	Write MTM start message
	*/
   	fprintf(MTMLogFp, "%s process started. Process ID = %d\n",
		MTMProcessName, MTMProcessId);

	fflush (MTMLogFp);
	fflush (info_file_ptr);
	fflush (qid_file_ptr);
	fclose (info_file_ptr);
	fclose (qid_file_ptr);

   	return SUCCESS;
}

/*
*	mtm_signal_catcher
*	[module number i.e. Future] [module name]
*
*	Description:
*
*	Returns:
*	SUCCESS or FAILURE
*/
void
mtm_signal_catcher(int sig)
{
	time_t current_time;

	/*
	*	Send info to log
	*/
	time(&current_time);
	fprintf(MTMLogFp,"MTM PID %d: received signal %d at %s\n",
		MTMProcessId,sig,ctime(&current_time));
	fprintf(MTMLogFp,"Last routine %s line %d\n",__FILE__,__LINE__);

	switch(sig)
	{
	   	case SIGALRM:
			fprintf(MTMLogFp, "ALRM signal received\n");
			fflush(MTMLogFp);
			break;
   		case SIGHUP:
			fprintf(MTMLogFp, "HUP signal received\n");
			fflush(MTMLogFp);
			break;
   		case SIGINT:
			fprintf(MTMLogFp, "INT signal received\n");
			fflush(MTMLogFp);
			break;
   		case SIGKILL:
			fprintf(MTMLogFp, "KILL signal received\n");
			fflush(MTMLogFp);
			break;
   		case SIGPIPE:
			fprintf(MTMLogFp, "PIPE signal received\n");
			fflush(MTMLogFp);
			break;
   		case SIGPOLL:
			fprintf(MTMLogFp, "POLL signal received\n");
			fflush(MTMLogFp);
			break;
   		case SIGUSR1:
			fprintf(MTMLogFp, "USR1 signal received\n");
			fflush(MTMLogFp);
			break;
   		case SIGUSR2:
			fprintf(MTMLogFp, "USR2 signal received\n");
			fflush(MTMLogFp);
			break;
   		case SIGVTALRM:
			fprintf(MTMLogFp, "VTALRM signal received\n");
			fflush(MTMLogFp);
			break;
		case SIGQUIT:
			fprintf(MTMLogFp, "QUIT signal received\n");
			fflush(MTMLogFp);
			MTMSignalFlags.sigquit = TRUE;
			mtm_shutdown();
			break;
		case SIGTERM:
			fprintf(MTMLogFp, "TERM signal received\n");
			fflush(MTMLogFp);
			MTMSignalFlags.sigquit = TRUE;
			mtm_shutdown();
			break;
		case SIGILL:	/*	Illegal Instruction 	*/
			fprintf(MTMLogFp, "ILL signal received\n");
			fflush(MTMLogFp);
			abort();
			/* Dump core and exit */
		case SIGIOT:	/*	I/O Trap 			*/
			fprintf(MTMLogFp, "IOT signal received\n");
			fflush(MTMLogFp);
			abort();
			/* Dump core and exit */
		case SIGFPE: 	/*	Floating Point Exception*/
			fprintf(MTMLogFp, "FPE signal received\n");
			fflush(MTMLogFp);
			abort();
			/* Dump core and exit */
		case SIGSEGV:	/*	Segmentation Violation	*/
			fprintf(MTMLogFp, "SEGV signal received\n");
			fflush(MTMLogFp);
			abort();
			/* Dump core and exit */
		case SIGBUS:	/*	Bus Error			*/
			fprintf(MTMLogFp, "BUS signal received\n");
			fflush(MTMLogFp);
			abort();
			/* Dump core and exit */
	}
}

/*
*	mtm_shutdown
*	[module number i.e. Future] [module name]
*
*	Description:
*	Frees shared resources and exits
*
*	Returns:
*	void
*/
void
mtm_shutdown(void)
{
	register 	i;
   	RETURNSTATUS	rc = SUCCESS;
	time_t		cal_time;

	time(&cal_time);
	fprintf(MTMLogFp, "----------------------------------------\n");
	fprintf(MTMLogFp, "Perform MTM shutdown at %s\n",ctime(&cal_time));

	/*
	*	Remove the MT Server Reply to Client Message Queue
   	*/
	if(MTMServerReplyQid != DISCONNECTED)
	{
		fprintf(MTMLogFp, "Remove server reply queue\n");
		if (msgctl(MTMServerReplyQid, 
					IPC_RMID,
					(struct msqid_ds *)NULL) == FAILURE)
		{
			MTM_EFD(errno);
		}
	}

	/*
	*	Remove the MT Server Control Message Queue
	*/
	if(MTMControlQid != DISCONNECTED)
	{ 
		fprintf(MTMLogFp, "Remove server control queue\n");
		if (msgctl(MTMControlQid, 
					IPC_RMID,
					(struct msqid_ds *)NULL) == FAILURE)
		{
			MTM_EFD(errno);
		}
	}

   	/*
   	*	Initialize Server Information to default state.
   	*/
   	for (i=0; i<MAX_SRV_TYPES; ++i)
   	{
		/*
		*	Remove the MT Server Queues
		*/
		if(MTMSrvTbl[i].server_type_qid != DISCONNECTED)
		{ 
			fprintf(MTMLogFp, "Remove server request queue for slot %d\n",i);
			if (msgctl(MTMSrvTbl[i].server_type_qid, 
				IPC_RMID,
				(struct msqid_ds *)NULL) == FAILURE)
			{
				MTM_EFD(errno);
			}
		}
	}

   	/*
   	*	Closes all the sockets
   	*/
	fprintf(MTMLogFp, "Closing client sockets\n");
	for(i=0;i<MTMMaxClient;i++)
	{
		if(MTMRoutingTbl[i].sd != DISCONNECTED)
			(void)close(MTMRoutingTbl[i].sd);
	}

	fprintf(MTMLogFp, "Closing MTM listening socket\n");
	if(MTMListenSd != DISCONNECTED)	
		(void)close(MTMListenSd);

	if (MTMTcpCount)
	{
		fprintf(MTMLogFp, "Closing TCP clients\n");
		tcp_client_disconnect();
	}

	/*
	*	Free memory allocated
	*/
	fprintf(MTMLogFp, "Deallocate memory\n");
	if (MTMMsg != NULL)
		free (MTMMsg);

	if(MTMRoutingTbl != NULL)
		free(MTMRoutingTbl);

	if(MTMTcpClient != NULL)
		free(MTMTcpClient);

	if(MTMAsyncClient != NULL)
		free(MTMAsyncClient);

	for (i=0;i<MAX_SRV_TYPES;i++)
	{
		if(MTMSrvTbl[i].cl_tbl != NULL)
			free(MTMSrvTbl[i].cl_tbl);
	}


	/*
	 *	Close log file. Release lock, close and remove lock file.
	 *	Close debug file, close fifo and remove fifo.
	 */

	if (MTMLockFd != DISCONNECTED)
	{
		fprintf(MTMLogFp, "Release lock file\n");
		mtm_lock_reg (MTMLockFd, F_SETLK, F_UNLCK, 0, SEEK_SET, 0);
		close (MTMLockFd);
	}

	fprintf(MTMLogFp, "Remove lock file\n");
	unlink (MTMLockFileName);

	fprintf(MTMLogFp, "Close fifo file\n");
	if (MTMFifoFd != DISCONNECTED)
		close (MTMFifoFd);

	fprintf(MTMLogFp, "Remove fifo file\n");
	unlink (MTMFifoName);

	if (MTMFdDebug != (FILE *)NULL)
		fclose(MTMFdDebug);

	time(&cal_time);
	fprintf(MTMLogFp, "%s ended at %s\n",MTMProcessName, ctime(&cal_time));
	fprintf(MTMLogFp, "Closing log file\n");
	fprintf(MTMLogFp, "----------------------------------------\n\n\n");
	fflush(MTMLogFp);
	if(MTMLogFp != (FILE *)NULL)
   		(void)fclose(MTMLogFp);

	exit(EXIT_SUCCESS);
}




/*
*	mtm_trap_signals
*
*	Setting the trap for signals that the MTM may receive.
*
*/
void
mtm_trap_signals()
{
	(void)mtm_signal_intr(SIGALRM,mtm_signal_catcher);	
	(void)mtm_signal_intr(SIGHUP,mtm_signal_catcher);	
	(void)mtm_signal_intr(SIGINT,mtm_signal_catcher);	
	(void)mtm_signal_intr(SIGKILL,mtm_signal_catcher);	
	(void)mtm_signal_intr(SIGPIPE,mtm_signal_catcher);	
	(void)mtm_signal_intr(SIGPOLL,mtm_signal_catcher);	
	(void)mtm_signal_intr(SIGUSR1,mtm_signal_catcher);	
	(void)mtm_signal_intr(SIGUSR2,mtm_signal_catcher);	
	(void)mtm_signal_intr(SIGVTALRM,mtm_signal_catcher);	
	(void)mtm_signal_intr(SIGILL,mtm_signal_catcher);	
	if (SIGIOT == SIGABRT)
		(void)mtm_signal_intr(SIGIOT,SIG_IGN);	
	else
		(void)mtm_signal_intr(SIGIOT,mtm_signal_catcher);	
	(void)mtm_signal_intr(SIGFPE,mtm_signal_catcher);	
	(void)mtm_signal_intr(SIGSEGV,mtm_signal_catcher);	
	(void)mtm_signal_intr(SIGBUS,mtm_signal_catcher);	
	(void)mtm_signal_intr(SIGQUIT,mtm_signal_catcher);	
	(void)mtm_signal_intr(SIGTERM,mtm_signal_catcher);	
	return;
}
