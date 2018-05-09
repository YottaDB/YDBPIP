/*****************************************************************************
*
*	mqclient.c
*
*	Copyright(c)2000 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	Description: Sanchez MQSeries Client API for UNIX
*
*	ORIG: Hien T. Ly - March 1999
*
* $Id: mqclient.c,v 1.2 2000/11/10 13:38:19 lyh Exp lyh $
*
* $Log: mqclient.c,v $
 * Revision 1.4  2005/03/24  thoniyim
 * Modified functions ClExchmsg and ClSend to send/retrieve MQMD info
 * from/to the user.
 *
 * Revision 1.3  2004/03/08  thoniyim
 * GetClQIni function is changed to return UserID read from INI file
 *
 * Revision 1.2  2000/11/10  13:38:19  lyh
 * Dropped saved message id and saved correl id since we are not using them
 * Replaced sizeof() with constant MQ_MSG_ID_LENGTH and MQ_CORREL_ID_LENGTH
 * Declared external function prototypes
 *
 * Revision 1.1  2000/11/08  19:55:46  lyh
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

/*------------ Global Variables ------------*/
CONNLIST MQMClientId = {0,0,NULL};		/* client connection data */
char     *req_msg = NULL;			/* request message buffer */
char     *rep_msg = NULL;			/* reply message buffer   */
char     *mqmd_buf = NULL;			/* MQMD buffer   	  */
/*char	 g_userid[MQ_USER_ID_LENGTH];	*/	/* UserID from the INI	  */
Sigfunc  *cHSIGALRM;				/* prev SIGALRM handler   */
Sigfunc  *cHSIGBUS;				/* prev SIGBUS handler    */
Sigfunc  *cHSIGFPE;				/* prev SIGFPE handler    */
Sigfunc  *cHSIGSEGV;				/* prev SIGSEGV handler   */

/*------------ External Variables ------------*/
extern CONNLIST MQMServerId;			/* server connection data */

/*------------ External Functions ------------*/
extern Sigfunc *mqm_signal(int, Sigfunc *);	/* a wrapper function     */
extern void GetClQIni(char *, char *, char *, char *, char *);
extern void CheckClConn(CONNINFO *);
extern void SaveClConn(CONNINFO *, SLONG *);
extern SLONG ClActiveConn();
extern void LV(int, char *);
extern void getMQMD(MQMD *, char *);
extern void setMQMD(char *, MQMD *);

/*------------ Local Functions ------------*/
void cl_signal_catcher(int);			/* signal catcher         */
int cl_setup_handlers();			/* push previous handlers */
int cl_cancel_handlers();			/* pop previous handlers  */


/*
**	ClConnect
**
**	Connect to MQSeries and return a slot id to the calling M process.
**
**	Inputs:
**		count		non-zero if calling from M.
**		env_name	environment variable that points to an INI file
**
**	Outputs:
**		slot_id		slot id, to be used in later calls.
**		return_code	SUCCESS or FAILURE
**
**	Returns:
**		None
*/
void ClConnect(int count, 
               char *env_name, 
               SLONG *slot_id, 
               SLONG *return_code)
{

   MQOD   Clod = {MQOD_DEFAULT};    /* Object Descriptor             */
   MQOD  Clodr = {MQOD_DEFAULT};    /* Object Descriptor for reply   */
   MQHCONN  Hcon;                   /* connection handle             */
   MQHOBJ   Hrequest;               /* object handle for request     */
   MQHOBJ   Hreply;                 /* object handle for reply       */
   MQLONG   O_options;              /* MQOPEN options                */
   MQLONG   CompCode;               /* completion code               */
   MQLONG   OpenCode;               /* MQOPEN completion code        */
   MQLONG   Reason;                 /* reason code                   */
   MQLONG   CReason;                /* reason code for MQCONN        */
   SLONG    mem_size;               /* memory block size             */
   char     ClQMName[MQ_Q_MGR_NAME_LENGTH]; /* queue manager name    */
   char     ClReqQName[MQ_Q_NAME_LENGTH];   /* request queue name    */
   char     ClRepQName[MQ_Q_NAME_LENGTH];   /* reply queue name      */
   char     ClUserId[MQ_USER_ID_LENGTH];    /* Alternate User ID     */
   CONNINFO *tmp_pClList = NULL;
   CONNINFO tmp_ClConn;

#ifdef DEBUG
   fprintf(stdout,"\nStart of ClConnect\n");
   fflush(stdout);
#endif /* DEBUG */

   *return_code = SUCCESS;

 do
 {
   /******************************************************************/
   /*                                                                */
   /* Before we do anything, let's establish the signal handlers.    */
   /*                                                                */
   /******************************************************************/
   if (cl_setup_handlers() == -1)
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"Problem establishing new signal handlers\n");
      fflush(stdout);
#endif /* DEBUG */
      break; 
   }

   /******************************************************************/
   /*                                                                */
   /* first check the .ini file for queue manager and queue names    */
   /*                                                                */
   /******************************************************************/
   memset(ClQMName,'\0',sizeof(ClQMName));
   memset(ClReqQName,'\0',sizeof(ClReqQName));
   memset(ClRepQName,'\0',sizeof(ClRepQName));
   memset(ClUserId,'\0',MQ_USER_ID_LENGTH);
/*   memset(g_userid,'\0',MQ_USER_ID_LENGTH); */
   GetClQIni(env_name,ClQMName,ClReqQName,ClRepQName,ClUserId);
   if ((ClQMName[0]=='\0')||(ClReqQName[0]=='\0')||(ClRepQName[0]=='\0'))
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"Problem locating queue manager and/or queue names\n");
      fflush(stdout);
#endif /* DEBUG */
      break; 
   }
