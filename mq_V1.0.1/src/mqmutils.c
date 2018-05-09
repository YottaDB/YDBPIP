/*****************************************************************************
*
*	mqmutils.c
*
*	Copyright(c)2000 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	Description: Sanchez Utility Routines for MQSeries on UNIX
*
*	ORIG: Hien T. Ly - March 1999
*
* $Id: mqmutils.c,v 1.2 2000/11/10 13:41:27 lyh Exp lyh $
*
* $Log: mqmutils.c,v $
 * Revision 1.4  2005/03/28  thoniyim
 * Added the functions, getMQMD() and setMQMD() to parse the input from the
 * user and to send the MQMD to the user. The user will provide the MQMD
 * info as a name=value pair separated by a delimiter.
 *
 * Revision 1.3  2005/03/24  thoniyim
 * Added version info.
 *
 * Revision 1.2  2000/11/10  13:41:27  lyh
 * Fixed routine header comments
 *
 * Revision 1.1  2000/11/08  19:58:26  lyh
 * Initial revision
 *
*
* $Revision: 1.2 $
*
*****************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <scatype.h>
#include <cmqc.h>
#include <mqmmsg.h>
#include <mqm.h>

char putenvbuf[512];

/*------------ External variables ------------*/

extern CONNLIST MQMServerId;       /* Server connect information    */
extern CONNLIST MQMClientId;       /* Client connect information    */

/*------------ Local constants ------------*/
#define MAX_CHAR_PER_LINE 16
#define MAX_MQMD_ELEMENTS 29

/*------------ Local functions ------------*/
void LV(int, char *);
void hex_dmp(char *, int);
void chr_dmp(char *, int);
char * version ();
int  getvalue(char *);
void getmsgid(char *, char *);

/*
**	GetSrvQIni
**
**	This routine translates an environment variable based on the
**	input server type. It will then read the defined .ini file and
**	return the default queue manager and request queue names for
**	the server.
**
**	Inputs:
**		srv_type_name	environment variable that points to INI file
**
**	Outputs:
**		QMName		queue manager name
**		ReqQName	request queue name
**
**	Returns:
**		None
*/
void GetSrvQIni(char *srv_type_name,
                char *QMName,
                char *ReqQName)
{
   /******************************************************************/
   /* There is supposed to be a text file that describes the queue   */
   /* manager and queue names to be used for a given service type.   */
   /* Here, we need to translate an environment variable to get to   */
   /* that file.                                                     */
   /******************************************************************/

   char env_name[MAX_NAME_LEN],buffer[512],option[80],value[80];
   char *ptr;
   char *env_val;
   FILE *fd;

#ifdef DEBUG
   fprintf(stdout,"Start of GetSrvQIni\n");
   fprintf(stdout,"\tsrv_type_name: %s\n",srv_type_name);
   fflush(stdout);
#endif /* DEBUG */

   /* Default queue manager and queue names                          */
   QMName[0] = '\0';
   ReqQName[0] = '\0';

   /* append server type to SCA_CS_ST                                */
   /* env_name is probably something like SCA_CS_ST_SCA$MQM          */
   sprintf(env_name,"%s_%s", SCA_CS_ST, srv_type_name);
#ifdef DEBUG
   fprintf(stdout,"\tenv_name = %s\n",env_name);
   fflush(stdout);
#endif

   /* replace '$' with '_'                                           */
   /* env_name is something like this: SCA_CS_ST_SCA_MQM             */
   ptr = env_name;
   while (*ptr != '\0')
   {
     if (*ptr == DOLLAR_SIGN)
         *ptr = UNDERSCORE;
     ptr++;
   }
#ifdef DEBUG
   fprintf(stdout,"\tAfter trasformation, env_name = %s\n",env_name);
   fflush(stdout);
#endif

   /* get environment variable                                       */
   /* there should be an exported variable like this:                */
   /* SCA_CS_ST_SCA_MQM=/v61dev/MQM_V61DEV.INI                       */
   /* export SCA_CS_ST_SCA_MQM                                       */
   /* env_val is the filename indicated on the right of the = sign   */
   env_val = getenv(env_name);
#ifdef DEBUG
   fprintf(stdout,"\tenv_val = %s\n",env_val);
   fflush(stdout);
#endif

   if (env_val != (char *)NULL)
   {
     /* Now open and read that file, one line at a time              */
     fd = fopen(env_val, "r");
     if (fd != (FILE *)NULL)
     {
	for (;;)
	{
		memset(buffer,0,sizeof(buffer));
		fscanf(fd,"%s\n",buffer);
		if (buffer[0] == '\0')
			break;
		sscanf(buffer,"%[^=]=%s",option,value);
		if (strcmp(option,"QMGR") == 0)
			strcpy(QMName,value);
		else if (strcmp(option,"REQQ") == 0)
			strcpy(ReqQName,value);
	}
       /* All done, close the file                                   */
       fclose(fd);
     }
   }

#ifdef DEBUG
   fprintf(stdout,"Queue manager name: %s\n",QMName);
   fprintf(stdout,"Request queue name: %s\n",ReqQName);
   fprintf(stdout,"End of GetSrvQIni - successful completion\n");
   fflush(stdout);
#endif /* DEBUG */

   return;

} /* end of GetSrvQIni */




