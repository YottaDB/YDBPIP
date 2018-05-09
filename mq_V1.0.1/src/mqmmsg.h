/*****************************************************************************
*
*	mqmmsg.h
*
*	Copyright(c)2000 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	Description: Sanchez MQSeries API Message Listing for UNIX
*
* $Author: lyh $
*
* $Date: 2000/11/08 20:09:38 $
*
* $Id: mqmmsg.h,v 1.1 2000/11/08 20:09:38 lyh Exp lyh $
*
* $Log: mqmmsg.h,v $
 * Revision 1.1  2000/11/08  20:09:38  lyh
 * Initial revision
 *
*
* $Revision: 1.1 $
*
*****************************************************************************/

#if !defined(MQMMSG_INCLUDED)             /* File not yet included?      */
#define MQMMSG_INCLUDED                   /* Show file now included      */

/* Completion Codes */
#define SCA_MQCC_FORCED_ERROR 3L
#define SCA_MQCC_UNKNOWN_ERROR 4L
#define MAX_MQCC_MSGS         5L
static char *mqm_cclist[MAX_MQCC_MSGS] = 
{
   "MQSeries CC ERROR: Invalid completion code.",
   "MQSeries CC ERROR: MQCC_WARNING",
   "MQSeries CC ERROR: MQCC_FAILED",
   "MQSeries CC ERROR: MQCC_FORCED_ERROR",
   "MQSeries CC ERROR: MQCC_UNKNOWN_ERROR"
};

