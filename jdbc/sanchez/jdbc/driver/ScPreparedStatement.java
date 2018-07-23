/**
 * ScPreparedStatement object is used to execute a precompiled
 * SQL statement with or without IN parameters.
 *
 * @version 1.0  Spet. 28 1999
 * @author Quansheng Jia
 * @see ScStatament, ScCallableStatement
 */

package sanchez.jdbc.driver;

import java.io.InputStream;
import java.io.Reader;
import java.math.BigDecimal;
import java.net.URL;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;
import java.util.Set;
import java.util.TreeMap;
import java.util.Vector;
import java.sql.*;
import java.util.Hashtable;

import sanchez.base.ScBundle;
import sanchez.base.ScResourceKeys;
import sanchez.utils.ScSerialUtils;
import sanchez.utils.ScUtility;

import java.sql.Types;

import sanchez.him_pa.utils.ScMSQLFormat;
import sanchez.him_pa.utils.ScUtils;
import sanchez.jdbc.dbaccess.ScDBError;
import sanchez.jdbc.dbaccess.ScDBStatement;
import sanchez.jdbc.dbaccess.ScMsqlDDLStatement;
import sanchez.jdbc.dbaccess.ScMsqlQueryStatement;

/**
 * An object that represents a precompiled SQL statement.
 * <P>A SQL statement is pre-compiled and stored in a
 * PreparedStatement object. This object can then be used to
 * efficiently execute this statement multiple times. 
 *
 * <P><B>Note:</B> The setXXX methods for setting IN parameter values
 * must specify types that are compatible with the defined SQL type of
 * the input parameter. For instance, if the IN parameter has SQL type
 * Integer, then the method <code>setInt</code> should be used.
 *
 * <p>If arbitrary parameter type conversions are required, the method
 * <code>setObject</code> should be used with a target SQL type.
 * <br>
 * Example of setting a parameter; <code>con</code> is an active connection  
 * <pre><code>
 *   PreparedStatement pstmt = con.prepareStatement("UPDATE EMPLOYEES
 *                                     SET SALARY = ? WHERE ID = ?");
 *   pstmt.setBigDecimal(1, 153833.00)
 *   pstmt.setInt(2, 110592)
 * </code></pre>
 *
 * @see Connection#prepareStatement
 * @see ResultSet
 */

public class ScPreparedStatement extends ScStatement implements PreparedStatement {
    protected HashMap hSqlQaulifier = new HashMap(5);
    protected String sSql;
    protected String orig_sSql;
    static Hashtable storeprocedure = new Hashtable();

    /**
     * Constructs ScPreparedStatement Object using ScConnection object and sSqlStatement
     * @param cConnection
     * @param sSqlStatement
     * @throws SQLException
     */
    public ScPreparedStatement(ScConnection cConnection, String sSqlStatement)
            throws SQLException {
        super(cConnection);
        connection.log("PrepareStatement(" + sSqlStatement + ")");
        initialization(sSqlStatement);
    }

    /**
     * Constructs a ScPreparedStatement object using a defined ScConnection,SqlStatement,resultsetType and resultSetConcurrency 
     * @param cConnection
     * @param sSqlStatement
     * @param resultSetType
     * @param resultSetConcurrency
     * @throws SQLException
     */
    public ScPreparedStatement(ScConnection cConnection, String sSqlStatement, int resultSetType,
                               int resultSetConcurrency)
            throws SQLException {
        super(cConnection, resultSetType, resultSetConcurrency);
        initialization(sSqlStatement);
    }

    protected ScPreparedStatement(ScConnection cConnection, String sSqlStatement, int resultSetType,
                                  int resultSetConcurrency, int resultSetHoldability)
            throws SQLException {
        this(cConnection, sSqlStatement, resultSetType, resultSetConcurrency);
        this.resHoldabilty = resultSetHoldability;
    }

    /**
     * Initializes SQL Statement with placeholder values and host varible values
     * @param sSqlStatement SQL statement with placeholders
     */
    private void initialization(String sSqlStatement) {
        int column, offset, oldoffset, where;
        StringBuffer sql = new StringBuffer();

        for (column = 1, offset = 0, oldoffset = 0;
             ((where = sSqlStatement.indexOf("?", offset)) > 0);
             offset = where + 1) {
            sql.append(sSqlStatement.substring(oldoffset, where)).append(":D").append(column);
            hSqlQaulifier.put(Integer.toString(column), "?");
            oldoffset = where + 1;
            ++column;
        }

        if (oldoffset < sSqlStatement.length()) sql.append(sSqlStatement.substring(oldoffset, sSqlStatement.length()));

        sSql = sql.toString();
        orig_sSql = sSqlStatement;
    }

    /**
     * Manoj Thoniyil - 10/18/2005
     * Start
     */
    /**
     * This function is added for debugging purposes. 
     * This function returns the hSqlQaulifier hashmap.
     */

    public HashMap getPSQualifier() throws SQLException {
        return hSqlQaulifier;
    }

    /**
     * This function is added for debugging purposes. 
     * This function returns the SQL.
     */

    public String getPSSQL() throws SQLException {
        return sSql;
    }

    /**
     * End
     */

    /**
     * Following lines are to be added to check whether any prepared statement
     * parameters were left unset.
     * @param x is the parameter value
     * @exception SQLException if a database access error occurs
     */
    private void checkParams(int x) throws SQLException {
        if (hSqlQaulifier != null) {
            Iterator paramIndix = hSqlQaulifier.keySet().iterator();
            while (paramIndix.hasNext()) {
                String sParam = (String) hSqlQaulifier.get(paramIndix.next());
                if (sParam != null && sParam.trim().equals("?"))
                    if (x == 1)
                        ScDBError.check_error(-64, "PreparedStatement executeQuery called before setting parameter" + (paramIndix));
                    else
                        ScDBError.check_error(-64, "PreparedStatement executeUpdate called before setting parameter  " + (paramIndix));
            }
        }
    }

