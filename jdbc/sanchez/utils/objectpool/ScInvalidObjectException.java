package sanchez.utils.objectpool;

import sanchez.base.ScException;

public class ScInvalidObjectException extends ScException {
    private static final int c_iMessageId = 116;

    public ScInvalidObjectException() {
        super("ScInvalidObjectException", c_iMessageId);
    }

    public ScInvalidObjectException(String a_sOtherInfo) {
        super(a_sOtherInfo, c_iMessageId);
    }

    public ScInvalidObjectException(int a_iMessageId) {
        super(a_iMessageId);
    }
}