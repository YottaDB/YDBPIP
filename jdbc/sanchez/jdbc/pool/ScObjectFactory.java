package sanchez.jdbc.pool;

import java.util.Hashtable;
import javax.naming.Context;
import javax.naming.Name;
import javax.naming.Reference;
import javax.naming.StringRefAddr;
import javax.naming.spi.ObjectFactory;

public class ScObjectFactory
        implements ObjectFactory {

    public ScObjectFactory() {
    }

    public Object getObjectInstance(Object refObj,
                                    Name name,
                                    Context nameCtx,
                                    Hashtable ht)
            throws Exception {
        Reference reference = (Reference) refObj;

        Object obj1 = null;
        String s = reference.getClassName();
        if (s.equals("sanchez.jdbc.pool.ScDataSource"))
            obj1 = new ScDataSource();
        else if (s.equals("sanchez.jdbc.pool.ScConnectionPoolDataSource"))
            obj1 = new ScConnectionPoolDataSource();
        else if (s.equals("sanchez.jdbc.pool.ScJDBCConnectionPoolCache"))
            obj1 = new ScJDBCConnectionPoolCache();

        if (obj1 != null) {
            StringRefAddr srf = null;
            if ((srf = (StringRefAddr) reference.get("url")) != null)
                ((ScDataSource) (obj1)).setURL((String) srf.getContent());
            if ((srf = (StringRefAddr) reference.get("user")) != null)
                ((ScDataSource) (obj1)).setUser((String) srf.getContent());
            if ((srf = (StringRefAddr) reference.get("networkProtocol")) != null)
                ((ScDataSource) (obj1)).setNetworkProtocol((String) srf.getContent());
            if ((srf = (StringRefAddr) reference.get("password")) != null)
                ((ScDataSource) (obj1)).setPassword((String) srf.getContent());
            if ((srf = (StringRefAddr) reference.get("serverName")) != null)
                ((ScDataSource) (obj1)).setServerName((String) srf.getContent());
            if ((srf = (StringRefAddr) reference.get("description")) != null)
                ((ScDataSource) (obj1)).setDescription((String) srf.getContent());
            if ((srf = (StringRefAddr) reference.get("portNumber")) != null) {
                String s1 = (String) srf.getContent();
                ((ScDataSource) (obj1)).setPortNumber(Integer.parseInt(s1));
            }
            if ((srf = (StringRefAddr) reference.get("databaseName")) != null)
                ((ScDataSource) (obj1)).setDatabaseName((String) srf.getContent());
            if ((srf = (StringRefAddr) reference.get("signOnType")) != null) {
                String s1 = (String) srf.getContent();
                ((ScDataSource) (obj1)).setSignOnType(Integer.parseInt(s1));
            }
        }
        return obj1;


    }
}