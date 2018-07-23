/**
 * <P>A connection (session) with a specific
 * database. Within the context of a Connection, SQL statements are
 * executed and results are returned.
 *
 * <P>A Connection's database is able to provide information
 * describing its tables, its supported SQL grammar, its stored
 * procedures, the capabilities of this connection, and so on. This
 * information is obtained with the <code>getMetaData</code> method.
 *
 * <P><B>Note:</B> By default the Connection automatically commits
 * changes after executing each statement. If auto commit has been
 * disabled, an explicit commit must be done or database changes will
 * not be saved.
 *
 * @version 1.0  Spet. 28 1999
 * @author Quansheng Jia
 * @see java.sql.Connection
 */

package sanchez.jdbc.driver;

import java.sql.*;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.Enumeration;
import java.util.Locale;
import java.util.Properties;
import java.util.Hashtable;
import java.util.Vector;

import sanchez.him_pa.ScProfToken;

import java.io.PrintStream;
import java.io.PrintWriter;
import java.util.concurrent.Executor;

import sanchez.base.ScDateManager;
import sanchez.base.ScNumberManager;
import sanchez.jdbc.dbaccess.ScDBAccess;
import sanchez.jdbc.dbaccess.ScDBError;
import sanchez.jdbc.pool.ScPooledConnection;

public class ScConnection implements Connection {

    public String i_sUrl;
    public String i_sUser;
    public boolean i_bAutoCommit;
    public ScDBAccess i_dDbAccess;
    public String sDatabase;

    public int i_iDefaultBatch = 0;
    public int i_iDefaultRowPrefetch = 30;
    public ScNumberManager nm = null;
    public ScDateManager sm = null;

    public Properties info;
    public Hashtable i_hStatementTable;
    public Vector xaTable;
    boolean i_bClosed;

    boolean physicalStatus;
    private boolean logicalHandle;
    ScPooledConnection pooledConnection;

    public static final int TRANSACTION_NONE = 0;
    public static final int TRANSACTION_READ_UNCOMMITTED = 1;
    public static final int TRANSACTION_READ_COMMITTED = 2;
    public static final int TRANSACTION_REPEATABLE_READ = 4;
    public static final int TRANSACTION_SERIALIZABLE = 8;

    boolean XA_wants_error;
    boolean UsingXA;
    protected int resHoldability = ResultSet.CLOSE_CURSORS_AT_COMMIT;
    Locale connLocale;

    public ScConnection()
            throws SQLException {
    }

    public ScConnection(ScDBAccess dAccessor, String sUrl, String sUser, String sPassword, String sDatabase, Properties pInfo)
            throws SQLException {
        ini(sUrl, sUser, sDatabase, dAccessor, pInfo);
        logicalHandle = false;

        try {
            dAccessor.logon(sUser, sPassword, sDatabase, pInfo, sUrl);
            setAutoCommit(true);

            iniDateManager();
            iniNumberManager();
        } catch (Exception e) {
            ScDBError.check_error(e);
        }
    }

    /**
     * The API will be called by PooledConnection class
     */
    public ScConnection(ScPooledConnection poolCon, ScConnection physicalConn, boolean autoCommitFlag)
            throws SQLException {
        ini(physicalConn.i_sUrl, physicalConn.i_sUser, physicalConn.sDatabase, physicalConn.i_dDbAccess, physicalConn.info);
        logicalHandle = true;
        pooledConnection = poolCon;
        setAutoCommit(autoCommitFlag);
    }

    /**
     * SQL statements without parameters are normally
     * executed using Statement objects. If the same SQL statement 
     * is executed many times, it is more efficient to use a 
     * PreparedStatement
     *
     * @return a new Statement object 
     * @exception SQLException if a database-access error occurs.
     */
    public Statement createStatement()
            throws SQLException {
        log("Connection.createStatement");
        checkPhysicalStatus();
        if (i_bClosed)
            ScDBError.check_error(-8, "createStatement");

        ScStatement stmt = new ScStatement(this);
        addStatement(stmt);
        return stmt;
    }