/*
**	GetClQIni
**
**	This routine translates an environment variable based on the
**	input server type. It will then read the defined .ini file and
**	return the default queue manager name, request queue name, and
**	reply queue name.
**
**	Inputs:
**		env_name	environment variable that points to INI file
**
**	Outputs:
**		ClQMName	queue manager name
**		ClReqQName	request queue name
**		ClRepQName	reply queue name
**		ClUserId	User Id from INI
**
**	Returns:
**		None
**	Revisions:
**		thoniyim - 03/08/2003
**		Modify this function to return a UserId from the INI file
*/
void GetClQIni(char *env_name, 
               char *ClQMName, 
               char *ClReqQName, 
               char *ClRepQName,
               char *ClUserId)
{
   /******************************************************************/
   /* There is supposed to be a text file that describes the queue   */
   /* manager and queue names to be used for a given service type.   */
   /* Here, we need to translate an environment variable to get to   */
   /* that file.                                                     */
   /******************************************************************/
 
   char *ptr;
   char *env_val;
   FILE *fd;
   char buffer[512],option[80],value[80];
   int rc;
 
#ifdef DEBUG
   fprintf(stdout,"Start of GetClQIni\n");
   fprintf(stdout,"Env Name - %s\n",env_name);
   fflush(stdout);
#endif /* DEBUG */
 
   /* Default queue manager and queue names                          */
   ClQMName[0]   = '\0';
   ClReqQName[0] = '\0';
   ClRepQName[0] = '\0';
   ClUserId[0]   = '\0';
 
   /* get environment variable                                       */
   /* there should be an exported variable like this:                */
   /* MQM_SCA_CS=/var/mqm/sca_mqm.ini                                */
   /* export MQM_SCA_CS                                              */
   /* env_val is the filename indicated on the right of the = sign   */
   if ((env_val = getenv(env_name)) != (char *)NULL)
   {
#ifdef DEBUG
   fprintf(stdout,"Env Value - %s\n",env_val);
   fflush(stdout);
#endif /* DEBUG */
     /* Now open and read that file, one line at a time              */
     fd = fopen(env_val, "r");
     if (fd != (FILE *)NULL)
     {
	for (;;)
	{
		memset(buffer,0,sizeof(buffer));
		value[0] = '\0';
		fscanf(fd,"%s\n",buffer);
		if (buffer[0] == '\0')
			break;
		sscanf(buffer,"%[^=]=%s",option,value);
#ifdef DEBUG
   fprintf(stdout,"Option = %s | Value = %s\n",option,value);
   fflush(stdout);
#endif /* DEBUG */
		if (strcmp(option,"MQSERVER") == 0) {
			memset(putenvbuf,0,sizeof(putenvbuf));
			strcpy(putenvbuf,buffer);
			if ((rc = putenv(putenvbuf)) != 0) {
				break;
			}
		}
		else if (strcmp(option,"QMGR") == 0)
			strcpy(ClQMName,value);
		else if (strcmp(option,"REQQ") == 0)
			strcpy(ClReqQName,value);
		else if (strcmp(option,"REPQ") == 0)
			strcpy(ClRepQName,value);
		else if (strcmp(option,"USERID") == 0)
			strcpy(ClUserId,value);
	}
       /* All done, close the file                                   */
       fclose(fd);
     }
   }
 
 
#ifdef DEBUG
   fprintf(stdout,"Queue manager name: %s\n",ClQMName);
   fprintf(stdout,"Request queue name: %s\n",ClReqQName);
   fprintf(stdout,"Reply queue name: %s\n",ClRepQName);
   fprintf(stdout,"UserId name: %s\n",ClUserId);
   fprintf(stdout,"End of GetClQIni - successful completion\n");
   fflush(stdout);
#endif /* DEBUG */
 
   return;
} /* end of GetClQIni */




