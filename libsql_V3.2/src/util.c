/*
	Updates
	-------

      -	Updated the parse_string to handle the length > 255 problem. If the 
	length of the data is greater than 255, then it'll add 2 bytes to the 
	existing value.

	thoniyim	08/10/2001

*/

#include "libsql.h"
#include <time.h>
#include <signal.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
/*#define MRPC_DELIMITER '?'*/
#define MESSAGE_ID_SIZE 12
#define MAX_FILE_SIZE 250000

extern void logging (STR_DESCRIPTOR *descriptor,
              char           *log_message);

static unsigned char line[80];

unsigned char const MYSERVER_TYPE[]="SCA$IBS";
/*unsigned char const MYSERVER_TYPE[]="SCA$MKT";*/
/*unsigned char const MYSERVER_TYPE[]="SCA$CHA";*/

unsigned char const ISIZE=sizeof(int);
const unsigned char HIGH_NUMBER_IN_LOW_ADDRESS = TRUE;
unsigned char file_name[]="/tmp/libsql.log";
FILE *fptr, *tptr;
unsigned char DEBUGGING=FALSE;
static int mypid=0;
static unsigned char mid[MESSAGE_ID_SIZE+1];

unsigned char first_time = TRUE;
unsigned char table_name[]="/SCA/sca_gtm/libsql/mrpc_table.txt";
int mrpc_table_size;
#define MRPC_MAX_TABLE_SIZE 200
typedef struct {
	         unsigned char mrpc_number[13];
                 unsigned char mrpc_version_number[13];                  
               } mrpc_struct_type;

mrpc_struct_type mrpc_table[MRPC_MAX_TABLE_SIZE];

/*---------------------------FUNCTIONS AND MACROS--------------------*/
void signal_catcher (int signal) {

printf ("\nLibrary libsql.a received a signal 11, SEGV from kernel.");
printf ("\nMost likely cause is improperly terminated or structured");
printf ("\nstring passed to library, causing a memory fault. Check");
printf ("\nstructure of strings passed to libsql.a.\n");
printf ("\nProgram exiting now");

exit(1);
}
/*-------------------------------------------------------------------*/

int get_string_size (unsigned char *string, unsigned char delimiter)
{
	int string_size;

	signal(11, signal_catcher);
	string_size = 0;
	while (string[string_size] != delimiter &&string_size<MAX_STRING_SIZE)
		string_size++;

	if (string_size < MAX_STRING_SIZE)
	   return string_size;
	else
	   return -1;	    
}
/*-------------------------------------------------------------------*/
setup_token (unsigned char *string, unsigned char *token_holder)
{
	int token_size, offset, i;

	token_size = sca_string_size(string, &offset);
	memcpy(token_holder,string+offset,token_size-1);
	token_holder[token_size-1] = '\0';
}
/*-------------------------------------------------------------------*/
int get_number_size (int number)
{
	if (number + 1 <= MAX_BYTE_VAL)
           return 1;
        else
           if (number + 2 <= MAX_WORD_VAL)
              return 2;
           else
              if (number + 3 <= MAX_3BYTE_VAL)
                 return 3;
              else
                 return 4;
}