    /**
     * A SQL statement with or without IN parameters can be
     * pre-compiled and stored in a PreparedStatement object. This
     * object can then be used to efficiently execute this statement
     * multiple times.
     *
     * <P><B>Note:</B> This method is optimized for handling
     * parametric SQL statements that benefit from precompilation. If
     * the driver supports precompilation, prepareStatement will send
     * the statement to the database for precompilation. Some drivers
     * may not support precompilation. In this case, the statement may
     * not be sent to the database until the PreparedStatement is
     * executed.  This has no direct affect on users; however, it does
     * affect which method throws certain SQLExceptions.
     *
     * @param sql a SQL statement that may contain one or more '?' IN
     * parameter placeholders
     * @return a new PreparedStatement object containing the
     * pre-compiled statement 
     * @exception SQLException if a database-access error occurs.
     */
    public PreparedStatement prepareStatement(String sSqlStatement)
            throws SQLException {
        log("Connection.prepareStatement");
        checkPhysicalStatus();
        if (i_bClosed)
            ScDBError.check_error(-8, "prepareStatement");

        ScPreparedStatement pstmt = new ScPreparedStatement(this, sSqlStatement);
        addStatement(pstmt);

        return pstmt;
    }

    /**
     * A SQL stored procedure call statement is handled by creating a
     * CallableStatement for it. The CallableStatement provides
     * methods for setting up its IN and OUT parameters, and
     * methods for executing it.
     *
     * <P><B>Note:</B> This method is optimized for handling stored
     * procedure call statements. Some drivers may send the call
     * statement to the database when the prepareCall is done; others
     * may wait until the CallableStatement is executed. This has no
     * direct affect on users; however, it does affect which method
     * throws certain SQLExceptions.
     *
     * @param sql a SQL statement that may contain one or more '?'
     * parameter placeholders. Typically this  statement is a JDBC
     * function call escape string.
     * @return a new CallableStatement object containing the
     * pre-compiled SQL statement 
     * @exception SQLException if a database-access error occurs.
     */
    public CallableStatement prepareCall(String sSqlStatement)
            throws SQLException {
        log("Connection.prepareCall");
        checkPhysicalStatus();
        if (i_bClosed)
            ScDBError.check_error(-8, "prepareCall");

        ScCallableStatement cstmt = new ScCallableStatement(this, sSqlStatement);
        addStatement(cstmt);

        return cstmt;
    }

    /**
     * A driver may convert the JDBC sql grammar into its system's
     * native SQL grammar prior to sending it; nativeSQL returns the
     * native form of the statement that the driver would have sent.
     *
     * @param sql a SQL statement that may contain one or more '?'
     * parameter placeholders
     * @return the native form of this statement
     * @exception SQLException if a database-access error occurs.
     */
    public String nativeSQL(String sSql)
            throws SQLException {

        log("Connection.nativeSQL");
        //String ScSql = new ScSqlFormat().parse(sSql);
        return sSql;

    }

    /**
     * If a connection is in auto-commit mode, then all its SQL
     * statements will be executed and committed as individual
     * transactions.  Otherwise, its SQL statements are grouped into
     * transactions that are terminated by either commit() or
     * rollback().  By default, new connections are in auto-commit
     * mode.
     *
     * The commit occurs when the statement completes or the next
     * execute occurs, whichever comes first. In the case of
     * statements returning a ResultSet, the statement completes when
     * the last row of the ResultSet has been retrieved or the
     * ResultSet has been closed. In advanced cases, a single
     * statement may return multiple results as well as output
     * parameter values. Here the commit occurs when all results and
     * output param values have been retrieved.
     *
     * @param autoCommit true enables auto-commit; false disables
     * auto-commit.  
     * @exception SQLException if a database-access error occurs.
     */
    public void setAutoCommit(boolean autoCommit)
            throws SQLException {
        log("Connection.setAutoCommit(" + autoCommit + ")");
        checkPhysicalStatus();
        if (XA_wants_error || UsingXA && autoCommit)
            ScDBError.check_error(261);
        if (i_bClosed)
            ScDBError.check_error(-8, "setAutoCommit");

        try {
            i_dDbAccess.setAutoCommit(autoCommit);
        } catch (Exception e) {
            ScDBError.check_error(e);
        }

        i_bAutoCommit = autoCommit;
    }

