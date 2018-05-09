/*****************************************************************************
*
*	mqserver.c
*
*	Copyright(c)2000 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	Description: Sanchez MQSeries Server API for Unix
*
*	ORIG: Hien T. Ly - March 1999
*
* $Id: mqserver.c,v 1.4 2000/11/15 16:50:40 lyh Exp lyh $
*
* $Log: mqserver.c,v $
 * Revision 1.6  2005/03/24  thoniyim
 * Modified functions SrvGetMsg and SrvReply to retrieve/send MQMD info
 * from/to the user.
 *
 * Revision 1.5  2004/03/08  10:16:38  thoniyim
 * GetClQIni function is changed to return UserID read from INI file
 *
 * Revision 1.4  2000/11/15  16:50:40  lyh
 * Use REPQ as default reply to queue.
 *
 * Revision 1.3  2000/11/10  13:40:51  lyh
 * Replaced sizeof() with constant MQ_MSG_ID_LENGTH and MQ_CORREL_ID_LENGTH
 * Declared external function prototypes
 *
 * Revision 1.2  2000/11/08  20:23:09  lyh
 * Added format MQFMT_STRING in server reply message.
 *
 * Revision 1.1  2000/11/08  19:56:55  lyh
 * Initial revision
 *
*
* $Revision: 1.4 $
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

/*------------ Global Variables ------------*/
CONNLIST MQMServerId = {0,0,NULL};	/* Server connect information    */
char     *svreq_buffer;			/* server request message buffer */
char     *svrep_buffer;			/* server reply message buffer   */
char     *svmqmd_buffer;		/* server MQMD buffer 		 */
MQBYTE24 saveMsgId;			/* saved message id              */
MQBYTE24 saveCorrelId;			/* saved correlation id          */
MQCHAR48 saveReplyToQ;			/* saved reply to queue          */
MQCHAR48 saveReplyToQMgr;		/* saved reply to queue manager  */
MQCHAR48 defaultReplyToQ;		/* default reply to queue        */
MQCHAR48 defaultReplyToQMgr;		/* default reply to queue manager*/
Sigfunc  *sHSIGALRM;			/* prev SIGALRM handler          */
Sigfunc  *sHSIGBUS;			/* prev SIGBUS handler           */
Sigfunc  *sHSIGFPE;			/* prev SIGFPE handler           */
Sigfunc  *sHSIGSEGV;			/* prev SIGSEGV handler          */

/*------------ External Variables ------------*/
extern CONNLIST MQMClientId;		/* Client connect information    */

/*------------ External Functions ------------*/
extern Sigfunc *mqm_signal(int, Sigfunc *);
extern void GetClQIni(char *, char *, char *, char *, char*);
extern void CheckConn(char *, char *, MQHOBJ *);
extern void SaveConn(char *, char *, MQHOBJ);
extern void LV(int, char *);
extern void getMQMD(MQMD *, char *);
extern void setMQMD(char *, MQMD *);

/*------------ Local Functions ------------*/
void sv_signal_catcher(int);
int sv_setup_handlers();
int sv_cancel_handlers();




/*
**	SrvConnect
**
**	Connect to MQSeries and open request queue.
**
**	Inputs:
**		count		non-zero if calling from M.
**		srv_type_name	environment variable that point to an INI file 
**
**	Outputs:
**		qmgr_id		the queue manager object handler
**		return_code	SUCCESS or FAILURE
**
**	Returns:
**		None
*/
void SrvConnect(int count,
                char *srv_type_name,
                SLONG *qmgr_id,
                SLONG *return_code)
{
   MQOD     SvodG = {MQOD_DEFAULT}; /* Object Descriptor (request)   */
   MQLONG   CompCode;               /* completion code               */
   MQLONG   Reason;                 /* reason code                   */
   MQLONG   O_options;              /* MQOPEN options                */
   MQHCONN  QMgrHcon;               /* Queue mgr connection handle   */
   MQHOBJ   ReqQHobj;               /* Request queue object handle   */
   char     QMName[MQ_Q_MGR_NAME_LENGTH];
   char     ReqQName[MQ_Q_NAME_LENGTH];
   char     RepQName[MQ_Q_NAME_LENGTH];
   char     UserId[MQ_USER_ID_LENGTH];
   CONNINFO *tmp_ptr;
   SLONG    mem_size;

#ifdef DEBUG
   fprintf(stdout,"\nStart of SrvConnect\n");
   fflush(stdout);
#endif

   *return_code = SUCCESS;

 do
 {
   /******************************************************************/
   /*                                                                */
   /* Before we do anything, let's establish the signal handlers.    */
   /*                                                                */
   /******************************************************************/
   if (sv_setup_handlers() == -1)
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Problem establishing new signal handlers\n");
     fflush(stdout);
#endif
     break;
   }

   /******************************************************************/
   /*                                                                */
   /*     Get queue manager and request queue names.                 */
   /*                                                                */
   /******************************************************************/
   memset(QMName,'\0',sizeof(QMName));
   memset(ReqQName,'\0',sizeof(ReqQName));
   memset(RepQName,'\0',sizeof(RepQName));
   memset(UserId,'\0',MQ_USER_ID_LENGTH);
   memset(defaultReplyToQ,'\0',sizeof(defaultReplyToQMgr));
   memset(defaultReplyToQMgr,'\0',sizeof(defaultReplyToQMgr));
   GetClQIni(srv_type_name, QMName, ReqQName, RepQName, UserId);
   if ((QMName[0] == '\0') || (ReqQName[0] == '\0'))
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Queue manager and/or queue names not defined\n");
     fflush(stdout);
#endif
     break;
   }

   /******************************************************************/
   /*                                                                */
   /*     Save default information                                   */
   /*                                                                */
   /******************************************************************/
   strncpy(defaultReplyToQ, RepQName,sizeof(defaultReplyToQ));
   strncpy(defaultReplyToQMgr, QMName, sizeof(defaultReplyToQMgr));

   /******************************************************************/
   /*                                                                */
   /*     Allocate memory to request message buffer                  */
   /*                                                                */
   /******************************************************************/
   svreq_buffer = (char *)malloc(MAX_MSG_SIZE);
   svrep_buffer = (char *)malloc(MAX_MSG_SIZE);
   svmqmd_buffer = (char *)malloc(MAX_MQMD_SIZE);
   if ((!svreq_buffer) || (!svrep_buffer) || (!svmqmd_buffer))
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Unable to allocate memory for request/reply message\n");
     fflush(stdout);