/*   strcpy(g_userid,ClUserId); */

   /******************************************************************/
   /*                                                                */
   /*   Prepare buffer for reply message                             */
   /*                                                                */
   /******************************************************************/
   if (!rep_msg)
   {
      rep_msg = (char *)malloc(MAX_MSG_SIZE);
      if (!rep_msg)
      {
         *return_code = FAILURE;
#ifdef DEBUG
         fprintf(stdout,"Out of memory for reply message buffer\n");
         fflush(stdout);
#endif /* DEBUG */
         break;
      }
   }

   /******************************************************************/
   /*                                                                */
   /*   Prepare buffer for request message                           */
   /*                                                                */
   /******************************************************************/
   if (!req_msg)
   {
      req_msg = (char *)malloc(MAX_MSG_SIZE);
      if (!req_msg)
      {
         *return_code = FAILURE;
#ifdef DEBUG
         fprintf(stdout,"Out of memory for request message buffer\n");
         fflush(stdout);
#endif /* DEBUG */
         break;
      }
   }

   /******************************************************************/
   /*                                                                */
   /*   Prepare buffer for MQMD                           	     */
   /*                                                                */
   /******************************************************************/
   if (!mqmd_buf)
   {
      mqmd_buf = (char *)malloc(MAX_MQMD_SIZE);
      if (!mqmd_buf)
      {
         *return_code = FAILURE;
#ifdef DEBUG
         fprintf(stdout,"Out of memory for MQMD buffer\n");
         fflush(stdout);
#endif /* DEBUG */
         break;
      }
   }

   /******************************************************************/
   /*                                                                */
   /*   Allocate initial memory for client data structure            */
   /*                                                                */
   /******************************************************************/
   if (MQMClientId.pConnList == NULL)
   {
      /* Allocate at least n slot for client connection, where n is  */
      /* QUEUE_LIST_INCREMENT. This number can be increased later in */
      /* routine SaveClConn                                          */
      mem_size    = sizeof(CONNINFO) * QUEUE_LIST_INCREMENT;
      tmp_pClList = (CONNINFO *)malloc(mem_size);
      if (!tmp_pClList)
      {
         *return_code = FAILURE;
#ifdef DEBUG
         fprintf(stdout,"Out of memory for client connection data\n");
         fflush(stdout);
#endif /* DEBUG */
         break;
      }
      memset(tmp_pClList,0,mem_size);
      MQMClientId.total_count = QUEUE_LIST_INCREMENT;
      MQMClientId.total_used  = 0;
      MQMClientId.pConnList   = tmp_pClList;
   }

   /******************************************************************/
   /*                                                                */
   /*   Check if we have this type of connection before              */
   /*                                                                */
   /******************************************************************/
   strncpy(tmp_ClConn.QMgrName, ClQMName, MQ_Q_MGR_NAME_LENGTH);
   strncpy(tmp_ClConn.ReqQName, ClReqQName, MQ_Q_NAME_LENGTH);
   strncpy(tmp_ClConn.RepQName, ClRepQName, MQ_Q_NAME_LENGTH);
   CheckClConn(&tmp_ClConn);

   if (!tmp_ClConn.QMgrHcon)
   {
#ifdef DEBUG
      fprintf(stdout,"Connecting to queue manager: '%s'\n",ClQMName);
      fflush(stdout);
#endif /* DEBUG */

      /***************************************************************/
      /*                                                             */
      /*   Connect to queue manager                                  */
      /*                                                             */
      /***************************************************************/

      MQCONN(ClQMName,                /* queue manager               */
             &Hcon,                   /* connection handle           */
             &CompCode,               /* completion code             */
             &CReason);               /* reason code                 */

      /* report reason and stop if it failed     */
      if (CompCode != MQCC_OK)
      {
         if (CReason != MQRC_ALREADY_CONNECTED)
         {
            *return_code = CReason;
#ifdef DEBUG
            fprintf(stdout,"MQCONN ended with reason code %ld\n", CReason);
            fflush(stdout);
#endif /* DEBUG */
            MQM_LOG(CompCode,CReason);
            break;
         }
      }

     tmp_ClConn.QMgrHcon = Hcon;
#ifdef DEBUG
     fprintf(stdout,"Queue manager connection handle: %ld\n", Hcon);
     fflush(stdout);
#endif /* DEBUG */
   }

   if (!tmp_ClConn.ReqQHobj)
   {
#ifdef DEBUG
      fprintf(stdout,"Opening request queue: %s\n",ClReqQName);
      fflush(stdout);
#endif /* DEBUG */

      /***************************************************************/
      /*                                                             */
      /*   Open the request message queue for PUT operation          */
      /*                                                             */
      /***************************************************************/
      strncpy(Clod.ObjectName, ClReqQName, MQ_Q_NAME_LENGTH);
      if (ClUserId[0]!='\0') {
     	     strcpy(Clod.AlternateUserId, ClUserId);
      	     O_options = MQOO_OUTPUT         /* open queue for output       */
	          + MQOO_ALTERNATE_USER_AUTHORITY 
                  + MQOO_FAIL_IF_QUIESCING;  /* but not if MQM stopping     */
      }
      else {
	     O_options = MQOO_OUTPUT         /* open queue for output       */
                  + MQOO_FAIL_IF_QUIESCING;  /* but not if MQM stopping     */
      }
      MQOPEN(tmp_ClConn.QMgrHcon,     /* connection handle           */
             &Clod,                   /* object descriptor for queue */
             O_options,               /* open options                */
             &Hrequest,               /* object handle               */
             &OpenCode,               /* completion code             */
             &Reason);                /* reason code                 */

      /* report reason, if any; stop if failed */
      if (OpenCode != MQCC_OK)
      {
         *return_code = Reason;
#ifdef DEBUG
         fprintf(stdout,"Unable to open request queue\n");
         fflush(stdout);
#endif /* DEBUG */
         MQM_LOG(OpenCode,Reason);
         break;
      }

     tmp_ClConn.ReqQHobj = Hrequest;
#ifdef DEBUG
     fprintf(stdout,"Request queue object handle: %ld\n", Hrequest);
     fflush(stdout);
#endif /* DEBUG */
   }

   if (!tmp_ClConn.RepQHobj)
   {
#ifdef DEBUG
      fprintf(stdout,"Opening reply queue: %s\n",ClRepQName);
      fflush(stdout);
#endif /* DEBUG */

      /***************************************************************/
      /*                                                             */
      /*   Open the reply message queue for GET operation            */
      /*                                                             */
      /***************************************************************/
      strncpy(Clodr.ObjectName, ClRepQName, MQ_Q_NAME_LENGTH);
      O_options = MQOO_INPUT_SHARED    /* open queue for input       */
             + MQOO_FAIL_IF_QUIESCING; /* but not if MQM stopping    */
      MQOPEN(tmp_ClConn.QMgrHcon,      /* connection handle          */
             &Clodr,                   /* object descriptor for queue*/
             O_options,                /* open options               */
             &Hreply,                  /* reply object handle        */
             &OpenCode,                /* completion code            */
             &Reason);                 /* reason code                */

      /* report reason, if any; stop if failed      */
      if (OpenCode != MQCC_OK)
      {
         *return_code = Reason;
#ifdef DEBUG
         fprintf(stdout,"Unable to open reply queue\n");
         fflush(stdout);
#endif /* DEBUG */
         MQM_LOG(OpenCode,Reason);
         break;
      }

     tmp_ClConn.RepQHobj = Hreply;
#ifdef DEBUG
     fprintf(stdout,"Reply queue object handle: %ld\n", Hreply);
     fflush(stdout);
#endif /* DEBUG */
   }

   SaveClConn(&tmp_ClConn,slot_id);

   if (*slot_id < 0)
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Invalid slot id: %ld\n", *slot_id);
     fflush(stdout);
