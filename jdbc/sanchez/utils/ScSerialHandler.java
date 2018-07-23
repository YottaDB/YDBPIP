package sanchez.utils;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;


public class ScSerialHandler {

    public static String ConvertByteArrayToHexStringReal(byte abyte0[]) {
        if (abyte0 == null || abyte0.length < 1)
            return null;
        StringBuffer stringbuffer = new StringBuffer(2 * abyte0.length);
        int k = abyte0.length;
        for (int l = 0; l < k; l++) {
            byte byte0 = abyte0[l];
            int i = byte0 / 16;
            int j = byte0 % 16;
            char c;
            switch (i) {
                case 0: // '\0'
                    c = '0';
                    break;

                case 1: // '\001'
                    c = '1';
                    break;

                case 2: // '\002'
                    c = '2';
                    break;

                case 3: // '\003'
                    c = '3';
                    break;

                case 4: // '\004'
                    c = '4';
                    break;

                case 5: // '\005'
                    c = '5';
                    break;

                case 6: // '\006'
                    c = '6';
                    break;

                case 7: // '\007'
                    c = '7';
                    break;

                case 8: // '\b'
                    c = '8';
                    break;

                case 9: // '\t'
                    c = '9';
                    break;

                case 10: // '\n'
                    c = 'A';
                    break;

                case 11: // '\013'
                    c = 'B';
                    break;

                case 12: // '\f'
                    c = 'C';
                    break;

                case 13: // '\r'
                    c = 'D';
                    break;

                case 14: // '\016'
                    c = 'E';
                    break;

                case 15: // '\017'
                    c = 'F';
                    break;

                default:
                    c = '0';
                    break;

            }
            char c1;
            switch (j) {
                case 0: // '\0'
                    c1 = '0';
                    break;

                case 1: // '\001'
                    c1 = '1';
                    break;

                case 2: // '\002'
                    c1 = '2';
                    break;

                case 3: // '\003'
                    c1 = '3';
                    break;

                case 4: // '\004'
                    c1 = '4';
                    break;

                case 5: // '\005'
                    c1 = '5';
                    break;

                case 6: // '\006'
                    c1 = '6';
                    break;

                case 7: // '\007'
                    c1 = '7';
                    break;

                case 8: // '\b'
                    c1 = '8';
                    break;

                case 9: // '\t'
                    c1 = '9';
                    break;

                case 10: // '\n'
                    c1 = 'A';
                    break;

                case 11: // '\013'
                    c1 = 'B';
                    break;

                case 12: // '\f'
                    c1 = 'C';
                    break;

                case 13: // '\r'
                    c1 = 'D';
                    break;

                case 14: // '\016'
                    c1 = 'E';
                    break;

                case 15: // '\017'
                    c1 = 'F';
                    break;

                default:
                    c1 = '0';
                    break;

            }
            stringbuffer.append(c);
            stringbuffer.append(c1);
        }

        return stringbuffer.toString();
    }

    public static String ConvertByteArrayToString(byte abyte0[]) {
        if (abyte0 == null || abyte0.length < 1)
            return null;
        StringBuffer stringbuffer = new StringBuffer(abyte0.length);
        int j = abyte0.length;
        for (int k = 0; k < j; k++) {
            int i = abyte0[k] + 128;
            stringbuffer.append((char) i);
        }

        return stringbuffer.toString();
    }

