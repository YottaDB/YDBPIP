/**
 
 *	@version 	1.0, 6/21/99.	
 *	@author		Pranav G. Amin	
 *	@see		sanchez.base.ScException
 * 
 */
package sanchez.utils;

import sanchez.base.ScException;

public class ScUtilsException extends ScException
{
	private static final int c_iMessageId = 101;
	/**
	  * Constructs an <code>ScUtilsException</code> with no specified detail message. 
      *	
      */
	public ScUtilsException()
	{
		super("ScUtilsException",c_iMessageId);		
	}
	/**
	  * Constructs an <code>ScUtilsException</code> with specified detail message. 
      *	@param a_sOtherInfo A string representing a message. This string can be restored by invoking
      * getOtherInfo() method of the Exception/
      */
	public ScUtilsException(String a_sOtherInfo)
	{
		super(a_sOtherInfo,c_iMessageId);		
	}
	/**
      * Constructs an <code>ScUtilsException</code> with a user
      * defined message_Id
      * @param   a_iMessageId 	User Defined MessageId. Should have an entry in the message table.         
      */
	public ScUtilsException(int a_iMessageId)
	{
		super(a_iMessageId);
	}
	/**
      * Constructs an <code>ScUtilsException</code> with the specified 
	  * detail message and a user defined MessageId 
      * @param   a_sOtherInfo   the detail message.
	  * @param   a_iMessageId 	User Defined MessageId. Should have an entry in the message table. 
	  */
	public ScUtilsException(String a_sOtherInfo, int a_iMessageId)
	{
		super(a_sOtherInfo,a_iMessageId);		
	}
}