/* Reason Codes */
#define SCA_MQRC_FIRST_MSG        2001L
#define SCA_MQRC_LAST_MSG         2296L
#define MAX_MQRC_MSGS 297
static char *mqm_rclist[MAX_MQRC_MSGS] =
{
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: MQRC_ALIAS_BASE_Q_TYPE_ERROR",
   "MQSeries RC ERROR: MQRC_ALREADY_CONNECTED",
   "MQSeries RC ERROR: MQRC_BACKED_OUT",
   "MQSeries RC ERROR: MQRC_BUFFER_ERROR",
   "MQSeries RC ERROR: MQRC_BUFFER_LENGTH_ERROR",
   "MQSeries RC ERROR: MQRC_CHAR_ATTR_LENGTH_ERROR",
   "MQSeries RC ERROR: MQRC_CHAR_ATTRS_ERROR",
   "MQSeries RC ERROR: MQRC_CHAR_ATTRS_TOO_SHORT",
   "MQSeries RC ERROR: MQRC_CONNECTION_BROKEN",
   "MQSeries RC ERROR: MQRC_DATA_LENGTH_ERROR",
   "MQSeries RC ERROR: MQRC_DYNAMIC_Q_NAME_ERROR",
   "MQSeries RC ERROR: MQRC_ENVIRONMENT_ERROR",
   "MQSeries RC ERROR: MQRC_EXPIRY_ERROR",
   "MQSeries RC ERROR: MQRC_FEEDBACK_ERROR",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: MQRC_GET_INHIBITED",
   "MQSeries RC ERROR: MQRC_HANDLE_NOT_AVAILABLE",
   "MQSeries RC ERROR: MQRC_HCONN_ERROR",
   "MQSeries RC ERROR: MQRC_HOBJ_ERROR",
   "MQSeries RC ERROR: MQRC_INHIBIT_VALUE_ERROR",
   "MQSeries RC ERROR: MQRC_INT_ATTR_COUNT_ERROR",
   "MQSeries RC ERROR: MQRC_INT_ATTR_COUNT_TOO_SMALL",
   "MQSeries RC ERROR: MQRC_INT_ATTRS_ARRAY_ERROR",
   "MQSeries RC ERROR: MQRC_SYNCPOINT_LIMIT_REACHED",
   "MQSeries RC ERROR: MQRC_MAX_CONNS_LIMIT_REACHED",
   "MQSeries RC ERROR: MQRC_MD_ERROR",
   "MQSeries RC ERROR: MQRC_MISSING_REPLY_TO_Q",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: MQRC_MSG_TYPE_ERROR",
   "MQSeries RC ERROR: MQRC_MSG_TOO_BIG_FOR_Q",
   "MQSeries RC ERROR: MQRC_MSG_TOO_BIG_FOR_Q_MGR",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: MQRC_NO_MSG_AVAILABLE",
   "MQSeries RC ERROR: MQRC_NO_MSG_UNDER_CURSOR",
   "MQSeries RC ERROR: MQRC_NOT_AUTHORIZED",
   "MQSeries RC ERROR: MQRC_NOT_OPEN_FOR_BROWSE",
   "MQSeries RC ERROR: MQRC_NOT_OPEN_FOR_INPUT",
   "MQSeries RC ERROR: MQRC_NOT_OPEN_FOR_INQUIRE",
   "MQSeries RC ERROR: MQRC_NOT_OPEN_FOR_OUTPUT",
   "MQSeries RC ERROR: MQRC_NOT_OPEN_FOR_SET",
   "MQSeries RC ERROR: MQRC_OBJECT_CHANGED",
   "MQSeries RC ERROR: MQRC_OBJECT_IN_USE",
   "MQSeries RC ERROR: MQRC_OBJECT_TYPE_ERROR",
   "MQSeries RC ERROR: MQRC_OD_ERROR",
   "MQSeries RC ERROR: MQRC_OPTION_NOT_VALID_FOR_TYPE",
   "MQSeries RC ERROR: MQRC_OPTIONS_ERROR",
   "MQSeries RC ERROR: MQRC_PERSISTENCE_ERROR",
   "MQSeries RC ERROR: MQRC_PERSISTENT_NOT_ALLOWED",
   "MQSeries RC ERROR: MQRC_PRIORITY_EXCEEDS_MAXIMUM",
   "MQSeries RC ERROR: MQRC_PRIORITY_ERROR",
   "MQSeries RC ERROR: MQRC_PUT_INHIBITED",
   "MQSeries RC ERROR: MQRC_Q_DELETED",
   "MQSeries RC ERROR: MQRC_Q_FULL",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: MQRC_Q_NOT_EMPTY",
   "MQSeries RC ERROR: MQRC_Q_SPACE_NOT_AVAILABLE",
   "MQSeries RC ERROR: MQRC_Q_TYPE_ERROR",
   "MQSeries RC ERROR: MQRC_Q_MGR_NAME_ERROR",
   "MQSeries RC ERROR: MQRC_Q_MGR_NOT_AVAILABLE",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: MQRC_REPORT_OPTIONS_ERROR",
   "MQSeries RC ERROR: MQRC_SECOND_MARK_NOT_ALLOWED",
   "MQSeries RC ERROR: MQRC_SECURITY_ERROR",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: MQRC_SELECTOR_COUNT_ERROR",
   "MQSeries RC ERROR: MQRC_SELECTOR_LIMIT_EXCEEDED",
   "MQSeries RC ERROR: MQRC_SELECTOR_ERROR",
   "MQSeries RC ERROR: MQRC_SELECTOR_NOT_FOR_TYPE",
   "MQSeries RC ERROR: MQRC_SIGNAL_OUTSTANDING",
   "MQSeries RC ERROR: MQRC_SIGNAL_REQUEST_ACCEPTED",
   "MQSeries RC ERROR: MQRC_STORAGE_NOT_AVAILABLE",
   "MQSeries RC ERROR: MQRC_SYNCPOINT_NOT_AVAILABLE",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: MQRC_TRIGGER_CONTROL_ERROR",
   "MQSeries RC ERROR: MQRC_TRIGGER_DEPTH_ERROR",
   "MQSeries RC ERROR: MQRC_TRIGGER_MSG_PRIORITY_ERR",
   "MQSeries RC ERROR: MQRC_TRIGGER_TYPE_ERROR",
   "MQSeries RC ERROR: MQRC_TRUNCATED_MSG_ACCEPTED",
   "MQSeries RC ERROR: MQRC_TRUNCATED_MSG_FAILED",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: MQRC_UNKNOWN_ALIAS_BASE_Q",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: MQRC_UNKNOWN_OBJECT_NAME",
   "MQSeries RC ERROR: MQRC_UNKNOWN_OBJECT_Q_MGR",
   "MQSeries RC ERROR: MQRC_UNKNOWN_REMOTE_Q_MGR",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: MQRC_WAIT_INTERVAL_ERROR",
   "MQSeries RC ERROR: MQRC_XMIT_Q_TYPE_ERROR",
   "MQSeries RC ERROR: MQRC_XMIT_Q_USAGE_ERROR",
   "MQSeries RC ERROR: MQRC_NOT_OPEN_FOR_PASS_ALL",
   "MQSeries RC ERROR: MQRC_NOT_OPEN_FOR_PASS_IDENT",
   "MQSeries RC ERROR: MQRC_NOT_OPEN_FOR_SET_ALL",
   "MQSeries RC ERROR: MQRC_NOT_OPEN_FOR_SET_IDENT",
   "MQSeries RC ERROR: MQRC_CONTEXT_HANDLE_ERROR",
   "MQSeries RC ERROR: MQRC_CONTEXT_NOT_AVAILABLE",
   "MQSeries RC ERROR: MQRC_SIGNAL1_ERROR",
   "MQSeries RC ERROR: MQRC_OBJECT_ALREADY_EXISTS",
   "MQSeries RC ERROR: MQRC_OBJECT_DAMAGED",
   "MQSeries RC ERROR: MQRC_RESOURCE_PROBLEM",
   "MQSeries RC ERROR: MQRC_ANOTHER_Q_MGR_CONNECTED",
   "MQSeries RC ERROR: MQRC_UNKNOWN_REPORT_OPTION",
   "MQSeries RC ERROR: MQRC_STORAGE_CLASS_ERROR",
   "MQSeries RC ERROR: MQRC_COD_NOT_VALID_FOR_XCF_Q",
   "MQSeries RC ERROR: MQRC_XWAIT_CANCELED",
   "MQSeries RC ERROR: MQRC_XWAIT_ERROR",
   "MQSeries RC ERROR: MQRC_SUPPRESSED_BY_EXIT",
   "MQSeries RC ERROR: MQRC_FORMAT_ERROR",
   "MQSeries RC ERROR: MQRC_SOURCE_CCSID_ERROR",
   "MQSeries RC ERROR: MQRC_SOURCE_INTEGER_ENC_ERROR",
   "MQSeries RC ERROR: MQRC_SOURCE_DECIMAL_ENC_ERROR",
   "MQSeries RC ERROR: MQRC_SOURCE_FLOAT_ENC_ERROR",
   "MQSeries RC ERROR: MQRC_TARGET_CCSID_ERROR",
   "MQSeries RC ERROR: MQRC_TARGET_INTEGER_ENC_ERROR",
   "MQSeries RC ERROR: MQRC_TARGET_DECIMAL_ENC_ERROR",
   "MQSeries RC ERROR: MQRC_TARGET_FLOAT_ENC_ERROR",
   "MQSeries RC ERROR: MQRC_NOT_CONVERTED",
   "MQSeries RC ERROR: MQRC_CONVERTED_MSG_TOO_BIG",
   "MQSeries RC ERROR: MQRC_NO_EXTERNAL_PARTICIPANTS",
   "MQSeries RC ERROR: MQRC_PARTICIPANT_NOT_AVAILABLE",
   "MQSeries RC ERROR: MQRC_OUTCOME_MIXED",
   "MQSeries RC ERROR: MQRC_OUTCOME_PENDING",
   "MQSeries RC ERROR: MQRC_BRIDGE_STARTED",
   "MQSeries RC ERROR: MQRC_BRIDGE_STOPPED",
   "MQSeries RC ERROR: MQRC_ADAPTER_STORAGE_SHORTAGE",
   "MQSeries RC ERROR: MQRC_UOW_IN_PROGRESS",
   "MQSeries RC ERROR: MQRC_ADAPTER_CONN_LOAD_ERROR",
   "MQSeries RC ERROR: MQRC_ADAPTER_SERV_LOAD_ERROR",
   "MQSeries RC ERROR: MQRC_ADAPTER_DEFS_ERROR",
   "MQSeries RC ERROR: MQRC_ADAPTER_DEFS_LOAD_ERROR",
   "MQSeries RC ERROR: MQRC_ADAPTER_CONV_LOAD_ERROR",
   "MQSeries RC ERROR: MQRC_BO_ERROR",
   "MQSeries RC ERROR: MQRC_DH_ERROR",
   "MQSeries RC ERROR: MQRC_MULTIPLE_REASONS",
   "MQSeries RC ERROR: MQRC_OPEN_FAILED",
   "MQSeries RC ERROR: MQRC_ADAPTER_DISC_LOAD_ERROR",
   "MQSeries RC ERROR: MQRC_CNO_ERROR",
   "MQSeries RC ERROR: MQRC_CICS_WAIT_FAILED",
   "MQSeries RC ERROR: MQRC_DLH_ERROR",
   "MQSeries RC ERROR: MQRC_HEADER_ERROR",
   "MQSeries RC ERROR: MQRC_SOURCE_LENGTH_ERROR",
   "MQSeries RC ERROR: MQRC_TARGET_LENGTH_ERROR",
   "MQSeries RC ERROR: MQRC_SOURCE_BUFFER_ERROR",
   "MQSeries RC ERROR: MQRC_TARGET_BUFFER_ERROR",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: MQRC_IIH_ERROR",
   "MQSeries RC ERROR: MQRC_PCF_ERROR",
   "MQSeries RC ERROR: MQRC_DBCS_ERROR",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: MQRC_OBJECT_NAME_ERROR",
   "MQSeries RC ERROR: MQRC_OBJECT_Q_MGR_NAME_ERROR",
   "MQSeries RC ERROR: MQRC_RECS_PRESENT_ERROR",
   "MQSeries RC ERROR: MQRC_OBJECT_RECORDS_ERROR",
   "MQSeries RC ERROR: MQRC_RESPONSE_RECORDS_ERROR",
   "MQSeries RC ERROR: MQRC_ASID_MISMATCH",
   "MQSeries RC ERROR: MQRC_PMO_RECORD_FLAGS_ERROR",
   "MQSeries RC ERROR: MQRC_PUT_MSG_RECORDS_ERROR",
   "MQSeries RC ERROR: MQRC_CONN_ID_IN_USE",
   "MQSeries RC ERROR: MQRC_Q_MGR_QUIESCING",
   "MQSeries RC ERROR: MQRC_Q_MGR_STOPPING",
   "MQSeries RC ERROR: MQRC_DUPLICATE_RECOV_COORD",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: MQRC_PMO_ERROR",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: MQRC_API_EXIT_NOT_FOUND",
   "MQSeries RC ERROR: MQRC_API_EXIT_LOAD_ERROR",
   "MQSeries RC ERROR: MQRC_REMOTE_Q_NAME_ERROR",
   "MQSeries RC ERROR: MQRC_INCONSISTENT_PERSISTENCE",
   "MQSeries RC ERROR: MQRC_GMO_ERROR",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: MQRC_TMC_ERROR",
   "MQSeries RC ERROR: MQRC_PAGESET_FULL",
   "MQSeries RC ERROR: MQRC_PAGESET_ERROR",
   "MQSeries RC ERROR: MQRC_NAME_NOT_VALID_FOR_TYPE",
   "MQSeries RC ERROR: MQRC_UNEXPECTED_ERROR",
   "MQSeries RC ERROR: MQRC_UNKNOWN_XMIT_Q",
   "MQSeries RC ERROR: MQRC_UNKNOWN_DEF_XMIT_Q",
   "MQSeries RC ERROR: MQRC_DEF_XMIT_Q_TYPE_ERROR",
   "MQSeries RC ERROR: MQRC_DEF_XMIT_Q_USAGE_ERROR",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: MQRC_NAME_IN_USE",
   "MQSeries RC ERROR: MQRC_CONNECTION_QUIESCING",
   "MQSeries RC ERROR: MQRC_CONNECTION_STOPPING",
   "MQSeries RC ERROR: MQRC_ADAPTER_NOT_AVAILABLE",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: MQRC_MSG_ID_ERROR",
   "MQSeries RC ERROR: MQRC_CORREL_ID_ERROR",
   "MQSeries RC ERROR: MQRC_FILE_SYSTEM_ERROR",
   "MQSeries RC ERROR: MQRC_NO_MSG_LOCKED",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: MQRC_FILE_NOT_AUDITED",
   "MQSeries RC ERROR: MQRC_CONNECTION_NOT_AUTHORIZED",
   "MQSeries RC ERROR: MQRC_MSG_TOO_BIG_FOR_CHANNEL",
   "MQSeries RC ERROR: MQRC_CALL_IN_PROGRESS",
   "MQSeries RC ERROR: MQRC_RMH_ERROR",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: MQRC_Q_MGR_ACTIVE",
   "MQSeries RC ERROR: MQRC_Q_MGR_NOT_ACTIVE",
   "MQSeries RC ERROR: MQRC_Q_DEPTH_HIGH",
   "MQSeries RC ERROR: MQRC_Q_DEPTH_LOW",
   "MQSeries RC ERROR: MQRC_Q_SERVICE_INTERVAL_HIGH",
   "MQSeries RC ERROR: MQRC_Q_SERVICE_INTERVAL_OK",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: MQRC_CHANNEL_AUTO_DEF_OK",
   "MQSeries RC ERROR: MQRC_CHANNEL_AUTO_DEF_ERROR",
   "MQSeries RC ERROR: MQRC_CFH_ERROR",
   "MQSeries RC ERROR: MQRC_CFIL_ERROR",
   "MQSeries RC ERROR: MQRC_CFIN_ERROR",
   "MQSeries RC ERROR: MQRC_CFSL_ERROR",
   "MQSeries RC ERROR: MQRC_CFST_ERROR",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: MQRC_INCOMPLETE_GROUP",
   "MQSeries RC ERROR: MQRC_INCOMPLETE_MSG",
   "MQSeries RC ERROR: MQRC_INCONSISTENT_CCSIDS",
   "MQSeries RC ERROR: MQRC_INCONSISTENT_ENCODINGS",
   "MQSeries RC ERROR: MQRC_INCONSISTENT_UOW",
   "MQSeries RC ERROR: MQRC_INVALID_MSG_UNDER_CURSOR",
   "MQSeries RC ERROR: MQRC_MATCH_OPTIONS_ERROR",
   "MQSeries RC ERROR: MQRC_MDE_ERROR",
   "MQSeries RC ERROR: MQRC_MSG_FLAGS_ERROR",
   "MQSeries RC ERROR: MQRC_MSG_SEQ_NUMBER_ERROR",
   "MQSeries RC ERROR: MQRC_OFFSET_ERROR",
   "MQSeries RC ERROR: MQRC_ORIGINAL_LENGTH_ERROR",
   "MQSeries RC ERROR: MQRC_SEGMENT_LENGTH_ZERO",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: MQRC_UOW_NOT_AVAILABLE",
   "MQSeries RC ERROR: MQRC_WRONG_GMO_VERSION",
   "MQSeries RC ERROR: MQRC_WRONG_MD_VERSION",
   "MQSeries RC ERROR: MQRC_GROUP_ID_ERROR",
   "MQSeries RC ERROR: MQRC_INCONSISTENT_BROWSE",
   "MQSeries RC ERROR: MQRC_XQH_ERROR",
   "MQSeries RC ERROR: MQRC_SRC_ENV_ERROR",
   "MQSeries RC ERROR: MQRC_SRC_NAME_ERROR",
   "MQSeries RC ERROR: MQRC_DEST_ENV_ERROR",
   "MQSeries RC ERROR: MQRC_DEST_NAME_ERROR",
   "MQSeries RC ERROR: MQRC_TM_ERROR",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: Invalid reason code.",
   "MQSeries RC ERROR: MQRC_HCONFIG_ERROR",
   "MQSeries RC ERROR: MQRC_FUNCTION_ERROR",
   "MQSeries RC ERROR: MQRC_CHANNEL_STARTED",
   "MQSeries RC ERROR: MQRC_CHANNEL_STOPPED",
   "MQSeries RC ERROR: MQRC_CHANNEL_CONV_ERROR",
   "MQSeries RC ERROR: MQRC_SERVICE_NOT_AVAILABLE",
   "MQSeries RC ERROR: MQRC_INITIALIZATION_FAILED",
   "MQSeries RC ERROR: MQRC_TERMINATION_FAILED",
   "MQSeries RC ERROR: MQRC_UNKNOWN_Q_NAME",
   "MQSeries RC ERROR: MQRC_SERVICE_ERROR",
   "MQSeries RC ERROR: MQRC_Q_ALREADY_EXISTS",
   "MQSeries RC ERROR: MQRC_USER_ID_NOT_AVAILABLE",
   "MQSeries RC ERROR: MQRC_UNKNOWN_ENTITY",
   "MQSeries RC ERROR: MQRC_UNKNOWN_AUTH_ENTITY",
   "MQSeries RC ERROR: MQRC_UNKNOWN_REF_OBJECT",
   "MQSeries RC ERROR: MQRC_CHANNEL_ACTIVATED",
   "MQSeries RC ERROR: MQRC_CHANNEL_NOT_ACTIVATED"
};

