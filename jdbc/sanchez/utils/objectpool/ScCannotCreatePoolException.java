/**
 * ScCannotCreatePool Exception is thrown by ObjectPoolManager when it is unable to create a Pool
 *
 * @version 1.0, 6/21/99.
 * @author Pranav G. Amin
 * @see        com.sanchez.base.ScException
 */
package sanchez.utils.objectpool;

public class ScCannotCreatePoolException extends ScObjectPoolException {
    private static final int c_iMessageId = 111;

    /**
     * Constructs an <code>ScCannotCreatePoolException</code> with no specified detail message.
     *
     */
    public ScCannotCreatePoolException() {
        super("ScCannotCreatePoolException", c_iMessageId);
    }

    /**
     * Constructs an <code>ScCannotCreatePoolException</code> with the specified
     * detail message.
     * @param   s   the detail message.
     */

    public ScCannotCreatePoolException(String a_sOtherInfo) {
        super(a_sOtherInfo, c_iMessageId);
    }

    /**
     * Constructs an <code>ScCannotCreatePoolException</code> with a user
     * defined message_Id
     * @param   a_iMessageId    User Defined MessageId.
     *				Should have an entry in the message table.
     */
    public ScCannotCreatePoolException(int a_iMessageId) {
        super(a_iMessageId);
    }

    /**
     * Constructs an <code>ScCannotCreatePoolException</code> with the specified
     * detail message and a user defined MessageId
     * @param   s   the detail message.
     * @param   a_iMessageId    User Defined MessageId.
     *				Should have an entry in the message table.
     */
    public ScCannotCreatePoolException(String a_sOtherInfo, int a_iMessageId) {
        super(a_sOtherInfo, a_iMessageId);
    }
}