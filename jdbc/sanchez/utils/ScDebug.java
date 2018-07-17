package sanchez.utils;

/**
 * [This class will be used to embed debugging information throughout the code.
 * It allows to display of debug info by level, 1 to 100, the higher the more specific
 * It also allows to display debug info by label -- targeted debug information]
 *
 * @version
 * @author Li Hou
 * @history [date]   [author, description of modification]
 * @modification 08/04/1999 Quansheng Jia
 * weblink
 */

import sanchez.base.ScObject;
import sanchez.security.ScSystemSecurityManager;

public class ScDebug extends ScObject {

    private static int iiDebugLevel = 0;
    public static String isDebugLabel = "";
    private static int iiDebugProtect = 1;            // Debug protection on by default;

    public ScDebug() {
        super();
    }

    /**
     * This method is used to create a debug block
     * for example:
     if (ScDebug.executeDebug(9))
     {
     // debugging code
     ....
     }
     * @return boolean
     * @param aiDebugLevel int
     */
    public static boolean excuteDebug(int aiDebugLevel) {
        if (aiDebugLevel == 0)
            return false;

        if (aiDebugLevel <= 50 && iiDebugProtect == 1)  // debug protected.
            return false;

        if (aiDebugLevel >= iiDebugLevel)        // level logic.  Display all levels bigger than the set level
            return true;
        else
            return false;
    }

    /**
     * This method is used to create a debug block
     * for example:
     if (ScDebug.executeDebug("mylabel"))
     {
     // debugging code
     ....
     }
     * @return boolean
     * @param aiDebugLevel int
     */
    public static boolean excuteDebug(String asDebugLabel) {

        if (asDebugLabel.equals(isDebugLabel))        // label has to match
            return true;
        else
            return false;
    }

    /**
     * This method was created in VisualAge.
     * @return String
     */
    public String getDebugLabel() {
        return isDebugLabel;
    }

    /**
     * This method was created in VisualAge.
     * @return int
     */
    public int getDebugLevel() {
        return iiDebugLevel;
    }

    /**
     * This method was created in VisualAge.
     * @param newValue java.lang.String
     */
    public static int setDebugLabel(String newValue) {
        isDebugLabel = newValue;
        return 1;
    }

    /**
     * This method was created in VisualAge.
     * @param newValue int
     */
    public static int setDebugLevel(int newValue) {
        iiDebugLevel = newValue;
        return 1;
    }

    /**
     * This method was created in VisualAge.
     * @return int
     */
    public static int setDebugln(int aiDebugLevel, String asDebugText) {
        if (aiDebugLevel == 0)
            return 1;

        if (aiDebugLevel <= 50 && iiDebugProtect == 1)  // debug protected.
            return 1;

        //System.out.println(ScAbstractionUtils.getClientEnvValue("REMOTE_HOST"));

        if (aiDebugLevel >= iiDebugLevel)        // level logic.  Display all levels bigger than the set level
        {
            ScSystemSecurityManager sSM = (ScSystemSecurityManager) System.getSecurityManager();

            System.out.println("** (" + aiDebugLevel + ") in: " +
                    sSM.getClass(2).getName() +
                    "; caller: " + sSM.getClass(3).getName() + "> **\n" + asDebugText
                    + "\n** \\(" + aiDebugLevel + ")|");
            //+ ScAbstractionUtils.getClientEnvValue("REMOTE_HOST") + "> **");
        }

        return 1;
    }

    /**
     * This method was created in VisualAge.
     * @return int
     */
    public static int setDebugln(String asDebugLabel, String asDebugText) {
        if (asDebugLabel.equals(isDebugLabel)) {
            ScSystemSecurityManager sSM = (ScSystemSecurityManager) System.getSecurityManager();

            System.out.println("** (" + isDebugLabel + ") in: " + sSM.getClass(2).getName() +
                    "; caller: " + sSM.getClass(3).getName() + "> **\n" +
                    asDebugText + "\n** \\(" + isDebugLabel + ")|");
            //+ScAbstractionUtils.getClientEnvValue("REMOTE_HOST") + "> **");
        }
        return 1;
    }

    /**
     * This method was created in VisualAge.
     * @param newValue int
     */
    public static int setDebugProtect(int newValue) {
        iiDebugProtect = newValue;
        return 1;
    }

    /**
     * This method was created in VisualAge.
     * @return int
     */
    public static int viewClassStack(int aiDebugLevel, int aiStackDepth) {
        if (aiDebugLevel == 0)
            return 1;

        if (aiDebugLevel <= 50 && iiDebugProtect == 1)  // debug protected.
            return 1;

        if (aiDebugLevel >= iiDebugLevel)        // level logic.  Display all levels bigger than the set level
        {
            ScSystemSecurityManager sSM = (ScSystemSecurityManager) System.getSecurityManager();
            Class c;

            System.out.println("** (" + aiDebugLevel + ") - (class stack)> **");

            for (int iIdx = 0; iIdx < aiStackDepth; iIdx++) {
                c = sSM.getClass(iIdx + 2);

                if (c == null)
                    System.out.println(" (" + iIdx + ")> null class");
                else
                    System.out.println(" (" + iIdx + ")> " + sSM.getClass(iIdx + 2).getName());
            }

            System.out.println("** \\(" + aiDebugLevel + ") - (class stack)> **");
        }

        return 1;
    }

    /**
     * This method was created in VisualAge.
     * @return int
     */
    public static int viewClassStack(String asLabel, int aiStackDepth) {
        if (asLabel.equals(isDebugLabel)) {
            ScSystemSecurityManager sSM = (ScSystemSecurityManager) System.getSecurityManager();

            System.out.println("** (" + asLabel + ") - (class stack)> **");

            for (int iIdx = 0; iIdx < aiStackDepth; iIdx++) {
                System.out.println(" (" + iIdx + ")> " + sSM.getClass(iIdx + 2).getName());
            }

            System.out.println("** \\(" + asLabel + ") - (class stack)> **");
        }

        return 1;
    }
}