package sanchez.jdbc.dbaccess;

import java.io.IOException;
import java.sql.BatchUpdateException;
import java.sql.SQLException;
import java.text.MessageFormat;
import java.lang.String;
import java.util.StringTokenizer;

import sanchez.base.ScBundle;
import sanchez.base.ScResourceKeys;
import sanchez.him_pa.ScProfileException;
import sanchez.jdbc.driver.ScDriver;

import java.io.*;
import java.util.Locale;
import java.util.MissingResourceException;
import java.util.ResourceBundle;

public class ScDBError {
    public static final String MESSAGE_RESOURCE = "Resource";
    public final static int errorRecord = 56;
    public final static String[] errorMessage = new String[errorRecord];
    public final static String UNKNOWN_SQL_ERROR = "unknownSqlError";
    public final static String MISSING_RESOURCE = "missingResource";
    public final static String NULL_RESOURCE = "nullResource";
    private static String fEncoding = "";

    /**
     * Class Constructor
     */
    public ScDBError() {
        errorMessage[0] = ScBundle.getMessage(ScResourceKeys.errorMessage_0);
        errorMessage[1] = ScBundle.getMessage(ScResourceKeys.errorMessage_1);
        errorMessage[2] = ScBundle.getMessage(ScResourceKeys.errorMessage_2);
        errorMessage[3] = ScBundle.getMessage(ScResourceKeys.errorMessage_3);
        errorMessage[4] = ScBundle.getMessage(ScResourceKeys.errorMessage_4);
        errorMessage[5] = ScBundle.getMessage(ScResourceKeys.errorMessage_5);
        errorMessage[6] = ScBundle.getMessage(ScResourceKeys.errorMessage_6);
        errorMessage[7] = ScBundle.getMessage(ScResourceKeys.errorMessage_7);
        errorMessage[8] = ScBundle.getMessage(ScResourceKeys.errorMessage_8);
        errorMessage[9] = ScBundle.getMessage(ScResourceKeys.errorMessage_9);
        errorMessage[10] = ScBundle.getMessage(ScResourceKeys.errorMessage_10);
        errorMessage[11] = ScBundle.getMessage(ScResourceKeys.errorMessage_11);
        errorMessage[12] = ScBundle.getMessage(ScResourceKeys.errorMessage_12);
        errorMessage[13] = ScBundle.getMessage(ScResourceKeys.errorMessage_13);
        errorMessage[14] = ScBundle.getMessage(ScResourceKeys.errorMessage_14);
        errorMessage[15] = ScBundle.getMessage(ScResourceKeys.errorMessage_15);
        errorMessage[16] = ScBundle.getMessage(ScResourceKeys.errorMessage_16);
        errorMessage[17] = ScBundle.getMessage(ScResourceKeys.errorMessage_17);
        errorMessage[18] = ScBundle.getMessage(ScResourceKeys.errorMessage_18);
        errorMessage[19] = ScBundle.getMessage(ScResourceKeys.errorMessage_19);
        errorMessage[20] = ScBundle.getMessage(ScResourceKeys.errorMessage_20);
        errorMessage[21] = ScBundle.getMessage(ScResourceKeys.errorMessage_21);
        errorMessage[22] = ScBundle.getMessage(ScResourceKeys.errorMessage_22);
        errorMessage[23] = ScBundle.getMessage(ScResourceKeys.errorMessage_23);
        errorMessage[24] = ScBundle.getMessage(ScResourceKeys.errorMessage_24);
        errorMessage[25] = ScBundle.getMessage(ScResourceKeys.errorMessage_25);
        errorMessage[26] = ScBundle.getMessage(ScResourceKeys.errorMessage_26);
        errorMessage[27] = ScBundle.getMessage(ScResourceKeys.errorMessage_27);
        errorMessage[28] = ScBundle.getMessage(ScResourceKeys.errorMessage_28);
        errorMessage[29] = ScBundle.getMessage(ScResourceKeys.errorMessage_29);
        errorMessage[30] = ScBundle.getMessage(ScResourceKeys.errorMessage_30);
        errorMessage[31] = ScBundle.getMessage(ScResourceKeys.errorMessage_31);
        errorMessage[32] = ScBundle.getMessage(ScResourceKeys.errorMessage_32);
        errorMessage[33] = ScBundle.getMessage(ScResourceKeys.errorMessage_33);
        errorMessage[34] = ScBundle.getMessage(ScResourceKeys.errorMessage_34);
        errorMessage[35] = ScBundle.getMessage(ScResourceKeys.errorMessage_35);
        errorMessage[36] = ScBundle.getMessage(ScResourceKeys.errorMessage_36);
        errorMessage[37] = ScBundle.getMessage(ScResourceKeys.errorMessage_37);
        errorMessage[38] = ScBundle.getMessage(ScResourceKeys.errorMessage_38);
        errorMessage[42] = ScBundle.getMessage(ScResourceKeys.errorMessage_42);
        errorMessage[43] = ScBundle.getMessage(ScResourceKeys.errorMessage_43);
        errorMessage[44] = ScBundle.getMessage(ScResourceKeys.errorMessage_44);
        errorMessage[45] = ScBundle.getMessage(ScResourceKeys.errorMessage_45);
        errorMessage[46] = ScBundle.getMessage(ScResourceKeys.errorMessage_46);
        errorMessage[47] = ScBundle.getMessage(ScResourceKeys.errorMessage_47);
        errorMessage[48] = ScBundle.getMessage(ScResourceKeys.errorMessage_48);
        errorMessage[49] = ScBundle.getMessage(ScResourceKeys.errorMessage_49);
        errorMessage[50] = ScBundle.getMessage(ScResourceKeys.errorMessage_50);
        errorMessage[51] = ScBundle.getMessage(ScResourceKeys.errorMessage_51);
        errorMessage[52] = ScBundle.getMessage(ScResourceKeys.errorMessage_52);
        errorMessage[53] = ScBundle.getMessage(ScResourceKeys.errorMessage_53);
        errorMessage[54] = ScBundle.getMessage(ScResourceKeys.errorMessage_54);
        errorMessage[55] = ScBundle.getMessage(ScResourceKeys.errorMessage_55);
    }

