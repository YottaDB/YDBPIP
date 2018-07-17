package sanchez.jdbc.thin;

/**
 * ScProfHIM is API for Profile/Anyware server classes:
 * MSQL,MNSP,MRPC,HTML
 *
 * @author Quansheng Jia
 * @version 1.0 4th Feb 1999
 * @Revision History:
 * 05/01 Jiaq
 * Modified ProfileLogin and ProfileLogout to deal with
 * proxy user sign on and sign off.
 * 08/16 Jiaq
 * Add ProfileHTML to deal with HTML message
 * @Methods: sign on:
 * public ScProfToken ProfileLogin (String sUserName,
 * String sPassWord)
 * sign out:
 * public int ProfileLogout (ScProfToken oToken);
 * MRPC:
 * public String ProfileMRPC (ScProfToken oToken,
 * String  a_sMRPCId,
 * String  a_asMRPCArgs[],
 * String  a_sStoreForward);
 * MSQL:
 * public String[] ProfileSQL  (ScProfToken oToken,
 * String psSQLMessage,
 * String psSQLQualifier,
 * String psStoreForward);
 * HTML:
 * public String ProfileHTML  (ScProfToken oToken,
 * String psHTMLMessage,
 * String psStoreForward);
 * @see ScProfileForm
 */


import sanchez.him_pa.formatters.*;


import java.sql.SQLException;

import sanchez.him_pa.ScProfToken;
import sanchez.app.ScGlobalCacheManager;
import sanchez.jdbc.dbaccess.ScDBError;

import java.util.Hashtable;
import java.util.Properties;

import sanchez.utils.cipher.ScMD5;
import sanchez.him_pa.transports.ScTransport;
import sanchez.him_pa.utils.ScUtils;
import sanchez.ipc.SiCommunication;

public class ScProfileAPI {
    private ScTransport i_oScTransport;
    private ScProfileForm oProfForm = new ScProfileForm();
    private Hashtable oContext = new Hashtable();
    private int iReadTimeOut = 0;

    /** Creates an ScProfileAPI instance with the input Database detail 
     * @param     sDatabase -- db type
     */
    public ScProfileAPI(String sDatabase, Properties pInfo) {
        i_oScTransport = (ScTransport) ScGlobalCacheManager.getObject(sDatabase);
        oContext = (Hashtable) ScGlobalCacheManager.getObject("CONTEXT");
        if (oContext == null) oContext = new Hashtable();
        String fileEncoding = (String) pInfo.get("ENCODING");
        oProfForm.set_encoding(fileEncoding);
    }

    /**
     * Creates an ScProfileAPI instance with the input User anem and Password
     * @param:sUserName: User Name;
     * @param sPassWord: User Password
     * @return:ScProfToken: token
     */
    public ScProfToken ProfileLogin(String sUserName, String sPassWord)
            throws Exception, SQLException {

        ScProfToken oTempToken = null;

        String sStationId = (String) System.getProperty("user.name");
        if (sStationId.equals(null)) sStationId = "";
        sStationId = sStationId + " JDBC driver";

        SiCommunication oCommunication = null;

        String sLogin = oProfForm.wrapLoginRequest(sUserName,
                sPassWord,
                sStationId,
                oContext
        );

        StringBuffer sResultMess = new StringBuffer();

        try {
            oCommunication = i_oScTransport.checkOut();
            sResultMess = oCommunication.exchangeMessage(new StringBuffer(sLogin));
        } catch (Exception ee1) {
            if (ee1 instanceof java.io.IOException) {
                i_oScTransport.refresh(oCommunication);
                oCommunication = i_oScTransport.checkOut();
                sResultMess = oCommunication.exchangeMessage(new StringBuffer(sLogin));
            } else throw ee1;
        } finally {
            i_oScTransport.checkIn(oCommunication);
        }

        oTempToken = (ScProfToken) oProfForm.unwrapLoginResponse(sResultMess.toString());

        return oTempToken;
    }//METHOD ProfileLogin ENDS