    /**
     * Executes the SQL query in this <code>PreparedStatement</code> object
     * and returns the result set generated by the query.
     *
     * @return a ResultSet that contains the data produced by the
     * query; never null
     * @exception SQLException if a database access error occurs
     */
    public ResultSet executeQuery() throws SQLException {//MKT723
        connection.log("PrepareStatement.executeQuery");

        String usesp = (String) connection.info.get("usesp");
        if (usesp != null && (usesp.equalsIgnoreCase("yes") || usesp.equalsIgnoreCase("y")) && !sSql.toUpperCase().trim().startsWith("SELECT *")) {
            return spQuery();
        }

        ini();
        checkParams(1);
        rowCount = -1;
        try {
            dBStatement = i_dDbAccess.open(sSql, fetchRow);
            if (!i_ahHash.isEmpty()) ((ScMsqlQueryStatement) dBStatement).setSqlStatus("1");
            if (efdJulianDate > 0) ((ScMsqlDDLStatement) dBStatement).setEFD(efdJulianDate);
            sqlQuilifierUpdate(1);

            i_dDbAccess.fetch(dBStatement);
            if (((ScMsqlQueryStatement) dBStatement).getSqlStatus().equals("01500")) gotLastBatch = true;
            if (i_ahHash.isEmpty()) firstFetch(dBStatement);
            else fetch(dBStatement);

            //08-21-2003
            Hashtable htMeda = asClearUp(sSql);
            if (htMeda.size() > 0)
                i_ahHash = htMeda;
            //08-21-2003

            //Manoj Thoniyil - 03/29/2007 
            //Doesn't allow setting the parameters inside a for loop
            //jiaq 06-11-06
            //hSqlQaulifier.clear();

            lastRs = new ScJdbcResultSet(connection, this);
            return lastRs;
        } catch (Exception e) {
            ScDBError.check_error(e);
            return null;
        }

    }

    // The overloaded executeQuery on the Statement object (which we
    // extend) is not valid for PreparedStatement or CallableStatement
    // objects.

    public ResultSet executeQuery(
            String sql)
            throws SQLException {
        connection.log("PrepareStatement.executeQuery");
        ScDBError.check_error(-56, "ScPreparedStatement.executeQuery(statement))");
        return null;
    }

    /**
     * Executes the SQL INSERT, UPDATE or DELETE statement
     * in this <code>PreparedStatement</code> object.
     * In addition,
     * SQL statements that return nothing, such as SQL DDL statements,
     * can be executed.
     *
     * @return either the row count for INSERT, UPDATE or DELETE statements;
     * or 0 for SQL statements that return nothing
     * @exception SQLException if a database access error occurs
     */
    public int executeUpdate() throws SQLException {
        connection.log("PrepareStatement.executeUpdate");
        dBStatement = new ScMsqlDDLStatement(sSql);

        checkParams(2);
        /***
         * Manoj Thoniyil - 07/29/05
         *
         * If the user tried to set the EFD before, then set it again, when the 
         * dBStatement is NOT NULL.
         ***/

        if (efdJulianDate > 0) ((ScMsqlDDLStatement) dBStatement).setEFD(efdJulianDate);
        sqlQuilifierUpdate(2);

        //Manoj Thoniyil - 03/29/2007 
        //Doesn't allow setting the parameters inside a for loop
        //jiaq 06-11-06
        //hSqlQaulifier.clear();


        try {
            if (connection.i_bAutoCommit) {
                rowCount = i_dDbAccess.executeUpdate(dBStatement);
                return rowCount;
            } else {
                sendFence((ScMsqlDDLStatement) dBStatement);
                return 1;
            }
        } catch (Exception e) {
            ScDBError.check_error(e);
            return 0;
        }

    }

    /**
     *
     * Executes an SQL INSERT, UPDATE or DELETE statement. In addition,
     * SQL statements that return nothing, such as SQL DDL statements,
     * can be executed.
     *
     * @param sql a SQL INSERT, UPDATE or DELETE statement or a SQL
     * statement that returns nothing
     * @return either the row count for INSERT, UPDATE or DELETE or 0
     * for SQL statements that return nothing
     * @exception SQLException if a database access error occurs
     */
    public int executeUpdate(
            String sql)
            throws SQLException {
        connection.log("PrepareStatement.executeUpdate");
        ScDBError.check_error(-56, "ScPreparedStatement.executeUpdate(statement))");
        return -1;
    }

    /**
     * Sets the designated parameter to SQL NULL.
     *
     * <P><B>Note:</B> You must specify the parameter's SQL type.
     *
     * @param parameterIndex the first parameter is 1, the second is 2, ...
     * @param sqlType the SQL type code defined in java.sql.Types
     * @exception SQLException if a database access error occurs
     */
    public void setNull(int parameterIndex, int sqlType) throws SQLException {
        setString(parameterIndex, "");
    }

    /**
     * Sets the designated parameter to a Java boolean value.  The driver converts this
     * to an SQL BIT value when it sends it to the database.
     *
     * @param parameterIndex the first parameter is 1, the second is 2, ...
     * @param x the parameter value
     * @exception SQLException if a database access error occurs
     */
    public void setBoolean(int parameterIndex, boolean x) throws SQLException {

        int i;
        verify(parameterIndex);
        if (x) i = 1;
        else i = 0;
        hSqlQaulifier.put(Integer.toString(parameterIndex), String.valueOf(i));
    }

    /**
     * Sets the designated parameter to a Java byte value.  The driver converts this
     * to an SQL TINYINT value when it sends it to the database.
     *
     * @param parameterIndex the first parameter is 1, the second is 2, ...
     * @param x the parameter value
     * @exception SQLException if a database access error occurs
     */
    public void setByte(int parameterIndex, byte x) throws SQLException {
        setString(parameterIndex, String.valueOf(x));
    }

    /**
     * Sets the designated parameter to a Java short value.  The driver converts this
     * to an SQL SMALLINT value when it sends it to the database.
     *
     * @param parameterIndex the first parameter is 1, the second is 2, ...
     * @param x the parameter value
     * @exception SQLException if a database access error occurs
     */
    public void setShort(int parameterIndex, short x) throws SQLException {
        setString(parameterIndex, String.valueOf(x));
    }

    /**
     * Sets the designated parameter to a Java int value.  The driver converts this
     * to an SQL INTEGER value when it sends it to the database.
     *
     * @param parameterIndex the first parameter is 1, the second is 2, ...
     * @param x the parameter value
     * @exception SQLException if a database access error occurs
     */
    public void setInt(int parameterIndex, int x) throws SQLException {
        setString(parameterIndex, String.valueOf(x));
    }

    /**
     * Sets the designated parameter to a Java long value.  The driver converts this
     * to an SQL BIGINT value when it sends it to the database.
     *
     * @param parameterIndex the first parameter is 1, the second is 2, ...
     * @param x the parameter value
     * @exception SQLException if a database access error occurs
     */
    public void setLong(int parameterIndex, long x) throws SQLException {
        setString(parameterIndex, String.valueOf(x));
    }

    /**
     * Sets the designated parameter to a Java float value.  The driver converts this
     * to an SQL FLOAT value when it sends it to the database.
     *
     * @param parameterIndex the first parameter is 1, the second is 2, ...
     * @param x the parameter value
     * @exception SQLException if a database access error occurs
     */
    public void setFloat(int parameterIndex, float x) throws SQLException {
        setString(parameterIndex, String.valueOf(x));
    }

