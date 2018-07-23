package sanchez.utils;

import java.util.Vector;

import sanchez.utils.ScSerialHandler;

public class ScSerialUtils {

    public static String ScGetObjectToString(Object obj) {
        if (obj == null)
            return null;
        try {
            ScSerialHandler saserialhandler = new ScSerialHandler();
            if (saserialhandler != null)
                return saserialhandler.ScGetObjectToString(obj);
        } catch (Throwable _ex) {
        }
        return null;
    }

    public static Object ScGetObjectFromString(String s) {
        if (s == null)
            return null;
        try {
            ScSerialHandler saserialhandler = new ScSerialHandler();
            if (saserialhandler != null)
                return saserialhandler.ScGetObjectFromString(s);
        } catch (Throwable _ex) {
        }
        return null;
    }

    public static void main(String args[]) {
        Vector vector = new Vector();
        vector.addElement("mark");
        System.err.println(vector.toString());
        String s = ScGetObjectToString(vector);
        System.err.println("len-" + s.length());
        Vector vector1 = (Vector) ScGetObjectFromString(s);
        System.err.println(vector1.toString());
        String s1 = new String("hi");
        s = ScGetObjectToString(s1);
        System.err.println("len-" + s.length());
        String s2 = (String) ScGetObjectFromString(s);
        System.err.println(s2.toString());
    }

    public ScSerialUtils() {
    }
}
