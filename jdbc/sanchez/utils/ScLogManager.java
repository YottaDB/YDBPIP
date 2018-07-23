/**
 * Registry for loggable logger objects. Core implementation of Doer-Doable pattern.
 * Each object that wishes to be logged should be registered against the logger
 * object in the registry below.
 *
 * @version 1.0, 6/21/99
 * @author Pranav G. Amin
 * @see        sanchez.utils.SiLogger
 * @see        sanchez.utils.SiLoggable
 * @see        sanchez.utils.ScFileLogger
 * @see        Doer Doable pattern in the GAEA design documentations.
 * @modification 09/08/1999      Quansheng Jia
 * weblink
 */


package sanchez.utils;

import java.io.FileWriter;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.StringTokenizer;
import java.util.Vector;

public class ScLogManager extends sanchez.base.ScObjectGlobal {
    private static Hashtable c_oLogRegistry = new Hashtable();
    private static FileWriter LoggerErrorLog;

    private static int[] iType = {1};
    private static String[] sDoable = {"sanchez.base.ScException"};
    private static int[] iDoerCount = {1};
    private static String[] sDoer = {"sanchez.utils.ScFileLogger"};

    /**  the static block below gets executed as soon as the class
     *  gets loaded. Essentially at load time the class will fetch
     *  information about all the registered loggables and loggers.
     *  Based on this information a table is created in the memory.
     *  Whenever a loggable is created the ScLogManager is notified.
     *  ScLogManager passes the Loggable Object to all registered Loggers.
     */

    static {
        try {
            LoggerErrorLog = new FileWriter("LoggerLog.txt");

            for (int i = 0; i < sDoable.length; i++) {
                Vector v = new Vector();
                String doable = sDoable[i];
                String doers = sDoer[i];
                StringTokenizer tokenizer = new StringTokenizer(doers);
                while (tokenizer.hasMoreTokens()) {
                    // Each token represents a string holding the doer name.
                    // Vector will have refence to all registered doer objects.
                    Object obj = Class.forName(tokenizer.nextToken()).newInstance();
                    v.addElement(obj);
                }
                c_oLogRegistry.put(doable.trim(), v);
            }

        }//end of try
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * This method finds out the registered Logger for the given Loggable.
     * It then call the log() method of all the registred Loggers.
     *
     *
     * @param  SiLoggable The Object that is requested to be logged.
     * @see     java.sanchez.SiLoggable
     */

    public static void log(SiLoggable a_oLoggable) {
        try {
            String className;
            Class c = a_oLoggable.getClass();
            do {
                className = c.getName().trim();
                c = c.getSuperclass();
            } while ((!c_oLogRegistry.containsKey(className)) && (!className.equals("java.lang.Object")));

            if (c_oLogRegistry.containsKey(className)) {
                Vector v = (Vector) c_oLogRegistry.get(className);
                Enumeration enum1 = v.elements();
                while (enum1.hasMoreElements()) {
                    try {
                        SiLogger Logger = (SiLogger) enum1.nextElement();
                        Logger.log(a_oLoggable);
                    } catch (Exception exc) {
                        exc.printStackTrace();
                        // if class cast or ioexception skip that Logger
                        // and go to the next one.
                    }
                }//while
            }// if (registered)
        } catch (Exception e) {
            e.printStackTrace();
            try {
                LoggerErrorLog.write(e.toString());
                LoggerErrorLog.flush();
            } catch (Exception exception) {
            }
        }
    }

    /**
     * Method to aid Debugging.
     */
    static void display() {
        //ScDebug.setDebugln(ScISKeys.iDEBUGSYSTEM,"In display"+c_oLogRegistry.size());
        Enumeration enum1 = c_oLogRegistry.keys();
        while (enum1.hasMoreElements()) {
            String s = (String) enum1.nextElement();
            //ScDebug.setDebugln(ScISKeys.iDEBUGSYSTEM,s);
            Vector v = (Vector) c_oLogRegistry.get(s);
            Enumeration venum = v.elements();
	       /*
	        while(venum.hasMoreElements())
	            ScDebug.setDebugln(ScISKeys.iDEBUGSYSTEM,venum.nextElement().toString());
	       */
        }
    }
}

