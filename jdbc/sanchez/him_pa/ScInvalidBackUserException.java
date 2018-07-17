/**
 * @version 1.0, 6/21/99.
 * @author Pranav G. Amin
 * @see        sanchez.base.ScException
 */
package sanchez.him_pa;

public class ScInvalidBackUserException extends ScHIM_PAException {
    private static final int c_iMessageId = 114;

    /**
     * Constructs an <code>ScInvalidBackUserException</code> with no specified detail message.
     *
     */
    public ScInvalidBackUserException() {
        super("ScInvalidBackUserException", c_iMessageId);
    }

    /**
     * Constructs an <code>ScInvalidBackUserException</code> with specified detail message.
     *    @param a_sOtherInfo A string representing a message. This string can be restored by invoking
     * getOtherInfo() method of the Exception/
     */
    public ScInvalidBackUserException(String a_sOtherInfo) {
        super(a_sOtherInfo, c_iMessageId);
    }

    /**
     * Constructs an <code>ScInvalidBackUserException</code> with a user
     * defined message_Id
     * @param   a_iMessageId    User Defined MessageId. Should have an entry in the message table.
     */
    public ScInvalidBackUserException(int a_iMessageId) {
        super(a_iMessageId);
    }

    /**
     * Constructs an <code>ScInvalidBackUserException</code> with the specified
     * detail message and a user defined MessageId
     * @param   a_sOtherInfo   the detail message.
     * @param   a_iMessageId    User Defined MessageId. Should have an entry in the message table.
     */
    public ScInvalidBackUserException(String a_sOtherInfo, int a_iMessageId) {
        super(a_sOtherInfo, a_iMessageId);
    }
}