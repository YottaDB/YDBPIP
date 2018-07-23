package sanchez.utils;

import java.sql.SQLException;

import sanchez.jdbc.dbaccess.ScDBError;

public class ScSqlFormat {
    int iCurrentArgument;
    int i;
    int iLength;
    char c;
    boolean bFirst;
    boolean bInString;
    String sOdbcSql;
    StringBuffer sbScSql;
    StringBuffer sbTokenBuffer;

    public ScSqlFormat() {
        sbScSql = new StringBuffer(128);
        sbTokenBuffer = new StringBuffer(32);
    }

    public String parse(String os)
            throws SQLException {
        iCurrentArgument = 1;
        i = 0;
        bFirst = true;
        bInString = false;
        iLength = sOdbcSql.length();
        sbScSql.ensureCapacity(iLength);
        sbScSql.setLength(0);
        sOdbcSql = os;
        handleODBC();

        if (i < iLength) {
            Integer index = new Integer(i);
            ScDBError.check_error(-33, index);
        }
        return sbScSql.toString();
    }

    void handleODBC()
            throws SQLException {
        String s;
        while (i < iLength) {
            c = sOdbcSql.charAt(i);
            if (bInString) {
                sbScSql.append(c);
                if (c == 39)
                    bInString = false;
                i++;
            } else {
                switch (c) {
                    case 39:
                        sbScSql.append(c);
                        bInString = true;
                        i++;
                        bFirst = false;
                        break;

                    case 123:
                        sbTokenBuffer.setLength(0);
                        i++;

                        skipSpace();
                        for (; i < iLength && (Character.isJavaLetterOrDigit(c = sOdbcSql.charAt(i)) || c == 63); i++)
                            sbTokenBuffer.append(c);
                        handleToken(sbTokenBuffer.toString());
                        c = sOdbcSql.charAt(i);
                        if (c != 125) {
                            s = new String(i + ": Expecting \"}\" got \"" + c + "\"");
                            ScDBError.check_error(-33, s);
                        }
                        i++;
                        break;

                    case 125:
                        return;

                    default:
                        appendChar(sbScSql, c);
                        i++;
                        bFirst = false;
                        break;
                }
            }
        }
    }


    void handleToken(String token)
            throws SQLException {
        if (token.equalsIgnoreCase("?")) {
            handleFunction();
            return;
        }
        if (token.equalsIgnoreCase("call")) {
            handleCall();
            return;
        }

        if (token.equalsIgnoreCase("ts")) {
            handleTimestamp();
            return;
        }

        if (token.equalsIgnoreCase("t")) {
            handleTime();
            return;
        }

        if (token.equalsIgnoreCase("d")) {
            handleDate();
            return;
        }

        if (token.equalsIgnoreCase("escape")) {
            handleEscape();
            return;
        }

        String s = new String(i + ": " + token);
        ScDBError.check_error(-34, s);
    }

    void handleFunction()
            throws SQLException {
        boolean need_block = bFirst;
        if (need_block)
            sbScSql.append("BEGIN ");
        appendChar(sbScSql, '?');
        skipSpace();

        if (c != 61) {
            String s = new String(i + ". Expecting \"=\" got \"" + c + "\"");
            ScDBError.check_error(-33, s);
        }

        i++;
        skipSpace();

        if (!sOdbcSql.startsWith("call", i)) {
            String s = new String(i + ". Expecting \"call\"");
            ScDBError.check_error(-33, s);
        }

        i += 4;
        sbScSql.append(" := ");
        skipSpace();
        handleODBC();

        if (need_block)
            sbScSql.append("; END;");
    }

    void handleCall()
            throws SQLException {
        boolean need_block = bFirst;
        if (need_block)
            sbScSql.append("BEGIN ");
        skipSpace();
        handleODBC();
        skipSpace();

        if (need_block)
            sbScSql.append("; END;");
    }

    void handleTimestamp()
            throws SQLException {
        sbScSql.append("TO_DATE (");
        skipSpace();

        boolean in_nanos = false;
        for (; i < iLength && (c = sOdbcSql.charAt(i)) != 125; i++) {
            if (!in_nanos) {
                if (c == 46)
                    in_nanos = true;
                else
                    sbScSql.append(c);
            }
        }

        if (in_nanos)
            sbScSql.append('\'');
        sbScSql.append(", 'YYYY-MM-DD HH24:MI:SS')");
    }

    void handleTime()
            throws SQLException {
        sbScSql.append("TO_DATE (");
        skipSpace();
        handleODBC();
        sbScSql.append(", 'HH24:MI:SS')");
    }

    void handleDate()
            throws SQLException {

        sbScSql.append("TO_DATE (");
        skipSpace();
        handleODBC();
        sbScSql.append(", 'YYYY-MM-DD')");
    }

    void handleEscape()
            throws SQLException {
        sbScSql.append("ESCAPE ");
        skipSpace();
        handleODBC();
    }

    String nextArgument() {
        String result = ":" + iCurrentArgument;
        iCurrentArgument++;
        return result;
    }

    void appendChar(StringBuffer sbScSql, char c) {
        if (c == 63) {
            sbScSql.append(nextArgument());
            return;
        }

        sbScSql.append(c);
    }

    void skipSpace() {
        for (i++; i < iLength && (c = sOdbcSql.charAt(i)) == 32; i++) /* null body */ ;
    }

}

