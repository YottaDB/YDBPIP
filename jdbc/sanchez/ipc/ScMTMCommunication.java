/**
  * Handles MTM Communication between clients and hosts.

  * @author	Pranav Amin
  * @version	1.0 24th May 1999.
  * @see sanchez.ipc.ScMQCommunication
  */

package sanchez.ipc;

/* Revision History:
 * May 10 1999 Jiaq
 * Modified sendMessage method, used new utility to convert byte[]
 * to string
 */
import sanchez.base.ScException;
import sanchez.base.ScBundle;
import sanchez.base.ScResourceKeys;
import sanchez.him_pa.utils.ScUtils;;

public class ScMTMCommunication extends ScTCPCommunication
{
	private String serverType="SCA$IBS";
	private ScUtils myutil = new ScUtils();
        
        private int MAX_WORD_VAL=0XFFFF; 
        private int MAX_3BYTE_VAL = 0XFFFFFF;
    
   
	/**
	  * Class constructor with pm_port, pm_host, pm_format, pm_serverType parameters
	  * @param pm_port Port number.
	  * @param pm_host IP Address of the host.
	  * @param pm_format Communication format Binary/ASCII/Unicode
	  * @param pm_serverType Server type, default is SCA$IBS.
	  * @exception throws java.lang.Exception
	  */
	public ScMTMCommunication(int pm_port, String pm_host, int pm_format, String pm_serverType)throws Exception
	{		
		super(pm_port, pm_host, pm_format);
		this.serverType = pm_serverType;
        
	}
	
	/**
	  * Class constructor with pm_port, pm_host, pm_serverType parameters
	  * @param pm_port Port number.
	  * @param pm_host IP Address of the host.
	  * @param pm_serverType Server type, default is SCA$IBS.
	  * @exception throws java.lang.Exception
	  */
	public ScMTMCommunication(int pm_port, String pm_host, String pm_serverType)throws Exception
	{		
		super(pm_port, pm_host);
		this.serverType = pm_serverType;
	}
	
	/**
	  * Class constructor with pm_port, pm_host parameters 
	  * @param pm_port Port number.
	  * @param pm_host IP Address of the host.
	  * @exception throws java.lang.Exception
	  */
	public ScMTMCommunication(int pm_port, String pm_host)throws Exception
	{
		super(pm_port, pm_host);
	}

	/**
	  * Class constructor 
	  * @exception throws java.lang.Exception
	  */
	public ScMTMCommunication()throws Exception
	{
	       super();
	}
	
