package sanchez.jdbc.pool;

import java.sql.SQLException;
import java.util.Enumeration;
import java.util.Hashtable;

import sanchez.utils.objectpool.ScObjectPool;

public class ScJdbcPool extends ScObjectPool {
    private ScConnectionPoolDataSource conPoolDataSource;

    public ScJdbcPool(ScConnectionPoolDataSource cpds) {
        super();
        minimumSize = 0;
        conPoolDataSource = cpds;
    }


    public ScJdbcPool(String userName, String password, String url)
            throws SQLException {
        super();
        conPoolDataSource = new ScConnectionPoolDataSource();
        conPoolDataSource.setUser(userName);
        conPoolDataSource.setPassword(password);
        conPoolDataSource.setURL(url);
    }


    public void closePool()
            throws Exception {

        int num = unlocked.size() + locked.size();
        if (num == 0) return;
        Enumeration enum1 = unlocked.keys();
        Object o;

        while (enum1.hasMoreElements()) {
            o = enum1.nextElement();
            Long time = (Long) unlocked.get(o);
            unlocked.remove(o);
            expire(o);
            o = null;
        }

        num = locked.size();

        if (num == 0) return;
        java.lang.Thread.sleep(1000);
        enum1 = locked.keys();

        while (enum1.hasMoreElements()) {
            o = enum1.nextElement();
            Long time = (Long) locked.get(o);
            locked.remove(o);
            expire(o);
            o = null;
        }
    }

    public Object create() throws SQLException {
        return conPoolDataSource.getPooledConnection();
    }

    /**
     * Close the connection to expire the Object
     * Overrides the method of the parent class - ScObjectPool
     */
    public void expire(Object o) {
        ScPooledConnection conn;
        try {
            conn = (ScPooledConnection) o;
            conn.close();
        } catch (ClassCastException cce) {
            cce.printStackTrace();
        } catch (SQLException se) {
            se.printStackTrace();
        }
    }

    public boolean validate(Object o) {
        return true;
    }

    public synchronized void remove(Object o) {
        locked.remove(o);
        unlocked.remove(o);
    }

    public int getLockedSize() {
        return locked.size();
    }

    public int getUnLockedSize() {
        return unlocked.size();
    }

    public Hashtable getActiveCache() {
        return locked;
    }

    public Hashtable getUnActiveCache() {
        return unlocked;
    }
}