/*
**	CheckConn
**
**	This routine checks if the server already made a connection to
**	the input queue manager and reply queue. If the server already
**	connected to the queue manager, the connection handle is
**	returned. If the server already opened the reply queue, the
**	queue object handle is returned.
**
**	Inputs:
**		IQName		input queue name
**
**	Outputs:
**		QueueHobj	queue object handle
**
**	Returns:
**		None
*/
void CheckConn(char        *IQName,
	       char	   *IQMgrName,
               MQHOBJ      *QueueHobj)
{
 SLONG index;
 CONNINFO *tmp_ptr = MQMServerId.pConnList;

 /* Init values to be returned                              */
 *QueueHobj = 0;

 for (index = 1; index < MQMServerId.total_used; index++)
 {
    if ((strncmp(IQName,tmp_ptr[index].RepQName,MQ_Q_NAME_LENGTH) == 0) && (strncmp(IQMgrName,tmp_ptr[index].QMgrName,MQ_Q_MGR_NAME_LENGTH) == 0))
    {
       *QueueHobj = tmp_ptr[index].RepQHobj;
       break;
    }
 }

 return;

} /* end of CheckConn */




/*
**	SaveConn
**
**	After connecting to the appropriate queues, the server can add
**	the connection information to a linked list. This list will
**	serve as persistent information on how many queue manager and
**	reply queues the server has connected to.
**
**	Inputs:
**		IQName		input queue name
**		QueueHobj	queue object handle
**
**	Outputs:
**		None
**
**	Returns:
**		None
*/
void SaveConn(char        *IQName,
	      char	  *IQMgrName,
              MQHOBJ      QueueHobj)
{
 SLONG index,mem_size;
 CONNINFO *tmp_ptr;

 if (MQMServerId.total_used == MQMServerId.total_count)
 {
   /* ok, we used up everything - allocate new memory block */
   mem_size = sizeof(CONNINFO) * (QUEUE_LIST_INCREMENT +
                                  MQMServerId.total_used);
   tmp_ptr = (CONNINFO *)malloc(mem_size);
   memset(tmp_ptr, 0, mem_size);
   memcpy(tmp_ptr, &MQMServerId.pConnList,
          sizeof(CONNINFO) * MQMServerId.total_count);
   MQMServerId.total_count += QUEUE_LIST_INCREMENT;
   free(MQMServerId.pConnList);
   MQMServerId.pConnList = tmp_ptr;
 }

 index = MQMServerId.total_used++;
 tmp_ptr = &MQMServerId.pConnList[index];
 strncpy(tmp_ptr->RepQName, IQName, MQ_Q_NAME_LENGTH);
 strncpy(tmp_ptr->QMgrName, IQMgrName, MQ_Q_MGR_NAME_LENGTH);
 tmp_ptr->RepQHobj = QueueHobj;

 return;

} /* end of SaveConn */




