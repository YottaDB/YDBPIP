package sanchez.him_pa.utils;

/**
 * ScMSQLFormat is used to format SQL statement
 * variable to host vairable
 * SQL statement to upper case
 *
 * @version 1.0  August 8 1999
 * @author Quansheng Jia
 * @see ScMSQLManagerHim,ScProfileFORM
 */

import java.util.NoSuchElementException;
import java.util.StringTokenizer;

import sanchez.him_pa.utils.ScStringTokenizer;

import java.util.Vector;
import java.util.Enumeration;
import java.util.Hashtable;
import java.sql.SQLException;

import sanchez.jdbc.dbaccess.ScDBError;
import sanchez.utils.ScMatrix;

import java.util.HashMap;

/**
 *  ScMSQLFormat is used to format SQL statement variable to host
 *  variable and SQL statement to upper case
 */
public class ScMSQLFormat extends sanchez.base.ScObject {
    public static int iRowCount = 0;

    /**
     * Default Contructor
     */
    public ScMSQLFormat() {
    }

    /**
     * Convert variable into host variable; SQL statement to upper case
     * @param X varibale to be converted 
     */
    public static String host(String X) {
        String ss1 = X.toUpperCase().trim();
        if (ss1.startsWith("OPEN") && ss1.indexOf("PROCEDURE") > 0
                || ss1.startsWith("CREATE PROCEDURE * AS")
                || ss1.startsWith("EXECUTE")
                || ss1.startsWith("BUFFER") && ss1.indexOf("EXECUTE") > 0
                ) return X;

        String wrd = "";
        String chrtbl = ",><=() ";
        Vector vHostVar = new Vector();
        int i, j = 1, a, b;
        Integer iTemp = null;
        StringBuffer sTemp = new StringBuffer();
        String sHost = "";
        String ss;
        String piece = "";

        X = noScheme(X);
        int fileNum = fileCount(X);

        ScStringTokenizer sToken = new ScStringTokenizer(X, chrtbl, true);

        while (wrd != "end!") {
            wrd = atomHost(sToken);
            if (wrd == "end!") break;
            int dotIndex = wrd.indexOf(".");
            if ((fileNum == 1) && (dotIndex > 0) && (!wrd.substring(dotIndex + 1, wrd.length()).equalsIgnoreCase("NEXTVAL"))) {

                ss = wrd.substring(wrd.indexOf(".") + 1, wrd.length());
                i = sToken.getcurrentPosition();
                X = X.substring(0, i - wrd.length()) + ss + X.substring(i, X.length());
                sToken.setStr(X);
                sToken.setCurrentPos(i - wrd.length() + ss.length());
            }

            if ((wrd.indexOf("<") >= 0) || (wrd.indexOf(">") >= 0) || (wrd.indexOf("=") >= 0)) {

                wrd = atomHost(sToken);
                if ((wrd.indexOf("<") >= 0) || (wrd.indexOf(">") >= 0) || (wrd.indexOf("=") >= 0))
                    wrd = atomHost(sToken);

                if ((wrd.charAt(0) == '\'') || (isDigit(wrd))) {
                    if (wrd.charAt(0) == '\'') {
                        int iLen = wrd.length();
                        if ((iLen == 1) || (wrd.charAt(wrd.length() - 1) != '\'') || ((wrd.charAt(wrd.length() - 1) == '\'') && (wrd.charAt(wrd.length() - 2) == '\'') && (wrd.compareTo("''") != 0))) {
                            while (sToken.hasMoreTokens()) {
                                wrd = wrd + sToken.nextToken();
                                if ((wrd.charAt(wrd.length() - 1) == '\'') && (wrd.charAt(wrd.length() - 2) != '\''))
                                    break;
                            }//while
                        }//if literal
                    }

                    i = sToken.getcurrentPosition();
                    iTemp = new Integer(j++);
                    sHost = ":C" + iTemp.toString();

                    X = X.substring(0, i - wrd.length()) + sHost + X.substring(i, X.length());
                    sToken.setStr(X);
                    sToken.setCurrentPos(i - wrd.length() + sHost.length());

                    if (wrd.indexOf("'.") == 0) {
                        wrd = "'" + wrd.substring(2, wrd.length());
                    }
                    vHostVar.addElement(wrd);

                }//literal and digit
            }//if
        }//while

        if (vHostVar.isEmpty()) return space(X);
        else {
            Enumeration e = vHostVar.elements();
            j = 1;
            StringBuffer sBuffer = new StringBuffer("/USING=(");
            String sTempStr = new String();
            while (e.hasMoreElements()) {
                iTemp = new Integer(j++);
                String sValue = (String) e.nextElement();

                if (iTemp.equals(new Integer(1))) sBuffer.append("C" + iTemp.toString() + "=" + sValue);
                else sBuffer.append(",C" + iTemp.toString() + "=" + sValue);
            }

            sBuffer = sBuffer.append(')').insert(0, space(X) + "\t");
            return sBuffer.toString();
        }
    }

    /**
     * Checks for General category "Lo" in the Unicode specification in a given String
     * @param a_sString String to be checked
     * @return true for presence of General category "Lo" false otherwise.
     */