#endif
     break;
   }

   /******************************************************************/
   /*                                                                */
   /*     Allocate memory to reply queue list                        */
   /*     We'll start with n slots for reply queues,                 */
   /*     where n = QUEUE_LIST_INCREMENT                             */
   /*                                                                */
   /******************************************************************/
   mem_size = sizeof(CONNINFO) * QUEUE_LIST_INCREMENT;
   tmp_ptr = (CONNINFO *)malloc(mem_size);
                                   
   if (!tmp_ptr)
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Unable to allocate memory for reply queue struct\n");
     fflush(stdout);
#endif
     break;
   }
   memset(tmp_ptr, 0, mem_size);
   MQMServerId.total_count = QUEUE_LIST_INCREMENT;
   MQMServerId.total_used  = 0;
   MQMServerId.pConnList   = tmp_ptr;

#ifdef DEBUG
   fprintf(stdout,"Queue manager name: %s\n",QMName);
   fprintf(stdout,"Request queue name: %s\n",ReqQName);
   fprintf(stdout,"Reply queue name: %s\n",RepQName);
   fprintf(stdout,"Before MQCONN\n");
   fflush(stdout);
#endif /* DEBUG */
   /******************************************************************/
   /*                                                                */
   /*   Connect to queue manager                                     */
   /*                                                                */
   /******************************************************************/
   MQCONN(QMName,                  /* queue manager name             */
          &QMgrHcon,               /* connection handle              */
          &CompCode,               /* completion code                */
          &Reason);                /* reason code                    */
 
   /* report reason and stop if it failed     */
   if (CompCode != MQCC_OK)
   {
     if (Reason != MQRC_ALREADY_CONNECTED)
     {
        *return_code = Reason;
#ifdef DEBUG
        fprintf(stdout,"MQCONN ended with reason code %ld\n", Reason);
        fflush(stdout);
#endif
        MQM_LOG(CompCode,Reason);
        break;
     }
   }
 

   /******************************************************************/
   /*                                                                */
   /*   Open the request message queue for shared input              */
   /*                                                                */
   /******************************************************************/
   memcpy(SvodG.ObjectName,            /* name of input queue        */
          ReqQName, MQ_Q_NAME_LENGTH);
   O_options = MQOO_INPUT_SHARED       /* open queue for shared input*/
             + MQOO_FAIL_IF_QUIESCING; /* but not if MQM stopping    */
   MQOPEN(QMgrHcon,                    /* connection handle          */
          &SvodG,                      /* obj desc for request queue */
          O_options,                   /* open options               */
          &ReqQHobj,                   /* object handle              */
          &CompCode,                   /* MQOPEN completion code     */
          &Reason);                    /* reason code                */
 
   /* report reason if any; stop if it failed     */
   if (CompCode != MQCC_OK)
   {
     *return_code = Reason;
#ifdef DEBUG
     fprintf(stdout,"MQOPEN ended with reason code %ld\n", Reason);
     fflush(stdout);
#endif
     MQM_LOG(CompCode, Reason);
     break;
   }

   /******************************************************************/
   /*                                                                */
   /* Everything is fine up to here. Now save the connection info in */
   /* slot 0.                                                        */
   /*                                                                */
   /******************************************************************/
   tmp_ptr = &MQMServerId.pConnList[0];
   memcpy(tmp_ptr->QMgrName, QMName, MQ_Q_MGR_NAME_LENGTH);
   memcpy(tmp_ptr->ReqQName, ReqQName, MQ_Q_NAME_LENGTH);
   tmp_ptr->QMgrHcon = QMgrHcon;
   tmp_ptr->ReqQHobj = ReqQHobj;
   MQMServerId.total_used = 1;
   *qmgr_id = QMgrHcon;

   break;
 } while (0);

   /******************************************************************/
   /*                                                                */
   /* Always restore the previous signal handlers.                   */
   /*                                                                */
   /******************************************************************/
   if (sv_cancel_handlers() == -1)
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"Problem restoring previous signal handlers\n");
      fflush(stdout);
#endif /* DEBUG */
   }

#ifdef DEBUG
   fprintf(stdout,"Queue manager object handle %d\n",*qmgr_id);
   fprintf(stdout,"End of SrvConnect - successful completion\n");
   fflush(stdout);