/*
**	CheckClConn
**
**	This routine checks if the client already made a connection to
**	the input queue manager, request, and reply queue. If the client
**	is already connected to the queue manager, the connection handle is
**	returned. If the client already opened the request queue, the
**	queue object handle is returned. Same goes for reply queue.
**
**	Inputs:
**		pClConn		connection information
**
**	Outputs:
**		pClConn		connection information
**
**	Returns:
**		None
*/
void CheckClConn(CONNINFO *pClConn)
{
   SLONG index;
   CONNINFO *ptmp_ClConn;

   /* initialize client connection info                              */
   pClConn->QMgrHcon = 0;
   pClConn->ReqQHobj = 0;
   pClConn->RepQHobj = 0;

   /* First find out if queue manager has been connected. If so, save*/
   /* the queue manager connection handle.                           */
   if ((MQMServerId.pConnList) &&
	  (strncmp(MQMServerId.pConnList[0].QMgrName,pClConn->QMgrName,
               MQ_Q_MGR_NAME_LENGTH) == 0))
   {
      pClConn->QMgrHcon = MQMServerId.pConnList[0].QMgrHcon;
   }
   else
   {
      for (index = 0; index < MQMClientId.total_used; index++)
      {
          ptmp_ClConn = &MQMClientId.pConnList[index];
          if (strncmp(ptmp_ClConn->QMgrName,pClConn->QMgrName,
                      MQ_Q_MGR_NAME_LENGTH) == 0)
          {
             pClConn->QMgrHcon = ptmp_ClConn->QMgrHcon;
             break;
          }
      }
   }
   /* Next find out if request queue has been opened. If so, save the*/
   /* request queue object handle.                                   */

   for (index = 0; index < MQMClientId.total_used; index++)
   {
       ptmp_ClConn = &MQMClientId.pConnList[index];
       if (strncmp(ptmp_ClConn->ReqQName,pClConn->ReqQName,
                    MQ_Q_NAME_LENGTH) == 0)
       {
          pClConn->ReqQHobj = ptmp_ClConn->ReqQHobj;
          break;
       }
   }

   /* Last find out if reply queue has been opened. If so, save the  */
   /* reply queue object handle.                                     */

   for (index = 0; index < MQMClientId.total_used; index++)
   {
       ptmp_ClConn = &MQMClientId.pConnList[index];
       if (strncmp(ptmp_ClConn->RepQName,pClConn->RepQName,
                    MQ_Q_NAME_LENGTH) == 0)
       {
          pClConn->RepQHobj = ptmp_ClConn->RepQHobj;
          break;
       }
   }

   return;

} /* end of CheckClConn */




/*
**	SaveClConn
**
**	After connecting to the appropriate queues, the client can add
**	the connection information to a linked list. This list will
**	serve as persistent information on how many queue managers,
**	request, and reply queues the client has connected to.
**
**	Inputs:
**		pClConn		connection information
**
**	Outputs:
**		slot_id		slot id
**
**	Returns:
**		None
*/
void SaveClConn(CONNINFO *pClConn, 
                SLONG      *slot_id)
{

   CONNINFO *ptmp_ClConn;
   SLONG      index,found,mem_size;

   /* First, find an empty slot to store data                        */
   found = FALSE;
   for (index = 0; index < MQMClientId.total_used; index++)
   {
       ptmp_ClConn = &MQMClientId.pConnList[index];
/* #ifdef DEBUG */
       fprintf(stdout,"index = %d, qmgr = %d\n",index,ptmp_ClConn->QMgrName[0]);
       fflush(stdout);
/* #endif */
       if (ptmp_ClConn->QMgrName[0] == 0)
       {
/* #ifdef DEBUG */
           fprintf(stdout,"slot id %d appears to be free\n",index);
           fflush(stdout);
/* #endif */
           found = TRUE;
           *slot_id = index;
           break;
       }
   }
   if (found)
   {
      memcpy(ptmp_ClConn,pClConn,sizeof(CONNINFO));
      return;
   }

   /* So far, no empty slot has been found to save our info.        */
   /* Check the current memory block to see if we have enough room  */
   /* for one more.                                                 */
   if (MQMClientId.total_count == MQMClientId.total_used)
   {
      /* no more room, create a new memory block */
      mem_size = sizeof(CONNINFO) * (MQMClientId.total_count +
                 QUEUE_LIST_INCREMENT);
      ptmp_ClConn = (CONNINFO *)malloc(mem_size);
      if (!ptmp_ClConn)
      {
         /* problem */
         return;
      }
      memset(ptmp_ClConn,0,mem_size);
      memcpy(ptmp_ClConn,MQMClientId.pConnList,
             sizeof(CONNINFO) * MQMClientId.total_count);
      free(MQMClientId.pConnList);
      MQMClientId.pConnList = ptmp_ClConn;
      MQMClientId.total_count += QUEUE_LIST_INCREMENT;
   }

   /* Now we are ready to copy the information over.                */
   index = MQMClientId.total_used++;
   ptmp_ClConn = &MQMClientId.pConnList[index];
   memcpy(ptmp_ClConn,pClConn,sizeof(CONNINFO));
   *slot_id = index;

   return;

} /* end of SaveClConn */




