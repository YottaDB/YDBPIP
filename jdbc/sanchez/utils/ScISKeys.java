/**
 * A class for storing project keys
 *
 * @version 1.0
 * @author
 * @modification: 08/03/1999 Quansheng Jia
 * weblink
 */

package sanchez.utils;

import java.io.Serializable;

public abstract class ScISKeys implements Serializable {

    // Session and application management constants/variables
    public static final String sSTATE_SESSION = "STATE_SESSION_KEY";
    /** SSL Key Name in INI File */
    public static final String sSSL = "SSL";
    /** Table.Column Access */
    public static final int iAPPLY_ACCESS_NO = 0;
    public static final int iAPPLY_ACCESS_YES = 1;
    /** The Default Environment variable
     * 0 is default environment
     * 0 to 10 is reserved for Sanchez defined environemnts*/
    public static final int iDefaultEnvironmentID = 0;
    /** The Default Language variable
     * 0 is default language */
    public static final int iDefaultLanguageID = 0;
    /** The UnsecurePage Datasite */
    public static final String sUNSECUREPAGEDATASITE = "##Sa_UNSECUREPAGE##";
    /** The Number of user retries */
    public static final String sUSERRETRIES = "UserRetries";
    /** The NameResolver key used to store the NameResolver in the global cache */
    public static final String sNameResolver = "NAME_RESOLVER";
    /** General user for unsecure login */
    public static final String sGAEA_USER = "GAEA_USER";
    public static final String sGAEA_PASSWORD = "GAEA_PASS";
    /** Default user class for new user */
    public static final String sNEW_USER_DEFAULT_CLASS = "CUSTOMER";
    /** Customer type */
    public static final int iUSER_AGENT = 0;
    public static final int iUSER_CONSUMER = 1;
    public static final int iUSER_USER = 2;
    public static final String sUSER_CLASS_ALL = "USER_CLASS_ALL";
    /** The following keys refer to the section header names in the
     * ini file for each specific  host and database sections.
     * If the header names in the ini file changes then these
     * should be modified to reflect new names.
     */

    public static final String sPA_HOST_TRANSPORT = "PA_HOST_TRANSPORT";
    public static final String sIS_DB_MANAGER = "IS_DB_MANAGER";
    public static final String sPA_HOST_BID = "PA";
    public static final String sTOKEN_POOL_MANAGER = "TOKEN_POOL_MANAGER";
    //weblink
    public static final String sWEBLINK = "ON";
    public static final String JDBC_DATE_FORMAT = "dd MMM yyyy";
    /**
     *   *patil- ScBankUtils constants
     */
    public static final String sCURANCY = "USD";
    public static final String sAMTTODESPOSIT = "AMOUNT TO DIPOSIT";
    public static final int iCURUNCY_STR_LEN = 12;
    public static final int iNUMBER_STR_LEN = 8;
    public static final String sCURUNCY_PRC = "2";
    public static final String sCdnSufixString = "REQ";
    /** The application ini file name */
    // value defined here is the default.  Actual value is set during app startup
    public static String sINI_FILENAME = "e:\\rep_weblink\\ScServer.ini";
    public static String sINI_MESSAGE = "i_messages.txt";       //weblink
    /** the standard error page name */
    public static String sERRORPAGE = "Error.htm";
    public static String sDATE_FORMAT = "DateFormat";
    /** The INI File Sections */
    public static String sSYSTEM = "SYSTEM";
    public static String sHOST = "PA_HOST";
    //public static String sDBMANAGER = "IS_DB_MANAGER";
    public static String sDBMANAGER = "";       //weblink
    /**
     * Personalization constants
     */
    public static String sPERSONALPREFERENCE = "##Sa_PersonalPreference_";
    public static String sENDTAG = "##";
    public static String sPERSONALDISPLAY = "##Sa_IF=Personal_Display_";
    public static String sPERSONALDISPLAYSTRING = "Personal_Display_";
    public static String sPERSONALLAYOUT = "##Sa_Personal_Layout_";
    public static String sDEFAULT_USER = "__DEFAULT_USER__";
    public static String sDEFAULT_PREFERENCE = "i_oDefaultPreference";
    public static String sDEFAULT_DISPLAY = "i_oDefaultDisplay";
    public static String sDEFAULT_LAYOUT = "i_oDefaultLayout";
    /**
     * VS - Page Building constants
     */
    public static String sCURRENTACCOUNTNUMBER = "CURRENTACCOUNTNUMBER";
    public static String sCURRENTACCOUNTTYPE = "CURRENTACCOUNTTYPE";
    public static String sCURRENTACCOUNTLIST = "CURRENTACCOUNTLIST";
    /**
     *  BP - ScDebug Constants.
     */
    public static int iDEBUGSYSTEM = 1;
    /** We use message_counter to automate the assignment of numbers to integer constants.
     This makes changing, inserting, deleting values much easier. All integer constants
     must follow the assignment format given below.
     */
    private static int message_counter = 0;
    public static final int iHIM_LOGIN_SUCCESSFULL = message_counter++;
    /**
     * INITIALIZATION
     * Get ini file based on the environment setting.
     */
	/*commit out by weblink
	static {
		String drive = ScAbstractionUtils.getServerEnvValue ("GAEA_DRIVE");
		String dir = ScAbstractionUtils.getServerEnvValue ("GAEA_INSTALL") + java.io.File.separator;
		sINI_FILENAME = drive + dir + sINI_FILENAME;
		ScDebug.setDebugln(ScISKeys.iDEBUGSYSTEM,"------------------ sINI_FILENAME=" + sINI_FILENAME);
	}
	*/
    public static final int iHIM_LOGIN_FAILED = message_counter++;
    public static final int iHIM_LOGOUT_SUCCESSFULL = message_counter++;
    public static final int iHIM_LOGOUT_FAILED = message_counter++;
    public static final int iUSER_CLASS_PROXY = message_counter++;
    public static final int iUSER_CLASS_PRIVILEGED = message_counter++;
    public static final int iUSER_CLASS_INVALID = message_counter++;
    public static final int iSUCCESS = message_counter++;
    /**
     NUMERIC ERROR CODES
     */
    private static int iErrorCounter = -1;
    public static final int iINVALID_PROFILE_HEADER = iErrorCounter--;//-2
    public static final int iPROFILE_ERROR = iErrorCounter--;//-3
    public static final int iINVALID_PASSWORD = iErrorCounter--;//-4
    public static final int iINVALID_USERID = iErrorCounter--;//-5
    public static final int iINVALID_BACKEND_END = iErrorCounter--;//-6
    public static final int iFAILURE = iErrorCounter--;
    /**
     AUTHENTICATION ERROR CODES
     */
    public static final int iPASSWORD_EXPIRED = iErrorCounter--;//-7
    public static final int iHOST_ERROR = iErrorCounter--;//-8
    public static final int iGENERIC_LOGIN_ERROR = iErrorCounter--;//-9
    public static final int iMAXTRIES_EXCEEDED = iErrorCounter--;//-10
    public static final int iACCESS_DENIED = iErrorCounter--;//-11
    /**
     STRING DESCRIPTION ERROR CODES
     */
    public static final int iMISSING_REQUIRED = iErrorCounter--;//-12

}