    private static boolean isOtherLetter(String a_sString) {
        int j = a_sString.length();
        byte[] a_bByte = new byte[j];
        for (int i = 0; i < j; i++) {
            int type = Character.getType(a_sString.charAt(i));
            if (type == java.lang.Character.OTHER_LETTER) return true;
            if (ScUnicodeBlock.inList(a_sString.charAt(i))) return true;
        }
        return false;
    }

    /**
     * Format INSERT SQL statement
     * @param String to be formatted
     */
    public static String InsertHostConv(String X) {
        X = noScheme(X);

        String wrd = "";
        String chrtbl = ", ";
        Vector vHostVar = new Vector();
        int i, j = 1;
        Integer iTemp = null;
        StringBuffer sTemp = new StringBuffer();
        String sHost = "";
        int iIndex = X.toUpperCase().indexOf("VALUES");
        if (iIndex < 0) return X;
        iIndex = X.toUpperCase().indexOf('(', iIndex);
        if (iIndex < 0) return X;
        String sFirstPiece = X.substring(0, iIndex);
        String sLastPiece = X.substring(iIndex + 1, X.length() - 1);

        ScStringTokenizer sToken = new ScStringTokenizer(sLastPiece, chrtbl, true);
        int iSeq = 0;

        while (wrd != "end!") {
            wrd = atomHost(sToken);
            if (wrd == "end!") break;
            if ((wrd.indexOf(",") == 0) || (iSeq == 0)) {
                if (wrd.indexOf(",") == 0) wrd = atomHost(sToken);
                if ((wrd.charAt(0) == '\'') || (isDigit(wrd))) {
                    if (wrd.charAt(0) == '\'') {
                        if ((wrd.length() == 1) || (wrd.charAt(wrd.length() - 1) != '\'') || ((wrd.charAt(wrd.length() - 1) == '\'') && (wrd.charAt(wrd.length() - 2) == '\'') && (wrd.compareTo("''") != 0))) {
                            while (sToken.hasMoreTokens()) {
                                wrd = wrd + sToken.nextToken();
                                if ((wrd.charAt(wrd.length() - 1) == '\'') && (wrd.charAt(wrd.length() - 2) != '\''))
                                    break;
                            }//while
                        }//if
                    }//if literal

                    i = sToken.getcurrentPosition();
                    iTemp = new Integer(j++);
                    sHost = ":C" + iTemp.toString();
                    sLastPiece = sLastPiece.substring(0, i - wrd.length()) + sHost + sLastPiece.substring(i, sLastPiece.length());
                    sToken.setStr(sLastPiece);
                    sToken.setCurrentPos(i - wrd.length() + sHost.length());
                    if (wrd.indexOf("'.") == 0) {
                        wrd = "'" + wrd.substring(2, wrd.length());
                    }
                    vHostVar.addElement(wrd);
                }//if digital or literal
            }//

            iSeq++;
        }//while

        if (vHostVar.isEmpty()) return space(X);
        else {
            Enumeration e = vHostVar.elements();
            j = 1;
            StringBuffer sBuffer = new StringBuffer("/USING=(");
            String sTempStr = new String();
            while (e.hasMoreElements()) {
                iTemp = new Integer(j++);
                String sValue = (String) e.nextElement();

                if (iTemp.equals(new Integer(1))) sBuffer.append("C" + iTemp.toString() + "=" + sValue);
                else sBuffer.append(",C" + iTemp.toString() + "=" + sValue);
            }
            sBuffer = sBuffer.append(')').insert(0, space(sFirstPiece + " (" + sLastPiece + ")") + "\t");

            return sBuffer.toString();
        }
    }

    /**
     * Returns the first non Empty String from the ScStringTokenizer 
     * @param Token The ScStringTokenizer to be searched
     * @return the First Non empty string or "end!" if ScStringTokenizer
     * does not contain any non empty string 
     */
    private static String atomHost(ScStringTokenizer Token) {
        String sTemp = new String();
        while (Token.hasMoreTokens()) {
            sTemp = Token.nextToken();
            if (sTemp.trim().length() < 1) continue;
            return sTemp;
        }
        return "end!";
    }

    /**
     * Checks whether a String value is Numeric or not
     * @param sWord the String to be checked
     * @return boolean true for numeric string false otherwise
     */
    private static boolean isDigit(String sWord) {
        try {
            Float.valueOf(sWord);
        } catch (NumberFormatException nfe) {

            return false;
        }
        return true;

    }

