/**
 * ScDBAccess
 * Database access interface
 *
 * @version 1.0  Spet. 28 1999
 * @author Quansheng Jia
 * @see ScProfAccess
 */

package sanchez.jdbc.dbaccess;

import java.sql.SQLException;
import java.util.Properties;

import sanchez.utils.ScMatrix;
import sanchez.him_pa.ScProfToken;

public interface ScDBAccess {
    /**
     * Logon to Profile using the input parameters
     * @param sUser The User Name
     * @param sPassword The password
     * @param sDatabase The Database details
     * @param pInfo The Property file containing additional parameters  
     * @param url The Database Url
     * @exception SQLException If any database access error occurrs
     * @exception Exception If any other error occurs.
     */
    public abstract void logon(String string1, String string2, String string3, Properties properties, String url)
            throws SQLException, Exception;

    /**
     * Logoff from Profile
     * @exception SQLException If any database access error occurrs
     * @exception Exception If any other error occurs.
     */
    public abstract void logoff()
            throws SQLException, Exception;

    /**
     * Executes and commits the buffer containts
     * @exception SQLException If any database access error occurrs
     * @exception Exception If any other error occurs.
     */
    public abstract void commit()
            throws SQLException, Exception;

    /**
     * Executes and commits the buffer containts
     * @exception SQLException If any database access error occurrs
     * @exception Exception If any other error occurs.
     */
    public abstract String[] batchCommit()
            throws SQLException, Exception;

    /**
     * Rolls back the executed Buffer
     * @exception SQLException If any database access error occurrs
     * @exception Exception If any other error occurs.
     */
    public abstract void rollback()
            throws SQLException, Exception;

    /**
     * Sets Autocommit on or off
     * @param flag Boolean true or else denoting on or off
     * @exception SQLException If any database access error occurrs
     * @exception Exception If any other error occurs.
     */
    public abstract void setAutoCommit(boolean flag)
            throws SQLException, Exception;

    /**
     * Opens a new ScMsqlQueryStatement statement with Cursor,
     * and input parameters.
     * @param sSql The String sql
     * @param fetchRow The number of rows ro be fetched  
     * @return ScDBStatement The new ScMsqlQueryStatement
     * @exception SQLException If any database access error occurrs
     * @exception Exception If any other error occurs.
     */
    public abstract ScDBStatement open(String sSql, int fetchRow)
            throws SQLException, Exception;

    /**
     * Closes the Cursor
     * @param dBStatement The ScMsqlQueryStatement contaning the cursor to be closed 
     * @exception SQLException If any database access error occurrs
     * @exception Exception If any other error occurs.
     */
    public abstract void closeQuery(ScDBStatement dBStatement)
            throws SQLException, Exception;

    /**
     * Closes the statement
     * @param dBStatement The ScDBStatement to be closed   
     * @exception SQLException If any database access error occurrs
     * @exception Exception If any other error occurs.
     */
    public abstract void close(ScDBStatement dBStatement)
            throws SQLException, Exception;

    /**
     * Gets the description of the Statement and Stores
     * in ScMsqlQueryStatement from the database.
     * @param dBStatement The ScMsqlQueryStatement to be used   
     * @exception SQLException If any database access error occurrs
     * @exception Exception If any other error occurs.
     */
    public abstract void describe(ScDBStatement dBStatement)
            throws SQLException, Exception;

    /**
     * Return the array of null statements
     * @param  dBStatement Instance of ScMsqlDDLStatement to be executed
     * @param  mMatrix
     * @exception SQLException If any database access error occurrs
     * @exception Exception If any other error occurs.
     */
    public abstract ScDBColumn[] parseExecuteDescribe(ScDBStatement dBStatement, ScMatrix mMatrix)
            throws SQLException, Exception;

    /**
     * Exceutes the CUD of CRUD operations.
     * @param dBStatement Instance of ScMsqlDDLStatement to be executed
     * @exception SQLException If any databse access error occurs
     * @exception Exception If any other exception occurs 
     */
    public abstract int executeUpdate(ScDBStatement dBStatement)
            throws SQLException, Exception;