/*-------------------------------------------------------------------*/
int move_number(unsigned char *ptr, int number)
{
	int temp_number, the_size, temp_num;
        int address_offset, shift, i;
        unsigned char *temp_ptr;
        unsigned char byte_array[4];

	if (number <= MAX_BYTE_VAL)
           the_size = 1;
	else
	   if (number <= MAX_WORD_VAL)
	      the_size = 2;
	   else
              if (number <= MAX_3BYTE_VAL)
		 the_size = 3;
              else /*number is 4 bytes long*/
                 the_size = 4;

	if (the_size == 1) {
           *ptr = number;
           return 1;
        }
        else {
             temp_ptr = ptr;
	     *temp_ptr = 0;
             temp_ptr++;
             *temp_ptr = the_size;
             temp_ptr++;
	     temp_num = number;
	     for (i = 0; i < the_size; i++) {
                  byte_array[i] = temp_num % 256;
                  temp_num /= 256;
	     }
             for (i = (the_size-1); i >= 0; i--) {
                 *temp_ptr = byte_array[i];
                 temp_ptr++;
             }
             return (the_size + 2); 
	}/*END OF ELSE*/
}
/*-------------------------------------------------------------------*/
/*-------------------------------------------------------------------*/
SLONG error_check (int  error_code,
                   int  what_to_do,
                   STR_DESCRIPTOR *server_message,
                   char *reply)
{
        int  value, i, j, k, num_size, size, error_size;
        unsigned char buffer[MAX_MSG_SIZE], string_num[9];
        unsigned char bufferx[MAX_MSG_SIZE];
        char *(header_and_message[3]);
        char *(hold_header[5]);
        char *(hold_message1[2000]);
        char *(hold_message2[2000]);
        char *(hold_message3[2000]);
        char *(error_condition[5]);
	int  msgType = 0;

        if (error_code != OK) 
        {
           switch (what_to_do)
           {
                case CLCONNECT : value = PROBLEM1; 
                                 strcpy(reply,"CS_NOMTM");
                                 break;
                case CLLOGIN   : value = PROBLEM2;
                                 strcpy(reply,"CS_NOSVTYP");
                                 break;
 	        case CLSQL     : value = error_code;
                                 strcpy (reply,"ERRORCS_SRV_TO");
                                 break;
                default        : value = error_code;
                                 strcpy (reply,"LIBSQL - UNKNOWN ERROR");
                                 break;
           }/*SWITCH STATEMENT ENDS*/
 
           return value;
        }/*IF STATEMENT ENDS*/

        if (what_to_do == CLCONNECT)
           return ok;

        /*CHECK TO SEE IF HEADER HAS ANY OBVIOUS PROBLEMS*/
        if (server_message->str[0] != ZERO           ||
            server_message->str[1] < MIN_HEADER_SIZE ||
            server_message->str[1] > MAX_HEADER_SIZE) {

              value = 1; /*GENERAL SANCHEZ ERROR*/
              strcpy (reply,"LIBSQL - MESSAGE HEADER CORRUPTED");
              return value;
        }

/*SETUP THE MESSAGE FOR INITIAL PARSING BY WRAPPING A SIZE AROUND IT*/
        num_size = get_number_size(server_message->length-2);
        i = move_number(buffer, server_message->length-2);
        memcpy(buffer+i,server_message->str+1,server_message->length-2);
 
/*GET THE HEADER AND THE MESSAGE*/
        parse_string(buffer,header_and_message);
/*BREAK THE HEADER APART*/
        parse_string(header_and_message[1],hold_header);
        parse_string(hold_header[3],error_condition);
        parse_string (header_and_message[2],hold_message1);

        parse_string (hold_message1[2],hold_message2);
        if (error_condition[1][0] == ZERO){
           if (what_to_do == CLSQL) {
	      memset(string_num,0,sizeof(string_num));
              i = hold_message2[1][0];
              if (i == 0)
                 return OK_BUT_EMPTY_MESSAGE_BODY;
	      memcpy(string_num,(char *)&(hold_message2[1][1]),i-1);

	      i = atoi((char *)string_num);
              /*i=OK;*/
	      return i;
	     }
             else   
	        return OK;
	}

        error_size = (char)hold_message2[3][0];
        if (error_size == 0) {
	    if(hold_message2[3][1] == 0) {
            	strcpy (reply,"LIBSQL - UNKNOWN ERROR");
            	return 1;
	    }
	    else {
		error_size = (int)hold_message2[3][2] * 256 + 
					(int)hold_message2[3][3] + 2;
		msgType = 1;
	    }
        }

	if(!msgType) {
        	memcpy(&reply[0],(char*)&(hold_message2[3][1]),error_size-1);
	} else {
        	memcpy(&reply[0],(char*)&(hold_message2[3][4]),error_size-4);
		error_size = error_size - 3;
	}

       	reply[error_size-1] = '|';/*AGREED UPON SEPARATOR*/
        memcpy(&reply[error_size],
               (char*)&(hold_message2[5][1]),
               (char)hold_message2[5][0]);

        error_size += (char)hold_message2[5][0];

        reply[error_size] = 0;
        return PROBLEM3;/*THAT IS, SANCHEZ HOST ERROR*/
 
/*return OK;*/
 
}
/*-------------------------------------------------------------------*/
int get_message_id(unsigned char *ascii_message_id, unsigned char what_to_do)
{
time_t *time1, time2;
int  *pid, pid2, i, j, k, *message_id;


	pid2 = getpid();
	if (pid2 != mypid) {
	   memset(mid,0,sizeof(mid));
	   mypid = pid2;
	   time1 = (time_t *) &mid[0];	
	   pid   = (int *)  &mid[4];
	   *time1 = time(&time2);
	   *pid   = pid2;
	}

	if (what_to_do == TRUE) {
	   message_id = (int *) &mid[8];
	   (*message_id)++;
	}

	memcpy (ascii_message_id,mid,MESSAGE_ID_SIZE);

	return MESSAGE_ID_SIZE;
}
/*-------------------------------------------------------------------*/
void setup_header (MESSAGE_TYPE which_action, 
                   unsigned char *the_token, 
                   unsigned char *retry)
{

	unsigned char store_or_forward;

	memset(header_array,0,sizeof(header_array));
	
        header_array[msg_id].field_in_use = TRUE;
	if (retry[0] != 0)
        {
	   store_or_forward = ONE;
/*
	   header_array[msg_id].field_size = get_string_size(retry,0);
ORIGINAL IN CORRECT VALUE. FULL MESSAGE ID IS 12. SINCE IT CONTAINS BINARY
0 WE CANNOT USE METHOD ABOVE.
*/
	   header_array[msg_id].field_size = MESSAGE_ID_SIZE;

           memcpy(header_array[msg_id].field,retry,header_array[msg_id].field_size);
        }
        else
        {
	    store_or_forward = ZERO;
            header_array[msg_id].field_size =
            get_message_id(header_array[msg_id].field,TRUE);
        }

        if (which_action == MRPC) {
	        header_array[srv_cls].field_size = 1;
                header_array[srv_cls].field[0]   = SERV_CLASS_MRPC;
                header_array[srv_cls].field_in_use = TRUE;

		header_array[token].field_size   = 
                       get_string_size(the_token,0);
                memcpy(header_array[token].field,
		       the_token,
                       header_array[token].field_size);
                header_array[token].field_in_use = TRUE;
		
                header_array[stf_flg].field_size = 1;
                header_array[stf_flg].field[0]   = store_or_forward;
                header_array[stf_flg].field_in_use = TRUE;

		header_array[grp_recs].field_size = 0;
                header_array[grp_recs].field[0]   = 0;
                header_array[grp_recs].field_in_use = TRUE;
	}

	if (which_action == SQL || which_action == RETRY)
	{
	        header_array[srv_cls].field_size = 1;
                header_array[srv_cls].field[0]   = SERV_CLASS_SQL;
                header_array[srv_cls].field_in_use = TRUE;

		header_array[token].field_size   = 
                       get_string_size(the_token,0);
                memcpy(header_array[token].field,the_token,header_array[token].field_size);
                header_array[token].field_in_use = TRUE;
		
                header_array[stf_flg].field_size = 1;
                header_array[stf_flg].field[0]   = store_or_forward;
                header_array[stf_flg].field_in_use = TRUE;

		header_array[grp_recs].field_size = 0;
                header_array[grp_recs].field[0]   = 0;
                header_array[grp_recs].field_in_use = TRUE;
	}
	if (which_action == SIGNON || which_action == SIGNOFF)
	{ 
		header_array[srv_cls].field_size = 1;
                header_array[srv_cls].field[0]   = SERV_CLASS_SIGNON;
                header_array[srv_cls].field_in_use = TRUE;

		header_array[token].field_size   = 0;
		header_array[token].field[0]     = 0;
                header_array[token].field_in_use = TRUE;
		
                header_array[stf_flg].field_size = 1;
                header_array[stf_flg].field[0]   = ZERO;
                header_array[stf_flg].field_in_use = TRUE;

		header_array[grp_recs].field_size = 0;
                header_array[grp_recs].field[0]   = 0;
                header_array[grp_recs].field_in_use = TRUE;

	}

}
/*-------------------------------------------------------------------*/
void setup_signon(unsigned char *param_user_id, 
		  unsigned char *password, 
		  unsigned char *mtm_address,
		  unsigned char *tlo)
{
	/*unsigned char context_string[]=" 5\7FORMAT\5EDGE";*/
	
/*unsigned char context_string[]="  5\7FORMAT\5EDGE\6ICODE 1 PREPARE 3";*/
unsigned char context_string[]="  5\6ICODE 1 PREPARE 3";

	context_string[0]=21;
	context_string[1]=2;
	context_string[9]=2;
	context_string[11]=8;
	context_string[19]=2;
/*
	context_string[0]=33;
	context_string[1]=2;
	context_string[21]=2;
	context_string[23]=8;
	context_string[31]=2;
*/
        memset(signon_array,0,sizeof(signon_array));

	signon_array[srv_prc].field_size = 1;
        signon_array[srv_prc].field[0]   = '1';
        signon_array[srv_prc].field_in_use = TRUE;

        signon_array[user_id].field_size =
               get_string_size((unsigned char *)param_user_id,0);
        memcpy(signon_array[user_id].field,param_user_id,signon_array[user_id].field_size);
        signon_array[user_id].field_in_use = TRUE;

/*No value given for tlo, use default*/
	if (tlo == 0)
	{
		signon_array[stn_id].field_size =
                get_string_size(mtm_address,0); /*Use mtm_address as deflt*/
                memcpy(signon_array[stn_id].field,mtm_address,
                signon_array[stn_id].field_size);
                signon_array[stn_id].field_in_use = TRUE;
	
	}
	else /*Value given for tlo, use it*/
	{
		signon_array[stn_id].field_size =
		get_string_size(tlo,0); /*Use real value of tlo as passed*/
                memcpy(signon_array[stn_id].field,tlo,
                signon_array[stn_id].field_size);
                signon_array[stn_id].field_in_use = TRUE;
  
	}

	signon_array[user_pwd].field_size = 
	      get_string_size(password,0);
        memcpy(signon_array[user_pwd].field,password,signon_array[user_pwd].field_size);
        signon_array[user_pwd].field_in_use = TRUE;
	
	signon_array[inst_id].field_size = 0;
        signon_array[inst_id].field_in_use = TRUE;

        signon_array[fap_ids].field_size = 0;
        signon_array[fap_ids].field_in_use = TRUE;
/*
        signon_array[context].field_size = 14;
        signon_array[context].field_in_use = TRUE;
	memcpy(signon_array[context].field,context_string,14);
*/
        signon_array[context].field_size = 21;
        signon_array[context].field_in_use = TRUE;
	memcpy(signon_array[context].field,context_string,21);
	
/*
        signon_array[7].field_size = 5;
        signon_array[7].field_in_use = TRUE;
	memcpy(signon_array[7].field,"ICODE",5);
	
        signon_array[8].field_size = 1;
        signon_array[8].field_in_use = TRUE;
	memcpy(signon_array[8].field,"1",1);

        signon_array[9].field_size = 7;
        signon_array[9].field_in_use = TRUE;
	memcpy(signon_array[9].field,"PREPARE",7);

        signon_array[10].field_size = 1;
        signon_array[10].field_in_use = TRUE;
	memcpy(signon_array[10].field,"1",1);

        signon_array[context].field_size = 0;
        signon_array[context].field_in_use = TRUE;
	signon_array[context].field[0]=0;	
*/
}

/*-------------------------------------------------------------------*/
void setup_mtm_header ()
{
	int size;

	mtm_header[mtm_message_size].field[0]   = 0;
        mtm_header[mtm_message_size].field_size = 2;

	mtm_header[server_type].field_size = sizeof(MYSERVER_TYPE)-1;
	memcpy(mtm_header[server_type].field,MYSERVER_TYPE,sizeof(MYSERVER_TYPE));

	mtm_header[separator].field_size = 1;
        mtm_header[separator].field[0]   = FS;

}

