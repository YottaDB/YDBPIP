package sanchez.jdbc.dbaccess;

public class ScDBType {
    public int type;
    public int max_length;
    public boolean is_stream;
    public static final int CHAR = 96;
    public static final int VARCHAR = 1;
    public static final int LONG = 8;
    public static final int NUMBER = 2;
    public static final int VARNUM = 6;
    public static final int RAW = 23;
    public static final int LONG_RAW = 24;
    public static final int ROWID = 11;
    public static final int RESULT_SET = 102;
    public static final int DATE = 12;
    public static final int BLOB = 113;
    public static final int CLOB = 112;
    public static final int BFILE = 114;
    public static final int CFILE = 115;


    public void setFields(int type) {
        is_stream = false;
        switch (type) {
            case 96:
                max_length = 255;
                return;

            case 1:
                max_length = 2000;
                return;

            case 8:
                max_length = 2147483647;
                is_stream = true;
                return;

            case 2:
            case 6:
                max_length = 22;
                return;

            case 23:
                max_length = 255;
                return;

            case 24:
                max_length = 2147483647;
                is_stream = true;
                return;

            case 11:
                max_length = 128;
                return;


            case 102:
                max_length = 0;
                return;

            case 12:
                max_length = 7;
                return;

            case 112:
            case 113:
                max_length = 86;
                return;


            case 114:
            case 115:
                max_length = 530;
                break;

            default:
        }
        return;
    }


    public ScDBType(int type, int max_size, boolean is_stream) {
        this.type = type;
        setFields(type);
        if (!is_stream)
            max_length = Math.min(max_size, max_length);
        else
            max_length = max_size;
        this.is_stream = is_stream;
    }


    public ScDBType(int type) {
        this.type = type;
        setFields(type);
    }


    public ScDBType(int type, int max_size) {
        this.type = type;
        setFields(type);
        if (type == 102) {
            max_length = max_size;
            return;
        }

        max_length = Math.min(max_size, max_length);
    }

}