#endif

   return;
} /* end of SrvConnect */




/*
**	SrvGetMsg
**
**	Retrieve a message on the request queue.
**
**	Inputs:
**		count		non-zero if calling from M.
**		timeout		timeout in seconds
**
**	Outputs:
**		msg		request message
**		return_code	SUCCESS or FAILURE
**
**	Returns:
**		None
*/

/*****

void SrvGetMsg(int count,
               STR_DESCRIPTOR *msg,
               SLONG timeout,
               SLONG *return_code)
{
   MQMD     Svmd  = {MQMD_DEFAULT};
   MQGMO    Svgmo = {MQGMO_DEFAULT};
   MQLONG   CompCode;
   MQLONG   Reason;
   int      buflen;
   MQLONG   messlen;
   CONNINFO *tmp_ptr;

#ifdef DEBUG
   fprintf(stdout,"\nStart of SrvGetMsg\n");
   fflush(stdout);
#endif

   *return_code = SUCCESS;

 do
 {
   if (sv_setup_handlers() == -1)
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Problem establishing new signal handlers\n");
     fflush(stdout);
#endif
     break;
   }

   if (!MQMServerId.pConnList)
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Memory access violation\n");
     fflush(stdout);
#endif
     break;
   }

   tmp_ptr = &MQMServerId.pConnList[0];

   buflen = MAX_MSG_SIZE;

   Svgmo.Options = MQGMO_ACCEPT_TRUNCATED_MSG
                 + MQGMO_CONVERT
                 + MQGMO_WAIT;
   Svgmo.WaitInterval = timeout*1000;

   Svmd.Encoding = MQENC_NATIVE;
   Svmd.CodedCharSetId = MQCCSI_Q_MGR;
 
   memcpy(Svmd.MsgId, MQMI_NONE, MQ_MSG_ID_LENGTH);
   memcpy(Svmd.CorrelId, MQCI_NONE, MQ_CORREL_ID_LENGTH);

   MQGET(tmp_ptr->QMgrHcon,
         tmp_ptr->ReqQHobj,
         &Svmd,
         &Svgmo,
         buflen,
         svreq_buffer,
         &messlen,
         &CompCode,
         &Reason);
 
   if (CompCode != MQCC_OK)
   {
     *return_code = Reason;
#ifdef DEBUG
     if (Reason != MQRC_NO_MSG_AVAILABLE)
     {
        fprintf(stdout,"MQGET ended with reason code %ld\n", Reason);
        fflush(stdout);
        MQM_LOG(CompCode, Reason);
     }
#endif
     break;
   }

   memcpy(saveMsgId, Svmd.MsgId, MQ_MSG_ID_LENGTH);
   memcpy(saveCorrelId, Svmd.CorrelId, MQ_CORREL_ID_LENGTH);
   if (Svmd.ReplyToQ[0] == '\0')
   	strncpy(saveReplyToQ, defaultReplyToQ, MQ_Q_NAME_LENGTH);
   else
   	strncpy(saveReplyToQ, Svmd.ReplyToQ, MQ_Q_NAME_LENGTH);
   if (Svmd.ReplyToQMgr[0] == '\0')
   	strncpy(saveReplyToQMgr, defaultReplyToQMgr, MQ_Q_MGR_NAME_LENGTH);
   else
   	strncpy(saveReplyToQMgr, Svmd.ReplyToQMgr, MQ_Q_MGR_NAME_LENGTH);
               
   msg->str = svreq_buffer;
   msg->length = messlen;

   break;
 } while (0);

   if (sv_cancel_handlers() == -1)
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"Problem restoring previous signal handlers\n");
      fflush(stdout);
#endif
   }

   return;
}

*****/

