package sanchez.him_pa.utils;

/* Revision History:
 * May 10 1999 Jiaq
 * Created new method byteToString and stringToByte to convert byte to
 * string and string to byte
 */

import java.util.Vector;


/*
 *
 * CLASS TITLE:  UTILS
 *
 */
public class ScUtils extends sanchez.base.ScObject {

    private static final int MAX_BUFFER_SIZE = 35000;
    private static final int MAX_BYTE_VAL = 0XFF;
    private static final int MAX_WORD_VAL = 0XFFFF;
    private static final int MAX_3BYTE_VAL = 0XFFFFFF;

    public static final int COUNT_STRINGS = 0x0001;
    public static final int EXTRACT = 0x0002;
    public static final int i_NUMBER_SIZE = 2;
//--------------------------------------------------------------------------------------------------------------------------

    public int buffer_to_int(int pi_size, byte buffer[], int offset) {

        int ii = 0;

        switch (pi_size) {
            case 0: {
                return 0;
            }
            case 1: {
                return unsigned(buffer[offset]);
            }
            case 2: {
                ii = unsigned((unsigned(buffer[offset + 0]) * 0x100));
                ii += unsigned(buffer[offset + 1]);
                return ii;
            }
            case 3: {
                ii = unsigned((unsigned(buffer[offset + 0]) * 0x10000));
                ii += unsigned(buffer[offset + 1] * 0x100);
                ii += unsigned(buffer[offset + 2]);
                return ii;
            }
            case 4: {
                ii = unsigned((unsigned(buffer[offset + 0]) * 0x1000000));
                ii += unsigned((unsigned(buffer[offset + 1]) * 0x10000));
                ii += unsigned((unsigned(buffer[offset + 2]) * 0x100));
                ii += unsigned((unsigned(buffer[offset + 3])));
                return ii;
            }

        }//SWITCH ENDS

        return -1;
    }//METHOD BUFFER_TO_INT ENDS

    //--------------------------------------------------------------------------------------------------------------------------
    public int copy_buffer(char source,
                           byte dest_buffer[],
                           int buffer_offset) {

        dest_buffer[buffer_offset] = (byte) source;

        return (1);

    }  //END OF COPY_BUFFER 2

    //--------------------------------------------------------------------------------------------------------------------------
    public int copy_buffer(String source_buffer,
                           byte dest_buffer[],
                           int buffer_offset) {

        int i;
        char char_buffer[] = new char[source_buffer.length()];

        char_buffer = source_buffer.toCharArray();
        for (i = 0; i < source_buffer.length(); i++)
            dest_buffer[buffer_offset + i] = (byte) char_buffer[i];

        return (source_buffer.length());

    }  //END OF COPY_BUFFER 1

    //--------------------------------------------------------------------------------------------------------------------------
    public static void int_to_buffer(int pi_size, int num, byte buffer[], int offset) {


        switch (pi_size) {
            case 1: {
                buffer[offset + 0] = (byte) num;
                break;
            }
            case 2: {
                buffer[offset + 0] = (byte) ((num & 0x0000ff00) / 0x100);
                buffer[offset + 1] = (byte) ((num & 0x000000ff));
                break;
            }
            case 3: {
                buffer[offset + 0] = (byte) ((num & 0x00ff0000) / 0x10000);
                buffer[offset + 1] = (byte) ((num & 0x0000ff00 / 0x100));
                buffer[offset + 2] = (byte) ((num & 0x000000ff));
                break;
            }

            case 4: {
                buffer[offset + 0] = (byte) ((num & 0xff000000) / 0x1000000);
                buffer[offset + 1] = (byte) ((num & 0x00ff0000 / 0x10000));
                buffer[offset + 2] = (byte) ((num & 0x0000ff00 / 0x100));
                buffer[offset + 3] = (byte) ((num & 0x000000ff));
                break;
            }

        }//SWITCH ENDS

    }//METHOD INT_TO_BUFFER ENDS;
//--------------------------------------------------------------------------------------------------------------------------

    public int pack_number(int source_number,
                           byte dest_buffer[],
                           int buffer_offset) {

        int temp_number = 0, the_size;
        int i;

        if (source_number + 1 <= MAX_BYTE_VAL) {
            the_size = 1;
            temp_number = source_number + 1;
        } else if (source_number + 2 <= MAX_WORD_VAL) {
            the_size = 2;
            temp_number = source_number + 2;
        } else if (source_number + 3 <= MAX_3BYTE_VAL) {
            the_size = 3;
            temp_number = source_number + 3;
        } else {/*number is 4 bytes long*/
            the_size = 4;
            temp_number = source_number + 4;
        }

        if (the_size == 1) {
            dest_buffer[buffer_offset] = (byte) temp_number;
            return 1;
        } else {    //ELSE A

            dest_buffer[buffer_offset++] = 0;
            dest_buffer[buffer_offset] = (byte) the_size;
            for (i = (buffer_offset + the_size); i > buffer_offset; i--) {
                dest_buffer[i] = (byte) (temp_number % 256);
                temp_number /= 256;
            }
            return (the_size + 2);

        }/*END OF ELSE A*/
    }//PACK_NUMBER ENDS