    /**
     @param: sUserName: User Name;
     sPassWord: User Password
     pInfo: Connection Properties
     @return: ScProfToken: token
     */
    public ScProfToken ProfileLogin(String sUserName, String sPassWord, Properties pInfo)
            throws Exception, SQLException {
        ScProfToken oTempToken = null;

        String sNewPwd = (String) pInfo.get("newPWD");
        String sInstId = (String) pInfo.get("instID");

        String sStationId = (String) System.getProperty("user.name");
        if (sStationId.equals(null)) sStationId = "";
        sStationId = sStationId + " JDBC driver";

        SiCommunication oCommunication = null;

        String sLogin = oProfForm.wrapLoginRequest(sUserName,
                sPassWord,
                sStationId,
                "0",
                sInstId,
                "",
                oContext,
                sNewPwd,
                null,
                "1");

        StringBuffer sResultMess = new StringBuffer();

        try {
            oCommunication = i_oScTransport.checkOut();
            sResultMess = oCommunication.exchangeMessage(new StringBuffer(sLogin));
        } catch (Exception ee1) {
            if (ee1 instanceof java.io.IOException) {
                i_oScTransport.refresh(oCommunication);
                oCommunication = i_oScTransport.checkOut();
                sResultMess = oCommunication.exchangeMessage(new StringBuffer(sLogin));
            } else throw ee1;
        } finally {
            i_oScTransport.checkIn(oCommunication);
        }

        oTempToken = (ScProfToken) oProfForm.unwrapLoginResponse(sResultMess.toString());

        return oTempToken;
    }//METHOD ProfileLogin ENDS

    /**
     * Challenge/response login
     *@param a_oUIO user UIO
     *@param a_sHostPassword password
     *@param iLoginStatus login status
     *@return sign status
     */
    public ScProfToken ProfileLoginCR(String sUserName,
                                      String sPassWord,
                                      String sNewPassword
    ) throws Exception {
        String sStationId = (String) System.getProperty("user.name");
        if (sStationId.equals(null)) sStationId = "";
        sStationId = sStationId + " JDBC driver";

        SiCommunication oCommunication = null;

        //client sign-on request (NMSP Service Procedure 4)
        String sLogin = oProfForm.wrapLoginRequest(sUserName);
        StringBuffer sbResultMess = null;

        try {
            oCommunication = i_oScTransport.checkOut();
            sbResultMess = oCommunication.exchangeMessage(new StringBuffer(sLogin));
        } catch (Exception ee1) {
            if (ee1 instanceof java.io.IOException) {
                i_oScTransport.refresh(oCommunication);
                oCommunication = i_oScTransport.checkOut();
                sbResultMess = oCommunication.exchangeMessage(new StringBuffer(sLogin));
            } else throw ee1;
        } finally {
            i_oScTransport.checkIn(oCommunication);
        }

        String[] sTokenKey = oProfForm.unwrapChallengeLoginResponse(sbResultMess.toString());
        ScMD5 md = new ScMD5();
        String enPass = new String();
        if (sPassWord.length() < 30) {
            enPass = md.calc(sPassWord);
            enPass = md.calc(sTokenKey[1] + enPass);
        } else enPass = md.calc(sTokenKey[1] + sPassWord);

        ScProfToken oToken = new ScProfToken(sTokenKey[0], "\1");

        sLogin = oProfForm.wrapLoginRequest(sUserName,
                enPass,
                sStationId,
                "0",
                "",
                "",
                oContext,
                sNewPassword,
                oToken,
                "5");

        try {
            oCommunication = i_oScTransport.checkOut();
            sbResultMess = oCommunication.exchangeMessage(new StringBuffer(sLogin));
        } finally {
            i_oScTransport.checkIn(oCommunication);
        }

        return (ScProfToken) oProfForm.unwrapLoginResponse(sbResultMess.toString());

    }//METHOD ProfileLogin ENDS

    /**
     * Logout from Profile Server
     * @param ScProfToken token
     * @return int
     */
    public int ProfileLogout(ScProfToken oToken)
            throws Exception, SQLException {

        String sStationId = (String) System.getProperty("user.name");
        if (sStationId.equals(null)) sStationId = "";
        sStationId = sStationId + " JDBC driver";

        SiCommunication oCommunication = null;
        String sLogout = oProfForm.wrapLogoutRequest(oToken);
        StringBuffer sResultMess = null;

        try {
            oCommunication = i_oScTransport.checkOut();
            sResultMess = oCommunication.exchangeMessage(new StringBuffer(sLogout));
        } catch (Exception ee1) {
            if (ee1 instanceof java.io.IOException) {
                i_oScTransport.refresh(oCommunication);
                oCommunication = i_oScTransport.checkOut();
                sResultMess = oCommunication.exchangeMessage(new StringBuffer(sLogout));
            } else throw ee1;
        } finally {
            i_oScTransport.checkIn(oCommunication);

        }
        return 1;

    }

