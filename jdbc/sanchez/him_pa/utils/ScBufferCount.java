package sanchez.him_pa.utils;

import sanchez.base.ScObject;

public class ScBufferCount extends ScObject
{
    boolean i_iOpen = false;
    public int iSeq = 0;
    
    public void setOpen(boolean iFlag)
    {
        i_iOpen=iFlag;
    }
    public boolean getOpen()
    {
        return i_iOpen;
    }
    
}