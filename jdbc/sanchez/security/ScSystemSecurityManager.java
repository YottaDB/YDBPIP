/**
 *  	ScSystemSecurityManager is primarily used by ScDebug class.
 *	Contarary to what the names suggests this class is <strong> not </strong> resposible for any security or authantication operations.
 *	The sole purpose of this class is to examine the method execution stack and provide debugging information such as
 *	what class instance made a method call to some method in another class
 *
 *	@version 	1.0, 6/21/99	
 *	@author		Pranav G. Amin	
 *	@see		sanchez.utils.ScDebug
 * 
 */

package sanchez.security;

import java.net.InetAddress;
import java.security.acl.Permission;
import java.io.FileDescriptor;

public class ScSystemSecurityManager extends SecurityManager 
{	
	public void checkPermission(Permission perm) {}
	public void checkPermission(Permission perm, Object context) {}	
	public void checkCreateClassLoader() { } 
	public void checkAccess(Thread g) { }
	public void checkAccess(ThreadGroup g) { }
	public void checkExit(int status) { }
	public void checkExec(String cmd) { }
	public void checkLink(String lib) { }
	public void checkRead(FileDescriptor fd) { }
	public void checkRead(String file) { }
	public void checkRead(String file, Object context) { }
	public void checkWrite(FileDescriptor fd) { }
	public void checkWrite(String file) { }
	public void checkDelete(String file) { }
	public void checkConnect(String host, int port) { }
	public void checkConnect(String host, int port, Object context) { }
   	public void checkListen(int port) { }
	public void checkAccept(String host, int port) { }
    	public void checkMulticast(InetAddress maddr) { }
    	public void checkMulticast(InetAddress maddr, byte ttl) { }
    	public void checkPropertiesAccess() { }
    	public void checkPropertyAccess(String key) { }
    	public void checkPropertyAccess(String key, String def) { }
    	public boolean checkTopLevelWindow(Object window) { return true; }
    	public void checkPrintJobAccess() { }
    	public void checkSystemClipboardAccess() { }
    	public void checkAwtEventQueueAccess() { }
    	public void checkPackageAccess(String pkg) { }
    	public void checkPackageDefinition(String pkg) { }
    	public void checkSetFactory() { }
    	public void checkMemberAccess(Class clazz, int which) { }
    	public void checkSecurityAccess(String provider) { }

	/**
 	  * This method will get the information from the system method stack. This method is used by the ScDebug class.

          * @param callStackLevel Stack level for which debugging information is required.
  	  */
	public Class getClass(int callStackLevel)
	{
		Class[] c = super.getClassContext();
		if ( c.length < callStackLevel + 2)
			return null;
		else
			return c[callStackLevel];
	}
}	
