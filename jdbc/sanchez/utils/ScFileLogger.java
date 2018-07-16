package sanchez.utils;

import java.io.FileWriter;
import java.util.Date;

import sanchez.base.ScObject;
import sanchez.base.ScBundle;
import sanchez.base.ScResourceKeys;

/**
 * 	ScFileLogger is a simple logger that logs the loggable in a file.
 * 	It implements the SiLogger interface. The implementation is in accordance to the doer - doable pattern.
 *	
 *
 *	@version 	1.0, 6/21/99.	
 *	@author		Pranav G. Amin	
 *	@see		sanchez.utils.SiLoggable.
 *      @see		sanchez.base.ScLogger.
 * 	@see		Doer Doable pattern in the GAEA design documentations.	
 *  @midification   09/06/1999      Quansheng Jia
 *              weblink
 */
public class ScFileLogger extends ScObject implements SiLogger
{
	FileWriter writer;
	/**
	 * Contsructs a new File Logger
	 * @throws Exception If any error occurs in creating the file logger
	 */
       	public ScFileLogger()throws Exception
       	{
       		String errorFile="Gaea.log";		
        	writer = new FileWriter(errorFile,true);          
        }
	/**
	 * This method will log the loggable.
	 * 
	 * @param SiLoggable
	 *            The SiLoggable Object that needs to be logged.
	 * @exception Exception
	 *            The implementing class can throw any subclass of
	 *            Exception. For instance an database logger might throw
	 *            SQLException while FileLogger might throw IOException.
	 */
	public void log(SiLoggable logable)throws Exception
       	{
		StringBuffer logbuffer = new StringBuffer();
        try
        {
			Date today = new Date(System.currentTimeMillis());
			logbuffer.append(today+"\n");
			logbuffer.append(logable.getLogInfo());
			synchronized(this)
			{
				writer.write(logbuffer.toString());			
				writer.flush();						
			}
		}
	    catch(Exception e)
		{
			Object[] obj = { e.toString() };
			throw new Exception(ScBundle.getMessage(ScResourceKeys.Cannot_Log,
					obj));
		}
 	}
}