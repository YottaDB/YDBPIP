/**
 *  	A ScMessageManager is a user level message manager. This object contains a reference
 *	to the ScMessageManagerGlobal a repository of all ScMessage Objects. It also contains
 * 	user selected variables in environment_id and language_id. The user sends in request 
 *	for a ScMessage to its ScMessageManageer. The ScSessionManager in terms requests the 
 * 	ScMessage from the ScMessageManagerGlobal object.
 *
 *	@version 	1.0, 6/21/99	
 *	@author		Pranav G. Amin	
 *	@see		sanchez.base.ScMessageManagerGlobal
 *      @see		sanchez.base.ScMessage
 * 
 */

package sanchez.base;
public class ScMessageManager extends ScObject
{
	private int i_iEnvironment_id;
	private int i_iLanguage_id;

	/**
 	  * Every user will have his own instance of ScMessageManager. All such instances need to
   	  * point to ScMessageManagerGlobal, hence the object reference is static. Every instance
	  * share the same reference and needs to be set only once.
        */
	private static final ScMessageManagerGlobal c_oMessageManagerGlobal = ScMessageManagerGlobal.getInstance();

	/**
      * Construct a ScMessageManager from environment_id & language_id.
      * @param language_id int number representing a unique language.
      * @param environment_id int number representing a unique environment.
      */
	public ScMessageManager(int a_iEnvironment_id, int a_iLanguage_id)
	{
		i_iEnvironment_id = a_iEnvironment_id;
		i_iLanguage_id = a_iLanguage_id;
	}
	/**
	  * Set Environment Id as current settings.  
      * @param a_iEnvironment_id Enviornment Id for this message Object
      */
	public void setEnvironmentID(int a_iEnvironment_id)
	{
		i_iEnvironment_id = a_iEnvironment_id;
	}
	/**
	  * Set Language Id as current settings.  
      * @param a_iLanguage_id Enviornment Id for this message Object
      */
	public void setLanguageID(int a_iLanguage_id)
	{
		i_iLanguage_id = a_iLanguage_id;
	}
    /**
	  * Get a message object for current settings of language and environment.
	  	  
	  * @param a_iMessageId Message Id for this message Object	  
	  */
	public ScMessage getMessage(int a_iMessage_id)throws Exception		
	{
		return  c_oMessageManagerGlobal.getMessage(i_iEnvironment_id, i_iLanguage_id, a_iMessage_id);
	}
}