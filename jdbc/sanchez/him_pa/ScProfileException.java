/**
 * @version 1.0, 6/21/99.
 * @author Pranav G. Amin
 * @see        sanchez.base.ScException
 */
package sanchez.him_pa;

import sanchez.base.ScException;

public class ScProfileException extends ScException {
    private static int c_iMessageId = 122;

    /**
     * Constructs an <code>ScProfileException</code> with no specified detail message.
     *
     */
    public ScProfileException() {
        super(c_iMessageId);
    }

    /**
     * Constructs an <code>ScProfileException</code> with specified detail message.
     *    @param a_sOtherInfo A string representing a message. This string can be restored by invoking
     * getOtherInfo() method of the Exception/
     */
    public ScProfileException(String a_sOtherInfo) {
        super(a_sOtherInfo, c_iMessageId);
    }

    /**
     * Constructs an <code>ScProfileException</code> with a user
     * defined message_Id
     * @param   a_iMessageId    User Defined MessageId. Should have an entry in the message table.
     */

    public ScProfileException(int a_iMessageId) {
        super(a_iMessageId);
    }

    /**
     * Constructs an <code>ScProfileException</code> with the specified
     * detail message and a user defined MessageId
     * @param   a_sOtherInfo   the detail message.
     * @param   a_iMessageId    User Defined MessageId. Should have an entry in the message table.
     */
    public ScProfileException(String a_sOtherInfo, int a_iMessageId) {
        super(a_sOtherInfo, a_iMessageId);
    }
}
