
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
*   $Revision: 1.7 $
*
*/


#ifndef 	MTM_H
#define 	MTM_H

#include <time.h>
#include "./scatype.h"
#include "./mtmerrno.h"
#include <sys/ipc.h>
#include <limits.h>

#ifndef __linux__
extern char *sys_errlist[];
#endif

#define MTM_LOG(reason)\
	if(reason != ENOMSG)\
	{\
		(void)fprintf(stderr,"ERROR:\tReason Code %d\n",reason);\
    	(void)fprintf(stderr,"ERROR:\tMessage: %s\n",sys_errlist[reason]);\
		(void)fprintf(stderr,"ERROR:\tSource file: %s Line Number %d\n",__FILE__,__LINE__);\
		(void)fflush(stdout);\
		(void)fflush(stderr);\
	}\

#define MTM_EFD(reason)\
		mtm_efd(reason, __FILE__, __LINE__);\

/*
*	Defines for message queues
*/
#define MTM_CONTROL_QUEUE			'\1'
#define MTM_SERVER_REPLY_QUEUE		'\2'
#define QKEYOFFSET					'\15'
#define PERMISSIONS					0666

#define MTM_CMDLINE_OPTIONS 		"c:l:m:n:p:v:"
#define MTM_MAX_CLIENT_OPTION		'c'
#define MTM_LOGFILE_OPTION			'l'
#define MTM_MAXMSGSIZE_OPTION		'm'
#define MTM_PROCESS_NAME_OPTION		'n'
#define MTM_SOCKET_PORT_OPTION		'p'
#define MTM_VALID_CLIENT_OPTION		'v'

#define MTM_MAXMSGSIZE				32767
#define SCAU_MTM					"SCAU_MTM"

#define	MTM_PAUSE					5
#define	MTM_MAX_RETRYS				100
#define NOT_ASSIGNED				-1
#define MAX_TOTAL_MSGS				25
#define MAX_ONE_BYTE_LENGTH			254
#define MULTI_BYTE_LV_OFFSET		4
#define MULTI_BYTE_LV				2
#define MULTI_BYTE_CHAR				'2'
#define ONE_BYTE_LV_OFFSET			1
#define MTM_STR_LEN					80
#define MAX_LOG_NAME_LEN			16
#define MTM_SERVER_PORT				5006
#define MAX_NAME_LEN				_POSIX_PATH_MAX
#define MIN_RESP_DEFAULT			99999
#define SCA_LEN_FIELD				3
#define MTM_LOG_FILE				"/tmp/MTM/mtm.log"	
#define MAX_LOG_ERRORS				1024

#define PROFILE_DELIMITER			'|'
#define RECORD_DELIMITER			0x1c
#define	DOLLAR_SIGN					'$'
#define UNDERSCORE					'_'

#define TIME_STR_LEN				12
#define IP_ADDR_LEN					15

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
	SLONG		client_msg;
	SLONG		connection_reqst;
	SLONG		server_msg;
	SLONG		cntrl_msg;
	SLONG		sigalrm;
	SLONG		sigquit;
	SLONG 		illegal_instr;
	SLONG 		io_trap_instr;
	SLONG 		emt_instr;
	SLONG 		float_pt_excep;
	SLONG 		seg_violation;
	SLONG 		bus_err;
} MTM_SIGNAL_FLAGS;

#define MAX_SRV_TYPES	1
#define OPERATOR		6	
#define ALL				'*'	

enum SOCKET_STATE
{
	SET,
	CLEARED
};

typedef struct {
	SLONG 				sd;
	enum SOCKET_STATE 	socket_state;
	SLONG 				port;
	char 				ip_address[IP_ADDR_LEN+1];
	SLONG 				srv_type;
	SLONG				cl_tbl_index;
	time_t				time_connected;
} MTM_CLIENT_ROUTING_TABLE;

typedef struct	{
	char ip_address[IP_ADDR_LEN+1];
	char *next;
} MTM_VALID_CLIENT;

#define	MAX_PARAM1_LEN		21
#define MAX_PARAM2_LEN		21
#define MAX_PARAM3_LEN		81
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
#define MAX_CLIENTS			512

typedef struct {
	time_t 		  		time_stats_started;
	SLONG 				active_servers;
	SLONG				total_client_connects;
	SLONG				current_client_connects;
	SLONG				active_requests;
	SLONG				total_client_reqsts;
	SLONG				total_server_resps;
	float				total_resp_time;
	float				min_resp_time;
	float				max_resp_time;
	SLONG 				server_type_qid;
	SLONG 				jrnl_on;
	FILE 				*jrnl_fd;
	char				jrnl_name[MAX_JRNL_NAME_LEN];
	char				srv_type_name[MAX_NAME_LEN];
	MTM_PROCESS_TABLE 	proc_tbl[MAX_SRV_PROCESSES];
	MTM_CLIENT_TABLE	cl_tbl[MAX_CLIENTS];
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
	SLONG	sd;
	SLONG	port;
	SSHORT 	length;
} MTM_MSG_HEADER;

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
	FIND_ZOMBIES
};

enum MTM_JRNL_MESSAGES
{
	REQST_MSG = 0,
	RESP_MSG
};

typedef struct {
	MTM_MSG_HEADER		header;
	enum MTM_CNTRL_CMDS cmd;
	char 				param1[MAX_PARAM1_LEN];
	char 				param2[MAX_PARAM2_LEN];
	char 				param3[MAX_PARAM3_LEN];
} MTM_CNTRL_MSG;

#define	MAX_ERR_MSG_LEN		81

/*
*	Control message types
*/
#define STOP_IMMEDIATE	'1'
#define STOP_PENDING	'0'
#define JRNL_ON			'1'
#define JRNL_OFF		'0'
#define ZERO_COUNTERS	'1'

/*
 *	Signal handling function type
 */
typedef void	Sigfunc (int);

#define KILO 1000

#define MTM_TMP_DIR			"/tmp/MTM"
#define MTM_ALARM_TIME		300
#define MTM_SCA_CS_ST		"SCA_CS_ST"

#define MTM_CONTROL_MSG_FLAG	"1"
#define MTM_REPLY_MSG_FLAG		"2"
#define MTM_MSG_FLAG_SIZE		1

#define MTM_LEN_FIELD_SIZE	2
/*
 *	macro to convert the length field in the MTM message to a number
 *  the parameter passed into the macro must be a unsigned char array.
 */
#define MTM_LENGTH(a)	(a[0] * 256 + a[1])

#include "./mtmprototypes.h"

#endif