    /**
     * Clears a SQL String , Creating a Single Spaced SQL String from the 
     * input String     
     * @param sStatement the Statement String
     * @return The Single Spaced Cleared SQL String
     */
    private static String space(String sStatement) {
        int iSpaceCount = 0;
        sStatement = sStatement.trim().replace('\n', ' ').replace('\r', ' ');

        StringBuffer sBuffer = new StringBuffer();
        for (int j = 0; j < sStatement.length(); j++) {
            if (sStatement.charAt(j) != ' ') {
                sBuffer.append(sStatement.charAt(j));
                continue;
            } else if (sStatement.charAt(j) == ' ') {
                if (sStatement.charAt(j - 1) == ' ') continue;
                sBuffer.append(sStatement.charAt(j));
            }
        }
        String ss = sBuffer.toString();
        sBuffer = new StringBuffer();
        String s = "";

        StringTokenizer parser = new StringTokenizer(ss, ",><=", true);
        while (parser.hasMoreTokens()) {
            s = ((String) parser.nextToken()).trim();
            sBuffer.append(s);
        }

        s = sBuffer.toString();

        if ((s.startsWith("CREATE TABLE")) || (s.startsWith("ALTER TABLE"))) {
            int i1 = s.indexOf("TABLE");
            int i2 = s.indexOf(" ", i1 + 2);
            String fileName = s.substring(i1 + 1, i2);

            if (fileName.indexOf(".") > 0) {
                fileName = fileName.substring(fileName.indexOf(".") + 1, fileName.length()).trim();
                String s1 = s.substring(0, i1 + 6).trim();
                String s2 = s.substring(i2, s.length()).trim();
                s = s1 + " " + fileName + " " + s2;
            }
        }

        int whereIndex = s.toUpperCase().indexOf("WHERE");
        if (whereIndex < 0)
            return asClear(s.toUpperCase());
        int likeIndex = s.toUpperCase().indexOf("LIKE", whereIndex + 5);
        if (likeIndex < 0)
            return asClear(s.toUpperCase());
        else {
            sBuffer = new StringBuffer();

            int offset, oldoffset, where, a1;
            String sValue;
            for (offset = 0, oldoffset = 0; ((where = s.toUpperCase().indexOf("LIKE", offset)) >= 0); offset = where + 1) {
                if (where >= 0) {
                    a1 = s.indexOf('\'', where + 6);
                    if (a1 < 0) a1 = s.length();
                    sValue = s.substring(where + 5, a1);

                    sBuffer = sBuffer.append(s.substring(oldoffset, where + 5).toUpperCase()).append(sValue);
                    where = a1;
                    oldoffset = a1;
                }
            }
            sBuffer.append(s.substring(oldoffset, s.length()).toUpperCase());
            s = sBuffer.toString();
        }
        return asClear(s);
    }

    /**
     * 	This function cleans up the SQL statement. When cleaning up it also
     * 	cleans up the JOINs from the SQL Statement. A check is included in the
     * 	part where the code checks for the tables. This change looks for JOIN
     * 	in the SQL statements and if there's any, then that part won't be cleaned up.
     *  It also cleans up the ORDER BY when a WHERE clause is not specified
     * 	in the SQL. Changes are made to check for ORDER and GROUP, when a WHERE
     * 	clause is not specified. Assumption is that ORDER and GROUP are keywords
     *
     * @param X SQL String to be cleaned
     * @return The Cleaned String
     */
    private static String asClear(String X) {
        int iGroup = -1, iOrder = -1;

        if (X.trim().indexOf("OPEN CURSOR") != 0) return X;

        int iSelect = X.indexOf(" SELECT ");
        if (iSelect < 0) return X;
        int iFrom = X.lastIndexOf(" FROM ");
        if (iFrom < 0) return X;
        int iWhere = X.lastIndexOf(" WHERE ");

        if ((iFrom > iWhere) && (iWhere > 0))
            iFrom = X.lastIndexOf(" FROM ", iWhere);

        String pieceOne = X.substring(0, iSelect + 8).trim();
        String pieceColumns = "";
        if (iFrom >= iSelect + 8)
            pieceColumns = X.substring(iSelect + 8, iFrom).trim();
        String pieceTables;
        String pieceWhere = "";
        String whereText = " WHERE ";

        if (iWhere < 0) {
            if ((iOrder = X.lastIndexOf(" ORDER ")) > 0) {
                iWhere = iOrder;
                whereText = " ORDER ";
            }
            iGroup = X.lastIndexOf(" GROUP ");
            if (((iGroup < iOrder) || (iOrder < 0)) && (iGroup > 0)) {
                iWhere = iGroup;
                whereText = " GROUP ";
            }
        }

        if (iWhere > 0) {
            pieceWhere = X.substring(iWhere + 7).trim();
            pieceTables = X.substring(iFrom + 6, iWhere).trim();
        } else pieceTables = X.substring(iFrom + 6).trim();

        StringBuffer ss = new StringBuffer();
        String wrdx, sTemp, sOtheName, realName;
        int i, i1;
        HashMap map = new HashMap();
        StringTokenizer parser;

        if (pieceTables.indexOf(" ") > 0) {
            ss = new StringBuffer();
            parser = new StringTokenizer(pieceTables, ",", true);
            while (parser.hasMoreElements()) {
                wrdx = (String) parser.nextElement();
                i = wrdx.indexOf(" ");
                if (i > 0) {
                    sOtheName = wrdx.substring(i);
                    if ((sOtheName.indexOf("JOIN") < 0) && (sOtheName.indexOf(" ON ") < 0)) {
                        wrdx = wrdx.substring(0, i).trim();
                        map.put(sOtheName.trim(), wrdx);
                    }
                }
                ss.append(wrdx);
            }
            pieceTables = ss.toString();
        }

        if (map.size() > 0) {
            //columns clear up
            ss = new StringBuffer();
            parser = new StringTokenizer(pieceColumns, ",", true);
            while (parser.hasMoreElements()) {
                wrdx = (String) parser.nextElement();
                i = wrdx.lastIndexOf(" AS ");
                if (i > 0) {
                    String s3 = wrdx.substring(0, i).trim();
                    int iDot = s3.indexOf(".");

                    if (iDot > 0) {
                        sOtheName = s3.substring(0, iDot);
                        realName = (String) map.get(sOtheName);
                        if (realName != null)
                            s3 = realName + s3.substring(iDot);
                    }
                    ss.append(s3);
                } else if (wrdx.indexOf(".") > 0) {
                    int iDot = wrdx.indexOf(".");
                    sOtheName = wrdx.substring(0, iDot).trim();
                    realName = (String) map.get(sOtheName);
                    if (realName != null)
                        wrdx = realName + wrdx.substring(iDot);
                    ss.append(wrdx);
                } else ss.append(wrdx);
            }
            if (ss.length() > 0)
                pieceColumns = ss.toString();

            //where clear up
            if (iWhere > 0) {
                ss = new StringBuffer();
                parser = new StringTokenizer(pieceWhere, ",><=() ", true);
                while (parser.hasMoreElements()) {
                    wrdx = (String) parser.nextElement();
                    i = wrdx.indexOf(".");
                    if (i > 0) {
                        sOtheName = wrdx.substring(0, i).trim();
                        realName = (String) map.get(sOtheName);
                        if (realName != null) wrdx = realName + wrdx.substring(i);
                    }
                    if (wrdx.equals("AND") || wrdx.equals("OR")) wrdx = " " + wrdx + " ";
                    ss.append(wrdx);
                }
                pieceWhere = ss.toString();

                StringBuffer sBuffer = new StringBuffer();
                for (int j = 0; j < pieceWhere.length(); j++) {
                    if (pieceWhere.charAt(j) != ' ') {
                        sBuffer.append(pieceWhere.charAt(j));
                        continue;
                    }//if
                    else if (pieceWhere.charAt(j) == ' ') {
                        if (pieceWhere.charAt(j - 1) == ' ') continue;
                        sBuffer.append(pieceWhere.charAt(j));
                    }//else if
                }
                pieceWhere = sBuffer.toString();
            }
        }

        ss = new StringBuffer();
        ss = ss.append(pieceOne).append(" ").append(pieceColumns).append(" FROM ").append(pieceTables);
        if (iWhere > 0) {
            ss = ss.append(whereText).append(pieceWhere);
        }
        map = null;
        return X = ss.toString();
    }

