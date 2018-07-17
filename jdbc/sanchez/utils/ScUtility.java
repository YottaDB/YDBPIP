package sanchez.utils;

/**
 * Utility for GAEA
 *
 * @author Quansheng Jia
 * @version 1.0 4th June 1999
 */

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.text.DateFormat;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Enumeration;
import java.util.GregorianCalendar;
import java.util.Hashtable;
import java.util.Locale;
import java.util.Random;
import java.util.StringTokenizer;
import java.util.Vector;
import java.util.Date;

import sanchez.base.ScObject;
import sanchez.base.ScBundle;
import sanchez.base.ScResourceKeys;

/**
 * Utility class for formatting date, number etc. Deep copy of Objects
 * and other helper ( utility) methods.
 *
 * @author
 * @version 1.0
 * @since 1.0
 */
public class ScUtility extends ScObject {
    private static Random generator = new Random();

    /**
     * It takes a number and locale as a input and format the
     * number using NumberFormat class.
     *
     * @param    a_dNumber    The Number to be formatted
     * @param    a_oLocale    The Locale from which the number format to be derived
     * @return String        The Formatted Number
     *
     * @see NumberFormat
     */
    public static String getFormattedNumber(double a_dNumber, Locale a_oLocale) {
        NumberFormat nf = NumberFormat.getInstance(a_oLocale);
        return nf.format(a_dNumber);
    }

    /**
     * Formats input date in the format specified and local constants.
     *
     * @param a_sDate                Date to be formatted in the format of
     * 								MM/DD/YYYY or MM/DD/YY or m/d/yyyy or m/d/yy
     * @param l                        Locale to format the Date Constants
     * @param a_sDisplayDateFormat    The format ion which the date is required
     * @return String                Formated Date
     *
     * @see GregorianCalendar
     * @see SimpleDateFormat
     */
    public static String getDisplayDate(String a_sDate, Locale l, String a_sDisplayDateFormat) {
        String year = a_sDate.substring(a_sDate.lastIndexOf("/") + 1);
        String month = a_sDate.substring(0, a_sDate.indexOf("/"));
        String date = a_sDate.substring(a_sDate.indexOf("/") + 1, a_sDate.lastIndexOf("/"));
        int i_year = Integer.parseInt(year);
        int i_month = Integer.parseInt(month);
        i_month--;
        int i_date = Integer.parseInt(date);
        GregorianCalendar gc = new GregorianCalendar(i_year, i_month, i_date);
        Date d = gc.getTime();
        DateFormat df = new SimpleDateFormat(a_sDisplayDateFormat, l);
        return df.format(d);
    }

    /**
     * Takes date and locale as input and get the Jdbc date
     * @param a_sDate        Date to be formatted in the format of
     * 						MM/DD/YYYY or MM/DD/YY or m/d/yyyy or m/d/yy
     * @param l                Locale to format the Date Constants
     * @return String        Formatted Date in the form of "dd MMM yyyy"
     */
    public static String getJdbcDate(String a_sDate, Locale l) {
        // Date should come in as MM/DD/YYYY
        String year = a_sDate.substring(a_sDate.lastIndexOf("/") + 1);
        String month = a_sDate.substring(0, a_sDate.indexOf("/"));
        String date = a_sDate.substring(a_sDate.indexOf("/") + 1, a_sDate.lastIndexOf("/"));
        int i_year = Integer.parseInt(year);
        int i_month = Integer.parseInt(month);
        i_month--;
        int i_date = Integer.parseInt(date);
        GregorianCalendar gc = new GregorianCalendar(i_year, i_month, i_date);
        Date d = gc.getTime();
        DateFormat df = new SimpleDateFormat(ScISKeys.JDBC_DATE_FORMAT, l);
        return df.format(d);
    }