    /**
     * generic MRPC API
     * @param ScProfToken/ oToken/token;
     * @param String/a_sMRPCId/MRPC ID;
     * @param String/a_asMRPCArgs/arguments of MRPC;
     * @param String/a_sStoreForward/Store Forward Flag;
     * @return java.lang.String  reply message from host
     */
    public String ProfileMRPC(ScProfToken oToken,
                              String a_sMRPCId,
                              String a_sVersion,
                              String a_asMRPCArgs[],
                              String a_asSpv,     /// 09/09/03 MKT	//**MKT-XBAD
                              String a_sStoreForward,
                              String a_sOutputSize
    ) throws Exception, SQLException {

        String sMRPCResult = null;

        StringBuffer sResultMess = null;
        String sMRPCMess = oProfForm.wrapMrpcRequest(a_sMRPCId,
                a_sVersion,
                a_asMRPCArgs,
                a_asSpv,    // 09/09/03 MKT - XBAD Changes	//**MKT-XBAD
                a_sStoreForward,
                oToken);
        SiCommunication oCommunication = null;
        try {
            oCommunication = i_oScTransport.checkOut();
            sResultMess = oCommunication.exchangeMessage(new StringBuffer(sMRPCMess));
        } catch (Exception ee1) {
            if (ee1 instanceof java.io.IOException) {
                i_oScTransport.refresh(oCommunication);
                oCommunication = null;
                throw ee1;
            } else throw ee1;
        } finally {
            i_oScTransport.checkIn(oCommunication);
        }

        sMRPCResult = oProfForm.unwrapMrpcResponse(sResultMess.toString(), a_sOutputSize, a_sMRPCId);
        return sMRPCResult;
    }

    /**
     * generic SQL API
     * @param ScProfToken/oToken/token;
     * @param String/psSQLMessage/SQL statement;
     * @param String/psSQLQualifier/SQL qualifier;
     * @param String/a_sStoreForward/Store Forward Flag;
     * @return java.lang.String[]  reply message from host
     */
    public String[] ProfileSQL(ScProfToken oToken,
                               String psSQLMessage,
                               String psSQLQualifier,
                               String psStoreForward
    ) throws Exception, SQLException {

        String[] sSQLResult;

        //jiaq
        //long startPoint = System.currentTimeMillis();
        int iOriginalTimeOut = 0;
        String sSQLMess = oProfForm.wrapSqlRequest(psSQLMessage,
                psSQLQualifier,
                psStoreForward,
                oToken);
        StringBuffer sResultMess = null;
        SiCommunication oCommunication = null;
        try {
            oCommunication = i_oScTransport.checkOut();
            if (this.iReadTimeOut > 0)                                          // To be Added from here
            {
                iOriginalTimeOut = oCommunication.getReadTimeOut();
                oCommunication.setSoReadTimeOut(this.iReadTimeOut);
            }
            sResultMess = oCommunication.exchangeMessage(new StringBuffer(sSQLMess));
        } catch (Exception ee1) {
            if (ee1 instanceof java.io.IOException) {
                i_oScTransport.refresh(oCommunication);
                oCommunication = null;

                if (ee1 instanceof java.io.IOException
                        && (psSQLMessage.toLowerCase().startsWith("open cursor") || psSQLMessage.toLowerCase().startsWith("fetch"))) {
                    oCommunication = i_oScTransport.checkOut();
                    if ((psSQLMessage.toLowerCase().startsWith("open cursor")) ||
                            (this.iReadTimeOut == 0)) {
                        sResultMess = oCommunication.exchangeMessage(new StringBuffer(sSQLMess));
                    }
                } else {
                    if (this.iReadTimeOut < iOriginalTimeOut)
                        throw new java.io.IOException("Query Timed Out");
                    else
                        throw ee1;
                }
            } else throw ee1;
        } finally {
            if (this.iReadTimeOut > 0)
                oCommunication.setSoReadTimeOut(iOriginalTimeOut);
            i_oScTransport.checkIn(oCommunication);

        }
        if (((psSQLMessage.indexOf("OPEN") == 0) || (psSQLMessage.indexOf("EXECUTE") == 0)) && (!oContext.isEmpty())) {
            if (psSQLQualifier.indexOf("NOMETA") > 0)
                sSQLResult = oProfForm.unwrapCursorResponse(sResultMess.toString(), 1);
            else
                sSQLResult = oProfForm.unwrapCursorResponse(sResultMess.toString());
        } else sSQLResult = oProfForm.unwrapSqlResponse(sResultMess.toString());

        return sSQLResult;

    }//METHOD ProfileSQL ENDS

