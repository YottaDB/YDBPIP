package sanchez.jdbc.pool;

import java.util.Hashtable;
import java.io.Serializable;
import java.sql.SQLException;

public class ScPoolManager implements Serializable
{
    
    static Hashtable poolTable = new Hashtable(6);

    /**
     * Gets the ScJdbcPool object, given the ScConnectionPoolDataSource object
     *
     * @param ScConnectionPoolDataSource object
     * @return the ScJdbcPool object from the hashtable, if one exists or a new one.
     * 
	 * @history - thoniyilmk - 11/25/2003 - CR 7420
	 * 		Added the password to the key. It was only looking at the url and userid.
	 * 		So, if the user supplied a wrong password the first time, that was not
	 * 		considered as the key was only the url and userid
	 */
    public static ScJdbcPool getConnectionPool(ScConnectionPoolDataSource ds)
            throws SQLException
    {
    	StringBuffer sbuf = new StringBuffer();
    	sbuf = sbuf.append(ds.getURL()).append("|").append(ds.getUser()).append("|").append(ds.getPassword());
    	String key = sbuf.toString();
        ScJdbcPool jp =  lookupConnectionPool(key);
        if (jp == null) {
			jp = new ScJdbcPool(ds);
            poolTable.put(key, jp);
        }
        return jp; 
        
    }

    public static ScJdbcPool lookupConnectionPool(String key)
    {
        return (ScJdbcPool)poolTable.get(key);
        
    }
}