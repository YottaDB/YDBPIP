/*****************************************************************************
*
*	mqm.h
*
*	Copyright(c)2000 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	Description: Sanchez MQSeries Data Definition for UNIX
*
* $Author: lyh $
*
* $Date: 2000/11/08 20:02:59 $
*
* $Id: mqm.h,v 1.1 2000/11/08 20:02:59 lyh Exp lyh $
*
* $Log: mqm.h,v $
 * Revision 1.1  2000/11/08  20:02:59  lyh
 * Initial revision
 *
*
* $Revision: 1.1 $
*
*****************************************************************************/

#if !defined(MQM_INCLUDED)             /* File not yet included?      */
#define MQM_INCLUDED                   /* Show file now included      */
#define DOLLAR_SIGN '$'
#define UNDERSCORE '_'
#define SCA_CS_ST "SCA_CS_ST"
#define MAX_NAME_LEN 80
#define QUEUE_LIST_INCREMENT 10
#define MQM_DEFAULT_TIMEOUT 60
#define MAX_MQMD_SIZE 2000

#define VERSION "libmqmapi.sl (LINUX) V1.0.1 Jun 06, 2005"

typedef struct ReplyInfo{
      MQBYTE24 saveMsgId;           /* saved message id              */
      MQBYTE24 saveCorrelId;        /* saved correlation id          */
      MQCHAR48 saveReplyToQ;        /* reply to queue name           */
      MQCHAR48 saveReplyToQMgr;     /* reply to queue manager name   */
} REPLYINFO;

/* Server/Client connection data structure */
typedef struct ConnInfo{            /* Individual connection info    */
         MQCHAR48 QMgrName;         /* Queue manager name            */
         MQCHAR48 ReqQName;         /* Request queue name            */
         MQCHAR48 RepQName;         /* Reply queue name              */
         MQHCONN  QMgrHcon;         /* Queue manager connect handle  */
         MQHOBJ   ReqQHobj;         /* Request queue object handle   */
         MQHOBJ   RepQHobj;         /* Reply queue object handle     */
} CONNINFO;
 
typedef struct ConnList{            /* List of open connection       */
         SLONG    total_count;      /* Number of slot allocated      */
         SLONG    total_used;       /* Number of slot used           */
         CONNINFO *pConnList;       /* Pointer to connection list    */
} CONNLIST;

typedef void Sigfunc (int);         /* For use in sigaction          */

#endif