/*
**      SrvGetMsg
**
**      Retrieve a message on the request queue.
**
**      Inputs:
**              count           non-zero if calling from M.
**              timeout         timeout in seconds
**
**      Outputs:
**              msg             request message
**              mqmd		message descriptor
**              return_code     SUCCESS or FAILURE
**
**      Returns:
**              None
*/
void SrvGetMsg(int count,
               STR_DESCRIPTOR *msg,
               char *mqmd,
               SLONG timeout,
               SLONG *return_code)
{
   MQMD     Svmd  = {MQMD_DEFAULT};  /* Message Descriptor           */
   MQGMO    Svgmo = {MQGMO_DEFAULT}; /* get message options          */
   MQLONG   CompCode;                /* completion code              */
   MQLONG   Reason;                  /* reason code                  */
   int      buflen;          	     /* buffer length		     */
   MQLONG   messlen;		     /* message length		     */
   CONNINFO *tmp_ptr;
 
#ifdef DEBUG
   fprintf(stdout,"\nStart of SrvGetMsg\n");
   fflush(stdout);
#endif
 
   *return_code = SUCCESS;
 
 do
 {
   /******************************************************************/
   /*                                                                */
   /* Before we do anything, let's establish the signal handlers.    */
   /*                                                                */
   /******************************************************************/
   if (sv_setup_handlers() == -1)
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Problem establishing new signal handlers\n");
     fflush(stdout);
#endif
     break;
   }
 
   /******************************************************************/
   /*                                                                */
   /*     Check for access violation (memory)                        */
   /*                                                                */
   /******************************************************************/
   if (!MQMServerId.pConnList)
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Memory access violation\n");
     fflush(stdout);
#endif
     break;
   }
 
   tmp_ptr = &MQMServerId.pConnList[0];
 
   buflen = MAX_MSG_SIZE;
 
   /* set up get options                                             */
 
   Svgmo.Options = MQGMO_ACCEPT_TRUNCATED_MSG
                 + MQGMO_CONVERT      /* receive converted messages  */
                 + MQGMO_WAIT;        /* wait for new messages       */
   Svgmo.WaitInterval = timeout*1000; /* time is in milliseconds     */
 
   /* specify representation required                                */
   Svmd.Encoding = MQENC_NATIVE;
   Svmd.CodedCharSetId = MQCCSI_Q_MGR;
 
   /******************************************************************/
   /*                                                                */
   /*   In order to read the messages in sequence, MsgId and         */
   /*   CorrelID must have the default value.  MQGET sets them       */
   /*   to the values in for message it returns, so re-initialise    */
   /*   them before every call                                       */
   /*                                                                */
   /******************************************************************/
   memcpy(Svmd.MsgId, MQMI_NONE, MQ_MSG_ID_LENGTH);
   memcpy(Svmd.CorrelId, MQCI_NONE, MQ_CORREL_ID_LENGTH);

   MQGET(tmp_ptr->QMgrHcon,           /* server connection handle    */
         tmp_ptr->ReqQHobj,           /* request queue object handle */
         &Svmd,                       /* message descriptor          */
         &Svgmo,                      /* GET options                 */
         buflen,                      /* buffer length               */
         svreq_buffer,                /* server req message buffer   */
         &messlen,                    /* message length              */
         &CompCode,                   /* completion code             */
         &Reason);                    /* reason code                 */
 
   /* report reason if any */
   if (CompCode != MQCC_OK)
   {
     *return_code = Reason;
#ifdef DEBUG
     /* timeout is not an error, so don't log it */
     if (Reason != MQRC_NO_MSG_AVAILABLE)
     {
        fprintf(stdout,"MQGET ended with reason code %ld\n", Reason);
        fflush(stdout);
        MQM_LOG(CompCode, Reason);
     }
#endif
     break;
   }
 
   /******************************************************************/
   /*                                                                */
   /*     Get message is ok up to this point. Save message id and    */
   /*     correlation id for match purpose later.                    */
   /*                                                                */
   /******************************************************************/
   memcpy(saveMsgId, Svmd.MsgId, MQ_MSG_ID_LENGTH);
   memcpy(saveCorrelId, Svmd.CorrelId, MQ_CORREL_ID_LENGTH);
   if (Svmd.ReplyToQ[0] == '\0')
        strncpy(saveReplyToQ, defaultReplyToQ, MQ_Q_NAME_LENGTH);
   else
        strncpy(saveReplyToQ, Svmd.ReplyToQ, MQ_Q_NAME_LENGTH);
   if (Svmd.ReplyToQMgr[0] == '\0')
        strncpy(saveReplyToQMgr, defaultReplyToQMgr, MQ_Q_MGR_NAME_LENGTH);
   else
        strncpy(saveReplyToQMgr, Svmd.ReplyToQMgr, MQ_Q_MGR_NAME_LENGTH);
 
   /******************************************************************/
   /*                                                                */
   /*     Transfer the contents of request message buffer.           */
   /*                                                                */
   /******************************************************************/
   /* memcpy(msg->str,svreq_buffer,messlen) ; */
   /* Note: memcpy won't work because msg is empty */
#ifdef DEBUG
     fprintf(stdout,"SrvGetMsg: svreq_buffer - %s\nmesslen - %d\n",svreq_buffer,messlen);
     fflush(stdout);
#endif

   svreq_buffer[messlen]=0;
   msg->str = svreq_buffer;
   msg->length = messlen;

   /******************************************************************/
   /*                                                                */
   /*     Transfer the contents of the message descriptor.           */
   /*                                                                */
   /******************************************************************/

#ifdef DEBUG
     fprintf(stdout,"SrvGetMsg: msg->str - %s\nmsg-length - %d\n",msg->str,msg->length);
     fprintf(stdout,"SrvGetMsg: Before getMQMD\n");
     fflush(stdout);
#endif
 
   getMQMD(&Svmd,svmqmd_buffer);

   memcpy(mqmd,svmqmd_buffer,MAX_MQMD_SIZE);
 
#ifdef DEBUG
     fprintf(stdout,"SrvGetMsg: After getMQMD\n");
     fprintf(stdout,"SrvGetMsg: mqmd - %s\nlength - %d\n",mqmd,strlen(mqmd));
     fflush(stdout);
#endif
 
   break;
 } while (0);
 
   /******************************************************************/
   /*                                                                */
   /* Always restore the previous signal handlers.                   */
   /*                                                                */
   /******************************************************************/
   if (sv_cancel_handlers() == -1)
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"Problem restoring previous signal handlers\n");
      fflush(stdout);
#endif /* DEBUG */
   }
 
#ifdef DEBUG
   fprintf(stdout,"Incoming (request) message id:\n");
   LV(MQ_MSG_ID_LENGTH, (char *)&saveMsgId);
   fprintf(stdout,"Incoming (request) correlation id:\n");
   LV(MQ_CORREL_ID_LENGTH, (char *)&saveCorrelId);
   fprintf(stdout,"Incoming (request) message :\n");
   LV(msg->length,msg->str);
   fprintf(stdout,"End of SrvGetMsg - successful completion\n");
   fflush(stdout);
