/*
*	utils.c
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	UNIX:	Sara G. Walters - 03 Mar 1995
*
*	DESC:	UNIX System calls
*
*   $Id$
*   $Log:	utils.c,v $
 * Revision 1.2  05/01/21  thoniyim ()
 * Modified the function gettime(), to return the current time in
 * micro seconds.
 * 
 * Revision 1.1  95/07/24  11:26:19  11:26:19  rcs ()
 * Initial revision
 * 
 * Revision 1.2  95/05/22  15:01:53  15:01:53  sca ()
 * sgI VMS
 * 
 *
*
*/
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <signal.h>
#include <time.h>
#include <sys/stat.h>
#include <extcall.h>
#include <stdlib.h>

#include <unistd.h>
#include <locale.h>
#include <libgen.h>
#include <sys/time.h>

#define BLOCKSIZE	512
#define MAX_STR 	256
#define CODE_STR 	32
#define DELIMITER 	"	"
#define STBLER_TABLE	"/SCA/sca_gtm/alerts/stbler.err"
#define STBLMSG_TABLE	"/SCA/sca_gtm/alerts/stblmsg.err"
#define MERROR_TABLE	"/SCA/sca_gtm/alerts/merror.err"
#define QUEUE_TABLE	"/SCA/sca_gtm/alerts/queue.err"
#define MUPIP_TABLE	"/SCA/sca_gtm/alerts/mupip.err"

#define HOSTNAME		"hostname"
/* #define ALERT_SCRIPT		"/usr/OV/bin/mcc_evc_send" */
#define ALERT_SCRIPT		"/SCA/tools/sca_alert.sh"
#define POLYCENTER_MACHINE_NAME	"polycenter_machine_name"
#define DATA_COLLECTOR_NAME	"psw_collector"
#define NETWORK_PROTOCOL	"UDPIP"

/*====================================================================
 * Function prototypes:
 *====================================================================*/
/* int     PostEvent(EvmEvent_t ev, char *evname);
int     PostEventGtm(float temperature, unsigned int sensor_no,char *evnam);
void    PrintEvmStatus(FILE *fd, EvmStatus_t status); */

static double time_dbl;
SLONG PidIndex = 0;

extern FILE *sca_fopen(char *file, char *mode);

void
prunning(int count,char *process_name,SLONG *return_code)
{
	RETURNSTATUS 	rc = SUCCESS;
	FILE 			*fd = (FILE *)NULL;
	char 			cmd[MAX_CMD_LEN];
	char			*rtnsdir = (char *)NULL;

	rtnsdir=(char *)getenv("SCA_RTNS");
	/*
	*	Build the ps command
	*/
	(void)sprintf(cmd,"sh %s/prunning.sh %s %d",rtnsdir,process_name,getpid());

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"prunning: cmd = %s\n",cmd);
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
	*	Read the result.
	*/
	if((rc = fread(cmd,1,1,fd)) == FAILURE)
	{
		*return_code = errno;
		return;
	}

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"prunning: cmd[0] = %c\n",cmd[0]);
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif

	/*
	*	If return value is 1 the process is running.
	*/
	if(((rc == 1) && (cmd[0] == '1'))
		|| ((rc == 0) && (cmd[0] == '0')))
			*return_code = TRUE;
	else
		*return_code = FALSE;

	(void)pclose(fd);

	return;
}