    /**
     * PROFILE/Aynware does support schema, This method gets rid of
     * schema from SQL statement
     * @param X the inputString
     * @return The schema stripped String
     */
    private static String noScheme(String X) {
        StringTokenizer parser = new StringTokenizer(X, ", ", true);
        StringBuffer ss = new StringBuffer();
        String wrdx = new String();
        while (parser.hasMoreElements()) {
            wrdx = (String) parser.nextElement();
            if (wrdx.toLowerCase().indexOf("profileschema.") == 0) {
                wrdx = wrdx.substring(14, wrdx.length());
                ss.append(wrdx);
            } else if (wrdx.indexOf("..") == 0) {
                wrdx = wrdx.substring(2, wrdx.length());
                ss.append(wrdx);
            } else ss.append(wrdx);
        }
        return ss.toString();
    }

    /**
     * Returns the columns selected in the input quuery string,* if
     * select * is used
     * @param a_sQueryStatement The Query Statement
     * @return The Hashtable containing the column names,
     *         '*' if 'Select * from <table name>' is used
     */

    public static Hashtable parseQuery(String a_sQueryStatement) {

        Hashtable ahHash = new Hashtable();
        int i = 1;

        String aTemp = a_sQueryStatement.trim().toUpperCase();


        aTemp = aTemp.substring(0, aTemp.indexOf("FROM"));
        aTemp = aTemp.substring(6, aTemp.length());
        if (aTemp.trim().indexOf("DISTINCT") == 0) {
            aTemp = aTemp.substring(9, aTemp.length());
        } else if (aTemp.trim().indexOf("ALL") == 0) {
            aTemp = aTemp.substring(4, aTemp.length());
        }

        if (aTemp.trim().compareTo("*") == 0)
            return ahHash;

        StringTokenizer parser = new StringTokenizer(aTemp.trim(), ",");


        while (parser.hasMoreElements()) {
            ahHash.put(new Integer(i++), new String((String) parser.nextElement()).trim());
        }

        return ahHash;
    }