/*-------------------------------------------------------------------------*/
int compact_mtm_header (unsigned char *caller_buffer)
{
        int total_size = 0;
        unsigned char *request_buffer;

	request_buffer = caller_buffer;

    /*    memcpy(request_buffer,mtm_header[mtm_message_size].field,
               mtm_header[mtm_message_size].field_size);
        request_buffer += mtm_header[mtm_message_size].field_size;
        total_size += mtm_header[mtm_message_size].field_size;
*/
        memcpy(request_buffer,mtm_header[server_type].field,
               mtm_header[server_type].field_size);
        request_buffer += mtm_header[server_type].field_size;
        total_size += mtm_header[server_type].field_size;

        memcpy(request_buffer,mtm_header[separator].field,mtm_header[separator].field_size);
        request_buffer += mtm_header[separator].field_size;
        total_size += mtm_header[separator].field_size;

	return total_size;
}
/*-------------------------------------------------------------------*/
/*
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

}*/
/*-------------------------------------------------------------------*/
/*-------------------------------------------------------------------*/
int get_struc_size (field_structure_type *struc_array)
{
	int i, j=0, size=0;

        i = 0;
        while (struc_array[i].field_in_use == TRUE)
        {
           j = struc_array[i].field_size +
                      get_number_size (struc_array[i].field_size);
           if (j <= MAX_BYTE_VAL)
              size += j;
           else
              size += j + 2;

           i++;
        }

	return size;
}
/*-------------------------------------------------------------------*/
void pack_array (unsigned char **buffer, field_structure_type *array)
{
	int i, temp_int, offset;

        i = 0;
        while (array[i].field_in_use == TRUE)
        {        
	   temp_int = array[i].field_size +
                      get_number_size (array[i].field_size);
	   offset = move_number(*buffer,temp_int);
           *buffer += offset;
           memcpy (*buffer,
                   array[i].field,
                   array[i].field_size);    
           *buffer += array[i].field_size;
           i++;
        }
 
}
/*-------------------------------------------------------------------*/
int pack_struc_size (unsigned char **buffer, field_structure_type *array)
{
	int i, offset;

	i = get_struc_size(array);
        i += get_number_size(i);
        offset = move_number(*buffer,i);
        *buffer += offset;

	return i;
}
/*-------------------------------------------------------------------*/
int   setup_login_request (STR_DESCRIPTOR *caller_buffer,
 			   unsigned char *param_user_id,
			   unsigned char *password,
			   unsigned char *mtm_address,
			   unsigned char *tlo)
{
        int temp_int, i, j, k, save_number;
        unsigned short message_size=0;
        unsigned char *request_buffer;
        unsigned char the_retry[1];

	request_buffer = (unsigned char *)caller_buffer->str;
 
        setup_mtm_header ();
        the_retry[0]=0;
	setup_header (SIGNON,(unsigned char*)0,the_retry);
	setup_signon(param_user_id,password,mtm_address,tlo);
  
/*COMPACT MTM HEADER*/
	i = compact_mtm_header (request_buffer);
        request_buffer += i;
        message_size += i;
        
/*get_header_size*/
        message_size += pack_struc_size(&request_buffer,header_array);
/*Move in header*/	
	pack_array (&request_buffer, header_array);

/*get signon size*/
        message_size += pack_struc_size(&request_buffer,signon_array);
/*Move in signon record*/
	pack_array(&request_buffer, signon_array);

/*Send back the length of the overall string, i.e. message*/
        caller_buffer->length=message_size;

}
/*-------------------------------------------------------------------*/
int pack_sql(STR_DESCRIPTOR *request,
	     unsigned char *sql_message,
             unsigned char *sql_qualifiers,
	     unsigned char *the_token,
             unsigned char *retry)
{
	int message_size=0, i=0;
        unsigned char *request_buffer;

	memset (sql_string,FALSE,sizeof(sql_string));

        request_buffer = (unsigned char *)request->str;
        setup_mtm_header ();
        setup_header (SQL,the_token,retry);
 
/*COMPACT MTM HEADER*/
        i = compact_mtm_header (request_buffer);
        request_buffer += i;
        message_size += i;

        message_size += pack_struc_size(&request_buffer,header_array);
       /*Move in header*/
        pack_array (&request_buffer, header_array);

	sql_string[sqlstmt].field_in_use = TRUE;
	sql_string[sqlstmt].field_size   = get_string_size(sql_message,0);
        memcpy(sql_string[sqlstmt].field,sql_message,sql_string[sqlstmt].field_size);

	sql_string[qualifiers].field_in_use = TRUE;
	sql_string[qualifiers].field_size = get_string_size(sql_qualifiers,0);
        memcpy(sql_string[qualifiers].field,sql_qualifiers,sql_string[qualifiers].field_size);

	sql_string[spv].field_in_use = TRUE;
	sql_string[spv].field_size   = 0;
	sql_string[spv].field[0]     = 0;

        message_size += pack_struc_size(&request_buffer,
                       (field_structure_type*)sql_string);
        pack_array (&request_buffer,
                    (field_structure_type*)sql_string);

	request->length = message_size;
/*pack_sql(&request,sql_message,sql_qualifiers);*/

	
}
/*-------------------------------------------------------------------*/
void check_for_delim (unsigned char *mrpc) {
/*THIS FUNCTION CHECKS TO SEE IF AN MRPC DELIMITER CHAR IS PLACE AT THE
VERY END OF THE PARAMS STRING, RIGHT BEFORE THE NULL TERMINATOR. IF IT
IS NOT THERE THE FUNCTION ADDS IT. THIS IS DONE AS A CONVENIENCE FOR THE
CALLER SINCE MANY CALLERS FORGET TO PLACE THE FINAL DELIMITER AT THE
END OF THE MRPC STRING */

	int ii=0;
        char add_mrpc[2];
        add_mrpc[0] = MRPC_DELIMITER;
        add_mrpc[1] = 0;

	while (mrpc[ii] != 0)
		ii++;
	if (mrpc[ii-1] != MRPC_DELIMITER) {
               strcat ((char *)mrpc,(char *)add_mrpc);

        }            
}
/*-------------------------------------------------------------------*/

