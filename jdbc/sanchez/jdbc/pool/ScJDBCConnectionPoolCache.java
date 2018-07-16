/** 
 *
 *
 * @version     1.0  June 1, 2000
 * @author      Quansheng Jia 
 * @see         javax.sql.DataSource
 */
package sanchez.jdbc.pool;

import java.io.Serializable;
import javax.naming.NamingException;
import javax.naming.Reference;
import javax.naming.Referenceable;
import javax.sql.PooledConnection;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Enumeration;

import sanchez.jdbc.dbaccess.*;


public class ScJDBCConnectionPoolCache extends ScDataSource
    implements Serializable, Referenceable
{
    private ScConnectionPoolDataSource conPoolDataSource;
   
    private ScJdbcPool conCache = null;
    private int activeSize;
    private int cacheSize ;
    private ScConnectionEvenListener conEvenLis;
    
    public ScJDBCConnectionPoolCache (ScConnectionPoolDataSource conPoolDataSource)
       throws SQLException
    {
         super();
         this.conPoolDataSource = conPoolDataSource;
         if (conPoolDataSource !=null) conCache = ScPoolManager.getConnectionPool(conPoolDataSource);
         cacheSize = 0;
         activeSize = 0;
         conEvenLis = new ScConnectionEvenListener(this);
    }
    
    public ScJDBCConnectionPoolCache()
        throws SQLException
    {
           this(null);
    }
    
    public Connection getConnection()
        throws SQLException
    {
        return getConnection(user, password);   
    }
            
    /**
     * Gets the connection object, given the userid and password.
     *
     * @param UserID
     * @param Password
     * @return the connection object or a null on error.
     * 
	 * @history - thoniyilmk - 11/25/2003 - CR 7420
	 * 		conCache is set to null, if the user is not connected. This allows
	 * 		the user to set the userid and password, the second time. It won't
	 * 		pick up the wrong password, that was given the first time.
	 */            
            
    public Connection getConnection(String currentUser, String currentPass)
        throws SQLException
    {
        ScPooledConnection pc = null;
        if (conCache == null) {
            if (user == null || password == null)
                ScDBError.check_error(260);
            conPoolDataSource = new ScConnectionPoolDataSource();
            conPoolDataSource.setUser(user);
            conPoolDataSource.setPassword(password);
            conPoolDataSource.setURL(url);
            checkUser(user, currentPass);
            conCache = ScPoolManager.getConnectionPool(conPoolDataSource);
        }  
        else {
            checkUser(user, currentPass);
        }
        
        try{
            pc = (ScPooledConnection)conCache.checkOut();
        }
        catch(Exception e){
        	conCache = null;
            ScDBError.check_error(e);
        }
        if (pc != null)
        {
            pc.addConnectionEventListener(conEvenLis);
            return pc.getConnection();
        }
        else return null;
    }
    
    public void checkUser(String userName, String pass)
        throws SQLException
    {
        String sUser = null;
        String sPass = null;
        if (conPoolDataSource != null)
        {
            sUser = conPoolDataSource.getUser();
            sPass = conPoolDataSource.getPassword();
        }
        
        if (((userName !=null) && (!userName.equals(sUser))) ||((pass != null) && (!pass.equals(sPass))))
        {
            ScDBError.check_error(-58, userName+"/"+pass);
        }
    }
    
    public void reusePooledConnection(PooledConnection pooledConnection)
        throws SQLException
    {
          pooledConnection.removeConnectionEventListener(conEvenLis);
          conCache.checkIn(pooledConnection);
    }
    
    public void closePooledConnection(PooledConnection pooledConnection)
        throws SQLException
    {
           pooledConnection.removeConnectionEventListener(conEvenLis);
           conCache.remove(pooledConnection);
           pooledConnection = null;
    }

    public int getActiveSize()
    {
        if (conCache == null) return 0;
        return conCache.getLockedSize();
    }
    
    public int getUnActiveSize()
    {
        if (conCache == null) return 0;
        return conCache.getUnLockedSize();
    }
    
	public void setPoolSize(int size)
	{
		conCache.setMaxmumSize(size);
	}

	public int getPoolSize()
	{
		return conCache.maximumSize();
	}

    public void setConCache(ScJdbcPool conCache)
    {
        this.conCache = conCache;
    }
    
    public ScJdbcPool getConCache()
    {
        return conCache;
    }
        
    
    public Reference getReference()
        throws NamingException
    {
        Reference reference = new Reference(getClass().getName(), "sanchez.jdbc.pool.ScObjectFactory", null);
        super.addRefProperties(reference);
        /*
        if(conCache != null)
            reference.add(new StringRefAddr("connectionCache",ScSerialUtils.ScGetObjectToString(conCache)));
        */
        return reference;
    }
    
     private void closeConnectionOneByOne(PooledConnection pooledconnection)
        throws SQLException
    {
        pooledconnection.close();
        conCache.remove(pooledconnection);
        pooledconnection = null;
    }
    
    public void close()
        throws SQLException
    {
       ScPooledConnection pCon;
       
       //retrive pooledconnection from locked table to unlocked table and remove listener
       
	   for(Enumeration enumeration = conCache.getActiveCache().keys(); enumeration.hasMoreElements(); reusePooledConnection(pCon))
       {
           pCon = (ScPooledConnection)enumeration.nextElement();
       }
	
	   Enumeration enum = conCache.getUnActiveCache().keys();
	   
	   while(enum.hasMoreElements())
	   {
			pCon = (ScPooledConnection)enum.nextElement();
		    closeConnectionOneByOne(pCon);
	   }
	
	   conCache = null;
    }
    
    //added for JDBC3.0
    //do nothing for this driver 
    public void setInitialPoolSize(int size)
    {
    }
    
    public void setMinPoolSize(int size)
    {
    	conCache.setMinimumSize(size);
    }
    
    public void setMaxPoolSize(int size)
    {
    	conCache.setMaxmumSize(size);
    }
     
    public void setMaxIdleTime(int idletime)
    {
    	conCache.setExpirationTime(idletime);
    }
    
    //do nothing for this driver
    public void setPropertyCycle(int cycle)
    {
    	
    }
}