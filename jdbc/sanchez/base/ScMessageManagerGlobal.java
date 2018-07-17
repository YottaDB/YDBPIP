/**
 * @version 1.0, 6/21/99.
 * @author Pranav G. Amin
 * @see        sanchez.base.ScMessage.
 * @see        sanchez.base.ScMessageManager.
 * @modification: 08/03/1999 Quansheng Jia
 * load message from flat file instead of DB
 * weblink
 * <p>
 * Implementation of singleton pattern. There will be one ScMessageManagerGloabal
 * object per Java Virtual Machine. User can get an instance by calling the static method
 * getInstance(). To Load all messages do ScMessageManagerGlobal.getInstance() or just do
 * Class.forName("sanchez.message.ScMessageManagerGlobal"). Upon the class loading
 * the database will be read and ScMessageObjects will be created. Reference to all
 * ScMessages will be held in a table. The ScMessageManage global maintains a refence this
 * table.  Returns ScMessage Object given the env_id, lang_id and message_id.
 * Synchronization of any of this method is unnecessary because all only the read method is
 * public. Hashtable in internally synchronized think of using Hashset instead, that can potentially
 * speed up the operations.
 */
package sanchez.base;

import java.util.Hashtable;

import sanchez.jdbc.dbaccess.ScDBError;
import sanchez.utils.ScISKeys;

public class ScMessageManagerGlobal extends ScObjectGlobal {
    private Hashtable c_oMessageStore;
    private static final ScMessageManagerGlobal i_oInstance = new ScMessageManagerGlobal();

    /**
     * Use this static method to obtain a instance of ScMessageManagerGloabal instance.
     * This mechanism ensures that there is always only one instance available at all times.
     * @return ScMessageManagerGloabal
     */
    public static ScMessageManagerGlobal getInstance() {
        return i_oInstance;
    }

    /**
     * Class constructor
     */
    private ScMessageManagerGlobal() {
        c_oMessageStore = new Hashtable();
        try {
            this.initialize();
        } catch (Exception e) {
            // Cannot propogate this error as the static var is calling it,
            // Have to resolve it here.
        }
    }

    /**
     * Try finding the message for the given env_id, lang_id & message_id
     * If message is not found, try default_env_id, default_lang_id & message_id
     * if message not found try sanchez_env_id, default_lang_id & message_id
     * If not found throw  Exception
     * If found return back ScMessage object.

     * @param a_iEnvironment_id Enviornment Id for this message Object
     * @param a_iMessageId Message Id for this message Object
     * @param a_iLanguage_id Language Id for this message Object
     * @return ScMessage
     * @exception throws java.lang.Exception
     */
    public ScMessage getMessage(int a_iEnvironment_id, int a_iLanguage_id, int a_iMessage_id) throws Exception {
        String key = ScMessage.generateKey(a_iEnvironment_id, a_iLanguage_id, a_iMessage_id);
        Object obj = c_oMessageStore.get(key);
        if (obj == null) // Message does not exist for the set enviroment
        {
            a_iEnvironment_id = getDefaultEnvironment();
            a_iLanguage_id = getDefaultLanguage();
            key = ScMessage.generateKey(a_iEnvironment_id, a_iLanguage_id, a_iMessage_id);
            obj = c_oMessageStore.get(key);
            if (obj == null) // Message does not exist for the default enviroment & default language
            {
                a_iEnvironment_id = getSanchezEnvironment();
                key = ScMessage.generateKey(a_iEnvironment_id, a_iLanguage_id, a_iMessage_id);
                obj = c_oMessageStore.get(key);
                if (obj == null) // Message does not exist for sanchez enviroment & default language
                {
                    throw new Exception(ScBundle.getMessage(ScResourceKeys.Invalid_message_id));
                }
            }
        }

        if (obj == null) // Message does not exist for sanchez enviroment & default language
        {
            throw new Exception(ScBundle.getMessage(ScResourceKeys.Invalid_message_id));
        } else {
            ScMessage tempMessage;
            try {
                tempMessage = (ScMessage) obj;
            } catch (ClassCastException e) {
                throw new Exception(ScBundle.getMessage(ScResourceKeys.Invalid_message_id));
            }
            return tempMessage;
        }
    }

    /**
     * To get default environment value from the ini files
     * @return int
     */
    private int getDefaultEnvironment() {
        // logic to get value from the ini files
        return 0;
    }

    /**
     * To get default language value from the ini files
     * @return int
     */
    private int getDefaultLanguage() {
        // logic to get value from the ini files
        return 0;
    }

    /**
     * To get sanchez environment value from the ini files
     * @return int
     */
    private int getSanchezEnvironment() {
        // logic to get value from the ini files
        return 0;
    }

    /**
     * Initialization
     * @throws java.lang.Exception
     */
    private void initialize() throws Exception {
        String sRow, a_sTemp;
        int iCurrentColumn = 0, offset = 0, oldoffset = 0, where;
        String[] sArray = new String[7];
        Integer iInt;
        int I_ENVIRONMENT_ID, I_MESSAGE_ID, I_LANGUAGE_ID, I_ACTION_CODE;
        int iRow = 0;
        ScDBError error = new ScDBError();
        for (iRow = 0; iRow < error.errorRecord; iRow++) {
            if (iRow == 0) continue;
            sRow = error.errorMessage[iRow];

            for (iCurrentColumn = 0, offset = 0, oldoffset = 0; ((where = sRow.indexOf("|", offset)) >= 0); offset = where + 1) {
                if (where >= 0) {
                    a_sTemp = sRow.substring(oldoffset, where);
                    if (a_sTemp == null) a_sTemp = "";
                    sArray[iCurrentColumn++] = a_sTemp;
                    oldoffset = where + 1;
                }
            }
            a_sTemp = sRow.substring(oldoffset, sRow.length());
            if (a_sTemp == null) a_sTemp = "";
            sArray[iCurrentColumn] = a_sTemp;

            if (sArray[0].length() < 1) sArray[0] = "0";
            iInt = Integer.valueOf(sArray[0]);
            I_ENVIRONMENT_ID = iInt.intValue();

            if (sArray[1].length() < 1) sArray[1] = "0";
            iInt = Integer.valueOf(sArray[1]);
            I_MESSAGE_ID = iInt.intValue();

            if (sArray[4].length() < 1) sArray[4] = "0";
            iInt = Integer.valueOf(sArray[4]);
            I_LANGUAGE_ID = iInt.intValue();

            if (sArray[5].length() < 1) sArray[5] = "0";
            iInt = Integer.valueOf(sArray[5]);
            I_ACTION_CODE = iInt.intValue();

            ScMessage temp = new ScMessage(I_ENVIRONMENT_ID,
                    I_MESSAGE_ID,
                    sArray[2],
                    sArray[3],
                    I_LANGUAGE_ID,
                    I_ACTION_CODE,
                    sArray[6]
            );

            c_oMessageStore.put(temp.createKey(), temp);
        }
    }

    /**
     * To parse the file.
     * @return Sring
     */
    private static final String getFileToParse() {
        return ScISKeys.sINI_MESSAGE;
    }

}