    /**
     * Converts variable to Host variable
     * @param sqlStatement The Variable to be converted
     * @return the host Variable
     */
    private static int fileCount(String sqlStatement) {
        String aTemp = sqlStatement.trim().toUpperCase();
        String a_sFileName = new String();
        if ((aTemp.indexOf("SELECT") < 0) && (aTemp.indexOf("UPDATE") < 0)) return 1;

        if ((aTemp.indexOf("UPDATE") >= 0) && (aTemp.indexOf("SELECT") >= 0)) return 2;

        if (aTemp.indexOf("UPDATE") >= 0) {
            a_sFileName = aTemp.substring(aTemp.indexOf("SET") + 3, aTemp.length()).trim();
            if (a_sFileName.indexOf("WHERE") > 0) a_sFileName = a_sFileName.substring(0, a_sFileName.indexOf("WHERE"));
        } else if (aTemp.indexOf("SELECT ") >= 0) {
            if (aTemp.indexOf("SELECT ", aTemp.indexOf("SELECT ")) >= 0) return 2;
            // get file names
            // group by,having, order by, for update
            if (aTemp.indexOf("WHERE") > 0)
                a_sFileName = aTemp.substring(aTemp.indexOf("FROM") + 4, aTemp.indexOf("WHERE"));
            else if ((aTemp.indexOf("WHERE") < 0) && (aTemp.indexOf("ORDER BY") < 0) && (aTemp.indexOf("GROUP BY") > 0)) {
                a_sFileName = aTemp.substring(aTemp.indexOf("FROM") + 4, aTemp.indexOf("GROUP BY"));
            } else if ((aTemp.indexOf("WHERE") < 0) && (aTemp.indexOf("GROUP BY") < 0) && (aTemp.indexOf("ORDER BY") > 0)) {
                a_sFileName = aTemp.substring(aTemp.indexOf("FROM") + 4, aTemp.indexOf("ORDER BY"));
            } else if ((aTemp.indexOf("WHERE") < 0) && (aTemp.indexOf("GROUP BY") > 0) && (aTemp.indexOf("ORDER BY") > 0)) {
                if (aTemp.indexOf("GROUP BY") < aTemp.indexOf("ORDER BY")) {
                    a_sFileName = aTemp.substring(aTemp.indexOf("FROM") + 4, aTemp.indexOf("GROUP BY"));
                } else a_sFileName = aTemp.substring(aTemp.indexOf("FROM") + 4, aTemp.indexOf("ORDER BY"));
            } else {
                try {
                    a_sFileName = aTemp.substring(aTemp.indexOf("FROM") + 4, aTemp.length());
                } catch (Exception e) {
                    return 1;
                }
            }
        }//end of select

        StringTokenizer parser = new StringTokenizer(a_sFileName, ",", false);
        return parser.countTokens();

    }

    /**
     * Creates a host describe statement of the Table Name(s) for the input query
     * @param a_sQueryStatement Input Query
     * @return Host describe statement
     * @throws Exception
     * @throws SQLException If the input query is invalid
     */

    public static String describeSql(String a_sQueryStatement)
            throws Exception, SQLException {
        String aTemp = a_sQueryStatement.trim().toUpperCase();
        String a_sFileName = new String();
        if (aTemp.indexOf("SELECT ") != 0)
            ScDBError.check_error(80, "ScMSQLFormat");

        // get file names
        // group by,having, order by, for update
        if (aTemp.indexOf("WHERE") > 0) {
            a_sFileName = aTemp.substring(aTemp.indexOf("FROM") + 4, aTemp.indexOf("WHERE"));
        } else if ((aTemp.indexOf("WHERE") < 0) && (aTemp.indexOf("ORDER BY") < 0) && (aTemp.indexOf("GROUP BY") > 0)) {
            a_sFileName = aTemp.substring(aTemp.indexOf("FROM") + 4, aTemp.indexOf("GROUP BY"));
        } else if ((aTemp.indexOf("WHERE") < 0) && (aTemp.indexOf("GROUP BY") < 0) && (aTemp.indexOf("ORDER BY") > 0)) {
            a_sFileName = aTemp.substring(aTemp.indexOf("FROM") + 4, aTemp.indexOf("ORDER BY"));
        } else if ((aTemp.indexOf("WHERE") < 0) && (aTemp.indexOf("GROUP BY") > 0) && (aTemp.indexOf("ORDER BY") > 0)) {
            if (aTemp.indexOf("GROUP BY") < aTemp.indexOf("ORDER BY")) {
                a_sFileName = aTemp.substring(aTemp.indexOf("FROM") + 4, aTemp.indexOf("GROUP BY"));
            } else a_sFileName = aTemp.substring(aTemp.indexOf("FROM") + 4, aTemp.indexOf("ORDER BY"));
        } else a_sFileName = aTemp.substring(aTemp.indexOf("FROM") + 4, aTemp.length());


        //get data items
        aTemp = aTemp.substring(0, aTemp.indexOf("FROM"));
        aTemp = (aTemp.substring(6, aTemp.length())).trim();
        if (aTemp.trim().indexOf("DISTINCT") == 0) {
            aTemp = aTemp.substring(9, aTemp.length());
        } else if (aTemp.trim().indexOf("ALL") == 0) {
            aTemp = aTemp.substring(4, aTemp.length());
        }

        // construct sql statement
        String a_sSqlStatement = "SELECT FID,DI,LEN,DFT,TYP,DES,SIZ,REQ,DEC,NOD FROM "
                + "DBTBL1D WHERE (";

        int i = 0;
        String asFile = new String();
        StringTokenizer parser = new StringTokenizer(a_sFileName.trim(), ",");
        try {
            while (parser.hasMoreElements()) {

                asFile = ((String) parser.nextElement()).trim();
                if (i == 0) a_sSqlStatement = a_sSqlStatement + "FID = '" + asFile.trim() + "'";
                else a_sSqlStatement = a_sSqlStatement + " or FID = '" + asFile.trim() + "'";
                i++;
            }
        } catch (NoSuchElementException e) {
            ScDBError.check_error(80, "ScMSQLFormat");
        }
        if (aTemp.compareTo("*") != 0) {
            a_sSqlStatement = a_sSqlStatement + ") and (";

            i = 0;
            String a_sData = new String();
            StringTokenizer parser1 = new StringTokenizer(aTemp, ",");
            try {
                while (parser1.hasMoreElements()) {
                    a_sData = ((String) parser1.nextElement()).trim();
                    if (a_sData.indexOf(".") == 0) a_sData = a_sData.substring(1, a_sData.length());
                    if (a_sData.indexOf('.') > 0)
                        a_sData = a_sData.substring(a_sData.indexOf('.') + 1, a_sData.length()).trim();
                    if (i == 0) a_sSqlStatement = a_sSqlStatement + "DI = '" + a_sData + "'";
                    else a_sSqlStatement = a_sSqlStatement + " or DI = '" + a_sData + "'";
                    i++;
                }
            } catch (NoSuchElementException e) {
                ScDBError.check_error(80, "ScMSQLFormat");
            }
            a_sSqlStatement = a_sSqlStatement + ")";
        } else {
            a_sSqlStatement = a_sSqlStatement + ") order by nod,pos";
        }
        return a_sSqlStatement;

    }

