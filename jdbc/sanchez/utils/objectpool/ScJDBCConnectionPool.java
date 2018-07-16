package sanchez.utils.objectpool;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Enumeration;

import sanchez.jdbc.dbaccess.ScDBError;
/**
  * An ScObjectPool for JDBC Connection.
  * This class is a concrete subclass of the ObjectPool.
  * ObjectPool is an abstract class
  
  *@author Pranav Amin
  *@version 1.0 4th Feb 1999
  *@see ScObjectPool  	
  */	
public class ScJDBCConnectionPool extends ScObjectPool
{
	private String dataSourceName, user, passWord, driver;

	public ScJDBCConnectionPool()
	{
		super();
}
	/**
	  * parameters to be passed data source name, userId, password, JDBC Driver name
  	  * @param pm_dataSourceName a String, containing the Data Source Name
	  * @param pm_user a String, containing the user identification.
	  * @param pm_password a String containing the password to login to the database.
	  * @param pm_driver a String conaing the name of the JDBC Driver
	  */	 

	public ScJDBCConnectionPool(String pm_dataSourceName, String pm_user, String pm_passWord, String pm_driver)throws ScCannotCreatePoolException
	{
		super();
		this.dataSourceName = pm_dataSourceName;
		this.user = pm_user;
		this.passWord = pm_passWord;
		this.driver = pm_driver;
		initialize();
	}
	public void closePool()
	{
	    Enumeration enumeration = unlocked.keys();
		while(enumeration.hasMoreElements())
		{
			Object o = enumeration.nextElement();
			unlocked.remove(o);
			expire(o);
			o=null;
		}   
	    
	}
	/**
		  * Creates a JDBC connection object.
		  * Overrides the abstract method of the parent class - ScObjectPool

	  * @exception java.sql.SQLException  sql exception thrown 
	  */

	public Object create() throws SQLException
	{
			Connection conn = DriverManager.getConnection(dataSourceName,user, passWord);
		return conn;
	}
	/**
   	  * Close the connection to expire the Object
	  * Overrides the method of the parent class - ScObjectPool
	
	  */
	public void expire(Object o)
	{
		Connection conn;
		try
		{
			conn = (Connection)o;
			conn.close();
		}
		catch(ClassCastException cce)
		{
			cce.printStackTrace();
		}
		catch(SQLException se)
		{
			se.printStackTrace();
		}
	}
	/** 
	  * Registers the specified JDBC driver with the DriverManager
		  
	  * @see java.sql.DriverManager
	  */

	public void initialize() throws ScCannotCreatePoolException
	{
		if(driver=="")
			return;
		try
		{
			Class.forName(driver).newInstance();
		}
		catch(ClassNotFoundException e)
		{
			throw new ScCannotCreatePoolException("Class not found in the ClassPath\n"+e);
		}
		catch(IllegalAccessException illegal)
		{
			throw new ScCannotCreatePoolException("Access to the class denied. Class is not public\n"+illegal);
		}
		catch(InstantiationException instantiation)
		{
			throw new ScCannotCreatePoolException("Class instantiation failed\n"+instantiation);
		}
	}
	/**
	  * Cleints should use this method to request JDBC Connection.
		  * Make sure you initialize and set the required attributes prior 
	  * calling this method.		

	  * @exception java.sql.SQLException Sql exception thrown
	  * @see ScObjectPool#checkOut()          
	  */
	public Connection requestConnection() throws SQLException
	{
		Connection conn;
		try
		{
			conn = (Connection)super.checkOut();
		}
		catch(Exception e)
		{
			try
			{
			SQLException se = (SQLException)e;
			throw(se);
			}
			catch(ClassCastException cce)
			{
				throw new SQLException();
			}
		}
		return conn;
	}
	/**
	  * Cleints should use this method to return a JDBC Connection.
	  
	  * @see ScObjectPool#checkIn()
	  */
	public void returnConnection(Connection conn)
	{
		super.checkIn(conn);
	}
	/**
	  * @param pm_dataSourceName a String, containing the Data Source Name
	  */
	public void setDataSourceName(String pm_dataSourceName)	
	{
		this.dataSourceName = pm_dataSourceName;
	}
	/**
	  * Once the driver name is set, call initialize() to register the driver. 	
	  * @param pm_driver a String conaing the name of the JDBC Driver
	  * @see #initialize()
	  */ 
	public void setDriver(String pm_driver)throws ScCannotCreatePoolException
	{
		this.driver = pm_driver;
		initialize();
	}
	/**
	  * @param pm_password a String containing the password to login to the database.
	  */

	public void setPassWord(String pm_passWord)
	{
		this.passWord = pm_passWord;
	}
	/**
	  * @param pm_user a String, containing the user identification.
	  */

	public void setUser(String pm_user)
	{
		this.user = pm_user;			
	}
	/**
	  * Performs Validation check on the Object - checks if the conneciton is open
	  * Overrides the method of the parent class - ObjectPool

	  */

	public boolean validate(Object o)
	{
		boolean valid = false;
		try
		{
		Connection conn = (Connection)o;
		//if closed valid = false . If not closed valid = true.
		valid = (!(conn.isClosed()));	
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		return valid;
	}
}