    /**
     * Get the current auto-commit state.
     *
     * @return Current state of auto-commit mode.
     * @exception SQLException if a database-access error occurs.
     * @see #setAutoCommit
     */
    public boolean getAutoCommit()
            throws SQLException {
        log("Connection.getAutoCommit");
        return i_bAutoCommit;
    }

    /**
     * Commit makes all changes made since the previous
     * commit/rollback permanent and releases any database locks
     * currently held by the Connection. This method should only be
     * used when auto commit has been disabled.
     *
     * @exception SQLException if a database-access error occurs.
     * @see #setAutoCommit
     */
    public void commit()
            throws SQLException {
        log("Connection.commit()");
        checkPhysicalStatus();
        if (XA_wants_error || UsingXA)
            ScDBError.check_error(261);
        if (i_bClosed)
            ScDBError.check_error(-8, "commit");
        if (i_bAutoCommit) return;
        try {
            for (Enumeration e = i_hStatementTable.elements(); e.hasMoreElements(); ) {
                ScStatement s = (ScStatement) e.nextElement();
                s.sendBatch();
            }
            i_dDbAccess.commit();
        } catch (Exception ex) {
            i_iDefaultBatch = 0;
            ScDBError.check_error(ex);
        } finally {
            i_iDefaultBatch = 0;
        }
    }

    /**
     * Commit makes all changes made since the previous
     * commit/rollback permanent and releases any database locks
     * currently held by the Connection. This method should only be
     * used when auto commit has been disabled.
     *
     * @exception SQLException if a database-access error occurs.
     * @see #setAutoCommit
     */
    public String[] batchCommit()
            throws SQLException {
        log("Connection.commit()");
        checkPhysicalStatus();
        if (XA_wants_error || UsingXA)
            ScDBError.check_error(261);
        if (i_bClosed)
            ScDBError.check_error(-8, "commit");
        if (i_bAutoCommit) return null;
        String[] batchResult = null;
        try {
            for (Enumeration e = i_hStatementTable.elements(); e.hasMoreElements(); ) {
                ScStatement s = (ScStatement) e.nextElement();
                s.sendBatch();
            }
            batchResult = i_dDbAccess.batchCommit();
        } catch (Exception ex) {
            i_iDefaultBatch = 0;
            ScDBError.check_error(ex);
        } finally {
            i_iDefaultBatch = 0;
        }
        return batchResult;
    }


    /**
     * Rollback drops all changes made since the previous
     * commit/rollback and releases any database locks currently held
     * by the Connection. This method should only be used when auto
     * commit has been disabled.
     *
     * @exception SQLException if a database-access error occurs.
     * @see #setAutoCommit
     */

    public void rollback()
            throws SQLException {
        log("Connection.rollback");
        checkPhysicalStatus();
        if (XA_wants_error || UsingXA)
            ScDBError.check_error(261);
        if (i_bClosed)
            ScDBError.check_error(-8, "commit");

        try {

            i_dDbAccess.rollback();
        } catch (Exception e) {
            ScDBError.check_error(e);
        }
    }

    /**
     * In some cases, it is desirable to immediately release a
     * Connection's database and JDBC resources instead of waiting for
     * them to be automatically released; the close method provides this
     * immediate release. 
     *
     * <P><B>Note:</B> A Connection is automatically closed when it is
     * garbage collected. Certain fatal errors also result in a closed
     * Connection.
     *
     * @exception SQLException if a database-access error occurs.
     */
    public void close()
            throws SQLException {
        if (i_bClosed)
            return;

        i_bClosed = true;
        closeStatements();

        if (logicalHandle) {
            logicalClose();
            return;
        }

        try {
            XA_wants_error = false;
            i_dDbAccess.logoff();
            cleanUp();
        } catch (Exception e) {
            ScDBError.check_error(e);
        }
    }