    /**
     * Wrapper method for Memo and Blob.
     * @param cells The ScMatrix Cells
     * @param a_sResultString The Raw Result String
     * @param a_icurrentRow The current row index
     * @param medaData The sql meta data
     *
     * @see parseRawResult(ScMatrix cells, String a_sResultString,int a_icurrentRow)
     */
    public static void parseRawResult(ScMatrix cells, String a_sResultString, int a_icurrentRow, String[][] medaData) {
        /*
         * Manoj Thoniyil - 04/18/2007
         *
         */
        if (medaData != null && medaData.length == 1 && (medaData[0][4].equals("M") || medaData[0][4].equals("B"))) {
            cells.addElement(a_icurrentRow, 0, a_sResultString);
            return;
        }

        parseRawResult(cells, a_sResultString, a_icurrentRow);
    }

    /*
     * As because for both no record found and single row single
     * column null value sTempResult[2] = "", there was no differentiation
     * between the two. Additionally for multi row single column
     * null value selects as because sTempResult[2] contained
     * \r\n\r\n\r\n .... StringTokenizer on \r\n did not give
     * expected result. For both these cases the total rows which is
     * a cell count became 0 and hence no record found condition resulted.
     * A logic to tokenize the \r\n\r\n\r\n by \r\n using indexOf logic
     * could have been used to replace the StringTokenizer logic. But
     * it would have added the overhead of extreme testing as the whole
     * cell formation logic would have been affected by it.
     *
     * Hence a simple solution is implemented.
     *
     * When the sTempResult[2] consists "" and sTempResult[1] is 1, it
     * means the result is null. When the count is more than 0, but the
     * trim.length() is 0 it is in the form \r\n\r\n i.e. multiple rows
     * with single column. Whenever multi columns are selected
     * the \t which comes in between of \r\n makes the cells formation ok
     * later on. Only the multi row single column selection and
     * single row single column selection with no data ( null) requires
     * special treatment. The code here takes care of multi row
     * single column null selection and single row single column
     * null selection too.
     */

    /**
     *  Build up the cells ( Rows and Columns )
     *  @param cells The ScMatrix cells to be formed
     *  @param a_sResultString The DB Returned Raw Result
     *  @param a_icurrentRow The current Row index
     */
    public static void parseRawResult(ScMatrix cells, String a_sResultString, int a_icurrentRow) {

        int iCurrentRow = a_icurrentRow;
        int iCurrentColumn = 0;
        int i_iTotalColumns = 0;

        if (a_sResultString == null)        // Single Row Single Column Null
        {
            cells.addElement(iCurrentRow, iCurrentColumn, a_sResultString);
            return;
        }
        // Multi Row Single Column Null
        if (a_sResultString.length() == 0) {
            int iTempRow = iCurrentRow;
            int iTempColumn = iCurrentColumn;
            for (; iTempRow < iRowCount; iTempRow++) {
                cells.addElement(iTempRow, iCurrentColumn, null);
            }
        }                              // To be Added Till here

        int count, offset, where, oldoffset;
        String a_sTemp = new String();

        if (a_sResultString.length() > 0) {
            //parses the i_sRawResult into Rows and Columns
            String[] sRow = a_sResultString.split("\r\n");

            for (int rcount = 0; rcount < sRow.length; rcount++) {
                for (iCurrentColumn = 0, offset = 0, oldoffset = 0; ((where = sRow[rcount].indexOf("\t", offset)) >= 0); offset = where + 1) {
                    if (where >= 0) {
                        a_sTemp = sRow[rcount].substring(oldoffset, where);
                        if (a_sTemp == null) a_sTemp = "";
                        cells.addElement(iCurrentRow, iCurrentColumn, a_sTemp);
                        oldoffset = where + 1;
                        ++iCurrentColumn;
                    }
                }
                a_sTemp = sRow[rcount].substring(oldoffset, sRow[rcount].length());
                if (a_sTemp == null) a_sTemp = "";
                cells.addElement(iCurrentRow, iCurrentColumn, a_sTemp);

                ++iCurrentColumn;

                iCurrentRow++;
                if (i_iTotalColumns == 0) i_iTotalColumns = iCurrentColumn;
            }

            sRow = null;
        }
        a_sResultString = null; //release memory RMX
    }

