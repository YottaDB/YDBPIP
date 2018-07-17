/**
 * ScException is the base class for all Sanchez Exceptions.
 * It maintains a reference to the session cache, from where he can get a handle to the message manager
 * So as to display appropriate messages.
 *
 * @version 1.0, 6/21/99.
 * @author Pranav G. Amin
 * @see        sanchez.base.ScException
 * @see sanchez.base.ScMessage
 * @see sanchez.app.ScSessionCacheManager
 */
package sanchez.base;

import java.util.Locale;

import sanchez.utils.ScLogManager;
import sanchez.utils.SiLoggable;
import sanchez.jdbc.dbaccess.ScDBError;
import sanchez.jdbc.driver.ScDriver;

public class ScException extends java.lang.Exception implements SiLoggable {
    private static final String SC_EXCEPTION = "ScException";
    private int messageId = 100;
    private String otherInfo = SC_EXCEPTION;
    private Locale locale = null;

    /**
     * Constructs an <code>ScException</code> with no specified detail message.
     *
     */
    public ScException() {
        super();
        initialize();
    }

    /**
     * @param   a_iMessageId    User Defined MessageId. Should have an entry in the message table.
     */
    public ScException(int messageId) {
        super();
        this.messageId = messageId;
        initialize();
    }

    /**
     * @param   a_sOtherInfo   the detail message.
     * @param   a_iMessageId    User Defined MessageId. Should have an entry in the message table.
     */
    public ScException(String otherInfo, int messageId) {
        super(otherInfo);
        this.messageId = messageId;
        this.otherInfo = otherInfo;
        if (messageId != 122)
            initialize();
    }

    /**
     * Constructs an <code>ScException</code> with no specified detail message.
     *
     */
    public ScException(Locale locale) {
        super();
        this.locale = locale;
        initialize();
    }

    /**
     * @param   a_iMessageId    User Defined MessageId. Should have an entry in the message table.
     */
    public ScException(int messageId, Locale locale) {
        super();
        this.messageId = messageId;
        this.locale = locale;
        initialize();
    }

    /**
     * @param   a_sOtherInfo   the detail message.
     * @param   a_iMessageId    User Defined MessageId. Should have an entry in the message table.
     */
    public ScException(String otherInfo, int messageId, Locale locale) {
        super(otherInfo);
        this.messageId = messageId;
        this.otherInfo = otherInfo;
        this.locale = locale;
        if (messageId != 122)
            initialize();
    }

    /**
     * @return int representing the messageId
     */
    public int getID() {
        return messageId;
    }

    /**
     * @return String that should be logged by the logger.
     */
    public String getLogInfo() {
        return "High Message :" + ScDBError.getErrorMessage(getID()) + "\n" +
                "Other Information :" + otherInfo + "\n";
    }

    /**
     * @return String representing the additional message with which the Exception was generated.
     */
    public String getOtherInfo() {
        return otherInfo;
    }

    private void initialize() {
        ScLogManager.log(this);
    }

    public Locale getLocale() {
        if (locale == null)
            setLocale(ScDriver.getDriverLocale());
        return locale;
    }

    public void setLocale(Locale locale) {
        this.locale = locale;
    }
}