void
pgtm(int count,long pid,SLONG *return_code)
{
	RETURNSTATUS 	rc = SUCCESS;
	FILE 			*fd = (FILE *)NULL;
	char 			cmd[MAX_CMD_LEN];
	char			*rtnsdir = (char *)NULL;

	rtnsdir=(char *)getenv("SCA_RTNS");
#ifdef DEBUG
	do {
		(void)fprintf(stdout,"pid: = %d\n",pid);
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif
	/*
	*	Build the ps command
	*/
	(void)sprintf(cmd,"sh %s/pgtm.sh %d %d",rtnsdir,pid,getpid());
	/* (void)sprintf(cmd,"sh -x %s/pgtm.sh %d %d",rtnsdir,&pid,getpid()); */

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"pmumps: cmd = %s\n",cmd);
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
	*	Read the result.
	*/
	if((rc = fread(cmd,1,1,fd)) == FAILURE)
	{
		*return_code = errno;
		return;
	}

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"pmumps: cmd[0] = %c\n",cmd[0]);
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif

	/*
	*	If return value is 1 the process is running.
	*/
	if(cmd[0] == '1')
		*return_code = TRUE;
	else
		*return_code = FALSE;

	(void)pclose(fd);

	return;
}

void getprocessid(int count, SLONG *pid)
{
	int i;

	*pid = getpid();
}

void validpid(int count, SLONG *pid)
{
	RETURNSTATUS rc = SUCCESS;

	if((rc = kill(*pid,SIGCONT)) == FAILURE)
	{
		if(errno == ESRCH)
			*pid = 0;
	}
	else
		*pid = 1;
}

void listpids(	int count, 
				SLONG *pid,
				SLONG *return_code)
{
	RETURNSTATUS	rc = SUCCESS;
	extern			PROCESSDATA pid_list[];

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"listpids: PidIndex = %d\n",PidIndex);
	} while (errno == EINTR);
	(void)fflush(stdout);
#endif
	if(PidIndex == 0)
	{
		*return_code = MUMPS_SUCCESS;
		create_pid_list(return_code);
		if(*return_code != MUMPS_SUCCESS)
			return;
	}

	for(;;)
	{
		if(pid_list[PidIndex].pid > 0) 
		{
			if(pid_list[PidIndex].tty[0] == '?')
			{
				*pid = pid_list[PidIndex++].pid;
#ifdef DEBUG
	do {
		(void)fprintf(stdout,"listpids: pid = %d\n",*pid);
	} while (errno == EINTR);
	(void)fflush(stdout);
#endif
				break;
			}
			PidIndex++;
#ifdef DEBUG
	do {
		(void)fprintf(stdout,"listpids: PidIndex = %d\n",PidIndex);
	} while (errno == EINTR);
	(void)fflush(stdout);
#endif
		}
		else
		{
			*pid = 0;
			PidIndex = 0;
			*return_code=MUMPS_SUCCESS;
#ifdef DEBUG
	do {
		(void)fprintf(stdout,"listpids: pid = %d\n",*pid);
	} while (errno == EINTR);
	(void)fflush(stdout);
#endif
			break;
		}
	}
}
/*
	This is the old implementation of gettime
*/
/*
void
gettime(int count,char *time_str)
{
	time_t		timer;
	struct tm	*time_now = (struct tm *)NULL;

	time(&timer);
	time_now = localtime(&timer);

	(void)sprintf(time_str,"%.2d:%.2d:%.2d",
				time_now->tm_hour,
				time_now->tm_min,
				time_now->tm_sec);
							
}
*/

/****
 * gettime()
 * Returns the current time in micro seconds.
 ****/
void
gettime(int count,char *time_str)
{
	struct timeval  time_now;
 
        /*
        *       Get the connect time
        */
        gettimeofday(&time_now,NULL);

	time_dbl = ((double)time_now.tv_sec*1000000)+(double)time_now.tv_usec; 

	sprintf(time_str,"%.0f",time_dbl);

	return;
}

void
quit()
{
	/* exit(); */
	exit;
}


void
extsleep1(int count,SLONG timeout)
{
	/* signal(SIGUSR2,quit); */
	/*
	*	Sleep for timeout
	*/
/*
DAG Sep 24, 98. Sleep changed to sca_sleep to guarantee it will sleep for
timeout seconds.
	sleep(timeout);	
*/
	sca_sleep(timeout);

	return;
}

