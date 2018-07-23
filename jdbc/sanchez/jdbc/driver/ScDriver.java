/**
 * It provides six methods. One method sets up a connection between
 * a driver and a database , and the others give information about
 * the driver or get information necessary for making a connection
 * to a database.
 *
 * @version 1.0  Spet. 28 1999
 * @author Quansheng Jia
 * @see DriverManager
 */

package sanchez.jdbc.driver;

import java.lang.reflect.Constructor;
import java.sql.*;
import java.util.HashMap;
import java.util.Locale;
import java.util.Hashtable;
import java.util.Properties;
import java.util.StringTokenizer;
import java.util.logging.Logger;

import sanchez.app.ScGlobalCacheManager;
import sanchez.base.ScBundle;
import sanchez.base.ScResourceKeys;
import sanchez.him_pa.formatters.ScProfileForm;
import sanchez.him_pa.transports.ScMTMTransport;
import sanchez.him_pa.transports.ScTransport;
import sanchez.jdbc.dbaccess.ScDBAccess;
import sanchez.jdbc.dbaccess.ScDBError;
import sanchez.jdbc.thin.ScProfAccess;
import sanchez.utils.ScUtility;
import sanchez.utils.objectpool.ScObjectPool;

public class ScDriver implements Driver {
    private static Properties protocols;

    public static final String PROFILE_DRIVER_LOCALE = "profile.driver.locale";
    private static Locale driverLocale = null;

    /**
     * Class Constructor
     * @exception SQLException If any database access error occurrs
     */
    public ScDriver()
            throws SQLException {
        try {
            Class.forName("sanchez.app.ScGlobalCacheManager");
            Hashtable h = new Hashtable();
            h.put("PREPARE", "1");
            h.put("ICODE", "1");
            ScGlobalCacheManager.setObject("CONTEXT", h);
        } catch (Exception e) {
        }
    }

    /**
     * Static Initializer block to load properties 
     */
    static {
        protocols = new Properties();
        protocols.put("thin", "sanchez.jdbc.thin.ScProfAccess");
        protocols.put("oci", "sanchez.jdbc.OCIDBAccess");

        try {
            ScBundle.loadProperty();
            java.sql.DriverManager.registerDriver(new ScDriver());
        } catch (RuntimeException e1) {
            e1.printStackTrace();
        } catch (SQLException e2) {
        }
    }

