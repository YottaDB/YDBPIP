/**
* ScMsqlDDLStatement
*
* @version     1.0  Spet. 28 1999
* @author      Quansheng Jia 
* @see         ScDBStatement
*/

package sanchez.jdbc.dbaccess;

import java.sql.SQLException;


public class ScMsqlDDLStatement extends sanchez.jdbc.dbaccess.ScDBStatement
{
    public String i_sSqlstmt;
    String i_sBufferName;
    public String sqlQuailfier = new String();
    private String generatedKeys = null;
    public String spvInfo = new String();
      
    public ScMsqlDDLStatement(String sBufferName,String sSql)
    {
        super();
        i_sBufferName = sBufferName;
        i_sSqlstmt = sSql;
    }
    
    public ScMsqlDDLStatement(String sSqlstmt)
    {
        super();
        i_sSqlstmt = sSqlstmt;
    }
    
    public void setEFD(int efd)
    {
         sqlQuailfier = "/EFD="+efd;  
    }
    
    public String getSqlStatment()
    {
        return i_sSqlstmt;
    }

    /**
     * Returns the supervisory information 
     * @return String supervisory information
     */
    public String getSpvInfo()
    {
        return spvInfo;
    }
    

    public String getGeneratedKeys() {
		return generatedKeys;
	}

    public void setGeneratedKeys(String generatedKeys) {
		this.generatedKeys = generatedKeys;
	}
    
       
}