int pack_mrpc (STR_DESCRIPTOR *request,
	       unsigned char  *id,
	       unsigned char  *params,
	       unsigned char  *the_token,
               unsigned char  *retry)
{
	int message_size=0, i=0, k=0, l=0, m=0, n=0, the_field=0;
        unsigned char *request_buffer, *temp_ptr;
	unsigned char still_parsin, version[12], stop;
        field_structure_type temp_field[50];

        check_for_delim(params);
        request_buffer = (unsigned char *)request->str;
        setup_mtm_header ();
        setup_header (MRPC,the_token,retry);
      
/*COMPACT MTM HEADER*/
        i = compact_mtm_header (request_buffer);
        request_buffer += i;
        message_size += i;

        message_size += pack_struc_size(&request_buffer,header_array);
       /*Move in header*/
        pack_array (&request_buffer, header_array);

/*START OF MRPC SPECIFIC STUFF*/
	if ((mrpc_string = (mrpc_type *)malloc(sizeof(mrpc_type))) == NULL) {
	   printf ("\nCannot malloc memory for mrpc_string: %d", errno);
           exit(1);
        }
	memset (mrpc_string, FALSE, sizeof(mrpc_type));

/*PACK MRPC_ID*/
	 (*mrpc_string)[mrpc_id].field_in_use = TRUE;
	 (*mrpc_string)[mrpc_id].field_size   = get_string_size(id,0);
	 memcpy((*mrpc_string)[mrpc_id].field,
                 id,
                (*mrpc_string)[mrpc_id].field_size);

/*LOAD AND PACK THE MRPC INFO*/
/*LOAD THE MRPC TABLE IF IT HAS NOT BEEN LOADED YET*/
        if (first_time == TRUE) {/*IF A*/
           first_time = FALSE;
	   if ((tptr = fopen((char *)table_name,"r")) == NULL) {
               printf ("\nFILE OPEN FAILED");
                logging (NULL,"\nWARNING -- CANNOT OPEN MRPC TABLE");
                logging (NULL, "\nLIBSQL WILL USE A DEFAULT VERSION OF 1 FOR ALL MRPC CALLS\n");
	       /*return CANNOT_OPEN_TABLE; */
           }
/*READ IN AND PARSE THE INFO IN THE TABLE*/
	   i=0;
           if (tptr != 0) {/*IF B*/
              while (fgets((char *)line,80,tptr) != NULL) {
	  	    k=get_string_size(line,TAB);
	 	    memcpy(mrpc_table[i].mrpc_number,line,k);
		    mrpc_table[i].mrpc_number[k]=0;
		    m = get_string_size(&line[k+1],0);
		    m--;
	 	    memcpy(mrpc_table[i].mrpc_version_number,&line[k+1],m);
		    mrpc_table[i].mrpc_version_number[m]=0;
                    i++; 

	     }
	     fclose(tptr);
           }/*IF B ENDS*/
           mrpc_table_size = i;
        }/*END OF IF A*/

/*FIND THE MRPC ID THAT HAS BEEN PASSED IN THE TABLE, IF NOT FOUND
RETURN AN ERROR*/
	version[0]=0;
	for (i = 0; i < mrpc_table_size; i++) {
	    if ( (memcmp(mrpc_table[i].mrpc_number,
                 id,
                 get_string_size(id,0))) == 0) {
                 memcpy(version,
                        mrpc_table[i].mrpc_version_number,
			get_string_size(mrpc_table[i].mrpc_version_number,0)+1);
                break;  
          }
        }
/*THE MRPC ID PASSED IS NOT IN THE TABLE, USE A DEFAULT VERSION OF 1*/
	if (i == mrpc_table_size) {
	   /*MRPC ID NOT FOUND USE A DEFAULT VERSION OF 1*/
           memcpy(version,
                  "1",
	           sizeof("1"));

        }
	(*mrpc_string)[mrpc_version].field_in_use = TRUE;
	(*mrpc_string)[mrpc_version].field_size  = get_string_size(version,0);
	memcpy((*mrpc_string)[mrpc_version].field,
	       version,
               (*mrpc_string)[mrpc_version].field_size);

/*MRPC PARAMS*/
/*PARSE THE PARAMS FIRST*/

memset (temp_field,FALSE,sizeof(temp_field));
i = 0;
the_field = 0;
stop = FALSE;

while (stop != TRUE) {
	k = get_string_size(&params[the_field],MRPC_DELIMITER);
        temp_field[i].field_in_use = TRUE;
	temp_field[i].field_size   = k;

	memcpy (temp_field[i].field,
                (unsigned char *)&params[the_field],
                k);
	the_field += k + 1;
	if (params[the_field] == 0)
           stop = TRUE;

	i++;	
	
}
/* END OF PARSING*/
	/*temp_ptr = (*mrpc_string)[mrpc_param1].field;*/

	k = get_struc_size(temp_field);

	temp_ptr = (*mrpc_string)[mrpc_param1].field;

	pack_array (&temp_ptr, temp_field);
	(*mrpc_string)[mrpc_param1].field_in_use = TRUE;
        (*mrpc_string)[mrpc_param1].field_size = k+2;

        message_size += pack_struc_size(&request_buffer,
                       (field_structure_type*)mrpc_string);
        pack_array (&request_buffer,
                    (field_structure_type*)mrpc_string);

	request->length = message_size;
	free(mrpc_string);

	return ok;
}
/*-------------------------------------------------------------------*/
int sca_string_size (unsigned char *string, int *offset)
{
	unsigned char the_size=0;
        unsigned char *temp_ptr;
	int  temp=0, i;
	char debugStr[3];
	if (string == NULL)
		return 0;
	temp_ptr = string;
	memset (debugStr, 0, 3);
	debugStr[1] = *(string + 2);
	debugStr[0] = *(string + 1);
	if (*string != (unsigned char) 0)
        {
		*offset = 1;
		return (unsigned char)*string;
	}
	else
	{	
		temp_ptr++; 
		the_size = (unsigned char)*temp_ptr;
		temp_ptr++;
		temp=0;
		for (i=0; i<the_size; i++) {
		    temp *= 256;
		    temp += *temp_ptr;
		    temp_ptr++;	
		}
		*offset = the_size+2;
		return temp;
/*
memcpy((unsigned char*)(&temp)+((the_size-ISIZE)*-1),temp_ptr,the_size);
		*offset = the_size+2;
		return temp;*/
	}
}

/*-------------------------------------------------------------------*/
int parse_string(unsigned char *string, unsigned char **array)
{
	int i=0, j=0, k=0, offset=0, total_size=0, size_so_far=0;
	unsigned char *temp_string;

	temp_string = string;
	j = sca_string_size(string, &offset);
	total_size = j - get_number_size(j);
	temp_string += offset;
	i=1;

	while (size_so_far < total_size)
	{
		array[i++] = temp_string;
		j = sca_string_size(temp_string,&offset);
/*  	
	if the data size is greater than 255, then add 2 to the original value
    	This may need to be fixed at the server side, as we get the message 
	length from the host  
	
	thoniyim	08/10/2001 
*/
		if (j > 255)
			j += 2;
		temp_string += j;
		size_so_far += j;
	}

	array[0] = (unsigned char*)(i - 1);
	return i - 1;
}

/*-------------------------------------------------------------------*/
int setup_signoff(STR_DESCRIPTOR *request, unsigned char *the_token)
{
	int message_size=0, i=0;
        unsigned char *request_buffer;
        unsigned char the_retry[1];

	memset(signoff_array,FALSE,sizeof(signoff_array));

	signoff_array[srv_prc_off].field_size = 1;
	signoff_array[srv_prc_off].field[0] = '0';
	signoff_array[srv_prc_off].field_in_use = TRUE;

	signoff_array[token_off].field_in_use = TRUE;
	signoff_array[token_off].field_size = get_string_size(the_token,0);
	memcpy(signoff_array[token_off].field,the_token,
	       signoff_array[token_off].field_size);

        request_buffer = (unsigned char *)request->str;
        setup_mtm_header ();
	the_retry[0]=0;
        setup_header (SIGNOFF,the_token,the_retry);

/*COMPACT MTM HEADER*/
        i = compact_mtm_header (request_buffer);
        request_buffer += i;
        message_size += i;

        message_size += pack_struc_size(&request_buffer,header_array);
       /*Move in header*/
        pack_array (&request_buffer, header_array);

        message_size += pack_struc_size(&request_buffer,
                       (field_structure_type*)signoff_array);
        pack_array (&request_buffer,
                    (field_structure_type*)signoff_array);

	request->length = message_size;

}

char * version () {
        return VERSION;
}

