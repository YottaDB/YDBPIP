
/*
*	mtm.h - Sanchez Message Transport Manager for UNIX
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	ORIG:	Sara G. Walters - 11 Jan 1995
*
*	DESC:
*
*   $Id$
*   $Log:	mtm.h,v $
 * Revision 2.7  05/12/06  paulj
 * Added MTM_STATS_TABLE to store MTM Stats. Modified MTM_MSG_HEADER to
 * include two more fields to pass massage wait time in the queue.Added
 * three more commands to MTM_CNTRL_CMDS to start/stop/get MTM Stats.
 *
 * Revision 2.6  04/08/20  yurkovicg (thoniyim)
 * Increased maximum message length to 1 meg. 
 *
 * Revision 2.5  00/07/06  17:17:26  17:17:26  lyh ()
 * Removed certain restrictions for tcp client (MTM v2.0.1)
 * 
 * Revision 2.4  00/03/29  09:37:36  09:37:36  lyh ()
 * Changed length format to pattern matching instead of using option
 * 
 * Revision 2.3  00/03/27  16:07:22  16:07:22  lyh ()
 * wogm release
 * 
 * Revision 2.2  00/03/03  15:31:47  15:31:47  lyh ()
 * sand comber release
 * 
 * Revision 2.1  00/01/17  11:17:49  11:17:49  lyh ()
 * storm trooper release
 * 
 * Revision 1.3  99/12/28  11:12:01  11:12:01  lyh ()
 * added 3 new control messages: SENDMSG, GETVER, GETPARAM
 * 
 * Revision 1.2  99/12/27  16:04:46  16:04:46  lyh ()
 * added variable length size
 * 
 * Revision 1.1  99/12/20  16:30:53  16:30:53  lyh ()
 * Initial revision
 * 
 * Revision 1.7  96/04/26  15:11:56  15:11:56  zengf (Fan Zeng)
 * final fix
 * 
 * Revision 1.6  96/04/25  16:12:31  16:12:31  zengf (Fan Zeng)
 * fix client message bug.
 * 
 * Revision 1.5  96/04/17  15:16:27  15:16:27  zengf (Fan Zeng)
 * Fixed stats.
 * 
 * Revision 1.4  96/04/10  17:20:41  17:20:41  zengf (Fan Zeng)
 * General cleaning up
 * 
 * Revision 1.3  96/03/21  15:04:00  15:04:00  zengf (Fan Zeng)
 * Collapsed directories and replaced signals with fifos.
 * 
 * Revision 1.2  96/03/13  10:11:56  10:11:56  zengf (Fan Zeng)
 * prepare for removing signals
 * ,
 * 
 * Revision 1.1  96/02/29  10:28:48  10:28:48  zengf (Fan Zeng)
 * Initial revision
 * 
 * Revision 1.4  95/08/11  14:42:45  14:42:45  rcs ()
 * Benchmark bug fixes
 * 
 * Revision 1.3  95/07/19  14:35:02  14:35:02  rcs ()
 * Bug fixes as a result of MTM testing.
 * 
 * Revision 1.2  95/05/22  15:13:14  15:13:14  sca ()
 * sgI VMS
 * 
*   $Revision: 2.5 $
*
*/


#ifndef 	MTM_H
#define 	MTM_H

#include <time.h>
#include <sys/ipc.h>
#include <limits.h>
#include "scatype.h"
#include "mtmerrno.h"

#define MTM_LOG(reason)\
	if(reason != ENOMSG)\
	{\
		(void)fprintf(stderr,"ERROR:\tReason Code %d\n",reason);\
    		(void)fprintf(stderr,"ERROR:\tMessage: %s\n",strerror(reason));\
		(void)fprintf(stderr,"ERROR:\tSource file: %s Line Number %d\n",__FILE__,__LINE__);\
		(void)fflush(stdout);\
		(void)fflush(stderr);\
	}\

