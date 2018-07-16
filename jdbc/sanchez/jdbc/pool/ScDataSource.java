package sanchez.jdbc.pool;

/** 
 * <p>A DataSource object is a factory for Connection objects.  An
 * object that implements the DataSource interface will typically be
 * registered with a JNDI service provider.  A JDBC driver that is 
 * accessed via the DataSource API does not automatically register 
 * itself with the DriverManager.  
 *
 * @version     1.0  June 1, 2000
 * @author      Quansheng Jia 
 * @see         javax.sql.DataSource
 */

import java.sql.Connection;
import java.sql.SQLException;
import javax.naming.NamingException;
import javax.naming.RefAddr;
import javax.naming.Reference;
import javax.naming.Referenceable;
import javax.naming.StringRefAddr;
import javax.sql.DataSource;
import java.io.Serializable;
import java.io.PrintWriter;
import java.sql.DriverManager;

import sanchez.jdbc.dbaccess.ScDBError;
import sanchez.jdbc.driver.ScDriver;


public class ScDataSource
    implements DataSource, Serializable, Referenceable
{
  /**
   * Empty ScDatasource constructor
   * @throws SQLException
   */
  public ScDataSource()
    throws SQLException
    {
        locale = "US:EN";
        dateFormat = null;
        timeFormat = null;
        rowPrefetch = 30;
        signOnType = 0;
        url = null;
        timeOut = 0;
        if (!isReg)
        {
           DriverManager.registerDriver(new ScDriver());
           isReg = true; 
        }
        dataSourceName = "ScDataSource";
        urlExplict = false;
        serverName = null;
        portNumber = 0;
        databaseName = null;
        description = null;
        networkProtocol = null;
        password = null;
        user = null;
        serverName = null;
    }

  /**
   * <p>Attempt to establish a database connection.
   *
   * @return  a Connection to the database
   * @exception SQLException if a database-access error occurs.
   */
  public Connection getConnection() 
        throws SQLException
   {
        return getConnection(user, password);
   }
  /**
   * <p>Attempt to establish a database connection.
   *
   * @param user the database user on whose behalf the Connection is 
   *  being made
   * @param password the user's password
   * @return  a Connection to the database
   * @exception SQLException if a database-access error occurs.
   */
  public Connection getConnection(String username, String password) 
    throws SQLException
    {
        trace("URL = "+url);
        parseURL();
        return DriverManager.getConnection(url, username, password); 
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
   * with the java.sql.Drivermanager class.  When a DataSource object is
   * created the log writer is initially null, in other words, logging
   * is disabled.
   *
   * @return the log writer for this data source, null if disabled
   * @exception SQLException if a database-access error occurs.  
   */
  public java.io.PrintWriter getLogWriter() 
        throws SQLException
  {
        return pw;
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
   * with the java.sql.Drivermanager class. When a DataSource object is
   * created the log writer is initially null, in other words, logging
   * is disabled.
   *
   * @param out the new log writer; to disable, set to null
   * @exception SQLException if a database-access error occurs.  
   */
  public void setLogWriter(java.io.PrintWriter out) 
        throws SQLException
  {
        pw = out;
        //ScLog.setLogWriter(out);
  }
  /**
   * <p>Sets the maximum time in seconds that this data source will wait
   * while attempting to connect to a database.  A value of zero
   * specifies that the timeout is the default system timeout 
   * if there is one; otherwise it specifies that there is no timeout.
   * When a DataSource object is created the login timeout is
   * initially zero.
   *
   * @param seconds the data source login time limit
   * @exception SQLException if a database access error occurs.
   */
  public void setLoginTimeout(int seconds) 
        throws SQLException
  {
        timeOut = seconds;
    
  }
  /**
   * Gets the maximum time in seconds that this data source can wait
   * while attempting to connect to a database.  A value of zero
   * means that the timeout is the default system timeout 
   * if there is one; otherwise it means that there is no timeout.
   * When a DataSource object is created the login timeout is
   * initially zero.
   *
   * @return the data source login time limit
   * @exception SQLException if a database access error occurs.
   */
  public int getLoginTimeout() 
        throws SQLException
  {
        return timeOut;
  }

  /**
   * Retrieves the reference of the ScObectFactory
   * @return Reference
   * @exception NamingException
   */
  public Reference getReference()
        throws NamingException
  {
        Reference ref = new Reference(this.getClass().getName(),
            "sanchez.jdbc.pool.ScObjectFactory",
            null);
        addRefProperties(ref);    
        return ref;
    
    }
  /**
   * Adding elements to the Reference properties file
   * @param ref
   */
    
    protected void addRefProperties(Reference ref)
    {
        ref.add( new StringRefAddr("serverName", serverName));
        ref.add( new StringRefAddr("portNumber", Integer.toString(portNumber)));
        ref.add( new StringRefAddr("databaseName", databaseName));
        ref.add( new StringRefAddr("user", user));
        ref.add( new StringRefAddr("password", password));
        ref.add( new StringRefAddr("url", url));
        ref.add( new StringRefAddr("networkProtocol", networkProtocol));
        ref.add( new StringRefAddr("description", description));
        ref.add( new StringRefAddr("signOnType", Integer.toString(signOnType)));
   
    }
    /**
     * Set the ServerName
     * @param serverName
     * @throws SQLException
     */
    public void setServerName(String serverName) 
        throws SQLException
    {
        this.serverName = serverName;
        
    }
  /**
   * Retrieves the server name
   * @return serverName
   * @throws SQLException
   */
    public String getServerName() 
        throws SQLException
    {
        return serverName;
    }
  /**
   * Set the Port Number
   * @param portNumber
   * @throws SQLException
   */
    public void setPortNumber(int portNumber) 
        throws SQLException
    {
        this.portNumber = portNumber;
        
    }
   /**
    * Retrieve the port number
    * @return portNumber
    * @throws SQLException
    */
    public int getPortNumber() 
        throws SQLException
    {
        return portNumber;
    }
    /**
     * Set the prefetch size for a row
     * @param rowPrefetch
     * @throws SQLException
     */
    public void setRowPrefetch(int rowPrefetch) 
        throws SQLException
    {
        this.rowPrefetch = rowPrefetch;
    
    }
  /**
   * Retrieves the prefetch size for a row
   * @return rowPrefetch
   * @throws SQLException
   */
    public int getRowPrefetch() 
        throws SQLException
    {
        return rowPrefetch;
    }
    
    /**
     * Set the sign on type 
     * @param signOnType
     * @throws SQLException
     */
    
    public void setSignOnType(int signOnType) 
        throws SQLException
    {
        this.signOnType = signOnType;
        
    }
  /**
   * Get the signon type
   * @return
   * @throws SQLException
   */
    public int getSignOnType() 
        throws SQLException
    {
        return signOnType;
    }
   /**
    * Set the database name
    * @param databaseName
    * @throws SQLException
    */
    public void setDatabaseName(String databaseName) 
        throws SQLException
    {
        this.databaseName = databaseName;
        
    }
  /**
   * Retrieves the database name
   * @return database name
   * @throws SQLException
   */
    public String getDatabaseName() 
        throws SQLException
    {
        return databaseName;
    }
    
    /**
     * Sets the database url
     * @param url
     * @throws SQLException
     */
    public void setURL(String url) 
        throws SQLException
    {
        this.url = url;
        if (url != null)
            urlExplict = true;
    
    }
  /**
   * Retrieves the database URL
   * @return database URL
   * @throws SQLException
   */
    public String getURL() 
        throws SQLException
    {
        return url;
    }
   /**
    * Sets the login username
    * @param userName
    * @throws SQLException
    */
    public void setUser(String userName) 
        throws SQLException
    {
        this.user = userName;
    
    }
  /**
   * Retrives the login user name
   * @return login username 
   * @throws SQLException
   */
    public String getUser() 
        throws SQLException
    {
        return user;
    }
    /**
     * Sets the login password
     * @param password
     * @throws SQLException
     */
    public void setPassword(String password) 
        throws SQLException
    {
        this.password = password;
    
    }
   /**
    * Retrieves the login password
    * @return login password
    * @throws SQLException
    */
    public String getPassword() 
        throws SQLException
    {
        return password;
    }
    /**
     * Sets database description
     * @param description
     * @throws SQLException
     */
    public void setDescription(String description) 
        throws SQLException
    {
        this.description = description;
    
    }
   /**
    * Retrieves the database description
    * @return database description
    * @throws SQLException
    */
    public String getDescription() 
        throws SQLException
    {
        return description;
    }
    /**
     * Sets the network protocol
     * @param networkProtocol
     * @throws SQLException
     */
     public void setNetworkProtocol(String networkProtocol) 
        throws SQLException
    {
        this.networkProtocol = networkProtocol;
    
    }
  /**
   * Retrieves the network protocol
   * @return network protocol
   * @throws SQLException
   */
    public String getNetworkProtocol() 
        throws SQLException
    {
        return networkProtocol;
    }
    /**
     * Parses the database URL to check for null values in serverName,portNumber,databaseName and accordinly throws error
     * @throws SQLException
     */
    private void parseURL()
        throws SQLException
    {
       //String url = "protocol=jdbc:sanchez/database=140.140.1.1:18610:SCA$IBS/User=4609/passWord=xxx/signOnType=1";   
       if (urlExplict)
        return;
       
       if (serverName == null)
    	   ScDBError.check_error(266);
       if (portNumber == 0) 
    	   ScDBError.check_error(267);
       if (databaseName == null)
    	   ScDBError.check_error(268);
       
       StringBuffer sb = new StringBuffer();
       sb.append("protocol=jdbc:sanchez/").append("database=").append(serverName).append(":");
       sb.append(portNumber).append(":").append(databaseName);
       
       if (networkProtocol!= null) sb.append("/networkProtocol=").append(networkProtocol);
       if (signOnType !=0) sb.append("/signOnType=").append(signOnType);
       
       url = sb.toString();
    }
    /**
     * Tracking the datasource errors
     * @param log
     */
    protected void trace (String log)
    {
        //if (pw != null)
            //ScLog.print(null, 0xfffffff, 1, 32, log);
    }
    
    protected String databaseName;
    protected String dataSourceName;
    protected String description;
    protected String networkProtocol; //trnsType
    protected String password;
    protected int portNumber;
    protected String user;
    protected String serverName;
    
    protected PrintWriter pw;
    
    protected String url;
    
    //optional
    protected int timeOut;
    protected String locale;
    protected String dateFormat;
    protected String timeFormat;
    protected int rowPrefetch;
    protected int signOnType;
    
    boolean urlExplict;
    
    private static boolean isReg = false;    
} 