/******************************************************************************
Function Name : long CleanUpSQLStmt (const char* a_sSQLStmt, long a_lSQLStmt,i
			char* a_sOutputSQLStmt, long *a_lOutputSQLStmt) 

Argument      :	a_sSQLStmt-> Input SQL Statement to be cleaned
		a_lSQLStmt-> Length of the Input SQL Statement
		a_sOutputSQLStmt -> The Ouptut SQL statement after cleaning
		a_lOutputSQLStmt -> The Length of the output SQL statement

Return	      :	1  - SUCCESS
		-1 - Conversion Error
					
Comments      :	This Functions searches the SQL statement for tab,CR,space and
		NULL characters and removes it. Once it is cleaned it converts 
		everything to uppercase without changing the literal constants.
*****************************************************************************/
long CleanUpSQLStmt (const char* a_sSQLStmt, long a_lSQLStmt, 
			char* a_sCleanedSQLStmt,long *a_lCleanedSQLStmt) 
{
	unsigned int iHVIndex = 0, iSqlIndex = 0, iOutputSqlIndex = 0, nLen = 0;
	char	checkStr[5]   = "\"\r\t\n";
	char	quote[2] = "'", space[2] = " ",comma[2] = ",";
	int	bSnglQuote = 1, bSpace = 1;
	char	*lpsExecute = NULL, *tokens = NULL;
	

	if (NULL == a_sSQLStmt || 0 == a_lSQLStmt ||
	    NULL == a_sCleanedSQLStmt || NULL == a_lCleanedSQLStmt) {
		return -1;
	}

	/* For EXECUTE don't trim the double quotes from the sql. */
	tokens = (char *)strstr(a_sSQLStmt, " ");
	nLen = tokens - a_sSQLStmt;
	lpsExecute	= (char *) calloc(nLen + 1,1);
	if(NULL == lpsExecute)
		return -1;
	strncpy(lpsExecute,a_sSQLStmt,nLen);
	
	if(strcasecmp(lpsExecute,"EXECUTE") == 0)
		strcpy(checkStr,"\r\t\n");
	free(lpsExecute);
 			
	while ((int)iSqlIndex <= a_lSQLStmt)
	{
	  if ((int)iSqlIndex == *a_lCleanedSQLStmt) {
		return -2;
 	  }
	  if(strchr(quote, a_sSQLStmt[iSqlIndex]) != NULL) {
		while(bSnglQuote)
		{
			a_sCleanedSQLStmt[iOutputSqlIndex] = 
						a_sSQLStmt[iSqlIndex];
		  	iSqlIndex++;
			iOutputSqlIndex++;
			if(strchr(quote, a_sSQLStmt[iSqlIndex]) != NULL) {
				a_sCleanedSQLStmt[iOutputSqlIndex] = 
						a_sSQLStmt[iSqlIndex];
				iSqlIndex++;
				iOutputSqlIndex++;
				bSnglQuote = 0;
			}
		}
		bSnglQuote = 1;
	}
		/* Check for junk character */
	else if (strchr(checkStr, a_sSQLStmt[iSqlIndex]) != NULL) {
		if((int)a_sSQLStmt[iSqlIndex] == 13 && 
			(int)a_sSQLStmt[iSqlIndex + 1] == 10) {
			a_sCleanedSQLStmt[iOutputSqlIndex] = space[0];
			iOutputSqlIndex++;
		}
		iSqlIndex++;
	}
	else
	{
		if(strchr(space,a_sSQLStmt[iSqlIndex]))
		{
			while(bSpace)
			{	/* Check Space */
				if((int)a_sSQLStmt[iSqlIndex + 1] == 32) 
				{
					iSqlIndex++;
				}
				else if(strchr(comma,a_sSQLStmt[iSqlIndex + 1]) 							!= NULL) 
				{ 
					iSqlIndex++;
					bSpace = 0;
				}
				else
					bSpace = 0;
				}
				bSpace = 1;
			}

			if(islower(a_sSQLStmt[iSqlIndex]))
			{
				a_sCleanedSQLStmt[iOutputSqlIndex] = 
						_toupper(a_sSQLStmt[iSqlIndex]);
				iSqlIndex++;
				iOutputSqlIndex++;
			}
			else
			{
				a_sCleanedSQLStmt[iOutputSqlIndex] = 
						a_sSQLStmt[iSqlIndex];
				iSqlIndex++;
				iOutputSqlIndex++;
			}

			/* Check if there is space after copying comma */
			if(strchr(comma,a_sCleanedSQLStmt[iOutputSqlIndex-1])
							!= NULL)
			{
				while(bSpace)
				{	/* Check Space */
					if((int)a_sSQLStmt[iSqlIndex] == 32) 
					{
						iSqlIndex++;
					}
					else
						bSpace = 0;
				}				
				bSpace = 1;
			}
		}
	}
	*a_lCleanedSQLStmt = strlen(a_sCleanedSQLStmt);
	return 1;
}

void HandleHostVariable (
	const char* a_sWhereClause, 
	unsigned int *a_iWhereIndex,
	char* a_sOutputWhereClause, 
	unsigned int *a_iOutputWhereIndex,
	char* a_sOutputUsingQualifier, 
	unsigned int *a_iHVIndex) 

{
	int iWhereIndex = *a_iWhereIndex;
	int iOutputWhereIndex = *a_iOutputWhereIndex;
	int iLiteralIndex = 0;
	int iNotDone = 1;
	char sLiteral[32 * 1024], sHV[1000];
	char *sOutputUsingQualifier = (char *)calloc(320000,1); 

	memset (sLiteral, 0, 32 * 1024);
	memset (sHV, 0, 1000);
	/*skip leading spaces*/
	while (isspace (a_sWhereClause[iWhereIndex]))
	{
		iWhereIndex++;
	}
	/*check if it is a literal*/
	if (a_sWhereClause[iWhereIndex] == '\'' ||
		isdigit (a_sWhereClause[iWhereIndex]) ||
		a_sWhereClause[iWhereIndex] =='-')
	{
		if (a_sWhereClause[iWhereIndex] == '\'')
		{
			sLiteral[iLiteralIndex] = a_sWhereClause[iWhereIndex];
			iLiteralIndex++;
			iWhereIndex++;
			iNotDone = 1;
			
			/*SLC - Since host don't like literal having '' to be 
			converted into host variable if we find one, we skip.*/

			if(a_sWhereClause[iWhereIndex] == '\'')
			{
				free(sOutputUsingQualifier);
				return;
			}
			while (iNotDone)
			{
				if (a_sWhereClause[iWhereIndex] == '\'')
				{
					if (a_sWhereClause[iWhereIndex + 1] 
								!= '\'')
					{
						iNotDone = 0;
					}
					else
					{
	/*this is so that we can copy both the single quotes
	in one pass and don't fall in the previous if for
	the second single quote.*/
						sLiteral[iLiteralIndex] = 
						a_sWhereClause[iWhereIndex];
						iLiteralIndex++;
						iWhereIndex++;
					}
				}
				sLiteral[iLiteralIndex] = 
					a_sWhereClause[iWhereIndex];
				iLiteralIndex++;
				iWhereIndex++;
			}
/*			sLiteral[iLiteralIndex] = a_sWhereClause[iWhereIndex];
			iLiteralIndex++;
			iWhereIndex++;
*/
		}
		else
		{
/*			
		Changes done here to fix a problem when the values 
		are numbers followed by
		characters (For eg. 42316 GOODY) Earlier, only the 
		number part was getting 
		converted to the HOST Variable with the character 
		part as a tag (:C14 GOODY).
		Now the whole value gets converted to the HOST variable

		Manoj Thoniyil
		07/18/2001
*/
			if(strstr(a_sWhereClause, "VALUES "))
			{
				if (isdigit (a_sWhereClause[iWhereIndex]) 
					|| a_sWhereClause[iWhereIndex] == ':')
				{
					while (a_sWhereClause[iWhereIndex] != ',' && a_sWhereClause[iWhereIndex] != ')')
					{
						sLiteral[iLiteralIndex] = 
						   a_sWhereClause[iWhereIndex];
						iLiteralIndex++;
						iWhereIndex++;
					}
				/*did we break out on a decimal point*/
					if (a_sWhereClause[iWhereIndex] == '.'
					|| a_sWhereClause[iWhereIndex] == '-')
					{
				/*if yes then copy the decimal point
			and continue copying the rest of the decimal point*/
						sLiteral[iLiteralIndex] = 
						   a_sWhereClause[iWhereIndex];
						iLiteralIndex++;
						iWhereIndex++;
						while (isdigit (a_sWhereClause[iWhereIndex]))
						{
						     sLiteral[iLiteralIndex] = 
							a_sWhereClause[iWhereIndex];
							iLiteralIndex++;
							iWhereIndex++;
						}
					}
				}
			}
			else
			{
				while (isdigit (a_sWhereClause[iWhereIndex]) 
					|| a_sWhereClause[iWhereIndex] == ':')
				{
					sLiteral[iLiteralIndex] = 
						   a_sWhereClause[iWhereIndex];
					iLiteralIndex++;
					iWhereIndex++;
				}
				/*did we break out on a decimal point*/
				if (a_sWhereClause[iWhereIndex] == '.'
					|| a_sWhereClause[iWhereIndex] == '-')
				{
				/*if yes then copy the decimal point
			and continue copying the rest of the decimal point*/
					sLiteral[iLiteralIndex] = 
						   a_sWhereClause[iWhereIndex];
					iLiteralIndex++;
					iWhereIndex++;
					while (isdigit (a_sWhereClause[iWhereIndex]))
					{
						sLiteral[iLiteralIndex] = 
							a_sWhereClause[iWhereIndex];
						iLiteralIndex++;
						iWhereIndex++;
					}
				}
			}
		}
		(*a_iHVIndex)++;
		memset (sHV, 0, 1000);
		sprintf (sHV, ":C%d", *a_iHVIndex);
		strcpy (a_sOutputWhereClause + *a_iOutputWhereIndex, sHV);
		*a_iOutputWhereIndex += strlen (sHV);
		*a_iWhereIndex = iWhereIndex;
		if (*a_iHVIndex != 1)
		{
			strcat (a_sOutputUsingQualifier, ",");
		}
		else
		{
			if (a_sOutputUsingQualifier &&
				strlen (a_sOutputUsingQualifier) != 0)
			{
				int iUsingIndex = 0;
				while (a_sOutputUsingQualifier[iUsingIndex] 
			!= 0 &&a_sOutputUsingQualifier[iUsingIndex] != ')')
				{
					iUsingIndex++;
				}
				if (a_sOutputUsingQualifier[iUsingIndex] == ')')
				{
				     a_sOutputUsingQualifier[iUsingIndex] = ',';
				}
			}
			else
			{
				strcpy (a_sOutputUsingQualifier, "/USING=(");
			}
		}
		sprintf (sOutputUsingQualifier, "%s=%s", sHV + 1, sLiteral);
		strcat (a_sOutputUsingQualifier, sOutputUsingQualifier);
	}
	/*it's a join condition*/
	else 
	{
	}

	free(sOutputUsingQualifier);
}