#endif /* DEBUG */
     break;
   }

   break;

  } while (0);

   /******************************************************************/
   /*                                                                */
   /* Always restore the previous signal handlers.                   */
   /*                                                                */
   /******************************************************************/
   if (cl_cancel_handlers() == -1)
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"Problem restoring previous signal handlers\n");
      fflush(stdout);
#endif /* DEBUG */
   }

#ifdef DEBUG
   if (*return_code == SUCCESS)
      fprintf(stdout,"End of ClConnect - slot id is %d\n",*slot_id);
   else
      fprintf(stdout,"End of ClConnect - unsuccessful completion\n");
   fflush(stdout);
#endif /* DEBUG */

   return;

} /* end of ClConnect */




/*
**	ClDisconnect
**
**	Disconnect from MQSeries.
**
**	Inputs:
**		count		non-zero if calling from M.
**		slot_id		slot id.
**
**	Outputs:
**		return_code	SUCCESS or FAILURE
**
**	Returns:
**		None
*/
void ClDisconnect(int count, SLONG slot_id, SLONG *return_code)
{

   MQLONG   C_options;              /* MQCLOSE options               */
   MQLONG   CompCode;               /* completion code               */
   MQLONG   OpenCode;               /* MQOPEN completion code        */
   MQLONG   Reason;                 /* reason code                   */
   CONNINFO *pClConn,*tmp_pClConn;
   SLONG index,active_conn,match_qmgr,match_reqq,match_repq,close_qmgr;

#ifdef DEBUG
   fprintf(stdout,"\nStart of ClDisconnect\n");
   fflush(stdout);
#endif /* DEBUG */

   *return_code = SUCCESS;

 do
 {
   /******************************************************************/
   /*                                                                */
   /* Before we do anything, let's establish the signal handlers.    */
   /*                                                                */
   /******************************************************************/
   if (cl_setup_handlers() == -1)
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"Problem establishing new signal handlers\n");
      fflush(stdout);
#endif /* DEBUG */
      break; 
   }

   /*****************************************************************/
   /*                                                               */
   /* check if slot id is valid                                     */
   /*                                                               */
   /*****************************************************************/
   if ((slot_id < 0) || (slot_id >= MQMClientId.total_used))
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"Invalid slot id: %d\n",slot_id);
      fflush(stdout);
#endif /* DEBUG */
      break;
   }

   /*****************************************************************/
   /*                                                               */
   /*    Check for access violation (memory)                        */
   /*                                                               */
   /*****************************************************************/
   if (!MQMClientId.pConnList)
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"Memory access violation\n");
      fflush(stdout);
#endif /* DEBUG */
      break;
   }

   /*****************************************************************/
   /*                                                               */
   /* How many active connection are out there?                     */
   /*                                                               */
   /*****************************************************************/
   active_conn = ClActiveConn();
   if (active_conn == 0)
   {
      /* there is nothing to do here */
      break;
   }

   pClConn = &MQMClientId.pConnList[slot_id];
   match_qmgr = 0;
   match_reqq = 0;
   match_repq = 0;
   for (index = 0; index < MQMClientId.total_used; index++)
   {
       if (index != slot_id)
       {
          tmp_pClConn = &MQMClientId.pConnList[index];
          if (pClConn->QMgrHcon == tmp_pClConn->QMgrHcon)
          {
             match_qmgr++;
             if (pClConn->ReqQHobj == tmp_pClConn->ReqQHobj)
                match_reqq++;
             if (pClConn->RepQHobj == tmp_pClConn->RepQHobj) 
                match_repq++;
          }
       }
   }

   if (match_reqq == 0)
   {
      /***************************************************************/
      /*                                                             */
      /*   Close request queue                                       */
      /*                                                             */
      /***************************************************************/
      C_options = 0;                  /* no close options            */
      MQCLOSE(pClConn->QMgrHcon,      /* connection handle           */
              &pClConn->ReqQHobj,     /* object handle               */
              C_options,
              &CompCode,              /* completion code             */
              &Reason);               /* reason code                 */

      /* report reason, if any     */
      if (CompCode != MQCC_OK)
      {
         *return_code = Reason;
#ifdef DEBUG
         fprintf(stdout,"Unable to close request queue\n");
         fflush(stdout);
#endif /* DEBUG */
         MQM_LOG(CompCode,Reason);
         /* Note: even if we failed here, we should continue on and  */
         /* try to close the other queue (reply).                    */
      }
      else
      {
#ifdef DEBUG
         fprintf(stdout,"Request queue %s closed\n",pClConn->ReqQName);
         fflush(stdout);
#endif /* DEBUG */
      }
   }

   if (match_repq == 0)
   {
      /***************************************************************/
      /*                                                             */
      /*   Close reply queue                                         */
      /*                                                             */
      /***************************************************************/
      C_options = 0;                    /* no close option           */
      MQCLOSE(pClConn->QMgrHcon,        /* connection handle         */
              &pClConn->RepQHobj,       /* object handle             */
              C_options,
              &CompCode,                /* completion code           */
              &Reason);                 /* reason code               */

      /* report reason, if any     */
      if (CompCode != MQCC_OK)
      {
         *return_code = Reason;
#ifdef DEBUG
         fprintf(stdout,"Unable to close reply queue\n");
         fflush(stdout);
#endif /* DEBUG */
         MQM_LOG(CompCode,Reason);
         /* Note: even if we failed here, we should continue on and  */
         /* try to close the queue manager.                          */
      }
      else
      {
#ifdef DEBUG
         fprintf(stdout,"Reply queue %s closed\n",pClConn->RepQName);
         fflush(stdout);
#endif /* DEBUG */
      }
   }

   if (match_qmgr == 0)
   {
      if (MQMServerId.pConnList)
      {
         if (MQMServerId.pConnList->QMgrHcon != pClConn->QMgrHcon)
         {
#ifdef DEBUG
            fprintf(stdout,"No other server - close connection\n");
            fflush(stdout);
#endif
            close_qmgr = TRUE;
         }
         else
         {
#ifdef DEBUG
            fprintf(stdout,"Server is connected - leave connection open\n");
            fflush(stdout);
#endif
            close_qmgr = FALSE;
         }
      }
      else
      {
#ifdef DEBUG
          fprintf(stdout,"No other client - close connection\n");
          fflush(stdout);
#endif
          close_qmgr = TRUE;
      }
   }
   else
   {
#ifdef DEBUG
      fprintf(stdout,"Other client(s) - leave connection open\n");
      fflush(stdout);
#endif      
      close_qmgr = FALSE;
   }

   if (close_qmgr)
   {
      /***************************************************************/
      /*                                                             */
      /*   Disconnect from MQM  (unless previously connected)        */
      /*                                                             */
      /***************************************************************/

      MQDISC(&pClConn->QMgrHcon,      /* connection handle           */
             &CompCode,               /* completion code             */
             &Reason);                /* reason code                 */

      /* report reason, if any     */
      if (CompCode != MQCC_OK)
      {
         *return_code = Reason;
#ifdef DEBUG
        fprintf(stdout,"MQDISC ended with reason code %ld\n", Reason);
        fflush(stdout);
#endif /* DEBUG */
        MQM_LOG(CompCode,Reason); 
      }
      else
      {
#ifdef DEBUG
         fprintf(stdout,"Disconnected from queue mgr %s\n",pClConn->QMgrName);
         fflush(stdout);
#endif /* DEBUG */
      }
   }

   /* Reset memory block to indicate an open and reusable slot. */
   memset(pClConn,0,sizeof(CONNINFO)); 

   if ((active_conn == 1) && (MQMClientId.pConnList))
   {
#ifdef DEBUG
      fprintf(stdout,"Free client memory structure\n");
      fflush(stdout);
#endif /* DEBUG */
      /* This is the last connection that the client is disconnecting from */
      /* so remember to free the reply and request message buffers */
      free(MQMClientId.pConnList);
      MQMClientId.pConnList = (CONNINFO *)NULL;
   }

   /* throw away the request and reply buffers, we don't need them anymore */
   if (rep_msg)
   {
      free(rep_msg);
      rep_msg = (char *)NULL;
   }
   if (req_msg)
   {
      free(req_msg);
      req_msg = (char *)NULL;
   }
   if (mqmd_buf)
   {
      free(mqmd_buf);
      mqmd_buf = (char *)NULL;
   }

   break;

  } while (0);

   /******************************************************************/
   /*                                                                */
   /* Always restore the previous signal handlers.                   */
   /*                                                                */
   /******************************************************************/
   if (cl_cancel_handlers() == -1)
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"Problem restoring previous signal handlers\n");
      fflush(stdout);