    /**
     * Sets the designated parameter to a Java double value.  The driver converts this
     * to an SQL DOUBLE value when it sends it to the database.
     *
     * @param parameterIndex the first parameter is 1, the second is 2, ...
     * @param x the parameter value
     * @exception SQLException if a database access error occurs
     */
    public void setDouble(int parameterIndex, double x) throws SQLException {
        setString(parameterIndex, String.valueOf(x));
    }

    /**
     * Sets the designated parameter to a java.lang.BigDecimal value.  
     * The driver converts this to an SQL NUMERIC value when
     * it sends it to the database.
     *
     * @param parameterIndex the first parameter is 1, the second is 2, ...
     * @param x the parameter value
     * @exception SQLException if a database access error occurs
     */
    public void setBigDecimal(int parameterIndex, BigDecimal x) throws SQLException {
        connection.log("PrepareStatement.setBigDecimal");
        setString(parameterIndex, String.valueOf(x));
    }

    /**
     * Sets the designated parameter to a Java String value.  The driver converts this
     * to an SQL VARCHAR or LONGVARCHAR value (depending on the argument's
     * size relative to the driver's limits on VARCHARs) when it sends
     * it to the database.
     *
     * @param parameterIndex the first parameter is 1, the second is 2, ...
     * @param x the parameter value
     * @exception SQLException if a database access error occurs
     */
    public void setString(int parameterIndex, String x) throws SQLException {
        connection.log("PrepareStatement.setString");
        verify(parameterIndex);
        if (x == null) x = "";
        hSqlQaulifier.put(Integer.toString(parameterIndex), x);
    }

    /**
     * Sets the designated parameter to a Java array of bytes.  The driver converts
     * this to an SQL VARBINARY or LONGVARBINARY (depending on the
     * argument's size relative to the driver's limits on VARBINARYs)
     * when it sends it to the database.
     *
     * @param parameterIndex the first parameter is 1, the second is 2, ...
     * @param x the parameter value 
     * @exception SQLException if a database access error occurs
     */
    public void setBytes(int parameterIndex, byte x[]) throws SQLException {
        connection.log("PrepareStatement.setBytes");
        setString(parameterIndex, ScUtils.byteToString(x, x.length));
    }

    /**
     * Sets the designated parameter to a java.sql.Date value.  The driver converts this
     * to an SQL DATE value when it sends it to the database.
     *
     * @param parameterIndex the first parameter is 1, the second is 2, ...
     * @param x the parameter value
     * @exception SQLException if a database access error occurs
     */
    public void setDate(int parameterIndex, java.sql.Date x)
            throws SQLException {
        connection.log("PrepareStatement.setDate");
        DateFormat df = new SimpleDateFormat("yyyy-MM-dd", Locale.US);
        String julianDate = ScUtility.JulianDate(df.format(x));
        setString(parameterIndex, new String(julianDate));
    }

    /**
     * Sets the designated parameter to a java.sql.Time value.  The driver converts this
     * to an SQL TIME value when it sends it to the database.
     *
     * @param parameterIndex the first parameter is 1, the second is 2, ...
     * @param x the parameter value
     * @exception SQLException if a database access error occurs
     */
    public void setTime(int parameterIndex, java.sql.Time x)
            throws SQLException {
        connection.log("PrepareStatement.setTime");
        setString(parameterIndex, new String(ScUtility.JulianTime(x.toString(), 0)));

    }

    /**
     * Sets the designated parameter to a java.sql.Timestamp value.  The driver
     * converts this to an SQL TIMESTAMP value when it sends it to the
     * database.
     *
     * @param parameterIndex the first parameter is 1, the second is 2, ...
     * @param x the parameter value 
     * @exception SQLException if a database access error occurs
     */
    public void setTimestamp(int parameterIndex, java.sql.Timestamp x)
            throws SQLException {
        connection.log("PrepareStatement.setTimestamp");
        setString(parameterIndex, x.toString());
    }

    /**
     * Sets the designated parameter to the given input stream, which will have
     * the specified number of bytes.
     * When a very large ASCII value is input to a LONGVARCHAR
     * parameter, it may be more practical to send it via a
     * java.io.InputStream. JDBC will read the data from the stream
     * as needed, until it reaches end-of-file.  The JDBC driver will
     * do any necessary conversion from ASCII to the database char format.
     *
     * <P><B>Note:</B> This stream object can either be a standard
     * Java stream object or your own subclass that implements the
     * standard interface.
     *
     * @param parameterIndex the first parameter is 1, the second is 2, ...
     * @param x the Java input stream that contains the ASCII parameter value
     * @param length the number of bytes in the stream 
     * @exception SQLException if a database access error occurs
     */
    public void setAsciiStream(int parameterIndex, java.io.InputStream x, int readSize)
            throws SQLException {
        connection.log("PrepareStatement.setAsciiStream");
        ScDBError.check_error(-56, "ScPreparedStatement.setAsciiStream(statement))");
    }

    /**
     * Sets the designated parameter to the given input stream, which will have
     * the specified number of bytes.
     * When a very large UNICODE value is input to a LONGVARCHAR
     * parameter, it may be more practical to send it via a
     * java.io.InputStream. JDBC will read the data from the stream
     * as needed, until it reaches end-of-file.  The JDBC driver will
     * do any necessary conversion from UNICODE to the database char format.
     * The byte format of the Unicode stream must be Java UTF-8, as
     * defined in the Java Virtual Machine Specification.
     *
     * <P><B>Note:</B> This stream object can either be a standard
     * Java stream object or your own subclass that implements the
     * standard interface.
     *
     * @param parameterIndex the first parameter is 1, the second is 2, ...  
     * @param x the java input stream which contains the
     * UNICODE parameter value 
     * @param length the number of bytes in the stream 
     * @exception SQLException if a database access error occurs
     * @deprecated
     */
    public void setUnicodeStream(int parameterIndex, java.io.InputStream x,
                                 int length) throws SQLException {
        connection.log("PrepareStatement.setUnicodeStream");
        verify(parameterIndex);

        ScDBError.check_error(-56, "ScPreparedStatement.setAsciiStream(statement))");
    }

