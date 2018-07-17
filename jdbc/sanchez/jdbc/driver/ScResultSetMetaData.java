/**
 * ScResulSetMetaData provides information about the types and
 * properties of the columns in a ResultSet object.
 *
 * @version 1.0  Spet. 28 1999
 * @author Quansheng Jia
 * @see ^ScResultSet
 */
package sanchez.jdbc.driver;

import java.sql.*;

import sanchez.jdbc.dbaccess.ScDBError;
import sanchez.jdbc.dbaccess.ScDBStatement;

/**
 * An object that can be used to find out about the types 
 * and properties of the columns in a ResultSet.
 */

public class ScResultSetMetaData implements ResultSetMetaData {
    ScConnection connection;
    ScStatement statement;

    @Override
    public boolean isWrapperFor(Class<?> iface) {
        return false;
    }

    @Override
    public <T> T unwrap(Class<T> iface) {
        return null;
    }

    public ScResultSetMetaData(ScDBStatement dBStatement) {

    }

    public ScResultSetMetaData(ScConnection c, ScStatement s) {
        connection = c;
        statement = s;
    }

    /**
     * Returns the number of columns in this ResultSet.
     *
     * @return the number of columns
     * @exception SQLException if a database access error occurs
     */
    public int getColumnCount() throws SQLException {
        connection.log("ResultSetMetaData.getColumnCount");
        return statement.i_ahHash.size();
    }

    /**
     * Indicates whether the column is automatically numbered, thus read-only.
     *
     * @param column the first column is 1, the second is 2, ...
     * @return true if so
     * @exception SQLException if a database access error occurs
     */
    public boolean isAutoIncrement(int column) throws SQLException {
        connection.log("ResultSetMetaData.isAutoIncrement");
        return false;
    }

    /**
     * Indicates whether a column's case matters.
     *
     * @param column the first column is 1, the second is 2, ...
     * @return true if so
     * @exception SQLException if a database access error occurs
     */
    public boolean isCaseSensitive(int column) throws SQLException {
        connection.log("ResultSetMetaData.isCaseSensitive");
        int type = getColumnType(column);
        if (type != 1 && type != 12 && type != -1)
            return false;
        else
            return true;
    }

    /**
     * Indicates whether the column can be used in a where clause.
     *
     * @param column the first column is 1, the second is 2, ...
     * @return true if so
     * @exception SQLException if a database access error occurs
     */
    public boolean isSearchable(int column) throws SQLException {
        connection.log("ResultSetMetaData.isSearchable");
        int type = getColumnType(column);
        if (type == -2 || type == -3 || type == -4 || type == -1)
            return false;
        else
            return true;
    }

    /**
     * Indicates whether the column is a cash value.
     *
     * @param column the first column is 1, the second is 2, ...
     * @return true if so
     * @exception SQLException if a database access error occurs
     */
    public boolean isCurrency(int column) throws SQLException {
        connection.log("ResultSetMetaData.isCurrency");
        if (getColumnType(column) != 3)
            return false;
        else
            return true;
    }

    /**
     * Indicates the nullability of values in the designated column.		
     *
     * @param column the first column is 1, the second is 2, ...
     * @return the nullability status of the given column; one of columnNoNulls,
     *          columnNullable or columnNullableUnknown
     * @exception SQLException if a database access error occurs
     */
    //FID,DI,LEN,DFT,TYP,DES,SIZ,REQ,DEC,NOD FROM
    public int isNullable(int column) throws SQLException {
        connection.log("ResultSetMetaData.isNullable");
        int index = getValidColumnIndex(column);
        if (statement.description[index][7].equalsIgnoreCase("0"))
            return columnNullable;
        else if (statement.description[index][7].equalsIgnoreCase("1"))
            return columnNoNulls;
        else return columnNullableUnknown;

    }

    /**
     * Column does not allow NULL values.
     */
    int columnNoNulls = 0;

    /**
     * Column allows NULL values.
     */
    int columnNullable = 1;

    /**
     * Nullability of column values is unknown.
     */
    int columnNullableUnknown = 2;

    /**
     * Indicates whether values in the column are signed numbers.
     *
     * @param column the first column is 1, the second is 2, ...
     * @return true if so
     * @exception SQLException if a database access error occurs
     */
    public boolean isSigned(int column) throws SQLException {
        connection.log("ResultSetMetaData.isSigned");
        return true;
    }

    /**
     * Indicates the column's normal max width in chars.
     *
     * @param column the first column is 1, the second is 2, ...
     * @return the normal maximum number of characters allowed as the width
     *          of the designated column
     * @exception SQLException if a database access error occurs
     */
    public int getColumnDisplaySize(int column) throws SQLException {
        connection.log("ResultSetMetaData.getColumnDisplaySize");
        int index = getValidColumnIndex(column);
        return Integer.parseInt(statement.description[index][2]);
    }

    /**
     * Gets the suggested column title for use in printouts and
     * displays.
     *
     * @param column the first column is 1, the second is 2, ...
     * @return the suggested column title
     * @exception SQLException if a database access error occurs
     */
    public String getColumnLabel(int column) throws SQLException {
        connection.log("ResultSetMetaData.getColumnLabel");
        return getColumnName(column);
    }

