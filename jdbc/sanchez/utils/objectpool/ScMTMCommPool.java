package sanchez.utils.objectpool;

import java.util.Enumeration;
import sanchez.base.ScBundle;
import sanchez.base.ScResourceKeys;
import sanchez.ipc.ScMTMCommunication;

/**
  * A Pool of MTMCommunication Objects to a specific host
  
  * @version 1.0
  * @author Pranav Amin  
  * @see ScTCPCommPool
  * @see ObjectPool
  *
  * 
  * Oct. 22 1999 Jiaq
  *     Added closePool to close the pool when the JVM is shut down
  */
public class ScMTMCommPool extends ScTCPCommPool
{      
	private String serverType="SCA$IBS";

	/**
    	  * Constructs an <code>ScMTMCommPool</code> with the specified arguments. 
     	  *
     	  * @param pm_port	Port number to connect to.
	  * @param pm_host	IP address of the host to connect to.
	  *			A Domain Name can also be passed as an alternative to IP Address
	  * @param pm_format	Data Comunication format Default is Binary.
	  */

	public ScMTMCommPool(int pm_port, String pm_host, int pm_format)
	{
		super(pm_port,pm_host,pm_format);		
	}
	/**
    	  * Constructs an <code>ScMTMCommPool</code> with the specified arguments. 
     	  *
     	  * @param pm_port	Port number to connect to.
	  * @param pm_host	IP address of the host to connect to.
	  *			A Domain Name can also be passed as an alternative to IP Address
	  * @param pm_format	Data Comunication format Default is Binary.
	  *@param pm_serverType	Server type default is SCA$IBS.
	  */
	public ScMTMCommPool(int pm_port, String pm_host, int pm_format,String pm_serverType)
	{
		super(pm_port,pm_host,pm_format);
	    	this.serverType = pm_serverType;
	}
	/**
    	  * Constructs an <code>ScMTMCommPool</code> with the specified arguments. 
     	  *
     	  * @param pm_port	Port number to connect to.
	  * @param pm_host	IP address of the host to connect to.
	  *			A Domain Name can also be passed as an alternative to IP Address	 
	  *@param pm_server	TypeServer type default is SCA$IBS.
	  */
	public ScMTMCommPool(int pm_port, String pm_host, String pm_serverType)
	{
		super(pm_port,pm_host);		
		this.serverType = pm_serverType;
	}
	public Object create() throws Exception
	{
		ScMTMCommunication mtm;
		try
		{
			mtm = new ScMTMCommunication(this.port,this.host,this.format,this.serverType);
		}
		catch(Exception e)
		{
			if (e.getMessage() == null) 
			{
				Object[] objs = { e.getMessage() };
				throw new Exception(ScBundle.getMessage(
						ScResourceKeys.MTM_Coonection_Failed, objs));
			} 
			else 
			{
				Object[] objs = { e.getMessage() };
				throw new Exception(ScBundle.getMessage(
						ScResourceKeys.MTM_Coonection_Failed, objs));
			}
		}
		return mtm;
	}

	/**
	 * Closes the TCP/IP channel. 
	 * Null all references to this object, always call super.expire(o)
	 * 
	 * @see ScTCPCommPool#expire(Object)
	 * @see ScTCPCommunication#close()
	 */
	protected void expire( Object o )
	{
		// null all references to this object
		// always call super.expire(o)
	   	super.expire(o);
	}

	/**
	 * If an instance of ScMTMCommunication is passed and the server type 
	 * is either "SCA$IBS" or "SCA$XYZ" checks whether a member Object of 
	 * the Pool is in a valid state.
	 * 
	 * @param o Object 	Instance of ScMTMCommunication, whose validity is to be checked.
	 * @return boolean 	false if either the Object passed is not an instance of 
	 *                 	ScMTMCommunication, or server type is neither "SCA$IBS"
	 *                 	nor SCA$XYZ, or the Object is not in a valid state.
	 *                 	Returns True otherwise.
	 */
	public boolean validate( Object o )
	{          
		if(!(o instanceof ScMTMCommunication))
			return false;
		else    
		{	   
			if(serverType.equals("SCA$IBS") || serverType.equals("SCA$XYZ"))                
				return super.validate();
			else
				return false;
		}    
	}
	
	/**
	 * This method is to close the ScMTMCommunication.
	 * 
	 * @exception Exception If any error occurs 
	 */
	public void closePool()
	throws Exception
	{
	    int num = unlocked.size()+locked.size();
	    if (num==0) return;
	    Enumeration enum1 = unlocked.keys();

		ScMTMCommunication mtm;
		
		while(enum1.hasMoreElements())
		{
			mtm = (ScMTMCommunication)enum1.nextElement();
			mtm.close();
			unlocked.remove(mtm);
		} 
		
	    enum1 = locked.keys();
		while(enum1.hasMoreElements())
		{
			mtm = (ScMTMCommunication)enum1.nextElement();
			mtm.close();
			locked.remove(mtm);
		} 
	}
}