    /**
     * Sets the designated parameter to the given input stream, which will have
     * the specified number of bytes.
     * When a very large binary value is input to a LONGVARBINARY
     * parameter, it may be more practical to send it via a
     * java.io.InputStream. JDBC will read the data from the stream
     * as needed, until it reaches end-of-file.
     *
     * <P><B>Note:</B> This stream object can either be a standard
     * Java stream object or your own subclass that implements the
     * standard interface.
     *
     * @param parameterIndex the first parameter is 1, the second is 2, ...
     * @param x the java input stream which contains the binary parameter value
     * @param length the number of bytes in the stream 
     * @exception SQLException if a database access error occurs
     */
    public void setBinaryStream(int parameterIndex, java.io.InputStream x,
                                int readSize) throws SQLException {
        // Validate the parameter index
        connection.log("PrepareStatement.setBinaryStream");
        verify(parameterIndex);

        // Read in the entire InputStream all at once.  A more optimal
        // way of handling this would be to defer the read until execute
        // time, and only read in chunks at a time.

        byte abyte0[] = new byte[readSize];
        try {
            int k = 0;
            do
                k += x.read(abyte0, k, readSize - k);
            while (k != -1);
        } catch (java.io.IOException _ex) {
            ScDBError.check_error(263);
        }
        setBytes(parameterIndex, abyte0);

    }

    /**
     * Clears the current parameter values immediately.
     * <P>In general, parameter values remain in force for repeated use of a
     * Statement. Setting a parameter value automatically clears its
     * previous value.  However, in some cases it is useful to immediately
     * release the resources used by the current parameter values; this can
     * be done by calling clearParameters.
     *
     * @exception SQLException if a database access error occurs
     */
    public void clearParameters() throws SQLException {
        connection.log("PrepareStatement.clearParameters");
        hSqlQaulifier.clear();
        initialization(orig_sSql);
    }

    //----------------------------------------------------------------------
    // Advanced features:

    /**
     * <p>Sets the value of a parameter using an object. The second
     * argument must be an object type; for integral values, the
     * java.lang equivalent objects should be used.
     *
     * <p>The given Java object will be converted to the targetSqlType
     * before being sent to the database.
     *
     * If the object has a custom mapping (is of a class implementing SQLData),
     * the JDBC driver should call its method <code>writeSQL</code> to write it 
     * to the SQL data stream.
     * If, on the other hand, the object is of a class implementing
     * Ref, Blob, Clob, Struct,
     * or Array, the driver should pass it to the database as a value of the 
     * corresponding SQL type.
     *
     * <p>Note that this method may be used to pass datatabase-
     * specific abstract data types. 
     *
     * @param parameterIndex the first parameter is 1, the second is 2, ...
     * @param x the object containing the input parameter value
     * @param targetSqlType the SQL type (as defined in java.sql.Types) to be 
     * sent to the database. The scale argument may further qualify this type.
     * @param scale for java.sql.Types.DECIMAL or java.sql.Types.NUMERIC types,
     *          this is the number of digits after the decimal point.  For all other
     *          types, this value will be ignored.
     * @exception SQLException if a database access error occurs
     * @see Types
     */
    public void setObject(int parameterIndex, Object x, int targetSqlType,
                          int scale) throws SQLException {
        connection.log("PrepareStatement.setObject");
        String actualJdbcType = null;
        switch (targetSqlType) {
            case 1: // '\001'
                if (x instanceof String) {
                    setString(parameterIndex, (String) x);
                } else {
                    actualJdbcType = getActualJdbcType(x);
                    ScDBError.check_error(-66, actualJdbcType
                            + " to java.lang.String");
                }
                break;

            case 12: // '\f'
                if (x instanceof String) {
                    setString(parameterIndex, (String) x);
                } else {
                    actualJdbcType = getActualJdbcType(x);
                    ScDBError.check_error(-66, actualJdbcType
                            + " to java.lang.String");
                }
                break;

            case -1:
                if (x instanceof String) {
                    setString(parameterIndex, (String) x);
                } else {
                    actualJdbcType = getActualJdbcType(x);
                    ScDBError.check_error(-66, actualJdbcType
                            + " to java.lang.String");
                }
                break;

            case 2: // '\002'
                if (x instanceof BigDecimal) {
                    setBigDecimal(parameterIndex, (BigDecimal) x);
                } else {
                    actualJdbcType = getActualJdbcType(x);
                    ScDBError.check_error(-66, actualJdbcType
                            + " to java.math.BigDecimal");
                }
                break;

            case 3: // '\003'
                if (x instanceof BigDecimal) {
                    setBigDecimal(parameterIndex, (BigDecimal) x);
                } else {
                    actualJdbcType = getActualJdbcType(x);
                    ScDBError.check_error(-66, actualJdbcType
                            + " to java.math.BigDecimal");
                }
                break;

            case -7:
                if (x instanceof Boolean) {
                    setBoolean(parameterIndex, ((Boolean) x).booleanValue());
                } else {
                    actualJdbcType = getActualJdbcType(x);
                    ScDBError.check_error(-66, actualJdbcType
                            + " to java.lang.Boolean");
                }
                break;

            case -6:
                if (x instanceof Byte) {
                    setByte(parameterIndex, (byte) ((Integer) x).intValue());
                } else {
                    actualJdbcType = getActualJdbcType(x);
                    ScDBError.check_error(-66, actualJdbcType
                            + " to java.lang.Byte");
                }
                break;

            case 5: // '\005'
                if (x instanceof Short) {
                    setShort(parameterIndex, (short) ((Integer) x).intValue());
                } else {
                    actualJdbcType = getActualJdbcType(x);
                    ScDBError.check_error(-66, actualJdbcType
                            + " to java.lang.Short");
                }
                break;

            case 4: // '\004'
                if (x instanceof Integer) {
                    setInt(parameterIndex, ((Integer) x).intValue());
                } else {
                    actualJdbcType = getActualJdbcType(x);
                    ScDBError.check_error(-66, actualJdbcType
                            + " to java.lang.Integer");
                }
                break;

            case -5:
                if (x instanceof Long) {
                    setLong(parameterIndex, ((Long) x).longValue());
                } else {
                    actualJdbcType = getActualJdbcType(x);
                    ScDBError.check_error(-66, actualJdbcType
                            + " to java.lang.Long");
                }
                break;

            case 7: // '\007'
                if (x instanceof java.lang.Float) {
                    setFloat(parameterIndex, ((java.lang.Float) x).floatValue());
                } else {
                    actualJdbcType = getActualJdbcType(x);
                    ScDBError.check_error(-66, actualJdbcType
                            + " to java.lang.Float");
                }
                break;

            case 6: // '\006'
                if (x instanceof java.lang.Float) {
                    setFloat(parameterIndex, ((java.lang.Float) x).floatValue());
                } else {
                    actualJdbcType = getActualJdbcType(x);
                    ScDBError.check_error(-66, actualJdbcType
                            + " to java.lang.Float");
                }
                break;

            case 8: // '\b'
                if (x instanceof Double) {
                    setDouble(parameterIndex, ((Double) x).doubleValue());
                } else {
                    actualJdbcType = getActualJdbcType(x);
                    ScDBError.check_error(-66, actualJdbcType
                            + " to java.lang.Double");
                }
                break;

            case -2:
                if (x instanceof byte[]) {
                    setBytes(parameterIndex, (byte[]) x);
                } else {
                    actualJdbcType = getActualJdbcType(x);
                    ScDBError.check_error(-66, actualJdbcType + " to byte[]");
                }
                break;

            case -3:
                if (x instanceof byte[]) {
                    setBytes(parameterIndex, (byte[]) x);
                } else {
                    actualJdbcType = getActualJdbcType(x);
                    ScDBError.check_error(-66, actualJdbcType + " to byte[]");
                }
                break;

            case -4:
                if (x instanceof byte[]) {
                    setBytes(parameterIndex, (byte[]) x);
                } else {
                    actualJdbcType = getActualJdbcType(x);
                    ScDBError.check_error(-66, actualJdbcType + " to byte[]");
                }
                break;

            case 91: // '['
                if (x instanceof java.sql.Date) {
                    setDate(parameterIndex, (java.sql.Date) x);
                } else {
                    actualJdbcType = getActualJdbcType(x);
                    ScDBError
                            .check_error(-66, actualJdbcType + " to java.sql.Date");
                }
                break;

            case 92: // '\\'
                if (x instanceof java.sql.Time) {
                    setTime(parameterIndex, (Time) x);
                } else {
                    actualJdbcType = getActualJdbcType(x);
                    ScDBError
                            .check_error(-66, actualJdbcType + " to java.sql.Time");
                }
                break;

            case 93: // ']'
                if (x instanceof java.sql.Timestamp) {
                    setTimestamp(parameterIndex, (Timestamp) x);
                } else {
                    actualJdbcType = getActualJdbcType(x);
                    ScDBError.check_error(-66, actualJdbcType
                            + " to java.sql.Timestamp");
                }
                break;

            case java.sql.Types.BLOB:
                if (x instanceof Blob) {
                    setBlob(parameterIndex, (Blob) x);
                } else {
                    actualJdbcType = getActualJdbcType(x);
                    ScDBError.check_error(-66, actualJdbcType + " to Blob");
                }
                break;

            default:
                hSqlQaulifier.put(Integer.toString(parameterIndex), x);
                break;
        }
    }