    public static String ConvertByteArrayToHexString(byte abyte0[]) {
        if (abyte0 == null || abyte0.length < 1)
            return null;
        StringBuffer stringbuffer = new StringBuffer(2 * abyte0.length);
        int l = abyte0.length;
        for (int i1 = 0; i1 < l; i1++) {
            int k = abyte0[i1] + 128;
            int i = k / 16;
            int j = k % 16;
            char c;
            switch (i) {
                case 0: // '\0'
                    c = '0';
                    break;

                case 1: // '\001'
                    c = '1';
                    break;

                case 2: // '\002'
                    c = '2';
                    break;

                case 3: // '\003'
                    c = '3';
                    break;

                case 4: // '\004'
                    c = '4';
                    break;

                case 5: // '\005'
                    c = '5';
                    break;

                case 6: // '\006'
                    c = '6';
                    break;

                case 7: // '\007'
                    c = '7';
                    break;

                case 8: // '\b'
                    c = '8';
                    break;

                case 9: // '\t'
                    c = '9';
                    break;

                case 10: // '\n'
                    c = 'A';
                    break;

                case 11: // '\013'
                    c = 'B';
                    break;

                case 12: // '\f'
                    c = 'C';
                    break;

                case 13: // '\r'
                    c = 'D';
                    break;

                case 14: // '\016'
                    c = 'E';
                    break;

                case 15: // '\017'
                    c = 'F';
                    break;

                default:
                    c = '0';
                    break;

            }
            char c1;
            switch (j) {
                case 0: // '\0'
                    c1 = '0';
                    break;

                case 1: // '\001'
                    c1 = '1';
                    break;

                case 2: // '\002'
                    c1 = '2';
                    break;

                case 3: // '\003'
                    c1 = '3';
                    break;

                case 4: // '\004'
                    c1 = '4';
                    break;

                case 5: // '\005'
                    c1 = '5';
                    break;

                case 6: // '\006'
                    c1 = '6';
                    break;

                case 7: // '\007'
                    c1 = '7';
                    break;

                case 8: // '\b'
                    c1 = '8';
                    break;

                case 9: // '\t'
                    c1 = '9';
                    break;

                case 10: // '\n'
                    c1 = 'A';
                    break;

                case 11: // '\013'
                    c1 = 'B';
                    break;

                case 12: // '\f'
                    c1 = 'C';
                    break;

                case 13: // '\r'
                    c1 = 'D';
                    break;

                case 14: // '\016'
                    c1 = 'E';
                    break;

                case 15: // '\017'
                    c1 = 'F';
                    break;

                default:
                    c1 = '0';
                    break;

            }
            stringbuffer.append(c);
            stringbuffer.append(c1);
        }

        return stringbuffer.toString();
    }

    public static char getHexFromInt(int i) {
        if (i < 0 || i > 15)
            return '0';
        switch (i) {
            case 0: // '\0'
                return '0';

            case 1: // '\001'
                return '1';

            case 2: // '\002'
                return '2';

            case 3: // '\003'
                return '3';

            case 4: // '\004'
                return '4';

            case 5: // '\005'
                return '5';

            case 6: // '\006'
                return '6';

            case 7: // '\007'
                return '7';

            case 8: // '\b'
                return '8';

            case 9: // '\t'
                return '9';

            case 10: // '\n'
                return 'A';

            case 11: // '\013'
                return 'B';

            case 12: // '\f'
                return 'C';

            case 13: // '\r'
                return 'D';

            case 14: // '\016'
                return 'E';

            case 15: // '\017'
                return 'F';

        }
        return '0';
    }

    public static int getIntFromHex(char c) {
        switch (c) {
            case 48: // '0'
                return 0;

            case 49: // '1'
                return 1;

            case 50: // '2'
                return 2;

            case 51: // '3'
                return 3;

            case 52: // '4'
                return 4;

            case 53: // '5'
                return 5;

            case 54: // '6'
                return 6;

            case 55: // '7'
                return 7;

            case 56: // '8'
                return 8;

            case 57: // '9'
                return 9;

            case 65: // 'A'
                return 10;

            case 66: // 'B'
                return 11;

            case 67: // 'C'
                return 12;

            case 68: // 'D'
                return 13;

            case 69: // 'E'
                return 14;

            case 70: // 'F'
                return 15;

        }
        return 0;
    }