    /**
     * Tests to see if a Connection is closed.
     *
     * @return true if the connection is closed; false if it's still open
     * @exception SQLException if a database-access error occurs.
     */
    public boolean isClosed()
            throws SQLException {
        log("Connection.isClosed");
        return i_bClosed;

    }

    //======================================================================
    // Advanced features:

    /**
     * A Connection's database is able to provide information
     * describing its tables, its supported SQL grammar, its stored
     * procedures, the capabilities of this connection, etc. This
     * information is made available through a DatabaseMetaData
     * object.
     *
     * @return a DatabaseMetaData object for this Connection 
     * @exception SQLException if a database-access error occurs.
     */
    public java.sql.DatabaseMetaData getMetaData()
            throws SQLException {
        log("Connection.getMetaData");
        if (i_bClosed)
            ScDBError.check_error(-8, "getMetaData");
        return new ScDatabaseMetaData(this);
    }

    /**
     * You can put a connection in read-only mode as a hint to enable 
     * database optimizations.
     *
     * <P><B>Note:</B> setReadOnly cannot be called while in the
     * middle of a transaction.
     *
     * @param readOnly true enables read-only mode; false disables
     * read-only mode.  
     * @exception SQLException if a database-access error occurs.
     */
    public void setReadOnly(boolean readOnly)
            throws SQLException {
        log("Connection.setReadOnly");
        if (readOnly)
            ScDBError.check_error(-29, "setReadOnly");
    }

    /**
     * Tests to see if the connection is in read-only mode.
     *
     * @return true if connection is read-only
     * @exception SQLException if a database-access error occurs.
     */
    public boolean isReadOnly()
            throws SQLException {
        log("Connection.isReadOnly");
        return false;
    }

    /**
     * A sub-space of this Connection's database may be selected by setting a
     * catalog name. If the driver does not support catalogs it will
     * silently ignore this request.
     *
     * @exception SQLException if a database-access error occurs.
     */
    public void setCatalog(String string)
            throws SQLException {
        log("Connection.setCatalog");
    }

    /**
     * Return the Connection's current catalog name.
     *
     * @return the current catalog name or null
     * @exception SQLException if a database-access error occurs.
     */
    public String getCatalog()
            throws SQLException {
        log("Connection.getCatalog");
        return null;
    }

    /**
     * You can call this method to try to change the transaction
     * isolation level using one of the TRANSACTION_* values.
     *
     * <P><B>Note:</B> setTransactionIsolation cannot be called while
     * in the middle of a transaction.
     *
     * @param level one of the TRANSACTION_* isolation values with the
     * exception of TRANSACTION_NONE; some databases may not support
     * other values
     * @exception SQLException if a database-access error occurs.
     * @see DatabaseMetaData#supportsTransactionIsolationLevel
     */
    public void setTransactionIsolation(int level)
            throws SQLException {
        log("Connection.setTransactionIsolation");
        if (level != Connection.TRANSACTION_READ_UNCOMMITTED)
//            ScDBError.check_error(-30, "setTransactionIsolation");
            /* For Beta XES testing 10/13/2005*/
            log("Supplied transaction isolation level is not supported by Profile");
    }

    /**
     * Get this Connection's current transaction isolation mode.
     *
     * @return the current TRANSACTION_* mode value
     * @exception SQLException if a database-access error occurs.
     */
    public int getTransactionIsolation()
            throws SQLException {
        log("Connection.getTransactionIsolation");
        return Connection.TRANSACTION_READ_UNCOMMITTED;
    }

    public java.sql.SQLWarning getWarnings()
            throws SQLException {
        log("Connection.getWarnings");
        return null;
    }