    /**
     *  Build up the cells ( Rows and Columns )
     *  @param cells The ScMatrix cells to be formed
     *  @param a_sResultString The DB Returned Raw Result
     *  @param a_icurrentRow The current Row index
     */
    public static void parseMrpcRawResult(ScMatrix cells, String a_sResultString, int a_icurrentRow, String size) {

        int iCurrentRow = a_icurrentRow;
        int iCurrentColumn = 0;
        int i_iTotalColumns = 0;

        if (a_sResultString.length() < 1) return;


        int count, offset, where, oldoffset;
        String a_sTemp = new String();

        //parses the i_sRawResult into Rows and Columns
        StringTokenizer stRows = new StringTokenizer(a_sResultString, "\r\n");
        while (stRows.hasMoreTokens() == true) {
            String sRow = (String) stRows.nextElement();
            for (iCurrentColumn = 0, offset = 0, oldoffset = 0; ((where = sRow.indexOf("\t", offset)) >= 0); offset = where + 1) {
                if (size.equals("1"))
                    break;

                if (where >= 0) {
                    a_sTemp = sRow.substring(oldoffset, where);
                    if (a_sTemp == null) a_sTemp = "";
                    if ((a_sTemp.indexOf((char) 199) >= 0) || (a_sTemp.indexOf((char) 200) >= 0)) {
                        a_sTemp = a_sTemp.replace((char) 199, '\t');
                        a_sTemp = a_sTemp.replace((char) 200, '\r');
                        a_sTemp = a_sTemp.replace((char) 201, '\n');
                        cells.addElement(iCurrentRow, iCurrentColumn, a_sTemp);
                    } else cells.addElement(iCurrentRow, iCurrentColumn, a_sTemp);
                    oldoffset = where + 1;
                    ++iCurrentColumn;
                }
            }
            a_sTemp = sRow.substring(oldoffset, sRow.length());
            if (a_sTemp == null) a_sTemp = "";
            if ((a_sTemp.indexOf((char) 199) >= 0) || (a_sTemp.indexOf((char) 200) >= 0) || (a_sTemp.indexOf((char) 201) >= 0)) {
                if (size.equals("1") == false) {
                    a_sTemp = a_sTemp.replace((char) 199, '\t');
                }
                a_sTemp = a_sTemp.replace((char) 200, '\r');
                a_sTemp = a_sTemp.replace((char) 201, '\n');

                cells.addElement(iCurrentRow, iCurrentColumn, a_sTemp);
            } else cells.addElement(iCurrentRow, iCurrentColumn, a_sTemp);

            ++iCurrentColumn;

            iCurrentRow++;
            if (i_iTotalColumns == 0) i_iTotalColumns = iCurrentColumn;
        }
        a_sResultString = null; //release memory RMX
        stRows = null;
    }

    /**
     * Creates the data description
     * @param a_sResultString DB returned Raw Result
     * @param colIndexColname The map of Column Indices and Clumn names ( Aliases)
     * @return String[][] of data description
     */
    public static String[][] parseRawResult(String a_sResultString, Hashtable colIndexColname) {
        if (a_sResultString.compareTo("") == 0) return null;
        //FID,DI,LEN,DFT,TYP,DES,SIZ,REQ,DEC,NOD FROM
        ScMatrix cells = new ScMatrix();
        parseRawResult(cells, a_sResultString, 0);
        if (colIndexColname.size() == 0) getScheme(cells, colIndexColname);

        String[][] sArray = new String[cells.rows()][10];

        for (int i = 0; i < cells.rows(); i++) {
            for (int j = 0; j < 10; j++) {
                sArray[i][j] = (String) cells.elementAt(i, j);

            }
        }

        cells = null;
        String[][] dbaInf = new String[colIndexColname.size()][10];
        String sFile = "";
        String sTemp = "";
        String columnName;
        Hashtable table = new Hashtable();

        for (int columnIndex = 0; columnIndex < colIndexColname.size(); columnIndex++) {
            columnName = getColumnName(columnIndex + 1, colIndexColname).trim();

            if (columnName.indexOf(".") > 0) {
                sFile = columnName.substring(0, columnName.indexOf("."));
                columnName = columnName.substring(columnName.indexOf(".") + 1, columnName.length());

                for (int row = 0; row < sArray.length; row++) {
                    sTemp = (String) sArray[row][0];
                    if ((sFile.length() > 0) && (sTemp.trim().compareTo(sFile) != 0)) continue;
                    sTemp = (String) sArray[row][1];
                    if (sTemp.compareTo(columnName) != 0) continue;

                    Integer iRow = (Integer) table.get(new Integer(row));
                    if ((iRow == null) || !(iRow.equals(new Integer(row)))) {
                        dbaInf[columnIndex] = sArray[row];
                        table.put(new Integer(row), new Integer(row));
                    } else {
                        String[] ss = {new String(sArray[row][0]), new String(sArray[row][1]), new String(sArray[row][2]), new String(sArray[row][3]), new String(sArray[row][4]), new String(sArray[row][5]), new String(sArray[row][6]), new String(sArray[row][7]), new String(sArray[row][8]), new String(sArray[row][9])};
                        dbaInf[columnIndex] = ss;
                    }
                }
            } else {
                for (int row = 0; row < sArray.length; row++) {
                    sTemp = (String) sArray[row][1];

                    if (sTemp.compareTo(columnName) == 0) {
                        Integer iRow = (Integer) table.get(new Integer(row));
                        if ((iRow == null) || !(iRow.equals(new Integer(row)))) {
                            dbaInf[columnIndex] = sArray[row];
                            table.put(new Integer(row), new Integer(row));
                        } else {
                            String[] ss = {new String(sArray[row][0]), new String(sArray[row][1]), new String(sArray[row][2]), new String(sArray[row][3]), new String(sArray[row][4]), new String(sArray[row][5]), new String(sArray[row][6]), new String(sArray[row][7]), new String(sArray[row][8]), new String(sArray[row][9])};
                            dbaInf[columnIndex] = ss;
                        }
                        break;
                    } else if ((sTemp.compareTo(columnName) != 0) && (row == sArray.length - 1)) {
                        String[] sTemPara = {"TMP", "TMP", "20", "", "T", "", "20", "0", "", ""};
                        dbaInf[columnIndex] = sTemPara;
                    }
                }
            }
        }
        a_sResultString = null;
        return dbaInf;
    }