void
extsleep(int count,SLONG timeout,int(*sleep_noint)())
{
         /* signal(SIGUSR2,quit); */
        /*
        *       Sleep for timeout
        */

/*
DAG Sep 24, 98. Sleep changed to sca_sleep to guarantee it will sleep for
timeout seconds.
        sleep(timeout);
*/
        sleep_noint(timeout);

        return;
}



void
sendsig(int count,SLONG pid,SLONG signalno)
{
	/*
	*	Send specified signal to process	
	*/
	kill(pid,signalno);

	return;
}


void
sendsvsig(int count,SLONG pid)
{
        /*
        *       Send SIGUSR2 signal to process
        */
        kill(pid,SIGUSR2);

        return;
}


void
pwd(int count,
	STR_DESCRIPTOR *result,
	SLONG *return_code)
{
	RETURNSTATUS 	rc = SUCCESS;
	FILE 			*fd = (FILE *)NULL;
	char 			cmd[8];

#ifdef DEBUG
	(void)fprintf(stdout,"pwd\n");
	(void)sca_fflush(stdout);
#endif

	/*
	*	Build the ps command
	*/
	(void)strcpy(cmd,"pwd");

	/*
	*	Open pipe and execute command
	*/
	if((fd = popen(cmd,"r")) == (FILE *)NULL)
	{
#ifdef DEBUG
	do {
		fprintf(stdout,"pwd: errno = %d\n",errno);
	} while (errno == EINTR);
	sca_fflush(stdout);
#endif
		*return_code = errno;
		return;
	}

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"pwd: cmd = %s\n",cmd);
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif

	/*
	*	Read the "process data" of a mumps process.
	*/
	if((rc = fscanf(fd,
					"%s",
					result->str)) < 1)
	{
#ifdef DEBUG
	do {
		(void)fprintf(stdout,"Local Job\n");
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif
		pclose(fd);
		*return_code=errno;
		return;
	}

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"pwd: After fscanf rc = %d\n",rc);
	} while (errno == EINTR);
	do {
		(void)fprintf(stdout,"pwd: pwd = %s\n",result->str);
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif

	(void)pclose(fd);
	*return_code=MUMPS_SUCCESS;
	return;
}

void
cdt(int count,
	char *file,
	STR_DESCRIPTOR *result,
	SLONG *return_code)
{
	RETURNSTATUS 	rc = SUCCESS;
	FILE 			*fd = (FILE *)NULL;
	char 			cmd[256];

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"cdt\n");
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif

	/*
	*	Build the ls -l command
	*/
	(void)strcpy(cmd,"pwd");
	(void)sprintf(cmd,"ls -l %s",file);

	/*
	*	Open pipe and execute command
	*/
	if((fd = popen(cmd,"r")) == (FILE *)NULL)
	{
#ifdef DEBUG
	do {
		fprintf(stdout,"cdt: errno = %d\n",errno);
	} while (errno == EINTR);
	sca_fflush(stdout);
#endif
		*return_code = errno;
		return;
	}

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"cdt: cmd = %s\n",cmd);
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif

	/*
	*	Read the "process data" of a mumps process.
	*/
	if((rc = fscanf(fd,
					"%s",
					result->str)) < 1)
	{
#ifdef DEBUG
	do {
		(void)fprintf(stdout,"Local Job\n");
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif
		pclose(fd);
		*return_code=errno;
		return;
	}

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"cdt: After fscanf rc = %d\n",rc);
	} while (errno == EINTR);
	do {
		(void)fprintf(stdout,"cdt: cdt = %s\n",result->str);
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif

	(void)pclose(fd);
	*return_code=MUMPS_SUCCESS;
	return;
}

