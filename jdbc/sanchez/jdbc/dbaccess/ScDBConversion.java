package sanchez.jdbc.dbaccess;

import java.sql.*;
import java.io.InputStream;
import java.math.BigDecimal;

public interface ScDBConversion {
    public static final short ASCII_CHARSET = 1;
    public static final short ISO_LATIN_1_CHARSET = 31;
    public static final short UNICODE_1_CHARSET = 870;
    public static final short UNICODE_2_CHARSET = 871;

    public abstract short getCharacterSet();

    public abstract byte[] StringToCharBytes(String string)
            throws SQLException;

    public abstract String CharBytesToString(byte ab[], int i)
            throws SQLException;

    public abstract byte[] StringToWorkbench(String string);

    public abstract int StringToWorkbench(String string, byte ab[], int i);

    public abstract byte[] StringToNetworkRep(String string)
            throws SQLException;

    public abstract byte[] BigDecimalToNumberBytes(BigDecimal bigDecimal)
            throws SQLException;

    public abstract BigDecimal NumberBytesToBigDecimal(byte ab[], int i)
            throws SQLException;

    public abstract byte NumberBytesToByte(byte ab[], int i)
            throws SQLException;

    public abstract byte[] ByteToNumberBytes(byte b);

    public abstract short NumberBytesToShort(byte ab[], int i)
            throws SQLException;

    public abstract byte[] ShortToNumberBytes(short s);

    public abstract int NumberBytesToInt(byte ab[], int i)
            throws SQLException;

    public abstract byte[] IntToNumberBytes(int i);

    public abstract long NumberBytesToLong(byte ab[], int i)
            throws SQLException;

    public abstract byte[] LongToNumberBytes(long i);

    public abstract float NumberBytesToFloat(byte ab[], int i);

    public abstract byte[] FloatToNumberBytes(float f);

    public abstract double NumberBytesToDouble(byte ab[], int i);

    public abstract byte[] DoubleToNumberBytes(double d)
            throws SQLException;

    public abstract byte[] BooleanToNumberBytes(boolean flag);

    public abstract boolean NumberBytesToBoolean(byte ab[], int i)
            throws SQLException;

    public abstract Date DateBytesToDate(byte ab[], int i);

    public abstract byte[] DateToDateBytes(Date date);

    public abstract Time DateBytesToTime(byte ab[], int i);

    public abstract byte[] TimeToDateBytes(Time time);

    public abstract Timestamp DateBytesToTimestamp(byte ab[], int i);

    public abstract byte[] TimestampToDateBytes(Timestamp timestamp);

    public abstract int requestLength(int i, int j);

    public abstract InputStream ConvertStream(InputStream inputStream, int i);

    public abstract int CHARBytesToJavaChars(byte ab[], int i, char ach[])
            throws SQLException;

    public abstract int JavaCharsToCHARBytes(char ach[], int i, byte ab[])
            throws SQLException;

    public abstract int JavaCharsToAsciiBytes(char ach[], int i, byte ab[]);

    public abstract int JavaCharsToUnicodeBytes(char ach[], int i, byte ab[]);

    public abstract int RAWBytesToHexChars(byte ab[], int i, char ach[]);

    public abstract int UnicodeBytesToJavaChars(byte ab[], int i, char ach[]);

    public abstract int AsciiBytesToJavaChars(byte ab[], int i, char ach[]);
}