#define MTM_EFD(reason)\
		mtm_efd(reason, __FILE__, __LINE__);\

/*
*	Defines for message queues
*/
#define MTM_CONTROL_QUEUE		'\1'
#define MTM_SERVER_REPLY_QUEUE		'\2'
#define QKEYOFFSET			'\15'
#define PERMISSIONS			0666

#define MTM_CMDLINE_OPTIONS 		"a:c:h:l:m:n:p:r:s:v:"
#define MTM_ASYNC_MODE_OPTION		'a'
#define MTM_MAX_CLIENT_OPTION		'c'
#define MTM_MSGFILE_OPTION		'f'
#define MTM_OTHER_HOST_OPTION		'h'
#define MTM_LOGFILE_OPTION		'l'
#define MTM_MAXMSGSIZE_OPTION		'm'
#define MTM_PROCESS_NAME_OPTION		'n'
#define MTM_SOCKET_PORT_OPTION		'p'
#define MTM_ROOT_IP_OPTION		'r'
#define MTM_LENGTH_SIZE_OPTION		's'
#define MTM_VALID_CLIENT_OPTION		'v'

#define MTM_MAXMSGSIZE			1048575
#define MTM_MAXCTRLMSGSIZE		32767
#define SCAU_MTM			"SCAU_MTM"

#define	MTM_PAUSE			5
#define	MTM_MAX_RETRYS			100
#define NOT_ASSIGNED			-1
#define MAX_TOTAL_MSGS			25
#define MAX_ONE_BYTE_LENGTH		254
#define MULTI_BYTE_LV_OFFSET		4
#define MULTI_BYTE_LV			2
#define MULTI_BYTE_CHAR			'2'
#define ONE_BYTE_LV_OFFSET		1
#define MTM_STR_LEN			80
#define MAX_LOG_NAME_LEN		16
#define MTM_SERVER_PORT			5006
#define MAX_NAME_LEN			_POSIX_PATH_MAX
#define MIN_RESP_DEFAULT		99999
#define SCA_LEN_FIELD			3
#define MTM_LOG_FILE			"/tmp/MTM/mtm.log"	
#define MAX_LOG_ERRORS			1024

#define PROFILE_DELIMITER		'|'
#define RECORD_DELIMITER		0x1c
#define	DOLLAR_SIGN			'$'
#define UNDERSCORE			'_'

#define TIME_STR_LEN			12
#define IP_ADDR_LEN			15

enum CLIENT_STATES
{
	DISCONNECTED = -1,
	CONNECTED = 0,
	REQUEST_PENDING = 1,
	INITIALIZED = 2
};

enum SERVER_STATES
{
	PAUSE,
	BUSY
};

typedef struct {
	SLONG	client_msg;
	SLONG	connection_reqst;
	SLONG	server_msg;
	SLONG	cntrl_msg;
	SLONG	sigalrm;
	SLONG	sigquit;
	SLONG 	illegal_instr;
	SLONG 	io_trap_instr;
	SLONG 	emt_instr;
	SLONG 	float_pt_excep;
	SLONG 	seg_violation;
	SLONG 	bus_err;
	SLONG	tcp_msg;
} MTM_SIGNAL_FLAGS;

#define MAX_SRV_TYPES		5
#define OPERATOR		6	
#define ALL			'*'	

enum SOCKET_STATE
{
	SET,
	CLEARED
};

typedef struct {
	SLONG 			sd;
	enum SOCKET_STATE 	socket_state;
	SLONG 			port;
	char 			ip_address[IP_ADDR_LEN+1];
	SLONG 			srv_type;
	SLONG			cl_tbl_index;
	time_t			time_connected;
} MTM_CLIENT_ROUTING_TABLE;

typedef struct	{
	char ip_address[IP_ADDR_LEN+1];
	char *next;
} MTM_VALID_CLIENT;