void 
diff(	int count,
		char *dir1,
		char *dir2,
		char *srcfile,
		STR_DESCRIPTOR *result,
		SLONG *return_code)
{
	RETURNSTATUS 	rc = SUCCESS;
	FILE 			*fd = (FILE *)NULL;
	char 			cmd[1024];
	char			*path1 = (char *)NULL;
	char			*path2 = (char *)NULL;

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"diff: %s %s %s\n",dir1,dir2,srcfile);
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif
	path1=(char *)getenv(dir1);
	path2=(char *)getenv(dir2);

	/*
	*	Build the ps command
	*/
	(void)sprintf(cmd,"diff %s/%s %s/%s",path1,srcfile,path2,srcfile);

#ifdef DEBUG
	do {
		(void)fprintf(stdout,"cmd: %s \n",cmd);
	} while (errno == EINTR);
	(void)sca_fflush(stdout);
#endif
	/*
	*	Open pipe and execute command
	*/
	if((fd = popen(cmd,"r")) == (FILE *)NULL)
	{
#ifdef DEBUG
	do {
		fprintf(stdout,"diff: errno = %d\n",errno);
	} while (errno == EINTR);
	sca_fflush(stdout);
#endif
		*return_code = errno;
		return;
	}

	for(;;)
	{
		rc = fread(cmd,1,1,fd);
		if(rc < 1)
		{
			pclose(fd);
			break;
		}
		if(cmd[0] == '<')
			do {
				(void)fprintf(stdout,"\n%s",dir1);
			} while (errno == EINTR);
		else if(cmd[0] == '>')
			do {
				(void)fprintf(stdout,"\n%s",dir2);
			} while (errno == EINTR);
		else	
			do {
				(void)fprintf(stdout,"%c",cmd[0]);
			} while (errno == EINTR);
		(void)sca_fflush(stdout);
	}
}


void
getfileinfo(int count,
                char *file_name,
                char *item,
                STR_DESCRIPTOR *result,
                SLONG *return_code)
 
{
        char            tbuf[20];
        char            *format = "%x %X";
        size_t          maxsize = 20, length;
        time_t          cal;
        struct stat     buf;
        struct tm       *tmptr;
 
        if (stat(file_name, &buf) < 0)
        {
                /*
                 * stat error for file_name
                 */
 
                *return_code = errno;
                return;
        }
 
        if ((strcmp(item,"CDT")) == 0)
        {
                        /*
                         * CDT - Creation date/time
                         */
                        cal = (buf.st_mtime);
                        tmptr = gmtime(&cal);
                        length = strftime(tbuf,maxsize,format,tmptr);
                        memcpy(result->str, tbuf, length);
                        result->length = length;
                        *return_code = MUMPS_SUCCESS;
                        return;
        }
 
        if ((strcmp(item,"ALQ")) == 0)
        {
 
                        /*
                         * ALQ - Allocation quantity
                         */
 
                        *return_code = buf.st_blocks;
                        return;
        }
 
 
        if ((strcmp(item,"BLS")) == 0)
        {
                        /*
                         * BLS - Block size
                         */
 
                        *return_code = BLOCKSIZE;
                        return;
        }
 
        return;
 
}

void
geterrlos(int count,
		char *error_code,
		char *error_category,
		char *error_params,
		SLONG nolog,
		SLONG noalert,
		STR_DESCRIPTOR *desc,
		SLONG *return_code)
 
