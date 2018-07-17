/**
 * Abstract Communication class.
 * It is a high level abstraction of functionalities of all Communication
 * objects. All communication objects need to implement this interface.
 *
 * @author Pranav Amin
 * @version 1.0 4th Feb 1999.
 * @see MQSCommunication, TCPCommunication, MTMCommunication,RTRCommunication;
 */

package sanchez.ipc;

import java.net.SocketException;

public interface SiCommunication {
    /**
     * This method opens a channel (connection) for communication.
     * If unsuccessful it will throw a subclass of java.lang.Exception depending
     * upon the concrete implementation of SiCommunication class.
     * eg TCP Communication will throw IOException.

     * @ param pm_message	The message that needs to be sent.
     * @exception java.lang.Exception Depending upon the Communication method
     * a subclass of Exception will be thrown
     */

    public abstract void sendMessage(StringBuffer pm_message) throws Exception;

    /**
     * This method opens a channel (connection) for communication.
     * If unsuccessful it will throw a subclass of java.lang.Exception depending
     * upon the concrete implementation of SiCommunication class.
     * eg TCP Communication will throw IOException.

     * @ param pm_read	Number of byte to read.
     * @ return StringBuffer  The message received.
     * @exception java.lang.Exception Depending upon the Communication method
     * a subclass of Exception will be thrown
     */
    public StringBuffer receiveMessage(int pm_read) throws Exception;

    /**
     * This method opens a channel (connection) for communication.
     * If unsuccessful it will throw a subclass of java.lang.Exception depending
     * upon the concrete implementation of SiCommunication class.
     * eg TCP Communication will throw IOException.

     * @ param pm_message	The message that needs to be sent.
     * @ return StringBuffer  The message received.
     * @exception java.lang.Exception Depending upon the Communication method
     * a subclass of Exception will be thrown
     */
    public StringBuffer exchangeMessage(StringBuffer pm_message) throws Exception;

    /**
     * Reset the object
     * @throws Exception
     */
    void close() throws Exception;

    /**
     * Checks the status of communication with the server
     * @return boolean
     */
    public boolean statusCheck();
    // added this method on March 15th 1999.

    /**
     * If a communication exception such as read time out occurs this method  will
     * be called. This method is host specific. For instance the MTM Communication
     * Object closes the communication object.
     */
    public void handleCommException();

    /**
     * Sets the socket read timeout period. Used for Query Timeout.
     */
    /**
     * Get the readtimeout seconds until which the server waits for read operations to be completed.
     * @return int readtimeout value
     */
    public int getReadTimeOut();

    /**
     *
     *With this option set to a non-zero timeout, a read() call on the InputStream associated with this Socket will block for only this amount of time.
     *If the timeout expires, a java.net.SocketTimeoutException is raised, though the Socket is still valid.
     */
    public void setSoReadTimeOut(int iTimeOut) throws SocketException;
}