/*
**	ClActiveConn
**
**	This routine tells a process how many connection it has with MQSeries
**	(either as client or server).
**
**	Inputs:
**		None
**
**	Outputs:
**		None
**
**	Returns:
**		active_conn	number of active queue manager connection
*/
SLONG ClActiveConn()
{
   SLONG active_conn,index;
   CONNINFO *ptmp_ClConn;

   active_conn = MQMServerId.total_used;

   for (index = 0; index < MQMClientId.total_used; index++)
   {
       ptmp_ClConn = &MQMClientId.pConnList[index];
       if (ptmp_ClConn->QMgrName[0] != 0)
          active_conn++;
   }

   return(active_conn);

} /* end of ClActiveConn */




/*
**	mqm_signal
**
**	A wrapper function for the sigaction() system call.
**
**	Inputs:
**		signo		signal number
**		func		signal catcher function
**
**	Outputs:
**		None
**
**	Returns:
**		oact.sa_handler	address of old signal catcher function
*/
Sigfunc * mqm_signal(int signo, Sigfunc *func)
{
	struct sigaction	act,oact;

	act.sa_handler = func;
	sigemptyset(&act.sa_mask);
	act.sa_flags = 0;
	if (signo == SIGALRM)
	{
#ifdef SA_INTERRUPT
		act.sa_flags |= SA_INTERRUPT;
#endif
	}
	else
	{
#ifdef SA_RESTART
		act.sa_flags |= SA_RESTART;
#endif
	}
	if (sigaction(signo, &act, &oact) < 0)
		return (SIG_ERR);
	return (oact.sa_handler);
} /* end of mqm_signal */




/*
**	LV
**
**	Dump message contents for debug purpose.
**
**	Inputs:
**		length		number of bytes to dump
**		msg		starting address for dump
**
**	Outputs:
**		None
**
**	Returns:
**		None
*/
void LV(int length, char *msg)
{
        char    hex[MAX_CHAR_PER_LINE];
        char    ch;
        int     count;
 
        fprintf(stdout,"LV: Message Length %d\n",length);
 
        memset (hex, 0, MAX_CHAR_PER_LINE);
        count = 0;
 
        while (length > 0) {
                ch = *msg++;
                hex[count] = ch;
                length--;
                count++;
                if (count == MAX_CHAR_PER_LINE) {
                        hex_dmp(hex, count);
                        chr_dmp(hex, count);
                        count = 0;
                        memset (hex, 0, MAX_CHAR_PER_LINE);
                }
        }
        if (count) {
                hex_dmp(hex, count);
                chr_dmp(hex, count);
        }
 
        fflush(stdout);

	return;
} /* end of LV */
 


 
/*
**	hex_dmp
**
**	Dump message contents in hex for debug purpose.
**
**	Inputs:
**		msg		starting address for dump
**		count		number of bytes to dump
**
**	Outputs:
**		None
**
**	Returns:
**		None
*/
void hex_dmp(char *msg, int count)
{
        int     i,j;
 
        for (i = 0; i < count; i++)
		fprintf(stdout, "%02x ",(unsigned char) msg[i]);
	for (j = i; j < MAX_CHAR_PER_LINE; j++)
		fprintf(stdout,"   ");

        fprintf(stdout, "----- ");

	return;
} /* end of hex_dmp */

 
/*
**	chr_dmp
**
**	Dump message contents in ASCII for debug purpose. Non-printable
**	characters are replaced by '~' character.
**
**	Inputs:
**		msg		starting address for dump
**		count		number of bytes to dump
**
**	Outputs:
**		None
**
**	Returns:
**		None
*/
void chr_dmp(char *msg, int count)
{
        int     i;
 
        for (i = 0; i < count; i++) {
                if ((msg[i] > 31) && (msg[i] < 127))
                        fprintf(stdout, "%c", msg[i]);
                else
                        fprintf(stdout, "~");
        }
        fprintf(stdout, "\n");

	return;
} /* end of chr_dmp */

