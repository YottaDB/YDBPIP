package sanchez.utils;

import java.io.FileWriter;

public class ScUtilLogger extends FileWriter implements SiLogger {
    public ScUtilLogger() throws Exception {
        super("Util.txt", true);
    }

    public void log(SiLoggable logable) throws Exception {
        try {
            this.write(logable.getLogInfo());
            this.flush();
        } catch (Exception e) {
            throw e;
        }
    }
}