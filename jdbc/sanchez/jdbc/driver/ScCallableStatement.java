/**
 * a CallableStatement object is used to execute a call to a database
 * stored procedure
 *
 * @version 1.0  Spet. 28 1999
 * @author Quansheng Jia
 * @see
 */

package sanchez.jdbc.driver;

import java.io.InputStream;
import java.io.Reader;
import java.math.BigDecimal;
import java.net.URL;
import java.sql.*;
import java.util.Calendar;

import sanchez.jdbc.dbaccess.*;

import java.util.Enumeration;

import java.util.Map;
import java.util.StringTokenizer;
import java.util.Vector;

import sanchez.base.ScBundle;
import sanchez.base.ScResourceKeys;
import sanchez.him_pa.utils.ScMSQLFormat;

import java.util.HashMap;
import java.util.Hashtable;

import sanchez.jdbc.dbaccess.ScDBError;

/**
 * The interface used to execute SQL
 * stored procedures.  JDBC provides a stored procedure
 * SQL escape that allows stored procedures to be called in a standard
 * way for all RDBMSs. This escape syntax has one form that includes
 * a result parameter and one that does not. If used, the result
 * parameter must be registered as an OUT parameter. The other parameters
 * can be used for input, output or both. Parameters are referred to
 * sequentially, by number. The first parameter is 1.
 * <P>
 * <blockquote><pre>
 *   {?= call &lt;procedure-name&gt;[&lt;arg1&gt;,&lt;arg2&gt;, ...]}
 *   {call &lt;procedure-name&gt;[&lt;arg1&gt;,&lt;arg2&gt;, ...]}
 * </pre></blockquote>
 * <P>
 * IN parameter values are set using the set methods inherited from
 * {@link PreparedStatement}.  The type of all OUT parameters must be
 * registered prior to executing the stored procedure; their values
 * are retrieved after execution via the <code>get</code> methods provided here.
 * <P>
 * A <code>CallableStatement</code> can return one {@link ResultSet} or
 * multiple <code>ResultSet</code> objets.  Multiple
 * <code>ResultSet</code> objects are handled using operations
 * inherited from {@link Statement}.
 * <P>
 * For maximum portability, a call's <code>ResultSet</code> objects and
 * update counts should be processed prior to getting the values of output
 * parameters.
 *
 *
 * @see Connection#prepareCall
 * @see ResultSet
 */
public class ScCallableStatement extends ScPreparedStatement implements CallableStatement {
    static final String SQL_MESS = new String("5");
    static final String HTML_MESS = new String("6");
    static final String LOGIN_REQUEST = new String("0");
    static final String MRPC_MESS = new String("3");
    static final String XML_MESS = new String("4");
    HashMap outTable = new HashMap(3);

    int fetchRows = 0;
    int prepare = 0;

    @Override
    public <T> T getObject(int parameterIndex, Class<T> type) {
        return null;
    }

    @Override
    public <T> T getObject(String parameterName, Class<T> type) {
        return null;
    }

    @Override
    public void setNClob(String parameterName, NClob value) {

    }

    @Override
    public void setNClob(String parameterName, Reader reader) {

    }

    @Override
    public void setNClob(String parameterName, Reader reader, long length) {

    }

    @Override
    public void setBlob(String parameterName, Blob x) {

    }

    @Override
    public void setBlob(String parameterName, InputStream inputStream) {

    }

    @Override
    public void setBlob(String parameterName, InputStream inputStream, long length) {

    }

    @Override
    public void setClob(String parameterName, Clob x) {

    }

    @Override
    public void setClob(String parameterName, Reader reader) {

    }

    @Override
    public void setClob(String parameterName, Reader reader, long length) {

    }

    @Override
    public void setNCharacterStream(String parameterName, Reader value) {

    }

    @Override
    public void setNCharacterStream(String parameterName, Reader value, long length) {

    }

    @Override
    public void setCharacterStream(String parameterName, Reader reader) {

    }

    @Override
    public void setCharacterStream(String parameterName, Reader reader, long length) {

    }

    @Override
    public void setBinaryStream(String parameterName, InputStream x) {

    }

    @Override
    public void setBinaryStream(String parameterName, InputStream x, long length) {

    }

    @Override
    public void setAsciiStream(String parameterName, InputStream x) {

    }

    @Override
    public void setAsciiStream(String parameterName, InputStream x, long length) {

    }

    @Override
    public Reader getCharacterStream(int parameterIndex) {
        return null;
    }

    @Override
    public Reader getCharacterStream(String parameterName) {
        return null;
    }

    @Override
    public Reader getNCharacterStream(int parameterIndex) {
        return null;
    }

    @Override
    public Reader getNCharacterStream(String parameterName) {
        return null;
    }

    @Override
    public String getNString(int parameterIndex) {
        return null;
    }

    @Override
    public String getNString(String parameterName) {
        return null;
    }

    @Override
    public SQLXML getSQLXML(int parameterIndex) {
        return null;
    }

    @Override
    public SQLXML getSQLXML(String parameterName) {
        return null;
    }

    @Override
    public void setSQLXML(int parameterIndex, SQLXML xmlObject) {
        super.setSQLXML(parameterIndex, xmlObject);
    }

    @Override
    public void setSQLXML(String parameterName, SQLXML xmlObject) {

    }

    @Override
    public NClob getNClob(int parameterIndex) {
        return null;
    }

    @Override
    public NClob getNClob(String parameterName) {
        return null;
    }

    @Override
    public void setNString(int parameterIndex, String value) {
        super.setNString(parameterIndex, value);
    }

    @Override
    public void setNString(String parameterName, String value) {

    }

    @Override
    public void setRowId(String parameterName, RowId x) {

    }

    @Override
    public RowId getRowId(String parameterName) {
        return null;
    }

    @Override
    public RowId getRowId(int parameterIndex) {
        return null;
    }

