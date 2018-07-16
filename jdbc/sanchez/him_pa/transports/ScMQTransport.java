/**
  *  	
  *	The MQSeries Transport Object. 
  *
  *	@version 	1.0, 6/21/99	
  *	@author		Pranav G. Amin	
  * @see		sanchez.him_pa.transports.ScMTMTransport
  * @see		sanchez.him_pa.transports.ScMQTransport
  * @see        sanchez.ipc.SiCommunication
  */
package sanchez.him_pa.transports;

import sanchez.ipc.ScMQCommunication;
import sanchez.ipc.SiCommunication;
import sanchez.utils.objectpool.ScMQCommPool;

public class ScMQTransport extends ScTransport
{
	private int i_iTransIPPort;
	private String i_sTransIPAddress;
	private String i_sTransQueueManager;
	private String i_sTransRequestQueue;
	private String i_sTransReplyQueue;
	private String i_sTransChannel;
	private String i_sTransUserId;
	private String i_sTransPassword;
	private ScMQCommPool MQCommPool;

    /**
      * param a_iTransIPPort Port number
      * param a_sTransIPAddress IP Address
      * param a_sTransQueueManager Name of the QueueManager
      * param a_sTransRequestQueue Request Queue Name
      * param a_sTransReplyQueue   Reply Queue Name
      * param a_sTransChannel      Channel Name
      * param a_sTransUserId       User Id
      * param a_sTransPassword     User Password
      */
	public ScMQTransport(int a_iTransIPPort,String a_sTransIPAddress,String a_sTransQueueManager,String a_sTransRequestQueue,
				String a_sTransReplyQueue, String a_sTransChannel, String a_sTransUserId, String a_sTransPassword) throws Exception
	{
		i_iTransIPPort = a_iTransIPPort;
		i_sTransIPAddress = a_sTransIPAddress;	
		i_sTransQueueManager = a_sTransQueueManager;
		i_sTransRequestQueue = a_sTransRequestQueue;
		i_sTransReplyQueue = a_sTransReplyQueue;
		i_sTransChannel = a_sTransChannel;
		i_sTransUserId = a_sTransUserId;
		i_sTransPassword = a_sTransPassword;
		MQCommPool = new ScMQCommPool(i_iTransIPPort,i_sTransIPAddress,i_sTransQueueManager,i_sTransRequestQueue,
						i_sTransReplyQueue,i_sTransChannel,i_sTransUserId,i_sTransPassword);
	}
	 /**
      * Get a MQSeries Communication Object.
      * @return SiCommunication Object.
      */
	public SiCommunication checkOut() throws Exception
	{
		ScMQCommunication comm = (ScMQCommunication)MQCommPool.checkOut();     
	        return comm;
	}
    /**
      * Return the Communication Object once communication needs are meet.
      * @param SiCommunication Object
      */
	public void checkIn(SiCommunication a_oComm) 
	{
		MQCommPool.checkIn(a_oComm);
	}

    public void freeze()
	{
	    MQCommPool.freeze();
	}
	
	public void closePool()
	throws Exception
	{
	    MQCommPool.closePool();
	}
	
	 public void remove(SiCommunication pm_comm)
	 {
	 }
    
    /**
      *refresh transaction
      */
    public  void refresh(SiCommunication pm_comm) 
        throws Exception
    {
    }
    
}