    /**
     * Gets the name of the JDBC type of the object passed as a parameter
     * @param Object x
     * @return name of the object's corresponding JDBC Type
     *
     */
    public String getActualJdbcType(Object x) {
        Class classOfActualJdbcType = x.getClass();
        return classOfActualJdbcType.getName();
    }

    /**
     * Sets the value of the designated parameter with the given object.
     * This method is like setObject above, except that it assumes a scale of zero.
     *
     * @param parameterIndex the first parameter is 1, the second is 2, ...
     * @param x the object containing the input parameter value
     * @param targetSqlType the SQL type (as defined in java.sql.Types) to be 
     *                      sent to the database
     * @exception SQLException if a database access error occurs
     */
    public void setObject(int parameterIndex, Object x, int targetSqlType)
            throws SQLException {
        connection.log("PrepareStatement.setObject");
        setObject(parameterIndex, x, targetSqlType, 0);
    }

    /**
     * <p>Sets the value of a parameter using an object; use the
     * java.lang equivalent objects for integral values.
     *
     * <p>The JDBC specification specifies a standard mapping from
     * Java Object types to SQL types.  The given argument java object
     * will be converted to the corresponding SQL type before being
     * sent to the database.
     *
     * <p>Note that this method may be used to pass datatabase-
     * specific abstract data types, by using a Driver-specific Java
     * type.
     *
     * If the object is of a class implementing SQLData,
     * the JDBC driver should call its method <code>writeSQL</code> to write it 
     * to the SQL data stream.
     * If, on the other hand, the object is of a class implementing
     * Ref, Blob, Clob, Struct,
     * or Array, then the driver should pass it to the database as a value of the 
     * corresponding SQL type.
     *
     * This method throws an exception if there is an ambiguity, for example, if the
     * object is of a class implementing more than one of those interfaces.
     *
     * @param parameterIndex the first parameter is 1, the second is 2, ...
     * @param x the object containing the input parameter value 
     * @exception SQLException if a database access error occurs
     */
    public void setObject(int parameterIndex, Object x) throws SQLException {
        connection.log("PrepareStatement.setObject");
        int sqlType = getObjectType(x);
        setObject(parameterIndex, x, sqlType, 0);
    }

    /**
     * Executes any kind of SQL statement.
     * Some prepared statements return multiple results; the execute
     * method handles these complex statements as well as the simpler
     * form of statements handled by executeQuery and executeUpdate.
     *
     * @exception SQLException if a database access error occurs
     * @see Statement#execute
     */
    public boolean execute() throws SQLException {
        connection.log("PrepareStatement.execute");
        if (sSql.toUpperCase().trim().indexOf("SELECT") == 0) {
            lastRs = (ScJdbcResultSet) executeQuery();
            return true;
        } else {
            rowCount = executeUpdate();
            return false;
        }
    }

    //--------------------------JDBC 2.0-----------------------------

    /**
     * JDBC 2.0
     *
     * Adds a set of parameters to the batch.
     *
     * @exception SQLException if a database access error occurs
     * @see Statement#addBatch
     */
    public void addBatch() throws SQLException {
        connection.log("PrepareStatement.addBatch");
        if (connection.i_bAutoCommit) {
            ScDBError.check_error(-50, "ScStatement");
            return;
        }

        dBStatement = new ScMsqlDDLStatement(sSql);
        sqlQuilifierUpdate(2);
        clearParameters();

        i_batchSql.addElement(dBStatement);
    }

    /**
     * JDBC 2.0
     *
     * Sets the designated parameter to the given <code>Reader</code>
     * object, which is the given number of characters long.
     * When a very large UNICODE value is input to a LONGVARCHAR
     * parameter, it may be more practical to send it via a
     * java.io.Reader. JDBC will read the data from the stream
     * as needed, until it reaches end-of-file.  The JDBC driver will
     * do any necessary conversion from UNICODE to the database char format.
     *
     * <P><B>Note:</B> This stream object can either be a standard
     * Java stream object or your own subclass that implements the
     * standard interface.
     *
     * @param parameterIndex the first parameter is 1, the second is 2, ...
     * @param x the java reader which contains the UNICODE data
     * @param length the number of characters in the stream 
     * @exception SQLException if a database access error occurs
     */
    public void setCharacterStream(int parameterIndex,
                                   java.io.Reader reader,
                                   int j) throws SQLException {
        connection.log("PrepareStatement.setCharacterStream");
        verify(parameterIndex);

        char ac[] = new char[j];
        try {
            int k = 0;
            do
                k += reader.read(ac, k, j - k);
            while (k != -1);
        } catch (java.io.IOException _ex) {
            ScDBError.check_error(263);
        }
        String s = new String(ac);

        setString(parameterIndex, s);
    }

