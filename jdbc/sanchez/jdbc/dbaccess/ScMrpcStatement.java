/**
 * ScMrpcStatement
 *
 * @version 1.0  Spet. 28 1999
 * @author Quansheng Jia
 * @see ScDBStatement
 */

package sanchez.jdbc.dbaccess;

public class ScMrpcStatement extends sanchez.jdbc.dbaccess.ScDBStatement {
    String version = "1";
    String[] i_sParams;
    String i_sSpv;
    String i_sMrpcID;
    String i_sReply;
    String i_outPutSize = "1";
    String[] outParams;

    public ScMrpcStatement(String version, String mrpcID, String[] params) {
        super();

        this.version = version;
        i_sParams = params;
        i_sMrpcID = mrpcID;
    }

    ///// 09/09/2003 MKT
    public ScMrpcStatement(String version, String mrpcID, String[] params, String spv) {
        super();

        this.version = version;
        i_sSpv = spv;
        i_sParams = params;
        i_sMrpcID = mrpcID;
    }

    public String getSpv() {
        return i_sSpv;
    }
    ///////

    public String[] getParams() {
        return i_sParams;
    }

    public String getMrpcID() {
        return i_sMrpcID;
    }

    public void setReply(String mrpcReply) {
        i_sReply = mrpcReply;
    }

    public String getReply() {
        return i_sReply;
    }

    public String getVersion() {
        return version;
    }

    public void setOutputSize(String size) {
        i_outPutSize = size;
    }

    public String getOutputSize() {
        return i_outPutSize;
    }

    public void setOutParams(String[] oParams) {
        outParams = oParams;
    }

    public String[] getOutParams() {
        return outParams;
    }
}