    /**
     * This method converts JulianDate to Java Date
     * @param sJulianDate    The Julian Date
     * @return Date        java.util.Date
     */
    public static Date julianDateToJavaDate(String sJulianDate) {
        try {
            int year = 0, mm = 0, dd = 0;
            String stringDate;
            try {
                stringDate = JulianDate(sJulianDate);
            } catch (NumberFormatException nfe) {
                stringDate = sJulianDate;
            }

            String delimiter = "/";
            if (stringDate.indexOf("/", 0) > 0)
                delimiter = "/"; //delimiter is "front slash"
            else if (stringDate.indexOf("\\", 0) > 0)
                delimiter = "\\"; //delimiter is "back slash"
            else if (stringDate.indexOf("-", 0) > 0)
                delimiter = "-";    //delimiter is "-"
            else if (stringDate.indexOf(" ", 0) > 0)
                delimiter = " ";    //delimiter is "space"

            String tokens[] = tokenParser(stringDate, delimiter);

            //if(tokens.length <3)
            // throw new ScUtilsException((3-tokens.length) + " elements of date are missing.");

            if (tokens[0].length() == 4) {
                //if the first element is year (year/month/day)
                year = Integer.valueOf(tokens[0]).intValue();
                mm = Integer.valueOf(tokens[1]).intValue();
                dd = Integer.valueOf(tokens[2]).intValue();
            } else {
                //if the first element is month (month/day/year)
                mm = Integer.valueOf(tokens[0]).intValue();
                dd = Integer.valueOf(tokens[1]).intValue();
                year = Integer.valueOf(tokens[2]).intValue();
            }

            try {
                java.text.DateFormat dDate = new java.text.SimpleDateFormat("dd MM yyyy");
                return dDate.parse(dd + " " + mm + " " + year);
            } catch (java.text.ParseException e) {
                return null;
            }
        } catch (Exception e) {
            return new Date();
        }
    }

    /**
     * This method converts JavaDate to Julian Date
     * @param dJavaDate    java.util.Date
     * @return String The Corresponding Julian Date
     */
    public static String JavaDateToJulianDate(java.util.Date dJavaDate) {
        DateFormat df = new SimpleDateFormat("yyyy-MM-dd", Locale.US);
        return JulianDate(df.format(dJavaDate));
        /*
        int year,mm,dd;
        return  JulianDate((dJavaDate.getYear()+1900)+"/"+(dJavaDate.getMonth()+1)+"/"+dJavaDate.getDate());
        */
    }

    /**
     * This method converts julian time to java time
     * @param sJulianTime    The String Julian Time
     * @return java.sql.Time Corresponding java.sql.Time Time
     */
    public static java.sql.Time julianTimeToJavaTime(String sJulianTime) {
        return java.sql.Time.valueOf(JulianTime(sJulianTime, 4));
    }

    /**
     * This method converts java time to julian time.
     * @param dJavaTime The Java Date to be converted
     * @return String The Corresponding Julian Time
     */
    public static String JavaTimeToJulianTime(Date dJavaTime) {
        return JulianTime(dJavaTime.toString(), 0);
    }

    /**
     * This method padds a sql String with required escape characters.
     * @param a_sValue The String SQL to be padded
     * @return String The Padded String
     */
    public static String getSQLValue(String a_sValue) {
        if (a_sValue.equals(null) || a_sValue.length() == 0) return "";
        String sValue = "";

        for (int x = 0; x < a_sValue.length(); x++) {
            if (a_sValue.charAt(x) == '\'') {
                sValue = sValue + "''";
            } else {
                sValue = sValue + a_sValue.charAt(x);
            }
        }
        return sValue;
    }

    /**
     * This method checks whether the given argument is null or empty string.
     *
     * @param a_sString java.lang.String to be validated
     * @return boolean  true if a_sString is null or empty string.
     * 					false otherwise.
     */
    public static boolean checkForNullOrEmptyStr(String a_sString) {
        if ((a_sString == null) || (a_sString.equalsIgnoreCase("")))
            return true;
        return false;
    }

    /** Converts following formats to julian date
     * yyyyy/mm/dd, yyyy/m/dd, yyyy/mm/d, yyyy/m/d, mm/dd/yyyy,m/dd/yyyy, mm/d/yyyy, m/d/yyyy
     * yyyy-mm-dd, yyyy-m-dd, yyyy-mm-d, yyyy-m-d, mm-dd-yyyy,m-dd-yyyy, mm-d-yyyy, m-d-yyyy
     * yyyyy\mm\dd, yyyy\m\dd, yyyy\mm\d, yyyy\m\d, mm\dd\yyyy,m\dd\yyyy, mm\d\yyyy, m\d\yyyy
     * yyyyy mm dd, yyyy m dd, yyyy mm d, yyyy m d, mm dd yyyy,m dd yyyy, mm d yyyy, m d yyyy
     *
     *
     * @history 07201999 modified by Basavaraj Patil
     * @see
     * @bug
     *     01: (07191999) faild to parse stingDate with 8<size <10
     *
     */