/*****************************************************************************
Function Name	:	char *TrimStr(char *lpsStr,char *lpsTrim)

Argument	:	char		*lpsStr
			char		*lpsTrim

Comments	:	This Functions searches the SQL statement for string 
			passed as 2 parameter and removes it from SQL statement.
*****************************************************************************/
char *TrimStr(char *lpsStr,char *lpsTrim)
{
	char *pToken = NULL;

	if(lpsStr == NULL || lpsTrim == NULL)
		return lpsStr;

	pToken = (char *)strstr(lpsStr, lpsTrim);
	while(pToken)
	{
		strcpy(pToken, &pToken[1]);
		pToken = (char *)strstr(lpsStr, lpsTrim);
	}

	return lpsStr;
}

/******************************************************************************
DESC:

Function to convert where clause of a select statement into using
using host variables.
a_sWhereClause: The input where clause
a_lWhereLen: The input where clause length
a_sUsingClause: The input using clause
a_sUsingLen: The input using clause length
a_sOutputWhereClause: The output where clause with host variables
a_lOutputWhereLen: 	Length of the output where clause. If the length
is set to 0 then the input where clause wasn't modified.
a_sOutputUsingQualifier: The output using qualifier 
a_lOutputUsingLen: 	Length of the output using qualifier. If the length
is set to 0 then the input using clause wasn't modified.
 
return:
 	1: success
 	-1: conversion error
 	-2: exceed 32k
 
 
Rules :
Function receives Where clause and can possibly receive "/USING..." clause. 
It should never receive any other qualifiers such as "/ROWS=1..." etc. 
The function will either create a "/USING..." qualifier or append to the 
existing qualifier.
a_sUsingClause can be an empty string. This will be indicated by a_sUsingLen = 0.
if a_sUsingClause is empty then the function will return 
"/USING = (c1=...)" in the a_sOutputUsingQualifier
if a_sUsingClause is not empty then if the function finds an existing ')'
if assumes that the /USING clause already exists in a_sUsingClause and it
will append to current clause. if it does not find any ')' then it will
append a "/USING = (c1=...)" clause.
******************************************************************************/
long ConvertWhereClause ( 
	const char* a_sWhereClause, 
	long a_lWhereLen, 
	const char* a_sUsingClause, 
	long a_lUsingLen, 
	char* a_sOutputWhereClause, 
	long *a_lOutputWhereLen, 
	char* a_sOutputUsingQualifier, 
	long *a_lOutputUsingLen)
{
	char	checkStr[20];
	char	*lpsNewWhere = NULL,*lpsWhereClause = NULL;
	char	*lpsBetween = NULL;
	char	*lpsAnd = NULL;
	char	*pToken = NULL;
	int	nBetweenCount = 0, lenWhereClause = 0;
	unsigned int iHVIndex = 0, iWhereIndex = 0, iOutputWhereIndex = 0;

	if (NULL == a_sWhereClause || 0 == a_lWhereLen ||
	    NULL == a_sOutputWhereClause ||NULL == a_lOutputWhereLen ||
	    NULL == a_sOutputUsingQualifier ||NULL == a_lOutputUsingLen)
	{
		return -1;
	}

	lpsWhereClause = (char *)calloc(a_lWhereLen+1,1);
	strcpy(lpsWhereClause,a_sWhereClause);
	lenWhereClause = a_lWhereLen;

	
	/*UPDATE STMT*/
	if((char *)strstr(lpsWhereClause, " SET "))		
		strcpy(checkStr,",=<>");
	/*SELECT/DELETE STMT*/
	else if((char *)strstr(lpsWhereClause, " WHERE "))	
		strcpy(checkStr,"=<>");			
	/*INSERT STMT*/
	else if((char *)strstr(lpsWhereClause, " VALUES "))	
		strcpy(checkStr,"(,");

	if (a_sUsingClause)
	{
		if (a_lUsingLen) {
			strncpy (a_sOutputUsingQualifier, a_sUsingClause, 
						a_lUsingLen);
		}
		else {
			a_sOutputUsingQualifier[0] = 0;
		}
	}

	lpsBetween	= (char *)strstr(lpsWhereClause,"BETWEEN");
	lpsAnd		= (char *)strstr(lpsWhereClause,"AND");

	if(lpsBetween && lpsAnd)
	{
		pToken = (char *)strtok(lpsWhereClause, " ");
		lpsNewWhere = (char *)calloc (MAX_MSG_SIZE,1);
		if(lpsNewWhere == NULL)
			return -1;
		
		while ( pToken != NULL )
		{ 
			strcat(lpsNewWhere,pToken);
			if((strcmp(pToken,"BETWEEN") == 0) || 
				((strcmp(pToken,"AND") == 0) && nBetweenCount))
			{
				strcat(lpsNewWhere, " ^");
				nBetweenCount = !nBetweenCount;
			}
			pToken = (char *)strtok(NULL, " "); 
			if(pToken)
				strcat(lpsNewWhere," ");
		} 
		free(lpsWhereClause);
		lpsWhereClause = (char *)calloc(strlen(lpsNewWhere)+1,1);
		strcpy(lpsWhereClause,lpsNewWhere);
		lenWhereClause = strlen(lpsWhereClause);
		strcat(checkStr,"^");
		if(lpsNewWhere) 
			free(lpsNewWhere);
	}

	while ((int)iWhereIndex != lenWhereClause)
	{
		if ((int)iWhereIndex == *a_lOutputWhereLen)
		{
			return -2;
		}
		a_sOutputWhereClause[iOutputWhereIndex] = 
					lpsWhereClause[iWhereIndex];
		/*'=' indicates a literal or a join condition. A join condition
		will be handled within the HandleHostVariable function.*/
		if (strchr(checkStr, lpsWhereClause[iWhereIndex]) != NULL)
		{
			iWhereIndex++;
			iOutputWhereIndex++;
			HandleHostVariable (lpsWhereClause,
					&iWhereIndex,
					a_sOutputWhereClause,
					&iOutputWhereIndex,
					a_sOutputUsingQualifier,
					&iHVIndex);
		}
		else
		{
			iWhereIndex++;
			iOutputWhereIndex++;
		}
	}
	if (iHVIndex)
	{
		strcat (a_sOutputUsingQualifier, ")");
		TrimStr(a_sOutputWhereClause,"^");
		*a_lOutputWhereLen = strlen (a_sOutputWhereClause);
		*a_lOutputUsingLen = strlen (a_sOutputUsingQualifier);
	}
	else
	{
		*a_lOutputWhereLen = 0;
		*a_lOutputUsingLen = 0;
	}
	free(lpsWhereClause);
	return 1;
}

