/**
 * The MTM Transport Object.
 *
 * @version 1.0, 6/21/99
 * @author Pranav G. Amin
 * @see        sanchez.him_pa.transports.ScMTMTransport
 * @see        sanchez.him_pa.transports.ScMQTransport
 * @see sanchez.ipc.SiCommunication
 */
package sanchez.him_pa.transports;

import sanchez.ipc.ScMTMCommunication;
import sanchez.ipc.SiCommunication;
import sanchez.utils.objectpool.ScMTMCommPool;

public class ScMTMTransport extends ScTransport {
    // port, host, format attributes of the TCPCommunication Object will be stored
    // by reading a file or a hashtable.
    // This functionlity will be included in the next version.
    public ScMTMCommPool MTMCommPool;

    public ScMTMTransport() {
        super();
    }

    /**
     * param sIPAddress IP Address
     * param iIPPort Port number
     * param sProfServType Name of the Server Type eg. SCA$IBS
     */

    public ScMTMTransport(String sIPAddress, int iIPPort, String sProfServType) {
        MTMCommPool = new ScMTMCommPool(iIPPort, sIPAddress, sProfServType);
    }

    public ScMTMTransport(String sIPAddress, int iIPPort, String sProfServType, String sPoolSize) {
        MTMCommPool = new ScMTMCommPool(iIPPort, sIPAddress, sProfServType);

        try {
            if (sPoolSize != null) MTMCommPool.setMaxmumSize(Integer.parseInt(sPoolSize.trim()));
        } catch (Exception e) {
        }
    }

    /**
     * Get a Communication Object related with the Transport Object
     * @return SiCommunication Object.
     */
    public void checkIn(SiCommunication pm_comm) {
        checkInMTM((ScMTMCommunication) pm_comm);
    }

    private void checkInMTM(ScMTMCommunication pm_comm) {
        MTMCommPool.checkIn(pm_comm);
    }

    /**
     * Return the Communication Object once communication needs are meet.
     * @param SiCommunication Object
     */
    public SiCommunication checkOut() throws Exception {
        return checkOutMTM();
    }

    private ScMTMCommunication checkOutMTM() throws Exception {
        return (ScMTMCommunication) MTMCommPool.checkOut();
    }

    public void freeze() {
        MTMCommPool.freeze();
    }

    public void refresh(SiCommunication pm_comm)
            throws Exception {
        remove(pm_comm);
        MTMCommPool.refresh();
    }

    public void closePool()
            throws Exception {
        MTMCommPool.closePool();
    }

    public void remove(SiCommunication pm_comm) {
        try {
            pm_comm.close();
        } catch (Exception e) {
        }
        MTMCommPool.remove((ScMTMCommunication) pm_comm);

    }

}