package sanchez.utils.objectpool;

import java.util.Enumeration;

import sanchez.ipc.ScTCPCommunication;

/**
 * TCP Communication Object Pool.
 * Holds a pool of TCP Socket connection classes bound to a specified host and port
 *
 * @author Pranav Amin
 * @version 1.0  19 Feb 1999
 * @see     ObjectPool
 * @see GarbageCollector
 * @see Cleanable
 * <p>
 * Revision History:
 * Oct. 22 1999 Jiaq
 * Added closePool to close the pool when the JVM is shut down
 */

public class ScTCPCommPool extends ScObjectPool {

    int port;
    String host;
    int format = ScTCPCommunication.BINARY;

    /**
     * @param pm_port an integer indicating the port to be bound for communication.
     * @param pm_host a String identifing the host to which connection is required eg. "www.sanchez.com"
     */
    public ScTCPCommPool(int pm_port, String pm_host) {
        super();
        minimumSize = 0;
        port = pm_port;
        host = pm_host;
    }

    /**
     * @param pm_port   an integer indicating the port to be bound for communication.
     * @param pm_host   a String identifing the host to which connection is required eg. "www.sanchez.com"
     * @param pm_format an int indicating the format for communication. Could be Binary or Unicode.
     *                  use ScTransport.BINARY or 0 for Binary communication format.
     *                  use ScTransport.UNICode or 1 for Unicode communicatoin format.
     */
    public ScTCPCommPool(int pm_port, String pm_host, int pm_format) {
        super();
        port = pm_port;
        host = pm_host;
        format = pm_format;
    }

    /**
     * @see ObjectPool#create
     */
    public Object create() throws Exception {
        return new ScTCPCommunication(port, host, format);
    }

    protected void expire(Object o) {
        try {
            ((ScTCPCommunication) o).close();
        } catch (Exception e) {
        }
        super.expire(o);
    }

    public boolean validate(Object o) {
        ScTCPCommunication tcp;
        try {
            tcp = (ScTCPCommunication) o;
        } catch (ClassCastException e) {
            return false;
        }
        if (tcp.getPort() == this.port && tcp.getHost().equals(this.host) && tcp.getFormat() == this.format)
            return true;
        else
            return false;
    }

    public void closePool()
            throws Exception {

        int num = unlocked.size() + locked.size();
        if (num == 0) return;
        Enumeration enum1 = unlocked.keys();

        ScTCPCommunication tcp;

        while (enum1.hasMoreElements()) {
            tcp = (ScTCPCommunication) enum1.nextElement();
            unlocked.remove(tcp);
            try {
                tcp.close();
            } catch (Exception e) {
            }
        }

        enum1 = locked.keys();
        while (enum1.hasMoreElements()) {
            tcp = (ScTCPCommunication) enum1.nextElement();
            locked.remove(tcp);
            try {
                tcp.close();
            } catch (Exception e) {
            }
        }
    }

    public synchronized void refresh()
            throws Exception {
        Enumeration enum1 = unlocked.keys();

        ScTCPCommunication tcp;

        while (enum1.hasMoreElements()) {
            tcp = (ScTCPCommunication) enum1.nextElement();
            unlocked.remove(tcp);
            try {
                tcp.close();
            } catch (Exception e) {
            }
            tcp = null;
        }
    }
}