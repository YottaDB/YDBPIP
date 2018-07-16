package sanchez.jdbc.dbaccess;

public class ScDBColumn
{
       
    public String fileName;
    public String colName;
    public int maxLength;
    public String defaultValue;
    public String dataType;
    public String colDescription;
    public int displaySize;
    public boolean nullable;
    public int decimalPrecision;
    public String subscrptKey;
    
    //FID,DI,LEN,DFT,TYP,DES,SIZ,REQ,DEC,NOD FROM "
    
    public ScDBColumn()
    {

    }

    public ScDBColumn(String fileName,
                        String colName,
                        int maxLength,
                        String defaultValue,
                        String dataType,
                        String colDescription,
                        int displaySize,
                        boolean nullable,
                        int decimalPrecision,
                        String subscrptKey
                        )
    {

        this.fileName = fileName;
        this.colName = colName;
        this.maxLength = maxLength;
        this.defaultValue = defaultValue;
        this.dataType = dataType;
        this.colDescription = colDescription;
        this.nullable = nullable;
        this.decimalPrecision = decimalPrecision;

    }


    public String getColumnName()
    {
        return fileName+"."+colName;
    }

}

