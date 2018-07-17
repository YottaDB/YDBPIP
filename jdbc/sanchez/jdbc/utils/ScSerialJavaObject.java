package sanchez.jdbc.utils;

import java.io.Serializable;
import java.lang.reflect.Field;
import java.sql.SQLException;

import sanchez.jdbc.dbaccess.ScDBError;

// Referenced classes of package javax.sql.rowset.serial:
//            SerialException

public class ScSerialJavaObject
        implements Serializable, Cloneable {

    public ScSerialJavaObject(Object obj1)
            throws SQLException {
        Class class1 = obj1.getClass();
        boolean flag = false;
        Class aclass[] = class1.getInterfaces();
        for (int i = 0; i < aclass.length; i++) {
            String s = aclass[i].getName();
            if (s == "java.io.Serializable")
                flag = true;
        }

        boolean flag1 = false;
        fields = class1.getFields();
        for (int j = 0; j < fields.length; j++)
            if (fields[j].getModifiers() == 8)
                flag1 = true;

        if (!flag || flag1) {
            throw new ScSerialException("Located static fields in object instance. Cannot serialize");
        } else {
            obj = obj1;
            return;
        }
    }

    public Object getObject()
            throws SQLException {
        return obj;
    }

    public Field[] getFields()
            throws SQLException {
        if (fields != null)
            return fields;
        else
            throw new ScSerialException("SerialJavaObject does not contain a serialized object instance");
    }

    private Object obj;
    private Field fields[];
}
