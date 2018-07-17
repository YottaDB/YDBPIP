package sanchez.jdbc.utils;

import java.io.Serializable;
import java.net.URL;
import java.sql.*;
import java.util.Map;

// Referenced classes of package javax.sql.rowset.serial:
//            SerialStruct, SerialBlob, SerialClob, SerialDatalink, 
//            SerialJavaObject, SerialException

public class ScSerialArray
        implements Array, Serializable, Cloneable {

    @Override
    public void free() {

    }

    public ScSerialArray(Array array, Map map)
            throws SQLException {
        elements = (Object[]) array.getArray(map);
        baseType = getBaseType();
        baseTypeName = getBaseTypeName();
        len = elements.length;
        switch (baseType) {
            default:
                break;

            case 2002:
                for (int i = 0; i < len; i++)
                    elements[i] = new ScSerialStruct((Struct) elements[i], map);

                break;

            case 2003:
                for (int j = 0; j < len; j++)
                    elements[j] = new ScSerialArray((Array) elements[j], map);

                break;

            case 2004:
                for (int k = 0; k < len; k++)
                    elements[k] = new ScSerialBlob((Blob) elements[k]);

                break;

            case 2005:
                for (int l = 0; l < len; l++)
                    elements[l] = new ScSerialClob((Clob) elements[l]);

                break;

            case 70: // 'F'
                for (int i1 = 0; i1 < len; i1++)
                    elements[i1] = new ScSerialDatalink((URL) elements[i1]);

                // fall through

            case 2000:
                for (int j1 = 0; j1 < len; j1++)
                    elements[j1] = new ScSerialJavaObject((URL) elements[j1]);

                break;
        }
    }

    public ScSerialArray(Array array)
            throws SQLException {
        elements = (Object[]) array.getArray();
        baseType = getBaseType();
        baseTypeName = getBaseTypeName();
        len = elements.length;
        switch (baseType) {
            default:
                break;

            case 2004:
                for (int i = 0; i < len; i++)
                    elements[i] = new ScSerialBlob((Blob) elements[i]);

                break;

            case 2005:
                for (int j = 0; j < len; j++)
                    elements[j] = new ScSerialClob((Clob) elements[j]);

                break;

            case 70: // 'F'
                for (int k = 0; k < len; k++)
                    elements[k] = new ScSerialDatalink((URL) elements[k]);

                // fall through

            case 2000:
                for (int l = 0; l < len; l++)
                    elements[l] = new ScSerialJavaObject((URL) elements[l]);

                break;
        }
    }

    public Object getArray()
            throws SQLException {
        Object aobj[] = new Object[len];
        System.arraycopy(((Object) (elements)), 0, ((Object) (aobj)), 0, len);
        return ((Object) (aobj));
    }

    public Object getArray(Map map)
            throws SQLException {
        Object aobj[] = new Object[len];
        System.arraycopy(((Object) (elements)), 0, ((Object) (aobj)), 0, len);
        return ((Object) (aobj));
    }

    public Object getArray(long l, int i)
            throws SQLException {
        Object aobj[] = new Object[i];
        System.arraycopy(((Object) (elements)), (int) l, ((Object) (aobj)), 0, i);
        return ((Object) (aobj));
    }

    public Object getArray(long l, int i, Map map)
            throws SQLException {
        Object aobj[] = new Object[i];
        System.arraycopy(((Object) (elements)), (int) l, ((Object) (aobj)), 0, i);
        return ((Object) (aobj));
    }

    public int getBaseType()
            throws SQLException {
        return baseType;
    }

    public String getBaseTypeName()
            throws SQLException {
        return baseTypeName;
    }

    public ResultSet getResultSet(long l, int i)
            throws SQLException {
        throw new UnsupportedOperationException();
    }

    public ResultSet getResultSet(Map map)
            throws SQLException {
        throw new UnsupportedOperationException();
    }

    public ResultSet getResultSet()
            throws SQLException {
        throw new UnsupportedOperationException();
    }

    public ResultSet getResultSet(long l, int i, Map map)
            throws SQLException {
        throw new UnsupportedOperationException();
    }

    private Object elements[];
    private int baseType;
    private String baseTypeName;
    private int len;
}