    /**
     * generic  API
     * @param
     *      ScProfToken/oToken/token;
     *      String/psHTMLMessage/generic message;
     *      String/a_sStoreForward/Store Forward Flag;
     *      String/sHeaderIndicator/e.g. HTML="6"
     * @return java.lang.String reply message from host
     */
    public String ProfileGeneric(ScProfToken oToken,
                                 String psMessage,
                                 String psStoreForward,
                                 String sHeaderIndicator
    ) throws Exception, SQLException {

        String sHTMLResult = new String();

        String sHTMLMess = oProfForm.wrapGenericRequest(psMessage,
                psStoreForward,
                oToken,
                sHeaderIndicator
        );
        StringBuffer sResultMess = null;
        SiCommunication oCommunication = null;
        try {
            oCommunication = i_oScTransport.checkOut();
            sResultMess = oCommunication.exchangeMessage(new StringBuffer(sHTMLMess));
        } catch (Exception ee1) {
            if (ee1 instanceof java.io.IOException) {
                i_oScTransport.refresh(oCommunication);
                oCommunication = null;
                throw ee1;
			            /*
			            if (ee1 instanceof java.io.IOException)
			            {
			                oCommunication = i_oScTransport.checkOut();
			                sResultMess = oCommunication.exchangeMessage(new StringBuffer(sHTMLMess));
		                }
		                */
            } else throw ee1;
        } finally {
            i_oScTransport.checkIn(oCommunication);
        }
        sHTMLResult = oProfForm.unwrapHtmlResponse(sResultMess.toString());

        return sHTMLResult;
    }//METHOD ProfileHTML ENDS

    /**
     * API used by multiple SQL statement
     * @param
     *      ScProfToken/oToken/token;
     *      String/psSQLMessage/SQL statement;
     *      String/psSQLQualifier/SQL qualifier;
     *      String/a_sStoreForward/Store Forward Flag;
     *      SiCommunication/oCommunication/communication object;
     *      boolean/lTransEnd/Commit indicator
     * @return java.lang.String reply message from host
     * @see
     *      ScMSQLManager
     */
    public String[] ProfileSQLTP(ScProfToken oToken,
                                 String psSQLMessage,
                                 String psSQLQualifier,
                                 String psStoreForward,
                                 SiCommunication oCommunication,
                                 boolean lTransEnd
    ) throws Exception, SQLException {


        if (oToken == null)
            ScDBError.check_error(-40, "Invalid Token");

        String sSQLMess = oProfForm.wrapSqlRequest(psSQLMessage,
                psSQLQualifier,
                psStoreForward,
                oToken);
        StringBuffer sResultMess = null;

        try {
            sResultMess = oCommunication.exchangeMessage(new StringBuffer(sSQLMess));
        } catch (Exception ee1) {
            if (ee1 instanceof java.io.IOException) {
                i_oScTransport.refresh(oCommunication);
                oCommunication = null;
                throw ee1;
            } else throw ee1;
        } finally {
            if (lTransEnd == true)
                i_oScTransport.checkIn(oCommunication);
        }
        String[] sSQLResult = oProfForm.unwrapSqlResponse(sResultMess.toString());

        return sSQLResult;

    }//METHOD ProfileSQL ENDS

    public ScTransport getTransport() {
        return i_oScTransport;
    }

    public String errorMessParse(String psMessageToCheck) {
        int string_size = psMessageToCheck.length();

        byte temp_buffer[] = new byte[string_size + 120];
        int message[] = new int[12];
        int message1[] = new int[12];
        ScUtils ScUtils_obj = new ScUtils();

        temp_buffer = ScUtils.stringToByte(psMessageToCheck);
        ScUtils_obj.parse_string(temp_buffer, 0, message, ScUtils.EXTRACT);
        ScUtils_obj.parse_string(temp_buffer, message[1], message1, ScUtils.EXTRACT);

        if (message1[0] > 2) {

            int k = 0;
            for (int j = 0; j < temp_buffer.length; j++) {
                k = (int) temp_buffer[j];
                if ((k < 48) || (k > 122)) temp_buffer[j] = (byte) ' ';
                if ((k > 59) && (k < 65)) temp_buffer[j] = (byte) ' ';

                for (int h = 2; h < message1[0]; h++) {
                    temp_buffer[message1[h]] = (byte) '|';
                }
            }
            return (ScUtils.byteToString(temp_buffer, temp_buffer.length)).trim();
        }

        return psMessageToCheck;
    }

    /**
     * Sets the socket read timeout period. Used for Query Timeout.
     * Reference ID : STMT0006 : 01/06/2006
     *
     * @param iTimeout The Timeout to be set
     */

    protected void setSoReadTimeOut(int iTimeout) {
        this.iReadTimeOut = iTimeout;
    }
}