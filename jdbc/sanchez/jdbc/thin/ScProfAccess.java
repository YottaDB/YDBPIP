/**
 * ScProfAccess
 *
 * @version 1.0  Spet. 28 1999
 * @author Quansheng Jia
 * @see DriverManager
 */
package sanchez.jdbc.thin;

import java.sql.SQLException;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Properties;
import java.util.Random;
import java.util.Vector;

import sanchez.utils.ScMatrix;
import sanchez.base.ScBundle;
import sanchez.base.ScResourceKeys;
import sanchez.him_pa.ScProfToken;
import sanchez.him_pa.utils.ScMSQLFormat;
import sanchez.him_pa.formatters.ScProfileForm;
import sanchez.him_pa.ScProfileException;
import sanchez.him_pa.utils.ScUtils;
import sanchez.jdbc.dbaccess.ScDBAccess;
import sanchez.jdbc.dbaccess.ScDBColumn;
import sanchez.jdbc.dbaccess.ScDBError;
import sanchez.jdbc.dbaccess.ScDBStatement;
import sanchez.jdbc.dbaccess.ScGenericStatement;
import sanchez.jdbc.dbaccess.ScMrpcStatement;
import sanchez.jdbc.dbaccess.ScMsqlDDLStatement;
import sanchez.jdbc.dbaccess.ScMsqlQueryStatement;
import sanchez.jdbc.dbaccess.ScStoreProStatement;
import sanchez.jdbc.pool.ScJdbcPool;
import sanchez.jdbc.pool.ScPoolManager;
import sanchez.jdbc.pool.ScPooledConnection;

public class ScProfAccess implements ScDBAccess {
    ScProfileAPI i_hHim = null;
    ScProfileForm oProfForm = new ScProfileForm();

    Hashtable i_hStatementTable;
    private static Hashtable i_hMetaDataTable = new Hashtable();
    private static Hashtable i_hColIndexTable = new Hashtable();
    String i_sBufferName;

    boolean i_bAutoCommit = true;

    ScProfToken oToken = null;
    String psSQLQualifier = "";
    String psStoreForward = "0";

    int i_iDefaultRowPrefetch = 0;
    int i_iDefaultExecuteBatch = 1;

    String userName;
    String password;
    Properties info;
    String i_sDatabase;
    String url;

    private int iQueryTimeOut = 0;
    private static int nometa = 1;

    /**
     * Default Constructor
     */
    public ScProfAccess() {
    }

    /**
     * Logon to Profile using the input parameters
     * @param sUser The User Name
     * @param sPassword The password
     * @param sDatabase The Database details
     * @param pInfo The Property file containing additional parameters  
     * @param url The Database Url
     * @exception SQLException If any database access error occurrs
     * @exception Exception If any other error occurs.
     */
    public void logon(String sUser, String sPassword, String sDatabase, Properties pInfo, String url)
            throws SQLException, Exception {
        i_sDatabase = sDatabase;
        userName = sUser;
        password = sPassword;
        info = pInfo;
        this.url = url;

        if (i_hHim == null) i_hHim = new ScProfileAPI(sDatabase, pInfo);
        String signOnType = (String) pInfo.get("signOnType");
        String newPWD = (String) pInfo.get("newPWD");
        String instID = (String) pInfo.get("instID");

        if (signOnType == null) signOnType = "0";

        //sign on at clear password
        if (signOnType.trim().equalsIgnoreCase("0")) {
            if ((newPWD == null) && (instID == null))
                oToken = i_hHim.ProfileLogin(sUser, sPassword);
            else
                oToken = i_hHim.ProfileLogin(sUser, sPassword, pInfo);
        }
        //challenge/response
        else if (newPWD != null) {
            oToken = i_hHim.ProfileLoginCR(sUser, sPassword, newPWD);
        } else oToken = i_hHim.ProfileLoginCR(sUser, sPassword, "");

        i_sBufferName = String.valueOf(oToken.getToken().hashCode());
    }

    /**
     * Logoff from Profile
     *
     * @exception SQLException If any database access error occurrs
     * @exception Exception If any other error occurs.
     */
    public void logoff()
            throws SQLException, Exception {
        i_hHim.ProfileLogout(oToken);
        cleanUp();
    }