    public void clearWarnings()
            throws SQLException {
    }

    void addStatement(Statement s) {
        //if (i_bAutoCommit == true) return;
        //System.out.print("\n ScConnection "+s+"   "+i_bAutoCommit+" size:"+i_hStatementTable.size());
        i_hStatementTable.put(s, s);
    }

    private void closeStatements()
            throws SQLException {
        for (Enumeration e = i_hStatementTable.elements(); e.hasMoreElements(); ) {
            Statement s = (Statement) e.nextElement();
            s.close();
            s = null;
        }
        closeXaStatements();
    }

    public synchronized void closeXaStatements()
            throws SQLException {
        for (Enumeration e = xaTable.elements(); e.hasMoreElements(); ) {
            Object s = e.nextElement();
            s = null;
        }
        xaTable.clear();
    }

    //--------------------------JDBC 2.0-----------------------------

    /**
     * JDBC 2.0
     *
     * Creates a <code>Statement</code> object that will generate
     * <code>ResultSet</code> objects with the given type and concurrency.
     * This method is the same as the <code>createStatement</code> method
     * above, but it allows the default result set
     * type and result set concurrency type to be overridden.
     *
     * @param resultSetType a result set type; see ResultSet.TYPE_XXX
     * @param resultSetConcurrency a concurrency type; see ResultSet.CONCUR_XXX
     * @return a new Statement object 
     * @exception SQLException if a database access error occurs
     */
    public Statement createStatement(int resultSetType, int resultSetConcurrency)
            throws SQLException {
        log("Connection.createStatement");
        checkPhysicalStatus();
        if (i_bClosed)
            ScDBError.check_error(-8, "createStatement");

        ScStatement stmt = new ScStatement(this, resultSetType, resultSetConcurrency);
        addStatement(stmt);
        return stmt;
    }

    /**
     * JDBC 2.0
     *
     * Creates a <code>PreparedStatement</code> object that will generate
     * <code>ResultSet</code> objects with the given type and concurrency.
     * This method is the same as the <code>prepareStatement</code> method
     * above, but it allows the default result set
     * type and result set concurrency type to be overridden.
     *
     * @param resultSetType a result set type; see ResultSet.TYPE_XXX
     * @param resultSetConcurrency a concurrency type; see ResultSet.CONCUR_XXX
     * @return a new PreparedStatement object containing the
     * pre-compiled SQL statement 
     * @exception SQLException if a database access error occurs
     */
    public PreparedStatement prepareStatement(String sql, int resultSetType,
                                              int resultSetConcurrency)
            throws SQLException {
        log("Connection.prepareStatement");
        checkPhysicalStatus();
        if (i_bClosed)
            ScDBError.check_error(-8, "prepareStatement");

        ScPreparedStatement pstmt = new ScPreparedStatement(this, sql, resultSetType, resultSetConcurrency);
        addStatement(pstmt);

        return pstmt;
    }

    /**
     * JDBC 2.0
     *
     * Creates a <code>CallableStatement</code> object that will generate
     * <code>ResultSet</code> objects with the given type and concurrency.
     * This method is the same as the <code>prepareCall</code> method
     * above, but it allows the default result set
     * type and result set concurrency type to be overridden.
     *
     * @param resultSetType a result set type; see ResultSet.TYPE_XXX
     * @param resultSetConcurrency a concurrency type; see ResultSet.CONCUR_XXX
     * @return a new CallableStatement object containing the
     * pre-compiled SQL statement 
     * @exception SQLException if a database access error occurs
     */
    public CallableStatement prepareCall(String sql, int resultSetType,
                                         int resultSetConcurrency) throws SQLException {
        log("Connection.prepareCall");
        checkPhysicalStatus();
        if (i_bClosed)
            ScDBError.check_error(-8, "prepareCall");

        ScCallableStatement cstmt = new ScCallableStatement(this, sql, resultSetType, resultSetConcurrency);
        addStatement(cstmt);

        return cstmt;
    }