    /**
     * JDBC 2.0
     *
     * Sets a REF(&lt;structured-type&gt;) parameter.
     *
     * @param i the first parameter is 1, the second is 2, ...
     * @param x an object representing data of an SQL REF Type
     * @exception SQLException if a database access error occurs
     */
    public void setRef(int i, Ref x) throws SQLException {
        connection.log("PrepareStatement.setRef");
        ScDBError.check_error(-56, "ScPreparedStatement.setRef()");
    }

    /**
     * JDBC 2.0
     *
     * Sets a BLOB parameter.
     *
     * @param i the first parameter is 1, the second is 2, ...
     * @param x an object representing a BLOB
     * @exception SQLException if a database access error occurs
     */
    boolean setBlob = false;

    public void setBlob(int i, Blob x) throws SQLException {
        connection.log("PrepareStatement.setBlob");
        verify(i);
        byte[] bytes = x.getBytes(0, (int) x.length());
        String s0 = ScUtils.byteToString(bytes, bytes.length);
        //below one line will be removed after Profile defect was fixed
        //for a 'M' message with escape characters
        s0 = ScSerialUtils.ScGetObjectToString(s0);
        setString(i, s0);
    }

    /**
     * JDBC 2.0
     *
     * Sets a CLOB parameter.
     *
     * @param i the first parameter is 1, the second is 2, ...
     * @param x an object representing a CLOB
     * @exception SQLException if a database access error occurs
     */
    public void setClob(int i, Clob x) throws SQLException {
        connection.log("PrepareStatement.setClob");
        verify(i);

        long len = x.length();
        String s = x.getSubString(0, (int) len);
        //below one line will be removed after Profile defect was fixed
        //for a 'M' message with escape characters
        s = ScSerialUtils.ScGetObjectToString(s);
        this.setString(i, s);
    }

    /**
     * JDBC 2.0
     *
     * Sets an Array parameter.
     *
     * @param i the first parameter is 1, the second is 2, ...
     * @param x an object representing an SQL array
     * @exception SQLException if a database access error occurs
     */
    public void setArray(int i, Array x) throws SQLException {
        connection.log("PrepareStatement.setArray");
        ScDBError.check_error(-56, "ScPreparedStatement.setArray()");
    }

    /**
     * JDBC 2.0
     *
     * Gets the number, types and properties of a ResultSet's columns.
     *
     * @return the description of a ResultSet's columns
     * @exception SQLException if a database access error occurs
     */
    public ResultSetMetaData getMetaData() throws SQLException {
        connection.log("PrepareStatement.getMetaData");
        if (lastRs != null) return lastRs.getMetaData();

        String sqlKind = sSql.toLowerCase().trim();

        if (!sqlKind.regionMatches(true, 0, "select", 0, 6) && !sqlKind.regionMatches(true, 0, "open", 0, 4))
            return null;

        Statement s = connection.createStatement();
        s.setFetchSize(0);

        int i = sqlKind.indexOf(" from ");
        if (i < 0) return null;

        int i1 = sqlKind.indexOf(" where ", i);
        if (i1 > 0) sqlKind = sqlKind.substring(0, i1).trim();
        ResultSet rs = s.executeQuery(sqlKind);
        return rs.getMetaData();
    }


    /**
     * JDBC 2.0
     *
     * Sets the designated parameter to a java.sql.Date value,
     * using the given <code>Calendar</code> object.  The driver uses
     * the <code>Calendar</code> object to construct an SQL DATE,
     * which the driver then sends to the database.  With a
     * a <code>Calendar</code> object, the driver can calculate the date
     * taking into account a custom timezone and locale.  If no
     * <code>Calendar</code> object is specified, the driver uses the default
     * timezone and locale.
     *
     * @param parameterIndex the first parameter is 1, the second is 2, ...
     * @param x the parameter value
     * @param cal the <code>Calendar</code> object the driver will use
     *            to construct the date
     * @exception SQLException if a database access error occurs
     */
    public void setDate(int parameterIndex, java.sql.Date x, Calendar cal)
            throws SQLException {
        connection.log("PrepareStatement.setDate");
        java.util.Calendar targetCalendar = java.util.Calendar.getInstance(cal.getTimeZone());
        targetCalendar.clear();
        targetCalendar.setTime(x);
        java.util.Calendar defaultCalendar = java.util.Calendar.getInstance();
        defaultCalendar.clear();
        defaultCalendar.setTime(x);
        long timeZoneOffset = targetCalendar.get(java.util.Calendar.ZONE_OFFSET) -
                defaultCalendar.get(java.util.Calendar.ZONE_OFFSET) +
                targetCalendar.get(java.util.Calendar.DST_OFFSET) -
                defaultCalendar.get(java.util.Calendar.DST_OFFSET);
        java.sql.Date adjustedDate = ((timeZoneOffset == 0) || (x == null)) ? x : new
                java.sql.Date(x.getTime() + timeZoneOffset);

        setDate(parameterIndex, adjustedDate);
    }

    /**
     * JDBC 2.0
     *
     * Sets the designated parameter to a java.sql.Time value,
     * using the given <code>Calendar</code> object.  The driver uses
     * the <code>Calendar</code> object to construct an SQL TIME,
     * which the driver then sends to the database.  With a
     * a <code>Calendar</code> object, the driver can calculate the time
     * taking into account a custom timezone and locale.  If no
     * <code>Calendar</code> object is specified, the driver uses the default
     * timezone and locale.
     *
     * @param parameterIndex the first parameter is 1, the second is 2, ...
     * @param x the parameter value
     * @param cal the <code>Calendar</code> object the driver will use
     *            to construct the time
     * @exception SQLException if a database access error occurs
     */
    public void setTime(int parameterIndex, java.sql.Time x, Calendar cal)
            throws SQLException {
        connection.log("PrepareStatement.setTime");
        java.util.Calendar targetCalendar = java.util.Calendar.getInstance(cal.getTimeZone());
        targetCalendar.clear();
        targetCalendar.setTime(x);
        java.util.Calendar defaultCalendar = java.util.Calendar.getInstance();
        defaultCalendar.clear();
        defaultCalendar.setTime(x);
        long timeZoneOffset =
                targetCalendar.get(java.util.Calendar.ZONE_OFFSET) -
                        defaultCalendar.get(java.util.Calendar.ZONE_OFFSET) +
                        targetCalendar.get(java.util.Calendar.DST_OFFSET) -
                        defaultCalendar.get(java.util.Calendar.DST_OFFSET);
        java.sql.Time adjustedTime = ((timeZoneOffset == 0) || (x == null)) ? x : new
                java.sql.Time(x.getTime() + timeZoneOffset);
        setTime(parameterIndex, adjustedTime);
    }