    /**
     * Executes and commits the buffer containts
     *
     * @exception SQLException If any database access error occurrs
     * @exception Exception If any other error occurs.
     */
    public void commit()
            throws SQLException, Exception {
        String bufferName = "BUFFER COMMIT " + i_sBufferName.toUpperCase();
        String[] asResult;
        try {
            asResult = i_hHim.ProfileSQL(oToken, bufferName, "", psStoreForward);
        } catch (Exception e) {
            if (e.getMessage().startsWith("MSG_8555|")) return;
            else throw e;
        }
    }

    /**
     * Executes and commits the buffer contents
     *
     * @exception SQLException If any database access error occurrs
     * @exception Exception If any other error occurs.
     */
    public String[] batchCommit()
            throws SQLException, Exception {
        String bufferName = "BUFFER COMMIT " + i_sBufferName.toUpperCase();
        String[] asResult;
        try {
            asResult = i_hHim.ProfileSQL(oToken, bufferName, "", psStoreForward);
        } catch (Exception e) {
            if (e.getMessage().startsWith("MSG_8555|")) return null;
            else throw e;
        }
        return asResult;
    }

    /**
     * Rolls back the executed Buffer
     * @exception SQLException If any database access error occurrs
     * @exception Exception If any other error occurs.
     */
    public void rollback()
            throws SQLException, Exception {
        String bufferName = "BUFFER ROLLBACK " + i_sBufferName.toUpperCase();
        String[] asResult = i_hHim.ProfileSQL(oToken, bufferName, "", psStoreForward);
    }

    /**
     * Sets Autocommit on or off
     *
     * @param flag Boolean true or else denoting on or off
     * @exception SQLException If any database access error occurrs
     * @exception Exception If any other error occurs.
     */
    public void setAutoCommit(boolean flag) {
        i_bAutoCommit = flag;
    }

    /**
     * Opens a new ScMsqlQueryStatement statement with Cursor,
     * and input parameters.
     *
     * @param sSql The String sql
     * @param fetchRow The number of rows ro be fetched  
     * @return ScDBStatement The new ScMsqlQueryStatement
     * @exception SQLException If any database access error occurrs
     * @exception Exception If any other error occurs.
     */
    public ScDBStatement open(String sSql, int fetchRow)
            throws SQLException, Exception {

        String cursorName = oToken.getCursorId();
        return new ScMsqlQueryStatement(cursorName, sSql, fetchRow);
    }

    /**
     * Closes the Cursor,
     *
     * @param dBStatement The ScMsqlQueryStatement contaning the cursor to 
     *        be closed   
     * @exception SQLException If any database access error occurrs
     * @exception Exception If any other error occurs.
     */
    public void closeQuery(ScDBStatement dBStatement)
            throws SQLException, Exception {
        ScMsqlQueryStatement statement = (ScMsqlQueryStatement) dBStatement;

        String sCursor = statement.getCursor();

        String[] sTempResult;
        try {
            sTempResult = i_hHim.ProfileSQL(oToken, "CLOSE " + sCursor, "", psStoreForward);
        } catch (Exception e) {
            int i = tokenCheck(e);
            if (i == 1) sTempResult = i_hHim.ProfileSQL(oToken, "CLOSE " + sCursor, "", psStoreForward);
        }

    }

    /**
     * Closes the statement,
     *
     * @param dBStatement The ScDBStatement to be closed   
     * @exception SQLException If any database access error occurrs
     * @exception Exception If any other error occurs.
     */
    //close statement
    public void close(ScDBStatement dBStatement)
            throws SQLException, Exception {
        dBStatement = null;
    }

    /**
     * Gets the description of the Statement and Stores
     * in ScMsqlQueryStatement from the database.
     *
     * @param dBStatement The ScMsqlQueryStatement to be used   
     * @exception SQLException If any database access error occurrs
     * @exception Exception If any other error occurs.
     */
    public void describe(ScDBStatement dBStatement)
            throws SQLException, Exception {
        ScMsqlQueryStatement statement = (ScMsqlQueryStatement) dBStatement;
        statement.setColIndexColNameMap(statement.getSqlStatment());
        String describeStatement = ScMSQLFormat.describeSql(statement.getSqlStatment());

        //unicode supporting
        describeStatement = ScUtils.stringEncoding(describeStatement, (String) info.get("ENCODING"));

        String[] asResult = null;
        try {
            asResult = i_hHim.ProfileSQL(oToken, describeStatement, "ROWS=200", psStoreForward);
        } catch (Exception e) {
            int i = tokenCheck(e);
            if (i == 1) asResult = i_hHim.ProfileSQL(oToken, describeStatement, "ROWS=200", psStoreForward);
        }
        statement.setDBA(asResult[2]);
    }