    /**
     * Connects to the profile database server with properties initialized.
     * @param sUrl String
     * @param info java.util.Properties
     * @return java.sql.Connection
     * @exception SQLException when database error occurs
     */
    public java.sql.Connection connect(String sUrl, Properties info)
            throws SQLException {
        ScConnection connection;

        if (!acceptsURL(sUrl))
            return null;

        Hashtable urlProperties = parseUrl(sUrl);
        String user = info.getProperty("user");
        String password = info.getProperty("password");
        String database = info.getProperty("database");

        if (database == null)
            database = info.getProperty("server");

        if (user == null)
            user = (String) urlProperties.get("user");

        if (password == null)
            password = (String) urlProperties.get("password");

        if (database == null)
            database = (String) urlProperties.get("database");

        String protocol = (String) urlProperties.get("protocol");

        String locale = info.getProperty("locale");

        if (protocol == null)
            ScDBError.check_error(-40, "ScDriver.parseUrl");

        String access = (String) protocols.get(protocol);

        if (access == null)
            ScDBError.check_error(-40, "ScDriver.parseUrl");

        String dll_str = info.getProperty("dll");

        if (dll_str == null) {
            if (protocol.equals("oci"))
                info.put("dll", "ocijdbc");
        }

        String sTransType = info.getProperty("transType");
        String timeOut = info.getProperty("timeOut");
        String prefetch = info.getProperty("prefetch");
        String signontype = info.getProperty("signOnType");
        String timeformat = info.getProperty("timeFormat");
        String dateformat = info.getProperty("dateFormat");
        String poolsize = info.getProperty("poolSize");
        String numberformat = info.getProperty("numberFormat");

        //unicode supporting
        String fileEncod = info.getProperty("ENCODING");
        // Garbage Collection option
        String gCollect = info.getProperty("garbageCollect");
        // support store procedure
        String usesp = info.getProperty("usesp");
        // new password
        String newPWD = info.getProperty("newPWD");
        // Institution ID
        String instID = info.getProperty("instID");
        //Turn off NOMETA qualifier
        String nometa = info.getProperty("nometa");

        if (usesp == null) {
            usesp = (String) urlProperties.get("usesp");
            if (usesp != null) info.put("usesp", usesp);
        }

        if (sTransType == null) {
            sTransType = (String) urlProperties.get("transtype");
            if (sTransType != null) info.put("transType", sTransType);
        }

        if (timeOut == null) {
            timeOut = (String) urlProperties.get("timeout");
            if (timeOut != null) info.put("timeOut", timeOut);
        }

        if (prefetch == null)
            prefetch = info.getProperty("rowPrefetch");

        if (prefetch == null)
            prefetch = info.getProperty("defaultRowPrefetch");

        if (prefetch == null) {
            prefetch = (String) urlProperties.get("rowprefetch");
            if (prefetch != null) info.put("rowPrefetch", prefetch);
        }

        if (signontype == null) {
            signontype = (String) urlProperties.get("signontype");
            if (signontype != null) info.put("signOnType", signontype);
        }
        if (poolsize == null) {
            poolsize = (String) urlProperties.get("poolsize");
            if (poolsize != null) info.put("poolSize", poolsize);
        }

        if (locale == null) {
            locale = (String) urlProperties.get("locale");
            if (locale != null) info.put("locale", locale);
        }

        if (dateformat == null) {
            dateformat = (String) urlProperties.get("dateformat");
            if (dateformat != null) info.put("dateFormat", dateformat);
        }

        if (timeformat == null) {
            timeformat = (String) urlProperties.get("timeformat");
            if (timeformat != null) info.put("timeFormat", timeformat);
        }

        if (numberformat == null) {
            numberformat = (String) urlProperties.get("numberformat");
            if (numberformat != null) info.put("numberFormat", numberformat);
        }

        if (fileEncod == null) {
            fileEncod = (String) urlProperties.get("fileencoding");
            if (fileEncod != null) {
                info.put("ENCODING", fileEncod);
            }
        }

        if (gCollect == null) {
            gCollect = (String) urlProperties.get("garbagecollect");
            if (gCollect != null) {
                info.put("garbageCollect", gCollect);
                if (gCollect.equalsIgnoreCase("1"))
                    ScObjectPool.setGC(1);
                else
                    ScObjectPool.setGC(0);
            }
        } else {
            if (gCollect.equalsIgnoreCase("1"))
                ScObjectPool.setGC(1);
            else
                ScObjectPool.setGC(0);
        }

        if (newPWD == null) {
            newPWD = (String) urlProperties.get("newpwd");
            if (newPWD != null) info.put("newPWD", newPWD);
        }

        if (instID == null) {
            instID = (String) urlProperties.get("instid");
            if (instID != null) info.put("instID", instID);
        }

        if (nometa == null) {
            nometa = (String) urlProperties.get("nometa");
            if (nometa != null) {
                info.put("nometa", nometa);
                if (nometa.equalsIgnoreCase("0"))
                    ScProfAccess.set_nometa(0);
                else
                    ScProfAccess.set_nometa(1);
            }
        } else {
            if (nometa.equalsIgnoreCase("0"))
                ScProfAccess.set_nometa(0);
            else
                ScProfAccess.set_nometa(1);
        }

        if (prefetch != null && Integer.parseInt(prefetch) <= 0)
            prefetch = null;

        String batch = info.getProperty("batch");

        if (batch == null)
            batch = info.getProperty("executeBatch");

        if (batch == null)
            batch = info.getProperty("defaultExecuteBatch");

        if (batch != null && Integer.parseInt(batch) <= 0)
            batch = null;

        ScDBAccess accessor = null;
        try {
            createTrans(database, info);
        } catch (Exception e) {
            ScDBError.check_error(e);
        }

        try {
            accessor = (ScDBAccess) Class.forName(access).newInstance();
            connection = new ScConnection(accessor, sUrl, user, password, database, info);
            if (prefetch != null) {
                accessor.setDefaultRowPrefetch(Integer.parseInt(prefetch));
                connection.i_iDefaultRowPrefetch = Integer.parseInt(prefetch);
            }
            if (batch != null) {
                accessor.setDefaultExecuteBatch(Integer.parseInt(batch));
                connection.i_iDefaultBatch = Integer.parseInt(batch);
            }
        } catch (Exception e) {
            if (e.getMessage().indexOf("Object Unavailable") == 0)
                ScDBError.check_error(259);
            else ScDBError.check_error(e);
            return null;
        }

        initStoreProcedure(connection);
        return connection;
    }

