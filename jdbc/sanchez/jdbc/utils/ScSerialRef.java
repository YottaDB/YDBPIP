package sanchez.jdbc.utils;

import java.io.Serializable;
import java.sql.Ref;
import java.sql.SQLException;
import java.util.Hashtable;
import java.util.Map;

import sanchez.jdbc.dbaccess.ScDBError;

// Referenced classes of package javax.sql.rowset.serial:
//            SerialException

public class ScSerialRef
    implements Ref, Serializable, Cloneable
{

    public ScSerialRef(Ref ref)
        throws SQLException
    {
        baseTypeName = new String(ref.getBaseTypeName());
    }

    public String getBaseTypeName()
        throws SQLException
    {
        return baseTypeName;
    }

    public Object getObject(Map map)
        throws SQLException
    {
        map = new Hashtable(map);
        if(!object.equals(null))
            return map.get(object);
        else
            throw new SQLException("The object is not set");
    }

    public Object getObject()
        throws SQLException
    {
        if(!object.equals(null))
            return object;
        else
            throw new SQLException("The object is not set");
    }

    public void setObject(Object obj)
        throws SQLException
    {
        object = obj;
    }

    private String baseTypeName;
    private Object object;
}
