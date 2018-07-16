package sanchez.jdbc.utils;

import java.sql.SQLException;

public class ScSerialException extends SQLException
{

    public ScSerialException()
    {
    }

    public ScSerialException(String s)
    {
        super(s);
    }
}