    private static String date_to_julian(String stringDate) throws ScUtilsException {
        int year = 0, mm = 0, dd = 0;

        int days = 0;   /* days have elasped since Jan,1 1841 */

        int noleapdaysPerMonth[] = {0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334};
        int leapdaysPerMonth[] = {0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335};

        String delimiter = null;
        if (stringDate.indexOf("/", 0) > 0)
            delimiter = "/"; //delimiter is "front slash"
        else if (stringDate.indexOf("\\", 0) > 0)
            delimiter = "\\"; //delimiter is "back slash"
        else if (stringDate.indexOf("-", 0) > 0)
            delimiter = "-";    //delimiter is "-"
        else if (stringDate.indexOf(" ", 0) > 0)
            delimiter = " ";    //delimiter is "space"

        String tokens[] = tokenParser(stringDate, delimiter);

        if (tokens.length < 3) {
            throw new ScUtilsException((3 - tokens.length)
                    + ScBundle.getMessage(ScResourceKeys.Date_Missing));
        }

        if (tokens[0].length() == 4) {
            //if the first element is year (year/month/day)
            year = Integer.valueOf(tokens[0]).intValue();
            mm = Integer.valueOf(tokens[1]).intValue();
            dd = Integer.valueOf(tokens[2]).intValue();
        } else {
            //if the first element is month (month/day/year)
            mm = Integer.valueOf(tokens[0]).intValue();
            dd = Integer.valueOf(tokens[1]).intValue();
            year = Integer.valueOf(tokens[2]).intValue();
        }
		/*
		else
		{	
			//if the first element is day (day/month/year)
			dd   = Integer.valueOf(tokens[0]).intValue();
			mm   = Integer.valueOf(tokens[1]).intValue();
			year = Integer.valueOf(tokens[2]).intValue();
		}
		*/


        /* Is this year a leap year? And get days in current year */
        if (year % 400 == 0 || (year % 4 == 0 && (year % 100 != 0)))
            days = dd + leapdaysPerMonth[mm - 1];
        else
            days = dd + noleapdaysPerMonth[mm - 1];

        /* days in normal 365 days year */
        days = days + (year - 1841) * 365;

        /* add one day for each leap year whiout considering current year */
        days = days + (year - 1841) / 4;

        /* subtract one day for each century */
        days = days - ((year - 1) / 100 - 18);

        /* add one day for each fourth century */
        days = days + ((year - 1) / 400 - 4);

        Integer iTemp = new Integer(days);
        return iTemp.toString();
    }

    /**
     * This function is used to convert mumps date to gregorian date or
     * gregorian date to mumps. If the date is in /FORMAT=NNNNN it gets
     * converted to MM/DD/YYYY format and vice versa.
     *
     * 	Converts following formats to julian date:
     * yyyyy/mm/dd, yyyy/m/dd, yyyy/mm/d, yyyy/m/d, mm/dd/yyyy,m/dd/yyyy, mm/d/yyyy, m/d/yyyy
     * yyyy-mm-dd, yyyy-m-dd, yyyy-mm-d, yyyy-m-d, mm-dd-yyyy,m-dd-yyyy, mm-d-yyyy, m-d-yyyy
     * yyyyy\mm\dd, yyyy\m\dd, yyyy\mm\d, yyyy\m\d, mm\dd\yyyy,m\dd\yyyy, mm\d\yyyy, m\d\yyyy
     * yyyyy mm dd, yyyy m dd, yyyy mm d, yyyy m d, mm dd yyyy,m dd yyyy, mm d yyyy, m d yyyy
     *
     * @parm String    string date
     *
     * @return String    Number of Days since 12/31/1840 or String Date Translation of Mumps Julian Date
     *					Otherwise null incase of any error.
     *
     *History         : 07201999 modified by Basavaraj Patil
     *
     *see:
     *Bug:
     *
     */
    public static String JulianDate(String a_sDate) {

        if (a_sDate.equalsIgnoreCase(null) || a_sDate.equalsIgnoreCase("")) return null;

        try {
            if ((a_sDate.indexOf("/") > 0) || (a_sDate.indexOf("-") > 0))
                return date_to_julian(a_sDate);
            else
                return julianToDate(a_sDate);
        } catch (ScUtilsException sue) {
            //this Exception must be propagated upward!!
            //ScDebug.setDebugln(ScISKeys.iDEBUGSYSTEM,"Exception : " + sue.getLogInfo());
            return null;
        }
    }