#endif /* DEBUG */
   }

#ifdef DEBUG
   if (*return_code == SUCCESS)
      fprintf(stdout,"End of ClDisconnect - successful completion\n");
   else
      fprintf(stdout,"End of ClDisconnect - unsuccessful completion\n");
   fflush(stdout);
#endif /* DEBUG */

   return;

} /* end of ClDisconnect */




/*
**	ClExchmsg
**
**	Exchange message with server.
**
**	Inputs:
**		count		non-zero if calling from M.
**		request		request message
**		timeout		timeout in seconds
**		slot_id		slot id.
**
**	Outputs:
**		reply		reply message
**		return_code	SUCCESS or FAILURE
**
**	Returns:
**		None
*/

/*****

void ClExchmsg(int count,
          STR_DESCRIPTOR *request,
          STR_DESCRIPTOR *reply,
          SLONG timeout,
          SLONG slot_id,
          SLONG *return_code)
{
   MQMD   Clmd = {MQMD_DEFAULT};
   MQGMO Clgmo = {MQGMO_DEFAULT};
   MQPMO Clpmo = {MQPMO_DEFAULT};
   MQLONG   CompCode;
   MQLONG   Reason;
   MQLONG   buflen;
   MQLONG   replylen;
   CONNINFO *pClConn;
   SLONG      index;

#ifdef DEBUG
   fprintf(stdout,"\nStart of ClExchmsg\n");
   fflush(stdout);
#endif

   *return_code = SUCCESS;

 do
 {
   if (cl_setup_handlers() == -1)
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"Problem establishing new signal handlers\n");
      fflush(stdout);
#endif
      break; 
   }

   if ((slot_id < 0) || (slot_id >= MQMClientId.total_used))
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Invalid slot id: %d\n",slot_id);
     fflush(stdout);
#endif
     break;
   }

   if ((request->length == 0) || (request->length > MAX_MSG_SIZE))
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Request message length is invalid\n");
     fprintf(stdout,"Request message is not sent\n");
     fflush(stdout);
#endif
     break;
   }

   if ((!MQMClientId.pConnList) || (!req_msg) || (!rep_msg))
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"ClExchmsg error: Memory access violation\n");
      fprintf(stdout,"Please check if slot id %d is still open\n",slot_id);
      fflush(stdout);
#endif
      break;
   }

   pClConn = &MQMClientId.pConnList[slot_id];

   memcpy(req_msg, request->str, request->length);
   req_msg[request->length] = 0;
   memcpy(Clmd.MsgId, MQMI_NONE, MQ_MSG_ID_LENGTH);
   memcpy(Clmd.CorrelId, MQCI_NONE, MQ_CORREL_ID_LENGTH);
   memcpy(Clmd.Format, MQFMT_STRING, MQ_FORMAT_LENGTH);
   strncpy(Clmd.ReplyToQ, pClConn->RepQName, MQ_Q_NAME_LENGTH);
   strncpy(Clmd.ReplyToQMgr, pClConn->QMgrName, MQ_Q_MGR_NAME_LENGTH);
   Clmd.MsgType        = MQMT_REQUEST;
   Clmd.Report         = MQRO_PASS_MSG_ID + MQRO_PASS_CORREL_ID;
   Clmd.Persistence    = MQPER_PERSISTENCE_AS_Q_DEF;
   Clmd.Encoding       = MQENC_NATIVE;
   Clmd.CodedCharSetId = MQCCSI_Q_MGR;
   Clpmo.Options       = MQPMO_NO_SYNCPOINT;

   MQPUT(pClConn->QMgrHcon,
         pClConn->ReqQHobj,
         &Clmd,
         &Clpmo,
         request->length,
         req_msg,
         &CompCode,
         &Reason);

   if (CompCode != MQCC_OK)
   {
     *return_code = Reason;
#ifdef DEBUG
     fprintf(stdout,"Unable to post message on request queue - %l\n",Reason);
     fflush(stdout);
#endif
     MQM_LOG(CompCode,Reason);
     break;
   }

#ifdef DEBUG
   fprintf(stdout,"Outgoing (request) message id:\n");
   fflush(stdout);
   LV(MQ_MSG_ID_LENGTH, (char *)&Clmd.MsgId);
   fprintf(stdout,"Outgoing (request) correlation id:\n");
   fflush(stdout);
   LV(MQ_CORREL_ID_LENGTH, (char *)&Clmd.CorrelId);
   fflush(stdout);
   fprintf(stdout,"Outgoing (request) message:\n");
   fflush(stdout);
   LV(request->length, req_msg);
#endif

   Clgmo.WaitInterval = timeout * 1000;
   Clgmo.Options = MQGMO_WAIT
       + MQGMO_CONVERT
       + MQGMO_ACCEPT_TRUNCATED_MSG;
   Clgmo.MatchOptions =MQMO_MATCH_MSG_ID
       + MQMO_MATCH_CORREL_ID;

#ifdef DEBUG
   fprintf(stdout,"waiting for reply...\n");
	fprintf(stdout,"\tprevious SIGALRM handler %x\n",cHSIGALRM);
	fprintf(stdout,"\tprevious SIGBUS handler %x\n",cHSIGBUS);
	fprintf(stdout,"\tprevious SIGFPE handler %x\n",cHSIGFPE);
	fprintf(stdout,"\tprevious SIGSEGV handler %x\n",cHSIGSEGV);
   fflush(stdout);
#endif

   buflen = MAX_MSG_SIZE;

   MQGET(pClConn->QMgrHcon,
         pClConn->RepQHobj,
         &Clmd,
         &Clgmo,
         buflen,
         rep_msg,
         &replylen,
         &CompCode,
         &Reason);

   if (CompCode != MQCC_OK)
   {
     *return_code = Reason;
#ifdef DEBUG
     switch(Reason)
     {
       case MQRC_NO_MSG_AVAILABLE:
            fprintf(stdout,"GET reply is timed out\n");
            fflush(stdout);
            break;
       default:
            fprintf(stdout,"Unable to get message on reply queue\n");
            fflush(stdout);
            MQM_LOG(CompCode,Reason);
            break;
     }
#endif
     break;
   }

   reply->str = rep_msg;
   reply->length = replylen;
#ifdef DEBUG
   fprintf(stdout,"Incoming (reply) message id:\n");
   fflush(stdout);
   LV(MQ_MSG_ID_LENGTH, (char *)&Clmd.MsgId);
   fprintf(stdout,"Incoming (reply) correlation id:\n");
   fflush(stdout);
   LV(MQ_CORREL_ID_LENGTH, (char *)&Clmd.CorrelId);
   fprintf(stdout,"Incoming (reply) message:\n");
   fflush(stdout);
   LV(reply->length, reply->str);
#endif

   break;

  } while (0);

   if (cl_cancel_handlers() == -1)
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"Problem restoring previous signal handlers\n");
      fflush(stdout);
#endif
   }

#ifdef DEBUG
   if (*return_code == SUCCESS)
      fprintf(stdout,"End of ClExchmsg - successful completion\n");
   else
      fprintf(stdout,"End of ClExchmsg - unsuccessful completion\n");
   fflush(stdout);
#endif

   return;

}

*****/

