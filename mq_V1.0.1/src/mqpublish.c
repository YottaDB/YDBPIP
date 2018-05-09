/*********************************************************************/
/*                                                                   */
/* Copyright(c)2001 Sanchez Computer Associates, Inc.	             */	
/*      All Rights Reserved					     */
/*                                                                   */
/*      ORIG: Harsha Lakshmikantha				     */
/*                                                                   */
/* Program name: mqpublish.c                                         */
/*                                                                   */
/* Description: This is a publication program, publishing on a       */
/*              specified topic using the high level function        */
/*              amPublish().                                         */
/*                                                                   */
/*********************************************************************/
/*                                                                   */
/*  Program logic:                                                   */
/*                                                                   */
/*    Create a session using amInitialize().                         */
/*    Publish data using amPublish().          	                     */
/*    Close and delete the session using amTerminate().              */
/*    Terminate the session and return EXIT_FAILURE if any AMI       */
/*    function call returns an error.                                */
/*                                                                   */
/*********************************************************************/
#ifdef AMT_IMS
#pragma runopts(env(IMS),plist(IMS))
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <scatype.h>
#include <cmqc.h>
#include <mqmmsg.h>
#include <mqm.h>
#if defined (AMT_OAMAS)
 #include <oamasami.h>
#else
 #include <amtc.h>
#endif
#include <time.h>

#if defined (AMT_CICS ) | defined (AMT_IMS)
#include <amts39sp.h>
#endif

/*------------ Global Variables ------------*/
Sigfunc  *sHSIGALRM;			/* prev SIGALRM handler          */
Sigfunc  *sHSIGBUS;			/* prev SIGBUS handler           */
Sigfunc  *sHSIGFPE;			/* prev SIGFPE handler           */
Sigfunc  *sHSIGSEGV;			/* prev SIGSEGV handler          */

/*------------ External Functions ------------*/
extern Sigfunc *mqm_signal(int, Sigfunc *);

/*------------ Local Functions ------------*/
void pub_signal_catcher(int);
int pub_setup_handlers();
int pub_cancel_handlers();

/*********************************************************************/
/* The names used on the creation of the objects.                    */
/*                                                                   */
/* SESSION_NAME                                                      */
/*    This is the name used to create the session.                   */
/*                                                                   */
/* POLICY_NAME                                                       */
/*    This is the name used to create the policy used for most       */
/*    operations in this program. The name matches a supplied policy */
/*    definition in the repository.                                  */
/*                                                                   */
/* PUBLISHER_NAME                                                    */
/*    This is the name used to create the publisher service used     */
/*    to publish topic data. The name matches a supplied service     */
/*    definition in the repository.                                  */
/*                                                                   */
/* RESPONSE_NAME                                                     */
/*    This is the name used to create the receiver service used for  */
/*    receiving response message from the broker. The name matches   */
/*    a supplied service definition in the repository.               */
/*                                                                   */
/* PUB_MESSAGE_NAME                                                  */
/*    This is the name of the message used to contain the            */
/*    publication data. The name is simply a user supplied tag for   */
/*    the message.                                                   */
/*                                                                   */
/*********************************************************************/
#define SESSION_NAME        (AMSTR)"AMT.SANCHEZ.SESSION"
#define POLICY_NAME         (AMSTR)"AMT.SANCHEZ.PUB.SUB.POLICY"
#define PUBLISHER_NAME      (AMSTR)"AMT.SANCHEZ.PUBLISHER"
#define RESPONSE_NAME       (AMSTR)"AMT.SANCHEZ.RESPONSE.RECEIVER"
#define PUB_MESSAGE_NAME    (AMSTR)"AMT.SANCHEZ.PUB.MESSAGE"

void psconnect(int count,
             SLONG *handle,
             SLONG *return_code)
{
  AMLONG   compCode;
  AMLONG   reason;
  AMHSES   hSession     = AMH_NULL_HANDLE;


#ifdef DEBUG
   fprintf(stdout,"Start of psconnect\n");
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
   if (pub_setup_handlers() == -1)
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Problem establishing new signal handlers\n");
     fflush(stdout);
#endif
     break;
   }

  /********************************************************************/
  /* Initialize (i.e., create and open) the session with the          */
  /* specified name.                                                  */
  /********************************************************************/

  hSession = amInitialize( SESSION_NAME  	/* session name       */
                         , POLICY_NAME   	/* policy name        */
                         , &compCode            /* completion code    */
                         , &reason);            /* reason code        */
  if ( hSession == AMH_NULL_HANDLE )
  {
#ifdef DEBUG
    fprintf(stdout,"*** amInitialize() failed cc = %d, rc = %d \n",
            compCode, reason);
    fflush(stdout);
#endif

    *return_code = reason;
    break;
  }

    *handle = hSession;

#ifdef DEBUG
  fprintf(stdout,"Session handle %d\n",*handle);
  fprintf(stdout,"    psconnect() succeeded \n");
  fflush(stdout);
#endif

   break;
 } while (0);

   /******************************************************************/
   /*                                                                */
   /* Always restore the previous signal handlers.                   */
   /*                                                                */
   /******************************************************************/
   if (pub_cancel_handlers() == -1)
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"Problem restoring previous signal handlers\n");
      fflush(stdout);
#endif /* DEBUG */
   }
}



