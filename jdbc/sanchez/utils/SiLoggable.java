/**
 * 	Any object that needs to be Logged, should implement this interface.  	
 *	
 *
 *	@version 	1.0, 6/21/99.	
 *	@author		Pranav G. Amin	
 *	@see		sanchez.utils.SiLogger.
 *      @see		sanchez.base.ScMessage.
 * 	@see		Doer Doable pattern in the GAEA design documentations.	
 * 
 */
package sanchez.utils;
public interface SiLoggable
{
	/**
   	  * Returns a String representing the information that the object wishes to log.
  	  * For instance a Calendar object can implement SiLoggable and this method may
  	  * return a String representing the date and time. Similarly an Exception Object
  	  * may return back a Error Message.
	  *
   	  * @return  String 
  	  */
	public String getLogInfo();	
}