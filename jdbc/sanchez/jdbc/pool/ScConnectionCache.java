/**
 * @version 1.0  June 1, 2000
 * @author Quansheng Jia
 * @see javax.sql.DataSource
 */
package sanchez.jdbc.pool;

import java.io.Serializable;
import java.sql.Connection;
import java.sql.SQLException;
import javax.naming.Referenceable;
import javax.sql.PooledConnection;

import sanchez.jdbc.dbaccess.ScDBError;


public class ScConnectionCache extends ScDataSource
        implements Serializable, Referenceable {
    private ScConnectionPoolDataSource conPoolDataSource;
    private static int defaultMinLimit = 0;
    private static int defaultMaxLimit = 10;
    private int minLimit;
    private int maxLimit;
    private ScJdbcPool conCache = null;
    private int activeSize;
    private int cacheSize;
    private ScConnectionEvenListener conEvenLis;

    public ScConnectionCache(ScConnectionPoolDataSource conPoolDataSource)
            throws SQLException {
        this.conPoolDataSource = conPoolDataSource;
        //conCache = new Stack();
        conCache = new ScJdbcPool(conPoolDataSource);
        cacheSize = 0;
        activeSize = 0;
        conEvenLis = new ScConnectionEvenListener(this);
    }

    public ScConnectionCache()
            throws SQLException {
        this(null);
    }

    public Connection getConnection()
            throws SQLException {
        return getConnection(user, password);
    }

    public Connection getConnection(String currentUser, String currentPass)
            throws SQLException {
        ScPooledConnection pc = null;
        if (conCache == null) {
            if (user == null || password == null)
                ScDBError.check_error(260);
            conPoolDataSource = new ScConnectionPoolDataSource();
            conPoolDataSource.setUser(user);
            conPoolDataSource.setPassword(password);
            conPoolDataSource.setURL(url);
            checkUser(user, currentPass);
            conCache = new ScJdbcPool(conPoolDataSource);
        } else {
            checkUser(user, currentPass);
        }

        try {
            pc = (ScPooledConnection) conCache.checkOut();
        } catch (Exception e) {
            ScDBError.check_error(e);
        }
        if (pc != null) {
            pc.addConnectionEventListener(conEvenLis);
            return pc.getConnection();
        } else return null;
    }

    public void checkUser(String userName, String pass)
            throws SQLException {
        String sUser = null;
        String sPass = null;
        if (conPoolDataSource != null) {
            sUser = conPoolDataSource.getUser();
            sPass = conPoolDataSource.getPassword();
        }

        if (((userName != null) && (!userName.equals(sUser))) || ((pass != null) && (!pass.equals(sPass)))) {
            ScDBError.check_error(-58, userName + "/" + pass);
        }
    }

    public void reusePooledConnection(PooledConnection pooledConnection)
            throws SQLException {
        pooledConnection.removeConnectionEventListener(conEvenLis);
        conCache.checkIn(pooledConnection);
    }

    public void closePooledConnection(PooledConnection pooledConnection)
            throws SQLException {
        pooledConnection.removeConnectionEventListener(conEvenLis);
        conCache.remove(pooledConnection);
        pooledConnection = null;
    }

    public int getActiveSize() {
        return conCache.getLockedSize();
    }

    public int getUnActiveSize() {
        return conCache.getUnLockedSize();
    }

}