    /**
     * Main method
     *
     * @param mess message in string format
     * @throws throws java.lang.SQLException
     */
    private static void mutipleError(String mess)
            throws SQLException {
        int vendorCode = 0;
        String code = mess.substring(0, mess.indexOf("|"));
        String errorText = mess.substring(mess.indexOf("|") + 1);

        try {
            String er = code.substring(code.indexOf("_") + 1, code.length());
            vendorCode = Integer.parseInt(er.trim());

        } catch (Exception e1) {
            vendorCode = 0;
        }
        SQLException e = new SQLException(errorText, code, vendorCode);

        StringTokenizer o = new StringTokenizer(errorText, "\n", false);

        String s;
        int i;

        while (o.hasMoreElements()) {
            s = (String) o.nextElement();
            i = s.indexOf("|");
            if (i > 0) {
                String subCode = s.substring(0, i);
                String subErrorText = s.substring(i + 1);
                e.setNextException(new SQLException(subErrorText, subCode, 0));
            }
        }
        throw e;
    }

    public static void set_encoding(String encoding) {
        if (encoding == null)
            fEncoding = "ISO8859_1";
        else
            fEncoding = encoding;
    }

    /*
     * 		Check errors
     *      @param e Exception
     *
     */
    public static void check_error(Exception e)
            throws SQLException {
        String mess = e.getMessage();
        error(e);

        if (mess.startsWith("RFLG_1000") || mess.startsWith("OVR_1000") || mess.startsWith("XBAD_1000"))
            mutipleError(mess);

        if (e instanceof ScProfileException) {
            if (mess.indexOf("|") > 0) {
                String code = mess.substring(0, mess.indexOf("|"));
                String errorText = mess.substring(mess.indexOf("|") + 1, mess.length());
                int vendorCode = 0;

                if (code.indexOf("RFLG_") < 0 && code.indexOf("MSG_") < 0 && code.indexOf("OVR_") < 0 && code.indexOf("XBAD_") < 0)
                    throw new SQLException(mess);

                try {
                    String er = code.substring(code.indexOf("_") + 1, code.length());
                    vendorCode = Integer.parseInt(er.trim());

                }//try
                catch (Exception e1) {
                    vendorCode = 0;
                }
                throw new SQLException(errorText, code, vendorCode);
            }//if
            throw new SQLException(mess);
        } else throw new SQLException(mess);
    }

    /**
     * Throws appropriate Error Messages depending on the status
     *
     * @param status
     * @param What
     * @return int
     * @throws throws SQLException
     *                executeUpdate allowed select query. Additional
     *                check incorporated to block select and open. case -59
     *                <p>
     *                setFetchDirection allowed invalid directions.Additional
     *                check incorporated to block invalid directions. case -60
     *                <p>
     *                Statement setMaxFieldSize did not have a check for invalid
     *                Max Field Size. Incorporated the check. case -61
     *                <p>
     *                Statement setMaxRows did not have a check for invalid Max Rows.
     *                Incorporated the check. acse -62
     *                <p>
     *                ResultSet setFetchSize did not have a check for invalid Max Fetch Size.
     *                Incorporated the check. acse -63
     *                <p>
     *                Prepared Statement execute methods did not have any check to
     *                validate whether all the parameters are set prior to the
     *                execute call. Incorporated the check : case -64
     *                <p>
     *                Sets the socket read timeout period. Used for Query Timeout.
     */
    public static int check_error(int status, Object what)
            throws SQLException {
        if (status >= 0)
            return status;

        Object[] obj = {what};

        switch (status) {
            case -3:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_column_index));