	 /**
  	  * This method opens a channel (connection) for communication.
  	  * If unsuccessful it will throw a java.lang.Exception.
      * @param pm_message The message that needs to be sent.
      * @exception throws java.lang.Exception
	  */
	public void sendMessage(StringBuffer pm_message)throws Exception
	{
        
        int ii=0;		
        int iStringLen = serverType.length();
                
	// wrap headers...
        byte abbuff[] = new byte[40];
        
        //take care message size larger than 64k
        long sourceSize = iStringLen + pm_message.length();
        int iHeadSize = 0;
        
        if (sourceSize+3<MAX_WORD_VAL)
        {
            for (ii=0; ii<iStringLen; ii++)
            {
                abbuff[2+ii] = (byte)serverType.charAt(ii);
            }
            ii += 2;
            abbuff[ii++] = (byte)28;

            iHeadSize = ii;
            ii += pm_message.length();

            abbuff[0] = (byte)(ii/256); 
            abbuff[1] = (byte)(ii%256);
        }
        else{
            abbuff[0] = (byte)0; 
            abbuff[1] = (byte)0;
            
            int bytesSize;
            sourceSize = sourceSize+1;
            
            if(sourceSize+3<=MAX_3BYTE_VAL)
            {
                bytesSize=3;
            }
            else bytesSize=4;
            
            //[2] n(bytes in length)
            abbuff[2]=(byte)bytesSize;
            
            sourceSize = sourceSize+bytesSize+3;
            int i=0;
            //[3]~[3+n]   message length
            for (i = 2+bytesSize; i>2; i--)
            {
                abbuff[i]=(byte)(sourceSize%256);
               
                sourceSize/=256;
            }
           
            //service type
            for (ii=0; ii<iStringLen; ii++)
            {
                abbuff[3+bytesSize+ii] = (byte)serverType.charAt(ii);
            }
            ii += 3+bytesSize;
            abbuff[ii++] = (byte)28;
            iHeadSize = ii;
        }
        
        pm_message.insert(0,ScUtils.byteToString(abbuff,iHeadSize)); 

        for (int iii=0; iii<20;iii++)
        {
        	byte b = (byte)pm_message.toString().charAt(iii);
        }
        
        try
        {
    		super.sendMessage(pm_message);
                pm_message = null;
        }
        catch(Exception e)
        {
            handleComm();
            throw e;
        }
	}
	/**
  	  * This method opens a channel (connection) for communication.
  	  * If unsuccessful it will throw a java.lang.Exception.
	  * @return StringBuffer The message received.
      * @exception throws java.lang.Exception
	  * 
	  */
	public StringBuffer receiveMessage() throws Exception
	{
		// unwrap headers...
            
		StringBuffer sbuffer  = new StringBuffer();
        try
        {
        	sbuffer = super.receiveMessage(2);
		}
		catch(Exception e)
        {
            handleComm();
            throw e;
        }
        
        int ii=0;
        int jj=0;
        int kk=0;
        
    	if ((sbuffer == null) || (sbuffer.toString().length() == 0))
   		{
    		throw new Exception(ScBundle.getMessage(ScResourceKeys.MTM_NULL_DATA));
   		}
    	try 
    	{
	        jj = ScUtils.unsigned((byte)(sbuffer.toString().charAt(0)));
	        kk = ScUtils.unsigned((byte)(sbuffer.toString().charAt(1)));
	        
	        ii = ((jj*256)+kk) - 2;
	        if(ii>0)
	        {
	            try{
	            	sbuffer = super.receiveMessage(ii);
	            }
	            catch(Exception e)
	            {
	                handleComm();
	                throw e;
	            }
	        }
	        else
	        {
	            try{
	                sbuffer = super.receiveMessage(1);
	            }
	            catch(Exception e)
	            {
	                handleComm();
	                throw e;
	            }
	            
	            int byteInLen = ScUtils.unsigned((byte)sbuffer.toString().charAt(0));
	            try{
	             
	            	sbuffer = super.receiveMessage(byteInLen);
	            }
	            catch(Exception e)
	            {
	                handleComm();
	                throw e;
	            }
	            
	            int x2=0;
	            
	            for (int i=0; i<byteInLen; i++)
	            {
	              
	              x2 *= 256;
	              x2 += ScUtils.unsigned((byte)sbuffer.toString().charAt(i));
	            }
	            x2 = x2-3-byteInLen;
	            try{
	                 sbuffer = super.receiveMessage(x2);
	                 
	            }
	            catch(Exception e)
	            {
	                handleComm();
	                throw e;
	            }
	        }
	    	if ((sbuffer != null) || (sbuffer.toString().length() > 0))
	   		{
	   			if (sbuffer.toString().charAt(0) != 48)
	   			{
	   				throw new Exception(ScBundle.getMessage(ScResourceKeys.Invalid_Message_Format));
	   			}
	   		}
	   		else
	   		{
	   			throw new Exception(ScBundle.getMessage(ScResourceKeys.MTM_NULL_DATA));
	   		}
	
	        StringBuffer mybuff = new StringBuffer(sbuffer.toString().substring(1,sbuffer.length()));
	        return mybuff;
    	}
        catch(Exception e)
        {
            handleComm();
            throw e;
        }
	}
	
	/**
	  * This method opens a channel (connection) for communication.
  	  * If unsuccessful it will throw a java.lang.Exception.
      * @param pm_message The message that needs to be sent.
      * @return StringBuffer The message received.
      * @exception throws java.lang.Exception
	  */
	public StringBuffer exchangeMessage(StringBuffer pm_message)throws Exception
	{ 
	    StringBuffer sbuffer = new StringBuffer();
	    String sMsg = pm_message.toString();
	    
	    try
	    {
	    	this.sendMessage(pm_message);
    		sbuffer = this.receiveMessage();
        }
    	catch(Exception e)
        {
            if (e.getMessage()==null || e.getMessage().length()<1)
            {
            	throw new java.io.IOException(ScBundle.getMessage(ScResourceKeys.MTM_Failed));
            }
            throw e;    
        }
        return sbuffer;
	}
	/**
	 * Reset the object
	 * @throws Exception
	 */
	public void close()throws Exception
	{
		super.close();
	}
	/**
	 * Checks the status of communication with the server
	 * @return boolean 
	  */
	public boolean statusCheck()
	{
	    if(serverType.equals("SCA$IBS") || serverType.equals("SCA$XYZ"))
    		return super.statusCheck();
        else
            return false;
	}
	/**
	 * This method returns the server type
	 * @return String serverType
	 */
	public String getServerType()
	{
		return this.serverType;
	}

	/**
	  * Handles exception thrown during reading and writting a socket.
	  * ScMTMCommunication Object closes the socket object in case an
	  * Excpetion is thrown. Creates a new Socket and reinitializes the 
	  * ScMTMCommunication object.
	  */
	public void handleComm()
	{   
	   
	}
	
}
