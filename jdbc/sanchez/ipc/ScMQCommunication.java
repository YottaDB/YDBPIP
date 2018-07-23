/**
 * Handles MQCommunication between clients and hosts.
 *
 * @author Pranav Amin
 * @version 1.0 24th May 1999.
 * @see ScMTMCommunication,ScRTRCommunication
 * @see com.ibm.mq.MQQueue.
 */
package sanchez.ipc;

import java.net.SocketException;

import sanchez.base.*;
import sanchez.him_pa.utils.*;
import com.ibm.mq.*;

public class ScMQCommunication extends ScObjectGlobal implements SiCommunication {
    MQMessage i_oSend;
    MQMessage i_oReceive;
    MQPutMessageOptions pmo;
    MQGetMessageOptions gmo;
    MQQueue i_oReply;
    MQQueue i_oRequest;
    String i_oQmgr;
    String i_sReplyQueueName;

    /**
     * Class constructor with a_oReply, a_oRequest, a_oQmgr, a_sReplyQueueName as parameters.
     * @param a_oReply reply queue object.
     * @param a_oRequest request queue pobject.
     * @param a_oQmgr Name of the server queue manager.
     * @param a_sReplyQueueName Name of the reply queue.
     */
    public ScMQCommunication(MQQueue a_oReply, MQQueue a_oRequest, String a_oQmgr, String a_sReplyQueueName) {
        i_oReply = a_oReply;
        i_oRequest = a_oRequest;
        i_oQmgr = a_oQmgr;
        i_sReplyQueueName = a_sReplyQueueName;
        i_oSend = new MQMessage();
        i_oReceive = new MQMessage();
        pmo = new MQPutMessageOptions();
        gmo = new MQGetMessageOptions();
        gmo.waitInterval = 60000;
        gmo.matchOptions = MQC.MQMO_MATCH_MSG_ID;
        gmo.options = MQC.MQGMO_WAIT | MQC.MQGMO_ACCEPT_TRUNCATED_MSG | MQC.MQGMO_CONVERT;
    }

    /**
     * This method opens a channel (connection) for communication.
     * If unsuccessful it will throw a java.lang.Exception.
     * @param pm_message The message that needs to be sent.
     * @exception throws java.lang.Exception
     */
    public void sendMessage(StringBuffer pm_message) throws Exception {
        byte[] message = ScUtils.stringToByte(pm_message.toString());
        i_oSend.write(message);
        i_oSend.replyToQueueManagerName = i_sReplyQueueName;
        i_oSend.replyToQueueName = i_sReplyQueueName;
        //-----------------
        i_oSend.format = MQC.MQFMT_STRING;        // message is in string format
        i_oSend.messageType = MQC.MQMT_REQUEST;        // type of message is a request
        i_oSend.messageId = MQC.MQMI_NONE;                // generate new message id
        i_oSend.report = MQC.MQRO_PASS_MSG_ID;            // pass back message id
        //-----------------
        i_oRequest.put(i_oSend, pmo);
        i_oReceive.messageId = i_oSend.messageId;
    }

    /**
     * This method opens a channel (connection) for communication.
     * If unsuccessful it will throw a java.lang.Exception.
     * @return StringBuffer The message received.
     * @exception throws java.lang.Exception
     */
    public StringBuffer receiveMessage() throws Exception {
        i_oReceive.clearMessage();
        i_oReply.get(i_oReceive, gmo);
        int len = i_oReceive.getMessageLength();
        byte[] temp = new byte[len];
        i_oReceive.readFully(temp);
        return new StringBuffer(ScUtils.byteToString(temp, temp.length));
    }

    /**
     * This method opens a channel (connection) for communication.
     * If unsuccessful it will throw a java.lang.Exception.
     * @param a_oMessage The message that needs to be sent.
     * @return StringBuffer The message received.
     * @exception throws java.lang.Exception
     */
    public StringBuffer exchangeMessage(StringBuffer a_oMessage) throws Exception {
        sendMessage(a_oMessage);
        StringBuffer sb = receiveMessage();
        i_oSend.clearMessage();
        i_oReceive.clearMessage();
        reset();
        return sb;
    }

    /**
     * This method closes communication.
     * @exception throws an exception
     */
    public void close() throws Exception {
    }

    /**
     * Checks the status of communication with the server
     * @return boolean
     */
    public boolean statusCheck() {
        return true;
    }

    /**
     * Handles exception thrown during reading and writing a socket.
     */
    public void handleCommException() {
        return;
    }

    /**
     * This method opens a channel (connection) for communication.
     * If unsuccessful it will throw a java.lang.Exception.
     * @param pm_read
     * @return StringBuffer The message received.
     * @exception throws java.lang.Exception
     */
    public StringBuffer receiveMessage(int pm_read) throws Exception {
        return new StringBuffer();
    }

    /**
     * This method Resets message objects
     */
    private void reset() {
        i_oSend = new MQMessage();
        i_oReceive = new MQMessage();
        i_oSend.format = MQC.MQFMT_STRING;        // message is in string format
        i_oSend.messageType = MQC.MQMT_REQUEST;    // type of message is a request
        i_oSend.messageId = MQC.MQMI_NONE;        // generate new message id
        i_oSend.report = MQC.MQRO_PASS_MSG_ID;
    }

    /**
     * Sets the socket read timeout period. Used for Query Timeout.
     */
    /**
     * Get the readtimeout seconds until which the server waits for read operations to be completed.
     * @return int readtimeout value
     */
    public int getReadTimeOut() {
        return 0;
    }

    /**
     *With this option set to a non-zero timeout, a read() call on the InputStream associated with this Socket will block for only this amount of time.
     *If the timeout expires, a java.net.SocketTimeoutException is raised, though the Socket is still valid.
     *
     *@param pm_readTimeOut
     *@exception throws SocketException
     */
    public void setSoReadTimeOut(int pm_readTimeOut) throws SocketException {
    }
}