/**
 * ScProfToken
 *
 * @version 1.0  Spet. 28 1999
 * @author Quansheng Jia
 * @see ScProfAccess
 */

package sanchez.him_pa;

import sanchez.utils.ScISKeys;

public class ScProfToken extends sanchez.him_pa.ScToken {
    private String sToken;
    private String sMessageId;
    private String sStartMessId;
    private long iMessageId = 0;
    private int iUserStatus;
    private long iCursorId = 0;
    private String sUserIdentification = "";
    private String sSreverChannelId = "";

    //Get Set methods
    public ScProfToken(String psToken, String psStartMessId) {
        sToken = psToken;
        sStartMessId = psStartMessId;
        iMessageId = 0;
    }

    public String getMessId() {
        synchronized (this) {
            iMessageId++;
        }
//		String stemp = String.valueOf(iMessageId);//+sStartMessId; //Manoj Thoniyil 10/25/2006
        String stemp = String.valueOf(iMessageId) + sStartMessId;
        return stemp;
    }

    public String getCursorId() {
        synchronized (this) {
            iCursorId++;
        }
        String stemp = String.valueOf(iCursorId) + String.valueOf(sToken.hashCode());
        return stemp;
    }

    public String getToken() {
        return sToken;
    }

    public int getUserStatus() {
        return iUserStatus;
    }

    public void setUserStatus(int iStatus) {
        if (iStatus != ScISKeys.iUSER_CLASS_PROXY && iStatus != ScISKeys.iUSER_CLASS_PRIVILEGED) {
            iUserStatus = ScISKeys.iUSER_CLASS_PROXY;
        }
        iUserStatus = iStatus;
    }

    public void setUserId(String userId) {
        sUserIdentification = userId;
    }

    public void setServerChannelId(String channelId) {
        sSreverChannelId = channelId;
    }

    public String getUserId() {
        return sUserIdentification;
    }

    public String getServerChannelId() {
        return sSreverChannelId;
    }
}