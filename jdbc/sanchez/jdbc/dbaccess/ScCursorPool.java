package sanchez.jdbc.dbaccess;

public class ScCursorPool extends sanchez.utils.objectpool.ScObjectPool
{

	public ScCursorPool()
	{
		super();
    }
	
	public Object create() 
	{
		long now = System.currentTimeMillis();
		return String.valueOf(now);
	}
	
	public void expire(Object o)
	{
	
	}
	
	public boolean validate(Object o)
	{		
		return true;
	}

}