    /**
     * Executes different types of dBStatement like
     * ScMsqlDDLStatement,ScMrpcStatement, ScStoreProStatement, ScGenericStatement etc.
     * @param dBStatement statement
     * @exception SQLException If any database access error occurs
     * @exception Exception If any other error occurs.
     */
    public void executeProcedure(ScDBStatement dBStatement)
            throws SQLException, Exception;

    /**
     * As because for both no record found and single row single
     * column null value sTempResult[2] = "", there was no differentiation
     * between the two. Additionally for multi row single column 
     * null value selects as because sTempResult[2] contained 
     * \r\n\r\n\r\n .... StringTokenizer on \r\n did not give 
     * expected result. For both these cases the total rows which is
     * a cell count became 0 and hence no record found condition resulted.
     * A logic to tokenize the \r\n\r\n\r\n by \r\n using indexOf logic
     * could have been used to replace the StringTokenizer logic. But
     * it would added the overhead of extreme testing as the whole
     * cell formation logic would have been affected by it.
     *
     * Hence a simple solution is implemented.
     *
     * When the sTempResult[2] consists "" and sTempResult[1] is 1, it
     * means the result is null. When the count is more than 0, but the
     * trim.length() is 0 it is in the form \r\n\r\n i.e. multiple rows
     * with single column. Whenever multi columns are selected 
     * the \t which comes in between of \r\n makes the cells formation ok
     * later on. Only the mutli row single column selection and
     * single row single column selection with no data ( null) requires
     * special treatment. The code later on takes care of multi row
     * single column null selection. Here single row single column 
     * null selection is being taken care of by setting the raw result as null.
     *
     * Statement Query timeout was not implemented.
     * There were two ways to implement the query timeout
     * Either using thread or using socket read timeout.
     * Following changes are the part of Socket Read Timeout
     * implementation.
     *
     * @param dBStatement ScMsqlQueryStatement statement
     * @exception SQLException If any database access error occurs
     * @exception Exception If any other error occurs.
     */
    public abstract int fetch(ScDBStatement dBStatement)
            throws SQLException, Exception;

    /**
     * Returns the Version. Returns Null currently.
     * @exception SQLException If any databse access error occurs
     * @exception Exception If any other exception occurs 
     */
    public abstract byte[] getVersion()
            throws SQLException, Exception;

    /**
     * Returns the default Prefetch set
     */
    public abstract int getDefaultPrefetch();

    /**
     * Return zero 
     */
    public abstract int getDefaultStreamChunkSize();

    /**
     * Not yet implemented
     * @exception SQLException If any databse access error occurs
     * @exception Exception If any other exception occurs 
     */
    public abstract void cancel()
            throws SQLException, Exception;

    /**
     * Not yet implemented
     * @param dBStatement
     * @param i
     * @param j
     * @exception SQLException If any databse access error occurs
     */
    public abstract void setWaitandAutoRollback(ScDBStatement dBStatement, int i, int j)
            throws SQLException;

    /**
     * Sets the default Row Prefetch Value
     * @param iDefaultRowPrefetch The Positive DefaultRowPrefetch value
     * @exception SQLDException If any error occurs 
     */
    public abstract void setDefaultRowPrefetch(int iDefaultRowPrefetch)
            throws SQLException;

    /**
     * Sets the Default Execute Batch  
     * @param iDefaultExecuteBatch value
     * @exception SQLException If any databse access error occurs
     */
    public abstract void setDefaultExecuteBatch(int iDefaultExecuteBatch)
            throws SQLException;

    /**
     * Gets the Buffer name in UpperCase
     * @exception SQLException If any databse access error occurs
     */
    public abstract String getBufferName()
            throws SQLException;

    /**
     * Gets the particular Token
     * @return ScProfToken token 
     * @exception SQLException If any databse access error occurs
     */
    public abstract ScProfToken getToken()
            throws SQLException;

    /**
     * Sets the socket read timeout period. Used for Query Timeout.
     * @param iTimeOut The query timeout to be set
     */
    public abstract void setQueryTimeout(int iTimeOut);
}

