package sanchez.base;


import java.text.ParsePosition;
import java.text.SimpleDateFormat;
import java.text.Format;
import java.text.DateFormat;
import java.util.Date;
import java.util.Locale;
import java.sql.Timestamp;

import sanchez.utils.ScUtility;

/**
 * ScDateManager handles various Date and Timestamp format conversions
 */

public class ScDateManager {
    private Locale i_oLocale;
    private SimpleDateFormat i_oDateFormatter;
    private SimpleDateFormat i_oTimeFormatter;

    private String jdbcDateFormat = ScBundle.getMessage(ScResourceKeys.jdbcDateFormat);
    private String jdbcTimeFormat = ScBundle.getMessage(ScResourceKeys.jdbcTimeFormat);
    private SimpleDateFormat jdbcDateFormatter;
    private SimpleDateFormat jdbcTimeFormatter;

    /**
     * Constructor
     *
     * @param a_oLocale        java.util.Locale
     * @param a_sDateForamtter java.text.SimpleDateFormat which will be used for date conversion
     * @param a_oTimeFormatter java.text.SimpleDateFormat which will be used for Timestamp conversion
     */
    public ScDateManager(Locale a_oLocale, SimpleDateFormat a_sDateForamtter, SimpleDateFormat a_oTimeFormatter) {
        i_oLocale = a_oLocale;
        i_oDateFormatter = a_sDateForamtter;
        i_oTimeFormatter = a_oTimeFormatter;
        jdbcDateFormatter = new SimpleDateFormat();
        jdbcDateFormatter.applyPattern(jdbcDateFormat);
        jdbcTimeFormatter = new SimpleDateFormat();
        jdbcTimeFormatter.applyPattern(jdbcTimeFormat);
        i_oDateFormatter.setLenient(false);
        i_oTimeFormatter.setLenient(false);

    }

    /**
     * Returns Date String in displayable format from the JDBC format
     *
     * @param sJdbc Date string in JDBC format
     * @return Date String for display
     */
    public String getDisplayDateFromJdbcDate(String sJdbc) throws Exception {
        if (!this.isDateInJdbcFormat(sJdbc)) {
            //"yyyy-MM-dd hh:mm a"
            sJdbc = sJdbc + " 00:00:00.0";
        }
        try {
            Date dt = jdbcDateFormatter.parse(sJdbc);
            return getDisplayDate(dt);
        } catch (Exception e) {
            // Check whether it is time stamp if not throw exception.
            return getDisplayDateFromJdbcDate(getJdbcDateFromTimeStamp(sJdbc));
        }
    }

    /**
     * Returns Time String in displayable format from the JDBC format
     *
     * @param sJdbcTime Time String in JDBC format
     * @return Date String for display
     */
    public String getDisplayTimeFromJdbcTime(String sJdbcTime) throws Exception {
        if (!this.isDateInJdbcFormat(sJdbcTime)) {
            //"yyyy-MM-dd hh:mm a"
            sJdbcTime = "1970-01-01 " + sJdbcTime;
        }
        try {
            Date dt = jdbcTimeFormatter.parse(sJdbcTime);
            return getDisplayTime(dt);
        } catch (Exception e) {
            // Check whether it is time stamp if not throw exception.
            return getDisplayTimeFromJdbcTime(getJdbcTimeFromTimeStamp(sJdbcTime));
        }
    }

    /**
     * Returns Date String in displayable format from the Julian Date format
     *
     * @param sJulianDate java.lang.String
     * @return Date String for display
     */
    public String getDisplayDate(String sJulianDate) throws Exception {
        Date date = ScUtility.julianDateToJavaDate(sJulianDate);
        return i_oDateFormatter.format(date);
    }

    /**
     * Returns Date String in displayable format from the Date Object
     *
     * @param a_oDate Date to be converted to String
     * @return Date String for display
     */
    public String getDisplayDate(Date a_oDate) throws Exception {
        return i_oDateFormatter.format(a_oDate);
    }

    /**
     * Returns Time String in displayable format from the Date Object
     *
     * @param a_oDate Date to be converted to String
     * @return Time String for display
     */
    public String getDisplayTime(Date a_oDate) {
        return i_oTimeFormatter.format(a_oDate);
    }