    /**
     *Constructs a ResultSet object using a connection and Statement
     *@param ScConnection cConnection
     *@param String sSqlStatement
     *   {call procedure_name[(?,?,...)]}
     *   {?=call procedure_name[(?,?,...)]}
     *   {call procedure_name}
     * @exception SQLException when database error occurs
     **/
    public ScCallableStatement(ScConnection cConnection, String sSqlStatement)
            throws SQLException {
        super(cConnection, sSqlStatement);
        resultSetType = ResultSet.TYPE_SCROLL_INSENSITIVE;
        resultSetConcurrency = ResultSet.CONCUR_READ_ONLY;
        connection.log("CallableStatement.ScCallableStatement(" + sSqlStatement + ")");
        if (sSqlStatement.toUpperCase().indexOf("CALL") < 0) {
            Object[] objs = {sSqlStatement};
            throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_CallableStatement, objs));
        }
    }

    /**
     * Constructs a ScCallableStatement object using a defined ScConnection,SqlStatement,resultsetType and resultSetConcurrency  
     * @param cConnection
     * @param sSqlStatement
     * @param resultSetType
     * @param resultSetConcurrency
     * @exception SQLException when database error occurs
     */
    public ScCallableStatement(ScConnection cConnection, String sSqlStatement, int resultSetType,
                               int resultSetConcurrency)
            throws SQLException {
        super(cConnection, sSqlStatement, resultSetType, resultSetConcurrency);

        if (resultSetConcurrency != ResultSet.CONCUR_READ_ONLY) {
            ScDBError.check_error(-54, Integer.toString(resultSetType));
            return;
        }

        resultSetType = ResultSet.TYPE_SCROLL_INSENSITIVE;
        resultSetConcurrency = ResultSet.CONCUR_READ_ONLY;

        if (sSqlStatement.toUpperCase().indexOf("CALL") < 0) {
            Object[] objs = {sSqlStatement};
            throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_CallableStatement, objs));
        }
    }

    public ScCallableStatement(ScConnection cConnection, String sSqlStatement, int resultSetType,
                               int resultSetConcurrency, int resultSetHoldability)
            throws SQLException {
        this(cConnection, sSqlStatement, resultSetType, resultSetConcurrency);
        this.resHoldabilty = resultSetHoldability;
    }

    /**
     * Executes a SQL statement that returns a single ResultSet.
     * @return a ResultSet that contains the data produced by the query; never null 
     * @exception SQLException if a database access error occurs
     */
    public ResultSet executeQuery() throws SQLException {
        connection.log("CallableStatement.executeQuery");
        ini();
        if (sSql.toUpperCase().indexOf("CALL") < 0) {
            Object[] objs = {sSql};
            throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_CallableStatement, objs));
        }

        Vector vInput = new Vector();
        Vector vOut = new Vector();

        parserInOut(vInput, vOut);

        Object[] sInput = new Object[vInput.size()];
        String[] sOut = new String[vOut.size()];
        int j = 0;
        Enumeration ev = vInput.elements();
        int ii = 0;
        while (ev.hasMoreElements()) {
            sInput[ii++] = ev.nextElement();
        }
        ii = 0;
        ev = vOut.elements();
        while (ev.hasMoreElements()) {
            sOut[ii] = (String) ev.nextElement();
            ii++;
        }

        String s = sSql.toUpperCase().trim();
        String serverClass = s.substring(s.indexOf("CALL") + 4, s.length()).trim();

        if (serverClass.indexOf("XML") == 0) {
            dBStatement = new ScGenericStatement((String) sInput[0]);
            dBStatement.setServerClass(XML_MESS);
        } else if (serverClass.indexOf("HTML") == 0) {
            dBStatement = new ScGenericStatement((String) sInput[0]);
            dBStatement.setServerClass(HTML_MESS);
        } else if (serverClass.indexOf("MRPC") == 0) {
            String mrpcId = (String) sInput[0];
            String[] params;
            String spv = null;
            String[] tempParams;
            /*** Manoj Thoniyil - 08/03/05
             *
             * Modified to allow SPV info as part of the input paramter array.
             *
             ***/
            if (sInput[1] instanceof String[]) {
                tempParams = (String[]) sInput[1];
                j = tempParams.length + 1;
            } else {
                tempParams = new String[sInput.length - 1];
                for (j = 1; j < sInput.length; j++)
                    tempParams[j - 1] = (String) sInput[j];
            }
            if (tempParams[j - 2].indexOf("SPV_AUTH=") == 0) {
                params = new String[tempParams.length - 1];
                spv = tempParams[j - 2].substring(9);
                for (j = 0; j < tempParams.length - 1; j++)
                    params[j] = tempParams[j];
            } else
                params = tempParams;

            if (spv == null)
                dBStatement = new ScMrpcStatement("1", mrpcId, params);
            else
                dBStatement = new ScMrpcStatement("1", mrpcId, params, spv);
            ((ScMrpcStatement) dBStatement).setOutputSize(Integer.toString(vOut.size()));
        } else {
            int index = serverClass.indexOf("(");
            if (index > 0) serverClass = serverClass.substring(0, index).trim();
            String[] params = new String[sInput.length];
            for (j = 0; j < sInput.length; j++)
                params[j] = (String) sInput[j];
            dBStatement = new ScStoreProStatement(serverClass, params);
            /* Manoj Thoniyil - 09/08/2005 */
            if (fetchRows > 0)
                if (dBStatement != null) ((ScStoreProStatement) dBStatement).sqlQuailfier = "ROWS=" + fetchRows;
            if (prepare > 0)
                if (dBStatement != null)
                    ((ScStoreProStatement) dBStatement).sqlQuailfier = ((ScStoreProStatement) dBStatement).sqlQuailfier + " PREPARE=" + prepare;
            /** **/
        }

        try {
            if (connection.getXAErrorFlag()) {
                connection.xaTable.addElement(dBStatement);
                return null;
            } else i_dDbAccess.executeProcedure(dBStatement);
        } catch (Exception e) {
            ScDBError.check_error(e);
            return null;
        }
        fetch(dBStatement, sOut);
        lastRs = new ScJdbcResultSet(connection, this);
        return lastRs;
    }

    /**
     * JDBC 2.0
     *
     * Gives the JDBC driver a hint as to the number of rows that should 
     * be fetched from the database when more rows are needed.  The number 
     * of rows specified affects only result sets created using this 
     * statement. If the value specified is zero, then the hint is ignored.
     * The default value is zero.
     *
     * @param rows the number of rows to fetch
     * @exception SQLException if a database access error occurs, or the
     * condition 0 <= rows <= this.getMaxRows() is not satisfied.
     */
    /* Manoj Thoniyil - 09/08/2005 */
    public void setFetchSize(int rows) throws SQLException {
        connection.log("CallableStatement.setFetchSize");

        if (rows <= 0) ScDBError.check_error(-32, "ScCallableStatement");
        fetchRows = rows;
    }

    /**
     * JDBC 2.0
     * Gives the JDBC driver a hint as to the number of values that should 
     * be fetched from the database when more rows are needed.  The number 
     * of values specified affects only result sets created using this 
     * statement. If the value specified is zero, then the hint is ignored.
     * The default value is zero.
     *
     * @param value
     * @exception SQLException if a database access error occurs, or the
     * condition 0 <= rows <= this.getMaxRows() is not satisfied.
     */
    /* Manoj Thoniyil - 11/14/2005 */
    public void setPrepare(int value) throws SQLException {
        connection.log("CallableStatement.setPrepare");

        if (value <= 0) ScDBError.check_error(-32, "ScCallableStatement");
        prepare = value;
    }

    /**
     * Executes an SQL INSERT, UPDATE or DELETE statement. In addition,
     * SQL statements that return nothing, such as SQL DDL statements,
     * can be executed.
     * @return integer 0 if the resultset returns nothing
     * @return integer 1 if the resultset returns value
     * @exception SQLException if a database access error occurs
     */

    public int executeUpdate() throws SQLException {
        connection.log("CallableStatement.executeUpdate");
        ResultSet rResult = executeQuery();
        if (rResult == null) return 0;
        return 1;
    }

    /**
     * Parses the input to initialize values of host variables with the corresponding values from SQL DML statement
     * @param vInput
     * @param vOut
     * @exception SQLException if a database access error occurs
     */
    private void parserInOut(Vector vInput, Vector vOut)
            throws SQLException {
        if (sSql.indexOf('(') < 0) return;
        String sParam = sSql.substring(sSql.indexOf('(') + 1, sSql.lastIndexOf(')'));
        StringTokenizer parser = new StringTokenizer(sParam, ",");
        String sTemp;

        while (parser.hasMoreElements()) {
            sTemp = ((String) parser.nextElement()).trim();
            if (sTemp.indexOf(":D") != 0) vInput.addElement(sTemp);
            else if (sTemp.indexOf(":D") == 0) {
                String o;
                Object value;
                String s;
                for (int i = 1; i < hSqlQaulifier.size() + 1; i++) {
                    o = String.valueOf(i);
                    value = hSqlQaulifier.get(o);
                    s = "";

                    if (sTemp.equalsIgnoreCase(":D" + o)) {
                        if (value instanceof String) s = ((String) value).trim();
                        if (s.indexOf("out|") == 0) {
                            vOut.addElement(s.substring(s.indexOf('|') + 1, s.length()));
                            outTable.put(o, new Integer(outTable.size() + 1));
                        } else if (s.equalsIgnoreCase("?")) {
                            ScDBError.check_error(256);
                        } else vInput.addElement(value);
                    }//end of if (sTemp.equalsIgnoreCase(":D"+o))

                } //end of for
            }//end of else if (sTemp.indexOf(":D")==0)


        }// end of while


    }

    /**
     * Registers the OUT parameter in ordinal position
     * <code>parameterIndex</code> to the JDBC type
     * <code>sqlType</code>.  All OUT parameters must be registered
     * before a stored procedure is executed.
     * <p>
     * The JDBC type specified by <code>sqlType</code> for an OUT
     * parameter determines the Java type that must be used
     * in the <code>get</code> method to read the value of that parameter.
     * <p>
     * If the JDBC type expected to be returned to this output parameter
     * is specific to this particular database, <code>sqlType</code>
     * should be <code>java.sql.Types.OTHER</code>.  The method
     * {@link #getObject} retrieves the value.
     * @param parameterIndex the first parameter is 1, the second is 2,
     * and so on
     * @param sqlType the JDBC type code defined by <code>java.sql.Types</code>.
     * If the parameter is of type Numeric or Decimal, the version of
     * <code>registerOutParameter</code> that accepts a scale value
     * should be used.
     * @exception SQLException if a database access error occurs
     * @see Types
     */
    public void registerOutParameter(int parameterIndex, int sqlType)
            throws SQLException {
        connection.log("CallableStatement.registerOutParameter");
        verify(parameterIndex);
        hSqlQaulifier.put(Integer.toString(parameterIndex), "out|" + String.valueOf(sqlType));
    }

    /**
     * Registers the parameter in ordinal position
     * <code>parameterIndex</code> to be of JDBC type
     * <code>sqlType</code>.  This method must be called
     * before a stored procedure is executed.
     * <p>
     * The JDBC type specified by <code>sqlType</code> for an OUT
     * parameter determines the Java type that must be used
     * in the <code>get</code> method to read the value of that parameter.
     * <p>
     * This version of <code>registerOutParameter</code> should be
     * used when the parameter is of JDBC type <code>NUMERIC</code>
     * or <code>DECIMAL</code>.
     * @param parameterIndex the first parameter is 1, the second is 2,
     * and so on
     * @param sqlType SQL type code defined by <code>java.sql.Types</code>.
     * @param scale the desired number of digits to the right of the
     * decimal point.  It must be greater than or equal to zero.
     * @exception SQLException if a database access error occurs
     * @see Types
     */
    public void registerOutParameter(int parameterIndex, int sqlType, int scale)
            throws SQLException {
        connection.log("CallableStatement.registerOutParameter");
        verify(parameterIndex);
        hSqlQaulifier.put(Integer.toString(parameterIndex), "out|" + String.valueOf(sqlType));
    }

    /**
     * Indicates whether or not the last OUT parameter read had the value of
     * SQL NULL.  Note that this method should be called only after
     * calling the <code>get</code> method; otherwise, there is no value to use in
     * determining whether it is <code>null</code> or not.
     * @return <code>true</code> if the last parameter read was SQL NULL;
     * <code>false</code> otherwise.
     * @exception SQLException if a database access error occurs
     */
    public boolean wasNull() throws SQLException {
        connection.log("CallableStatement.wasNull");
        boolean b = false;
        if (lastRs.absolute(1)) {
            b = lastRs.wasNull();
        }
        return b;
    }

    /**
     * Retrieves the value of a JDBC <code>CHAR</code>, <code>VARCHAR</code>,
     * or <code>LONGVARCHAR</code> parameter as a <code>String</code> in
     * the Java programming language.
     * <p>
     * For the fixed-length type JDBC CHAR, the <code>String</code> object
     * returned has exactly the same value the JDBC CHAR value had in the
     * database, including any padding added by the database.
     * @param parameterIndex the first parameter is 1, the second is 2,
     * and so on
     * @return the parameter value. If the value is SQL NULL, the result
     * is <code>null</code>.
     * @exception SQLException if a database access error occurs
     */
    public String getString(int parameterIndex) throws SQLException {
        connection.log("CallableStatement.getString");
        String s = null;
        if (lastRs.absolute(1)) {
            s = lastRs.getString(checkOutBind(parameterIndex));
        }
        lastRs.beforeFirst();
        return s;
    }

    /**
     * Checks if the ResultSet pointer points before the first row and throws error if it is so.
     * @param parameterIndex
     * @return
     * @exception SQLException if a database access error occurs
     */
    private int checkOutBind(int parameterIndex)
            throws SQLException {
        Integer index = (Integer) outTable.get(String.valueOf(parameterIndex));
        if (index == null) {
            lastRs.beforeFirst();
            ScDBError.check_error(208);
        }
        return index.intValue();
    }

    /**
     * Gets the value of a JDBC BIT parameter as a <code>boolean</code>
     * in the Java programming language.
     * @param parameterIndex the first parameter is 1, the second is 2,
     * and so on
     * @return the parameter value.  If the value is SQL NULL, the result
     * is <code>false</code>.
     * @exception SQLException if a database access error occurs
     */
    public boolean getBoolean(int parameterIndex) throws SQLException {
        connection.log("CallableStatement.getBoolean");
        boolean b = false;
        if (lastRs.absolute(1)) {
            b = lastRs.getBoolean(checkOutBind(parameterIndex));
        }
        lastRs.beforeFirst();
        return b;
    }

    /**
     * Gets the value of a JDBC TINYINT parameter as a <code>byte</code>
     * in the Java programming language.
     * @param parameterIndex the first parameter is 1, the second is 2,
     * and so on
     * @return the parameter value.  If the value is SQL NULL, the result
     * is 0.
     * @exception SQLException if a database access error occurs
     */
    public byte getByte(int parameterIndex) throws SQLException {
        connection.log("CallableStatement.getByte");
        byte b = 0;
        if (lastRs.absolute(1)) {
            b = lastRs.getByte(checkOutBind(parameterIndex));
        }
        lastRs.beforeFirst();
        return b;
    }

    /**
     * Gets the value of a JDBC SMALLINT parameter as a <code>short</code>
     * in the Java programming language.
     * @param parameterIndex the first parameter is 1, the second is 2,
     * and so on
     * @return the parameter value.  If the value is SQL NULL, the result
     * is 0.
     * @exception SQLException if a database access error occurs
     */
    public short getShort(int parameterIndex) throws SQLException {
        connection.log("CallableStatement.getShort");
        short b = 0;
        if (lastRs.absolute(1)) {
            b = lastRs.getShort(checkOutBind(parameterIndex));
        }
        lastRs.beforeFirst();
        return b;
    }

    /**
     * Gets the value of a JDBC INTEGER parameter as an <code>int</code>
     * in the Java programming language.
     * @param parameterIndex the first parameter is 1, the second is 2,
     * and so on
     * @return the parameter value.  If the value is SQL NULL, the result
     * is 0.
     * @exception SQLException if a database access error occurs
     */
    public int getInt(int parameterIndex) throws SQLException {
        connection.log("CallableStatement.getInt");
        int b = 0;
        if (lastRs.absolute(1)) {
            b = lastRs.getInt(checkOutBind(parameterIndex));
        }
        lastRs.beforeFirst();
        return b;
    }

    /**
     * Gets the value of a JDBC BIGINT parameter as a <code>long</code>
     * in the Java programming language.
     * @param parameterIndex the first parameter is 1, the second is 2,
     * and so on
     * @return the parameter value.  If the value is SQL NULL, the result
     * is 0.
     * @exception SQLException if a database access error occurs
     */
    public long getLong(int parameterIndex) throws SQLException {
        connection.log("CallableStatement.getLong");
        long b = 0;
        if (lastRs.absolute(1)) {
            b = lastRs.getLong(checkOutBind(parameterIndex));
        }
        lastRs.beforeFirst();
        return b;
    }

    /**
     * Gets the value of a JDBC FLOAT parameter as a <code>float</code>
     * in the Java programming language.
     * @param parameterIndex the first parameter is 1, the second is 2,
     * and so on
     * @return the parameter value.  If the value is SQL NULL, the result
     * is 0.
     * @exception SQLException if a database access error occurs
     */
    public float getFloat(int parameterIndex) throws SQLException {
        connection.log("CallableStatement.getFloat");
        float b = 0;
        if (lastRs.absolute(1)) {
            b = lastRs.getFloat(checkOutBind(parameterIndex));
        }
        lastRs.beforeFirst();
        return b;
    }

    /**
     * Gets the value of a JDBC DOUBLE parameter as a <code>double</code>
     * in the Java programming language.
     * @param parameterIndex the first parameter is 1, the second is 2,
     * and so on
     * @return the parameter value.  If the value is SQL NULL, the result
     * is 0.
     * @exception SQLException if a database access error occurs
     */
    public double getDouble(int parameterIndex) throws SQLException {
        connection.log("CallableStatement.getDouble");
        double b = 0;
        if (lastRs.absolute(1)) {
            b = lastRs.getDouble(checkOutBind(parameterIndex));
        }
        lastRs.beforeFirst();
        return b;
    }


    /**
     * Gets the value of a JDBC <code>NUMERIC</code> parameter as a
     * <code>java.math.BigDecimal</code> object with scale digits to
     * the right of the decimal point.
     * @param parameterIndex the first parameter is 1, the second is 2,
     * and so on
     * @param scale the number of digits to the right of the decimal point
     * @return the parameter value.  If the value is SQL NULL, the result is
     * <code>null</code>.
     * @exception SQLException if a database access error occurs
     * @deprecated
     */
    public BigDecimal getBigDecimal(int parameterIndex, int scale)
            throws SQLException {
        connection.log("CallableStatement.getBigDecimal");
        BigDecimal b = BigDecimal.valueOf(0);
        if (lastRs.absolute(1)) {
            b = lastRs.getBigDecimal(checkOutBind(parameterIndex), scale);
        }
        lastRs.beforeFirst();
        return b;
    }

    /**
     * Gets the value of a JDBC <code>BINARY</code> or <code>VARBINARY</code>
     * parameter as an array of <code>byte</code> vlaures in the Java
     * programming language.
     * @param parameterIndex the first parameter is 1, the second is 2,
     * and so on
     * @return the parameter value.  If the value is SQL NULL, the result is
     *  <code>null</code>.
     * @exception SQLException if a database access error occurs
     */
    public byte[] getBytes(int parameterIndex) throws SQLException {
        connection.log("CallableStatement.getBytes");
        byte[] b = null;
        if (lastRs.absolute(1)) {
            b = lastRs.getBytes(checkOutBind(parameterIndex));
        }
        lastRs.beforeFirst();
        return b;
    }

    /**
     * Gets the value of a JDBC <code>DATE</code> parameter as a
     * <code>java.sql.Date</code> object.
     * @param parameterIndex the first parameter is 1, the second is 2,
     * and so on
     * @return the parameter value.  If the value is SQL NULL, the result
     * is <code>null</code>.
     * @exception SQLException if a database access error occurs
     */
    public java.sql.Date getDate(int parameterIndex) throws SQLException {
        connection.log("CallableStatement.getDate");
        java.sql.Date b = null;
        if (lastRs.absolute(1)) {
            b = lastRs.getDate(checkOutBind(parameterIndex));
        }
        lastRs.beforeFirst();
        return b;
    }

    /**
     * Get the value of a JDBC <code>TIME</code> parameter as a
     * <code>java.sql.Time</code> object.
     * @param parameterIndex the first parameter is 1, the second is 2,
     * and so on
     * @return the parameter value.  If the value is SQL NULL, the result
     * is <code>null</code>.
     * @exception SQLException if a database access error occurs
     */
    public java.sql.Time getTime(int parameterIndex) throws SQLException {
        connection.log("CallableStatement.getTime");
        java.sql.Time b = null;
        if (lastRs.absolute(1)) {
            b = lastRs.getTime(checkOutBind(parameterIndex));
        }
        lastRs.beforeFirst();
        return b;
    }

    /**
     * Gets the value of a JDBC <code>TIMESTAMP</code> parameter as a
     * <code>java.sql.Timestamp</code> object.
     * @param parameterIndex the first parameter is 1, the second is 2,
     * and so on
     * @return the parameter value.  If the value is SQL NULL, the result
     * is <code>null</code>.
     * @exception SQLException if a database access error occurs
     */
    public java.sql.Timestamp getTimestamp(int parameterIndex)
            throws SQLException {

        connection.log("CallableStatement.getTimestamp");
        java.sql.Timestamp b = null;
        if (lastRs.absolute(1)) {
            b = lastRs.getTimestamp(checkOutBind(parameterIndex));
        }
        lastRs.beforeFirst();
        return b;
    }

    //----------------------------------------------------------------------
    // Advanced features:


    /**
     * Gets the value of a parameter as an object in the Java
     * programming language.
     * <p>
     * This method returns a Java object whose type corresponds to the JDBC
     * type that was registered for this parameter using the method
     * <code>registerOutParameter</code>.  By registering the target JDBC
     * type as <code>java.sql.Types.OTHER</code>, this method can be used
     * to read database-specific abstract data types.
     * @param parameterIndex The first parameter is 1, the second is 2,
     * and so on
     * @return A <code>java.lang.Object</code> holding the OUT parameter value.
     * @exception SQLException if a database access error occurs
     * @see Types
     */
    public Object getObject(int parameterIndex) throws SQLException {
        connection.log("CallableStatement.getObject");
        Object b = null;
        if (lastRs.absolute(1)) {
            b = lastRs.getObject(checkOutBind(parameterIndex));
        }
        lastRs.beforeFirst();
        return b;
    }


    //--------------------------JDBC 2.0-----------------------------

    /**
     * JDBC 2.0
     *
     * Gets the value of a JDBC <code>NUMERIC</code> parameter as a
     * <code>java.math.BigDecimal</code> object with as many digits to the
     * right of the decimal point as the value contains.
     * @param parameterIndex the first parameter is 1, the second is 2,
     * and so on
     * @return the parameter value in full precision.  If the value is
     * SQL NULL, the result is <code>null</code>.
     * @exception SQLException if a database access error occurs
     */
    public BigDecimal getBigDecimal(int parameterIndex) throws SQLException {
        connection.log("CallableStatement.getBigDecimal");
        BigDecimal b = BigDecimal.valueOf(0);
        if (lastRs.absolute(1)) {
            b = lastRs.getBigDecimal(checkOutBind(parameterIndex));
        }
        lastRs.beforeFirst();
        return b;
    }

    /**
     * JDBC 2.0
     *
     * Returns an object representing the value of OUT parameter
     * <code>i</code> and uses <code>map</code> for the custom
     * mapping of the parameter value.
     * <p>
     * This method returns a Java object whose type corresponds to the
     * JDBC type that was registered for this parameter using the method
     * <code>registerOutParameter</code>.  By registering the target
     * JDBC type as <code>java.sql.Types.OTHER</code>, this method can
     * be used to read database-specific abstract data types.
     * @param i the first parameter is 1, the second is 2, and so on
     * @param map the mapping from SQL type names to Java classes
     * @return a java.lang.Object holding the OUT parameter value.
     * @exception SQLException if a database access error occurs
     */
    public Object getObject(int i, java.util.Map map) throws SQLException {
        connection.log("CallableStatement.getObject");
        Object b = null;
        if (lastRs.absolute(1)) {
            b = lastRs.getObject(checkOutBind(i), map);
        }
        lastRs.beforeFirst();
        return b;
    }

    /**
     * JDBC 2.0
     *
     * Gets the value of a JDBC <code>REF(&lt;structured-type&gt;)</code>
     * parameter as a {@link Ref} object in the Java programming language.
     * @param i the first parameter is 1, the second is 2,
     * and so on
     * @return the parameter value as a <code>Ref</code> object in the
     * Java programming language.  If the value was SQL NULL, the value
     * <code>null</code> is returned.
     * @exception SQLException if a database access error occurs
     */
    public Ref getRef(int i) throws SQLException {
        connection.log("CallableStatement.getRef");
        Ref b = null;
        if (lastRs.absolute(1)) {
            b = lastRs.getRef(checkOutBind(i));
        }
        lastRs.beforeFirst();
        return b;
    }

    /**
     * JDBC 2.0
     *
     * Gets the value of a JDBC <code>BLOB</code> parameter as a
     * {@link Blob} object in the Java programming language.
     * @param i the first parameter is 1, the second is 2, and so on
     * @return the parameter value as a <code>Blob</code> object in the
     * Java programming language.  If the value was SQL NULL, the value
     * <code>null</code> is returned.
     * @exception SQLException if a database access error occurs
     */
    public Blob getBlob(int i) throws SQLException {
        connection.log("CallableStatement.getBlob");
        Blob b = null;
        if (lastRs.absolute(1)) {
            b = lastRs.getBlob(checkOutBind(i));
        }
        lastRs.beforeFirst();
        return b;
    }

    /**
     * JDBC 2.0
     *
     * Gets the value of a JDBC <code>CLOB</code> parameter as a
     * <code>Clob</code> object in the Java programming language.
     * @param i the first parameter is 1, the second is 2, and
     * so on
     * @return the parameter value as a <code>Clob</code> object in the
     * Java programming language.  If the value was SQL NULL, the
     * value <code>null</code> is returned.
     * @exception SQLException if a database access error occurs
     */
    public Clob getClob(int i) throws SQLException {
        connection.log("CallableStatement.getClob");
        Clob b = null;
        if (lastRs.absolute(1)) {
            b = lastRs.getClob(checkOutBind(i));
        }
        lastRs.beforeFirst();
        return b;
    }

    /**
     * JDBC 2.0
     *
     * Gets the value of a JDBC <code>ARRAY</code> parameter as an
     * {@link Array} object in the Java programming language.
     * @param i the first parameter is 1, the second is 2, and
     * so on
     * @return the parameter value as an <code>Array</code> object in
     * the Java programming language.  If the value was SQL NULL, the
     * value <code>null</code> is returned.
     * @exception SQLException if a database access error occurs
     */
    public Array getArray(int i) throws SQLException {
        connection.log("CallableStatement.getArray");
        Array b = null;
        if (lastRs.absolute(1)) {
            b = lastRs.getArray(checkOutBind(i));
        }
        lastRs.beforeFirst();
        return b;
    }

    /**
     * Gets the value of a JDBC <code>DATE</code> parameter as a
     * <code>java.sql.Date</code> object, using
     * the given <code>Calendar</code> object
     * to construct the date.
     * With a <code>Calendar</code> object, the driver
     * can calculate the date taking into account a custom timezone and locale.
     * If no <code>Calendar</code> object is specified, the driver uses the
     * default timezone and locale.
     *
     * @param parameterIndex the first parameter is 1, the second is 2,
     * and so on
     * @param cal the <code>Calendar</code> object the driver will use
     *            to construct the date
     * @return the parameter value.  If the value is SQL NULL, the result is
     * <code>null</code>.
     * @exception SQLException if a database access error occurs
     */
    public java.sql.Date getDate(int parameterIndex, Calendar cal)
            throws SQLException {
        java.sql.Date b = null;
        if (lastRs.absolute(1)) {
            b = lastRs.getDate(checkOutBind(parameterIndex), cal);
        }
        lastRs.beforeFirst();
        return b;
    }

    /**
     * Gets the value of a JDBC <code>TIME</code> parameter as a
     * <code>java.sql.Time</code> object, using
     * the given <code>Calendar</code> object
     * to construct the time.
     * With a <code>Calendar</code> object, the driver
     * can calculate the time taking into account a custom timezone and locale.
     * If no <code>Calendar</code> object is specified, the driver uses the
     * default timezone and locale.
     *
     * @param parameterIndex the first parameter is 1, the second is 2,
     * and so on
     * @param cal the <code>Calendar</code> object the driver will use
     *            to construct the time
     * @return the parameter value; if the value is SQL NULL, the result is
     * <code>null</code>.
     * @exception SQLException if a database access error occurs
     */
    public java.sql.Time getTime(int parameterIndex, Calendar cal)
            throws SQLException {
        connection.log("CallableStatement.getTime");
        java.sql.Time b = null;
        if (lastRs.absolute(1)) {
            b = lastRs.getTime(checkOutBind(parameterIndex), cal);
        }
        lastRs.beforeFirst();
        return b;
    }

    /**
     * Gets the value of a JDBC <code>TIMESTAMP</code> parameter as a
     * <code>java.sql.Timestamp</code> object, using
     * the given <code>Calendar</code> object to construct
     * the <code>Timestamp</code> object.
     * With a <code>Calendar</code> object, the driver
     * can calculate the timestamp taking into account a custom timezone and locale.
     * If no <code>Calendar</code> object is specified, the driver uses the
     * default timezone and locale.
     *
     *
     * @param parameterIndex the first parameter is 1, the second is 2,
     * and so on
     * @param cal the <code>Calendar</code> object the driver will use
     *            to construct the timestamp
     * @return the parameter value.  If the value is SQL NULL, the result is
     * <code>null</code>.
     * @exception SQLException if a database access error occurs
     */
    public java.sql.Timestamp getTimestamp(int parameterIndex, Calendar cal)
            throws SQLException {
        connection.log("CallableStatement.getTimestamp");
        java.sql.Timestamp b = null;
        if (lastRs.absolute(1)) {
            b = lastRs.getTimestamp(checkOutBind(parameterIndex), cal);
        }
        lastRs.beforeFirst();
        return b;
    }


    /**
     * JDBC 2.0
     *
     * Registers the designated output parameter.  This version of
     * the method <code>registerOutParameter</code>
     * should be used for a user-named or REF output parameter.  Examples
     * of user-named types include: STRUCT, DISTINCT, JAVA_OBJECT, and
     * named array types.
     *
     * Before executing a stored procedure call, you must explicitly
     * call <code>registerOutParameter</code> to register the type from
     * <code>java.sql.Types</code> for each
     * OUT parameter.  For a user-named parameter the fully-qualified SQL
     * type name of the parameter should also be given, while a REF
     * parameter requires that the fully-qualified type name of the
     * referenced type be given.  A JDBC driver that does not need the
     * type code and type name information may ignore it.   To be portable,
     * however, applications should always provide these values for
     * user-named and REF parameters.
     *
     * Although it is intended for user-named and REF parameters,
     * this method may be used to register a parameter of any JDBC type.
     * If the parameter does not have a user-named or REF type, the
     * typeName parameter is ignored.
     *
     * <P><B>Note:</B> When reading the value of an out parameter, you
     * must use the <code>getXXX</code> method whose Java type XXX corresponds to the
     * parameter's registered SQL type.
     *
     * @param parameterIndex the first parameter is 1, the second is 2,...
     * @param sqlType a value from {@link java.sql.Types}
     * @param typeName the fully-qualified name of an SQL structured type
     * @exception SQLException if a database-access error occurs
     * @see Types
     */
    public void registerOutParameter(int paramIndex, int sqlType, String typeName)
            throws SQLException {
        connection.log("CallableStatement.registerOutParameter");
        verify(paramIndex);
        hSqlQaulifier.put(Integer.toString(paramIndex), "out|" + String.valueOf(sqlType) + "|" + typeName);
    }

    /**
     * Builds ResultSet components according to replies(MRPC) from server
     * @param dBStatement
     * @param sOut
     * @exception SQLException if a database access error occurs
     */
    private void fetch(ScDBStatement dBStatement, String[] sOut)
            throws SQLException {
        if (dBStatement instanceof ScGenericStatement) {
            ScGenericStatement stmt = (ScGenericStatement) dBStatement;
            ScMSQLFormat.parseRawResult(cells, stmt.getReply(), 0);
            stmt.setReply(null);    //release memory RMX
            i_iTotalRows = 1;
            gotLastBatch = true;

            String di;
            if (sOut[0].indexOf('|') > 0)
                di = sOut[0].substring(sOut[0].indexOf('|') + 1, sOut[0].length());
            else di = "reply";
            setDba("HTML/XML", di, String.valueOf(stmt.getReply().length()), "T", "HTML/XML Reply Message", "Y", "");
            return;
        } else if (dBStatement instanceof ScMrpcStatement) {
            ScMrpcStatement stmt = (ScMrpcStatement) dBStatement;
            ScMSQLFormat.parseMrpcRawResult(cells, stmt.getReply(), 0, stmt.getOutputSize());
            i_iTotalRows = cells.rows();
            stmt.setReply(null);    //release memory RMX
            gotLastBatch = true;
            String di;
            String type;
            description = new String[sOut.length][10];

            for (int j = 0; j < sOut.length; j++) {

                if (sOut[j].indexOf('|') > 0) {
                    di = sOut[j].substring(sOut[j].indexOf('|') + 1, sOut[j].length());
                    type = sOut[j].substring(0, sOut[j].indexOf('|'));
                } else {
                    di = "col" + (j + 1);
                    type = sOut[j];
                }

                setDba("MRPC" + stmt.getMrpcID(), di, "3000", type, "", "", "");
                //setDba("MRPC",di,"3000",type,"","","");
            }
            return;

        } else if (dBStatement instanceof ScStoreProStatement) {
            ScStoreProStatement stmt = (ScStoreProStatement) dBStatement;
            ScMSQLFormat.parseRawResult(cells, stmt.getReply(), 0);
            i_iTotalRows = cells.rows();
            stmt.setReply(null);    //release memory RMX
            gotLastBatch = true;
            String di;
            String type;
            description = new String[sOut.length][10];

            for (int j = 0; j < sOut.length; j++) {

                if (sOut[j].indexOf('|') > 0) {
                    di = sOut[j].substring(sOut[j].indexOf('|') + 1, sOut[j].length());
                    type = sOut[j].substring(0, sOut[j].indexOf('|'));
                } else {
                    di = "col" + (j + 1);
                    type = sOut[j];
                }

                setDba("MRPC", di, "3000", type, "", "", "");
            }
            return;
        }
    }
    //FID,DI,LEN,DFT,TYP,DES,SIZ,REQ,DEC,NOD

    /**
     * Sets the description
     * @param FID
     * @param DI
     * @param LEN
     * @param TYP
     * @param DES
     * @param REQ
     * @param DEC
     */
    private void setDba(String FID, String DI, String LEN, String TYP, String DES, String REQ, String DEC) {
        if (i_ahHash == null) i_ahHash = new Hashtable(10);
        int i = i_ahHash.size();
        i_ahHash.put(new Integer(i_ahHash.size() + 1), DI);
        description[i][0] = FID;
        description[i][1] = DI;
        description[i][2] = LEN;
        description[i][4] = TYP;
        description[i][5] = DES;
        description[i][7] = REQ;
        description[i][8] = DEC;

    }

    /**
     * Clears the table values
     */
    protected void ini() {
        super.ini();
        outTable.clear();
    }

    //  --------------------------JDBC 3.0-----------------------------
    /* (non-Javadoc)
     * @see java.sql.CallableStatement#registerOutParameter(java.lang.String, int)
     */
    public void registerOutParameter(String parameterName, int sqlType) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#registerOutParameter(java.lang.String, int)");

    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#registerOutParameter(java.lang.String, int, int)
     */
    public void registerOutParameter(String parameterName, int sqlType, int scale) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#registerOutParameter(java.lang.String, int, int)");

    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#registerOutParameter(java.lang.String, int, java.lang.String)
     */
    public void registerOutParameter(String parameterName, int sqlType, String typeName) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#registerOutParameter(java.lang.String, int, java.lang.String)");

    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#getURL(int)
     */
    public URL getURL(int parameterIndex) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#getURL(int)");
        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#setURL(java.lang.String, java.net.URL)
     */
    public void setURL(String parameterName, URL val) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#setURL(java.lang.String, java.net.URL)");

    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#setNull(java.lang.String, int)
     */
    public void setNull(String parameterName, int sqlType) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#setNull(java.lang.String, int)");

    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#setBoolean(java.lang.String, boolean)
     */
    public void setBoolean(String parameterName, boolean x) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#setBoolean(java.lang.String, boolean)");

    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#setByte(java.lang.String, byte)
     */
    public void setByte(String parameterName, byte x) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#setByte(java.lang.String, byte)");

    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#setShort(java.lang.String, short)
     */
    public void setShort(String parameterName, short x) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#setShort(java.lang.String, short)");

    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#setInt(java.lang.String, int)
     */
    public void setInt(String parameterName, int x) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#setInt(java.lang.String, int)");

    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#setLong(java.lang.String, long)
     */
    public void setLong(String parameterName, long x) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#setLong(java.lang.String, long)");

    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#setFloat(java.lang.String, float)
     */
    public void setFloat(String parameterName, float x) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#setFloat(java.lang.String, float)");

    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#setDouble(java.lang.String, double)
     */
    public void setDouble(String parameterName, double x) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#setDouble(java.lang.String, double)");

    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#setBigDecimal(java.lang.String, java.math.BigDecimal)
     */
    public void setBigDecimal(String parameterName, BigDecimal x) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#setBigDecimal(java.lang.String, java.math.BigDecimal)");

    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#setString(java.lang.String, java.lang.String)
     */
    public void setString(String parameterName, String x) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#setString(java.lang.String, java.lang.String)");

    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#setBytes(java.lang.String, byte[])
     */
    public void setBytes(String parameterName, byte[] x) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#setBytes(java.lang.String, byte[])");

    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#setDate(java.lang.String, java.sql.Date)
     */
    public void setDate(String parameterName, Date x) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#setDate(java.lang.String, java.sql.Date)");

    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#setTime(java.lang.String, java.sql.Time)
     */
    public void setTime(String parameterName, Time x) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#setTime(java.lang.String, java.sql.Time)");

    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#setTimestamp(java.lang.String, java.sql.Timestamp)
     */
    public void setTimestamp(String parameterName, Timestamp x) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#setTimestamp(java.lang.String, java.sql.Timestamp)");

    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#setAsciiStream(java.lang.String, java.io.InputStream, int)
     */
    public void setAsciiStream(String parameterName, InputStream x, int length) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#setAsciiStream(java.lang.String, java.io.InputStream, int)");


    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#setBinaryStream(java.lang.String, java.io.InputStream, int)
     */
    public void setBinaryStream(String parameterName, InputStream x, int length) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#setBinaryStream(java.lang.String, java.io.InputStream, int)");


    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#setObject(java.lang.String, java.lang.Object, int, int)
     */
    public void setObject(String parameterName, Object x, int targetSqlType, int scale) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#setObject(java.lang.String, java.lang.Object, int, int");


    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#setObject(java.lang.String, java.lang.Object, int)
     */
    public void setObject(String parameterName, Object x, int targetSqlType) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#setObject(java.lang.String, java.lang.Object, int)");


    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#setObject(java.lang.String, java.lang.Object)
     */
    public void setObject(String parameterName, Object x) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#setObject(java.lang.String, java.lang.Object)");


    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#setCharacterStream(java.lang.String, java.io.Reader, int)
     */
    public void setCharacterStream(String parameterName, Reader reader, int length) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#setCharacterStream(java.lang.String, java.io.Reader, int)");

    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#setDate(java.lang.String, java.sql.Date, java.util.Calendar)
     */
    public void setDate(String parameterName, Date x, Calendar cal) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#setDate(java.lang.String, java.sql.Date, java.util.Calendar)");


    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#setTime(java.lang.String, java.sql.Time, java.util.Calendar)
     */
    public void setTime(String parameterName, Time x, Calendar cal) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#setTime(java.lang.String, java.sql.Time, java.util.Calendar)");

    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#setTimestamp(java.lang.String, java.sql.Timestamp, java.util.Calendar)
     */
    public void setTimestamp(String parameterName, Timestamp x, Calendar cal) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#setTimestamp(java.lang.String, java.sql.Timestamp, java.util.Calendar)");


    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#setNull(java.lang.String, int, java.lang.String)
     */
    public void setNull(String parameterName, int sqlType, String typeName) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#setNull(java.lang.String, int, java.lang.String)");

    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#getString(java.lang.String)
     */
    public String getString(String parameterName) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#getString(java.lang.String)");
        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#getBoolean(java.lang.String)
     */
    public boolean getBoolean(String parameterName) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#getBoolean(java.lang.String)");
        return false;
    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#getByte(java.lang.String)
     */
    public byte getByte(String parameterName) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#getByte(java.lang.String)");

        return 0;
    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#getShort(java.lang.String)
     */
    public short getShort(String parameterName) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#getShort(java.lang.String)");

        return 0;
    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#getInt(java.lang.String)
     */
    public int getInt(String parameterName) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#getInt(java.lang.String)");

        return 0;
    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#getLong(java.lang.String)
     */
    public long getLong(String parameterName) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#getLong(java.lang.String)");

        return 0;
    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#getFloat(java.lang.String)
     */
    public float getFloat(String parameterName) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#getFloat(java.lang.String)");

        return 0;
    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#getDouble(java.lang.String)
     */
    public double getDouble(String parameterName) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#getDouble(java.lang.String)");

        return 0;
    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#getBytes(java.lang.String)
     */
    public byte[] getBytes(String parameterName) throws SQLException {
        // TODO Auto-generated method stub
        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#getDate(java.lang.String)
     */
    public Date getDate(String parameterName) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#getDate(java.lang.String)");

        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#getTime(java.lang.String)
     */
    public Time getTime(String parameterName) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#getTime(java.lang.String)");

        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#getTimestamp(java.lang.String)
     */
    public Timestamp getTimestamp(String parameterName) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#getTimestamp(java.lang.String");

        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#getObject(java.lang.String)
     */
    public Object getObject(String parameterName) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#getObject(java.lang.String)");

        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#getBigDecimal(java.lang.String)
     */
    public BigDecimal getBigDecimal(String parameterName) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#getBigDecimal(java.lang.String)");

        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#getObject(java.lang.String, java.util.Map)
     */
    public Object getObject(String parameterName, Map map) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#getObject(java.lang.String, java.util.Map)");

        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#getRef(java.lang.String)
     */
    public Ref getRef(String parameterName) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#getRef(java.lang.String)");

        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#getBlob(java.lang.String)
     */
    public Blob getBlob(String parameterName) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#getBlob(java.lang.String)");

        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#getClob(java.lang.String)
     */
    public Clob getClob(String parameterName) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#getClob(java.lang.String)");

        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#getArray(java.lang.String)
     */
    public Array getArray(String parameterName) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#getArray(java.lang.String)");

        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#getDate(java.lang.String, java.util.Calendar)
     */
    public Date getDate(String parameterName, Calendar cal) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#getDate(java.lang.String, java.util.Calendar");

        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#getTime(java.lang.String, java.util.Calendar)
     */
    public Time getTime(String parameterName, Calendar cal) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#getTime(java.lang.String, java.util.Calendar)");

        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#getTimestamp(java.lang.String, java.util.Calendar)
     */
    public Timestamp getTimestamp(String parameterName, Calendar cal) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#getTimestamp(java.lang.String, java.util.Calendar)");

        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.CallableStatement#getURL(java.lang.String)
     */
    public URL getURL(String parameterName) throws SQLException {
        ScDBError.check_error(-52, "java.sql.CallableStatement#getURL(java.lang.String)");

        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.PreparedStatement#setURL(int, java.net.URL)
     */
    public void setURL(int parameterIndex, URL x) throws SQLException {
        ScDBError.check_error(-52, "java.sql.PreparedStatement#setURL(int, java.net.URL)");

    }

    /* (non-Javadoc)
     * @see java.sql.PreparedStatement#getParameterMetaData()
     */
    public ParameterMetaData getParameterMetaData() throws SQLException {
        ScDBError.check_error(-52, "java.sql.PreparedStatement#getParameterMetaData()");
        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#getMoreResults(int)
     */
    public boolean getMoreResults(int current) throws SQLException {
        ScDBError.check_error(-52, "java.sql.Statement#getMoreResults(int)");
        return false;
    }

    /* (non-Javadoc)
     * @see java.sql.Statement#getResultSetHoldability()
     */
    public int getResultSetHoldability() throws SQLException {
        return this.resHoldabilty;
    }
}