#define MQM_LOG(CompCode, ReasonCode)\
  if (CompCode != MQCC_OK)\
    {\
      if ((CompCode < MQCC_OK) || (CompCode > SCA_MQCC_FORCED_ERROR))\
	{\
	  CompCode = SCA_MQCC_UNKNOWN_ERROR;\
	}\
      (void)fprintf(stderr,"\nERROR:\tCompletion Code %d\n",CompCode);\
      (void)fprintf(stderr,"ERROR:\tMessage: %s\n",mqm_cclist[CompCode]);\
      (void)fprintf(stderr,"ERROR:\tSource file: %s Line Number %d\n",\
                    __FILE__,__LINE__);\
      (void)fflush(stdout);\
      (void)fflush(stderr);\
    }\
  if (ReasonCode != MQRC_NONE)\
    {\
      (void)fprintf(stderr,"ERROR:\tReason Code %d\n",ReasonCode);\
      if ((ReasonCode < SCA_MQRC_FIRST_MSG)||(ReasonCode > SCA_MQRC_LAST_MSG))\
	{\
	  ReasonCode = 0;\
	}\
      else\
	{\
	  ReasonCode = ReasonCode - SCA_MQRC_FIRST_MSG + 1;\
	}\
      (void)fprintf(stderr,"ERROR:\tMessage: %s\n",mqm_rclist[ReasonCode]);\
      (void)fprintf(stderr,"ERROR:\tSource file: %s Line Number %d\n",\
                    __FILE__,__LINE__);\
      (void)fflush(stdout);\
      (void)fflush(stderr);\
    }\

#endif