    /**
     * Given a time in julian format return back a Display time fromat string
     *
     * @param a_sJulian java.lang.String
     * @return java.lang.String
     */
    public String getDisplayTime(String a_sJulian) {
        java.sql.Time dt = ScUtility.julianTimeToJavaTime(a_sJulian);
        return getDisplayTime(dt);
    }

    /**
     * Given a String in Timestamp format return back a string representing jdbc format
     *
     * @param a_sTimestamp Timestamp String for JDBC Date format conversion
     * @return Date as a String in JDBC format
     */
    public String getJdbcDateFromTimeStamp(String a_sTimestamp) throws Exception {
        Timestamp tempTimestamp = Timestamp.valueOf(a_sTimestamp);
        return getJdbcDateFromTimeStamp(tempTimestamp);
    }

    /**
     * Given a Timestamp object returns back a string representing jdbc format
     *
     * @param a_sTimestamp Timestamp object for JDBC Date format conversion
     * @return Date as a String in JDBC format
     */
    public String getJdbcDateFromTimeStamp(Timestamp a_sTimestamp) throws Exception {
        Date dt = (Date) a_sTimestamp;
        return jdbcDateFormatter.format(dt);
    }

    /**
     * Returns Date as a String in JDBC format from dispalyable format date string
     *
     * @param a_sDisplayDate Date string in display format
     * @return Date string in JDBC format
     */
    public String getJdbcDateFromDisplayDate(String a_sDisplayDate) throws Exception {
        Date dt = getDateFromDisplay(a_sDisplayDate);
        return jdbcDateFormatter.format(dt);
    }

    /**
     * Returns Time string in JDBC format from Timestamp string in display format
     *
     * @param a_sTimestamp Timestamp string for JDBC format conversion
     * @return Timestamp string in JDBC format
     */
    public String getJdbcTimeFromTimeStamp(String a_sTimestamp) throws Exception {
        Timestamp tempTimestamp = Timestamp.valueOf(a_sTimestamp);
        return getJdbcTimeFromTimeStamp(tempTimestamp);
    }

    /**
     * Returns Time string in JDBC format from Timestamp
     *
     * @param a_sTimestamp Timestamp for JDBC format conversion
     * @return Timestamp string in JDBC format
     */
    public String getJdbcTimeFromTimeStamp(Timestamp a_sTimestamp) throws Exception {
        Date dt = (Date) a_sTimestamp;
        return jdbcTimeFormatter.format(dt);
    }

    /**
     * Given a Time in display format return a string representing jdbc time format
     *
     * @param a_sDisplayTime Timestamp string for JDBC format conversion
     * @return Timestamp string in JDBC format
     */
    public String getJdbcTimeFromDisplayTime(String a_sDisplayTime) throws Exception {
        Date dt = getTimeFromDisplay(a_sDisplayTime);
        return jdbcTimeFormatter.format(dt);
    }

    /**
     * Parses jdbc format date string to return a date object.
     *
     * @param sJdbc Date string in jdbc date format
     * @return Date object
     * @throws Exception if the jdbc format string is not in timestamp format
     */
    public Date getDateFromJDBC(String sJdbc) throws Exception {
        if (!this.isDateInJdbcFormat(sJdbc)) {
            //"yyyy-MM-dd hh:mm a"
            sJdbc = sJdbc + " 00:00:00.0";
        }
        try {
            Date dt = jdbcDateFormatter.parse(sJdbc);
            return dt;
        } catch (Exception e) {
            // Check whether it is time stamp if not throw exception.
            return getDateFromJDBC(getJdbcDateFromTimeStamp(sJdbc));
        }
    }

    /**
     * Parses a date string to return date object on checking the validity of year format.
     *
     * @param a_sDisplayDate Date string in diaplay format
     * @return Date object
     */
    public Date getDateFromDisplay(String a_sDisplayDate) throws Exception {
        if (!isYear4Digit(a_sDisplayDate)) {
            throw new Exception(ScBundle.getMessage(ScResourceKeys.Date_Format_Invalid));
        }
        return i_oDateFormatter.parse(a_sDisplayDate);
    }

    /**
     * Parses a string in display format to return Time object
     *
     * @param a_sDisplayTime Time string in display format
     * @return Time Object representing the display time
     */
    public java.sql.Time getTimeFromDisplay(String a_sDisplayTime) {
        Date dt;
        dt = i_oTimeFormatter.parse(a_sDisplayTime, new ParsePosition(0));
        long tme = dt.getTime();
        return new java.sql.Time(tme);
    }