    /**
     * JDBC 2.0
     *
     * Sets the designated parameter to a java.sql.Timestamp value,
     * using the given <code>Calendar</code> object.  The driver uses
     * the <code>Calendar</code> object to construct an SQL TIMESTAMP,
     * which the driver then sends to the database.  With a
     * a <code>Calendar</code> object, the driver can calculate the timestamp
     * taking into account a custom timezone and locale.  If no
     * <code>Calendar</code> object is specified, the driver uses the default
     * timezone and locale.
     *
     * @param parameterIndex the first parameter is 1, the second is 2, ...
     * @param x the parameter value 
     * @param cal the <code>Calendar</code> object the driver will use
     *            to construct the timestamp
     * @exception SQLException if a database access error occurs
     */

    public void setTimestamp(int parameterIndex, java.sql.Timestamp x, Calendar cal)
            throws SQLException {
        connection.log("PrepareStatement.setTimestamp");
        if (cal == null) {
            setTimestamp(parameterIndex, x);
        }
        java.util.Calendar targetCalendar = java.util.Calendar.getInstance(cal.getTimeZone());
        targetCalendar.clear();
        targetCalendar.setTime(x);
        java.util.Calendar defaultCalendar = java.util.Calendar.getInstance();
        defaultCalendar.clear();
        defaultCalendar.setTime(x);
        long timeZoneOffset =
                targetCalendar.get(java.util.Calendar.ZONE_OFFSET) -
                        defaultCalendar.get(java.util.Calendar.ZONE_OFFSET) +
                        targetCalendar.get(java.util.Calendar.DST_OFFSET) - defaultCalendar.get(java.util.Calendar.DST_OFFSET);
        java.sql.Timestamp adjustedTimestamp = ((timeZoneOffset == 0) || (x == null)) ? x : new
                java.sql.Timestamp(x.getTime() + timeZoneOffset);
        if (x != null) {
            adjustedTimestamp.setNanos(x.getNanos());
        }
        setTimestamp(parameterIndex, adjustedTimestamp);
    }

    /**
     * JDBC 2.0
     *
     * Sets the designated parameter to SQL NULL.  This version of setNull should
     * be used for user-named types and REF type parameters.  Examples
     * of user-named types include: STRUCT, DISTINCT, JAVA_OBJECT, and 
     * named array types.
     *
     * <P><B>Note:</B> To be portable, applications must give the
     * SQL type code and the fully-qualified SQL type name when specifying
     * a NULL user-defined or REF parameter.  In the case of a user-named type 
     * the name is the type name of the parameter itself.  For a REF 
     * parameter the name is the type name of the referenced type.  If 
     * a JDBC driver does not need the type code or type name information, 
     * it may ignore it.     
     *
     * Although it is intended for user-named and Ref parameters,
     * this method may be used to set a null parameter of any JDBC type.
     * If the parameter does not have a user-named or REF type, the given
     * typeName is ignored.
     *
     *
     * @param parameterIndex the first parameter is 1, the second is 2, ...
     * @param sqlType a value from java.sql.Types
     * @param typeName the fully-qualified name of an SQL user-named type,
     *  ignored if the parameter is not a user-named type or REF 
     * @exception SQLException if a database access error occurs
     */
    public void setNull(int paramIndex, int sqlType, String typeName)
            throws SQLException {
        connection.log("PrepareStatement.setNull");
    }