    /**********************************************************************************
     public static String JulianTime(String a_sTime,int format)

     Arguments		:	String	a_sTime  /TYP=S/FORMAT=11:11:20 or /FORMAT = NNNNN
     String  format:
     = 0 Format the return time to h:mm AM/PM
     = 1 Format the return time to h:mm A/P format
     = 2 Format the return time to hh:mm am/pm format
     = 3 Format the return time to h:mm format
     = 4 Format the return time to h:mm:ss format

     Return			:	String	pTime		Number of Days
     or String Time Translation of Mumps
     Julian Time

     Comments		:	This function is used to convert mumps time to gregorian time or
     gregorian date to mumps. If the date is in /FORMAT=NNNNN it gets
     converted to hh:mm:ss format and vice versa.
     converted from ODBC driver
     ***********************************************************************************/
    public static String JulianTime(String a_sTime, int format) {
        int l_hours = 0, l_minutes = 0, l_seconds = 0, l_remseconds = 0;
        String s_fmtHours, s_fmtMin, s_fmtSec;
        int HR = 0, MN = 0, SC = 0, julTime;
        String pTime = new String();

        if (a_sTime.equalsIgnoreCase(null) || a_sTime.equalsIgnoreCase(""))
            return null;

        Integer iTemp = null;

        if (a_sTime.indexOf(":") > 0) {
            StringTokenizer pToken = new StringTokenizer(a_sTime, ":", false);
            if (pToken.hasMoreTokens()) {
                iTemp = new Integer(pToken.nextToken());
                HR = iTemp.intValue();

                if (pToken.hasMoreTokens()) {
                    iTemp = new Integer(pToken.nextToken());
                    MN = iTemp.intValue();
                }

                if (pToken.hasMoreTokens()) {
                    iTemp = new Integer(pToken.nextToken());
                    SC = iTemp.intValue();
                }

                julTime = HR * 3600 + MN * 60 + SC;

                iTemp = new Integer(julTime);
                return iTemp.toString();

            }
        } else {

            iTemp = new Integer(a_sTime);
            l_hours = (iTemp.intValue()) / 3600;

            if (l_hours > 24)
                return null;
            l_remseconds = (iTemp.intValue() - (l_hours * 3600));
            l_minutes = l_remseconds / 60;
            if (l_hours == 24 && l_minutes > 0)
                return null;        // If time is greater than 24hrs return a null
            l_seconds = (l_remseconds - (l_minutes * 60));

            if (l_hours == 24 && l_seconds > 0)
                return null;        // If time is greater than 24hrs return

            if (iTemp.intValue() == 0) {                // If the input time is 0 then return 0
                l_hours = 0;
                l_minutes = 0;
                l_seconds = 0;
            }

            if (l_hours < 10) {
                iTemp = new Integer(l_hours);
                s_fmtHours = "0" + iTemp.toString();
            } else {
                iTemp = new Integer(l_hours);
                s_fmtHours = iTemp.toString();
            }

            if (l_minutes < 10) {
                iTemp = new Integer(l_minutes);
                s_fmtMin = "0" + iTemp.toString();
            } else {
                iTemp = new Integer(l_minutes);
                s_fmtMin = iTemp.toString();
            }

            if (l_seconds < 10) {
                iTemp = new Integer(l_seconds);
                s_fmtSec = "0" + iTemp.toString();
            } else {
                iTemp = new Integer(l_seconds);
                s_fmtSec = iTemp.toString();
            }

            switch (format) {
                // Format the return time to h:mm AM/PM format
                case 0:
                    if (l_hours > 12) {
                        l_hours = l_hours - 12;
                        if (l_hours < 10) {
                            iTemp = new Integer(l_hours);
                            s_fmtHours = "0" + iTemp.toString();
                        } else {
                            iTemp = new Integer(l_hours);
                            s_fmtHours = iTemp.toString();
                        }
                        pTime = s_fmtHours + ":" + s_fmtMin + " PM";
                    } else {
                        if (l_hours < 10) {
                            iTemp = new Integer(l_hours);
                            s_fmtHours = "0" + iTemp.toString();
                        } else {
                            iTemp = new Integer(l_hours);
                            s_fmtHours = iTemp.toString();
                        }
                        pTime = s_fmtHours + ":" + s_fmtMin + " AM";
                    }
                    break;

                case 1:
                    // Format the return time to h:mm A/P format
                    if (l_hours > 12) {
                        l_hours = l_hours - 12;
                        if (l_hours < 10) {
                            iTemp = new Integer(l_hours);
                            s_fmtHours = "0" + iTemp.toString();
                        } else {
                            iTemp = new Integer(l_hours);
                            s_fmtHours = iTemp.toString();
                        }
                        pTime = s_fmtHours + ":" + s_fmtMin + " P";
                    } else {
                        if (l_hours < 10) {
                            iTemp = new Integer(l_hours);
                            s_fmtHours = "0" + iTemp.toString();
                        } else {
                            iTemp = new Integer(l_hours);
                            s_fmtHours = iTemp.toString();
                        }
                        pTime = s_fmtHours + ":" + s_fmtMin + " A";
                    }
                    break;
                case 2:
                    // Format the return time to hh:mm am/pm format
                    if (l_hours > 12) {
                        l_hours = l_hours - 12;
                        if (l_hours < 10) {
                            iTemp = new Integer(l_hours);
                            s_fmtHours = "0" + iTemp.toString();
                        } else {
                            iTemp = new Integer(l_hours);
                            s_fmtHours = iTemp.toString();
                        }
                        pTime = s_fmtHours + ":" + s_fmtMin + ":" + s_fmtSec + " PM";
                    } else {

                        if (l_hours < 10) {
                            iTemp = new Integer(l_hours);
                            s_fmtHours = "0" + iTemp.toString();
                        } else {
                            iTemp = new Integer(l_hours);
                            s_fmtHours = iTemp.toString();
                        }
                        pTime = s_fmtHours + ":" + s_fmtMin + ":" + s_fmtSec + " AM";
                    }
                    break;
                case 3:
                    // Format the return time to h:mm format
                    pTime = s_fmtHours + ":" + s_fmtMin;
                    break;
                case 4:
                    // Format the return time to h:mm:ss format
                    pTime = s_fmtHours + ":" + s_fmtMin + ":" + s_fmtSec;
                    break;
                default:
                    break;
            }
        }
        return pTime;
    }