#endif
 
   /* Note: the calling program should not free the message buffer.  */
   /* The same message buffer is being used to later call.           */
 
   return;
} /* end of SrvGetMsg */
 
 

/*
**	SrvReply
**
**	Put a message on the reply queue.
**
**	Inputs:
**		count		non-zero if calling from M.
**		msg		reply message
**
**	Outputs:
**		return_code	SUCCESS or FAILURE
**
**	Returns:
**		None
*/

/*****

void SrvReply(int count, STR_DESCRIPTOR *msg, SLONG *return_code)
{
   MQOD     SvodR = {MQOD_DEFAULT};
   MQPMO    Svpmo = {MQPMO_DEFAULT};
   MQMD     Svmd  = {MQMD_DEFAULT};
   MQHOBJ   RepHobj;
   MQLONG   O_options;
   MQLONG   CompCode;
   MQLONG   Reason;
   int      messlen;
   CONNINFO *tmp_ptr;

#ifdef DEBUG
   fprintf(stdout,"\nStart of SrvReply\n");
   fflush(stdout);
#endif

   *return_code = SUCCESS;

 do
 {
   if (sv_setup_handlers() == -1)
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Problem establishing new signal handlers\n");
     fflush(stdout);
#endif
     break;
   }

   if (!MQMServerId.pConnList)
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Memory access violation\n");
     fflush(stdout);
#endif
     break;
   }

   tmp_ptr = &MQMServerId.pConnList[0];

   messlen = (msg->length);
   if ((messlen == 0) || (messlen > MAX_MSG_SIZE))
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Invalid reply message length %d\n",messlen);
     fprintf(stdout,"Reply message not sent\n");
     fflush(stdout);
#endif
     break;
   }

   memcpy(svrep_buffer,msg->str,messlen);
   memcpy(Svmd.MsgId, saveMsgId, MQ_MSG_ID_LENGTH);
   memcpy(Svmd.CorrelId, saveMsgId, MQ_CORREL_ID_LENGTH);
   memcpy(Svmd.Format, MQFMT_STRING, MQ_FORMAT_LENGTH);
   strncpy(SvodR.ObjectName, saveReplyToQ, MQ_Q_NAME_LENGTH);
   strncpy(SvodR.ObjectQMgrName,
               saveReplyToQMgr, MQ_Q_MGR_NAME_LENGTH);
   Svmd.MsgType        = MQMT_REPLY;
   Svmd.Report         = MQRO_NONE;
   Svmd.Persistence    = MQPER_PERSISTENCE_AS_Q_DEF;
   Svmd.Encoding       = MQENC_NATIVE;
   Svmd.CodedCharSetId = MQCCSI_Q_MGR;
   Svpmo.Options       = MQPMO_NO_SYNCPOINT;

#ifdef DEBUG
   fprintf(stdout,"Outgoing (reply) message id:\n");
   LV(MQ_MSG_ID_LENGTH, (char *)&Svmd.MsgId);
   fprintf(stdout,"Outgoing (reply) correlation id:\n");
   LV(MQ_CORREL_ID_LENGTH, (char *)&Svmd.CorrelId);
   fprintf(stdout,"Outgoing (reply) message :\n");
   LV(messlen,svrep_buffer); 
   fflush(stdout);
#endif

   CheckConn(saveReplyToQ,saveReplyToQMgr,&RepHobj);
   if (!RepHobj)
   {
      O_options = MQOO_OUTPUT
        + MQOO_FAIL_IF_QUIESCING;
      MQOPEN(tmp_ptr->QMgrHcon,
             &SvodR,
             O_options,
             &RepHobj,
             &CompCode,
             &Reason);
 
      if (CompCode != MQCC_OK)
      {
         *return_code = Reason;
#ifdef DEBUG
         fprintf(stdout,"Unable to open reply queue\n");
         fflush(stdout);
#endif
         MQM_LOG(CompCode,Reason);
         break;
      }

#ifdef DEBUG
     fprintf(stdout,"Reply queue object handle: %ld\n", RepHobj);
     fflush(stdout);
#endif

     SaveConn(saveReplyToQ,saveReplyToQMgr,RepHobj);
   }
 
   MQPUT(tmp_ptr->QMgrHcon,
         RepHobj,
         &Svmd,
         &Svpmo,
         messlen,
         svrep_buffer,
         &CompCode,
         &Reason);
 
   if (CompCode != MQCC_OK)
   {
     *return_code = Reason;
#ifdef DEBUG
     fprintf(stdout,"Unable to post message on reply queue\n");
     fflush(stdout);
#endif
     MQM_LOG(CompCode,Reason);
     break;
   }

   break;
 } while (0);

   if (sv_cancel_handlers() == -1)
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"Problem restoring previous signal handlers\n");
      fflush(stdout);
#endif
   }

#ifdef DEBUG
   fprintf(stdout,"End of SrvReply - successful completion\n");
   fflush(stdout);
#endif

   return;
}

*****/