    private void initStoreProcedure(ScConnection con) {
        String usesp = (String) con.info.get("usesp");
        if (usesp != null && (usesp.equalsIgnoreCase("yes") || usesp.equalsIgnoreCase("y"))) {
            String sDb = "sp|" + con.sDatabase;
            String sDb_pgm = "sp_pgm|" + con.sDatabase;
            HashMap map = (HashMap) ScGlobalCacheManager.getObject(sDb);
            HashMap pgm_map = (HashMap) ScGlobalCacheManager.getObject(sDb_pgm);
            if ((map != null) || (pgm_map != null)) return;
            try {
                Statement state = con.createStatement();
                String s = "select pid,pgm,sqlstmt,ltd,time from dbtblsp";
                ResultSet rs = state.executeQuery(s);
                map = new HashMap();
                pgm_map = new HashMap();

                while (rs.next()) {
                    String ltd = rs.getString("LTD");
                    ltd = ScUtility.JulianDate(ltd);
                    String time = rs.getString("TIME");
                    time = ScUtility.JulianTime(time, 0);
                    String pid = rs.getString("PID");
                    StringBuffer bf = new StringBuffer();
                    bf = bf.append(pid).append("-").append(ltd).append("-").append(time);
                    map.put("SELECT " + rs.getString("SQLSTMT"), bf.toString());
                    pgm_map.put(rs.getString("PGM"), bf.toString());

                }
                ScGlobalCacheManager.setObject(sDb, map);
                ScGlobalCacheManager.setObject(sDb_pgm, pgm_map);
            } catch (SQLException e) {
                e.printStackTrace();
            }

        }
    }

    /**
     * Creates Transaction with requestqueue,replyqueue,transqueue manager,TransRequestQueue,TransChannel and transaction userid and password initialized.
     * @param database
     * @param info
     * @exception SQLException If any database access error occurrs
     * @exception Exception If any other error occurs.
     */
    private void createTrans(String database, Properties info)
            throws SQLException, Exception {
        if (ScGlobalCacheManager.getObject(database) != null) return;

        int iIndex, iFirst;

        iIndex = database.indexOf(':');
        String sIPAddress = database.substring(0, iIndex);
        if (sIPAddress.equals("NULL"))
            throw new SQLException(ScBundle.getMessage(ScResourceKeys.IPAddress_not_set));

        iFirst = iIndex;
        iIndex = database.indexOf(':', iIndex + 1);
        String sTransIPPort = database.substring(iFirst + 1, iIndex);
        if (sTransIPPort.equals("NULL"))
            throw new SQLException(ScBundle.getMessage(ScResourceKeys.TransIPPort_not_set));

        int iIPPort = new Integer(sTransIPPort).intValue();

        String sProfServType = database.substring(iIndex + 1, database.length());

        String sTransType = info.getProperty("transType");
        String sPoolSize = info.getProperty("poolSize");

        if ((sTransType == null) || (sTransType.equalsIgnoreCase("MTM"))) {
            if (ScGlobalCacheManager.getObject(database) == null)
                ScGlobalCacheManager.setObject(database, new ScMTMTransport(sIPAddress, iIPPort, sProfServType, sPoolSize));
            return;
        } else if (sTransType.equalsIgnoreCase("MQSERIES")) {
            String sTransQueueManager = info.getProperty("TransQueueManager");
            if (sTransQueueManager.equals("NULL"))
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.TransQueueManager_not_set));

