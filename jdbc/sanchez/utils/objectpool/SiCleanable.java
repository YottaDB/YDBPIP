package sanchez.utils.objectpool;

//class okay 9th March 1999
/**
  * Any Class that requires periodic check on consistency of its states &nbc
  * should implement this interface.
  * Some classes require active checks on inconsistent state,
  * this requires keeping an eye on the attributes of the object
  * so as to avoid undesirable state. Any object that requires such
  * check should implement this interface. In addition the class
  * should create an instance of class ScGarbageCollector and set
  * the time period for checks, and start the thread.
  * Thread garbage = new GarbageCollector();
  * gc.setTimeExpired(time) // time in millisecond
  * gc.start();

  * @author Pranav Amin
  * @version 1.0 4th Feb 1999
  * @see GarbageCollector
  * @see ScObjectPool
  */

public interface SiCleanable
{
	
	/**
	  * cleanUp() method dereferences all the objects this particular object is referring.
	  * there by making the object garbage collectable.
  	  */
	public void cleanUp();
	/**
	  * This method contains all logic to check consistence
	  * of the object state. 

	  *@see java.lang.Object#finalize()
	  */
 	public boolean validate();  
}