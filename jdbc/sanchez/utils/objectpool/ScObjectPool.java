package sanchez.utils.objectpool;

import java.util.Enumeration;
import java.util.Hashtable;

/**
 * Object pool is a generic pool of objects, it is an abstract class.
 * All classes that need a object pool should extend from this class.
 * These objects should implement the following methods.
 * create()  To create an object
 * expire()
 * <p>
 * This class maintains two Hashtable, 'locked' for referring objects
 * which are in service 'unlocked' which refers to objects waiting in
 * the pool to serve.Objects are stored as keys to the Hashtable.
 * Time of Access is stored as value
 * A Thread wakes up at userdefined intervals and collects all objects
 * that can invalid. All objects that have been idle for a particular
 * time are invalid and subjected to expiry.
 * To set expiry times use  setExpirationTime()
 * IF THE USER WISHES TO SET A MINIMUM SIZE OF THE POOL USE setMinimumSize()
 *
 * @author Pranav Amin
 * @version 1.0  2 Feb 1999
 * @see ScGarbageCollector
 * @see ScCleanable
 */

public abstract class ScObjectPool extends sanchez.base.ScObjectGlobal implements SiCleanable {
    transient protected Hashtable locked;
    transient protected Hashtable unlocked;
    private transient long expirationTime;
    protected transient ScGarbageCollector garbage;
    protected transient int minimumSize = 10;
    private transient boolean i_bFreeze = false;
    protected transient int maxmumSize = 60;

    private static int garbage_Collect = 0;

    /**
     * Default Class Constructor
     * Sets expiration time to 2 mins.
     * Objects not checkedOut before expiration date will <code>expire</code>
     */
    protected ScObjectPool() {
        locked = new Hashtable();
        unlocked = new Hashtable();
        expirationTime = 120000;
        garbage = new ScGarbageCollector(this, expirationTime);
        garbage.start();
    }

    /**
     * Class Constructor with optional expiry time argument
     * the object expires if it is not checked out before expirationTime.
     * Default expiration time is 2 mins.
     *
     * @param pm_expirationTime a long value indicating time in millisecond
     */

    protected ScObjectPool(long pm_expirationTime) {
        this();
        if (pm_expirationTime > 0)
            this.expirationTime = pm_expirationTime;
    }

    /**
     * Clients return back the Objects to the Object Pool using this method.
     * The object is moved from the locked Hashtable to the unlocked Hashtable
     * with the timestamp. This indicates that the object is free to serve.
     * If the object is in the 'unlocked' Hashtable for a period exceeding
     * expiryTime, a daemon thread will garbage collect that object
     */

    public void checkIn(Object o) {
        if (o != null) {
            long now = System.currentTimeMillis();
            locked.remove(o);
            unlocked.put(o, now);
        }
    }

    /**
     * <p> Client Objects should use this method to request an Object
     * this method throws an &nbc Exception. The client object should
     * catch and handle Exception. This method is <code>thread safe</code>.
     * When a client requests an object, using this method, following
     * operations take place. An object is fetched from the 'unlocked'
     * Hashtable and it is checked for validation.If client is invalid it
     * is expired and garbage collected and next object in the Hashtable
     * is considered. If there are no more objects in the Hashtable a
     * new Object is created.
     *
     * @throws java.lang.Exception Superclass of all Exceptions, a concrete &nbc
     *                             subclass may throw any of its subclasses.
     */

    public synchronized Object checkOut() throws Exception {

        if (i_bFreeze == true)
            throw new ScObjectPoolException(144);
        long now = System.currentTimeMillis();
        Object o;

        if (unlocked.size() > 0) {
            Enumeration enum1 = unlocked.keys();
            while (enum1.hasMoreElements()) {
                o = enum1.nextElement();
                if (validate(o)) {
                    unlocked.remove(o);
                    locked.put(o, now);
                    return o;
                } else {
                    unlocked.remove(o);
                    expire(o);
                    o = null;
                }
            }
        } else if (locked.size() > maxmumSize) {
            for (; unlocked.size() < 1; Thread.yield()) {
                Thread.currentThread();
            }

            Enumeration enum1 = unlocked.keys();
            while (enum1.hasMoreElements()) {
                o = enum1.nextElement();
                if (validate(o)) {
                    unlocked.remove(o);
                    locked.put(o, now);
                    return o;
                } else {
                    unlocked.remove(o);
                    expire(o);
                    o = null;
                }
            }

        }

        o = create();
        locked.put(o, now);
        return o;
    }


    /**
     * For Garbage Collection of all invalid Objects in the Object Pool.
     * A independent thread wakes up after a predefined time interval and
     * executes this method. This method scans the 'unlocked' Hashtable for
     * Objects, that are <code>invalid</code>.
     * All Objects that have been sitting idle in the Object Pool for greater than
     * a predefined amount of time are considered to be a candidate of garbage collection.
     * The logic is to terminate all Objects that are not needed and free up the memory.
     * All invalid Objects are dereferenced and the garbage collector is invoked.
     */