    /**
     * Gets a column's name.
     *
     * @param column the first column is 1, the second is 2, ...
     * @return column name
     * @exception SQLException if a database access error occurs
     */
    public String getColumnName(int column) throws SQLException {
        int index = getValidColumnIndex(column);
        connection.log("ResultSetMetaData.getColumnName:" + statement.description[index][1]);
        return statement.description[index][1];
    }

    /**
     * Gets a column's table's schema.
     *
     * @param column the first column is 1, the second is 2, ...
     * @return schema name or "" if not applicable
     * @exception SQLException if a database access error occurs
     */
    public String getSchemaName(int column) throws SQLException {
        connection.log("ResultSetMetaData.getSchemaName");
        return "";
    }

    /**
     * Gets a column's number of decimal digits.
     *
     * @param column the first column is 1, the second is 2, ...
     * @return precision
     * @exception SQLException if a database access error occurs
     */
    public int getPrecision(int column) throws SQLException {
        connection.log("ResultSetMetaData.getPrecision");
        int index = getValidColumnIndex(column);
        String s = statement.description[index][8];
        if (s.length() < 1) s = "0";
        return Integer.parseInt(s);
    }

    /**
     * Gets a column's number of digits to right of the decimal point.
     *
     * @param column the first column is 1, the second is 2, ...
     * @return scale
     * @exception SQLException if a database access error occurs
     */
    public int getScale(int column) throws SQLException {
        connection.log("ResultSetMetaData.getScale");
        return 0;
    }

    /**
     * Gets a column's table name. 
     *
     * @param column the first column is 1, the second is 2, ...
     * @return table name or "" if not applicable
     * @exception SQLException if a database access error occurs
     */
    public String getTableName(int column) throws SQLException {
        connection.log("ResultSetMetaData.getTableName");
        int index = getValidColumnIndex(column);
        return statement.description[index][0];
    }

    /**
     * Gets a column's table's catalog name.
     *
     * @param column the first column is 1, the second is 2, ...
     * @return column name or "" if not applicable.
     * @exception SQLException if a database access error occurs
     */
    public String getCatalogName(int column) throws SQLException {
        connection.log("ResultSetMetaData.getCatalogName");
        return "";
    }

    /**
     * Retrieves a column's SQL type.
     *
     * @param column the first column is 1, the second is 2, ...
     * @return SQL type from java.sql.Types
     * @exception SQLException if a database access error occurs
     * @see Types
     *
     * BIT 		=  -7;
     * TINYINT 	=  -6;
     * SMALLINT	=   5;
     * INTEGER 	=   4;
     * BIGINT 	=  -5;
     * FLOAT 	=   6;
     * REAL 	=   7;
     * DOUBLE 	=   8;
     * NUMERIC 	=   2;
     * DECIMAL	=   3;
     * CHAR		=   1;
     * VARCHAR 	=  12;
     * LONGVARCHAR 	=  -1;
     * DATE 	=  91;
     * TIME 	=  92;
     * TIMESTAMP =  93;
     * BINARY	=  -2;
     * VARBINARY 	=  -3;
     * LONGVARBINARY 	=  -4;
     * NULL		=   0;
     * CURRENCY = 99;
     */
    public int getColumnType(int column) throws SQLException {
        //connection.log("ResultSetMetaData.getColumnType");
        int index = getValidColumnIndex(column);
        int type = 0;
        int iLen;

        String sType = statement.description[index][4];
        String sLen = statement.description[index][2];
        iLen = Integer.parseInt(sLen);

        if (sType.compareTo("L") == 0) type = -7; //BIT
            //else if (sType.compareTo("B")==0) type = -2;  //BINARY
        else if (sType.compareTo("B") == 0) type = Types.BLOB;  //BLOB
        else if (sType.compareTo("D") == 0) type = 91;  //DATE
        else if (sType.compareTo("C") == 0) type = 92;  //TIME
            //else if (sType.compareTo("$")==0) type = 99;    //CURRENCY
            //99 is not a invalid sql data type and it is not accepted by SUN studio creator
        else if (sType.compareTo("$") == 0) type = 3;    //CURRENCY
        else if ((sType.compareTo("T") == 0) || (sType.compareTo("U") == 0) || (sType.compareTo("F") == 0)) {
            type = 12;  //VARCHAR
        } else if (sType.compareTo("M") == 0) type = java.sql.Types.LONGVARCHAR;
            //else if (sType.compareTo("M")==0) type = java.sql.Types.CLOB;
        else if (sType.compareTo("N") == 0) {
            String sDec = statement.description[index][8];
            if (sDec.length() < 1) sDec = "0";
            int iDec = Integer.parseInt(sDec);

            /*
             * @history 10/17/2003 thoniyilm
             * Originally this was INTEGER (4). This was changed to BIGINT
             * at some point of time. I don't know, why.
             * Changing back to INTEGER
             *
             * jiaq, change it back to BIGINT since INTEGER is limited to max 9 digits and does fit all
             * condition's requirement
             */
            //if (iDec<1) type = 4;//INTEGER    Max 9 digits  (code) //java.sql.Types.BIGINT;
            if (iDec < 1) type = java.sql.Types.BIGINT;
            else type = 8; //DOUBLE
        } else try {
            type = Integer.parseInt(sType);
        } catch (Exception e) {
            type = 1111;
        }
        connection.log("ResultSetMetaData.getColumnType " + type);
        return type;
    }