{

	char buf[MAX_STR];
	char str[MAX_STR];
	char fmtstr[MAX_STR];
	char error_table[MAX_STR];
	char *pstr;
	char *err_code;
	char *err_desc;
	char *event;
	char *priority;
	char *custom_priority;
	char *log;
	char *err_code_str;
	int err_pri = -1;
	int err_log;
	int custom_err_pri = -1;
	int scount = 0;
	int found = 0;
	int ret;
	int status;
	char *evnam;
	char *padir = (char *)NULL;
	char *errordir = (char *)NULL;
	char *err_dir="/SCA/sca_gtm/alerts";

	FILE *fp = NULL;


	/*
	 * Get PROFILE/Anyware directory name
	 */
	if ((padir=(char *)getenv("PROFILE_DIR")) == NULL) {
                if ((padir=(char *)getenv("DIR")) == NULL) {
                        padir = "PROFILE_DIR";
                }
        }
	padir=(char *)basename(padir);


	if ((errordir=(char *)getenv("SCA_ERROR_DIR")) == NULL) {
		errordir=err_dir;
	}

	if (strcmp(error_category,"STBLER") == 0) {
		sprintf(error_table,"%s/stbler.err",errordir);
	}
	else if (strcmp(error_category,"STBLMSG") == 0) {
		sprintf(error_table,"%s/stblmsg.err",errordir);
	}
	else if (strcmp(error_category,"MERROR") == 0) {
		sprintf(error_table,"%s/merror.err",errordir);
	}
	else if (strcmp(error_category,"QUEUE") == 0) {
		sprintf(error_table,"%s/queue.err",errordir);
	}
	else if (strcmp(error_category,"MUPIP") == 0) {
		sprintf(error_table,"%s/mupip.err",errordir);
	}


	/* if ((fp = sca_fopen(error_table, "r")) == NULL) {  */
	if ((fp = fopen(error_table, "r")) == NULL) { 
		printf("Can't open file %s \n",error_table);
		return;
	}

	while (((fgets(buf, MAX_STR - 1, fp)) != NULL) && (!found)) {
		if ((pstr = strtok(buf, DELIMITER )) != NULL) {
			scount++;
        		/* pstr points to the first token */
			err_code = pstr;


			if (strcmp(error_code, err_code) == 0) {
				found = 1;
				while ((pstr = strtok((char *)NULL, DELIMITER )) != NULL) {
					scount++;
					switch(scount) {
						case(2):
							desc->str[desc->length] = '\0';
							ret = sscanf(desc->str,"%s",str);
							if (ret != 1) {
								err_desc = pstr;
							}
							else {
								err_desc = desc->str;
							}
                 					break;

						case(3):
							priority = pstr;
							err_pri = atoi(priority);
                 					break;

						case(4):
							custom_priority = pstr;
							custom_err_pri = atoi(custom_priority);
                 					break;
						case(5):
							event = pstr;
                 					break;
						case(6):
							log = pstr;
							err_log = atoi(log);
                 					break;



					} /* switch */

				} /* while */
			} /* if */
			scount = 0;
		} /* if */
		if (found == 1) {
        		(void)strncpy(desc->str,err_desc, (strlen(err_desc) < desc->length) ? strlen(err_desc) : desc->length); 
        		desc->length=(strlen(desc->str) < desc->length) ? strlen(err_desc) : desc->length;
			*return_code = err_pri;
			if ((nolog != 1) && (err_log != 0)) {
				sprintf(fmtstr,"PROFILE Directory - %s: %s",padir,err_desc);
				status = PostEventSanchez(event,custom_err_pri,fmtstr);
			}
			if ((noalert != 1) && (err_pri >= 3)) {
				status = AlertEventSanchez(event,custom_err_pri,err_desc);
			}
			fclose(fp);
               		break;
		}
	} /* while */
	if (found == 0 ) {
		if (desc->length > 40)
		{
			sprintf(desc->str,"Error code %s not found in error table", error_code);
       			desc->length=strlen(desc->str);
		}
		*return_code = 0;
	}
	fclose(fp);

}



/*====================================================================
 * Function:  PostEventSanchez()
 *
 * This function creates and posts one event.
 *====================================================================*/
int
PostEventSanchez(char *evname, int evpriority, char *evformat)
{	
	return 0;
}



/*====================================================================
 * Function:  PostEvent()
 *
 * This function posts the supplied event.  Since this program
 * does not expect to post events frequently, it connects to the
 * EVM daemon each time it has an event to post, then immediately
 * disconnects.
 *====================================================================*/
