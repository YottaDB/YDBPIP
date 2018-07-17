package sanchez.jdbc.utils;

import java.io.InputStream;
import java.io.Reader;
import java.math.BigDecimal;
import java.net.URL;
import java.sql.*;
import java.util.Map;
import java.util.Vector;

// Referenced classes of package javax.sql.rowset.serial:
//            SerialStruct, SerialRef, SerialBlob, SerialClob, 
//            SerialArray

public class ScSQLOutputImpl
        implements SQLOutput {

    public ScSQLOutputImpl(Vector vector, Map map1) {
        attribs = vector;
        map = map1;
    }

    public void writeString(String s)
            throws SQLException {
        attribs.add(s);
    }

    public void writeBoolean(boolean flag)
            throws SQLException {
        attribs.add(new Boolean(flag));
    }

    public void writeByte(byte byte0)
            throws SQLException {
        attribs.add(new Byte(byte0));
    }

    public void writeShort(short word0)
            throws SQLException {
        attribs.add(new Short(word0));
    }

    public void writeInt(int i)
            throws SQLException {
        attribs.add(new Integer(i));
    }

    public void writeLong(long l)
            throws SQLException {
        attribs.add(new Long(l));
    }

    public void writeFloat(float f)
            throws SQLException {
        attribs.add(new Float(f));
    }

    public void writeDouble(double d)
            throws SQLException {
        attribs.add(new Double(d));
    }

    public void writeBigDecimal(BigDecimal bigdecimal)
            throws SQLException {
        attribs.add(bigdecimal);
    }

    public void writeBytes(byte abyte0[])
            throws SQLException {
        attribs.add(abyte0);
    }

    public void writeDate(Date date)
            throws SQLException {
        attribs.add(date);
    }

    public void writeTime(Time time)
            throws SQLException {
        attribs.add(time);
    }

    public void writeTimestamp(Timestamp timestamp)
            throws SQLException {
        attribs.add(timestamp);
    }

    public void writeCharacterStream(Reader reader)
            throws SQLException {
    }

    public void writeAsciiStream(InputStream inputstream)
            throws SQLException {
    }

    public void writeBinaryStream(InputStream inputstream)
            throws SQLException {
    }

    public void writeObject(SQLData sqldata)
            throws SQLException {
        if (sqldata == null) {
            attribs.add(sqldata);
            return;
        } else {
            attribs.add(new ScSerialStruct(sqldata, map));
            return;
        }
    }

    public void writeRef(Ref ref)
            throws SQLException {
        if (ref == null) {
            attribs.add(ref);
            return;
        } else {
            attribs.add(new ScSerialRef(ref));
            return;
        }
    }

    public void writeBlob(Blob blob)
            throws SQLException {
        if (blob == null) {
            attribs.add(blob);
            return;
        } else {
            attribs.add(new ScSerialBlob(blob));
            return;
        }
    }

    public void writeClob(Clob clob)
            throws SQLException {
        if (clob == null) {
            attribs.add(clob);
            return;
        } else {
            attribs.add(new ScSerialClob(clob));
            return;
        }
    }

    public void writeStruct(Struct struct)
            throws SQLException {
        ScSerialStruct serialstruct = new ScSerialStruct(struct, map);
        attribs.add(serialstruct);
    }

    public void writeArray(Array array)
            throws SQLException {
        if (array == null) {
            attribs.add(array);
            return;
        } else {
            attribs.add(new ScSerialArray(array, map));
            return;
        }
    }

    public void writeURL(URL url)
            throws SQLException {
        throw new SQLException("Operation not supported");
    }

    @Override
    public void writeSQLXML(SQLXML x) {

    }

    @Override
    public void writeRowId(RowId x) {

    }

    @Override
    public void writeNClob(NClob x) {

    }

    @Override
    public void writeNString(String x) {

    }

    private Vector attribs;
    private Map map;
}
