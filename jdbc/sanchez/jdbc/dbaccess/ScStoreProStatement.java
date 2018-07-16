package sanchez.jdbc.dbaccess;


public class ScStoreProStatement extends sanchez.jdbc.dbaccess.ScDBStatement
{
    String[] i_sParams;
    String i_sStoreProName;
    String i_sReply;
    String i_outPutSize="1";
    /* Manoj Thoniyil - 09/08/2005 */
    public String sqlQuailfier = new String();
    String[] outParams;
    
    public ScStoreProStatement(String storeProName, String[] params){
        super();
        i_sParams = params;
        i_sStoreProName = storeProName;
    }
    
    public String[] getParams(){
        return i_sParams;
    }
    
    public String getStoreProName(){
        return i_sStoreProName;
    }
    
    public void setReply(String mrpcReply)
    {
        i_sReply = mrpcReply;
    }
    
    public String getReply()
    {
        return i_sReply;
    }
     
    public void setOutputSize(String size)
    {
        i_outPutSize = size;
    }
    
    public String getOutputSize()
    {
        return i_outPutSize;
    }

    public void setOutParams(String[] oParams){
    	outParams = oParams;
    }
    
    public String[] getOutParams(){
        return outParams;
    }

}