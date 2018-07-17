/**
 * @version 1.0, 6/21/99.
 * @author Pranav G. Amin
 * @see        sanchez.base.ScException
 */
package sanchez.him_pa;

import sanchez.base.ScException;

public class ScHIM_PAException extends ScException {
    private static final int c_iMessageId = 106;

    /**
     * Constructs an <code>ScHIM_PAException</code> with no specified detail message.
     *
     */
    public ScHIM_PAException() {
        super("ScHIM_PAException", c_iMessageId);
    }

    /**
     * Constructs an <code>ScHIM_PAException</code> with specified detail message.
     *    @param a_sOtherInfo A string representing a message. This string can be restored by invoking
     * getOtherInfo() method of the Exception/
     */
    public ScHIM_PAException(String a_sOtherInfo) {
        super(a_sOtherInfo, c_iMessageId);
    }

    /**
     * Constructs an <code>ScHIM_PAException</code> with a user
     * defined message_Id
     * @param   a_iMessageId    User Defined MessageId. Should have an entry in the message table.
     */
    public ScHIM_PAException(int a_iMessageId) {
        super(a_iMessageId);
    }

    /**
     * Constructs an <code>ScHIM_PAException</code> with the specified
     * detail message and a user defined MessageId
     * @param   a_sOtherInfo   the detail message.
     * @param   a_iMessageId    User Defined MessageId. Should have an entry in the message table.
     */
    public ScHIM_PAException(String a_sOtherInfo, int a_iMessageId) {
        super(a_sOtherInfo, a_iMessageId);
    }
}