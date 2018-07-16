package sanchez.jdbc.utils;

import java.io.Serializable;
import java.net.MalformedURLException;
import java.net.URL;
import java.sql.SQLException;

import sanchez.jdbc.dbaccess.ScDBError;

// Referenced classes of package javax.sql.rowset.serial:
//            SerialException

public class ScSerialDatalink
    implements Serializable, Cloneable
{

    public ScSerialDatalink(URL url1)
        throws SQLException
    {
        if(url1 == null)
        {
            throw new ScSerialException("Cannot serialize empty URL instance");
        } else
        {
            url = url1;
            return;
        }
    }

    public URL getDatalink()
        throws SQLException
    {
        URL url1 = null;
        try
        {
            url1 = new URL(url.toString());
        }
        catch(MalformedURLException malformedurlexception)
        {
            malformedurlexception.printStackTrace();
        }
        return url1;
    }

    private URL url;
    private int baseType;
    private String baseTypeName;
}
