package sanchez.jdbc.dbaccess;


public class ScGenericStatement extends sanchez.jdbc.dbaccess.ScDBStatement {
    String i_sRequstMessage;
    String i_sReplyMessage;

    public ScGenericStatement(String requestMessage) {
        super();
        i_sRequstMessage = requestMessage;
    }

    public void setReply(String reply) {
        i_sReplyMessage = reply;
    }

    public String getReply() {
        return i_sReplyMessage;
    }

    public String getRequestMessage() {
        return i_sRequstMessage;
    }
}