    /**
     * JDBC 2.0
     *
     * Gets the type map object associated with this connection.
     * Unless the application has added an entry to the type map,
     * the map returned will be empty.
     *
     * @return the <code>java.util.Map</code> object associated
     *         with this <code>Connection</code> object
     */

    public java.util.Map getTypeMap() throws SQLException {
        log("Connection.getTypeMap");
        return null;
    }

    /**
     * JDBC 2.0
     *
     * Installs the given type map as the type map for
     * this connection.  The type map will be used for the
     * custom mapping of SQL structured types and distinct types.
     *
     * @param the <code>java.util.Map</code> object to install
     *        as the replacement for this <code>Connection</code>
     *        object's default type map
     */
    public void setTypeMap(java.util.Map map) throws SQLException {
        log("Connection.setTypeMap");
    }

    public void log(String s)
            throws SQLException {
        PrintStream out = DriverManager.getLogStream();
        if (out != null) {
            out.println(s);
            out.flush();
            return;
        }

        try {
            PrintWriter w = DriverManager.getLogWriter();
            if (w != null) {
                w.println(s);
                w.flush();
                return;
            }
        } catch (Exception ee) {
        }
    }

    private void iniNumberManager() {
        String number_pattern = (String) info.get("numberFormat");

        if (number_pattern == null) return;

        DecimalFormat i_oDecimalFormat;

        // determine number formatter---------
        NumberFormat nf = NumberFormat.getInstance(getLocale());
        i_oDecimalFormat = (DecimalFormat) nf;

        //DecimalFormatSymbols dfs = i_oDecimalFormat.getDecimalFormatSymbols();
        i_oDecimalFormat.applyPattern(number_pattern);

        //NumberFormat nfs = NumberFormat.getInstance(i_oLocale);		
        DecimalFormat i_oIntegerFormats = (DecimalFormat) nf;
        i_oIntegerFormats.applyPattern("####");

        nm = new ScNumberManager(i_oDecimalFormat, i_oIntegerFormats, number_pattern);

    }

    private void cleanUp() {
        i_dDbAccess = null;
        nm = null;
        sm = null;
        i_hStatementTable = null;
    }

    private void ini(String url, String user, String database, ScDBAccess dbaccess, Properties info)
            throws SQLException {

        i_sUrl = url;
        i_sUser = user;
        i_dDbAccess = dbaccess;
        sDatabase = database;
        this.info = info;
        XA_wants_error = false;
        UsingXA = false;
        i_hStatementTable = null;
        xaTable = new Vector();
        i_hStatementTable = new Hashtable(10);

        physicalStatus = true;
        i_bClosed = false;
        setLocale((String) info.get("locale"));

        if (i_dDbAccess != null) {
            ScProfToken token = i_dDbAccess.getToken();
            if (token != null) {
                token.setServerChannelId("");
                token.setUserId("");
            }
        }
    }

    public String getURL() {
        return sDatabase;
    }

    public synchronized void setPhysicalStatus(boolean flag) {
        physicalStatus = flag;
    }

    private void checkPhysicalStatus()
            throws SQLException {
        if (!physicalStatus)
            ScDBError.check_error(2);
    }

    public synchronized void logicalClose()
            throws SQLException {
        closeStatements();
        if (pooledConnection != null && physicalStatus)
            pooledConnection.checkInlogicalConnection();
        setPhysicalStatus(false);
    }

    public void setUserId(String userId) {
        try {
            if (i_dDbAccess != null) {
                ScProfToken token = i_dDbAccess.getToken();
                token.setUserId(userId);
            }
        } catch (Exception e) {
        }
    }

    public void setChannelId(String channelId) {
        try {
            if (i_dDbAccess != null) {
                ScProfToken token = i_dDbAccess.getToken();
                token.setServerChannelId(channelId);
            }
        } catch (Exception e) {
        }
    }

    public boolean getXAErrorFlag() {
        return XA_wants_error;
    }