/*
**      SrvReply
**
**      Put a message on the reply queue.
**
**      Inputs:
**              count           non-zero if calling from M.
**              msg             reply message
**              mqmd		message descriptor
**
**      Outputs:
**              return_code     SUCCESS or FAILURE
**
**      Returns:
**              None
*/
void SrvReply (int count, 
		STR_DESCRIPTOR *msg, 
		STR_DESCRIPTOR *mqmd, 
		SLONG *return_code)
{
   MQOD     SvodR = {MQOD_DEFAULT};  /* Object Descriptor (reply)    */
   MQPMO    Svpmo = {MQPMO_DEFAULT}; /* put message options          */
   MQMD     Svmd  = {MQMD_DEFAULT};  /* Message Descriptor           */
   MQHOBJ   RepHobj;                 /* Reply queue object handle    */
   MQLONG   O_options;               /* MQOPEN options               */
   MQLONG   CompCode;                /* completion code              */
   MQLONG   Reason;                  /* reason code                  */
   int      messlen;                 /* message length               */
   CONNINFO *tmp_ptr;
 
#ifdef DEBUG
   fprintf(stdout,"\nStart of SrvReply\n");
   fprintf(stdout,"SrvReply: Reply\nStr - %s\nLength - %d\n",msg->str,msg->length);
   fprintf(stdout,"SrvReply: mqmd->str - %s\nmqmd->length - %d\n",mqmd->str,mqmd->length);
   fflush(stdout);
#endif
 
   *return_code = SUCCESS;

 do
 {
   /******************************************************************/
   /*                                                                */
   /* Before we do anything, let's establish the signal handlers.    */
   /*                                                                */
   /******************************************************************/
   if (sv_setup_handlers() == -1)
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Problem establishing new signal handlers\n");
     fflush(stdout);
#endif
     break;
   }
 
   /******************************************************************/
   /*                                                                */
   /*     Check for access violation (memory)                        */
   /*                                                                */
   /******************************************************************/
   if (!MQMServerId.pConnList)
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Memory access violation\n");
     fflush(stdout);
#endif
     break;
   }
 
   tmp_ptr = &MQMServerId.pConnList[0];
 
   /******************************************************************/
   /*                                                                */
   /*     Check if message will fit in the queue                     */
   /*                                                                */
   /******************************************************************/
   messlen = (msg->length);
   if ((messlen == 0) || (messlen > MAX_MSG_SIZE))
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Invalid reply message length %d\n",messlen);
     fprintf(stdout,"Reply message not sent\n");
     fflush(stdout);
#endif
     break;
   }
 
   /******************************************************************/
   /*                                                                */
   /*     Prepare to send reply                                      */
   /*                                                                */
   /******************************************************************/
   memcpy(svrep_buffer,msg->str,messlen);
   svrep_buffer[messlen] = 0;

#ifdef DEBUG
     fprintf(stdout,"SrvReply: mqmd->str - %s\n",mqmd->str);
     fflush(stdout);
#endif
   if (mqmd->length > 0)
   {
	memcpy(svmqmd_buffer,mqmd->str,mqmd->length);
	svmqmd_buffer[mqmd->length] = 0;
	setMQMD(svmqmd_buffer,&Svmd);
#ifdef DEBUG
     fprintf(stdout,"SrvReply: Svmd.MsgId - %s\n",Svmd.MsgId);
     fflush(stdout);
#endif
	if (Svmd.MsgId[0] == 0)
	{ 
	    memcpy(Svmd.MsgId, saveMsgId, MQ_MSG_ID_LENGTH);
            memcpy(Svmd.CorrelId, saveMsgId, MQ_CORREL_ID_LENGTH);
            memcpy(Svmd.Format, MQFMT_STRING, MQ_FORMAT_LENGTH);
            Svmd.MsgType        = MQMT_REPLY;
	}
   }
   else {
   	memcpy(Svmd.MsgId, saveMsgId, MQ_MSG_ID_LENGTH);
   	/* Copy the message id to correlation id */
   	memcpy(Svmd.CorrelId, saveMsgId, MQ_CORREL_ID_LENGTH);
   	memcpy(Svmd.Format, MQFMT_STRING, MQ_FORMAT_LENGTH);
   	Svmd.MsgType        = MQMT_REPLY;
   	Svmd.Report         = MQRO_NONE;
   	Svmd.Persistence    = MQPER_PERSISTENCE_AS_Q_DEF;
   	Svmd.Encoding       = MQENC_NATIVE;
   	Svmd.CodedCharSetId = MQCCSI_Q_MGR;
   }
   strncpy(SvodR.ObjectName, saveReplyToQ, MQ_Q_NAME_LENGTH);
   /* Uncommented line to use the QMGR in the reply */
   strncpy(SvodR.ObjectQMgrName,
           saveReplyToQMgr, MQ_Q_MGR_NAME_LENGTH);
   Svpmo.Options       = MQPMO_NO_SYNCPOINT;
 
#ifdef DEBUG
   fprintf(stdout,"Outgoing (reply) message id:\n");
   LV(MQ_MSG_ID_LENGTH, (char *)&Svmd.MsgId);
   fprintf(stdout,"Outgoing (reply) correlation id:\n");
   LV(MQ_CORREL_ID_LENGTH, (char *)&Svmd.CorrelId);
   fprintf(stdout,"Outgoing (reply) message :\n");
   LV(messlen,svrep_buffer);
   fflush(stdout);
