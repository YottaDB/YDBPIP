package sanchez.jdbc.utils;

import java.io.*;
import java.lang.reflect.Array;
import java.sql.Blob;
import java.sql.SQLException;

import sanchez.jdbc.dbaccess.ScDBError;
import sanchez.base.ScBundle;
import sanchez.base.ScResourceKeys;

/**
 * A serialized mapping in the Java programming language of an SQL BLOB value.
 * <p>
 * The ScSerialBlob class provides constructors for creating an instance from
 * a Blob object or a String object.
 * </p>
 * <p>
 * ScSerialBlob methods make it possible to make a copy of a SerialBlob object as
 * an array of bytes or as a stream. They also make it possible to locate a given
 * pattern of bytes.
 * </p>
 */
public class ScSerialBlob
        implements Blob, Serializable, Cloneable {

    @Override
    public InputStream getBinaryStream(long pos, long length) {
        return null;
    }

    @Override
    public void free() {

    }

    /**
     * Constructs a SerialBlob object that is a serialized version of the given Blob object.
     *
     * @param blob - the Blob object from which this SerialBlob object is to be constructed; cannot be null.
     * @throws SQLException - if an error occurs during serialization or if the Blob passed to this to this constructor is a null.
     */
    public ScSerialBlob(Blob blob)
            throws SQLException {
        len = blob.length();
        origLen = len;
        buf = blob.getBytes(0L, (int) len);
    }

    /**
     * Constructs a SerialBlob object that is a serialized version of the given byte array.
     *
     * @param s - the byte array containing the data for the Blob object to be serialized.
     */
    public ScSerialBlob(byte[] bytes) {
        len = bytes.length;
        origLen = len;
        buf = bytes;
    }

    /**
     * Retrieves the BLOB value designated by this Blob instance as a stream.
     *
     * @return a stream containing the BLOB data.
     * @throws SQLException - if there is an error accessing the BLOB value.
     */
    public InputStream getBinaryStream()
            throws SQLException {
        ByteArrayInputStream bytearrayinputstream = new ByteArrayInputStream(buf);
        return bytearrayinputstream;
    }

    /**
     * Retrieves all or part of the BLOB value that this Blob object represents, as an array of bytes. This byte array contains up to length consecutive bytes starting at position l.
     *
     * @param l - the ordinal position of the first byte in the BLOB value to be extracted; the first byte is at position 1
     * @param i - the number of consecutive bytes to be copied.
     * @return a byte array containing up to length consecutive bytes from the BLOB value designated by this Blob object, starting with the byte at position i.
     * @throws SQLException - if there is an error accessing the BLOB value.
     */
    public byte[] getBytes(long l, int i)
            throws SQLException {
        if ((long) i > len)
            i = (int) len;
        if (l < 0L || (long) i - l < 0L) {
            throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_Arguments));
        } else {
            Class class1 = buf.getClass();
            Class class2 = class1.getComponentType();
            Object obj = Array.newInstance(class2, (int) ((long) i - l));
            System.arraycopy(buf, (int) l, obj, 0, (int) ((long) i - l));
            return (byte[]) obj;
        }
    }

    /**
     * Returns the number of bytes in the BLOB value designated by this Blob object.
     *
     * @return length of the BLOB in bytes.
     * @throws SQLException - if there is an error accessing the length of the BLOB.
     */
    public long length()
            throws SQLException {
        return len;
    }

    /**
     * Retrieves the byte position in the BLOB value designated by this Blob object at which the blob pattern begins. The search begins at position l.
     *
     * @param blob - the Blob object designating the BLOB value for which to search.
     * @param l    - the position in the BLOB value at which to begin searching; the first position is 1.
     * @return the position at which the blob pattern begins, else -1
     * @throws SQLException - if there is an error accessing the BLOB value.
     */
    public long position(Blob blob, long l)
            throws SQLException {
        return position(blob.getBytes(0L, (int) blob.length()), l);
    }

    /**
     * Retrieves the byte position at which the specified byte array pattern begins within the BLOB value that this Blob object represents. The search for pattern begins at position l.
     *
     * @param abyte0 - the byte array for which to search.
     * @param l      - the position at which to begin searching; the first position is 1.
     * @return the position at which the pattern appears, else -1.
     * @throws SQLException - if there is an error accessing the BLOB.
     */
    public long position(byte abyte0[], long l)
            throws SQLException {
        int i = (int) (l - 1L);
        boolean flag = false;
        long l2 = abyte0.length;
        if (l < 0L || l > len)
            return -1L;
        while ((long) i < len) {
            int j = 0;
            long l1 = i + 1;
            while (abyte0[j++] == buf[i++])
                if ((long) j == l2)
                    return l1;
        }
        return -1L;
    }

    public int setBytes(long l, byte abyte0[])
            throws SQLException {
        return setBytes(l, abyte0, 0, abyte0.length);
    }

    public int setBytes(long l, byte abyte0[], int i, int j)
            throws SQLException {

        if ((long) j > origLen)
            throw new SQLException("Buffer is not sufficient to hold the value");
        int k;
        for (k = 0; k < j; k++)
            buf[(int) l + k] = abyte0[i + k];

        return k;
    }

    public OutputStream setBinaryStream(long l)
            throws SQLException {
        ByteArrayOutputStream bytearrayoutputstream = new ByteArrayOutputStream((int) ((long) buf.length - l));
        return bytearrayoutputstream;
    }

    public void truncate(long l)
            throws SQLException {
        if (l > len) {
            throw new SQLException("Length more than what can be truncated");
        } else {
            len = l;
            buf = getBytes(0L, (int) len);
            return;
        }
    }

    byte buf[];
    long len;
    long origLen;
}