    public synchronized void setXAErrorFlag(boolean flag) {
        XA_wants_error = flag;
    }

    public boolean getUsingXAFlag() {
        return UsingXA;
    }

    public void setUsingXAFlag(boolean flag) {
        UsingXA = flag;
    }

    private void iniDateManager() {
        try {
            String datepattern = (String) info.get("dateFormat");
            String timepattern = (String) info.get("timeFormat");

            if (getLocale() == null && datepattern == null && timepattern == null) return;

            if (datepattern == null || datepattern.length() < 1) datepattern = "yyyy-mm-dd";
            if (timepattern == null || timepattern.length() < 1) timepattern = "hh:mm:ss";

            SimpleDateFormat dateformat = new SimpleDateFormat(datepattern, getLocale());
            SimpleDateFormat timeformat = new SimpleDateFormat(timepattern, getLocale());

            sm = new ScDateManager(getLocale(), dateformat, timeformat);
        } catch (Exception e) {
        }
    }

    //  --------------------------JDBC 3.0-----------------------------
    /* (non-Javadoc)
     * @see java.sql.Connection#setHoldability(int)
     */
    public void setHoldability(int holdability) throws SQLException {
        log("setHoldability()");
        if (holdability != ResultSet.CLOSE_CURSORS_AT_COMMIT && holdability != ResultSet.HOLD_CURSORS_OVER_COMMIT)
            ScDBError.check_error(263);
        this.resHoldability = holdability;

    }