    //--------------------------------------------------------------------------------------------------------------------------
    public int pack_string(byte source_string[],
                           int sizeof_source,
                           byte dest_buffer[],
                           int buffer_offset) {
        int i, j;

        i = pack_number(sizeof_source, dest_buffer, buffer_offset);
        for (j = 0; j < sizeof_source; j++)
            dest_buffer[buffer_offset + i + j] = source_string[j];

        return (i + sizeof_source);

    }//PACK_STRING ENDS	1

    //--------------------------------------------------------------------------------------------------------------------------
    public int pack_string(ScRawString source_string,
                           byte dest_buffer[],
                           int buffer_offset) {

        int i, j, sizeof_source = source_string.get_string_size();

        i = pack_number(sizeof_source, dest_buffer, buffer_offset);
        for (j = 0; j < sizeof_source; j++)
            dest_buffer[buffer_offset + i + j] = (byte) source_string.get_byte(j);


        return (i + sizeof_source);

    }//PACK_STRING ENDS	3

    //--------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------
    public int pack_string(String source_string,
                           byte dest_buffer[],
                           int buffer_offset) {

        int i, j, sizeof_source = source_string.length();

        i = pack_number(sizeof_source, dest_buffer, buffer_offset);
        for (j = 0; j < sizeof_source; j++)
            dest_buffer[buffer_offset + i + j] = (byte) source_string.charAt(j);


        return (i + sizeof_source);

    }//PACK_STRING ENDS	2

    //--------------------------------------------------------------------------------------------------------------------------
    public int pack_string(StringBuffer source_string,
                           byte dest_buffer[],
                           int buffer_offset) {

        ScRawString mystring = new ScRawString(source_string.toString());
        int ii = this.pack_string(mystring, dest_buffer, buffer_offset);
        return ii;

    }//PACK_STRING ENDS	4
    //--------------------------------------------------------------------------------------------------------------------------

    public int parse_string(byte source_buffer[],
                            int source_index,
                            int dest_array[],
                            int what_to_do) {
        int index = source_index, size_so_far = 0, total_size, i, offset = 0;
        ScInt ci = new ScInt();

        index += unpack_number(source_buffer, source_index, ci);
        total_size = ci.val;
        i = 1;

        while (size_so_far < total_size) {
            if (what_to_do == COUNT_STRINGS)
                i++;
            else
                dest_array[i++] = index;

            offset = unpack_number(source_buffer, index, ci);
            index += offset + ci.val;
            size_so_far += offset + ci.val;
        }

        /*** MKT */
        if ((source_index == 0) && (size_so_far > total_size))
            i = 1;
        /***/
        dest_array[0] = i;

        return (i);
    } //END OF PARSE_STRING

    //--------------------------------------------------------------------------------------------------------------------------
    //public utils () {
    //}
//--------------------------------------------------------------------------------------------------------------------------
    public static String toString(byte source_buffer[]) {

        int i, j;
        i = 0;
        while (source_buffer[i++] != 0) ;

        char temp_buffer[] = new char[i + 1];
        for (j = 0; j <= i; j++)
            temp_buffer[i] = (char) source_buffer[i];

        return String.valueOf(temp_buffer);

    }//TOSTRING METHOD ENDS

    //--------------------------------------------------------------------------------------------------------------------------
    public int unpack_number(byte source_buffer[],
                             int source_index,
                             ScInt number) {

        int index = source_index, size;

        if (source_buffer[index] != 0) {
            number.val = (unsigned(source_buffer[index]) - 1);    //abs
            number.total_size = 1;
            return 1;
        }

        index++;
        size = unsigned(source_buffer[index]);
        index++;

        number.val = 0;
        for (int i = 0; i < size; i++) {
            number.val *= 256;
            number.val += unsigned(source_buffer[index]);
            index++;
        }

        number.val -= size;
        number.total_size = (byte) (size + 2);
        return (size + 2);

    } //END OF UNPACK_NUMBER

    //--------------------------------------------------------------------------------------------------------------------------
    public static int unsigned(byte number) {

        return (int) (number & 0xFF);

    }

    //--------------------------------------------------------------------------------------------------------------------------
    public static int unsigned(int number) {

        if (number < 0)
            return (number * -1);
        else
            return number;
    }

    public static String byteToString(byte[] bByteArray, int offset) {

        int j = bByteArray.length;
        char[] cChar = new char[j];
        for (int i = 0; i < j; i++) {

            cChar[i] = (char) (bByteArray[i]);

        }

        return new String(cChar, 0, offset);

    }