#define	MAX_PARAM1_LEN		21
#define MAX_PARAM2_LEN		21
#define MAX_PARAM3_LEN		MTM_MAXCTRLMSGSIZE
#define MAX_JRNL_NAME_LEN	81

enum SLOT_STATE
{
	IN_USE,
	FREE
};

typedef struct {
	SLONG			srv_type;
	char 			process_name[MAX_PARAM1_LEN];
	enum SLOT_STATE		state;
	enum SERVER_STATES	srv_state;
	SLONG 			pid;
	time_t	 		time_connected;
} MTM_PROCESS_TABLE;

typedef struct {
	SLONG 		state;
	time_t		time_connected;
	char 		ip_address[IP_ADDR_LEN+1];
	SLONG 		port;
	SLONG		sd;
	SLONG		srv_pid;
	time_t		recv_time;
	float 		microsecs_recv_time;
	SLONG 		reqst_msgs;
	SLONG 		resp_msgs;
	float 		total_resp_time;
	float 		min_resp_time;
	float 		max_resp_time;
} MTM_CLIENT_TABLE;

#define MAX_SRV_PROCESSES	32
#define MAX_CLIENTS		1000

typedef struct {
	time_t 	  	time_stats_started;
	SLONG 		active_servers;
	SLONG		total_client_connects;
	SLONG		current_client_connects;
	SLONG		active_requests;
	SLONG		total_client_reqsts;
	SLONG		total_server_resps;
	float		total_resp_time;
	float		min_resp_time;
	float		max_resp_time;
	SLONG 		server_type_qid;
	SLONG 		jrnl_on;
	FILE 		*jrnl_fd;
	char		jrnl_name[MAX_JRNL_NAME_LEN];
	char		srv_type_name[MAX_NAME_LEN];
	MTM_PROCESS_TABLE 	proc_tbl[MAX_SRV_PROCESSES];
	MTM_CLIENT_TABLE	*cl_tbl;
} MTM_SERVER_TYPE_TABLE;

/*
 * A messge header is appended to all PROFILE messages when they are exchaged 
 * inside MTM.
 */
typedef struct {
	union {
		long unix_pid;
		long slot_id;
	} mtype;
	SLONG 	return_code;
	SLONG	reason_code;
	SLONG	mtm_process_id;
	SLONG	slot_id;
	SLONG	pid;
	SLONG	srv_type;
	SLONG	srv_mode;
	SLONG	sd;
	SLONG	port;
	SLONG 	length;
	char	format;
	char	header;
	SLONG	lsize;
	SLONG	hsize;
	SLONG	lcount;
	SLONG	tcount;
	SLONG   time_in;	/* Time the message enter into the queue. */
				/* (Added for MTM Stats)   */
	SLONG   request_time;	/* Message wait time in the request queue. */
				/* (Added for MTM Stats)  */
} MTM_MSG_HEADER;

/*
 * A table to store the MTM Statistics.
 */

typedef struct
{
	SLONG	mtm_stats_on;
	char	srv_type_name[MAX_NAME_LEN];
	SLONG	active_servers;
	char	start_time[TIME_STR_LEN];
	char	end_time[TIME_STR_LEN] ;
	SLONG	total_server_reply;
	SLONG	min_reply_time;
	SLONG	max_reply_time;
	float	avg_reply_time;
	SLONG	total_server_req;
	SLONG	min_req_time;
	SLONG   max_req_time;
	float	avg_req_time;
}MTM_STATS_TABLE;


#define MAX_COMMAND_LEN		11
#define MAX_SRV_CL_LEN		2
#define MAX_CNTRL_MSG_LEN	512+MAX_COMMAND_LEN

enum MTM_CNTRL_CMDS
{
	ADDSRV = 0,
	STOP,
	DELSRV,
	JRNL,
	PEND,
	CLSTAT,
	SVSTAT,
	FIND_ZOMBIES,
	SENDMSG,
	GETVER,
	GETPARAM,
	SVCLEAN,
	STARTSTAT,
	STOPSTAT,
	GETSTAT
};

