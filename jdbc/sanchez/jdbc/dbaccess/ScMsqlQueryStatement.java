/**
 * ScMsqlQueryStatement
 *
 * @version 1.0  Spet. 28 1999
 * @author Quansheng Jia
 * @see ScDBStatement
 */

package sanchez.jdbc.dbaccess;

import java.io.Serializable;
import java.sql.SQLException;
import java.util.Hashtable;

import sanchez.him_pa.utils.ScMSQLFormat;

public class ScMsqlQueryStatement extends sanchez.jdbc.dbaccess.ScDBStatement implements Serializable {
    int iRowCount = 0;
    String i_sSqlstmt;
    String i_sCursor;
    String i_sDba = "";
    String i_sRawData = "";
    String i_sSqlStatus = "0";
    Hashtable i_hColIndexColName = new Hashtable();
    public String sqlQuailfier = new String();
    public String spvInfo = new String();

    /**
     * Creates an instance of ScMsqlQueryStatement with the input parameters
     * @param sCursorID Cursor Id
     * @param sSql  String SQL Statement
     * @param fetchRow  Number of Rows to be fetched
     */
    public ScMsqlQueryStatement(String sCursorID, String sSql, int fetchRow) {
        super();
        i_sCursor = sCursorID;
        i_sSqlstmt = sSql;
        if (fetchRow > 0) sqlQuailfier = "/ROWS=" + Integer.toString(fetchRow);
    }

    /**
     * Sets the SQL String of this Statement 
     * @param String SQL Statement
     */
    public ScMsqlQueryStatement(String sSqlstmt) {
        super();
        i_sSqlstmt = sSqlstmt;
    }

    /**
     * Sets the Statement DBA Description 
     * @param DBA Description as String
     */
    public void setDBA(String dba) {
        i_sDba = dba;
    }

    /**
     * Sets the SQL Status as recived from DB
     * @param sSqlStatus The value to be set
     */
    public void setSqlStatus(String sSqlStatus) {
        i_sSqlStatus = sSqlStatus;
    }

    /**
     * Returns the Statement DBA Description 
     * @return DBA Description as String
     */
    public String getDBA() {
        return i_sDba;
    }

    /**
     * Returns the Column Alias map
     * @return hashTable containing the 
     *         Column Indeces as key, Alias names as values
     */
    public Hashtable getColIndexColNameMap() {
        return i_hColIndexColName;
    }

    /**
     * Sets the Column Aliases 
     * @param sSql String SQL to be parsed and Map to be  
     *        genrated with Column Indeces as key, Alias 
     *        names as values
     * @throws SQLException If any error occurs in setting the alias values
     */
    public void setColIndexColNameMap(String sSql)
            throws SQLException {
        i_hColIndexColName = ScMSQLFormat.parseQuery(sSql);
    }

    /**
     * Sets the Column Aliases 
     * @param ColIndexColName Column Indeces as key, Alias names as values
     * @throws SQLException If any error occurs in setting the alias values
     */
    public void setColIndexColNameMap(Hashtable ColIndexColName)
            throws SQLException {
        i_hColIndexColName = ColIndexColName;
    }

    /**
     * Returns the SQL Status returned from Profile 
     * @return String sql Status
     */
    public String getSqlStatus() {
        return i_sSqlStatus;
    }

    /**
     * Returns the SQL Statement 
     * @return String SQL Statement
     */
    public String getSqlStatment() {
        return i_sSqlstmt;
    }

    /**
     * Returns the supervisory information 
     * @return String supervisory information
     */
    public String getSpvInfo() {
        return spvInfo;
    }

    /**
     * Returns the Cursor Name
     * @return String cursor Name
     */
    public String getCursor() {
        return i_sCursor;
    }

    /**
     * Sets the Raw Data
     * @param sResult The Raw data to be Set
     */
    public void setReply(String sResult) {
        i_sRawData = sResult;

    }

    /**
     * Returns the Raw Data
     * @return String raw data
     */
    public String getReply() {
        return i_sRawData;
    }

    /**
     * When the sTempResult[2] consists "" and sTempResult[1] is 1, it
     * means the result is null. When the count is more than 0, but the
     * trim.length() is 0 it is in the form \r\n\r\n i.e. multiple rows
     * with single column. Whenever multi columns are selected 
     * the \t which comes in between of \r\n makes the cells formation ok
     * later on. Only the mutli row single column selection and
     * single row single column selection with no data ( null) requires
     * special treatment. The row count is required for the later part of 
     * the implementation.
     *
     * @param rowCount Row Count to be Set  
     */
    public void setRowCount(int rowCount) {
        iRowCount = rowCount;
    }

    /**
     * Returns the Row Count
     * @return row Count
     */
    public int getRowCount() {
        return iRowCount;
    }

}