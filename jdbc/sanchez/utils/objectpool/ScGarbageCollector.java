package sanchez.utils.objectpool;

//class okay 9th March 1999

/**
 * This is a Thread class that wakes up after a specific time and executes
 * <code>cleanUp()</code> method of the  classes that implement ScCleanable.
 *
 * @author Pranav Amin
 * @version 1.0  2 Feb 1999
 * @see ScObjectPool
 * @see ScCleanable
 * @see java.util.Hashtable
 * <p>
 * Revision History:
 * Oct. 22 1999 Jiaq
 * Added ThreadGroup garbageGrp to destory the threads when shut down the JVM
 */


public class ScGarbageCollector extends Thread {
    private SiCleanable object;
    private long sleepTime;
    public static ThreadGroup garbageGrp = new ThreadGroup("garbage");
    private static int i = 0;

    /**
     * Constructor, accepts a reference to Object pool and a long referring
     * to sleep time
     */

    ScGarbageCollector(SiCleanable pm_object, long pm_sleepTime) {
        super(garbageGrp, String.valueOf(i++));
        this.object = pm_object;
        this.sleepTime = pm_sleepTime;
        setDaemon(true);

    }

    /**
     * Get the sleep time defined for the Thread
     */

    public long getSleepTime() {
        return sleepTime;
    }

    /**
     * Sleep for a period of sleepTime and execute cleanUp() method of the ScObjectPool
     */

    public void run() {
        for (; ; ) {
            try {
                sleep(this.getSleepTime());
            } catch (InterruptedException e) {
            }
            //if(!object.validate())
            object.cleanUp();
        }
    }

    /**
     * Set sleep time of the thread
     */

    public void setSleepTime(long pm_sleepTime) {
        this.sleepTime = pm_sleepTime;
    }
}