/* int
PostEvent(EvmEvent_t ev, char *evname)
{	
	return 0;
} */

/*====================================================================
 * Function:  PrintEvmStatus()
 *
 * This function interprets the supplied EVM status code and prints
 * it on the supplied file stream.
 *====================================================================*/
/* void
PrintEvmStatus(FILE *fd, EvmStatus_t status)
{	

	return;
} */


/*====================================================================
 * Function:  AlertEventSanchez()
 *
 * This function sends an alert event.
 *====================================================================*/
int
AlertEventSanchez(char *evname, int evpriority, char *evformat)
{	
	RETURNSTATUS    rc = SUCCESS;
	char		alertcmd[MAX_STR];
	char		alformat[MAX_STR];
	char		alertformat[MAX_STR];
	char		host[MAX_STR];
	char 		*pname = (char *)NULL;
	char 		*ascript = (char *)NULL;
	char 		*dcname = (char *)NULL;
	char 		*nwprotocol = (char *)NULL;
	int		ret;
	int		i = 0;
	int		j = 0;


	/*
	 * Get the hostname
	 */

	if((rc = gethostname(host, MAX_STR)) != SUCCESS)
	{
		(void)strcpy(host,HOSTNAME);
	}

	/*
	 * Get the polycenter machine name 
	 */

	if ((pname=(char *)getenv("POLYCENTER_MACHINE_NAME")) == NULL) {
                        pname = POLYCENTER_MACHINE_NAME;
        }

	/*
	 * Get the alert script name
	 */

	if ((ascript=(char *)getenv("ALERT_SCRIPT")) == NULL) {
                        ascript = ALERT_SCRIPT;
        }


	/*
	 * Get the data collector name
	 */

	if ((dcname=(char *)getenv("DATA_COLLECTOR_NAME")) == NULL) {
                        dcname = DATA_COLLECTOR_NAME;
        }

	/*
	 * Get the network protocol
	 */

	if ((nwprotocol=(char *)getenv("NETWORK_PROTOCOL")) == NULL) {
                        nwprotocol = NETWORK_PROTOCOL;
        }

	/*
	 * Build the alert command string to call the shell script
	 */

	memset(alformat,0,MAX_STR);
	while ((evformat[i]) != '\0') {
		if (evformat[i] != '"') {
			alformat[j] = evformat[i];
			i++;
			j++;
		}
		else {
			i++;
		}
			
	}

	evformat[strlen(evformat)-1]='\0';
	alertformat[0]='\0';

	/* strcat(alertformat,"\"\"SANCHEZ ");
	strcat(alertformat,evformat);
	strcat(alertformat,"\"\""); */

	strcat(alertformat,"\"\\\"SANCHEZ ");
	strcat(alertformat,alformat);
	strcat(alertformat,"\\\"\"");


	/* sprintf(alertcmd,"%s %s %s %s %s %s %d %s",ALERT_SCRIPT,POLYCENTER_MACHINE_NAME,DATA_COLLECTOR_NAME,host,evname,alertformat,evpriority,NETWORK_PROTOCOL); */
	sprintf(alertcmd,"%s %s %s %s %s %s %d %s",ascript,pname,dcname,host,evname,alertformat,evpriority,nwprotocol);
	

	/*
	 * Send an alert event and return the status 
	 */

	ret = system(alertcmd);
	return ret;
}

/* GtmEventLog(char *category, char *code, char *msg) */
int
GtmEventLog(int count, char *category, char *code, char *msg)
{	
	SLONG 		rc;
	char		desc_str[2048];
	STR_DESCRIPTOR	desc;

	desc.length = strlen(msg);
	desc.str = &desc_str[0];
	strcpy(desc.str, msg);
	/* geterrlos(count+4, code, category, NULL, 0, 0, &desc, &rc); */
	geterrlos(7, code, category, NULL, 0, 0, &desc, &rc);
	return(rc);
}

char * version () {
        return VERSION;
}

