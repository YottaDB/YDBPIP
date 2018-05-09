/*===========================DATA STRUCTURES===========================*/
#define VERSION "libsql.a V3.2 Jan 16, 2004"
#include "scatype.h"
#include "sca.h"
#include "mtmerrno.h"
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
 
#define MRPC_DELIMITER '\3'
/*#define MRPC_DELIMITER '?'*/
 
#define STRING_TERMINATOR 0
#define MAX_STRING_SIZE MAX_MSG_SIZE
#define SMALL_MAX_FIELD_SIZE  255
#define TAB 9
/*#define BIG_MAX_FIELD_SIZE  38000*/
#define BIG_MAX_FIELD_SIZE  8000 * 2
 
#define MAX_POSSIBLE_FIELDS 250
 
#define SERV_CLASS_SIGNON '0'
#define SERV_CLASS_SQL    '5'
#define SERV_CLASS_MRPC   '3'
 
#define ZERO 48
#define ONE  49
#define INFO_NODE 0

/***********************************/
STR_DESCRIPTOR dummyrec;
char           dummy_buff[150]; 
/***********************************/
 
typedef struct
{
	short total_substrings;
	short first_string_pos;
	unsigned char  *string_ptr;
} node_type;
 
node_type string_tree_array[5000];
 
/***********************************/
typedef struct {
        union {
                long unix_pid;
                long slot_id;
        } mtype;
        SLONG   return_code;
        SLONG   reason_code;
        SLONG   mtm_process_id;
        SLONG   slot_id;
        SLONG   pid;
        SLONG   srv_type;
        SLONG   sd;
        SLONG   port;
        SSHORT  length;
} MTM_MSG_HEADER;
/**********************************/
#define TRUE  1
#define FALSE 0
 
#define OK 0
#define SQL_OK 1500
 
#define MAX_HEADER_FIELDS 6
#define MAX_SIGNON_FIELDS 8
#define FS 28
 
/*HEADER DEFINITION FIELDS*/
#define srv_cls   0
#define token     1
#define msg_id    2
#define stf_flg   3
#define grp_recs  4
 
/*+++++++++++++++++++++++++++++*/
#define srv_prc   0
#define user_id   1
#define stn_id    2
#define user_pwd  3
#define inst_id   4
#define fap_ids   5
#define context   6
/*++++++++++++++++++++++++++++*/
#define srv_prc_off 0
#define token_off   1
 
#define SIGNON_SIZE 40000 * 2
/*+++++++++++++++++++++++++++++*/
#define mtm_message_size  0
#define server_type  1
#define separator    2
/*+++++++++++++++++++++++++++++*/
#define sqlstmt 0
#define qualifiers 1
#define spv 2
/*+++++++++++++++++++++++++++++*/
#define mrpc_id      0
#define mrpc_version 1
#define mrpc_param1  2
/*+++++++++++++++++++++++++++++*/
 
typedef struct
{
	unsigned char field_in_use;
	int  field_size;
	unsigned char field[BIG_MAX_FIELD_SIZE];
} field_structure_type;
 
field_structure_type header_array[MAX_HEADER_FIELDS];
field_structure_type signon_array[MAX_SIGNON_FIELDS];
field_structure_type signoff_array[3];
field_structure_type mtm_header[4];
field_structure_type sql_string[4];
typedef field_structure_type mrpc_type[500];
/*mrpc_type *mrpc_string;*/
field_structure_type (*mrpc_string)[500];
/*field_structure_type sql_string_array[5];*/
 
field_structure_type server_return_array[MAX_POSSIBLE_FIELDS];
/***********************************/
 
static int numeric_message_id = 2;
 
#define HEADER_SIZE  sizeof(MSG_HEADER_TYPE)
#define SIGN_ON_SIZE sizeof(CLIENT_SIGN_ON_TYPE)
 
#define MAX_BYTE_VAL  0X000000FF
#define MAX_WORD_VAL  0X0000FFFF
#define MAX_3BYTE_VAL 0X00FFFFFF
 
#define LEAVE_ROOM_FOR_MSG_SIZE 6
#define ok 0
 
#define MIN_HEADER_SIZE  7
#define MAX_HEADER_SIZE  29
 
typedef int MESSAGE_TYPE;
 
char passed_mtm_address[40];
/***************************MESSAGES*****************************************/
#define LOGGING_OFF 0
#define LOGGING_ON 1
#define LOGGING_PROBLEM 1
#define LOGGING_OK      0
 
#define CS_NOMTM      11
#define CS_NOSERVTYPE 14
#define CS_MTERROR    13
#define CS_TIMEOUT    4
 
#define PROBLEM1  11
#define PROBLEM2  14
#define PROBLEM3  1
#define PROBLEM4  4
 
#define SIGNON            0x00010000
#define TALK_TO_SERVER    0x00020000
#define HEADER_CHECK      0x00030000
#define MESSAGE_CHECK     0x00040000
#define SQL               0x00050000
#define SIGNOFF           0x00060000
#define RETRY             0X00070000
#define CHECK_MTMHEADER   0x00080000
#define CHECK_MESS_HEADER 0x00090000
#define CLCONNECT         0X000A0000
#define CLEXCHMSG         0X000B0000
#define MRPC              0x000C0000
#define CANNOT_OPEN_TABLE 0x000D0000
#define MRPC_ID_NOT_FOUND 0x000E0000
#define CLSQL             0X000F0000
#define CLMRPC            0X00100000
#define CLDISCONNECT      0X00200000
#define CLLOGIN           0X00300000
#define OK_BUT_EMPTY_MESSAGE_BODY 0X00300001
#define UNKNOWN_ERROR      0X00300002