    /* (non-Javadoc)
     * @see java.sql.Connection#getHoldability()
     */
    public int getHoldability() throws SQLException {
        return this.resHoldability;
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#setSavepoint()
     */
    public Savepoint setSavepoint() throws SQLException {
        ScDBError.check_error(-52, "java.sql.Connection#setSavepoint()");
        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#setSavepoint(java.lang.String)
     */
    public Savepoint setSavepoint(String name) throws SQLException {
        ScDBError.check_error(-52, "java.sql.Connection#setSavepoint(java.lang.String)");
        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#rollback(java.sql.Savepoint)
     */
    public void rollback(Savepoint savepoint) throws SQLException {
        ScDBError.check_error(-52, "java.sql.Connection#rollback(java.sql.Savepoint)");

    }

    /* (non-Javadoc)
     * @see java.sql.Connection#releaseSavepoint(java.sql.Savepoint)
     */
    public void releaseSavepoint(Savepoint savepoint) throws SQLException {
        ScDBError.check_error(-52, "java.sql.Connection#releaseSavepoint(java.sql.Savepoint)");

    }

    /* (non-Javadoc)
     * @see java.sql.Connection#createStatement(int, int, int)
     */
    public Statement createStatement(int resultSetType, int resultSetConcurrency, int resultSetHoldability) throws SQLException {
        log("Connection.createStatement");
        if (resultSetHoldability != ResultSet.CLOSE_CURSORS_AT_COMMIT && resultSetHoldability != ResultSet.HOLD_CURSORS_OVER_COMMIT)
            ScDBError.check_error(263);

        checkPhysicalStatus();
        if (i_bClosed)
            ScDBError.check_error(-8, "createStatement");

        ScStatement stmt = new ScStatement(this, resultSetType, resultSetConcurrency, resultSetHoldability);
        addStatement(stmt);
        return stmt;

    }

    /* (non-Javadoc)
     * @see java.sql.Connection#prepareStatement(java.lang.String, int, int, int)
     */
    public PreparedStatement prepareStatement(String sql, int resultSetType, int resultSetConcurrency, int resultSetHoldability) throws SQLException {
        log("Connection.prepareStatement");
        if (resultSetHoldability != ResultSet.CLOSE_CURSORS_AT_COMMIT && resultSetHoldability != ResultSet.HOLD_CURSORS_OVER_COMMIT)
            ScDBError.check_error(263);

        checkPhysicalStatus();
        if (i_bClosed)
            ScDBError.check_error(-8, "prepareStatement");

        ScPreparedStatement pstmt = new ScPreparedStatement(this, sql, resultSetType, resultSetConcurrency, resultSetHoldability);
        addStatement(pstmt);

        return pstmt;

    }

    /* (non-Javadoc)
     * @see java.sql.Connection#prepareCall(java.lang.String, int, int, int)
     */
    public CallableStatement prepareCall(String sql, int resultSetType, int resultSetConcurrency, int resultSetHoldability) throws SQLException {

        log("Connection.prepareCall");
        if (resultSetHoldability != ResultSet.CLOSE_CURSORS_AT_COMMIT && resultSetHoldability != ResultSet.HOLD_CURSORS_OVER_COMMIT)
            ScDBError.check_error(263);

        checkPhysicalStatus();
        if (i_bClosed)
            ScDBError.check_error(-8, "prepareCall");

        ScCallableStatement cstmt = new ScCallableStatement(this, sql, resultSetType, resultSetConcurrency, resultSetHoldability);
        addStatement(cstmt);

        return cstmt;
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#prepareStatement(java.lang.String, int)
     */
    public PreparedStatement prepareStatement(String sql, int autoGeneratedKeys) throws SQLException {
        ScDBError.check_error(-52, "java.sql.Connection#prepareStatement(java.lang.String, int)");
        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#prepareStatement(java.lang.String, int[])
     */
    public PreparedStatement prepareStatement(String sql, int[] columnIndexes) throws SQLException {
        ScDBError.check_error(-52, "java.sql.Connection#prepareStatement(java.lang.String, int[])");
        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.Connection#prepareStatement(java.lang.String, java.lang.String[])
     */
    public PreparedStatement prepareStatement(String sql, String[] columnNames) throws SQLException {
        ScDBError.check_error(-52, "java.sql.Connection#prepareStatement(java.lang.String, java.lang.String[])");
        return null;
    }

    private void setLocale(String sLocale) {
        //First default to driver level locale
        this.connLocale = ScDriver.getDriverLocale();
        // - determine the locale
        if (sLocale != null) {
            /*
             * Delimiter ":" is used for downward compatibility.
             * Old profile db url's locale format is "locale=country:language".
             * One example seen is "locale=US:ENGLISH", for locale to work ISO code should be used.
             * Java standard locale format is language_country (example: en_US) for more info refer Locale class.
             */
            String tokens[] = sLocale.split("[:_]");
            if (tokens.length == 2) {
                //tokens[1] is language code and tokens[0] is country code
                this.connLocale = new Locale(tokens[1], tokens[0], "");
            }
        }
    }

    public Locale getLocale() {
        return connLocale;
    }

    @Override
    public int getNetworkTimeout() {
        return 0;
    }

    @Override
    public void setNetworkTimeout(Executor executor, int milliseconds) {

    }

    @Override
    public void abort(Executor executor) {

    }

    @Override
    public String getSchema() {
        return null;
    }

    @Override
    public void setSchema(String schema) {

    }

    @Override
    public Struct createStruct(String typeName, Object[] attributes) {
        return null;
    }

    @Override
    public Array createArrayOf(String typeName, Object[] elements) {
        return null;
    }

    @Override
    public Properties getClientInfo() {
        return null;
    }

    @Override
    public String getClientInfo(String name) {
        return null;
    }

    @Override
    public void setClientInfo(Properties properties) {

    }

    @Override
    public void setClientInfo(String name, String value) {

    }

    @Override
    public boolean isValid(int timeout) {
        return false;
    }

    @Override
    public SQLXML createSQLXML() {
        return null;
    }

    @Override
    public NClob createNClob() {
        return null;
    }

    @Override
    public Blob createBlob() {
        return null;
    }

    @Override
    public Clob createClob() {
        return null;
    }

    @Override
    public boolean isWrapperFor(Class<?> iface) {
        return false;
    }

    @Override
    public <T> T unwrap(Class<T> iface) {
        return null;
    }
}