char * version () {
        return VERSION;
}

/*
**	getMQMD
**
**	Convert the MQMD structure into a name=value pair string.
**	The delimiter between the name=value pairs is '\3'.
**
**	Inputs:
**		input		pointer to MQMD structure
**
**	Outputs:
**		output		name=value pair string
**
**	Returns:
**		None
*/
void getMQMD(MQMD *input, char *output)
{
	char str_mqmd[MAX_MQMD_SIZE];

#ifdef DEBUG
   fprintf(stdout,"getMQMD: Input Length - %d\n",sizeof(input));
   fflush(stdout);
#endif /* DEBUG */

	memset((char *)str_mqmd,0,MAX_MQMD_SIZE);

	sprintf((char *)str_mqmd,"STRUCID=%s\3",input->StrucId);
	sprintf((char *)str_mqmd,"%sVERSION=%d\3",str_mqmd,input->Version);
	sprintf((char *)str_mqmd,"%sREPORT=%d\3",str_mqmd,input->Report);
	sprintf((char *)str_mqmd,"%sMSGTYPE=%d\3",str_mqmd,input->MsgType);
	sprintf((char *)str_mqmd,"%sEXPIRY=%d\3",str_mqmd,input->Expiry);
	sprintf((char *)str_mqmd,"%sFEEDBACK=%d\3",str_mqmd,input->Feedback);
	sprintf((char *)str_mqmd,"%sENCODING=%d\3",str_mqmd,input->Encoding);
	sprintf((char *)str_mqmd,"%sCODEDCHARSETID=%d\3",str_mqmd,input->CodedCharSetId);
	sprintf((char *)str_mqmd,"%sFORMAT=%-8s\3",str_mqmd,input->Format);
	sprintf((char *)str_mqmd,"%sPRIORITY=%d\3",str_mqmd,input->Priority);
	sprintf((char *)str_mqmd,"%sPERSISTENCE=%d\3",str_mqmd,input->Persistence);
	sprintf((char *)str_mqmd,"%sMSGID=%-24s\3",str_mqmd,input->MsgId);
	sprintf((char *)str_mqmd,"%sCORRELID=%-24s\3",str_mqmd,input->CorrelId);
	sprintf((char *)str_mqmd,"%sBACKOUTCOUNT=%d\3",str_mqmd,input->BackoutCount);
	sprintf((char *)str_mqmd,"%sREPLYTOQ=%-48s\3",str_mqmd,input->ReplyToQ);
	sprintf((char *)str_mqmd,"%sREPLYTOQMGR=%-48s\3",str_mqmd,input->ReplyToQMgr);
	sprintf((char *)str_mqmd,"%sUSERIDENTIFIER=%-12s\3",str_mqmd,input->UserIdentifier);
	sprintf((char *)str_mqmd,"%sACCOUNTINGTOKEN=%-32s\3",str_mqmd,input->AccountingToken);
	sprintf((char *)str_mqmd,"%sAPPLIDENTITYDATA=%-32s\3",str_mqmd,input->ApplIdentityData);
	sprintf((char *)str_mqmd,"%sPUTAPPLTYPE=%d\3",str_mqmd,input->PutApplType);
	sprintf((char *)str_mqmd,"%sPUTAPPLNAME=%-28s\3",str_mqmd,input->PutApplName);
	sprintf((char *)str_mqmd,"%sPUTDATE=%-8s\3",str_mqmd,input->PutDate);
	sprintf((char *)str_mqmd,"%sPUTTIME=%-8s\3",str_mqmd,input->PutTime);
	sprintf((char *)str_mqmd,"%sAPPLORIGINDATA=%s\3",str_mqmd,input->ApplOriginData);
	sprintf((char *)str_mqmd,"%sGROUPID=%-24s\3",str_mqmd,input->GroupId);
	sprintf((char *)str_mqmd,"%sMSGSEQNUMBER=%d\3",str_mqmd,input->MsgSeqNumber);
	sprintf((char *)str_mqmd,"%sOFFSET=%d\3",str_mqmd,input->Offset);
	sprintf((char *)str_mqmd,"%sMSGFLAGS=%d\3",str_mqmd,input->MsgFlags);
	sprintf((char *)str_mqmd,"%sORIGINALLENGTH=%d\3\0",str_mqmd,input->OriginalLength);
	
	memcpy(output,str_mqmd,MAX_MQMD_SIZE);

#ifdef DEBUG
   fprintf(stdout,"getMQMD: output - %s\n",output);
   fflush(stdout);
#endif /* DEBUG */

	return;
}

