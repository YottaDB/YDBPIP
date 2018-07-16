/**
 * 	All Threads that do not run in context to a user session, will acess Message Objects
 *	through this Message Manager.
 *
 *	@version 	1.0, 6/21/99.	
 *	@author		Pranav G. Amin	
 *	@see		sanchez.app.ScSessionCacheManager
 * 	@see		Object Cache pattern in the GAEA design documentations.	
 * 
 */
package sanchez.base;

public class ScNonSessionMessageManager extends ScObjectGlobal
{
	private static ScMessageManager c_oMessageManager = new ScMessageManager(0,0);

	/**
   	  * Lazy instantiation of ScMessageManager. The MessageManager is created with the 
	  * default environment_id and defalult language_id
   	  * @return  ScMessageManager
  	  */
	public synchronized static ScMessageManager getMessageManager()
	{
		if(c_oMessageManager ==null)
			c_oMessageManager = new ScMessageManager(0,0);
		return c_oMessageManager;
	}

}