            String sTransRequestQueue = info.getProperty("TransRequestQueue");
            if (sTransRequestQueue.equals("NULL"))
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.TransRequestQueue_not_set));

            String sTransReplyQueue = info.getProperty("sTransReplyQueue");
            if (sTransReplyQueue.equals("NULL"))
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.TransReplyQueue_not_set));

            String sTransChannel = info.getProperty("TransChannel");
            if (sTransChannel.equals("NULL"))
                throw new SQLException(ScBundle.getMessage(ScResourceKeys.TransChannel_not_set));

            String sTransUserId = info.getProperty("TransUserId");
            if (sTransUserId.equals("NULL"))
                sTransUserId = "";

            String sTransPassword = info.getProperty("TransPassword");
            if (sTransPassword.equals("NULL"))
                sTransPassword = "";

            Class c = Class.forName("sanchez.him_pa.transports.ScMQTransport");
            Constructor con = c.getConstructor(new Class[]{int.class, String.class, String.class, String.class, String.class, String.class, String.class, String.class});
            Object[] s = {new Integer(iIPPort), sIPAddress, sTransQueueManager, sTransRequestQueue, sTransReplyQueue, sTransChannel, sTransUserId, sTransPassword};
            Object t = con.newInstance(s);
            ScTransport mt = (ScTransport) t;
            ScGlobalCacheManager.setObject(database, mt);
            return;
        }
    }

    /**
     * Checks for the validity of url format
     * @param sUrl
     * @return true or false depending on the url validity
     * @exception SQLException If any database access error occurrs
     */
    public boolean accURL(String sUrl)
            throws SQLException {
        if (sUrl.indexOf("jdbc:sanchez") > 0) return true;
        else return false;
    }

    /**
     * Check whether the format of URL is accepted.
     * @param sUrl
     * @return boolean
     * @exception SQLException If any database access error occurrs
     */
    public boolean acceptsURL(String sUrl)
            throws SQLException {
        if (sUrl.indexOf('=') > 0) return accURL(sUrl);

        int firstColon = sUrl.indexOf(58);

        if (firstColon == -1)
            return false;

        int secondColon = sUrl.indexOf(58, firstColon + 1);

        if (secondColon == -1)
            return false;

        else
            return sUrl.regionMatches(true, firstColon + 1, "sanchez", 0, secondColon - (firstColon + 1));
    }

    /**
     * Gets the information on JDBC Driver's properties
     * @param string
     * @param properties
     * @return java.sql.DriverPropertyInfo[]
     * @exception SQLException If any database access error occurrs
     */
    public java.sql.DriverPropertyInfo[] getPropertyInfo(String string, Properties properties)
            throws SQLException {
        return new java.sql.DriverPropertyInfo[0];
    }

    /**
     *  Gets the major version number
     * @return 1
     */
    public int getMajorVersion() {
        return 1;
    }

    /**
     * Gets the minor version number
     * @return 0
     */
    public int getMinorVersion() {
        return 0;
    }

    /**
     * Checks for JDBC Compliance standards
     * @return true
     */
    public boolean jdbcCompliant() {
        return true;
    }

    /**
     *Parses the URL
     *@param sUrl
     *example1: sUrl = "jdbc:sanchez:thin:@140.140.1.1:18610:sca$ibs"
     *example2: sUrl = "jdbc:sanchez:thin:4609/xxx@140.140.1.1:18610:SCA$IBS!MTM";
     *protocol: thin(pure JAVA) or oci(C lib)
     *IP address: 140.140.1.1
     *port: 18610
     *userID: 4609
     *password: xxx
     *server type: SCA$IBS
     *transaction type: MTM or MQ
     *@exception SQLException If any database access error occurrs
     */
    Hashtable parseUrl(String sUrl)
            throws SQLException {
        if (sUrl.indexOf('=') > 0) return parseUrl1(sUrl);

        Hashtable result = new Hashtable(5);
        int subIndex = sUrl.indexOf(58, sUrl.indexOf(58) + 1) + 1;
        int transign = sUrl.indexOf('!');
        int end;
        if (transign > 0) end = transign;
        else end = sUrl.length();

        if (subIndex == end)
            return result;

        int nextColonIndex = sUrl.indexOf(58, subIndex);

        if (nextColonIndex == -1)
            return result;

        result.put("protocol", sUrl.substring(subIndex, nextColonIndex));

        int user = nextColonIndex + 1;
        int slash = sUrl.indexOf(47, user);
        int atSign = sUrl.indexOf(64, user);

        if (atSign == -1)
            atSign = end;

        if (slash == -1)
            slash = atSign;

        if (user < slash)
            result.put("user", sUrl.substring(user, slash));

        if (slash < atSign)
            result.put("password", sUrl.substring(slash + 1, atSign));

        if (atSign < end)
            result.put("database", sUrl.substring((atSign + 1), end));

        if (transign > 0) result.put("transtype", sUrl.substring(transign + 1));

        return result;

    }

    /**
     *Parse URL
     *@param sUrl
     *example1: sUrl = "jdbc:sanchez:thin:@140.140.1.1:18610:sca$ibs"
     *example2: sUrl = "jdbc:sanchez:thin:4609/xxx@140.140.1.1:18610:SCA$IBS!MTM";
     *protocol: thin(pure JAVA) or oci(C lib)
     *IP address: 140.140.1.1
     *port: 18610
     *userID: 4609
     *password: xxx
     *server type: SCA$IBS
     *transaction type: MTM or MQ
     *@exception SQLException If any database access error occurrs
     */
    Hashtable parseUrl1(String sUrl)
            throws SQLException {
        StringTokenizer parserSlash = new StringTokenizer(sUrl, "|", false);
        StringTokenizer parserEqual = new StringTokenizer(sUrl, "=", false);
        if ((parserEqual.countTokens() > 1) && (parserSlash.countTokens() <= 1)) {
            parserSlash = new StringTokenizer(sUrl, "/", false);
            if (parserSlash.countTokens() <= 1) parserSlash = new StringTokenizer(sUrl, "\\", false);
            if (parserSlash.countTokens() <= 1) ScDBError.check_error(-57, sUrl);
        }
        if ((parserEqual.countTokens()) != (parserSlash.countTokens() + 1))
            ScDBError.check_error(-57, sUrl);

        Hashtable pro = new Hashtable(5);
        String s;
        int i;
        while (parserSlash.hasMoreTokens()) {
            s = parserSlash.nextToken();
            i = s.indexOf('=');
            pro.put(s.substring(0, i).trim().toLowerCase(), s.substring(i + 1, s.length()).trim());

        }
        pro.put("protocol", "thin");
        return pro;

    }

    public static Locale getDriverLocale() {
        if (driverLocale != null)
            return driverLocale;
        //initialize first to JVM locale
        driverLocale = Locale.getDefault();
        //look for driver level locale
        String profileDriverLocale = System.getProperty(ScDriver.PROFILE_DRIVER_LOCALE);
        if (profileDriverLocale != null) {
            String languageCountry[] = profileDriverLocale.split("_");
            if (languageCountry.length == 2) {
                driverLocale = new Locale(languageCountry[0], languageCountry[1], "");
            }
        }
        return driverLocale;
    }

    @Override
    public Logger getParentLogger() {
        return null;
    }
}