    /**
     * Builds and Sets the Column Index Column Name Map and DBA Information for the 
     * input ScMsqlQueryStatement.
     *
     * @param statement ScMsqlQueryStatement statement
     * @param prapare
     * @throws SQLException If any database access error occurs
     * @throws Exception If any other error occurs.
     */
    private void parserPrapare(ScMsqlQueryStatement statement, String prapare)
            throws SQLException, Exception {
        int i = 0, k = 0, m = 1, kk = 0;
        int colIndex = 1;
        long colLen;

        HashMap sch = new HashMap(18);
        Hashtable colIndexColName = new Hashtable();
        StringBuffer s = new StringBuffer();
        String sss = "", file = "", sTemp = "";
        String dbaInf = "";
        char c;

        for (int jjj = 0; jjj < prapare.length(); jjj++) {
            if (jjj == 0) {
                do {
                    i = ScUtils.unsigned((byte) prapare.charAt(jjj++));
                } while (i != 255);
                k = jjj;
                jjj--;
            }//if

            else {
                i = ScUtils.unsigned((byte) prapare.charAt(jjj));

                switch (m) {
                    case 1:
                        sss = Integer.toBinaryString(i);

                        if (sss.charAt(sss.length() - 1) == '0') sch.put("REQ", "1");
                        else sch.put("REQ", "0");
                        c = sss.charAt(sss.length() - 3);
                        sch.put("CAS", String.valueOf(c));
                        c = sss.charAt(sss.length() - 4);
                        sch.put("SEA", String.valueOf(c));
                        c = sss.charAt(sss.length() - 6);
                        sch.put("UNS", String.valueOf(c));
                        if (sss.length() < 7) {
                            if ((int) c == 1) sch.put("SIN", String.valueOf(0));
                            else sch.put("SIN", String.valueOf(1));
                            sch.put("MON", String.valueOf(0));
                            break;
                        }
                        c = sss.charAt(sss.length() - 7);
                        sch.put("SIN", String.valueOf(c));
                        c = sss.charAt(sss.length() - 8);
                        sch.put("MON", String.valueOf(c));
                        break;
                    case 2:
                        sss = Integer.toBinaryString(i);

                        c = sss.charAt(sss.length() - 1);
                        sch.put("AUT", String.valueOf(c));

                        break;
                    case 3:
                        sch.put("TYP", String.valueOf((char) i));
                        break;
                    case 4:
                        kk = ScUtils.unsigned((byte) prapare.charAt(jjj + 1));
                        sch.put("LEN", String.valueOf((i * 256) + kk));
                        colLen = (i * 256) + kk;
                        if (colLen > 32767) {
                            String sTyp = (String) sch.get("TYP");
                            if (sTyp.equalsIgnoreCase("M") || sTyp.equalsIgnoreCase("B")) {
                                m = m + 6;
                                jjj = jjj + 3;
                            }
                        }
                        //
                        break;
                    case 5:
                    case 6:
                    case 7:
                        break;
                    case 8:
                        kk = ScUtils.unsigned((byte) prapare.charAt(jjj + 1));
                        sch.put("SIZ", String.valueOf((i * 256) + kk));
                        break;
                    case 9:
                        break;
                    case 10:
                        sch.put("DEC", String.valueOf(i));
                        break;
                    case 11:
                        kk = i;
                        break;
                    case 12:
                        if ((i == 255) && (kk == 0)) {
                            sch.put("DI", "");
                            sch.put("FID", "");
                            s = new StringBuffer();
                            break;
                        }

                        int start = jjj;
                        while (i != 255) {
                            i = ScUtils.unsigned((byte) prapare.charAt(++jjj));
                        }
                        String substr = prapare.substring(start, jjj);
                        if (jjj > start)
                            s.append(substr);

                        if (kk == 0) {
                            file = s.toString();
                        } else {
                            s.insert(0, file.substring(0, kk));
                            file = s.toString();
                        }
                        sch.put("DI", file.substring(file.indexOf('.') + 1, file.length()));
                        sch.put("FID", file.substring(0, file.indexOf('.')));
                        s = new StringBuffer();
                        break;

                }//switch
                if (i != 255 || m < 12) {
                    m++;
                    continue;
                } else {
                    colIndexColName.put(new Integer(colIndex), (String) sch.get("FID") + "." + (String) sch.get("DI"));
                    sTemp = (String) sch.get("FID") + '\t'
                            + (String) sch.get("DI") + '\t'
                            + (String) sch.get("LEN") + '\t'
                            + "" + '\t'
                            + (String) sch.get("TYP") + '\t'
                            + (String) sch.get("DI") + '\t'
                            + (String) sch.get("SIZ") + '\t'
                            + (String) sch.get("REQ") + '\t'
                            + (String) sch.get("DEC") + '\t' + "";

                    if (colIndex == 1) dbaInf = sTemp;
                    else dbaInf = dbaInf + "\r\n" + sTemp;

                    colIndex++;
                    m = 1;
                }//else
            }//else
        }//for

        statement.setColIndexColNameMap(colIndexColName);
        statement.setDBA(dbaInf);
    }