enum MTM_JRNL_MESSAGES
{
	REQST_MSG = 0,
	RESP_MSG
};

typedef struct {
	MTM_MSG_HEADER		header;
	enum MTM_CNTRL_CMDS 	cmd;
	SLONG	param3Length;
	char	param1[MAX_PARAM1_LEN];
	char	param2[MAX_PARAM2_LEN];
	char	param3[MAX_PARAM3_LEN];
} MTM_CNTRL_MSG;

#define	MAX_ERR_MSG_LEN		81

/*
*	Control message types
*/
#define STOP_IMMEDIATE		'1'
#define STOP_PENDING		'0'
#define JRNL_ON			'1'
#define JRNL_OFF		'0'
#define ZERO_COUNTERS		'1'

/*
 *	Signal handling function type
 */
typedef void	Sigfunc (int);

#define KILO 1000

#define MTM_TMP_DIR		"/tmp/MTM"
#define MTM_ALARM_TIME		300
#define MTM_SCA_CS_ST		"SCA_CS_ST"

#define MTM_CONTROL_MSG_FLAG	"1"
#define MTM_REPLY_MSG_FLAG	"2"
#define MTM_MSG_FLAG_SIZE	1

#define MTM_LEN_FIELD_SIZE	2
/*
 *	macro to convert the length field in the MTM message to a number
 *  the parameter passed into the macro must be a unsigned char array.
 */
#define MTM_LENGTH(a)	(a[0] * 256 + a[1])

/*
*	Generic timer declaration
*/
#define ENV_VAR		"GTM_CALLIN_START"
#define UNK_TIMER	0
#define SCA_TIMER	1
#define GTM_TIMER	2
typedef struct {
	int	value;
	int	type;
	int	flag;
} st_timeout;

/*
*	More options for mtm length:
*	format:	'b' big endian
*		'l' little endian
*		'p' packed decimal, right justified, zero filled
*		'd' packed decimal, left justified, space filled
*	header:	'y' header length is included in overall message length
*		'n' header length is not included in overall message length
*	lsize:	number of bytes used for message length
*	hsize:	number of bytes used for message header
*	lcount:	leading "don't care" character
*	tcount:	trailing "don't care" characters
*/
typedef struct {
	char	format;
	char	header;
	SLONG	lsize;
	SLONG	hsize;
	SLONG	lcount;
	SLONG	tcount;
} st_length;

/*
*	TCP client
*	The MTM can be client to multiple other server(s).
*	The required information would be:
*	host address - in dot notation format
*	port number - a well known port number of the host
*	length structure - other server(s) may have different
*		length structure than the MTM.
*	Note: when specifying "other host" during MTM startup,
*		use -hHOST_ADDRESS/PORT_NUMBER/LENGTH_FORMAT/REPEAT_COUNT
*		like this: -h140.140.1.252/2000/bby/1
*	max socket - number of sockets that can be open for this host/port
*	used socket - number of socket actually used. (this is provided
*		for later enhancement. it's not used now)
*	client socket - an array that contains cross reference in the
*		client routing table where you can find the socket descriptor
*	next - a pointer to the next host.
*	Currently, we define a maximum 32 sockets per host. This could be a
*		dynamic value.
*/
#define MAX_TCP_CLIENT_SOCKETS	32
typedef struct stc {
	char		hostAddr[IP_ADDR_LEN+1];
	int		portNum;
	st_length	length;
	int		maxSd;
	int		usedSd;
	int		clientSd[MAX_TCP_CLIENT_SOCKETS];
	struct stc	*next;
} st_tcpclient;

#define MAX_TCP_CLIENTS		5
#define MTM_DEFAULT_TIMEOUT	50

#ifndef MAX
#define MAX(X,Y) ((X) < (Y) ? (Y) : (X))
#endif

#include "mtmprototypes.h"

#endif