/*****************************************************************************
Function Name :LONG StripTableName (const LPSTR a_sSQLStmt, LONG a_lSQLStmt, 
			LPSTR a_sOutputSQLStmt, LONG *a_lOutputSQLStmt) 

Argument      : a_sSQLStmt-> Input SQL Statement whose tablename 
				needs to be stiped
		a_lSQLStmt-> Length of the Input SQL Statement
		a_sOutputSQLStmt -> The Ouptut SQL statement with 
				stripped table name
		a_lOutputSQLStmt -> The Length of the output SQL statement

Return        : 1  - SUCCESS
		0  - NO CHANGE, Contains more than one table in SQL statement.
		-1 - Error

Comments      :	The purpose of this function is to strip the table name 
		associated with the column name from the SQL statement with 
		single table select.
*****************************************************************************/
long StripTableName ( 
	const char* a_sSQLStmt, 
	long a_lSQLStmt, 
	char* a_sOutputSQLStmt, 
	long *a_lOutputSQLStmt) 
{
	char	*lpsFrom = NULL,*lpsBefore = NULL,*lpsWhere = NULL;
	char	*lpsTableName = NULL, *newTableName = NULL ,
			*tmpBuffer = NULL,*pToken = NULL;
	int	nLen,bSingleTable;
	
	if (NULL == a_sSQLStmt	 ||
	0 == a_lSQLStmt		 ||
	NULL == a_sOutputSQLStmt ||
	NULL == a_lOutputSQLStmt)
	{
		return -1;
	}
	
	if (a_sSQLStmt)
	{
		if (a_lSQLStmt)
		{
			memset(a_sOutputSQLStmt,0,*a_lOutputSQLStmt);
			strncpy (a_sOutputSQLStmt, a_sSQLStmt, a_lSQLStmt);
		}
		else
		{
			a_sOutputSQLStmt[0] = 0;
		}
	}

	lpsFrom	= (char *)strstr(a_sOutputSQLStmt,"FROM");
	if(lpsFrom == NULL)
		return 0;

	nLen = lpsFrom - a_sOutputSQLStmt;
	lpsBefore	= (char *) calloc(nLen + 1,1);
	if(NULL == lpsBefore)
		return -1;

	strncpy(lpsBefore,a_sOutputSQLStmt,nLen);

	pToken = (char *)strstr(a_sOutputSQLStmt,"WHERE");
	if(pToken)
	{
		lpsWhere = (char *)calloc (strlen(pToken) + 1,1);
		if(NULL == lpsWhere){
			if(lpsBefore) free(lpsBefore);
			return -1;
		}
		strcpy(lpsWhere,pToken);
	}

	if(lpsWhere)
	{
		nLen = (pToken - lpsFrom - 5);
		tmpBuffer	= (char *)calloc (nLen + 1,1);
		if(NULL == tmpBuffer){
			if(lpsBefore) free(lpsBefore);
			if(lpsWhere) free(lpsWhere);
			return -1;
		}

		strncpy(tmpBuffer,lpsFrom + 5,nLen);
		tmpBuffer[nLen] = '\0';
		
		lpsTableName = (char *)strtok(tmpBuffer," ");
		pToken = lpsTableName;
	}
	else
	{
		nLen = strlen(lpsFrom) - 5;
		tmpBuffer	= (char *)calloc (nLen + 1,1);
		if(NULL == tmpBuffer){
			if(lpsBefore) free(lpsBefore);
			if(lpsWhere) free(lpsWhere);
			return -1;
		}

		strncpy(tmpBuffer,lpsFrom + 5,nLen);
		lpsTableName = (char *)strtok(tmpBuffer," ");
		pToken = lpsTableName;
	}

	/* Check for the SingleTable */
	while(pToken)
	{
		/*tmpToken = pToken;*/
		if(strcmp(pToken, lpsTableName) != 0)
		{
			pToken = (char *)strtok(NULL," ");
			bSingleTable = 0;
		}
		else
		{
			pToken = (char *)strtok(NULL," ");
			bSingleTable = 1;
		}
	}

	/* Strip the table Name from associated with column name */
	if(bSingleTable)
	{
		newTableName	= (char *)calloc (strlen(lpsTableName) + 2,1);
		if(NULL == newTableName){
			if(lpsBefore) free(lpsBefore);
			if(lpsWhere) free(lpsWhere);
			if(tmpBuffer) free(tmpBuffer);
			return -1;
		}
		strcpy(newTableName,lpsTableName);
		strcat(newTableName,".");
		pToken = (char *)strstr(lpsBefore, newTableName);
		while(pToken)
		{
			nLen = strlen(newTableName);
			strcpy(pToken, &pToken[nLen]);
			pToken = (char *)strstr(lpsBefore, newTableName);
		}
	}
	else
	{
			*a_lOutputSQLStmt = 0;
			if(lpsBefore) free(lpsBefore);
			if(lpsWhere) free(lpsWhere);
			if(tmpBuffer) free(tmpBuffer);
			return 0;
	}

	strcpy(a_sOutputSQLStmt,lpsBefore);
	strcat(a_sOutputSQLStmt,"FROM ");
	strcat(a_sOutputSQLStmt,lpsTableName);
	if(lpsWhere)
	{
		strcat(a_sOutputSQLStmt," ");
		strcat(a_sOutputSQLStmt,lpsWhere);
	}
	*a_lOutputSQLStmt = strlen(a_sOutputSQLStmt);
	if(lpsBefore)
		free(lpsBefore);
	if(lpsWhere)
		free(lpsWhere);
	if(tmpBuffer)
		free(tmpBuffer);
	if(newTableName)
		free(newTableName);
	return 1;
}