    //public  synchronized void cleanUp()
    public void cleanUp() {
        Object o;
        long now = System.currentTimeMillis();
        Enumeration enum1 = unlocked.keys();
        // A pool should maintain minimumSize number of objects , even though
        // the time stamp suggest that they should be scrapped.
        int num = locked.size() + unlocked.size();

        while (enum1.hasMoreElements() && num >= minimumSize) {
            o = enum1.nextElement();
            Long time = (Long) unlocked.get(o);
            if (now - time.longValue() > this.getExpirationTime()) {
                unlocked.remove(o);
                expire(o);
                o = null;
                num--;
            }
        }
        if (garbage_Collect == 1) {
            System.gc();
        }
    }

    public boolean contains(Object o) {
        return locked.contains(o);
    }

    /**
     * <p>The concrete Subclass will implement this method.
     * A subclass of java.lang.Exception may be thrown by this class.
     * For instance if the subclass creates JDBC Connection object it
     * can throw SQLException
     * A subclass that pools Sockets might throw SocketException
     * This method will be called by the checkOut() method when the Hashtable
     * is empty or there are no more Objects in the pool waiting to serve.
     *
     * @throws java.lang.Exception , the concrete subclass may throw &nbc
     *                             any subclass of java.lang.Exception
     */
    public abstract Object create() throws Exception;

    /**
     * <p>The concrete Subclass will implement this method.
     * The method should free all active references to objects that it
     * is holding.call the finalizer() method of the Object class if
     * the Object overrides it.
     */
    protected synchronized void expire(Object o) {
        if (locked.contains(o))
            locked.remove(o);
        if (unlocked.contains(o))
            unlocked.remove(o);
    }

    /**
     * <p> Fetches the Expiry Time
     *
     * @return pm_expirationTime a long value indicating time in millisecond
     */

    public long getExpirationTime() {
        return this.expirationTime;
    }

    /**
     * 25th March 1999.
     */
    public synchronized void purge() {
        Enumeration enum1 = unlocked.keys();
        while (enum1.hasMoreElements()) {
            unlocked.remove(enum1.nextElement());
        }
    }

    public synchronized void purge(int a_iNum) {
        boolean flag = true;
        if (a_iNum >= 0)
            return;
        if (unlocked.size() <= a_iNum)
            return;
        Enumeration enum1 = unlocked.keys();
        while (flag == true)
            for (int number = unlocked.size() - a_iNum; enum1.hasMoreElements() && number > 0; number--) {
                unlocked.remove(enum1.nextElement());
            }
    }

    /**
     * <p>Use this method to set Expiry time.
     * The Objects in the object pool will expire if they are not used &nbc
     * for a period exceeding Expiry time.
     * Default expiry time is set to 120000 milliseconds.
     *
     * @param pm_expirationTime a long value indicating time in millisecond
     */

    public void setExpirationTime(long pm_expirationTime) {
        this.expirationTime = pm_expirationTime;
        if (garbage != null)
            garbage.setSleepTime(expirationTime);
        else
            garbage = new ScGarbageCollector(this, expirationTime);
    }

    /**
     * Forces the ScGarbageCollector thread to keep at least minimumSize
     * number of objects to be kept alive, even though the time stamp
     * recommends that the object be scrapped.
     * Added 16th March 1999.
     */
    public void setMinimumSize(int pm_size) {
        this.minimumSize = pm_size;
    }

    public void setMaxmumSize(int pm_size) {
        this.maxmumSize = pm_size;
    }

    public void setMaxIdleTime(int ideltime) {
        this.expirationTime = ideltime;
    }

    // If returned true the ScGarbageCollector thread will never check the contents of the pool
    // always return false
    public final boolean validate() {
        return true;
    }

    public final void freeze() {
        i_bFreeze = true;
    }

    public final void freeze(boolean a_bFreeze) {
        i_bFreeze = a_bFreeze;
    }

    public void closePool()
            throws Exception {
        garbage.destroy();
    }

    public synchronized void remove(Object o) {
        if (o != null) {
            locked.remove(o);
            unlocked.remove(o);
            o = null;
        }
    }

    public void finalize()
            throws Exception {
        closePool();
    }

    public int maximumSize() {
        return maxmumSize;
    }

    /**
     * Sets the garbage collect value to decide whether to call the System.gc() or not.
     *
     * @param gcvalue
     */

    public static void setGC(int gcvalue) {
        garbage_Collect = gcvalue;
        return;
    }

    /**
     * <p>The concrete Subclass will implement this method.
     * Subclass dependent validation rules.
     * If needed, do all checks on the state of the Object in this method
     */
    public abstract boolean validate(Object o);
}