void pub(int count,
         STR_DESCRIPTOR *msg,
         STR_DESCRIPTOR *topic,
         SLONG handle,
         SLONG *return_code)
{
  AMLONG   compCode;
  AMLONG   reason;
  AMHSES   hSession     = AMH_NULL_HANDLE;
  AMBOOL   success      = AMB_FALSE;


#ifdef DEBUG
   fprintf(stdout,"\nStart of pub\n");
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
   if (pub_setup_handlers() == -1)
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Problem establishing new signal handlers\n");
     fflush(stdout);
#endif
     break;
   }

  hSession = handle;

    /******************************************************************/
    /* Publish the data.                                              */
    /******************************************************************/
    success = amPublish( hSession             /* session handle       */
     , PUBLISHER_NAME                  	      /* publisher name       */
     , POLICY_NAME                            /* policy name          */
     , NULL                     	      /* no response needed   */
     , topic->length             	      /* topic name length    */
     , topic->str                             /* topic name           */
     , msg->length                            /* length of data       */
     , (unsigned char *)msg->str              /* publication data     */
     , PUB_MESSAGE_NAME                       /* publish message name */
     , &compCode                              /* completion code      */
     , &reason );                             /* reason code          */
    if ( success == AMB_FALSE )
    {
#ifdef DEBUG
      fprintf(stdout,"*** amPubPublish() failed cc = %d, rc = %d \n",
             compCode, reason);
      fflush(stdout);
#endif

      amTerminate( &hSession, NULL, &compCode, &reason);

      *return_code = reason;
      break;
    }

#ifdef DEBUG
  fprintf(stdout,"    pub() succeeded \n");
  fflush(stdout);
#endif

  *return_code = SUCCESS;

   break;
 } while (0);

   /******************************************************************/
   /*                                                                */
   /* Always restore the previous signal handlers.                   */
   /*                                                                */
   /******************************************************************/
   if (pub_cancel_handlers() == -1)
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"Problem restoring previous signal handlers\n");
      fflush(stdout);
#endif /* DEBUG */
      return;
   }

#ifdef DEBUG
   fprintf(stdout,"End of pub - successful completion\n");
   fflush(stdout);
#endif
} /* end of pub */




void psdisconnect(int count,
                  SLONG *handle,
                  SLONG *return_code)
{
  AMLONG   compCode;
  AMLONG   reason;
  AMHSES   hSession     = AMH_NULL_HANDLE;
  AMBOOL   success      = AMB_FALSE;


#ifdef DEBUG
   fprintf(stdout,"Start of psdisconnect\n");
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
   if (pub_setup_handlers() == -1)
   {
     *return_code = FAILURE;
#ifdef DEBUG
     fprintf(stdout,"Problem establishing new signal handlers\n");
     fflush(stdout);
#endif
     break;
   }

  /* success = amTerminate( &hSession   */

  /********************************************************************/
  /* Terminate the session.                                           */
  /********************************************************************/
  success = amTerminate( handle               /* session handle       */
                       , POLICY_NAME          /* policy name          */
                       , &compCode            /* completion code      */
                       , &reason);            /* reason code          */
  if ( success == AMB_FALSE )
  {
#ifdef DEBUG
    fprintf(stdout,"*** amTerminate() failed cc = %d, rc = %d \n",
            compCode, reason);
    fflush(stdout);
#endif

    *return_code = reason;
    break;
  }

#ifdef DEBUG
  fprintf(stdout,"    amTerminate() succeeded \n");
  fflush(stdout);
#endif

  *return_code = SUCCESS;

   break;
 } while (0);

   /******************************************************************/
   /*                                                                */
   /* Always restore the previous signal handlers.                   */
   /*                                                                */
   /******************************************************************/
   if (pub_cancel_handlers() == -1)
   {
      *return_code = FAILURE;
#ifdef DEBUG
      fprintf(stdout,"Problem restoring previous signal handlers\n");
      fflush(stdout);
#endif /* DEBUG */
      return;
   }

#ifdef DEBUG
   fprintf(stdout,"End of psdisconnect \n");
   fflush(stdout);
#endif
} /* end of psdisconnect */




/*
**	pub_signal_catcher
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
void pub_signal_catcher(int sig)
{

#ifdef DEBUG
	fprintf(stdout,"pub_signal_catcher: server PID %d caught signal %x\n",getpid(),sig);
	fflush(stdout);
#endif

	return;
} /* end of pub_signal_catcher */




/*
**	pub_setup_handlers
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
int pub_setup_handlers()
{
	int	status = -1;

#ifdef DEBUG
	fprintf(stdout,"pub_setup_handlers: start\n");
	fflush(stdout);
#endif

	do
	{
		if ((sHSIGALRM = mqm_signal(SIGALRM, SIG_IGN)) == SIG_ERR)
			break;

		if ((sHSIGBUS = mqm_signal(SIGBUS, pub_signal_catcher)) == SIG_ERR)
			break;

		if ((sHSIGFPE = mqm_signal(SIGFPE, pub_signal_catcher)) == SIG_ERR)
			break;

		if ((sHSIGSEGV = mqm_signal(SIGSEGV, pub_signal_catcher)) == SIG_ERR)
			break;

		status = 0;

	} while(0);

#ifdef DEBUG
	fprintf(stdout,"pub_setup_handlers: end - returning status is %d\n",status);
	fprintf(stdout,"\tprevious SIGALRM handler %x\n",sHSIGALRM);
	fprintf(stdout,"\tprevious SIGBUS handler %x\n",sHSIGBUS);
	fprintf(stdout,"\tprevious SIGFPE handler %x\n",sHSIGFPE);
	fprintf(stdout,"\tprevious SIGSEGV handler %x\n",sHSIGSEGV);
	fflush(stdout);
#endif

	return (status);
} /* end of pub_setup_handlers */




/*
**	pub_cancel_handlers
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
int pub_cancel_handlers()
{
	int	status = -1;

#ifdef DEBUG
	fprintf(stdout,"pub_cancel_handlers: start\n");
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
	fprintf(stdout,"pub_cancel_handlers: end - returning status is %d\n",status);
	fflush(stdout);
#endif

	return (status);
} /* end of pub_cancel_handlers */
