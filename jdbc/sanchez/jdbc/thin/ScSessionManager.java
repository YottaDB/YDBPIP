package sanchez.jdbc.thin;

import java.util.Enumeration;
import java.util.Hashtable;

import sanchez.him_pa.ScProfToken;

public class ScSessionManager {

    //** Attributes that have to be reset between sessions
    Hashtable i_oStore = new Hashtable();
    private ScProfToken i_oToken = null;
    // state management
    // Set the Session object from persistent store.  If not
    // store the session object as the first storage.
    private boolean i_bIsStateSession = false;
    //------------------------------------------------------
    // constructors
    //

    public ScSessionManager() {
    }


    /**
     * The i_bSessionRestoredFromState varibale
     */
    public boolean isStateSession() {
        return i_bIsStateSession;
    }

    public int setStateSession(boolean abSet) {
        i_bIsStateSession = abSet;
        return 1;
    }

    public String[] getKeys() {
        int size = i_oStore.size();
        String[] str = new String[size];
        Enumeration enum1 = i_oStore.elements();
        int count = 0;
        while (enum1.hasMoreElements()) {
            try {
                str[count++] = (String) enum1.nextElement();
            } catch (ClassCastException cce) {
                count--;
            }
        }
        return str;
    }

    /**
     * @param a_sName : key value of the object desired to be fetched.
     * @return Object associated with the key name a_sName
     */
    public Object getObject(Object a_sName) {
        return i_oStore.get(a_sName);
    }

    /**
     * Returns all Objects stored in the session cache is an array.
     */
    public Object[] getObjects() {
        int size = i_oStore.size();
        Object[] obj = new Object[size];
        Enumeration enum1 = i_oStore.elements();
        int count = 0;
        while (enum1.hasMoreElements())
            obj[count++] = enum1.nextElement();
        return obj;
    }

    public ScProfToken getToken() {
        return i_oToken;
    }

    public void removeAll() {
        Enumeration enum1 = i_oStore.keys();
        while (enum1.hasMoreElements())
            i_oStore.remove(enum1.nextElement());
    }

    /**
     * Given the key value remove the associated Object from the session cache.
     *
     * @param Key value of the Object desired to be removed from the session cache.
     */
    public void removeObject(Object a_sName) {
        i_oStore.remove(a_sName);
    }

    // Reset the attributes that should not be shared between logins in the session cache.
    public void reset() {
        Enumeration enum1 = i_oStore.keys();
        while (enum1.hasMoreElements())
            i_oStore.remove(enum1.nextElement());
        i_oToken = null;
    }

    /**
     * @param a_oObject : Object to be stored.
     *                  a_sName : key associated to the Object requested to be stored.
     */
    public void setObject(Object a_sName, Object a_oObject) {
        i_oStore.put(a_sName, a_oObject);
    }

    public void setToken(ScProfToken oToken) {
        i_oToken = oToken;
    }
}