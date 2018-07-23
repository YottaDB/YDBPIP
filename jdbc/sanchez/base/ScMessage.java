/**
 * ScMessage has  one to one bearing with the entry in the message table on the GAEA database.
 *
 * @version 1.0, 6/21/99.
 * @author Pranav G. Amin
 * @see        sanchez.utils.SiLoggable.
 * @see        sanchez.base.SiLogger.
 * @see        Doer Doable pattern in the GAEA design documentations.
 * <p>
 * 0 - 99: 		Reserved messages
 * 100 to 499,999: 	Sanchez base messages
 * 500,000 to 549,999: Sanchez off-site msgs
 * 600,000 to 609,999: Dev and temp msgs
 * 800,000 to 899,999: Custom msgs
 */

package sanchez.base;

import java.io.Serializable;

public class ScMessage extends ScObject implements Serializable {
    int i_iEnvironment_id;
    int i_iLanguage_id;
    int i_iMessage_id;
    String i_sLowMessage;
    String i_sHighMessage;
    int i_iActionCode;
    String i_sActionMessage;


    ScMessage(String alMessageID)    // init message object via message id from database or 	// global message store (see ScMessageManager)
    {
    }

    ScMessage()    // the Default constructor.
    {
    }

    /**
     * @param a_iEnvironment_id Enviornment Id for this message Object
     * @param a_iMessageId Message Id for this message Object
     * @param a_iLanguage_id Language Id for this message Object
     * @param a_sHighMessage High Message for this message Object
     * @param a_sLowMessage Low Message for this message Object
     * @param a_iActionCode Action Code for this message Object
     * @param a_sActionMessage Action Message this message Object
     */
    public ScMessage(int a_iEnvironment_id, int a_iMessage_id,
                     String a_sLowMessage, String a_sHighMessage,
                     int a_iLanguage_id,
                     int a_iActionCode, String a_sActionMessage) {
        i_iEnvironment_id = a_iEnvironment_id;
        i_iLanguage_id = a_iLanguage_id;
        i_iMessage_id = a_iMessage_id;
        i_sLowMessage = a_sLowMessage;
        i_sHighMessage = a_sHighMessage;
        i_iActionCode = a_iActionCode;
        i_sActionMessage = a_sActionMessage;
    }

    /**
     * Gets the MessageId of this Object
     *
     * @return MessageId Each message has a unique combination of message_id, language_id and environment_id
     */
    public int getMessageID()    // get message id.  If not assigned yet.// Create an ID using the ID algorithm
    {
        return i_iMessage_id;
    }

    /**
     * Gets the Action message for this object
     *
     * @return Action  Message
     */
    public String getActionMessage() {
        return i_sActionMessage;
    }

    /**
     * Gets the Low message for this object
     *
     * @return Low  Message
     */
    public String getLowMessage()    // receive the low message string
    {
        return i_sLowMessage;
    }

    /**
     * Gets the High message for this object
     *
     * @return High  Message
     */
    public String getHighMessage()    // get the high message string
    {
        return i_sHighMessage;
    }

    /**
     * Create a unique key to identify this message object.
     *
     * @return Action  Message
     */
    public String createKey() {
        return Integer.toString(i_iEnvironment_id)
                + Integer.toString(i_iLanguage_id)
                + Integer.toString(i_iMessage_id);
    }

    /**
     * String representation of the Object.
     */
    public String toString() {
        return "ScMessage " + i_iEnvironment_id + "\t" +
                i_iLanguage_id + "\t" +
                i_iMessage_id + "\t" +
                i_sLowMessage + "\t" +
                i_sHighMessage + "\t" +
                i_iActionCode + "\t" +
                i_sActionMessage;
    }

    /**
     * Static method to create a unique key to identify a message object.

     * @param a_iEnvironment_id Enviornment Id for this message Object
     * @param a_iMessageId Message Id for this message Object
     * @param a_iLanguage_id Language Id for this message Object
     * @return Action  Message
     */
    public static String generateKey(int a_iEnvironment_id, int a_iLanguage_id, int a_iMessage_id) {
        return Integer.toString(a_iEnvironment_id)
                + Integer.toString(a_iLanguage_id)
                + Integer.toString(a_iMessage_id);
    }
}