    /**
     * Parses a string in Julian time format to return Time object
     *
     * @param a_sJulianTime time string in Julian time format
     * @return Time Object representing the time
     */
    public java.sql.Time getTimeFromJulian(String a_sJulianTime) {
        return ScUtility.julianTimeToJavaTime(a_sJulianTime);
    }

    /**
     * Parses a string in Julian time format to returns Date object
     *
     * @param sJulianDate Date string in Julian time format
     * @return Date object
     */
    public Date getDateFromJulian(String sJulianDate) throws Exception {
        return ScUtility.julianDateToJavaDate(sJulianDate);
    }

    /**
     * Parses a string in display date format to returns Date string in Julian format
     *
     * @param a_sDisplayDate Date string in display format
     * @return Date String in Julian format
     */
    public String getJulianDate(String a_sDisplayDate) throws Exception {
        Date d = getDateFromDisplay(a_sDisplayDate);
        return getJulianDate(d);
    }

    /**
     * Parses date object to returns Date string in Julian format
     *
     * @param a_oDate Date object for conversion
     * @return Date String in Julian format
     */
    public String getJulianDate(Date a_oDate) throws Exception {
        SimpleDateFormat temp = new SimpleDateFormat("MM/dd/yyyy");
        String sDate = temp.format(a_oDate);
        return ScUtility.JulianDate(sDate);
    }

    /**
     * Gets Julian time format from a date object
     *
     * @param dt Date object for Julian Time conversion
     * @return Date string in julian format
     */
    public String getJulianTime(Date dt) {
        return ScUtility.JavaTimeToJulianTime(dt);
    }

    /**
     * Gets Julian time format from display time string
     *
     * @param dt Date object for Julian Time conversion
     * @return Time string in julian format
     */
    public String getJulianTime(String a_sDisplayTime) {
        Date dt = getTimeFromDisplay(a_sDisplayTime);
        return getJulianTime(dt);
    }


    /**
     * Returns the default date format for display
     *
     * @return date format for display
     */
    public String getDisplayDateFormat() {
        return i_oDateFormatter.toPattern();
    }

    /**
     * Returns the default time format for display
     *
     * @return Timeformat for display
     */
    public String getDisplayTimeFormat() {
        return i_oTimeFormatter.toPattern();
    }

    /**
     * returns jdbc date format
     *
     * @return Jdbc date format
     */
    public String getJdbcDateFormat() {
        return jdbcDateFormatter.toPattern();
    }

    /**
     * returns jdbc time format
     *
     * @return Jdbc time format
     */
    public String getJdbcTimeFormat() {
        return jdbcTimeFormatter.toPattern();
    }

    /**
     * Checks whether the date string value is in JDBC date format
     *
     * @param a_sDate Date string for verification
     * @return boolean true - if the input date string is in JDBC format. False - otherwise
     */
    public boolean isDateInJdbcFormat(String a_sDate) {
        boolean flag = true;
        try {
            SimpleDateFormat sdfTemp = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
            sdfTemp.parse(a_sDate);
            flag = true;
        } catch (Exception e) {
            try {
                jdbcDateFormatter.parse(a_sDate);
                flag = true;
            } catch (Exception exc) {
                flag = false;
            }
        }
        return flag;
    }

    /**
     * Checks whether the string value is in JDBC time format
     *
     * @param a_sTime time string for verification
     * @return boolean true - if the input time string is in JDBC format. False - otherwise
     */
    public boolean isTimeInJdbcFormat(String a_sTime) {
        boolean flag = true;
        try {
            SimpleDateFormat sdfTemp = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
            sdfTemp.parse(a_sTime);
            flag = true;
        } catch (Exception e) {
            try {
                jdbcTimeFormatter.parse(a_sTime);
                flag = true;
            } catch (Exception exc) {
                flag = false;
            }
        }
        return flag;
    }

    /**
     * Checks whether the string is in display date format
     *
     * @param a_sDate Date string for verification
     * @return boolean true - if the input time string is in JDBC format. False - otherwise
     */
    public boolean isDateInDisplayFormat(String a_sDate) {
        boolean flag = true;
        try {
            i_oDateFormatter.parse(a_sDate);
            flag = true;
        } catch (Exception e) {
            flag = false;
        }
        return flag;
    }

