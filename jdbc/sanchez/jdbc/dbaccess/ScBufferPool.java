package sanchez.jdbc.dbaccess;

import java.util.Hashtable;

public class ScBufferPool extends sanchez.utils.objectpool.ScObjectPool {
    public ScBufferPool() {
        super();
    }

    public Object create() {
        long now = System.currentTimeMillis();
        return String.valueOf(now);
    }

    public void expire(Object o) {

    }

    public boolean validate(Object o) {
        return true;
    }

    public Hashtable getLockBuffer() {
        return locked;
    }
}