    /**
     * This function returns first of previous month,
     * Example : If 10/22/1999 is System Date then 09/01/1999 is returned
     *
     * @author Kamal Itigi 10/22/99
     * @parm None
     *
     * @return String    First of previous month in string format
     *
     *see:
     *Bug:
     *
     */
    public static Date getFirstOfPreviousMonth() {
        int li_year, li_day = 1, li_month;

        Calendar cal = Calendar.getInstance();

        li_year = cal.get(Calendar.YEAR);
        li_month = cal.get(Calendar.MONTH);

        if (li_month == 0) {
            li_month = 11;
            li_year--;
        } else {
            li_month--;
        }
        cal.set(li_year, li_month, li_day);

        return cal.getTime();
    }


    /**
     * This function converts julian date to Gargian format (mm/dd/yyyy).
     * @return java.lang.String
     * @param a_sDate java.lang.String julian date (NNNNN)
     * @author Basavaraj Patil
     * @see
     * @bug
     */
    public static String julianToDate(String a_sDate) {
        long ll_julien;
        int li_year, li_day = 0, li_month = 1, li_LeapYear = 0;
        int li_scratch = 0, li_Incr = 0, li_NumDays = 31;
        String s_strMonth, s_strDay, s_strYear;

        int DaysInMonth[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

        Integer iTemp = new Integer(a_sDate);
        if (iTemp.intValue() < 0)
            return null;

        ll_julien = iTemp.intValue();
        if (ll_julien > 21914)
            ++ll_julien;

        li_LeapYear = (int) (ll_julien / 1461);
        li_scratch = (int) (ll_julien % 1461);
        li_year = li_LeapYear * 4 + 1841 + (li_scratch / 365);
        li_day = li_scratch % 365;

        if (li_scratch == 1460 && li_LeapYear != 14) {
            li_day = 365;
            li_year--;
        }

        //08/31/1999 by BP: julian Date bug fix. 
        li_Incr = 0;
        li_NumDays = DaysInMonth[li_Incr];
        //bug fix end

        while (li_NumDays < li_day) {
            if ((li_Incr == 1) && (li_scratch > 1154) && (li_LeapYear != 14))
                li_NumDays++;
            if ((li_day == 29) && (li_NumDays == 29))
                continue;
            li_month++;
            li_day = li_day - li_NumDays;
            li_Incr++;
            li_NumDays = DaysInMonth[li_Incr];
        }

        if (li_day == 0) {
            --li_year;
            li_month = 12;
            li_day = 31;
        }

        if (li_month < 10) {
            iTemp = new Integer(li_month);
            s_strMonth = "0" + iTemp.toString();
        } else {
            iTemp = new Integer(li_month);
            s_strMonth = iTemp.toString();
        }

        if (li_day < 10) {
            iTemp = new Integer(li_day);
            s_strDay = "0" + iTemp.toString();
        } else {
            iTemp = new Integer(li_day);
            s_strDay = iTemp.toString();
        }

        iTemp = new Integer(li_year);
        s_strYear = iTemp.toString();

        return (new String(s_strMonth + "/" + s_strDay + "/" + s_strYear));
//		return (new String(s_strYear +"-"+ s_strMonth +"-"+s_strDay));
    }

    /**
     * This method is to parse the token
     * @param a_sParseMe The String to be tokenized
     * @param a_sTokens String[] Array of tokens( String)
     * @return
     */
    public static String[] tokenParser(String a_sParseMe, String a_sTokens) {
        String asResult[] = null;
        if (a_sParseMe == null || a_sTokens == null) {
            asResult = new String[0];
            return asResult;
        }

        StringTokenizer parseme = new StringTokenizer(a_sParseMe, a_sTokens, false);
        String sToken;
        Vector oVector = new Vector();
        while (parseme.hasMoreTokens()) {//WHILE A
            sToken = parseme.nextToken();
            oVector.addElement(sToken);
        }

        asResult = new String[oVector.size()];
        for (int ii = 0; ii < oVector.size(); ii++)
            asResult[ii] = (String) oVector.elementAt(ii);

        return asResult;
    }//METHOD tokenParser ENDS

    /**
     * This function returns String array containing month, date and year respectively.
     *
     * @param  stringDate The date to be parsed
     * @return String[] string arry containg month, date and Year stirngs respectively.
     *
     * @author Basavaraj Patil
     * @since 07/29/1999
     *
     * @see
     * @bug
     *
     */
    private static String[] getDateElements(String stringDate) throws ScUtilsException {
        String delimiter = "/"; //default delimiter
        if (stringDate.indexOf("/", 0) > 0)
            delimiter = "/"; //delimiter is "front slash"
        else if (stringDate.indexOf("\\", 0) > 0)
            delimiter = "\\"; //delimiter is "back slash"
        else if (stringDate.indexOf("-", 0) > 0)
            delimiter = "-";    //delimiter is "-"
        else if (stringDate.indexOf(" ", 0) > 0)
            delimiter = " ";    //delimiter is "space"

        String tokens[] = tokenParser(stringDate, delimiter);

        if (tokens.length < 3)
            throw new ScUtilsException((3 - tokens.length)
                    + ScBundle.getMessage(ScResourceKeys.Date_Missing));

        if (tokens[0].length() == 4) {
            //if the first element is year (year/month/day)
            String temp[] = new String[3];
            temp[0] = tokens[1]; //month
            temp[1] = tokens[2];//day
            temp[2] = tokens[0]; //year
            return temp;
        } else {
            //if the first element is month (month/day/year)
            return tokens;
        }
    }//end of getDateElements

    /**
     * This method takes input as vector and returns the hashtable
     * to add the name values.
     * @param a_oStore        Vector to be parsed
     * @return HashTable    The Hashtable with the name values
     */
    public Hashtable addNameValues(Vector a_oStore) {
        Hashtable i_oMasterHash = new Hashtable();
        Enumeration enum1 = a_oStore.elements();
        while (enum1.hasMoreElements()) {
            Hashtable ht = (Hashtable) enum1.nextElement();
            Enumeration enum2 = ht.keys();
            while (enum2.hasMoreElements()) {
                Object key = enum2.nextElement();
                Object value = ht.get(key);
                i_oMasterHash.put(key, value);
            }
        }
        return i_oMasterHash;
    }

    /**
     * To get the random number.
     * @return int Next Random Number
     */
    public static int getRandomNumber() {
        return generator.nextInt();
    }

    /**
     * This method is to deep copy an object
     * The New object consists of the "surface" plus all the
     * objects that the handles are pointing to, plus all the
     * objects those objects are pointing to, etc.
     *
     * @param oldObj Object to be copied
     * @return Object The copied object
     *
     * @exception Exception If error occursd in Serialization
     */
    static public Object deepCopy(Object oldObj) throws Exception {
        ObjectOutputStream oos = null;
        ObjectInputStream ois = null;

        try {
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            oos = new ObjectOutputStream(bos);

            // serialize and pass the object
            oos.writeObject(oldObj);
            oos.flush();

            ByteArrayInputStream bin = new ByteArrayInputStream(bos.toByteArray());
            ois = new ObjectInputStream(bin);

            // return the new object
            return ois.readObject();
        } catch (Exception e) {
            throw (e);
        } finally {
            oos.close();
            ois.close();
        }
    }
}