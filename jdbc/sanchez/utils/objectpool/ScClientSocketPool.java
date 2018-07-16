package sanchez.utils.objectpool;

import java.io.IOException;
import java.net.InetAddress;
import java.net.Socket;

import sanchez.jdbc.dbaccess.ScDBError;
import sanchez.base.ScBundle;
import sanchez.base.ScResourceKeys;
/**
  * An ScObjectPool for Socket Connection.
  * This class is a concrete subclass of the ObjectPool.
  * ObjectPool is an abstract class
  
  *@author Pranav Amin
  *@version 1.0 4th Feb 1999
  *@see ObjectPool  	
  */	
public class ScClientSocketPool extends ScObjectPool
{
	private int port;
	private String hostName;
	private InetAddress address;
	
   /**
    * Default constructor.
    */
	public ScClientSocketPool()
	{
		super();
	}
	/**
	 * Parameters to be passed the host name and the port number
	 * 
	 * @param pm_hostName
	 *            a String denoting the name of the host.
	 * @param pm_port,
	 *            an int value representing the port number &nbc of the host,
	 *            where connection is requested.
	 */
	public ScClientSocketPool(String pm_hostName, int pm_port)
	{
		super();
		this.hostName = pm_hostName;
		this.port = pm_port;
	}

	/**
	 * Parameters to be passed the host name and the port number
	 * 
	 * @param pm_address
	 *            an InetAddress object denoting the host.
	 * @param pm_port,
	 *            an int value representing the port number &nbc of the host,
	 *            where connection is requested.
	 */
	public ScClientSocketPool(InetAddress pm_address, int pm_port)
	{
		super();
		this.address = pm_address;
		this.port = pm_port;
	}

	/**
	 * Clients should use this method to return a Socket.
	 * 
	 * @param socket 
	 * @see ScObjectPool#checkIn()
	 */
	public void checkInSocket(Socket socket)
	{
		super.checkIn(socket);
	}
	/**
	 * Cleints should use this method to request a Socket. Make sure you
	 * initialize and set the required attributes prior calling this method.
	 * 
	 * @exception java.io.IOException
	 *                Sql exception thrown - if an error occurs.
	 * @see ScObjectPool#checkOut()
	 */
	public Socket checkOutSocket() throws IOException
	{
		Socket socket;
		try
		{
			socket = (Socket)super.checkOut();
		}
		catch(Exception e)
		{
			try
			{
			IOException io = (IOException)e;
			throw(io);
			}
			catch(ClassCastException cce)
			{
				throw new IOException();
			}
		}
		return socket;
	}

	/**
	 * Creates a Socket connection object. Overrides the abstract method of the
	 * parent class - ScObjectPool
	 * 
	 * @exception java.io.IOException
	 *                IOException thrown
	 */
	public Object create() throws IOException
	{
		Socket socket;
			if(address==null)
		{
			if(hostName.length()>0 && port >0)
				socket = new Socket(hostName,port);
			else
				throw new IOException(ScBundle
						.getMessage(ScResourceKeys.Illegal_Host_Name));
		}
		else 
		{
		if(port > 0)
			socket = new Socket(address,port);
		else
				throw new IOException(ScBundle
						.getMessage(ScResourceKeys.Illegal_Port_Number));
		}
		return socket;
	}
	/**
	 * Close the Socket to expire the Object Overrides the method of the parent
	 * class - ScObjectPool
	 * 
	 * @param o - Socket as Object.
	 */
	public void expire(Object o)
	{
		Socket socket;
		try
		{
			socket = (Socket)o;
			socket.close();
		}
		catch(ClassCastException cce)
		{
			cce.printStackTrace();
		}
		catch(IOException io)
		{
			io.printStackTrace();
		}
	}
	/**
	  * @param pm_hostName a String, containing the name of the host.
	/**
	 * To set the Host Name.
	 * @param pm_hostName - Host Name as String.
	 *  a String, containing the name of the host.
	 */
	public void setHostName(String pm_hostName)
	{
		this.hostName = pm_hostName;			
	}
	/**
	 * To set InetAddress.
	 * @param pm_address - An InetAddress.
	 * 
	 */
	public void setInetAddress(InetAddress pm_address)	
	{
		this.address = pm_address;
	}
	/**
	 * To set port.
	 * @param pm_port - An int value, representing the port of the host where the
	 *  connection is requested.
	 */

	public void setPort(int pm_port)
	{
		this.port = pm_port;
	}

	/**
	 * Performs Validation check on the Object - checks if the conneciton is
	 * open Overrides the method of the parent class - ObjectPool
	 * 
	 * @param o - Object to validate.
	 */
	public boolean validate(Object o)
	{		
		return true;
	}
}