    /**
     * Retrieves a column's database-specific type name.
     *
     * @param column the first column is 1, the second is 2, ...
     * @return type name used by the database. If the column type is
     * a user-defined type, then a fully-qualified type name is returned.
     * @exception SQLException if a database access error occurs
     */
    public String getColumnTypeName(int column) throws SQLException {
        connection.log("ResultSetMetaData.getColumnTypeName");
        int type = getColumnType(column);

        switch (type) {
            case -14:
                return "CFILE";
            case -13:
                return "BFILE";
            case -10:
                return "REFCURSOR";
            case -8:
                return "ROWID";
            case -7:
                return "BIT";
            case -5:
                return "BIGINT";
            case -4:
                return "LONG RAW";
            case -3:
                return "RAW";
            case -2:
                return "BINARY";
            case 1:
                return "CHAR";
            case 2:
                return "NUMBER";
            case 3:
                return "DECIMAL";
            case 4:
                return "INTEGER";
            case 6:
                return "FLOAT";
            case 8:
                return "DOUBLE";
            case 12:
                return "VARCHAR2";
            case 91:
                return "DATE";
            case 92:
                return "TIME";
            case 93:
                return "TIMESTAMP";
            case 99:
                return "CURRENCY";
            case Types.BLOB:
                return "BLOB";
            case Types.CLOB:
                return "CLOB";
            case java.sql.Types.LONGVARCHAR:
                return "LONGVARCHAR";
            default:
                return null;
        }
    }

    /**
     * Indicates whether a column is definitely not writable.
     *
     * @param column the first column is 1, the second is 2, ...
     * @return true if so
     * @exception SQLException if a database access error occurs
     */
    public boolean isReadOnly(int column) throws SQLException {
        connection.log("ResultSetMetaData.isReadOnly");
        return false;
    }

    /**
     * Indicates whether it is possible for a write on the column to succeed.
     *
     * @param column the first column is 1, the second is 2, ...
     * @return true if so
     * @exception SQLException if a database access error occurs
     */
    public boolean isWritable(int column) throws SQLException {
        connection.log("ResultSetMetaData.isWritable");
        return true;
    }

    /**
     * Indicates whether a write on the column will definitely succeed.	
     *
     * @param column the first column is 1, the second is 2, ...
     * @return true if so
     * @exception SQLException if a database access error occurs
     */
    public boolean isDefinitelyWritable(int column) throws SQLException {
        connection.log("ResultSetMetaData.isDefinitelyWritable");
        return false;
    }

    //--------------------------JDBC 2.0-----------------------------------

    /**
     * JDBC 2.0
     *
     * <p>Returns the fully-qualified name of the Java class whose instances 
     * are manufactured if the method <code>ResultSet.getObject</code>
     * is called to retrieve a value
     * from the column.  <code>ResultSet.getObject</code> may return a subclass of the
     * class returned by this method.
     *
     * @return the fully-qualified name of the class in the Java programming
     *         language that would be used by the method
     * <code>ResultSet.getObject</code> to retrieve the value in the specified
     * column. This is the class name used for custom mapping.
     * @exception SQLException if a database access error occurs
     */
    //to be fixed jiaq
    public String getColumnClassName(int column) throws SQLException {
        connection.log("ResultSetMetaData.getColumnClassName");
        int type = getColumnType(column);

        switch (type) {
            case -7:
                return "java.lang.Boolean";
            case -2:
                return "byte[]";
            case 91:
                return "java.sql.Timestamp";
            case 4:
                return "java.lang.Integer";
            case -5:
                return "java.lang.Integer";
            case 8:
                return "java.lang.Double";
            case 2:
                return "java.lang.BigDecimal";
            case 3:
                return "java.lang.BigDecimal";
            case 92:
                return "java.sql.Timestamp";
            case 6:
                return "java.math.Float";
            case 99:
                return "Profile.CURRENCY";
            case 1:
                return "java.lang.String";
            case 12:
                return "java.lang.String";
            case -1:
                return "java.lang.Integer";
            case -3:
                return "java.lang.String";
            case -4:
                return "java.lang.String";
            case 93:
                return "java.sql.Timestamp";
            case -8:
                return "ROWID";
            case -10:
                return "REFCURSOR";
            case -11:
                return "java.sql.Blob";
            case -12:
                return "java.sql.Clob";
            case -13:
                return "BFILE";
            case -14:
                return "CFILE";
            default:
                return "java.lang.String";
        }
    }

    private int getValidColumnIndex(int column)
            throws SQLException {
        int index = column - 1;
        if (index < 0 || index >= statement.i_ahHash.size())
            ScDBError.check_error(-3, "getValidColumnIndex");
        return index;
    }
}

 
