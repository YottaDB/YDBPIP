package sanchez.him_pa.utils;

import java.util.StringTokenizer;

import sanchez.him_pa.utils.ScStringTokenizer;

public class ScMrpcUtility {
    public ScMrpcUtility() {
    }

    public static String parser(String X, String delimiter) {
        String wrd = "";
        String chrtbl = "=" + delimiter;
        int i, j = 1, a, b;
        StringBuffer sTemp = new StringBuffer();

        ScStringTokenizer sToken = new ScStringTokenizer(X, chrtbl, true);

        while (wrd != "end!") {
            wrd = atomHost(sToken);
            if (wrd == "end!") break;

            if (wrd.indexOf("=") == 0) {
                wrd = atomHost(sToken);
                if (wrd.charAt(0) == '\'') {
                    int iLen = wrd.length();
                    if ((iLen == 1) || (wrd.charAt(wrd.length() - 1) != '\'') || ((wrd.charAt(wrd.length() - 1) == '\'') && (wrd.charAt(wrd.length() - 2) == '\'') && (wrd.compareTo("''") != 0))) {
                        while (sToken.hasMoreTokens()) {
                            wrd = wrd + sToken.nextToken();
                            if ((wrd.charAt(wrd.length() - 1) == '\'') && (wrd.charAt(wrd.length() - 2) != '\'')) break;
                        }//while
                    }//if literal
                }
                i = sToken.getcurrentPosition();
                String oldWrd = new String(wrd);
                if (wrd.compareTo(delimiter) != 0)
                    wrd = doubleQutoe(wrd);
                else
                    wrd = "''" + delimiter;

                X = X.substring(0, i - oldWrd.length()) + wrd + X.substring(i, X.length());
                sToken.setStr(X);
                sToken.setCurrentPos(i - oldWrd.length() + wrd.length());
            }//if
        }//while

        sToken = new ScStringTokenizer(X, "=", false);
        int count, firstComma, lastComma;
        while (sToken.hasMoreTokens()) {
            String word = sToken.nextToken();
            StringTokenizer o = new StringTokenizer(word, delimiter);
            count = o.countTokens();
            if (count > 2) {
                firstComma = word.indexOf(delimiter);
                if (word.charAt(firstComma - 1) != '\'') break;
                lastComma = word.lastIndexOf(delimiter);

                i = sToken.getcurrentPosition();
                if (X.indexOf("=", i) < 0)
                    word = word.substring(0, firstComma - 1) + word.substring(firstComma, lastComma) + word.substring(lastComma, word.length()) + "'";
                else
                    word = word.substring(0, firstComma - 1) + word.substring(firstComma, lastComma) + "'" + word.substring(lastComma, word.length());

                X = X.substring(0, i - word.length()) + word + X.substring(i, X.length());
            }
        }
        return X;
    }

    private static String doubleQutoe(String wrd) {
        wrd = wrd.trim();
        String chrtbl = "'\"";
        ScStringTokenizer sToken = new ScStringTokenizer(wrd, chrtbl, true);
        String sTemp = new String();
        int currentPosition;
        while (sToken.hasMoreTokens()) {
            sTemp = sToken.nextToken();
            currentPosition = sToken.getcurrentPosition();
            if (currentPosition == 1 || currentPosition == wrd.length()) continue;
            if (wrd.charAt(currentPosition - 1) == '\'' && wrd.charAt(currentPosition) != '\'') {
                wrd = wrd.substring(0, currentPosition) + "'" + wrd.substring(currentPosition, wrd.length());
                sToken.setStr(wrd);
                sToken.setCurrentPos(currentPosition + 1);
            } else if (wrd.charAt(currentPosition - 1) == '\'' && wrd.charAt(currentPosition) == '\'') {
                sToken.setCurrentPos(currentPosition + 1);
            } else if (wrd.charAt(currentPosition - 1) == '"' && wrd.charAt(currentPosition) != '"') {
                wrd = wrd.substring(0, currentPosition) + "\"" + wrd.substring(currentPosition, wrd.length());
                sToken.setStr(wrd);
                sToken.setCurrentPos(currentPosition + 1);
            } else if (wrd.charAt(currentPosition - 1) == '"' && wrd.charAt(currentPosition) == '"') {
                sToken.setCurrentPos(currentPosition + 1);
            }
        }

        if (wrd.charAt(0) != '\'') {
            StringBuffer buf = new StringBuffer();
            buf.append("'").append(wrd).append("'");

            return buf.toString();
        } else return wrd;
    }

    private static String atomHost(ScStringTokenizer Token) {
        String sTemp = new String();
        while (Token.hasMoreTokens()) {
            sTemp = Token.nextToken();
            if (sTemp.trim().length() < 1) continue;
            return sTemp;
        }
        return "end!";
    }
}