#endif /* DEBUG */
 
   /******************************************************************/
   /*                                                                */
   /*   Determine whether to open the reply queue or not             */
   /*                                                                */
   /******************************************************************/
   CheckConn(saveReplyToQ,saveReplyToQMgr,&RepHobj);
   if (!RepHobj)
   {
      /***************************************************************/
      /*                                                             */
      /*   Open the reply message queue for PUT operation            */
      /*                                                             */
      /***************************************************************/
      O_options = MQOO_OUTPUT         /* open queue for output       */
        + MQOO_FAIL_IF_QUIESCING;     /* but not if MQM stopping     */
      MQOPEN(tmp_ptr->QMgrHcon,       /* connection handle           */
             &SvodR,                  /* object descriptor for queue */
             O_options,               /* open options                */
             &RepHobj,                /* object handle               */
             &CompCode,               /* completion code             */
             &Reason);                /* reason code                 */
 
      /* report reason, if any; stop if failed */
      if (CompCode != MQCC_OK)
      {
         *return_code = Reason;
#ifdef DEBUG
         fprintf(stdout,"Unable to open reply queue\n");
         fflush(stdout);
#endif /* DEBUG */
         MQM_LOG(CompCode,Reason);
         break;
      }
 
#ifdef DEBUG
     fprintf(stdout,"Reply queue object handle: %ld\n", RepHobj);
     fflush(stdout);
#endif /* DEBUG */
 
     SaveConn(saveReplyToQ,saveReplyToQMgr,RepHobj);
   }
 
   /******************************************************************/
   /*                                                                */
   /*   Send reply message using MPUT. The queue should remain open  */
   /*   until server disconnects.                                    */
   /******************************************************************/
   MQPUT(tmp_ptr->QMgrHcon,       /* connection handle               */
         RepHobj,                 /* object handle                   */
         &Svmd,                   /* message descriptor              */
         &Svpmo,                  /* default options                 */
         messlen,                 /* buffer length                   */
         svrep_buffer,            /* server reply message buffer     */
         &CompCode,               /* completion code                 */
         &Reason);                /* reason code                     */
 
   /* report reason, if any */
   if (CompCode != MQCC_OK)
   {
     *return_code = Reason;
#ifdef DEBUG
     fprintf(stdout,"Unable to post message on reply queue\n");
     fflush(stdout);
#endif /* DEBUG */
     MQM_LOG(CompCode,Reason);
     break;
   }
 
   break;
 } while (0);
 
   /******************************************************************/
   /*                                                                */
   /* Always restore the previous signal handlers.                   */
   /*                                                                */
   /******************************************************************/
   if (sv_cancel_handlers() == -1)
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"Problem restoring previous signal handlers\n");
      fflush(stdout);
#endif /* DEBUG */
   }
 
#ifdef DEBUG
   fprintf(stdout,"End of SrvReply - successful completion\n");
   fflush(stdout);
#endif /* DEBUG */
 
   return;
} /* end of SrvReply */
 
 

/*
**	SrvDisconnect
**
**	Disconnect from MQSeries.
**
**	Inputs:
**		count		non-zero if calling from M.
**
**	Outputs:
**		None
**
**	Returns:
**		None
*/
void SrvDisconnect(int count)
{
   MQLONG   C_options;              /* MQCLOSE options               */
   MQLONG   CompCode;               /* completion code               */
   MQLONG   Reason;                 /* reason code                   */
   MQHCONN  QMgrHcon;               /* queue mgr connection handle   */
   MQHOBJ   RepHobj;                /* reply queue object handle     */
   SLONG    index;                  /* used to travel queue list     */
   CONNINFO *tmp_ptr;               /* pointer to queue list         */

#ifdef DEBUG
   fprintf(stdout,"\nStart of SrvDisconnect\n");
   fflush(stdout);
#endif

 do
 {
   /******************************************************************/
   /*                                                                */
   /* Before we do anything, let's establish the signal handlers.    */
   /*                                                                */
   /******************************************************************/
   if (sv_setup_handlers() == -1)
   {
#ifdef DEBUG
     fprintf(stdout,"Problem establishing new signal handlers\n");
     fflush(stdout);
#endif
     break;
   }

   /******************************************************************/
   /*                                                                */
   /*     Check for access violation (memory)                        */
   /*                                                                */
   /******************************************************************/
   if (!MQMServerId.pConnList)
   {
#ifdef DEBUG
     fprintf(stdout,"Memory access violation\n");
     fflush(stdout);
#endif
     break;
   }

   tmp_ptr = &MQMServerId.pConnList[0];

   C_options = 0;                     /* no close options            */

   /******************************************************************/
   /*                                                                */
   /*   Close the request queue                                      */
   /*                                                                */
   /******************************************************************/
   QMgrHcon = tmp_ptr->QMgrHcon;
   MQCLOSE(QMgrHcon,                  /* connection handle           */
           &tmp_ptr->ReqQHobj,        /* request queue object handle */
           C_options,
           &CompCode,                 /* completion code             */
           &Reason);                  /* reason code                 */
 
#ifdef DEBUG
   /* report reason, if any     */
   if (Reason != MQRC_NONE)
   {
     fprintf(stdout,"MQCLOSE ended with reason code %ld\n", Reason);
     fflush(stdout);
   }
#endif

   /******************************************************************/
   /*                                                                */
   /*    Close ALL reply queues.                                     */
   /*                                                                */
   /******************************************************************/
   for (index = 1; index < MQMServerId.total_used; index++)
   {
      RepHobj = tmp_ptr[index].RepQHobj;
      MQCLOSE(QMgrHcon,               /* connection handle           */
              &RepHobj,               /* reply queue object handle   */
              C_options,
              &CompCode,              /* completion code             */
              &Reason);               /* reason code                 */
 
#ifdef DEBUG
      /* report reason, if any     */
      if (Reason != MQRC_NONE)
      {
        fprintf(stdout,"MQCLOSE ended with reason code %ld\n", Reason);
        fflush(stdout);
      }
#endif
   }

   /******************************************************************/
   /*                                                                */
   /*   Disconnect from MQM                                          */
   /*                                                                */
   /******************************************************************/
   MQDISC(&QMgrHcon,                 /* server connection handle     */
          &CompCode,                 /* completion code              */
          &Reason);                  /* reason code                  */
 
#ifdef DEBUG
   /* report reason, if any     */
   if (Reason != MQRC_NONE)
   {
      fprintf(stdout,"MQDISC ended with reason code %ld\n", Reason);
      fflush(stdout);
   }
#endif
 
   /* Now free the message buffer and open queue structure */
   if (svreq_buffer)
      free(svreq_buffer);
   if (svrep_buffer)
      free(svrep_buffer);
   if (svmqmd_buffer)
      free(svmqmd_buffer);
   if (MQMServerId.pConnList)
      free(MQMServerId.pConnList);
   if (MQMClientId.pConnList)
      free(MQMClientId.pConnList); /* if this server also acts as client */
   break;
 } while (0);

   /******************************************************************/
   /*                                                                */
   /* Always restore the previous signal handlers.                   */
   /*                                                                */
   /******************************************************************/
   if (sv_cancel_handlers() == -1)
   {
#ifdef DEBUG
      fprintf(stdout,"Problem restoring previous signal handlers\n");
      fflush(stdout);
#endif /* DEBUG */
   }

#ifdef DEBUG
   fprintf(stdout,"End of SrvDisconnect - successful completion\n");
   fflush(stdout);
#endif

   return;
} /* end of SrvDisconnect */