    /**
     * Returns null currently
     * @param dBStatement ScDBStatement Object,mMatrix ScMatrix Object
     * @return null
     */
    public ScDBColumn[] parseExecuteDescribe(ScDBStatement dBStatement, ScMatrix mMatrix)
            throws SQLException, Exception {
        return null;
    }

    /**
     * Exceutes the CUD of CRUD operations.
     * @param dBStatement Instance of ScMsqlDDLStatement to be executed
     * @exception SQLException If any databse access error occurs
     * @exception Exception If any other exception occurs 
     */
    public int executeUpdate(ScDBStatement dBStatement)
            throws SQLException, Exception {
        ScMsqlDDLStatement statement = (ScMsqlDDLStatement) dBStatement;
        String Qualifier;
        if ((statement.sqlQuailfier.equals(null)) || (statement.sqlQuailfier.length() < 1)) Qualifier = "";
        else Qualifier = statement.sqlQuailfier;

        String sUpdateSql = statement.getSqlStatment();

        //unicode supporting
        sUpdateSql = ScUtils.stringEncoding(sUpdateSql, (String) info.get("ENCODING"));
        Qualifier = ScUtils.stringEncoding(Qualifier, (String) info.get("ENCODING"));

        String[] asResult = null;
        try {
            asResult = i_hHim.ProfileSQL(oToken, sUpdateSql, Qualifier, psStoreForward);
        } catch (Exception e) {
            int i = tokenCheck(e);
            if (i == 1) {
                asResult = i_hHim.ProfileSQL(oToken, sUpdateSql, Qualifier, psStoreForward);
            }
        }

        String asCount = asResult[1];
        Integer aiRowCount;
        try {
            aiRowCount = Integer.valueOf(asCount);
        } catch (Exception e) {
            aiRowCount = Integer.valueOf("0");
        }
        return aiRowCount.intValue();
    }

    /**
     * As because for both no record found and single row single
     * column null value sTempResult[2] = "", there was no differentiation
     * between the two. Additionally for multi row single column 
     * null value selects as because sTempResult[2] contained 
     * \r\n\r\n\r\n .... StringTokenizer on \r\n did not give 
     * expected result. For both these cases the total rows which is
     * a cell count became 0 and hence no record found condition resulted.
     * A logic to tokenize the \r\n\r\n\r\n by \r\n using indexOf logic
     * could have been used to replace the StringTokenizer logic. But
     * it would added the overhead of extreme testing as the whole
     * cell formation logic would have been affected by it.
     *
     * Hence a simple solution is implemented.
     *
     * When the sTempResult[2] consists "" and sTempResult[1] is 1, it
     * means the result is null. When the count is more than 0, but the
     * trim.length() is 0 it is in the form \r\n\r\n i.e. multiple rows
     * with single column. Whenever multi columns are selected 
     * the \t which comes in between of \r\n makes the cells formation ok
     * later on. Only the mutli row single column selection and
     * single row single column selection with no data ( null) requires
     * special treatment. The code later on takes care of multi row
     * single column null selection. Here single row single column 
     * null selection is being taken care of by setting the raw result as null.
     *
     * Statement Query timeout was not implemented.
     * There were two ways to implement the query timeout
     * Either using thread or using socket read timeout.
     * Following changes are the part of Socket Read Timeout
     * implementation.
     *
     * @param dBStatement ScMsqlQueryStatement statement
     * @exception SQLException If any database access error occurs
     * @exception Exception If any other error occurs.
     */

