package sanchez.jdbc.pool;

/**
 * <p>A PooledConnection object is a connection object that provides
 * hooks for connection pool management.  A PooledConnection object
 * represents a physical connection to a data source.
 *
 * @version     1.0  June 1, 2000
 * @author      Quansheng Jia 
 * @see         javax.sql.PooledConnection
 */

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Hashtable;
import java.util.Enumeration;
import javax.sql.ConnectionEvent;
import javax.sql.ConnectionEventListener;
import javax.sql.PooledConnection;
import sanchez.base.ScBundle;
import sanchez.base.ScResourceKeys;
import sanchez.jdbc.dbaccess.ScDBError;
import sanchez.jdbc.driver.ScConnection;
import sanchez.jdbc.driver.ScDriver;

public class ScPooledConnection
    implements PooledConnection
{
  protected Connection connLogicalHandle;
  protected Connection physicalConn;
  private Hashtable eventListeners;
  private SQLException sqlException;
  private boolean autoCommitFlag;
  
  /**
   * Constructs a ScPooledConnection Object using database url.
   * @param url
   * @throws SQLException
   */
  public ScPooledConnection(String url)
        throws SQLException
    {
        DriverManager.registerDriver(new ScDriver());
        Connection connection = DriverManager.getConnection(url);
        ini(connection);
    }
  
  /**
   * Constructs a ScPooledConnection Object using database url,login username and login password
   * @param url
   * @param userName
   * @param password
   * @throws SQLException
   */
    public ScPooledConnection(String url, String userName, String password)
        throws SQLException
    {
        DriverManager.registerDriver(new ScDriver());
        Connection connection = DriverManager.getConnection(url, userName, password);
        ini(connection);
    }
  
    /**
    * Constructs a ScPooledConnection Object using connection object
    * @param connection
    */
    public ScPooledConnection(Connection connection)
    {
        ini(connection);
    }
   
    /**
    * Constructs a ScPooledConnection Object using connection object and autocommit flag
    * @param connection
    * @param flag
    */
    public ScPooledConnection(Connection connection, boolean flag)
    {
        this(connection);
        autoCommitFlag = flag;
    }
  
    /**
    * Initializating the physical connection, autocommitflag 
    * 
    * @param connection
    */
    private void ini(Connection connection)
    {
        autoCommitFlag = true;
        connLogicalHandle = null;
        physicalConn = connection;
        sqlException = null;
        eventListeners = new Hashtable(10);
    }
 
    /**
    * <p>Create an object handle for this physical connection.  The object
    * returned is a temporary handle used by application code to refer to
    * a physical connection that is being pooled.
    *
    * @return  a Connection object
    * @exception SQLException if a database-access error occurs.
    */
    public  Connection getConnection() throws SQLException
    {
	    if(physicalConn == null)
	    {
	       activeListener(2);
	       ScDBError.check_error(2);
	       return null;
	    }
	    
	    try {
	        if(connLogicalHandle != null)
	        {
	           ((ScConnection)connLogicalHandle).setPhysicalStatus(false);
	           connLogicalHandle.close();
	        }
	        
	        connLogicalHandle = new ScConnection(this,(ScConnection)physicalConn, autoCommitFlag);
	    }
	    catch(SQLException ex)
	    {
	         sqlException = ex;
	         activeListener(2);
	         ScDBError.check_error(2);
	         return null;
	    }
	    return connLogicalHandle;
    }
  
    /**
    * <p>Close the physical connection.
    *
    * @exception SQLException if a database-access error occurs.
    */
    public void close() throws SQLException
    {
    	physicalConn.close();
    	physicalConn = null;
    	activeListener(1);
    }
  
    private void activeListener(int i)
    {
        if(eventListeners == null)
            return;
        Enumeration en = eventListeners.keys();
        ConnectionEvent connectionEvent = new ConnectionEvent(this,sqlException);
        while(en.hasMoreElements()) 
        {
            ConnectionEventListener connEventListener = (ConnectionEventListener)en.nextElement();
        
            if(i == 1)
                connEventListener.connectionClosed(connectionEvent);
            else if(i == 2)
                connEventListener.connectionErrorOccurred(connectionEvent);
        }
    }
    
    /** 
     * Checking logical connection
     *
     */
    public synchronized void checkInlogicalConnection()
    {
        activeListener(1);
    }  
  
    /**
     * <P> Add an event listener.
     * @param ConnectionEventListener
     */
    public void addConnectionEventListener(ConnectionEventListener listener)
    {
    	if(eventListeners == null)
    		sqlException = new SQLException(ScBundle.getMessage(ScResourceKeys.Listener_Hashtable_Null));
    	else
            eventListeners.put(listener, listener);
    }

    /**
     * <P> Remove an event listener.
     *  @param ConnectionEventListener
     */
    public void removeConnectionEventListener(ConnectionEventListener listener)
    {
    	if(eventListeners == null)
    		sqlException = new SQLException(ScBundle.getMessage(ScResourceKeys.Listener_Hashtable_Null));
    	else
            eventListeners.remove(listener);
    }
} 