/*
**      ClExchmsg
**
**      Exchange message/MQMD with server.
**
**      Inputs:
**              count           non-zero if calling from M.
**              request         request message
**		in_mqmd		message descriptor - input
**              timeout         timeout in seconds
**              slot_id         slot id.
**
**      Outputs:
**              reply           reply message
**		out_mqmd	message descriptor - output
**              return_code     SUCCESS or FAILURE
**
**      Returns:
**              None
*/
void ClExchmsg(int count,
          STR_DESCRIPTOR *request,
          STR_DESCRIPTOR *reply,
          STR_DESCRIPTOR *in_mqmd,
          char *out_mqmd,
          SLONG timeout,
          SLONG slot_id,
          SLONG *return_code)
{
   MQMD   Clmd = {MQMD_DEFAULT};    /* Message Descriptor            */
   MQGMO Clgmo = {MQGMO_DEFAULT};   /* get message options           */
   MQPMO Clpmo = {MQPMO_DEFAULT};   /* put message options           */
   MQLONG   CompCode;               /* completion code               */
   MQLONG   Reason;                 /* reason code                   */
   MQLONG   buflen;                 /* buffer length                 */
   MQLONG   replylen;               /* reply length                  */
   CONNINFO *pClConn;
   SLONG    index;
 
#ifdef DEBUG
   fprintf(stdout,"\nStart of ClExchmsg\n");
   fprintf(stdout,"ClExchmsg: Request\nStr - %s\nLength - %d\n",request->str,request->length);
   fflush(stdout);
#endif /* DEBUG */
 
   *return_code = SUCCESS;
 
 do
 {
   /******************************************************************/
   /*                                                                */
   /* Before we do anything, let's establish the signal handlers.    */
   /*                                                                */
   /******************************************************************/
   if (cl_setup_handlers() == -1)
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"Problem establishing new signal handlers\n");
      fflush(stdout);
#endif /* DEBUG */
      break;
   }
 
   /* make sure slot id is valid */
   if ((slot_id < 0) || (slot_id >= MQMClientId.total_used))
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Invalid slot id: %d\n",slot_id);
     fflush(stdout);
#endif /* DEBUG */
     break;
   }
 
   /* Make sure request message length is valid */
   if ((request->length == 0) || (request->length > MAX_MSG_SIZE))
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Request message length is invalid\n");
     fprintf(stdout,"Request message is not sent\n");
     fflush(stdout);
#endif /* DEBUG */
     break;
   }
 
   /*****************************************************************/
   /*                                                               */
   /*    Check for access violation (memory)                        */
   /*                                                               */
   /*****************************************************************/
   if ((!MQMClientId.pConnList) || (!req_msg) || (!rep_msg))
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"ClExchmsg error: Memory access violation\n");
      fprintf(stdout,"Please check if slot id %d is still open\n",slot_id);
      fflush(stdout);
