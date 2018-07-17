package sanchez.jdbc.pool;


import java.sql.SQLException;
import java.sql.Connection;
import javax.sql.ConnectionPoolDataSource;
import javax.sql.PooledConnection;

/**
 * A ConnectionPoolDataSource object is a factory for PooledConnection
 * objects.  An object that implements this interface will typically be
 * registered with a JNDI service.
 */
public class ScConnectionPoolDataSource extends ScDataSource
        implements ConnectionPoolDataSource {

    public ScConnectionPoolDataSource()
            throws SQLException {
        super();
    }

    /**
     * <p>Attempt to establish a database connection.
     *
     * @return a Connection to the database
     * @throws SQLException if a database-access error occurs.
     */
    public PooledConnection getPooledConnection()
            throws SQLException {
        return getPooledConnection(user, password);
    }

    protected Connection getPhysicalConnection()
            throws SQLException {
        return super.getConnection(user, password);
    }

    protected Connection getPhysicalConnection(String userName, String password)
            throws SQLException {
        return super.getConnection(userName, password);
    }

    protected Connection getPhysicalConnection(String url, String userName, String password)
            throws SQLException {
        this.url = url;
        return super.getConnection(userName, password);
    }

    /**
     * <p>Attempt to establish a database connection.
     *
     * @param user     the database user on whose behalf the Connection is being made
     * @param password the user's password
     * @return a Connection to the database
     * @throws SQLException if a database-access error occurs.
     */
    public PooledConnection getPooledConnection(String user, String password)
            throws SQLException {
        Connection connection = getPhysicalConnection(url, user, password);
        ScPooledConnection pooledConnection = new ScPooledConnection(connection);
        return pooledConnection;
    }

    /**
     * <p>Get the log writer for this data source.
     *
     * <p>The log writer is a character output stream to which all logging
     * and tracing messages for this data source object instance will be
     * printed.  This includes messages printed by the methods of this
     * object, messages printed by methods of other objects manufactured
     * by this object, and so on.  Messages printed to a data source
     * specific log writer are not printed to the log writer associated
     * with the java.sql.Drivermanager class.  When a data source object is
     * created the log writer is initially null, in other words, logging
     * is disabled.
     *
     * @return the log writer for this data source, null if disabled
     * @throws SQLException if a database-access error occurs.
     */
    public java.io.PrintWriter getLogWriter()
            throws SQLException {
        return super.getLogWriter();
    }

    /**
     * <p>Set the log writer for this data source.
     *
     * <p>The log writer is a character output stream to which all logging
     * and tracing messages for this data source object instance will be
     * printed.  This includes messages printed by the methods of this
     * object, messages printed by methods of other objects manufactured
     * by this object, and so on.  Messages printed to a data source
     * specific log writer are not printed to the log writer associated
     * with the java.sql.Drivermanager class. When a data source object is
     * created the log writer is initially null, in other words, logging
     * is disabled.
     *
     * @param out the new log writer; to disable, set to null
     * @throws SQLException if a database-access error occurs.
     */
    public void setLogWriter(java.io.PrintWriter out)
            throws SQLException {
        super.setLogWriter(out);
    }

    /**
     * <p>Sets the maximum time in seconds that this data source will wait
     * while attempting to connect to a database.  A value of zero
     * specifies that the timeout is the default system timeout
     * if there is one; otherwise it specifies that there is no timeout.
     * When a data source object is created the login timeout is
     * initially zero.
     *
     * @param seconds the data source login time limit
     * @throws SQLException if a database access error occurs.
     */
    public void setLoginTimeout(int seconds)
            throws SQLException {
        super.setLoginTimeout(seconds);
    }

    /**
     * Gets the maximum time in seconds that this data source can wait
     * while attempting to connect to a database.  A value of zero
     * means that the timeout is the default system timeout
     * if there is one; otherwise it means that there is no timeout.
     * When a data source object is created the login timeout is
     * initially zero.
     *
     * @return the data source login time limit
     * @throws SQLException if a database access error occurs.
     */
    public int getLoginTimeout()
            throws SQLException {
        return super.getLoginTimeout();
    }
}





