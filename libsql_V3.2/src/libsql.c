/*
MAR 2, 99 DAG
	Fixed LV problem with MRPC AND MRPC2. LV bytes at beginning of
message were not being chopped off as in SQL. They were inappropriately
begin returned to the caller.  Copied the last part of 
ProfileSQL over to ProfileMRPC and PofileMRPC2 to solve the problem. That
is, I used the parsing mechanism setup in ProfileSQL. This solved the
problem.

SEP 21, 01 thoniyim
	Memory Leak fix for the variables
		new_sql_message
		new_using_clause
	in the ProfileSQL function

JAN 15, 04 thoniyim
	Check for message id for the request and the reply are the same
	in ProfileSQL, ProfileMRPC and ProfileMRPC2 functions.
*/

#include "libsql.h"
#include <time.h>

void logging (STR_DESCRIPTOR *descriptor,
              char           *log_message);

unsigned char global_logging = LOGGING_OFF;
int total_time_outs  = 0;
int conseg_time_outs = 0;
unsigned char xxx[100];
extern  FILE *fptr;
int MAX_FILE_SIZE=0;
/*-------------------------------------------------------------------*/
int ProfileConnect (	const unsigned char *param_user_id,
			const unsigned char *password,
			const unsigned char *mtm_address,
			char  unsigned *profile_reply,
			const unsigned char *tlo)
{
#define number_offset 6

        int error_code, timeout = 60, i, j, k, num_size;
        STR_DESCRIPTOR request, reply;
        char reply_buffer[MAX_MSG_SIZE],request_buffer[MAX_MSG_SIZE+1];
	MTM_MSG_HEADER  *mess_header;
	unsigned char *(header_and_message[6]);
	unsigned char *(header_strings[6]);
        unsigned char *(message_strings1[10]);
        unsigned char *(message_strings2[10]);
	unsigned char *temp_buffer;

        request.str  = request_buffer;
    
        k = 0;
        strcpy ((char *)passed_mtm_address,(char *)mtm_address);
	ClConnect(2, mtm_address, &k);
        error_code = error_check (k,CLCONNECT,(unsigned char*)0,profile_reply);
	if (error_code != OK)
	   return error_code;

        memset(reply_buffer,0,sizeof(reply_buffer));
        memset(request_buffer,0,sizeof(request_buffer));
	j = setup_login_request(&request, param_user_id, password,
            mtm_address, tlo);

        k=0;
        logging (&request,"\nCLIENT LOGON REQUEST\n");
   	ClExchmsg(4, &request, &reply, timeout, &k);
        logging (&reply,"\nSERVER RESPONSE TO CLIENT LOGON REQUEST\n");

        error_code = error_check (k,CLLOGIN,&reply,profile_reply);  
	if (error_code != OK)
	   return error_code;

	num_size = get_number_size(reply.length-2);
        i = move_number(reply_buffer, reply.length-2);
	memcpy(reply_buffer+i,reply.str+1,reply.length-2);
	reply.str = reply_buffer;

	parse_string(reply.str,header_and_message);

	parse_string(header_and_message[1],header_strings);

	parse_string(header_and_message[2],message_strings1);

	parse_string(message_strings1[2],message_strings2);

	setup_token(message_strings2[1],profile_reply);


	return 0;	
}
/*-------------------------------------------------------------------*/
int ProfileSQL (const unsigned char *sql_token,
		const unsigned char *sql_message,
		const unsigned char *sql_qualifiers,
		unsigned char *profile_reply,
		unsigned char *retry,
		int   time_out)
{
	STR_DESCRIPTOR request, reply;
        char request_buffer[MAX_MSG_SIZE], reply_buffer[MAX_MSG_SIZE];
	int aa, i, j, k, num_size, error_code, error_code2, offset;
	unsigned char *(header_and_message[6]);
        unsigned char *(header_strings[6]);
        unsigned char *(message_strings1[1000]);
        unsigned char *(message_strings2[1000]);
	char buffer[MAX_MSG_SIZE];
	char	*pszSql = NULL,*new_sql_message = NULL, *new_using_clause;
	long	len_new_sql_message, len_new_using_clause;
	unsigned char *col_attributes= NULL, *new_sql_qualifiers = NULL;
	char	*lpsSelect;
	char	*tokens;
	int	nLen = 0;
	struct tm *curTime; 
	time_t	ltime;
	char	tmpBuf[128];
	
	if(sql_message == NULL) {
		strcpy((char *)profile_reply,"MSG_8564|Invalid SQL Command");
		strcat((char *)profile_reply,(char *)sql_message);
		return 1;
	}
	
	memset (request_buffer,0,sizeof(request_buffer));
	memset (reply_buffer,0,sizeof(reply_buffer));
	request.str = request_buffer;
	reply.str   = reply_buffer;

	/* Get time as number */
	time(&ltime);
	curTime = localtime( &ltime );

	/* Use strftime to build a customized time string. */
	strftime( tmpBuf, 128,"OPEN CURSOR CUR%H%M%S AS \n", curTime );

	/* For SELECT add open cursor */
	tokens = (char *)strstr((char *)sql_message, " ");
	nLen = tokens - (char *)sql_message;
	lpsSelect  = (char *) calloc(nLen + 1,1);
	if(NULL == lpsSelect)
		return -1;
	strncpy(lpsSelect,(char *)sql_message,nLen);
	pszSql = (char *)calloc(MAX_MSG_SIZE,1);
	if(strcasecmp(lpsSelect,"SELECT") == 0) {
		strcpy(pszSql,tmpBuf);
		strcat(pszSql,(char *)sql_message);
	}
	else
		strcpy(pszSql,(char *)sql_message);
	free(lpsSelect);

	new_sql_message = (char *) calloc(MAX_MSG_SIZE,1);
	new_using_clause = (char *) calloc(MAX_MSG_SIZE,1);
	len_new_sql_message = MAX_MSG_SIZE;
	len_new_using_clause = MAX_MSG_SIZE;

	error_code = ParseHostSQL(pszSql, strlen(pszSql),
		NULL ,0 ,new_sql_message, &len_new_sql_message,
		new_using_clause, &len_new_using_clause );
	free(pszSql);

        logging (NULL, "\nSQL MESSAGE\n");
        logging (NULL,(char*) sql_message);
        logging (NULL, "\nCLEANED SQL MESSAGE\n");
        logging (NULL,(char*) new_sql_message);
		
	if(len_new_using_clause) {
		nLen = strlen((char *)sql_qualifiers)+ len_new_using_clause + 1;
		new_sql_qualifiers = (unsigned char *)calloc(nLen + 1, 1);
		strcpy((char *)new_sql_qualifiers, (char *)sql_qualifiers);
		strcat((char *)new_sql_qualifiers,new_using_clause);
		pack_sql(&request,(unsigned char *)new_sql_message,
			new_sql_qualifiers,sql_token,retry);
	}
	else
	{
		pack_sql(&request,(unsigned char *)new_sql_message,
			sql_qualifiers,sql_token,retry);
	}
	/* thoniyim 09/21/2001
	   memory leak fix
	*/
	free(new_sql_message);
        free(new_using_clause); 

	k=0;
        logging (&request, "\nSQL MESSAGE SENT TO SERVER\n");        

   	ClExchmsg(4, &request, &reply, time_out, &k);

        logging (&reply, "\nSERVER RESPONSE TO SQL MESSAGE\n");
        error_code = error_check (k,CLSQL,&reply,profile_reply);

        if (error_code == OK_BUT_EMPTY_MESSAGE_BODY) {
              profile_reply[0] = 0;
              return OK;
        }

	if (error_code != OK && error_code != SQL_OK) {
           if (error_code == 4) {
              total_time_outs++;
              conseg_time_outs++;
               if (total_time_outs > 50000 || conseg_time_outs > 5000) {
                   printf ("\nValue of total_time_outs and conseg_time_outs: %d  %d\n", 
                        total_time_outs, conseg_time_outs);
                   exit (1);
               }
               ClDisconnect(2, buffer);
               ClConnect(2, passed_mtm_address, &k);
               error_code2 = error_check (k,CLCONNECT,(unsigned
                           char*)0,profile_reply);
               if (error_code2 != OK) {
	           i = get_message_id (retry,FALSE);
                   return error_code2;
               }
           }

	   i = get_message_id (retry,FALSE);
	   return error_code;
	}
        conseg_time_outs = 0;

        i = move_number(reply_buffer, reply.length-2);
	memcpy(reply_buffer+i,reply.str+1,reply.length-2);
        reply.str = reply_buffer;
        parse_string(reply.str,header_and_message);
 
        /*
         * thoniyim - CR 7426 - 01/16/2004
         * Check the data from the host for message id.
         * Check if the message id of request and reply matches.
         */
 
        parse_string(header_and_message[1],header_strings);
 
        i = memcmp(header_array[2].field,
                   header_strings[2]+1,
                   header_array[2].field_size);
        if (i != 0)
        {
                strcpy(profile_reply,"Message Ids for the request and reply does
n't match. Disconnect and connect again.");
                return -1001;
        }
 
	parse_string(header_and_message[2],message_strings1);

	parse_string(message_strings1[2],message_strings2);

	num_size = sca_string_size (message_strings2[4], &offset);	

     if (num_size > 0)
	if (num_size <= MAX_BYTE_VAL)
           num_size--;
        else
           if (num_size <= MAX_WORD_VAL)
              num_size -= 2;
           else
              if (num_size <= MAX_3BYTE_VAL)
                 num_size -= 3;
              else
                 num_size -= 4;

	parse_string(message_strings2[4],message_strings1);

	memcpy(profile_reply,message_strings1[1],num_size);

	profile_reply[num_size]=0;

	num_size = sca_string_size (message_strings2[6], &offset);	
	parse_string(message_strings2[6],message_strings1);
	message_strings1[num_size]=0;

	col_attributes = (unsigned char *) calloc(num_size+1,1);
	memcpy(col_attributes,message_strings1[1],num_size);
	FormatResultSet(profile_reply,col_attributes);
	free(col_attributes);
	
	return error_code;
}
/*-------------------------------------------------------------------*/
int ProfileDisconnect (	unsigned char *the_token,
			unsigned char *profile_reply)
{
#define TIME_OUT 20

	STR_DESCRIPTOR request, reply;
        char request_buffer[MAX_MSG_SIZE],reply_buffer[MAX_MSG_SIZE];
        int i, j, k, num_size, error_code, offset;
        char temp_buffer[MAX_MSG_SIZE];

	memset(request_buffer,0,sizeof(request_buffer));
	memset(reply_buffer,0,sizeof(reply_buffer));

	request.str = request_buffer;
	reply.str   = reply_buffer;

	setup_signoff(&request,the_token);
/*--------------*/

        k=0;
        logging (&request, "\nREQUEST TO LOG OFF\n");
    	ClExchmsg(4, &request, &reply, TIME_OUT, &k);
        logging (&reply, "\nSERVER RESPONSE TO LOG OFF REQUEST\n");

/*--------------*/
        error_code = error_check (k,CLDISCONNECT,&reply,profile_reply);  
	if (error_code != OK) {
	   ClDisconnect(2, temp_buffer);
	   return error_code;
        }
	
        ClDisconnect(2, temp_buffer);

	return OK;

}

/*-------------------------------------------------------------------*/
int ProfileMRPC (const unsigned char *message_token,
                 const unsigned char *pmrpc_id,
                 const unsigned char *pmrpc_params,
                 unsigned char  *profile_reply,
                 unsigned char  *retry,
                 int   time_out)
{
	int error_code, i, j, k, x, y, z, num_size, offset;
	char request_buffer[MAX_MSG_SIZE], reply_buffer[MAX_MSG_SIZE];
	STR_DESCRIPTOR request, reply;
	unsigned char *(header_and_message[6]);
        unsigned char *(header_strings[6]);
        unsigned char *(message_strings1[1000]);
        unsigned char *(message_strings2[1000]);

	memset (request_buffer,0,sizeof(request_buffer));
	memset (reply_buffer,0,sizeof(reply_buffer));
	request.str = request_buffer;
        reply.str   = reply_buffer;
	error_code = pack_mrpc (&request,
                        	pmrpc_id,
                        	pmrpc_params,
                        	message_token,
	                	retry);

/*DEAL WITH ERROR CODES HERE*/
 
	if (error_code != OK) {
	   i = get_message_id (retry,FALSE);
           return error_code;
	}

/*xyz*/
	k=0;
        sprintf (dummy_buff,"\nERRDEBUG MRPC REQUEST SENT TO SERVER, timeout %d: \n",time_out);
       /* logging (&request, "\nMRPC REQUEST SENT TO SERVER\n");*/
        logging (&request, dummy_buff);
	ClExchmsg(4, &request, &reply, time_out, &k);
        logging (&reply, "\nSERVER RESPONSE TO MRPC REQUEST\n");

	error_code = error_check (k,CLMRPC,&reply,profile_reply);
        if (error_code != OK)
        {
           i = get_message_id (retry,FALSE);
           return error_code;
        }

/*START OF PARSING RETURN MESSAGE*/
        i = move_number(reply_buffer, reply.length-2);
        memcpy(reply_buffer+i,reply.str+1,reply.length-2);
        reply.str = reply_buffer;

        parse_string(reply.str,header_and_message);

        /*
         * thoniyim - CR 7426 - 01/16/2004
         * Check the data from the host for message id.
         * Check if the message id of request and reply matches.
         */
 
        parse_string(header_and_message[1],header_strings);
 
        i = memcmp(header_array[2].field,
                   header_strings[2]+1,
                   header_array[2].field_size);
        if (i != 0)
        {
                strcpy(profile_reply,"Message Ids for the request and reply does
n't match. Disconnect and connect again.");
                return -1001;
        }
 
	parse_string(header_and_message[2],message_strings1);

        parse_string(message_strings1[2],message_strings2);

        num_size = sca_string_size (message_strings2[1], &offset);
 
     	if (num_size > 0)
        	if (num_size <= MAX_BYTE_VAL)
           		num_size--;
        	else
           		if (num_size <= MAX_WORD_VAL)
              			num_size -= 2;
            		else
              			if (num_size <= MAX_3BYTE_VAL)
                 			num_size -= 3;
              			else
                 			num_size -= 4;
 
        parse_string(message_strings2[1],message_strings1);
 
        memcpy(profile_reply,message_strings1[1],num_size);
 
        profile_reply[num_size]=0;

	return 0;

}/*END OF ProfileMRPC*/
/*-------------------------------------------------------------------*/
/*-------------------------------------------------------------------*/
int ProfileMRPC2 (const    unsigned char *message_token,
                  const    unsigned char *pmrpc_id,
                  const    unsigned char *(pmrpc_params[]),
                  unsigned char     *profile_reply,
                  unsigned char     *retry,
                  int      time_out)
{
        int error_code, i, j, k, x, y, z, num_size, offset;
        char request_buffer[MAX_MSG_SIZE], reply_buffer[MAX_MSG_SIZE];
        STR_DESCRIPTOR request, reply;
        unsigned char *(header_and_message[6]);
        unsigned char *(header_strings[6]);
        unsigned char *(message_strings1[1000]);
        unsigned char *(message_strings2[1000]);
        char pmrpc_params2[5000];
        char temps[3];
    
        memset (request_buffer,0,sizeof(request_buffer));
        memset (reply_buffer,0,sizeof(reply_buffer));
 
        request.str = request_buffer;
        reply.str   = reply_buffer;
        memset(pmrpc_params2,0,sizeof(pmrpc_params2));
        memset(temps,0,sizeof(temps));
        i=0;

        temps[0]=MRPC_DELIMITER;
        while (pmrpc_params[i] != 0) {
              strcat (pmrpc_params2,(char *)pmrpc_params[i++]);
              strcat (pmrpc_params2,temps);
 
        }

        error_code = pack_mrpc (&request,
                                pmrpc_id,
                                pmrpc_params2,
                                message_token,
                                retry);
 
/*DEAL WITH ERROR CODES HERE
        if (error_code != OK) {
           i = get_message_id (retry,FALSE);
           return error_code;
        }
*/
/*xyz*/
        k=0;
        logging (&request, "\nMRPC REQUEST SENT TO SERVER\n");

        ClExchmsg(4, &request, &reply, time_out, &k);
        logging (&reply, "\nSERVER RESPONSE TO MRPC REQUEST\n");

        error_code = error_check (k,CLMRPC,&reply,profile_reply);
        if (error_code != OK)
        {
           i = get_message_id (retry,FALSE);

           return error_code;
        }
/*START OF PARSING RETURN MESSAGE*/
        i = move_number(reply_buffer, reply.length-2);
        memcpy(reply_buffer+i,reply.str+1,reply.length-2);
        reply.str = reply_buffer;
 
        parse_string(reply.str,header_and_message);

	/*
	 * thoniyim - CR 7426 - 01/13/2004
	 * Check the data from the host for message id.
	 * Check if the message id of request and reply matches.
	 */

        parse_string(header_and_message[1],header_strings);
	
	i = memcmp(header_array[2].field,
		   header_strings[2]+1,
		   header_array[2].field_size);
	if (i != 0)
	{
		strcpy(profile_reply,"Message Ids for the request and reply doesn't match. Disconnect and connect again.");
		return -1001;
	}

        parse_string(header_and_message[2],message_strings1);

        parse_string(message_strings1[2],message_strings2);

        num_size = sca_string_size (message_strings2[1], &offset);
 
     if (num_size > 0)
        if (num_size <= MAX_BYTE_VAL)
           num_size--;
        else
           if (num_size <= MAX_WORD_VAL)
              num_size -= 2;
            else
              if (num_size <= MAX_3BYTE_VAL)
                 num_size -= 3;
              else
                 num_size -= 4;
 
        parse_string(message_strings2[1],message_strings1);
 
        memcpy(profile_reply,message_strings1[1],num_size);
 
        profile_reply[num_size]=0;

/*
        if (num_size > 0) {
            memcpy(profile_reply,message_strings1[2],num_size);
        }
        profile_reply[num_size]=0;
*/
        return 0;
 
}/*END OF ProfileMRPC2*/

/*--------------------------------------------------------------------------*/

unsigned char ProfileLogging (char *filename,
                     int   maxfilesize,
                     int   logging_on_off) {

        if (global_logging == logging_on_off)
            return LOGGING_PROBLEM;

	global_logging = logging_on_off;

        MAX_FILE_SIZE = maxfilesize;
	if (logging_on_off == LOGGING_ON) {           
           if ((fptr = fopen(filename, "r+")) == 0) {
               if ((fptr = fopen (filename, "w")) == 0) {  
	           global_logging = LOGGING_OFF; /*FILE OPEN FAILED, TURN LOGGING OFF AND PRINT MESSAGE*/
                   return LOGGING_PROBLEM;
               }
           }
           else {
                fseek(fptr, 0, SEEK_END);
           }
 
        }
        else {
                   fclose (fptr);        
        }
}
                     
void logging (STR_DESCRIPTOR *descriptor,
              char           *log_message) {

	char time_buff[30];

        time_t timeval;
        extern char *ctime();
	int ii;
/*      fpos_t mypos=0;
	fpos_t changing to long in Linux        thoniyim  04/18/2001 */
	long mypos=0;
	
        if (global_logging == LOGGING_OFF)
            return;

	memset(time_buff,0,sizeof(time_buff));
	time(&timeval);
        sprintf (time_buff, ctime(&timeval));

        
/*      ii = fgetpos (fptr, &mypos);
	fgetpos changed to ftell in Linux     thoniyim  04/18/2001 */
	mypos = ftell(fptr);
	if (mypos > MAX_FILE_SIZE) {
            rewind (fptr);
        }
/*IF LOG MESSAGE IS EMPTY, DO NOTHING*/
        if (log_message != NULL) {
            fprintf (fptr, "\n");
            fprintf (fptr, "%s  Time Stamp: %s", log_message, time_buff); 
            fprintf (fptr, "\n");
        }

/*IF DESCRIPTOR IS EMPTY, DO NOTHING*/
        if (descriptor == NULL)
            return;

	for (ii=0; ii<descriptor->length; ++ii)
        {
            fprintf (fptr, "%d ", descriptor->str[ii]);
            if (ii % 25 == 0 && ii != 0)
               fprintf (fptr, "\n");
        }

        fprintf (fptr, "\n");
	for (ii=0; ii<descriptor->length; ++ii)
        {
            if (descriptor->str[ii] < ' ' || descriptor->str[ii] > 126)
                fprintf (fptr, ".%d. ", descriptor->str[ii]);
            else
                fprintf (fptr, "%c ", descriptor->str[ii]);

            if (ii % 25 == 0 && ii != 0)
               fprintf (fptr, "\n");
        }

}
/*
---------------------------------------------------------------------
void set_debug (unsigned char on_or_off, unsigned char *filename)
{
        printf ("\nInside set_debug\n");
        if (on_or_off == 1) {
           if ( (fptr = fopen(filename, "ab+")) == 0)
              printf ("\nProblem opening file\n");
        }
 
        if (on_or_off == 0) {
           fclose (fptr);
        }
 
}

---------------------------------------------------------------------
void testit (unsigned char *buffer, int j, unsigned char *message)
{
	char time_buff[30];
	time_t timeval;
        extern char *ctime();
	int i;
	long mypos=0;

	memset(time_buff,0,sizeof(time_buff));
	time(&timeval);
        sprintf (time_buff, ctime(&timeval));

	mypos = ftell(fptr);

	if (mypos > MAX_FILE_SIZE) {
           rewind (fptr);
           printf ("\nRewind has been called %d\n", mypos);
        }
       
        fprintf (fptr, "%s  Time Stamp: %s", message, time_buff); 
        fprintf (fptr, "\n");
	for (i=0; i<j; ++i)
        {
            fprintf (fptr, "%d ", buffer[i]);
            if (i % 25 == 0 && i != 0)
               fprintf (fptr, "\n");
        }
 
        fprintf (fptr, "\n");
	for (i=0; i<j; ++i)
        {
            fprintf (fptr, "%d ", buffer[i]);
            if (i % 25 == 0 && i != 0)
               fprintf (fptr, "\n");
        }
}
---------------------------------------------------------------------
void testit2 (unsigned char *buffer, int j)
{
	int i;

        fprintf (fptr, "\n");
	for (i=0; i<j; i++)
        {
            fprintf (fptr, "%c ", buffer[i]);
            if (i % 30 == 0 && i != 0)
               fprintf (fptr, "\n");
        }
}
*/
