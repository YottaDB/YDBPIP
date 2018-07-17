/**
 * Handles TCPCommunication between clients and hosts.
 *
 * @author Pranav Amin
 * @version 1.0 4th Feb 1999.
 * @see MQSCommunication, Communication, MTMCommunication,RTRCommunication;
 * <p>
 * Revision History:
 * 5th May 1999 Jiaq
 * Modified receiveMessage method , fix byte to char
 * converting bug. Use " new StringBuffer(new String(char[] charArray,int offset,int ount))"
 * to replace new StringBuffer(new String(byte[] byteArray,int offset,int count));
 * <p>
 * May 10, 1999 Jiaq
 * Modified send method, use new utility to convert byte[] to string
 */
package sanchez.ipc;

import java.net.*;
import java.io.*;

import sanchez.him_pa.utils.*;


public class ScTCPCommunication extends sanchez.base.ScObjectGlobal implements SiCommunication {
    public static final int BINARY = 0;
    public static final int UNICODE = 1;
    private int port = 18055;
    private String host = "192.168.2.1";
    private int format = BINARY; // Binary by default
    private BufferedInputStream bis;
    private BufferedOutputStream bos;
    private BufferedReader br;
    private BufferedWriter bw;
    private int bufferSize = 1048576;
    private int readTimeOut = 300000;
    private int readSize = 0;
    private Socket socket;
    ScUtils myuti = new ScUtils();

    /**
     * Class constructor with pm_port, pm_host, pm_format as parameters
     * @param pm_port Port number.
     * @param pm_host IP Address of the host.
     * @param pm_format Communication format Binary/ASCII/Unicode
     * @exception throws java.lang.Exception
     */
    public ScTCPCommunication(int pm_port, String pm_host, int pm_format) throws Exception {
        this.port = pm_port;
        this.host = pm_host;
        this.format = pm_format;
        socket = new Socket(host, port);

        this.initialize();
    }

    /**
     * Initializes the TCP/IP socket with the readtimeout value and enables SO_LINGER with the specified linger time in seconds
     * And creates channels with specified binary or unicode format
     * @throws java.lang.Exception
     */
    protected void initialize() throws Exception {
        //maximum milliseconds a read will be blocked when waiting for data
        socket.setSoTimeout(readTimeOut);
        socket.setSoLinger(true, 0);
        this.createChannels(format);
    }

    /**
     * Class constructor with pm_port, pm_host as parameters
     * @param pm_port Port number.
     * @param pm_host IP Address of the host.
     */
    public ScTCPCommunication(int pm_port, String pm_host) throws Exception {

        this(pm_port, pm_host, ScTCPCommunication.BINARY);
    }

    /**
     * Class constructor 
     */
    public ScTCPCommunication() throws Exception {
        this(80, "http://aminp", ScTCPCommunication.BINARY);
    }

    /**
     * Creates TCP/IP channels for sending and receiving messages from/to server 
     * @param type int
     * @throws java.lang.Exception
     */
    private void createChannels(int type) throws Exception {
        switch (type) {
            case 0:
                bis = new BufferedInputStream(socket.getInputStream(), this.bufferSize);
                bos = new BufferedOutputStream(socket.getOutputStream(), this.bufferSize);
                break;

            case 1:
                br = new BufferedReader(new InputStreamReader(socket.getInputStream()), this.bufferSize);
                bw = new BufferedWriter(new OutputStreamWriter(socket.getOutputStream()), this.bufferSize);
                break;
        }
    }

    /**
     * This method opens a channel (connection) for communication.
     * If unsuccessful it will throw a java.lang.Exception.
     * @param pm_message The message that needs to be sent.
     * @exception throws java.lang.Exception
     */
    public void sendMessage(StringBuffer pm_message) throws Exception {
        try {
            if (bos != null) {
                byte[] message = ScUtils.stringToByte(pm_message.toString());

                int len = message.length;
                if (bufferSize >= len) {
                    bos.write(message, 0, len);
                }//if
                else {
                    for (int temp = 0; temp <= len; temp = temp + bufferSize) {
                        if (temp + bufferSize < len)
                            bos.write(message, temp, bufferSize);
                        else
                            bos.write(message, temp, len - temp);
                    }//for
                }//else
                bos.flush();
            }//if
            if (bw != null) {
                String message = pm_message.toString();
                int len = message.length();
                if (bufferSize >= len)
                    bw.write(message, 0, len);
                else {
                    for (int temp = 0; temp <= len; temp = temp + bufferSize) {
                        if (temp + bufferSize < len)
                            bw.write(message, temp, bufferSize);
                        else
                            bw.write(message, temp, len - temp);
                    }//for
                }//else
                bw.flush();
            }//if
        }//try
        catch (Exception e) {
            //e.printStackTrace ();
            handleCommException();
            throw e;
            // Let the subclass handle the exception.
            // Do certain things that the subclass should not know or worry about.
        }
    }

    /**
     * This method opens a channel (connection) for communication.
     * If unsuccessful it will throw a java.lang.Exception.
     * @param pm_readSize
     * @return StringBuffer The message received.
     * @exception throws java.lang.Exception
     */
    public StringBuffer receiveMessage(int pm_readSize) throws Exception {
        this.readSize = pm_readSize;
        return receiveMessage();
    }