#endif /* DEBUG */
      break;
   }
 
   pClConn = &MQMClientId.pConnList[slot_id];
 
   /******************************************************************/
   /*                                                                */
   /*   Prepare request message                                      */
   /*                                                                */
   /******************************************************************/
   memcpy(req_msg, request->str, request->length);
   req_msg[request->length] = 0;
   memcpy(mqmd_buf,in_mqmd->str,in_mqmd->length);
   mqmd_buf[in_mqmd->length] = 0;

   if (in_mqmd->length > 0)
   {
        setMQMD(mqmd_buf,&Clmd);

   	if (Clmd.MsgId[0] == '\0')
		memcpy(Clmd.MsgId, MQMI_NONE, MQ_MSG_ID_LENGTH);
   	if (Clmd.CorrelId[0] == '\0')
		memcpy(Clmd.CorrelId, MQCI_NONE, MQ_CORREL_ID_LENGTH);
   	if (Clmd.Format[0] == '\0')
		memcpy(Clmd.Format, MQFMT_STRING, MQ_FORMAT_LENGTH);
   	if (Clmd.ReplyToQ[0] == '\0')
		strncpy(Clmd.ReplyToQ, pClConn->RepQName, MQ_Q_NAME_LENGTH);
   	if (Clmd.ReplyToQMgr[0] == '\0')
		strncpy(Clmd.ReplyToQMgr,pClConn->QMgrName,MQ_Q_MGR_NAME_LENGTH);
   	if (Clmd.Report == 0)
		Clmd.Report         = MQRO_PASS_MSG_ID + MQRO_PASS_CORREL_ID;
   	if (Clmd.MsgType == 0)
		Clmd.MsgType        = MQMT_REQUEST;
   }
   else {
   	memcpy(Clmd.MsgId, MQMI_NONE, MQ_MSG_ID_LENGTH);
   	memcpy(Clmd.CorrelId, MQCI_NONE, MQ_CORREL_ID_LENGTH);
   	memcpy(Clmd.Format, MQFMT_STRING, MQ_FORMAT_LENGTH);
   	strncpy(Clmd.ReplyToQ, pClConn->RepQName, MQ_Q_NAME_LENGTH);
  	strncpy(Clmd.ReplyToQMgr, pClConn->QMgrName, MQ_Q_MGR_NAME_LENGTH);
/*   	strcpy(Clmd.UserIdentifier,g_userid); // MKT 03/08/04 */
   	Clmd.MsgType        = MQMT_REQUEST;
   	Clmd.Report         = MQRO_PASS_MSG_ID + MQRO_PASS_CORREL_ID;
  	Clmd.Persistence    = MQPER_PERSISTENCE_AS_Q_DEF;
   	Clmd.Encoding       = MQENC_NATIVE;
   	Clmd.CodedCharSetId = MQCCSI_Q_MGR;
   }

   Clpmo.Options       = MQPMO_NO_SYNCPOINT;

   /******************************************************************/
   /*                                                                */
   /*   Put message buffer to the message queue                      */
   /*                                                                */
   /******************************************************************/
   MQPUT(pClConn->QMgrHcon,       /* connection handle               */
         pClConn->ReqQHobj,       /* object handle                   */
         &Clmd,                   /* message descriptor              */
         &Clpmo,                  /* default options                 */
         request->length,         /* buffer length                   */
         req_msg,                 /* message buffer                  */
         &CompCode,               /* completion code                 */
         &Reason);                /* reason code                     */
 
   /* report reason, if any */
   if (CompCode != MQCC_OK)
   {
     *return_code = Reason;
#ifdef DEBUG
     fprintf(stdout,"Unable to post message on request queue - %l\n",Reason);
     fflush(stdout);
#endif /* DEBUG */
     MQM_LOG(CompCode,Reason);
     break;
   }
 
#ifdef DEBUG
   fprintf(stdout,"Outgoing (request) message id:\n");
   fflush(stdout);
   LV(MQ_MSG_ID_LENGTH, (char *)&Clmd.MsgId);
   fprintf(stdout,"Outgoing (request) correlation id:\n");
   fflush(stdout);
   LV(MQ_CORREL_ID_LENGTH, (char *)&Clmd.CorrelId);
   fflush(stdout);
   fprintf(stdout,"Outgoing (request) message:\n");
   fflush(stdout);
   LV(request->length, req_msg);
#endif /* DEBUG */
 
   /******************************************************************/
   /*                                                                */
   /*   Set get message options.                                     */
   /*                                                                */
   /******************************************************************/
   Clgmo.WaitInterval = timeout * 1000;  /* time is in milliseconds  */
   Clgmo.Options = MQGMO_WAIT            /* wait for replies         */
       + MQGMO_CONVERT                   /* request conversion       */
       + MQGMO_ACCEPT_TRUNCATED_MSG;     /* can truncate if needed   */
   Clgmo.MatchOptions =MQMO_MATCH_MSG_ID /* match message id         */
       + MQMO_MATCH_CORREL_ID;           /* match correlation id     */
 
 
   /******************************************************************/
   /*                                                                */
   /*   Get reply message                                            */
   /*                                                                */
   /******************************************************************/
#ifdef DEBUG
   fprintf(stdout,"waiting for reply...\n");
        fprintf(stdout,"\tprevious SIGALRM handler %x\n",cHSIGALRM);
        fprintf(stdout,"\tprevious SIGBUS handler %x\n",cHSIGBUS);
        fprintf(stdout,"\tprevious SIGFPE handler %x\n",cHSIGFPE);
        fprintf(stdout,"\tprevious SIGSEGV handler %x\n",cHSIGSEGV);
   fflush(stdout);
#endif /* DEBUG */
 
   buflen = MAX_MSG_SIZE;
 
   MQGET(pClConn->QMgrHcon,       /* connection handle               */
         pClConn->RepQHobj,       /* object handle for reply         */
         &Clmd,                   /* message descriptor              */
         &Clgmo,                  /* get options                     */
         buflen,                  /* buffer length                   */
         rep_msg,                 /* message buffer                  */
         &replylen,               /* reply length                    */
         &CompCode,               /* completion code                 */
         &Reason);                /* reason code                     */
 
   if (CompCode != MQCC_OK)
   {
     *return_code = Reason;
#ifdef DEBUG
     switch(Reason)
     {
       case MQRC_NO_MSG_AVAILABLE:
            fprintf(stdout,"GET reply is timed out\n");
            fflush(stdout);
            break;
       default:
            fprintf(stdout,"Unable to get message on reply queue\n");
            fflush(stdout);
            MQM_LOG(CompCode,Reason);
            break;
     }
#endif /* DEBUG */
     break;
   }
 
   /******************************************************************/
   /*                                                                */
   /*   Copy the reply message if appropriate                        */
   /*                                                                */
   /******************************************************************/
   rep_msg[replylen]=0;
   reply->str = rep_msg;
   reply->length = replylen;
#ifdef DEBUG
   fprintf(stdout,"Incoming (reply) message id:\n");
   fflush(stdout);
   LV(MQ_MSG_ID_LENGTH, (char *)&Clmd.MsgId);
   fprintf(stdout,"Incoming (reply) correlation id:\n");
   fflush(stdout);
   LV(MQ_CORREL_ID_LENGTH, (char *)&Clmd.CorrelId);
   fprintf(stdout,"Incoming (reply) message:\n");
   fflush(stdout);
   LV(reply->length, reply->str);
