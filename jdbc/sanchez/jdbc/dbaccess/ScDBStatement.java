package sanchez.jdbc.dbaccess;

public abstract class ScDBStatement
{
    String i_sServerClass;
    protected static final String SQL_MESS      = new String("5");
    protected static final String HTML_MESS     = new String("6");
    protected static final String LOGIN_REQUEST = new String ("0");
    protected static final String MRPC_MESS     = new String("3");
    protected static final String XML_MESS     = new String("4");
    
    public ScDBStatement()
    {

    }
    
    public String getServerClass()
    {
        return i_sServerClass;
    }

    public void setServerClass(String serverClass)
    {
        i_sServerClass = serverClass;
    }
    
    
        
}