    /**
     * This method opens a channel (connection) for communication.
     * If unsuccessful it will throw a java.lang.Exception.
     * @return StringBuffer The message received.
     * @exception throws java.lang.Exception
     */
    private StringBuffer receiveMessage() throws Exception {

        int count, offset;
        byte[] data = new byte[readSize];
        StringBuffer sbuffer = new StringBuffer("");

        try {
            if (bis != null) {
                count = 0;
                offset = 0;

                do {
                    if (readSize - offset < bufferSize)
                        count = bis.read(data, offset, readSize - offset);
                    else {
                        count = bis.read(data, offset, bufferSize);
                    }
                    if (count > -1)
                        offset += count;
                    else {
                        handleCommException();
                        throw new IOException();
                    }
                }
                while (offset < readSize && count > -1);

                if (doCRCCheck(data)) {
                    //Unwrap communication headers ???
                } else {
                    // what if CRC errors...
                }
                return new StringBuffer(ScUtils.byteToString(data, offset));
            }//if bis

            if (br != null) {
                String stringMessage = br.readLine();

                byte[] message = ScUtils.stringToByte(stringMessage);
                if (doCRCCheck(message)) {
                    //Unwrap communication headers ???
                } else {
                    // what if CRC errors...
                }
                return new StringBuffer(new String(message));
            }//if br
        }//try
        catch (Exception exc) {

            handleCommException();
            // Let the subclass handle the exception.
            // Do certain things that the subclass should not know or worry about.
            throw exc;
        }
        return sbuffer;
    }

    /**
     * Does a cyclic redundancy check on the message that needs to be sent to server
     * @param pm_message message to be sent
     * @return boolean true
     */
    public boolean doCRCCheck(byte[] pm_message) {
        return true;
    }

    /**
     * This method opens a channel (connection) for communication.
     * Exception is thrown when unsuccessful
     * @param pm_message The message that needs to be sent.
     * @return StringBuffer The message received.
     * @throws java.lang.Exception
     */
    public StringBuffer exchangeMessage(StringBuffer pm_message) throws Exception {
        if (socket == null)
            handleCommException();
        this.sendMessage(pm_message);
        return this.receiveMessage();

    }

    /**
     * This method closes communication.
     * @exception throws an exception
     */
    public void close() throws Exception {
        try {
            socket.shutdownInput();
            socket.shutdownOutput();
            socket.close();
            if (bis != null)
                bis.close();
            if (bos != null)
                bos.close();
            if (br != null)
                br.close();
            if (bw != null)
                bw.close();
        } catch (IOException ioexception) {
            // handle exception
        }
        bis = null;
        bos = null;
        br = null;
        bw = null;
        socket = null;
    }

    /**
     * Checks the status of communication with the server
     * @return boolean
     */
    public boolean statusCheck() {
        if (socket != null && this.host != null && this.port > 0) {
            if (bis != null && bos != null)
                return true;
            if (br != null && bw != null)
                return true;
        }
        return false;
    }
//--------------Accessor Methods----------------------------	

    /**
     * sets the port number for communication channel
     * @param pm_port String
     * @exception throws java.lang.Exception
     */
    public void setPort(String pm_port) throws Exception {
        Integer port_no = new Integer(pm_port);
        this.port = port_no.intValue();
    }

    /**
     * Gets the port number
     * @return int port number
     */
    public int getPort() {
        return this.port;
    }

    /**
     * sets host value
     * @param pm_host
     * @exception throws java.lang.Exception
     */
    public void setHost(String pm_host) throws Exception {
        this.host = pm_host;
    }

    /**
     * Gets the host value
     * @return String host value
     */
    public String getHost() {
        return this.host;
    }

    /**
     * sets the buffer size
     * @param pm_bufferSize
     */
    protected void setBufferSize(int pm_bufferSize) {
        this.bufferSize = pm_bufferSize;
    }

    /**
     * sets the readtimeout value
     * @param pm_readTimeOut
     */
    public void setReadTimeOut(int pm_readTimeOut) {
        this.readTimeOut = pm_readTimeOut;
    }

    /**
     * sets the read size for a message
     * @param pm_readSize
     */
    public void setReadSize(int pm_readSize) {
        this.readSize = pm_readSize;
    }

    /**
     * Gets the read size of the message
     * @return readsize
     */
    public int getReadSize() {
        return readSize;
    }

    /**
     * sets the socket number
     * @param pm_socket
     */
    protected void setSocket(Socket pm_socket) {
        this.socket = pm_socket;
    }

    /**
     * Gets the socket number
     * @return socket number
     */
    public Socket getSocket() {
        return socket;
    }

    /**
     * Gets the format for the message
     * @return format
     */
    public int getFormat() {
        return this.format;
    }

    /**
     * Called when a communication exception is thrown.
     */
    public void handleCommException() {
        try {
            this.close();
            Socket socket = new Socket(this.getHost(), this.getPort());
            this.setSocket(socket);
            this.initialize();
        } catch (Exception e) {
        }
        // Let the subclass handle.
    }

    /**
     * Resets all the references of an object
     * @throws Throwable
     */
    public void finalize() throws Throwable {
        this.close();
    }

    /**
     * Sets the socket read timeout period. Used for Query Timeout.
     * @param pm_readTimeOut readTimeout
     * @exception throws SocketException
     */
    public void setSoReadTimeOut(int pm_readTimeOut) throws SocketException {
        if (socket != null)
            socket.setSoTimeout(pm_readTimeOut);
    }

    /**
     * Gets the read timeout value
     * @return int
     */
    public int getReadTimeOut() {
        return this.readTimeOut;
    }
}