    /**
     * Verifying the validity of the parameter index
     * @param parameterIndex
     * @throws SQLException
     */
    protected void verify(int parameterIndex)
            throws SQLException {
        clearWarnings();

        //added to support WAS 5.3
        if (sSql.indexOf(":") < 0 && hSqlQaulifier.size() == 0) return;
        // The paramCount was set when the statement was prepared
        if ((parameterIndex <= 0) ||
                (parameterIndex > hSqlQaulifier.size())) {
            Object[] objs = {Integer.valueOf(String.valueOf(parameterIndex))};
            throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_parameter_number, objs));
        }
    }

    /**
     * @history - thoniyilmk - 03/04/2004 - CR 8219
     * 		The values that goes as part of the qualifier were trimmed, before 
     * 		putting this as part of the host variables. This happens only when a
     * 		PreparedStatement is used. As the values should be passed to host as 
     * 		it is, the trim part should be removed from the code. This code is not
     * 		removed at this point as the impact on the application (Xpress) is not
     * 		known. This code "value=value.trim();" should be removed at a later time.
     *
     * 		thoniyilmk - 05/22/2007
     * 		Modified to check if a single quote (') is followed by another quote. If so, don't double 
     * 		the quotes and leave it as it is.
     */
    private void sqlQuilifierUpdate(int queryOrUpdate) {
        if (!hSqlQaulifier.isEmpty()) {
            //Enumeration enum = hSqlQaulifier.keys();
            String o;
            StringBuffer bTemp = new StringBuffer("/USING=(");
            String fetchSize = "", value;
            for (int i = 1; i < hSqlQaulifier.size() + 1; i++) {
                o = String.valueOf(i);
                value = ((String) hSqlQaulifier.get(o));
                if (value == null) value = "";
                StringBuffer sBuffer = new StringBuffer();

                for (int j = 0; j < value.length(); j++) {
                    if (value.charAt(j) == '\'') {
                        if ((j < value.length() - 1) && (value.charAt(j + 1) == '\'')) {
                            sBuffer.append(value.charAt(j));
                            sBuffer.append(value.charAt(j + 1));
                            j++;
                        } else {
                            sBuffer.append('\'');
                            sBuffer.append(value.charAt(j));
                        }
                        continue;
                    } else
                        sBuffer.append(value.charAt(j));
                }
                value = sBuffer.toString();
                if (o.equals("1")) bTemp.append("D").append(o).append("=").append('\'' + value + '\'');
                else if (!o.equalsIgnoreCase("ROWS"))
                    bTemp.append(",D").append(o).append("=").append('\'' + value + '\'');
                else if (o.equalsIgnoreCase("ROWS")) fetchSize = "ROWS=" + value;
            }
            if (hSqlQaulifier.size() > 0) bTemp.append(")");

            /***
             * Manoj Thoniyil - 07/29/05
             *
             * This code was overwriting any existing Qualifiers
             ***/

            if (queryOrUpdate == 1)
                ((ScMsqlQueryStatement) dBStatement).sqlQuailfier = ((ScMsqlQueryStatement) dBStatement).sqlQuailfier + fetchSize + bTemp.toString();
            else
                ((ScMsqlDDLStatement) dBStatement).sqlQuailfier = ((ScMsqlDDLStatement) dBStatement).sqlQuailfier + bTemp.toString();
        }
    }

    /**
     * Determine the data type of the Object by attempting to cast
     * the object.  An exception will be thrown if an invalid casting
     * is attempted.
     * @param x the object whose data type to be retrieved
     * @return the Object type
     * @throws SQLException
     */
    protected int getObjectType(
            Object x)
            throws SQLException {

        // Determine the data type of the Object by attempting to cast
        // the object.  An exception will be thrown if an invalid casting
        // is attempted.
        if (x == null)
            return 0;
        try {
            if ((String) x != null)
                return 12;
        } catch (Exception ex) {
        }
        try {
            if ((BigDecimal) x != null)
                return 2;
        } catch (Exception ex) {
        }
        try {
            if ((Boolean) x != null)
                return -7;
        } catch (Exception ex) {
        }
        try {
            if ((Integer) x != null)
                return 4;
        } catch (Exception ex) {
        }
        try {
            if ((Long) x != null)
                return -5;
        } catch (Exception ex) {
        }
        try {
            if ((Float) x != null)
                return 6;
        } catch (Exception ex) {
        }
        try {
            if ((Double) x != null)
                return 8;
        } catch (Exception ex) {
        }
        try {
            if ((byte[]) x != null)
                return -3;
        } catch (Exception ex) {
        }
        try {
            if ((java.sql.Date) x != null)
                return 91;
        } catch (Exception ex) {
        }
        try {
            if ((java.sql.Time) x != null)
                return 92;
        } catch (Exception ex) {
        }
        try {
            if ((java.sql.Timestamp) x != null)
                return 93;
        } catch (Exception ex) {
        }
        try {
            if ((Blob) x != null)
                return Types.BLOB;
        } catch (Exception ex) {
        }
        return 1111;
    }

    /**
     * Forms the cells ( Rows and Columns) using ScMSQLFormat
     * @param dBStatement Instance of ScMsqlQueryStatement
     * @throws SQLException If any database access error occurs

     * @param dBStatement
     * @throws SQLException
     */
    protected void fetch(ScDBStatement dBStatement)
            throws SQLException {
        if (dBStatement instanceof ScMsqlQueryStatement) {
            ScMsqlQueryStatement stmt = (ScMsqlQueryStatement) dBStatement;
            ScMSQLFormat.parseRawResult(cells, stmt.getReply(), 0);
            i_iTotalRows = cells.rows();
            stmt.setReply(null);    //release memory RMX

            copyDesc = new Object[i_iTotalRows][i_ahHash.size()];
            for (int i = 0; i < i_iTotalRows; i++) {
                for (int j = 0; j < i_ahHash.size(); j++) {
                    copyDesc[i][j] = cells.elementAt(i, j);
                }
            }
        }
    }

    private ResultSet spQuery() throws SQLException {

        //format the sql
        Vector v = new Vector();
        String newsql = ScMSQLFormat.sphost(sSql, v);
        //get sp_id form jvm cache
        String sDb = connection.sDatabase;
        String sp_id = (String) storeprocedure.get(sDb + "|" + newsql);

        if (sp_id == null) {
            String spsql = "CREATE PROCEDURE * AS ";
            spsql = spsql + newsql;
            ResultSet rs = super.executeQuery(spsql);
            if (rs.next()) {
                sp_id = rs.getString(1);
                rs.close();
                storeprocedure.put(sDb + "|" + newsql, sp_id);
            } else {
                ScDBError.check_error(-49, spsql);
                return null;
            }
        }

        TreeMap map = new TreeMap();

        for (int i = 0; i < v.size(); i++) {
            int colIndex = newsql.indexOf(":C" + String.valueOf(i + 1));
            String s = String.valueOf(colIndex);
            map.put(Integer.valueOf(s), v.get(i));
        }

        String key, value;
        for (int i = 0; i < hSqlQaulifier.size(); i++) {
            key = String.valueOf(i + 1);
            value = ((String) hSqlQaulifier.get(key));
            if (value == null) value = "";
            value = value.trim();
            int colIndex = newsql.indexOf(":D" + key);
            String s = String.valueOf(colIndex);
            map.put(Integer.valueOf(s), value);
        }

        StringBuffer bf = new StringBuffer();
        Set set = map.keySet();
        Iterator parse = set.iterator();
        Integer setKey;
        int i = 0;
        while (parse.hasNext()) {
            setKey = (Integer) parse.next();
            value = (String) map.get(setKey);
            if (i == 0) {
                bf = bf.append(" USING (").append("'").append(value).append("'");
                i++;
            } else
                bf = bf.append(",'").append(value).append("'");
        }

        if (i > 0) bf = bf.append(")");

        String spsql = sp_id + " " + bf.toString();
        ResultSet rs = super.executeQuery(spsql.trim());
        return rs;

    }

    //  --------------------------JDBC 3.0-----------------------------
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
        ScDBError.check_error(-52, "jjava.sql.Statement#getMoreResults(int)");
        return false;
    }


    /* (non-Javadoc)
     * @see java.sql.Statement#getResultSetHoldability()
     */
    public int getResultSetHoldability() throws SQLException {
        return this.resHoldabilty;

    }

    @Override
    public void setNClob(int parameterIndex, NClob value) {

    }

    @Override
    public void setNClob(int parameterIndex, Reader reader) {

    }

    @Override
    public void setNClob(int parameterIndex, Reader reader, long length) {

    }

    @Override
    public void setBlob(int parameterIndex, InputStream inputStream) {

    }

    @Override
    public void setBlob(int parameterIndex, InputStream inputStream, long length) {

    }

    @Override
    public void setClob(int parameterIndex, Reader reader) {

    }

    @Override
    public void setClob(int parameterIndex, Reader reader, long length) {

    }

    @Override
    public void setNCharacterStream(int parameterIndex, Reader value) {

    }

    @Override
    public void setNCharacterStream(int parameterIndex, Reader value, long length) {

    }

    @Override
    public void setCharacterStream(int parameterIndex, Reader reader) {

    }

    @Override
    public void setCharacterStream(int parameterIndex, Reader reader, long length) {

    }

    @Override
    public void setBinaryStream(int parameterIndex, InputStream x) {

    }

    @Override
    public void setBinaryStream(int parameterIndex, InputStream x, long length) {

    }

    @Override
    public void setAsciiStream(int parameterIndex, InputStream x) {

    }

    @Override
    public void setAsciiStream(int parameterIndex, InputStream x, long length) {

    }

    @Override
    public void setSQLXML(int parameterIndex, SQLXML xmlObject) {

    }

    @Override
    public void setNString(int parameterIndex, String value) {

    }

    @Override
    public void setRowId(int parameterIndex, RowId x) {

    }

}


