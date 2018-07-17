/**
 * Parent class for all TCP Transports.
 *
 * @version 1.0, 6/21/99
 * @author Pranav G. Amin
 * @see        com.sanchez.him_pa.transports.ScMTMTransport
 * @see        com.sanchez.him_pa.transports.ScMQTransport
 * @see com.sanchez.ipc.SiCommunication
 */
package sanchez.him_pa.transports;

import sanchez.ipc.ScTCPCommunication;
import sanchez.ipc.SiCommunication;
import sanchez.utils.objectpool.ScTCPCommPool;

public class ScTCPTransport extends ScTransport {
    private int port = 80;
    private String host = "www.fnfis.com";
    // port, host, format attributes of the TCPCommunication Object will be stored
    // by reading a file or a hashtable.
    // This functionlity will be included in the next version.
    public static ScTCPCommPool TCPCommPool;//

    /**
     * @param sIPAddress IP Adress of the host.
     * @param iIPPort  Port number.
     */
    public ScTCPTransport(String sIPAddress, int iIPPort) {
        TCPCommPool = new ScTCPCommPool(iIPPort, sIPAddress);
    }

    /**
     * Get a Communication Object related with the Transport Object
     * @return SiCommunication Object.
     */
    public SiCommunication checkOut() throws Exception {
        return checkOutTCP();
    }

    /**
     * Return the Communication Object once communication needs are meet.
     * @param SiCommunication Object
     */
    public void checkIn(SiCommunication pm_comm) {
        TCPCommPool.checkIn((ScTCPCommunication) pm_comm);
    }

    private ScTCPCommunication checkOutTCP() throws Exception {
        ScTCPCommunication comm = (ScTCPCommunication) TCPCommPool.checkOut();
        return comm;
    }

    private void checkInTCP(ScTCPCommunication pm_comm) {
        TCPCommPool.checkIn(pm_comm);
    }

    public void remove(SiCommunication pm_comm) {
        try {
            pm_comm.close();
        } catch (Exception e) {
        }

        TCPCommPool.remove((ScTCPCommunication) pm_comm);
    }

    public void freeze() {
        TCPCommPool.freeze();
    }

    public void refresh(SiCommunication pm_comm)
            throws Exception {
        remove(pm_comm);
        TCPCommPool.refresh();
    }

    public void closePool()
            throws Exception {
        TCPCommPool.closePool();
    }
}