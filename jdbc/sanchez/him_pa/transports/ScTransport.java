/**
 *  	
 *	Abstract base class for all Transport Objects.
 *
 *	@version 	1.0, 6/21/99	
 *	@author		Pranav G. Amin	
 *  @see		sanchez.him_pa.transports.ScMTMTransport
 * 	@see		sanchez.him_pa.transports.ScMQTransport
 *  @see        sanchez.ipc.SiCommunication
 */
package sanchez.him_pa.transports;

import sanchez.base.ScObject;
import sanchez.ipc.SiCommunication;

public abstract class ScTransport extends ScObject
{
    public static final int PROXY_USER = 0;
    protected static int proxyCount = 1;
    private SiCommunication communication;
    
    /**
      * Get a Communication Object related with the Transport Object
      * @return SiCommunication Object.
      */
    public abstract SiCommunication checkOut() throws Exception;

    /**
      * Return the Communication Object once communication needs are meet.
      * @param SiCommunication Object
      */
    public abstract void checkIn(SiCommunication pm_comm);

    public abstract void freeze();
    
    public abstract void remove(SiCommunication pm_comm);
    
    /**
      *refresh transaction
      */
    public abstract void refresh(SiCommunication pm_comm) throws Exception;
    
    public abstract void closePool() throws Exception;

}