    /**
     * Checks whether the string is in display time format
     *
     * @param a_sTime Time string for verification
     * @return boolean true - if the input time string is in JDBC format. False - otherwise
     */
    public boolean isTimeInDisplayFormat(String a_sTime) {
        boolean flag = true;
        try {
            i_oTimeFormatter.parse(a_sTime);
            flag = true;
        } catch (Exception e) {
            flag = false;
        }
        return flag;
    }

    /**
     * Gets the Display Date Seperator
     *
     * @return Date seperator string
     */
    public String getDisplayDateSeperator() {
        String sDisplayPattern = this.getDisplayDateFormat();
        int count = sDisplayPattern.length();
        if (count == 0) return null;
        char c = ' ';
        Character cSeparator = null;
        for (int i = 0; i < count; i++) {
            c = sDisplayPattern.charAt(i);
            cSeparator = new Character(c);

            if (!Character.isLetterOrDigit(c)) {
                return cSeparator.toString().trim();
            }
        }
        return null;
    }

    /**
     * Gets a display time seperator standardized on the occurences of a display pattern
     *
     * @return seperator of Display time
     */
    public String getDisplayTimeSeperator() {
        String sDisplayPattern = this.getDisplayTimeFormat();
        int count = sDisplayPattern.length();
        if (count == 0) return null;
        char c = ' ';
        Character cSeparator = null;
        for (int i = 0; i < count; i++) {
            c = sDisplayPattern.charAt(i);
            cSeparator = new Character(c);

            if (!Character.isLetterOrDigit(c)) {
                return cSeparator.toString().trim();
            }
        }
        return null;
    }

    /**
     * Checks for the validity of year display pattern
     *
     * @param displayDate for year verification
     * @return boolean true if the year is valid. false otherwise.
     */
    public boolean isYear4Digit(String displayDate) {
        String sep = this.getDisplayDateSeperator();
        char seperator = sep.charAt(0);
        int b = displayDate.indexOf(seperator);
        int c = displayDate.lastIndexOf(seperator);
        int d = displayDate.length();
        if (b == -1 || c == -1)
            return false;
        int group1 = b;
        int group2 = c - b;
        group2 = group2 - 1;
        int group3 = d - c;
        group3 = group3 - 1;
        if (group1 == 4) {
            String yearGroup = displayDate.substring(0, b);
            return isAllDigits(yearGroup);
        } else if (group2 == 4) {
            String yearGroup = displayDate.substring(b + 1, c);
            return isAllDigits(yearGroup);
        } else if (group3 == 4) {
            String yearGroup = displayDate.substring(c + 1);
            return isAllDigits(yearGroup);
        } else
            return false;
    }

    /**
     * Checks whether yeargroup is comprised only of digits
     *
     * @param yearGroup for number check
     * @return boolean true if the year string contains only numeric. false otherwise.
     */
    public boolean isAllDigits(String yearGroup) {
        boolean status = true;
        for (int ii = 0; ii < yearGroup.length(); ii++) {
            if (!Character.isDigit(yearGroup.charAt(ii)))
                status = false;
        }
        return status;
    }

    public void refresh() {
    }

    public void reset() {
    }

    /**
     * Returns Timestamp object from  timestamp string in JDBC format
     *
     * @param s_sTimestamp     timestamp string
     * @param timestampPattern format of timestamp string
     * @return Timestamp object
     */
    public Timestamp getDisplayTimeStampFromJdbcTimestamp(String s_sTimestamp,
                                                          String timestampPattern) throws Exception {
        Format format = null;
        Timestamp retTimestamp = null;
        try {
            if (timestampPattern != null)
                format = new SimpleDateFormat(timestampPattern, i_oLocale);
            else
                format = DateFormat.getDateInstance(DateFormat.LONG, i_oLocale);
            retTimestamp = new Timestamp((((DateFormat) format).parse(s_sTimestamp)).getTime());
        } catch (Exception e) {
            try {
                format = DateFormat.getDateInstance();
                retTimestamp = new Timestamp((((DateFormat) format).parse(s_sTimestamp)).getTime());
            } catch (Exception ex) {
                retTimestamp = Timestamp.valueOf(s_sTimestamp);
            }
        }
        return retTimestamp;
    }
}