package sanchez.io.db.jdbc;
/**
 * ScCursor is used to keep TP transaction object
 *
 * @version 1.0  May 12 1999
 * @author Quansheng Jia
 * @see ScMSQLManager,ScJDBCManager
 */

import java.sql.*;

import sanchez.ipc.SiCommunication;
import sanchez.him_pa.ScProfToken;
import sanchez.utils.*;

public class ScTransaction extends sanchez.base.ScObject {   //for JDBC connection
    Connection i_cConn;

    //for Profile TP connection
    String i_sBuffName;
    SiCommunication i_oCommunication;
    ScProfToken i_oToken;

    // Error code
    int i_iStatus = ScISKeys.iSUCCESS;
    String i_sException;

    /**
     * This method was created in VisualAge.
     */
    public ScTransaction() {

    }

    public ScTransaction(String a_sBuff, SiCommunication oCommunication, ScProfToken oToken) {

        i_sBuffName = a_sBuff;
        i_oCommunication = oCommunication;
        i_oToken = oToken;
    }

    public ScTransaction(Connection a_cConn) {
        i_cConn = a_cConn;
    }

    public String getBufferName() {
        return i_sBuffName;
    }

    public SiCommunication getCommunication() {
        return i_oCommunication;
    }

    public Connection getConnectionObject() {
        return i_cConn;
    }

    public ScProfToken getToken() {
        return i_oToken;
    }

    public void setException(String a_sException) {

        i_sException = a_sException;

    }

    public void setStatus(int a_iStatus) {

        i_iStatus = a_iStatus;

    }
}