/*
**	setMQMD
**
**	Convert the name=value pair string into an MQMD structure.
**	The delimiter between the name=value pairs is '\3'.
**
**	Inputs:
**		input		name=value pair string
**
**	Outputs:
**		output		pointer to MQMD structure
**
**	Returns:
**		None
*/
void setMQMD(char *input, MQMD *output)
{
	int i,pos,flag;
	char str_mqmd[MAX_MQMD_SIZE];
	char msg_id[50];
	char *mqmd_elmnt = NULL;
	char option[30],value[170];
	char s_mqmd[200];
	char value1[31];
	char delim[2];
	long lvalue;
	int msgflag = 0;

	delim[0] = '\3';
	delim[1] = '\0';

#ifdef DEBUG
   fprintf(stdout,"setMQMD: input message - %s\nLength - %d\n",input,strlen(input));
   fflush(stdout);
#endif /* DEBUG */

	memcpy((char *) str_mqmd,input,strlen(input));

	mqmd_elmnt = strtok(str_mqmd,delim);

	flag = 0;

	for (i = 0; (i < MAX_MQMD_ELEMENTS)&&(mqmd_elmnt != NULL);i++)
	{
		lvalue = 0, pos = 0;
		memset(option,0,30);
		memset(value,0,170);

		sscanf(mqmd_elmnt,"%[^=]=%s",option,value);

#ifdef DEBUG
   fprintf(stdout,"setMQMD: Option = %s | Value = %s\n",option,value);
   fflush(stdout);
#endif /* DEBUG */

		switch (getvalue(option)) {
		case 1: strcpy(output->StrucId,MQMD_STRUC_ID); break;
		case 2: 
			lvalue = strtol(value,NULL,10);
			output->Version = lvalue;
			break;
		case 3: 
			lvalue = strtol(value,NULL,10);
			output->Report = lvalue;
			break;
		case 4: 
			lvalue = strtol(value,NULL,10);
			output->MsgType = lvalue;
			break;
		case 5: 
			lvalue = strtol(value,NULL,10);
			output->Expiry = lvalue;
			break;
		case 6: 
			lvalue = strtol(value,NULL,10);
			output->Feedback = lvalue;
			break;
		case 7: 
			lvalue = strtol(value,NULL,10);
			output->Encoding = lvalue;
			break;
		case 8: 
			lvalue = strtol(value,NULL,10);
			output->CodedCharSetId = lvalue;
			break;
		case 9: sprintf(output->Format,"%-8s\0",value); break;
		case 10: 
			lvalue = strtol(value,NULL,10);
			output->Priority = lvalue;
			break;
		case 11: 
			lvalue = strtol(value,NULL,10);
			output->Persistence = lvalue;
			break;
		case 12: 
			memcpy(msg_id,mqmd_elmnt,strlen(mqmd_elmnt)); 
			msgflag = 1;
			break;
		case 13: sprintf(output->CorrelId,"%-24s\0",value); break;
		case 14: 
			lvalue = strtol(value,NULL,10);
			output->BackoutCount = lvalue;
			break;
		case 15: sprintf(output->ReplyToQ,"%-48s\0",value); break;
		case 16: sprintf(output->ReplyToQMgr,"%-48s\0",value); break;
		case 17: sprintf(output->UserIdentifier,"%-12s\0",value); break;
		case 18: sprintf(output->AccountingToken,"%-32s\0",value); break;
		case 19: sprintf(output->ApplIdentityData,"%-32s\0",value); break;
		case 20: 
			lvalue = strtol(value,NULL,10);
			output->PutApplType = lvalue;
			break;
		case 21: sprintf(output->PutApplName,"%-28s\0",value); break;
		case 22: sprintf(output->PutDate,"%-8s\0",value); break;
		case 23: sprintf(output->PutTime,"%-8s\0",value); break;
		case 24: strcpy(output->ApplOriginData,value); break;
		case 25: strcpy(output->GroupId,value); break;
		case 26: 
			lvalue = strtol(value,NULL,10);
			output->MsgSeqNumber = lvalue;
			break;
		case 27: 
			lvalue = strtol(value,NULL,10);
			output->Offset = lvalue;
			break;
		case 28: 
			lvalue = strtol(value,NULL,10);
			output->MsgFlags = lvalue;
			break;
		case 29: 
			lvalue = strtol(value,NULL,10);
			output->OriginalLength = lvalue;
			break;
		default: 
#ifdef DEBUG
   fprintf(stdout,"setMQMD: Invalid MQMD element name - %s\n",option);
   fflush(stdout);
#endif /* DEBUG */
			break;
		}
		mqmd_elmnt = strtok(NULL,delim);
	}

	if (msgflag)
	{
		getmsgid(msg_id,value1);
		memcpy(output->MsgId,value1,24);
	}
	return;
}

