/*
*	readport.c 
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	UNIX:	Sara G. Walters - 27 Feburary 1995
*
*	DESC:	Get the name of the tty associated with the calling
*			process.
*
*   $Id$
*   $Log:	readport.c,v $
 * Revision 1.4  00/10/19  10:23:49  10:23:49  lyh ()
 * Rewrite to make it more robust.
 * ut_host may have different length on each platform - so we should
 * take advantage of that.
 * also, host short name may not always have an alias - we should try
 * the host long name first. if that doesn't work, then we'll use the
 * host short name.
 * 
 * Revision 1.3  00/10/18  13:56:57  13:56:57  lyh ()
 * drop the strlen() in the same check if str is null
 * 
 * Revision 1.2  00/05/31  11:02:25  11:02:25  lyh ()
 * Returns the default device if user logged in from an Xterm window
 * 
 * Revision 1.1  95/07/24  11:25:58  11:25:58  rcs ()
 * Initial revision
 * 
 * Revision 1.3  95/05/22  15:01:51  15:01:51  sca ()
 * sgI VMS
 * 
*   $Revision: 1.4 $
*
*/

#include 	<stdio.h>
#include 	<stdlib.h>
#include 	<string.h>
#include 	<utmp.h>
#include	<unistd.h>
#include 	<memory.h>
#include 	<netdb.h>
#include 	<sys/socket.h>
#include 	<sys/socketvar.h>
#include 	<netinet/in.h>
#include 	<arpa/inet.h>
#include	"extcall.h"
#include	"scatype.h"

#define 	DELIMITER	"."

char *gethostSN(char *);
char *gethostIP(char *);

/***************************************************************************
*
*    readport - returns the IP address of the host system where the user
*               logged in from.
*    Example: If the user started a SmarTerm session to login to bubba,
*             readport will return 140.140.1.175 - which is the IP address
*             of the PC connected to the network.
*             If the user performs an rlogin or telnet from dino to bubba,
*             readport will return 140.140.1.203 - which is the IP address
*             of dino.
*
***************************************************************************/ 

void readport(int count,STR_DESCRIPTOR *tty,SLONG *rc)
{
 	char *ptr,*pstr;
	int i=0;
	int ip=1;
 	struct utmp *myutmp, temp;
	char *hostSN, *hostIP;
	char hoststr[256];
	char hstr[256];
	int ip_len=0;

	/* get TTY environment variable */
	ptr = getenv(TTY);
	if (ptr == (char *)NULL)
	{
		/* No TTY environment defined, try ttyname() */
		ptr = ttyname(0);
		if (ptr == (char *)NULL)
		{
			/* still no good, give up */
			tty->length=0;
			*rc = MUMPS_FAILURE;
			return;
		}
	}

	/* Set utmp structure in temp before querying the account database */
	/* At this point, ptr is pointer to string like this: "/dev/pts/2" */
	/* We need to copy "pts/2" to temp.ut_line and temp.ut_line        */
	/* in effect, we are skipping the first 5 bytes in ptr             */
	memset(&temp,0,sizeof(temp));
	temp.ut_type = USER_PROCESS;
	strcpy(temp.ut_id, &ptr[5]);
	strcpy(temp.ut_line, &ptr[5]); 
	hostIP = NULL;

	/* Do this loop exactly once */
	do
	{
		/* get utmp entry */
		if ((myutmp = getutline(&temp)) == NULL)
			break;

		/* check if host name is returned */
		if (myutmp->ut_host[0] == '\0')
			break;

		/* At this point, myutmp->ut_host is in either dot notation */
		/* such as "140.140.1.175", or full node name such as       */
                /* "dino.sanchez.com", or short node name such as "bubba"   */
		/* There is a problem with using ut_host because it's       */
		/* declared as 16 bytes string. If ut_host name is shorter  */
		/* than 16 bytes, then it's terminated properly. Otherwise  */
		/* (as in the case with "dino.sanchez.com", it will run-off */
		/* the declared boundary, and strlen() or strcpy will not   */
		/* work properly. Here, we will attempt to return only the  */
		/* dot notation. Keep in mind that it is necessary to       */
		/* shorten ut_host from "dino.sanchez.com" to "dino" before */
		/* calling hostip() to get the dot notation for a host name */

		memset(hoststr,0,sizeof(hoststr));
		strncpy(hoststr,myutmp->ut_host,sizeof(myutmp->ut_host));
		strcpy(hstr,hoststr);

		if ((pstr = strtok(hstr, DELIMITER )) != NULL) {
			while ((pstr[i]) != '\0') {
                		if (isdigit(pstr[i])) {
                        		i++;
                		}
                		else {
					ip=0;
					break;
                		}

			}
		}

		if (ip)
		{
			/* This must be dot notation...            */
			hostIP = hoststr;
			break;
		}

		/* Try to get the IP address now.		     */
		if ((hostIP = gethostIP(hoststr)) != NULL)
			break;

		/* That didn't work, try host shortname */
		if ((hostSN = gethostSN(hoststr)) == NULL)
			break;

		/* Try to get the IP address again */
		hostIP = gethostIP(hostSN);

		/* That's it - whether we get it or not, we will break here */
		break;

	} while(0);

	if (hostIP == NULL)
	{
		/* couldn't find host IP address, return ptr anyway */
		tty->length=strlen(ptr);
		(void)memcpy(tty->str,ptr,tty->length);
	}
	else
	{
		/* got IP address, return it */
		ip_len = strlen(hostIP);
		tty->length=strlen(hostIP);
		strncpy(tty->str,hostIP,tty->length);
	}

	*rc = MUMPS_SUCCESS;
	return;
}

/****************************************************************************
*
*    gethostSN - returns host short name
*    The host short name is delimted by '\0' or '.' character. The main idea
*    is to return the first part of a long host name to the calling program.
*
****************************************************************************/

char *
gethostSN(char *hostname)
{
	static char 		myhostSN[24];
	int			index = 0;

	memset(myhostSN,'\0',sizeof(myhostSN));
	for (;;)
	{
		if ((hostname[index] == '\0') || (hostname[index] == '.'))
			break;
		myhostSN[index] = hostname[index];
		index++;
	}

	return(myhostSN);
}

/****************************************************************************
*
*    gethostIP - returns host IP address.
*    The host IP address is in dot notation such as 140.140.1.175
* 
****************************************************************************/

char *
gethostIP(char *hostname)
{
	struct in_addr       netAddress;
	struct hostent       *hent     = (struct hostent *)NULL;
	char                 *list     = (char *)NULL;
	char                 *myhostIP = (char *)NULL;
 
	hent = gethostbyname(hostname);
	if (hent)
	{
		list = hent->h_addr_list[0];
		if (list)
		{
			memcpy(&netAddress,list,4);
			myhostIP = inet_ntoa(netAddress);
		}
	}
 
	return(myhostIP);
}

/*
void
readport(int count,STR_DESCRIPTOR *tty,SLONG *rc)
{
	char *ptr = (char *)NULL;


	ptr = getenv(TTY);

	if((strlen(ptr) < tty->length) && (ptr != (char *)NULL))
	{
		tty->length=strlen(ptr);
		(void)memcpy(tty->str,ptr,strlen(ptr));
		*rc = MUMPS_SUCCESS;
	}
	else
	{
		tty->length=0;
		*rc = MUMPS_FAILURE;
	}
}
*/