            case -4:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_column_type));

            case -5:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Unsupported_column_type));

            case -6:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_column_name));

            case -7:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_dynamic_column));

            case -8:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Closed_Connection));

            case -9:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Closed_Statement));

            case -10:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Closed_Resultset));

            case -11:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Exhausted_Resultset));

            case -12:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Parameter_Type_Conflict));

            case -13:
                return status;

            case -14:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.ResultSet_next_was_not_called));

            case -15:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Statement_was_cancelled));

            case -16:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Statement_timed_out));

            case -17:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Cursor_already_initialized));

            case -18:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_cursor));

            case -19:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Can_only_describe_a_query));

            case -20:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_row_prefetch));

            case -21:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Missing_defines));

            case -22:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Missing_defines_at_index, obj));

            case -23:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Unsupported_feature));

            case -24:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.No_data_read));

            case -25:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Error_in_defines_isNull));

            case -26:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Numeric_Overflow));

            case -27:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Stream_has_already_been_closed));

            case -28:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Current_ResultSet_is_closed));

            case -29:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Read_only_connections_not_supported));

            case -30:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.TRANSACTION_READ_UNCOMMITTED));

            case -31:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Auto_close_mode_on));

            case -32:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Cannot_set_row_prefetch_to_zero));

            case -33:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Malformed_SQL92_string_at_position, obj));

            case -34:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Non_supported_SQL92_token_at_position, obj));

            case -35:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Character_Set_Not_Supported));

            case -36:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Exception_in_OracleNumber));

            case -37:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Fail_to_convert_between_UTF8_and_UCS2));

            case -38:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Byte_array_not_long_enough));

            case -39:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Char_array_not_long_enough));

            case -40:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Sub_Protocol_must_be_specified));

            case -41:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Missing_IN_or_OUT_parameter, obj));

            case -42:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_Batch_Value));

            case -43:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_stream_maximum_size));

            case -45:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Attempt_to_access_bind_values));

            case -44:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Data_array_not_allocated));

            case -46:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_index_for_data_access));

            case -50:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Auto_commit_mode));

            case -51:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.setAciiStream_error));

            case -52:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Driver_dont_support_the_API, obj));

            case -53:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.FETCH_REVERSE));

            case -54:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.TYPE_SCROLL_INSENSITIVE));

            case -55:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.CONCUR_READ_ONLY, obj));

            case -56:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Method_is_not_valid, obj));

            case -57:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_URL_syntax, obj));

            case -58:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Cannot_create_a_connection, obj));

            case -59:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.ResultSet_Operations, obj));

            case -60:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.ResultSet_FETCH_FORWARD));

            case -61:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_Max_Field_Size, obj));

            case -62:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_Max_Row_Size, obj));

            case -63:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_Max_Fetch_Size, obj));

            case -64:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Not_All_parameter_set, obj));

            case -65:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Query_Timeout_Interval, obj));

            case -66:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Class_Cast_Exception, obj));

            case -67:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Cannot_call_getMetaData, obj));

            case -84:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Unsupported_operation, obj));

            case -86:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.getGeneratedKeys_support, obj));

            default:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Unknown_SQL_error));
        }
    }

    /**
     * executeBatch was allowing operations returning resultset.
     * Incorporated check to block such operations.
     *
     * @param code
     * @param exception
     * @param iBatchCount
     * @param iUpdateCount
     * @throws throws BatchUpdateException
     */
    public static void throwBatchUpdateException(int code, String exception,
                                                 int iBatchCount, int[] iUpdateCount) throws BatchUpdateException {
        BatchUpdateException batchUpdateException = null;
        switch (code) {
            case -1:
                batchUpdateException = new BatchUpdateException(("Invalid batch command - " + exception), iUpdateCount);
                throw batchUpdateException;

            case -2:
                batchUpdateException = new BatchUpdateException(("Error occurred while executing the batch - " + exception), iUpdateCount);
                throw batchUpdateException;

            default:
                batchUpdateException = new BatchUpdateException(exception, iUpdateCount);
                throw batchUpdateException;
        }
    }

    /**
     * Throws appropriate error messages depending on the code.
     *
     * @param code
     * @throws throws SQLException
     */
    public static void check_error(int code)
            throws SQLException {
        switch (code) {
            case 1:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Protocol_violation));

            case 2:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Physical_Connection_doesnt_exist));

            case 3:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Listener_Hashtable_Null));

            case 10:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.RPA_message));

            case 20:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.RXH_message));

            case 30:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Received_more_RXDs_than_expected));

            case 40:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.UAC_length_is_not_zero));

            case 100:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_Type_Representation_setRep));

            case 101:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_Type_Representation_getRep));

            case 102:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_buffer_length));

            case 103:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.No_more_data_to_read_from_socket));

            case 104:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Data_Type_representations_mismatch));

            case 105:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Bigger_type_length_than_Maximum));

            case 106:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Exceeding_key_size));

            case 107:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Insufficient_Buffer_size));

            case 108:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.This_type_hasnt_been_handled));

            case 109:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.FATAL));

            case 110:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.NLS_Problem));

            case 111:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Field_length_error));

            case 112:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_number_of_columns_returned));

            case 200:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Logon_must_be_called_after_connect));

            case 201:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Must_be_at_least_connected_to_server));

            case 202:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Must_be_logged_on_to_server));

            case 203:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.SQL_Statement_to_parse_is_null));

            case 204:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_options_in_all7));

            case 205:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_arguments_in_call));

            case 206:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Not_in_streaming_mode));

            case 207:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_number_of_in_out_binds_in_IOV));

            case 208:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_number_of_outbinds));

            case 209:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Error_in_PLSQL_block));

            case 210:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Unexpected_value));

            case 255:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.No_message_defined_for_this_error));

            case 256:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Parameter_not_defined));

            case 257:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.ResultSet_may_NOT_be_updated));

            case 258:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.CONCUR_READ_ONLY_ResultSet));

            case 259:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Server_can_not_be_connected));

            case 260:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Missed_username_or_password));

            case 261:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Do_not_call_the_methods));

            case 262:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.TYPE_FORWARD_ONLY));

            case 263:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Read_failed));

            case 264:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_parameter_number));

            case 265:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_CallableStatement));

            case 266:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Miss_IP_address));

            case 267:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Miss_port_number));

            case 268:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Miss_databaseName));

            case 270:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Invalid_Arguments));

            default:
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.Unknown_SQL_error));
        }
    }

    public static String getErrorMessage(int error_code) {
        return errorMessage[error_code];
    }

    /**
     * Converts SQLException to IOException
     *
     * @param e
     * @throws IOException
     */
    public static void SQLToIOException(SQLException e)
            throws IOException {
        throw new IOException(e.getMessage());
    }

    /**
     * static getMethod
     *
     * @return String
     */
    private static String getMethod() {
        try {
            Throwable thThis = new Throwable();

            StringWriter oWriter = new StringWriter();
            PrintWriter oNew = new PrintWriter(oWriter);

            thThis.printStackTrace(oNew);

            String sTemp = oWriter.toString();

            sTemp = sTemp.substring(sTemp.indexOf("\r", sTemp.indexOf("\r") + 1), sTemp.length());
            sTemp = sTemp.substring(sTemp.indexOf("\r", sTemp.indexOf("\r") + 1), sTemp.indexOf("\r", sTemp.indexOf("\r", sTemp.indexOf("\r") + 1) + 1));
            sTemp = sTemp.substring(sTemp.indexOf("at ") + 3, sTemp.length());
            return sTemp;
        } catch (Exception eError) {
            return "Class Unknown";
        }
    }

    static FileWriter i_oErrorFile = null;

    static {
        try {
            i_oErrorFile = new FileWriter("jdbc_error.log", false);
        } catch (Exception e) {
        }
    }

    /**
     * Determines if error or not
     *
     * @param aMsg
     * @return boolean
     */
    public static boolean error(Exception aMsg) {
        try {
            String sInfo, sMethod;
            sMethod = getMethod();

            StringWriter oWriter = new StringWriter();
            PrintWriter oNew = new PrintWriter(oWriter);

            aMsg.printStackTrace(oNew);
            String sTemp = oWriter.toString();

            java.util.Date dNow = new java.util.Date();

            sInfo = " <IN:" + sMethod + ";" + dNow.toString() + ">";

            try {
                i_oErrorFile.write("\r\nError:" + sInfo + "\r\n " + sTemp);
                i_oErrorFile.flush();
            } catch (IOException ex) {
                System.out.println(ScBundle.getMessage(ScResourceKeys.Error_writing));
            }
            return true;
        } catch (Exception e) {
            return true;
        }
    }
}