    public static byte[] stringToByte(String a_sString) {
        int j = a_sString.length();
        byte[] a_bByte = new byte[j];
        for (int i = 0; i < j; i++) {
            a_bByte[i] = (byte) a_sString.charAt(i);
        }
        return a_bByte;
    }


    //unicode supporting
    public static String stringEncoding(String mess, String fileEncoding) {
        if (fileEncoding != null && mess != null) {
            try {
                byte[] bytes = null;
                if (fileEncoding.equalsIgnoreCase("UTF16") || fileEncoding.equalsIgnoreCase("UTF-16")) {
                    bytes = mess.getBytes("UTF8");
                } else bytes = mess.getBytes(fileEncoding);
                mess = ScUtils.byteToString(bytes, bytes.length);
            } catch (Exception e) {
            }
        }
        return mess;
    }


    public static String[] stringEncoding(String[] mess, String fileEncoding) {
        if (fileEncoding != null && mess != null) {
            try {
                String[] sNewPara = new String[mess.length];
                for (int i = 0; i < mess.length; i++) {
                    if (mess[i] == null) {
                        sNewPara[i] = null;
                        continue;
                    }
                    byte[] bytes = null;
                    if (fileEncoding.equalsIgnoreCase("UTF16") || fileEncoding.equalsIgnoreCase("UTF-16")) {
                        bytes = mess[i].getBytes("UTF8");
                    } else bytes = mess[i].getBytes(fileEncoding);
                    sNewPara[i] = ScUtils.byteToString(bytes, bytes.length);
                }
                return sNewPara;
            } catch (Exception e) {
            }
        }
        return mess;
    }

    public static Vector stringEncoding(Vector mess, String fileEncoding) {
        if (fileEncoding != null && mess != null) {
            try {
                Vector v = new Vector();
                for (int i = 0; i < mess.size(); i++) {

                    if (mess.get(i) == null) {
                        v.add(null);
                        continue;
                    }
                    byte[] bytes = null;
                    if (fileEncoding.equalsIgnoreCase("UTF16") || fileEncoding.equalsIgnoreCase("UTF-16")) {
                        bytes = ((String) mess.get(i)).getBytes("UTF8");
                    } else bytes = ((String) mess.get(i)).getBytes(fileEncoding);
                    v.add(ScUtils.byteToString(bytes, bytes.length));
                }
                return v;
            } catch (Exception e) {
            }
        }
        return mess;
    }

    private static final String UTF_EMPTY = "UTF_EMPTY";
    private static final String UTF8EN = "UTF8EN";
    private static final String UTF32LE = "UTF32LE";
    private static final String UTF32BE = "UTF32BE";
    private static final String UTF16LE = "UTF16LE";
    private static final String UTF16BE = "UTF16BE";
    private static String UTF16 = "UTF-16";
    private static String UTF8 = "UTF-8";

    public static String detectEncoding(byte[] defaultBytes) {

        if (defaultBytes.length < 1) return UTF_EMPTY;
        if (defaultBytes.length < 2) return UTF8EN;    // assume UTF-8
        if (defaultBytes.length >= 4) {
            if (defaultBytes[0] == (byte) 0xFF &&
                    defaultBytes[1] == (byte) 0xFE &&
                    defaultBytes[2] == (byte) 0x00 &&
                    defaultBytes[3] == (byte) 0x00)
                return UTF32LE;
            if (defaultBytes[0] == (byte) 0x00 &&
                    defaultBytes[1] == (byte) 0x00 &&
                    defaultBytes[2] == (byte) 0xFE &&
                    defaultBytes[3] == (byte) 0xFF)
                return UTF32BE;
        }

        if (defaultBytes.length >= 3) {
            if (defaultBytes[0] == (byte) 0xEF &&
                    defaultBytes[1] == (byte) 0xBB &&
                    defaultBytes[2] == (byte) 0xBF)
                return UTF8EN;
        }

        if (defaultBytes.length >= 2) {
            if (defaultBytes[0] == (byte) 0xFF && defaultBytes[1] == (byte) 0xFE)
                return UTF16LE;
            else if (defaultBytes[0] == (byte) 0xFE && defaultBytes[1] == (byte) 0xFF)
                return UTF16BE;
            else if (defaultBytes[0] == (byte) 0x3C && defaultBytes[1] == (byte) 0x00)
                return UTF16LE;
            else if (defaultBytes[0] == (byte) 0x00 && defaultBytes[1] == (byte) 0x3C)
                return UTF16BE;
            else if (defaultBytes[0] == (byte) 0x3F && defaultBytes[1] == (byte) 0x00)
                return UTF16LE;
            else if (defaultBytes[0] == (byte) 0x00 && defaultBytes[1] == (byte) 0x3F)
                return UTF16BE;
        }

        return UTF8EN; // fall back on UTF-8 sort of equals ANSI/ASCII
    }
} //CLASS ScUtils ENDS
