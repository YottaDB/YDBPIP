/*
*	alerts.c
*
*	Copyright(c)2000 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	DESC: Sanchez Computer Associates Alerts library
*
*   $Id$
*   $Log:	alerts.c,v $
*   $Revision: 1.1 $
*
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <libgen.h>
#include "extcall.h" 

#define MAX_STR         2048 
#define DELIMITER 	"	"
#define STBLER_TABLE	"/SCA/sca_gtm/alerts/stbler.err"
#define STBLMSG_TABLE	"/SCA/sca_gtm/alerts/stblmsg.err"
#define MERROR_TABLE	"/SCA/sca_gtm/alerts/merror.err"
#define QUEUE_TABLE	"/SCA/sca_gtm/alerts/queue.err"
#define MUPIP_TABLE	"/SCA/sca_gtm/alerts/mupip.err"

#define HOSTNAME	"hostname"
#define ALERT_SCRIPT	"/SCA/tools/sca_alert.sh"

void
geterrlos(	int count,
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
	int  err_pri = -1;
	int  err_log;
	int  custom_err_pri = -1;
	int  scount = 0;
	int  found = 0;
	int  ret;
	int  status;
	char *evnam;
	char *padir = (char *)NULL;
	char *errordir = (char *)NULL;
	char *err_dir="/SCA/sca_gtm/alerts";

	FILE *fp = NULL;

	/*
	 * Get PROFILE/Anyware directory name
	 */
	if ((padir=(char *)getenv("PROFILE_DIR")) == NULL)
                if ((padir=(char *)getenv("DIR")) == NULL)
                        padir = "PROFILE_DIR";

	padir=(char *)basename((char *)padir);

	if ((errordir=(char *)getenv("SCA_ERROR_DIR")) == NULL)
		errordir=err_dir;

	if (strcmp(error_category,"STBLER") == 0)
		sprintf(error_table,"%s/stbler.err",errordir);
	else if (strcmp(error_category,"STBLMSG") == 0)
		sprintf(error_table,"%s/stblmsg.err",errordir);
	else if (strcmp(error_category,"MERROR") == 0)
		sprintf(error_table,"%s/merror.err",errordir);
	else if (strcmp(error_category,"QUEUE") == 0)
		sprintf(error_table,"%s/queue.err",errordir);
	else if (strcmp(error_category,"MUPIP") == 0)
		sprintf(error_table,"%s/mupip.err",errordir);

	if ((fp = fopen(error_table, "r")) == NULL) { 
		printf("Can't open file %s \n",error_table);
		return;
	}

	while (((fgets(buf, MAX_STR - 1, fp)) != NULL) && (!found)) 
	{
		if ((pstr = strtok(buf, DELIMITER )) != NULL) 
		{
			scount++;
        		/* pstr points to the first token */
			err_code = pstr;

			if (strcmp(error_code, err_code) == 0) 
			{
				found = 1;
				while ((pstr = strtok((char *)NULL, DELIMITER )) != NULL) 
				{
				    scount++;
				    switch(scount) 
				    {
					case(2):
					    desc->str[desc->length] = '\0';
					    ret = sscanf(desc->str,"%s",str);
				    	    if (ret != 1)
						err_desc = pstr;
					    else
						err_desc = desc->str;
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
		if (found == 1) 
		{
        	    (void)strncpy(desc->str,err_desc, (strlen(err_desc) < desc->length) ? strlen(err_desc) : desc->length); 
        	    desc->length=(strlen(desc->str) < desc->length) ? strlen(err_desc) : desc->length;
		    *return_code = err_pri;
		    sprintf(fmtstr,"PROFILE Directory - %s: %s",padir,err_desc);

		    if ((nolog != 1) && (err_log != 0))
			status = PostEventSanchez(event,custom_err_pri,fmtstr);

		    if ((noalert != 1) && (err_pri >= 3))
			status = AlertEventSanchez(event,custom_err_pri,fmtstr);
               	    break;
		}
	} /* while */
	if (found == 0 ) 
	{
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
		(void)strcpy(host,HOSTNAME);

	/*
	 * Get the alert script name
	 */
	if ((ascript=(char *)getenv("ALERT_SCRIPT")) == NULL)
		ascript = ALERT_SCRIPT;

	/*
	 * Build the alert command string to call the shell script
	 */

	memset(alformat,0,MAX_STR);
	while ((evformat[i]) != '\0') 
	{
		if (evformat[i] != '"') 
		{
			alformat[j] = evformat[i];
			i++;
			j++;
		}
		else
			i++;
	}
	evformat[strlen(evformat)-1]='\0';
	alertformat[0]='\0';

	/* strcat(alertformat,"\"\"SANCHEZ ");
	strcat(alertformat,evformat);
	strcat(alertformat,"\"\""); */

	strcat(alertformat,"\"\\\"SANCHEZ ");
	strcat(alertformat,alformat);
	strcat(alertformat,"\\\"\"");

	sprintf(alertcmd,"%s %s %s %s %d",ascript,host,evname,alertformat,evpriority);
	
	/*
	 * Send an alert event and return the status 
	 */

	ret = system(alertcmd);
	return ret;
}

int
GtmEventLog(int count, char *category, char *code, char *msg)
{	
	SLONG 		rc;
	char		desc_str[2048];
	STR_DESCRIPTOR	desc;

	desc.length = strlen(msg);
	desc.str = &desc_str[0];
	strcpy(desc.str, msg);

	geterrlos(7, code, category, NULL, 0, 0, &desc, &rc);
	return(rc);
}

char * version () {
        return VERSION;
}
