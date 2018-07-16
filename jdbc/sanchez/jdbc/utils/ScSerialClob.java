package sanchez.jdbc.utils;

import java.io.*;
import java.sql.Clob;
import java.sql.SQLException;

import sanchez.jdbc.dbaccess.ScDBError;
import sanchez.base.ScBundle;
import sanchez.base.ScResourceKeys;

/**
 * A serializable mapping in the Java programming language of an SQL CLOB value.
 * <p>
 * The ScSerialClob class provides a constructor for creating an instance from a 
 * Clob object. Note that the Clob object should have brought the SQL CLOB value's 
 * data over to the client before a ScSerialClob object is constructed from it. 
 * The data of an SQL CLOB value can be materialized on the client as a stream of 
 * Unicode characters. 
 * </p>
 * <p>
 * ScSerialClob methods make it possible to get a substring from a ScSerialClob object or to locate the start of a pattern of characters.
 * </p>
 */
public class ScSerialClob
    implements Clob, Serializable, Cloneable
{
	public ScSerialClob(String s) 
	{
	    	buf = s.toCharArray();
		    len = buf.length;
		    origLen = len;
	}
	
	public ScSerialClob(char[] bytes)
	{
	    	len = bytes.length;
	    	origLen = len;
	    	buf =bytes;
	}
	
	/**
	 * Constructs a ScSerialClob object that is a serializable version of the given Clob object.
	 * 
	 * @param clob - the Clob object from which this ScSerialClob object is to be constructed.
	 * @throws SQLException -  if an error occurs.
	 */
	public ScSerialClob(Clob clob)
        throws SQLException
    {
        len = clob.length();
        origLen = len;
        buf = new char[(int)len];
        int i = 0;
        int j = 0;
        BufferedReader bufferedreader = new BufferedReader(clob.getCharacterStream());
        try
        {
            do
            {
                i = bufferedreader.read(buf, j, (int)(len - (long)j));
                j += i;
            } while(i > 0);
        }
        catch(IOException ioexception)
        {
        	Object[] obj = {ioexception.getMessage()};
            throw new SQLException(ScBundle.getMessage(ScResourceKeys.SerialClob,obj));
        }
    }

    public Reader getCharacterStream()
        throws SQLException
    {
        return new CharArrayReader(buf);
    }

   /**
    * Not supported; throws an exception if called.
    * 
    * @return a InputStream object containing this ScSerialClob object's data.
    * @throws SQLException -  which in turn calls UnsupportedOperationException, if called.
    */
    public InputStream getAsciiStream()
        throws SQLException
    {
        throw new UnsupportedOperationException();
    }

    /**
     * Returns a copy of the substring contained in this ScSerialClob object, starting at the given position and continuing for the specified number or characters.
     * 
     * @param l - the position of the first character in the substring to be copied; 
     * the first character of the SerialClob object is at position 0; must not be 
     * less than 0, and the sum of the starting position and the length of the 
     * substring must be less than the length of this ScSerialClob object.
     * @param i - the number of characters in the substring to be returned; 
     * must not be greater than the length of this ScSerialClob object, and the sum 
     * of the starting position and the length of the substring must be less than 
     * the length of this ScSerialClob object.
     * @return a String object containing a substring of this ScSerialClob object 
     * beginning at the given position and containing the specified number of 
     * consecutive characters.
     * @throws SQLException - if either of the arguments is out of bounds.
     */
    public String getSubString(long l, int i)
        throws SQLException
    {
        if(l < 0L || (long)i > len || l + (long)i > len)
        	throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_Arguments));
        else
            return new String(buf, (int)l, i);
    }

    /**
     * Retrieves the number of characters in this ScSerialClob object's array of characters.
     * 
     * @return a long indicating the length in characters of this ScSerialClob object's 
     * array of characters.
     * @throws SQLException - if an error occurs.
     */
    public long length()
        throws SQLException
    {
        return len;
    }


    /**
     * Returns the position in this ScSerialClob object where the given String 
     * object begins, starting the search at the specified position. This method 
     * returns -1 if the pattern is not found.
     * 
     * @param s - the String object for which to search.
     * @param l - the position in this ScSerialClob object at which to start the search; the first position is 1
     * @return the position at which the given String object begins, starting the search at the specified position; -1 if the given String object is not found or the starting position is out of bounds.
     * @throws SQLException - if an error occurs.
     */
    public long position(String s, long l)
        throws SQLException
    {
        if(l < 0L || l > len || l + (long)s.length() > len)
        	throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_Arguments));
        char ac[] = s.toCharArray();
        int i = (int)(l - 1L);
        long l2 = ac.length;
        if(l < 1L || l > len)
            return -1L;
        while((long)i < len) 
        {
            int j = 0;
            long l1 = i + 1;
            while(ac[j++] == buf[i++]) 
                if((long)j == l2)
                    return l1;
        }
        return -1L;
    }

    /**
     * Not supported; throws an exception if called.
     * 
     * @param clob - the Clob object for which to search.
     * @param l - the position in this ScSerialClob object at which to start the search.
     * @return the position at which the given Clob object begins in this 
     * SerialClob object, at or after the specified starting position.
     * @throws SQLException - which in turn calls UnsupportedOperationException, if called.
     */
    public long position(Clob clob, long l)
        throws SQLException
    {
        throw new UnsupportedOperationException();
    }

    public int setString(long l, String s)
        throws SQLException
    {
        return setString(l, s, 0, s.length());
    }

    public int setString(long l, String s, int i, int j)
        throws SQLException
    {
        int k = 0;
        if((long)j > origLen)
            throw new SQLException("Buffer is not sufficient to hold the value");
        String s1 = s.substring(i);
        char ac[] = s1.toCharArray();
        for(k = 0; k < j; k++)
            buf[(int)l + k] = ac[i + k];

        return k;
    }

    public OutputStream setAsciiStream(long l)
        throws SQLException
    {
        ByteArrayOutputStream bytearrayoutputstream = new ByteArrayOutputStream((int)l);
        return bytearrayoutputstream;
    }

    public Writer setCharacterStream(long l)
        throws SQLException
    {
        CharArrayWriter chararraywriter = new CharArrayWriter((int)l);
        return chararraywriter;
    }

    public void truncate(long l)
        throws SQLException
    {
        if(l > len)
        {
            throw new SQLException("Length more than what can be truncated");
        } else
        {
            len = l;
            buf = getSubString(0L, (int)len).toCharArray();
            return;
        }
    }

    char buf[];
    long len;
    long origLen;
}
