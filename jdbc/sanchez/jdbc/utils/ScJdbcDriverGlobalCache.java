package sanchez.jdbc.utils;

import java.util.Hashtable;
import java.util.Enumeration;
 
public class ScJdbcDriverGlobalCache {
/**
 * ScGlobalCacheManager constructor comment.
 */
private static Hashtable i_hGlobalCache = new Hashtable();
private static final ScJdbcDriverGlobalCache i_oInstance = new ScJdbcDriverGlobalCache();
 
public static ScJdbcDriverGlobalCache getInstance()
	{
		return i_oInstance;
	}
	
public ScJdbcDriverGlobalCache() {
        /*
		try{
		Class.forName("sanchez.base.ScNameResolver");    
		Class.forName("sanchez.base.ScMessageManagerGlobal");
		Class.forName("sanchez.utils.ScLogManager");
	    }
	    catch (Exception e){}
        */
}
/**
 * This method was created in VisualAge.
 * @return : Array of string representing the keys for the objects
 * in the global cache.
 */
//public static  String[] getKeys() {
public  Enumeration getKeys() {
	return i_hGlobalCache.keys();
	
}
/**
 * This method was created in VisualAge.
 * @return : Object associated with key name a_sName
 * @param a_sName : Key value of the object to be fetched.
 */
public static   Object  getObject(String  a_sName) {
	return i_hGlobalCache.get(a_sName);
	
}
/**
 * This method was created in VisualAge.
 * @return : All objects associated in the global cache.
 */
public static  Object[] getObjects(){
	return null;
}
/**
 * This method was created in VisualAge.
 * @return : Object to be removed.
 * @param a_sName : Key value associated with the object to be removed.
 */
public static  Object removeObject(String a_sName)
 {
	 return i_hGlobalCache.remove(a_sName);

}
/**
 * This method was created in VisualAge.
 * @return : Object
 * @param a_sName : Key value associated with the object to be stored.
 * @param a_oObject : Object to b estored.
 */
public static  Object setObject(String a_sName, Object a_oObject) {
    if (a_sName==null) a_sName="";
    return i_hGlobalCache.put(a_sName, a_oObject);
}
}