package sanchez.jdbc.utils;


import java.io.Serializable;
import java.sql.*;
import java.util.Map;
import java.util.Vector;

// Referenced classes of package javax.sql.rowset.serial:
//            SerialException, SQLOutputImpl, SerialBlob, SerialClob, 
//            SerialRef, SerialArray

public class ScSerialStruct
    implements Struct, Serializable, Cloneable
{

    public ScSerialStruct(Struct struct, Map map)
        throws SQLException
    {
        try
        {
            SQLTypeName = new String(struct.getSQLTypeName());
            System.out.println("SQLTypeName: " + SQLTypeName);
            attribs = struct.getAttributes(map);
            mapToSerial(map);
        }
        catch(SQLException sqlexception)
        {
            throw new SQLException(sqlexception.getMessage());
        }
    }

    public ScSerialStruct(SQLData sqldata, Map map)
        throws SQLException
    {
        try
        {
            SQLTypeName = new String(sqldata.getSQLTypeName());
            Vector vector = new Vector();
            sqldata.writeSQL(new ScSQLOutputImpl(vector, map));
            attribs = vector.toArray();
            System.out.println("Dump: " + attribs[0] + "," + attribs[1]);
        }
        catch(SQLException sqlexception)
        {
            throw new SQLException(sqlexception.getMessage());
        }
    }

    public String getSQLTypeName()
        throws SQLException
    {
        return SQLTypeName;
    }

    public Object[] getAttributes()
        throws SQLException
    {
        return attribs;
    }

    public Object[] getAttributes(Map map)
        throws SQLException
    {
        return attribs;
    }

    private void mapToSerial(Map map)
        throws SQLException
    {
        try
        {
            for(int i = 0; i < attribs.length; i++)
                if(attribs[i] instanceof Struct)
                    attribs[i] = new ScSerialStruct((Struct)attribs[i], map);
                else
                if(attribs[i] instanceof SQLData)
                    attribs[i] = new ScSerialStruct((SQLData)attribs[i], map);
                else
                if(attribs[i] instanceof Blob)
                    attribs[i] = new ScSerialBlob((Blob)attribs[i]);
                else
                if(attribs[i] instanceof Clob)
                    attribs[i] = new ScSerialClob((Clob)attribs[i]);
                else
                if(attribs[i] instanceof Ref)
                    attribs[i] = new ScSerialRef((Ref)attribs[i]);
                else
                if(attribs[i] instanceof Array)
                    attribs[i] = new ScSerialArray((Array)attribs[i], map);

        }
        catch(SQLException sqlexception)
        {
            throw new SQLException(sqlexception.getMessage());
        }
    }

    private String SQLTypeName;
    private Object attribs[];
}