    public static byte[] ConvertStringToByteArray(String s) {
        if (s == null || s.length() < 1)
            return null;
        int i = s.length();
        byte abyte0[] = new byte[i];
        for (int k = 0; k < i; k++) {
            char c = s.charAt(k);
            int j = c;
            j -= 128;
            abyte0[k] = (byte) j;
        }

        return abyte0;
    }

    public static byte[] ConvertHexStringToByteArray(String s) {
        if (s == null || s.length() < 1)
            return null;
        int i = s.length();
        if (i % 2 != 0) {
            s = s + "0";
            i = s.length();
        }
        byte abyte0[] = new byte[i / 2];
        for (int k = 0; k < i; k += 2) {
            char c = s.charAt(k);
            char c1 = s.charAt(k + 1);
            byte byte0;
            switch (c) {
                case 48: // '0'
                    byte0 = 0;
                    break;

                case 49: // '1'
                    byte0 = 1;
                    break;

                case 50: // '2'
                    byte0 = 2;
                    break;

                case 51: // '3'
                    byte0 = 3;
                    break;

                case 52: // '4'
                    byte0 = 4;
                    break;

                case 53: // '5'
                    byte0 = 5;
                    break;

                case 54: // '6'
                    byte0 = 6;
                    break;

                case 55: // '7'
                    byte0 = 7;
                    break;

                case 56: // '8'
                    byte0 = 8;
                    break;

                case 57: // '9'
                    byte0 = 9;
                    break;

                case 65: // 'A'
                case 97: // 'a'
                    byte0 = 10;
                    break;

                case 66: // 'B'
                case 98: // 'b'
                    byte0 = 11;
                    break;

                case 67: // 'C'
                case 99: // 'c'
                    byte0 = 12;
                    break;

                case 68: // 'D'
                case 100: // 'd'
                    byte0 = 13;
                    break;

                case 69: // 'E'
                case 101: // 'e'
                    byte0 = 14;
                    break;

                case 70: // 'F'
                case 102: // 'f'
                    byte0 = 15;
                    break;

                default:
                    byte0 = 0;
                    break;

            }
            byte byte1;
            switch (c1) {
                case 48: // '0'
                    byte1 = 0;
                    break;

                case 49: // '1'
                    byte1 = 1;
                    break;

                case 50: // '2'
                    byte1 = 2;
                    break;

                case 51: // '3'
                    byte1 = 3;
                    break;

                case 52: // '4'
                    byte1 = 4;
                    break;

                case 53: // '5'
                    byte1 = 5;
                    break;

                case 54: // '6'
                    byte1 = 6;
                    break;

                case 55: // '7'
                    byte1 = 7;
                    break;

                case 56: // '8'
                    byte1 = 8;
                    break;

                case 57: // '9'
                    byte1 = 9;
                    break;

                case 65: // 'A'
                case 97: // 'a'
                    byte1 = 10;
                    break;

                case 66: // 'B'
                case 98: // 'b'
                    byte1 = 11;
                    break;

                case 67: // 'C'
                case 99: // 'c'
                    byte1 = 12;
                    break;

                case 68: // 'D'
                case 100: // 'd'
                    byte1 = 13;
                    break;

                case 69: // 'E'
                case 101: // 'e'
                    byte1 = 14;
                    break;

                case 70: // 'F'
                case 102: // 'f'
                    byte1 = 15;
                    break;

                default:
                    byte1 = 0;
                    break;

            }
            int j = byte0 * 16 + byte1;
            j -= 128;
            abyte0[k / 2] = (byte) j;
        }

        return abyte0;
    }

