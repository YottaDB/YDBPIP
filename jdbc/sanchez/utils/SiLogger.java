/**
 * Any object that has the capability to log a SiLoggable Object should implement
 * this interface
 *
 * @version 1.0, 6/21/99.
 * @author Pranav G. Amin
 * @see        sanchez.utils.SiLoggable.
 * @see        sanchez.base.ScFileLogger.
 * @see        Doer Doable pattern in the GAEA design documentations.
 */
package sanchez.utils;

public interface SiLogger {
    /**
     * This method will log the loggable.
     *
     * @param SiLoggable  The SiLoggable Object that needs to be logged.
     * @exception Exception The implementing class can throw any subclass of Exception.
     * For instance an database logger might throw SQLException while FileLogger might
     * throw IOException.
     */

    public void log(SiLoggable loggable) throws Exception;
}