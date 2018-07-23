package sanchez.utils.objectpool;

import sanchez.base.ScException;


public class ScObjectPoolException extends ScException {
    private static final int c_iMessageId = 118;

    public ScObjectPoolException() {
        super("ScObjectPoolException", c_iMessageId);
    }

    public ScObjectPoolException(String a_sOtherInfo) {
        super(a_sOtherInfo, c_iMessageId);
    }

    public ScObjectPoolException(int a_iMessageId) {
        super(a_iMessageId);
    }

    public ScObjectPoolException(String a_sOtherInfo, int a_iMessageId) {
        super(a_sOtherInfo, a_iMessageId);
    }
}