/*
**	sv_signal_catcher
**
**	Do nothing - simply ignore caught signal.
**
**	Inputs:
**		sig		signal number
**
**	Outputs:
**		None
**
**	Returns:
**		None
*/
void sv_signal_catcher(int sig)
{

#ifdef DEBUG
	fprintf(stdout,"sv_signal_catcher: server PID %d caught signal %x\n",getpid(),sig);
	fflush(stdout);
#endif

	return;
} /* end of sv_signal_catcher */




/*
**	sv_setup_handlers
**
**	Push previous signal handlers on stack.
**
**	Inputs:
**		None
**
**	Outputs:
**		None
**
**	Returns:
**		status		0 means SUCCESS, -1 means FAILURE
*/
int sv_setup_handlers()
{
	int	status = -1;

#ifdef DEBUG
	fprintf(stdout,"sv_setup_handlers: start\n");
	fflush(stdout);
#endif

	do
	{
		if ((sHSIGALRM = mqm_signal(SIGALRM, SIG_IGN)) == SIG_ERR)
			break;

		if ((sHSIGBUS = mqm_signal(SIGBUS, sv_signal_catcher)) == SIG_ERR)
			break;

		if ((sHSIGFPE = mqm_signal(SIGFPE, sv_signal_catcher)) == SIG_ERR)
			break;

		if ((sHSIGSEGV = mqm_signal(SIGSEGV, sv_signal_catcher)) == SIG_ERR)
			break;

		status = 0;

	} while(0);

#ifdef DEBUG
	fprintf(stdout,"sv_setup_handlers: end - returning status is %d\n",status);
	fprintf(stdout,"\tprevious SIGALRM handler %x\n",sHSIGALRM);
	fprintf(stdout,"\tprevious SIGBUS handler %x\n",sHSIGBUS);
	fprintf(stdout,"\tprevious SIGFPE handler %x\n",sHSIGFPE);
	fprintf(stdout,"\tprevious SIGSEGV handler %x\n",sHSIGSEGV);
	fflush(stdout);
#endif

	return (status);
} /* end of sv_setup_handlers */




/*
**	sv_cancel_handlers
**
**	Pop previous signal handlers on stack.
**
**	Inputs:
**		None
**
**	Outputs:
**		None
**
**	Returns:
**		status		0 means SUCCESS, -1 means FAILURE
*/
int sv_cancel_handlers()
{
	int	status = -1;

#ifdef DEBUG
	fprintf(stdout,"sv_cancel_handlers: start\n");
	fflush(stdout);
#endif

	do
	{
		if (mqm_signal(SIGALRM, sHSIGALRM) == SIG_ERR)
			break;

		if (mqm_signal(SIGBUS, sHSIGBUS) == SIG_ERR)
			break;

		if (mqm_signal(SIGFPE, sHSIGFPE) == SIG_ERR)
			break;

		if (mqm_signal(SIGSEGV, sHSIGSEGV) == SIG_ERR)
			break;

		status = 0;

	} while(0);

#ifdef DEBUG
	fprintf(stdout,"sv_cancel_handlers: end - returning status is %d\n",status);
	fflush(stdout);
#endif

	return (status);
} /* end of sv_cancel_handlers */