#endif /* DEBUG */
 
   /******************************************************************/
   /*                                                                */
   /*   Copy the reply message descriptor                            */
   /*                                                                */
   /******************************************************************/
   memset(mqmd_buf,0,MAX_MQMD_SIZE);
   getMQMD(&Clmd,mqmd_buf);

   memcpy(out_mqmd,mqmd_buf,MAX_MQMD_SIZE);

   break;
 
  } while (0);
 
   /******************************************************************/
   /*                                                                */
   /* Always restore the previous signal handlers.                   */
   /*                                                                */
   /******************************************************************/
   if (cl_cancel_handlers() == -1)
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"Problem restoring previous signal handlers\n");
      fflush(stdout);
#endif /* DEBUG */
   }
 
   /******************************************************************/
   /*                                                                */
   /*   All done                                                     */
   /*                                                                */
   /******************************************************************/
#ifdef DEBUG
   if (*return_code == SUCCESS)
      fprintf(stdout,"End of ClExchmsg- successful completion\n");
   else
      fprintf(stdout,"End of ClExchmsg - unsuccessful completion\n");
   fflush(stdout);
#endif /* DEBUG */
 
   return;
 
} /* end of ClExchmsg */
 


/*
**	ClSend
**
**	Send message without waiting for a reply.
**
**	Inputs:
**		count		non-zero if calling from M.
**		request		request message
**		slot_id		slot id.
**
**	Outputs:
**		return_code	SUCCESS or FAILURE
**
**	Returns:
**		None
*/

/*****

void ClSend(int count,
          STR_DESCRIPTOR *request,
          SLONG slot_id,
          SLONG *return_code)
{
   MQMD   Clmd = {MQMD_DEFAULT};
   MQPMO Clpmo = {MQPMO_DEFAULT};
   MQLONG   CompCode;
   MQLONG   Reason;
   CONNINFO *pClConn;

#ifdef DEBUG
   fprintf(stdout,"\nStart of ClSend\n");
   fflush(stdout);
#endif

   *return_code = SUCCESS;

 do
 {
   if (cl_setup_handlers() == -1)
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"Problem establishing new signal handlers\n");
      fflush(stdout);
#endif
      break; 
   }

   if ((slot_id < 0) || (slot_id >= MQMClientId.total_used))
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Invalid slot id: %d\n",slot_id);
     fflush(stdout);
#endif
     break;
   }

   if ((request->length == 0) || (request->length > MAX_MSG_SIZE))
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Request message length is invalid\n");
     fprintf(stdout,"Request message is not sent\n");
     fflush(stdout);
#endif
     break;
   }

   if ((!MQMClientId.pConnList) || (!req_msg))
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"ClSend error: Memory access violation\n");
      fprintf(stdout,"Please check if slot id %d is still open\n",slot_id);
      fflush(stdout);
#endif
      break;
   }

   pClConn = &MQMClientId.pConnList[slot_id];

   memcpy(req_msg, request->str, request->length);    
   memcpy(Clmd.MsgId, MQMI_NONE, MQ_MSG_ID_LENGTH);
   memcpy(Clmd.CorrelId, MQCI_NONE, MQ_CORREL_ID_LENGTH);
   memset(Clmd.ReplyToQ, 0, MQ_Q_NAME_LENGTH);
   memset(Clmd.ReplyToQMgr, 0, MQ_Q_MGR_NAME_LENGTH);
   memcpy(Clmd.Format, MQFMT_STRING, MQ_FORMAT_LENGTH);
   Clmd.MsgType        = MQMT_DATAGRAM;
   Clmd.Report         = MQRO_NONE;
   Clmd.Persistence    = MQPER_PERSISTENCE_AS_Q_DEF;
   Clmd.Encoding       = MQENC_NATIVE;
   Clmd.CodedCharSetId = MQCCSI_Q_MGR;
   Clpmo.Options       = MQPMO_NO_SYNCPOINT;

   MQPUT(pClConn->QMgrHcon,
         pClConn->ReqQHobj,
         &Clmd,
         &Clpmo,
         request->length,
         req_msg,
         &CompCode,
         &Reason);

   if (CompCode != MQCC_OK)
   {
     *return_code = Reason;
#ifdef DEBUG
     fprintf(stdout,"Unable to post message on request queue\n");
     fflush(stdout);
#endif
     MQM_LOG(CompCode,Reason);
     break;
   }

   break;

  } while (0);

   if (cl_cancel_handlers() == -1)
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"Problem restoring previous signal handlers\n");
      fflush(stdout);
#endif
   }

#ifdef DEBUG
   fprintf(stdout,"\nEnd of ClSend\n");
   fflush(stdout);
#endif
   return;

}

*****/

/*	ClSend
**
**      Send message without waiting for a reply.
**
**      Inputs:
**              count           non-zero if calling from M.
**              request         request message
**		mqmd		message descriptor
**              slot_id         slot id.
**
**      Outputs:
**              return_code     SUCCESS or FAILURE
**
**      Returns:
**              None
*/
void ClSend(int count,
          STR_DESCRIPTOR *request,
          STR_DESCRIPTOR *mqmd,
          SLONG slot_id,
          SLONG *return_code)
{
   MQMD   Clmd = {MQMD_DEFAULT};    /* Message Descriptor            */
   MQPMO Clpmo = {MQPMO_DEFAULT};   /* put message options           */
   MQLONG   CompCode;               /* completion code               */
   MQLONG   Reason;                 /* reason code                   */
   CONNINFO *pClConn;
 
#ifdef DEBUG
   fprintf(stdout,"\nStart of ClSend\n");
   fprintf(stdout,"ClSend: Request\nStr - %s\nLength - %d\n",request->str,request->length);
   fflush(stdout);
#endif /* DEBUG */
 
   *return_code = SUCCESS;
 
 do
 {
   /******************************************************************/
   /*                                                                */
   /* Before we do anything, let's establish the signal handlers.    */
   /*                                                                */
   /******************************************************************/
   if (cl_setup_handlers() == -1)
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"Problem establishing new signal handlers\n");
      fflush(stdout);
#endif /* DEBUG */
      break;
   }
 
   /* make sure slot id is valid */
   if ((slot_id < 0) || (slot_id >= MQMClientId.total_used))
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Invalid slot id: %d\n",slot_id);
     fflush(stdout);
#endif /* DEBUG */
     break;
   }
 
   /* Make sure request message length is valid */
   if ((request->length == 0) || (request->length > MAX_MSG_SIZE))
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Request message length is invalid\n");
     fprintf(stdout,"Request message is not sent\n");
     fflush(stdout);