    public static byte[] ConvertHexStringToByteArrayReal(String s) {
        if (s == null || s.length() < 1)
            return null;
        int i = s.length();
        if (i % 2 != 0) {
            s = s + "0";
            i = s.length();
        }
        byte abyte0[] = new byte[i / 2];
        for (int k = 0; k < i; k += 2) {
            char c = s.charAt(k);
            char c1 = s.charAt(k + 1);
            byte byte0;
            switch (c) {
                case 48: // '0'
                    byte0 = 0;
                    break;

                case 49: // '1'
                    byte0 = 1;
                    break;

                case 50: // '2'
                    byte0 = 2;
                    break;

                case 51: // '3'
                    byte0 = 3;
                    break;

                case 52: // '4'
                    byte0 = 4;
                    break;

                case 53: // '5'
                    byte0 = 5;
                    break;

                case 54: // '6'
                    byte0 = 6;
                    break;

                case 55: // '7'
                    byte0 = 7;
                    break;

                case 56: // '8'
                    byte0 = 8;
                    break;

                case 57: // '9'
                    byte0 = 9;
                    break;

                case 65: // 'A'
                case 97: // 'a'
                    byte0 = 10;
                    break;

                case 66: // 'B'
                case 98: // 'b'
                    byte0 = 11;
                    break;

                case 67: // 'C'
                case 99: // 'c'
                    byte0 = 12;
                    break;

                case 68: // 'D'
                case 100: // 'd'
                    byte0 = 13;
                    break;

                case 69: // 'E'
                case 101: // 'e'
                    byte0 = 14;
                    break;

                case 70: // 'F'
                case 102: // 'f'
                    byte0 = 15;
                    break;

                default:
                    byte0 = 0;
                    break;

            }
            byte byte1;
            switch (c1) {
                case 48: // '0'
                    byte1 = 0;
                    break;

                case 49: // '1'
                    byte1 = 1;
                    break;

                case 50: // '2'
                    byte1 = 2;
                    break;

                case 51: // '3'
                    byte1 = 3;
                    break;

                case 52: // '4'
                    byte1 = 4;
                    break;

                case 53: // '5'
                    byte1 = 5;
                    break;

                case 54: // '6'
                    byte1 = 6;
                    break;

                case 55: // '7'
                    byte1 = 7;
                    break;

                case 56: // '8'
                    byte1 = 8;
                    break;

                case 57: // '9'
                    byte1 = 9;
                    break;

                case 65: // 'A'
                case 97: // 'a'
                    byte1 = 10;
                    break;

                case 66: // 'B'
                case 98: // 'b'
                    byte1 = 11;
                    break;

                case 67: // 'C'
                case 99: // 'c'
                    byte1 = 12;
                    break;

                case 68: // 'D'
                case 100: // 'd'
                    byte1 = 13;
                    break;

                case 69: // 'E'
                case 101: // 'e'
                    byte1 = 14;
                    break;

                case 70: // 'F'
                case 102: // 'f'
                    byte1 = 15;
                    break;

                default:
                    byte1 = 0;
                    break;

            }
            int j = byte0 * 16 + byte1;
            abyte0[k / 2] = (byte) j;
        }

        return abyte0;
    }

    public String ScGetObjectToString(Object obj) {
        if (obj == null)
            return null;
        try {
            ByteArrayOutputStream bytearrayoutputstream = new ByteArrayOutputStream();
            ObjectOutputStream objectoutputstream = new ObjectOutputStream(bytearrayoutputstream);
            objectoutputstream.writeObject(obj);
            byte abyte0[] = bytearrayoutputstream.toByteArray();
            if (abyte0 == null)
                return null;
            else
                return ConvertByteArrayToHexString(abyte0);
        } catch (Exception exception) {
            return null;
        }
    }

    public Object ScGetObjectFromString(String s) {
        if (s == null)
            return null;
        try {
            if (s == null) {
                return null;
            } else {
                byte abyte0[] = ConvertHexStringToByteArray(s);
                ByteArrayInputStream bytearrayinputstream = new ByteArrayInputStream(abyte0);
                ObjectInputStream objectinputstream = new ObjectInputStream(bytearrayinputstream);
                return objectinputstream.readObject();
            }
        } catch (Exception exception) {
            return null;
        }
    }

    public ScSerialHandler() {
    }
}