    /**
     * Returns the column name for the column index
     * @param columnIndex The column index
     * @param i_ahHash The Map containing the index and name mapping
     * @return The Column Name
     */
    private static String getColumnName(int columnIndex, Hashtable i_ahHash) {

        if (i_ahHash == null) return "";

        String colName = "";

        colName = (String) i_ahHash.get(new Integer(columnIndex));
        return colName;

    }

    /**
     * Creates the data description
     * @param a_rResultMetaData The ScMatrix to be updated
     * @param ahHash Map containing the Column Indices and Column Name
     */
    private static void getScheme(ScMatrix a_rResultMetaData, Hashtable ahHash) {
        int i = 1;
        String sDataItem = "";
        //switch key data item to beginning of the matrix
        int iRow = 0;
        String sArray = new String();

        int iTotalRow = a_rResultMetaData.rows();
        for (int j = 0; j < iTotalRow; j++) {
            sDataItem = (String) a_rResultMetaData.elementAt(j, 9);
            if (sDataItem.indexOf("*") > 0) {
                if (((String) a_rResultMetaData.elementAt(j, 1)).indexOf('"') == 0) {
                    a_rResultMetaData.removeRow(j);
                    iTotalRow = iTotalRow - 1;
                    continue;
                }
                a_rResultMetaData.insertRow(iRow);
                for (int k = 0; k < 10; k++) {
                    a_rResultMetaData.updateElement(iRow, k, (String) a_rResultMetaData.elementAt(j + 1, k));

                }

                a_rResultMetaData.removeRow(j + 1);
                iRow++;
            }
        }

        for (int j = 0; j < a_rResultMetaData.rows(); j++) {
            sDataItem = (String) a_rResultMetaData.elementAt(j, 1);
            ahHash.put(new Integer(i++), sDataItem);
        }

    }

    public static String sphost(String s, Vector vector) {
        if (s.toUpperCase().trim().indexOf("EXECUTE") == 0)
            return s;
        String s1 = "";
        String s2 = ",><=() ";

        int k = 1;
        Object obj = null;
        StringBuffer stringbuffer = new StringBuffer();
        String s3 = "";
        String s6 = "";
        s = noScheme(s);
        int l = fileCount(s);
        ScStringTokenizer scstringtokenizer = new ScStringTokenizer(s, s2, true);
        while (s1 != "end!") {
            s1 = atomHost(scstringtokenizer);
            if (s1 == "end!")
                break;
            int i1 = s1.indexOf(".");
            if (l == 1 && i1 > 0 && !s1.substring(i1 + 1, s1.length()).equalsIgnoreCase("NEXTVAL")) {
                String s5 = s1.substring(s1.indexOf(".") + 1, s1.length());
                int i = scstringtokenizer.getcurrentPosition();
                s = s.substring(0, i - s1.length()) + s5 + s.substring(i, s.length());
                scstringtokenizer.setStr(s);
                scstringtokenizer.setCurrentPos((i - s1.length()) + s5.length());
            }
            if (s1.indexOf("<") >= 0 || s1.indexOf(">") >= 0 || s1.indexOf("=") >= 0) {
                s1 = atomHost(scstringtokenizer);
                if (s1.indexOf("<") >= 0 || s1.indexOf(">") >= 0 || s1.indexOf("=") >= 0)
                    s1 = atomHost(scstringtokenizer);
                if (s1.charAt(0) == '\'' || isDigit(s1)) {
                    if (s1.charAt(0) == '\'') {
                        int j1 = s1.length();
                        if (j1 == 1 || s1.charAt(s1.length() - 1) != '\'' || s1.charAt(s1.length() - 1) == '\'' && s1.charAt(s1.length() - 2) == '\'' && s1.compareTo("''") != 0)
                            while (scstringtokenizer.hasMoreTokens()) {
                                s1 = s1 + scstringtokenizer.nextToken();
                                if (s1.charAt(s1.length() - 1) == '\'' && s1.charAt(s1.length() - 2) != '\'')
                                    break;
                            }
                    }
                    int j = scstringtokenizer.getcurrentPosition();
                    Integer integer = new Integer(k++);
                    String s4 = ":C" + integer.toString();
                    s = s.substring(0, j - s1.length()) + s4 + s.substring(j, s.length());
                    scstringtokenizer.setStr(s);
                    scstringtokenizer.setCurrentPos((j - s1.length()) + s4.length());
                    if (s1.indexOf("'.") == 0)
                        s1 = "'" + s1.substring(2, s1.length());
                    if (s1.startsWith("'") && s1.endsWith("'")) s1 = s1.substring(1, s1.length() - 1);
                    vector.addElement(s1);
                }
            }
        }
        return space(s);
    }

    public static void updateRowCount(int row) {
        iRowCount = row;
        return;
    }

}