/*
**	getvalue
**
**	Returns the position of the given MQMD element.
**
**	Inputs:
**		option		MQMD element
**
**	Outputs:
**
**	Returns:
**		Position
*/
int getvalue(char *option)
{
	if (strcmp(option,"STRUCID") == 0) return 1;
	else if (strcmp(option,"VERSION") == 0) return 2;
	else if (strcmp(option,"REPORT") == 0) return 3;
	else if (strcmp(option,"MSGTYPE") == 0) return 4;
	else if (strcmp(option,"EXPIRY") == 0) return 5;
	else if (strcmp(option,"FEEDBACK") == 0) return 6;
	else if (strcmp(option,"ENCODING") == 0) return 7;
	else if (strcmp(option,"CODEDCHARSETID") == 0) return 8;
	else if (strcmp(option,"FORMAT") == 0) return 9;
	else if (strcmp(option,"PRIORITY") == 0) return 10;
	else if (strcmp(option,"PERSISTENCE") == 0) return 11;
	else if (strcmp(option,"MSGID") == 0) return 12;
	else if (strcmp(option,"CORRELID") == 0) return 13;
	else if (strcmp(option,"BACKOUTCOUNT") == 0) return 14;
	else if (strcmp(option,"REPLYTOQ") == 0) return 15;
	else if (strcmp(option,"REPLYTOQMGR") == 0) return 16;
	else if (strcmp(option,"USERIDENTIFIER") == 0) return 17;
	else if (strcmp(option,"ACCOUNTINGTOKEN") == 0) return 18;
	else if (strcmp(option,"APPLIDENTITYDATA") == 0) return 19;
	else if (strcmp(option,"PUTAPPLTYPE") == 0) return 20;
	else if (strcmp(option,"PUTAPPLNAME") == 0) return 21;
	else if (strcmp(option,"PUTDATE") == 0) return 22;
	else if (strcmp(option,"PUTTIME") == 0) return 23;
	else if (strcmp(option,"APPLORIGINDATA") == 0) return 24;
	else if (strcmp(option,"GROUPID") == 0) return 25;
	else if (strcmp(option,"MSGSEQNUMBER") == 0) return 26;
	else if (strcmp(option,"OFFSET") == 0) return 27;
	else if (strcmp(option,"MSGFLAGS") == 0) return 28;
	else if (strcmp(option,"ORIGINALLENGTH") == 0) return 29;
	else return 0;
}

void getmsgid(char *mqmd_elmnt, char *value)
{
	char *dummy;
	char *option;

	option = strtok(mqmd_elmnt,"=");
	value = strtok(NULL,"=");
	dummy = strtok(NULL,"=");

	return;
}