#endif /* DEBUG */
     break;
   }
 
   /*****************************************************************/
   /*                                                               */
   /*    Check for access violation (memory)                        */
   /*                                                               */
   /*****************************************************************/
   if ((!MQMClientId.pConnList) || (!req_msg))
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"ClSend error: Memory access violation\n");
      fprintf(stdout,"Please check if slot id %d is still open\n",slot_id);
      fflush(stdout);
#endif /* DEBUG */
      break;
   }
 
   pClConn = &MQMClientId.pConnList[slot_id];
 
   /******************************************************************/
   /*                                                                */
   /*   Prepare request message                                      */
   /*                                                                */
   /******************************************************************/
   memcpy(req_msg, request->str, request->length);
   req_msg[request->length] = 0;
   memcpy(mqmd_buf,mqmd->str,mqmd->length);
   mqmd_buf[mqmd->length] = 0;

   if (mqmd->length > 0)
   {
	setMQMD(mqmd_buf,&Clmd);

   	if (Clmd.MsgId[0] == '\0')
        	memcpy(Clmd.MsgId, MQMI_NONE, MQ_MSG_ID_LENGTH);
   	if (Clmd.CorrelId[0] == '\0')
        	memcpy(Clmd.CorrelId, MQCI_NONE, MQ_CORREL_ID_LENGTH);
   	if (Clmd.Format[0] == '\0')
        	memcpy(Clmd.Format, MQFMT_STRING, MQ_FORMAT_LENGTH);
   	if (Clmd.MsgType == 0)
		Clmd.MsgType        = MQMT_DATAGRAM;
   }
   else {
   	memcpy(Clmd.MsgId, MQMI_NONE, MQ_MSG_ID_LENGTH);
   	memcpy(Clmd.CorrelId, MQCI_NONE, MQ_CORREL_ID_LENGTH);
   	memset(Clmd.ReplyToQ, 0, MQ_Q_NAME_LENGTH);
   	memset(Clmd.ReplyToQMgr, 0, MQ_Q_MGR_NAME_LENGTH);
   	memcpy(Clmd.Format, MQFMT_STRING, MQ_FORMAT_LENGTH);
/*   	strcpy(Clmd.UserIdentifier,g_userid); // MKT 03/08/04 */
   	Clmd.MsgType        = MQMT_DATAGRAM;
   	Clmd.Report         = MQRO_NONE;
   	Clmd.Persistence    = MQPER_PERSISTENCE_AS_Q_DEF;
   	Clmd.Encoding       = MQENC_NATIVE;
   	Clmd.CodedCharSetId = MQCCSI_Q_MGR;
   }
 
   Clpmo.Options       = MQPMO_NO_SYNCPOINT;
 
   /******************************************************************/
   /*                                                                */
   /*   Put message buffer to the message queue                      */
   /*                                                                */
   /******************************************************************/
   MQPUT(pClConn->QMgrHcon,       /* connection handle               */
         pClConn->ReqQHobj,       /* object handle                   */
         &Clmd,                   /* message descriptor              */
         &Clpmo,                  /* default options                 */
         request->length,         /* buffer length                   */
         req_msg,                 /* message buffer                  */
         &CompCode,               /* completion code                 */
         &Reason);                /* reason code                     */
 
   /* report reason, if any */
   if (CompCode != MQCC_OK)
   {
     *return_code = Reason;
#ifdef DEBUG
     fprintf(stdout,"Unable to post message on request queue\n");
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
   if (cl_cancel_handlers() == -1)
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"Problem restoring previous signal handlers\n");
      fflush(stdout);
#endif /* DEBUG */
   }
 
   /******************************************************************/
   /*                                                                */
   /*   All done                                                     */
   /*                                                                */
   /******************************************************************/
#ifdef DEBUG
   fprintf(stdout,"\nEnd of ClSend\n");
   fflush(stdout);
#endif /* DEBUG */
   return;
 
} /* end of ClSend */
 

 
/*	cl_signal_catcher
**
**	Do nothing - simply ignore signal caught.
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
void cl_signal_catcher(int sig)
{

#ifdef DEBUG
	fprintf(stdout,"cl_signal_catcher: client PID %d caught signal %x\n",getpid(),sig);
	fflush(stdout);
#endif

	return;
} /* end of cl_signal_catcher */




/*
**	cl_setup_handlers
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
int cl_setup_handlers()
{
	int	status = -1;

#ifdef DEBUG
	fprintf(stdout,"cl_setup_handlers: start\n");
	fflush(stdout);
#endif

	do
	{
		if ((cHSIGALRM = mqm_signal(SIGALRM, SIG_IGN)) == SIG_ERR)
			break;

		if ((cHSIGBUS = mqm_signal(SIGBUS, cl_signal_catcher)) == SIG_ERR)
			break;

		if ((cHSIGFPE = mqm_signal(SIGFPE, cl_signal_catcher)) == SIG_ERR)
			break;

		if ((cHSIGSEGV = mqm_signal(SIGSEGV, cl_signal_catcher)) == SIG_ERR)
			break;

		status = 0;

	} while(0);

#ifdef DEBUG
	fprintf(stdout,"cl_setup_handlers: end - returning status is %d\n",status);
	fprintf(stdout,"\tprevious SIGALRM handler %x\n",cHSIGALRM);
	fprintf(stdout,"\tprevious SIGBUS handler %x\n",cHSIGBUS);
	fprintf(stdout,"\tprevious SIGFPE handler %x\n",cHSIGFPE);
	fprintf(stdout,"\tprevious SIGSEGV handler %x\n",cHSIGSEGV);
	fflush(stdout);
#endif

	return (status);
} /* end of cl_setup_handlers */




/*
**	cl_cancel_handlers
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
int cl_cancel_handlers()
{
	int	status = -1;

#ifdef DEBUG
	fprintf(stdout,"cl_cancel_handlers: start\n");
	fflush(stdout);
#endif

	do
	{
		if (mqm_signal(SIGALRM, cHSIGALRM) == SIG_ERR)
			break;

		if (mqm_signal(SIGBUS, cHSIGBUS) == SIG_ERR)
			break;

		if (mqm_signal(SIGFPE, cHSIGFPE) == SIG_ERR)
			break;

		if (mqm_signal(SIGSEGV, cHSIGSEGV) == SIG_ERR)
			break;

		status = 0;

	} while(0);

#ifdef DEBUG
	fprintf(stdout,"cl_cancel_handlers: end - returning status is %d\n",status);
	fflush(stdout);
#endif

	return (status);
} /* end of cl_cancel_handlers */