/*****************************************************************************
Function Name : ParseHostSQL( const char* a_sSQLStmt, long a_lSQLStmt,
		char* a_sUsingClause, long a_lUsingLen, char* a_sParsedSQLStmt,
		long *a_lParsedSQLStmt, char* a_sNewUsingClause, 
		long *a_lNewUsingClause)

Return        :	 1 - SUCCESS
		 0 - NO CHANGE, The SQL Statement is cleaned, 
				but not converted to Host Variables.
		-1 - Error

Comments      :	This function is used to parse the Where Clause from the SQL statements.If the Where Clause exists in the statement, It Calls ConverWhereClause
Function which returns WhereClause with host variable and /USING with value HostVariable = value. Now the SQL statement is build by new WhereClause.

Example       :	Old: Select * from acn where cif = 100 and acn = 1234567
		New: Select * from acn where (cif = :C1 and acn = :C2)
			 /USING=(C1=100,acn=1234567)
					
******************************************************************************/
long ParseHostSQL( const char* a_sSQLStmt, 
	long a_lSQLStmt,
	const char* a_sUsingClause,
	long a_lUsingLen,
	char* a_sParsedSQLStmt, 
	long *a_lParsedSQLStmt,
	char* a_sNewUsingClause, 
	long *a_lNewUsingClause)
{
	char	*lpsWhereClause = NULL,*lpsBefore = NULL;
	char	*lpsNewWhereClause = NULL, *lpsNewUsingClause = NULL;
	long	lNewWhereLen,lNewUsingLen,lCleanedSQLStmt,retVal;
	int	nPos = 0;
	char	*lpsCleanedSQLStmt = NULL;
	char	*pToken = NULL,*lpsNewWhere = NULL,*lpsBetween = NULL,
		*lpsAnd = NULL;

	if (NULL == a_sSQLStmt	  ||
	0 == a_lSQLStmt		  ||
	NULL == a_sParsedSQLStmt  ||
	NULL == a_lParsedSQLStmt  ||
	NULL == a_sNewUsingClause ||
	NULL == a_lNewUsingClause)
	{
		return -1;
	}

	/*First CleanUp the SQL statement*/
	lpsCleanedSQLStmt = (char *)calloc (MAX_MSG_SIZE,1);
	if(NULL == lpsCleanedSQLStmt)
		return -1;
	lCleanedSQLStmt = MAX_MSG_SIZE;
	retVal = CleanUpSQLStmt(a_sSQLStmt, strlen(a_sSQLStmt), 
			lpsCleanedSQLStmt,&lCleanedSQLStmt);
	if(retVal < 0){
		if(lpsCleanedSQLStmt)
			free(lpsCleanedSQLStmt);
		return retVal;
	}

	/* Strip the table name for single table Query */
	retVal = StripTableName(lpsCleanedSQLStmt,strlen(lpsCleanedSQLStmt),
				a_sParsedSQLStmt,a_lParsedSQLStmt);

	if(retVal < 0){
		if(lpsCleanedSQLStmt)
			free(lpsCleanedSQLStmt);
		return retVal;
	}

	if(!retVal)
	{
		memset(a_sParsedSQLStmt,0,strlen(a_sParsedSQLStmt));
		strcpy(a_sParsedSQLStmt,lpsCleanedSQLStmt);
		*a_lParsedSQLStmt = lCleanedSQLStmt;
	}

	/* Finding the occurence of Where Clause */
	lpsWhereClause	= (char *)strstr(a_sParsedSQLStmt, " SET ");
	if(lpsWhereClause == NULL)
		lpsWhereClause	= (char *)strstr(a_sParsedSQLStmt, " VALUES ");
	if(lpsWhereClause == NULL)
		lpsWhereClause	= (char *)strstr(a_sParsedSQLStmt, " WHERE ");

	/* if WHERE = NOT_FOUND then return 0
	Else modify the SQL with Host Variables */

	if(lpsWhereClause == NULL)
	{
		*a_lNewUsingClause = 0;
		if(lpsCleanedSQLStmt)
			free(lpsCleanedSQLStmt);
		return 0;
	}

	/* Making the len as 32k */
	lNewUsingLen = lNewWhereLen = MAX_MSG_SIZE;

	/* Allocating size as 32k for o/p strings */
	lpsNewWhereClause = (char *)calloc (MAX_MSG_SIZE,1);
	lpsNewUsingClause = (char *)calloc (MAX_MSG_SIZE,1);
	nPos = lpsWhereClause - a_sParsedSQLStmt;
	lpsBefore = (char *)calloc(nPos + 1,1);

	if(NULL==lpsNewWhereClause || NULL==lpsNewUsingClause 
			|| lpsBefore==NULL) {
		if(lpsCleanedSQLStmt)
			free(lpsCleanedSQLStmt);
		if(lpsNewWhereClause)
			free(lpsNewWhereClause);
		if(lpsNewUsingClause)
			free(lpsNewUsingClause);
		if(lpsBefore)
			free(lpsBefore);
		return -1;
	}

	strncpy(lpsBefore,a_sParsedSQLStmt,nPos);
	retVal = ConvertWhereClause(lpsWhereClause, strlen(lpsWhereClause),
		a_sUsingClause, a_lUsingLen, (char *)lpsNewWhereClause,
		&lNewWhereLen, (char *)lpsNewUsingClause, &lNewUsingLen);

	if((lNewWhereLen > 0) && (lNewUsingLen > 0))
	{
		*a_lParsedSQLStmt = strlen (lpsBefore) + lNewWhereLen ;
		strcpy(a_sParsedSQLStmt,lpsBefore);
		strcat(a_sParsedSQLStmt,lpsNewWhereClause);

		*a_lNewUsingClause = lNewUsingLen;
		strcpy(a_sNewUsingClause,lpsNewUsingClause);
	}
	else
		*a_lNewUsingClause = 0;

	if(lpsCleanedSQLStmt)
		free(lpsCleanedSQLStmt);
	if(lpsNewUsingClause)
		free(lpsNewUsingClause);
	if(lpsNewWhereClause)
		free(lpsNewWhereClause);
	if(lpsBefore)
		free(lpsBefore);
	return 1;
}

int FindChar(char *strCheck, char *strData)
{
	int nLen = 0;
	int i;
	nLen = strlen(strData);
	for (i=0; i < nLen ; i++)
	{
		if(strchr(strCheck,strData[i]) != NULL)
			return 1;
	}
	return 0;
}

/*****************************************************************************
Function Name	: long FormatResultSet	(unsigned char *profile_reply,
				unsigned char *col_attributes)

Arguments	: fpBuffer WorkBuffer

Return		: 1 - SUCCESS

Comments	:This function is used to do the client side formatting of Data
		 returned by the Host when called through PFW Client. 

Format Type	:
		D	Based on /DATE (regional setting)
		C	hh:mm:ss
		L	0 or 1
		2	$ Two decimal (character based on /DEC regional setting)
		n	n n decimal (character based on /DEC regional setting)

******************************************************************************/
long FormatResultSet	(unsigned char *profile_reply,
				unsigned char *col_attributes)
{
	int	header_len=0,totalChars,dataLen = 0;
	char	*pszFetchBuffer = NULL,*pszCurrentRow = NULL;
	char 	*pszNewCurrentRow = NULL;
	char	*lpsResult = NULL;
	char	checkStr[20];
	int	nOffset = 1;


	if (NULL == profile_reply)
	{
		return -1;
	}

	strcpy(checkStr,"LDC$123456789");
	if(FindChar((char *)checkStr, (char *)col_attributes))
	{
		pszFetchBuffer = (char *) calloc(strlen((char *)profile_reply) +1,1);
		if (pszFetchBuffer == NULL)
			return -1;
		strcpy((char *)pszFetchBuffer, (char *)profile_reply);
		totalChars = 0;
		dataLen = strlen(pszFetchBuffer);

		pszCurrentRow	= (char *) calloc ((MAX_MSG_SIZE + 1),1);
		pszNewCurrentRow = (char *) calloc ((MAX_MSG_SIZE + 1),1);
		lpsResult = (char *)calloc((MAX_MSG_SIZE + 1), 1);
		if(lpsResult==NULL || pszCurrentRow==NULL 
		|| pszNewCurrentRow==NULL ) {
			if(lpsResult)
				free(lpsResult);
			if(pszCurrentRow)
				free(pszCurrentRow);
			if(pszNewCurrentRow)
				free(pszNewCurrentRow);
			return -1;
		}


		while(*pszFetchBuffer)
		{	
			while (*pszFetchBuffer != 13 && *pszFetchBuffer != 0)
			{
				pszCurrentRow[totalChars] = *pszFetchBuffer;
				totalChars++;
				pszFetchBuffer++;
			}
			FormatCurrentRow(pszCurrentRow, col_attributes, 
						pszNewCurrentRow);
			strcat(lpsResult,pszNewCurrentRow);
			if(*pszFetchBuffer !=0)
			{
				strcat(lpsResult,"\r\n");
				pszFetchBuffer+=2;
			}
			memset(pszCurrentRow,0,MAX_MSG_SIZE + 1);
			memset(pszNewCurrentRow,0,MAX_MSG_SIZE + 1);
			totalChars = 0;
		}
		memset((char *)profile_reply,0,strlen((char *)profile_reply)+1);
		memcpy(profile_reply, lpsResult, strlen(lpsResult));
		pszFetchBuffer -=dataLen;

		if(pszFetchBuffer)
			free(pszFetchBuffer);
		if(pszCurrentRow)
			free(pszCurrentRow);
		if(pszNewCurrentRow)
			free(pszNewCurrentRow);
		if(lpsResult)
			free(lpsResult);
		return 1;
	}
	return 0;
}