    public int fetch(ScDBStatement dBStatement)
            throws SQLException, Exception {
        ScMsqlQueryStatement statement = (ScMsqlQueryStatement) dBStatement;
        String sSql = statement.getSqlStatment().trim().toUpperCase();
        int prapare = 0;
        int meta_flag = 0;
        String proc_name = null;
        String Qualifier;

        if (statement.getSqlStatus().equals("01500")) {
            return 0;
        } else if ((sSql.indexOf("EXECUTE") == 0) || (sSql.indexOf("DESCRIBE") == 0) || (sSql.indexOf("CREATE") == 0))
            sSql = statement.getSqlStatment();
        else if ((sSql.indexOf("OPEN") == 0)) {
            sSql = statement.getSqlStatment();
            prapare = 1;
        } else if (statement.getSqlStatus().equals("0")) {
            if (sSql.indexOf("SELECT") < 0) {
                sSql = "OPEN " + statement.getCursor() + " AS PROCEDURE " + statement.getSqlStatment();
                String sql_stmt = statement.getSqlStatment();

                if (sql_stmt.indexOf("USING") == -1)
                    proc_name = sql_stmt;
                else
                    proc_name = sql_stmt.substring(0, (sql_stmt.indexOf("USING") - 1));
                if (i_hMetaDataTable.get(proc_name) == null)
                    meta_flag = 1;
                else meta_flag = 2;
            } else sSql = "OPEN CURSOR " + statement.getCursor() + " AS " + statement.getSqlStatment();
            prapare = 1;
        } else if (statement.getSqlStatus().equals("1")) {
            sSql = "OPEN CURSOR " + statement.getCursor() + " AS " + statement.getSqlStatment();
        } else sSql = "FETCH " + statement.getCursor();

        if (statement.sqlQuailfier.equals(null)) Qualifier = psSQLQualifier;
        else {
            Qualifier = statement.sqlQuailfier;
            if (Qualifier.indexOf("ROWS") < 0) Qualifier = psSQLQualifier + Qualifier;
        }

        if ((meta_flag == 2) && (nometa == 1))
            Qualifier = Qualifier + "/NOMETA=1";

        String[] sTempResult = null;
        //unicode supporting
        sSql = ScUtils.stringEncoding(sSql, (String) info.get("ENCODING"));
        Qualifier = ScUtils.stringEncoding(Qualifier, (String) info.get("ENCODING"));

        try {
            if (this.iQueryTimeOut > 0) {
                i_hHim.setSoReadTimeOut(this.iQueryTimeOut);
            }
            sTempResult = i_hHim.ProfileSQL(oToken, sSql, Qualifier, psStoreForward);
        } catch (Exception e) {
            int i = tokenCheck(e);
            if (i == 1) {
                if (this.iQueryTimeOut == 0) {
                    sTempResult = i_hHim.ProfileSQL(oToken, sSql, Qualifier, psStoreForward);
                }
            }
        }
        if (sTempResult[2].indexOf('\t') != 0) {
            if (sTempResult[2] != null && sTempResult[2].trim().length() == 0) {
                if (Integer.valueOf(sTempResult[1]).intValue() == 1) {
                    sTempResult[2] = null;
                }
            }
        }
        if (meta_flag == 2) {
            statement.setColIndexColNameMap((Hashtable) i_hColIndexTable.get(proc_name));
            statement.setDBA((String) i_hMetaDataTable.get(proc_name));
        } else {
            if (prapare == 1) {
                if ((sTempResult.length == 3) || ((sTempResult.length == 4) && (sTempResult[3].length() < 1)))
                    describe(statement);
                else {
                    parserPrapare(statement, sTempResult[3]);
                    statement.sqlQuailfier = "ROWS=" + sTempResult[1];
                }
                if (meta_flag == 1) {
                    i_hColIndexTable.put(proc_name, statement.getColIndexColNameMap());
                    i_hMetaDataTable.put(proc_name, statement.getDBA());
                }
            } else if ((sSql.toUpperCase().indexOf("CREATE") == 0)) {
                String metadata = "CREATE\tCREATE PROC\t300\t\tT\tProcedure Name\t1\t1\t1\t";
                statement.setDBA(metadata);
            }
        }

        statement.setSqlStatus(sTempResult[0]);
        statement.setReply(sTempResult[2]);
        if (sTempResult[0].equals("50001")) {
            Object[] args = {sSql};
            throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_procedure_name, args));
        }

        try {
            if (Integer.valueOf(sTempResult[1]).intValue() > 0) {
                Integer row = Integer.valueOf(sTempResult[1]);
                statement.setRowCount(row.intValue());
                return row.intValue();
            } else if (sTempResult[2].length() > 0) {
                return 1;
            }
        } catch (Exception e) {
            return 0;
        }
        return 0;
    }

    /**
     * Executes different types of dBStatement like
     * ScMsqlDDLStatement,ScMrpcStatement,ScStoreProStatement,
     * ScGenericStatement etc.
     *
     * @param dBStatement statement
     * @exception SQLException If any database access error occurs
     * @exception Exception If any other error occurs.
     */
    public void executeProcedure(ScDBStatement dBStatement)
            throws SQLException, Exception {
        String Qualifier;

        //ddl
        if (dBStatement instanceof ScMsqlDDLStatement) {
            executeUpdate(dBStatement);
            return;
        }
        //mrpc
        else if (dBStatement instanceof ScMrpcStatement) {
            ScMrpcStatement statement = (ScMrpcStatement) dBStatement;
            String mrpcId = statement.getMrpcID();
            String version = statement.getVersion();
            String[] params = statement.getParams();
            String spv = statement.getSpv();
            String size = statement.getOutputSize();
            String result = "";
            //unicode supporting
            params = ScUtils.stringEncoding(params, (String) info.get("ENCODING"));
            try {
                result = i_hHim.ProfileMRPC(oToken, mrpcId, version, params, spv, psStoreForward, size); // 09/09/03 MKT XBAD Changes	//**MKT-XBAD
            } catch (Exception e) {
                int i = tokenCheck(e);
                if (i == 1)
                    result = i_hHim.ProfileMRPC(oToken, mrpcId, version, params, spv, psStoreForward, size); // 09/09/03 MKT XBAD Changes	//**MKT-XBAD
            }
            statement.setReply(result);
            return;
        }
        //ScStoreProStatement
        else if (dBStatement instanceof ScStoreProStatement) {
            ScStoreProStatement statement = (ScStoreProStatement) dBStatement;
            String storeProName = statement.getStoreProName();
            String[] params = statement.getParams();
            StringBuffer state = new StringBuffer();
            state.append("EXECUTE ").append(storeProName);
            int i = 0;
            for (i = 0; i < params.length; i++) {
                if (i == 0) state.append(" USING ('").append(params[i]).append("'");
                else state.append(",'").append(params[i]).append("'");
            }
            if (i > 0) state.append(")");

            String[] sTempResult = null;
            String sSql = state.toString();

            if (statement.sqlQuailfier.equals(null)) Qualifier = psSQLQualifier;
            else {
                Qualifier = statement.sqlQuailfier;
                if (Qualifier.indexOf("ROWS") < 0) Qualifier = psSQLQualifier + Qualifier;
            }

            //unicode suppoting
            sSql = ScUtils.stringEncoding(sSql, (String) info.get("ENCODING"));
            Qualifier = ScUtils.stringEncoding(Qualifier, (String) info.get("ENCODING"));

            try {
                sTempResult = i_hHim.ProfileSQL(oToken, sSql, Qualifier, psStoreForward);
            } catch (Exception e) {
                i = tokenCheck(e);
                sTempResult = i_hHim.ProfileSQL(oToken, sSql, Qualifier, psStoreForward);
            }
            statement.setReply(sTempResult[2]);
            return;
        } else if (dBStatement instanceof ScGenericStatement) {
            String serverClass = dBStatement.getServerClass();
            ScGenericStatement statement = (ScGenericStatement) dBStatement;
            String request = statement.getRequestMessage();
            String reply = "";

            //unicode supporting
            request = ScUtils.stringEncoding(request, (String) info.get("ENCODING"));

            try {
                reply = i_hHim.ProfileGeneric(oToken, request, psStoreForward, serverClass);
            } catch (Exception e) {
                int i = tokenCheck(e);
                if (i == 1) reply = i_hHim.ProfileGeneric(oToken, request, psStoreForward, serverClass);
            }
            statement.setReply(reply);
            return;
        }
        ScDBError.check_error(80, "ScProfAccess");

        return;
    }

    /**
     * Returns the Version. Returns Null currently.
     * @exception SQLException
     * @exception Exception
     */
    public byte[] getVersion()
            throws SQLException, Exception {
        return null;
    }

    /**
     * Returns the default Prefetch set
     */
    public int getDefaultPrefetch() {
        return i_iDefaultRowPrefetch;
    }

    /**
     * Return zero 
     */
    public int getDefaultStreamChunkSize() {
        return 0;
    }

    /**
     * Not yet implemented
     */
    public void cancel()
            throws SQLException, Exception {
    }

    /**
     * Not yet implemented
     */
    public void setWaitandAutoRollback(ScDBStatement dBStatement, int i, int j)
            throws SQLException {
    }

    /**
     * Sets the default Row Prefetch Value
     * @param iDefaultRowPrefetch The Positive DefaultRowPrefetch value
     * @exception SQLDException If any error occurs 
     */
    public void setDefaultRowPrefetch(int iDefaultRowPrefetch)
            throws SQLException {
        if (iDefaultRowPrefetch <= 0) return;
        i_iDefaultRowPrefetch = iDefaultRowPrefetch;
        psSQLQualifier = "ROWS=" + Integer.toString(iDefaultRowPrefetch);
    }

    /**
     * Sets the Default Execute Batch  
     * @param iDefaultExecuteBatch value
     */
    public void setDefaultExecuteBatch(int iDefaultExecuteBatch)
            throws SQLException {
        i_iDefaultExecuteBatch = iDefaultExecuteBatch;
    }

    /**
     * Gets the Buffer name in UpperCase
     * @exception If any error occurs
     */
    public String getBufferName()
            throws SQLException {
        return i_sBufferName.toUpperCase();
    }

    public static void set_nometa(int value) {
        nometa = value;
        return;
    }

    Random dom = new Random();
    long idleTime = 5000;

    /**
     * If the input Exception is an instance of ScProfileException
     * and if the handshake token has been invalidated relogin and
     * returns 1.   
     * @param e ScProfileException to be parsed 
     * @return 1 for successful relogin
     * @throws Exception if the input parameter is either not an
     * 		   instance of ScProfileException or the handshake token 
     *         error code is neither 'Not Signed On' nor 'Invalid Token'.
     */
    private int tokenCheck(Exception e)
            throws Exception {
        if (!(e instanceof ScProfileException)) throw e;
        else {
            if ((e.getMessage().indexOf("ER_SV_NOTSGNON") >= 0) ||
                    (e.getMessage().indexOf("ER_SV_INVLDTKN") >= 0)) {
                refreshTokenPool();
                Thread.currentThread().sleep(Math.abs(dom.nextInt() % 38) + idleTime);

                logon(userName, password, i_sDatabase, info, url);
                return 1;
            } else throw e;
        }
    }

    /**
     * Cleans up the resources
     *
     */
    private void cleanUp() {
        i_hHim = null;
        i_hStatementTable = null;
        i_sBufferName = null;
        oToken = null;
        psSQLQualifier = null;
        psStoreForward = null;
    }

    /**
     * Gets the particular Token
     * @return ScProfToken token 
     */
    public ScProfToken getToken()
            throws SQLException {
        return oToken;
    }

    /**
     * Refreshes the Token Pool
     * @throws SQLException If any database access error occurs.
     */
    private void refreshTokenPool()
            throws SQLException {
        ScPooledConnection pCon;
        String key = url + "|" + userName;

        ScJdbcPool conCache = ScPoolManager.lookupConnectionPool(key);
        if (conCache == null) return;

        Enumeration enum1 = conCache.getUnActiveCache().keys();

        while (enum1.hasMoreElements()) {
            pCon = (ScPooledConnection) enum1.nextElement();
            conCache.remove(pCon);
            pCon = null;
        }
        conCache = null;
    }

    /**
     * Sets the socket read timeout period. Used for Query Timeout.
     *
     * @param iTimeOut The query timeout to be set
     */
    public void setQueryTimeout(int iTimeOut) {
        this.iQueryTimeOut = iTimeOut;
    }
}

