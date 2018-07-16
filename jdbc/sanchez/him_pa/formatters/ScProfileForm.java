package sanchez.him_pa.formatters;

import sanchez.him_pa.ScProfToken;
import sanchez.him_pa.ScProfileException;
import sanchez.him_pa.utils.ScInt;
import sanchez.him_pa.utils.ScMSQLFormat;
import sanchez.him_pa.utils.ScMrpcUtility;
import sanchez.him_pa.utils.ScRawString;
import sanchez.him_pa.utils.ScUtils;
import java.util.Hashtable;
import java.util.Enumeration;
import java.util.Vector;
import sanchez.jdbc.dbaccess.ScMrpcStatement;
import sanchez.jdbc.dbaccess.ScDBStatement;


/**
 * The ScProfileForm is used to warp and unwrap PA server class
 *
 * @version     1.0  2 March 1 1999
 * @author      Quansheng Jia
 *
 * Methods:
 * MNSP:
 * public String wrapLoginRequest (String psUserName,
 *                                 String psPassWord,
 *                                 String psStationId,
 *                                 String psMessId,
 *                                 String psStoreForward,
 *                                 String psInstId,
 *                                 String psFapId,
 *                                 String psContext)
 *
 * public ScProfToken unwarpLoginResponse(String sMessToParse)
 * public String wrapLogoutRequest (ScProfToken a_oToken)
 *
 * MSQL:
 * public String wrapSqlRequest (String psSqlMess,
 *                               String psQualifier,
 *                               String psStoreForward,
 *                               ScProfToken oToken)
 * public String[] unwrapSqlResponse(String sMessToParse)
 *
 * MRPC:
 * public String wrapMrpcRequest (String psMrpcId,
 *                                String pasMrpcArgs[],
 *                                String psStoreForward,
 *                                ScProfToken oToken)
 * public String[] unwrapMrpcResponse(String sMessToParse)
 *
 * Example1:
 *      ScProfileForm mytest = new ScProfileForm();
 *      StringBuffer sbResult;
 *      try {
 *           sbResult = mycomm.exchangeMessage(new StringBuffer(mytest.wrapSqlRequest ("describe mli","ROWS=5","0",mytoken)));
 *      }
 *      catch (Exception except) {except.getMessage();
 *      String sxxx[] = mytest.unwrapSqlResponse(sbResult.toString());
 *
 *
 */

public class ScProfileForm extends ScFormatter
{
	//=============================PRIVATE VARIABLES=============================================
	private static final int OK         =  0;
	private static final int PROFILE_LOGIN =  0;
	private static final int SQL_MESS   =  5;
	private static final int HTML_MESS  =  6;
	private static final int MRPC_MESS  =  3;
	private static final int MIN_VALID_SIZE = 8;
	private static final int MAX_VALID_SIZE = 5500;
	
	private String fEncoding = "";
	
	protected static final String SIGNOFF = "0";
	protected static final String SEND_SQL_MESS      = new String("5");
	protected static final String SEND_HTML_MESS     = new String("6");
	protected static final String SEND_LOGIN_REQUEST = new String("0");
	protected static final String SEND_MRPC_MESS     = new String("3");
	protected static final String SIGNON  = "1";
	
	protected  ScUtils ScUtils_obj = new ScUtils();

	protected String chopLV (byte source_buffer[], int  buffer_offset) 
	{
		int i, j;
		ScInt ci = new ScInt();
		byte dest_buffer[] = new byte[source_buffer.length - buffer_offset];

		i = ScUtils_obj.unpack_number (source_buffer,buffer_offset,ci);
		for (j = 0; j < ci.val;  j++){
			  dest_buffer[j] = source_buffer[j + i + buffer_offset];
		}
		return ScUtils.byteToString(dest_buffer, ci.val);

	}//METHOD chopLV ENDS

	public void set_encoding(String encoding)
	{
		if (encoding == null)
			fEncoding = "ISO8859_1";
		else
			fEncoding = encoding;
	}
	
	private int complex_pack_string(String[] source,byte[] desc)
	{
		int size=source.length;
		int k = 0, j=0;
		for (j=0;j<size;j++)
		{
		  k +=  ScUtils_obj.pack_string (source[j],desc,k);
		}
		return k;
	}

	public int errorCheck (int what_to_do, String psMessageToCheck) 
		throws ScProfileException, ArrayIndexOutOfBoundsException 
	{
		String sLocation;
	
		ScUtils ScUtils_obj = new ScUtils();
		int  string_size    = psMessageToCheck.length();
		byte temp_buffer[]  = new byte[string_size+120];
		int i, j;
		ScInt ci = new ScInt();
		int header_and_message[] = new int[3];
		int header  [] = new int[10];
		int message [] = new int[12];
		int message2[] = new int[12];
		String sErrorCheckMess;
		StringBuffer bf = new StringBuffer();
	
		sLocation="UNKNOWN";
		switch (what_to_do) {
			case PROFILE_LOGIN :
				{
					sErrorCheckMess = new String("Server error encountered in Profile_SQL: ");
					sLocation = "PROFILE_LOGIN";
					break;
				}
			case HTML_MESS :
				{
					sErrorCheckMess = new String("Server error encountered in Profile_HTML: ");
					sLocation = "HTML_MESS";
					break;
				}
			case MRPC_MESS :
				{
					sErrorCheckMess = new String("Server error encountered in Profile_MRPC: ");
					sLocation = "MRPC_MESS";
					break;
				}
			default :
				{
					sErrorCheckMess = new String("Server error encountered in Profile_Connect: ");
					break;
				}
		} //SWITCH ENDS
	
	//============delete==========
		byte message_buffer[] = new byte[string_size + 150];
	
		if (string_size < MIN_VALID_SIZE) {
			message_buffer = ScUtils.stringToByte(psMessageToCheck);
			ci.val = psMessageToCheck.length();
			message_buffer[ci.val] = 0;
			throw new ScProfileException(ScUtils.byteToString(message_buffer,ci.val));
		}
		String sTemp = psMessageToCheck.substring(0,psMessageToCheck.length()-2);
		ScUtils_obj.pack_string (sTemp, temp_buffer, 0);//ADD NOW BY DG
	
		ScUtils_obj.parse_string(temp_buffer, 0, header_and_message, ScUtils.EXTRACT);
	
		ScUtils_obj.parse_string(temp_buffer, header_and_message[1], header, ScUtils.EXTRACT);
		if (temp_buffer[header[3] + 1] == 48)
			return OK;
	
		ScUtils_obj.parse_string(temp_buffer, header_and_message[2], message2, ScUtils.EXTRACT);
		ScUtils_obj.parse_string(temp_buffer, message2[2], message, ScUtils.EXTRACT);
	
		String[] sPiece =  new String[message[0]+1];
	
		//OVR support
	    sPiece[1] = chopLV (temp_buffer,message[1]);
	    if ((what_to_do == SQL_MESS||what_to_do == MRPC_MESS)&& sPiece[1].equals("AU"))
	    {
	    	int count[] = new int[2];

	    	ScUtils_obj.parse_string(temp_buffer, message[3], count, ScUtils.COUNT_STRINGS);

	    	int au_text[] = new int[count[0]];
		    ScUtils_obj.parse_string(temp_buffer, message[3], au_text, ScUtils.EXTRACT);
	
		    String[] sErrorMesasge = new String[au_text[0]];
	
		    for (int iii = 0; iii<(au_text[0]-1); iii++)
		    {
		    	sErrorMesasge[iii] = chopLV (temp_buffer,au_text[iii+1]);
		    	if (sErrorMesasge[iii].length()>0)
		    	{
		    		try
		    		{
		    			Vector v = chopLV(sErrorMesasge[iii],5);
	
				        for (int jj=0;jj<v.size();jj++)
				        {
				            String[] ss = (String[])v.get(jj);
			
				            if (what_to_do == SQL_MESS||ss[0].startsWith("XBAD"))
				            {
				                //e.g: "XBAD|error des|access keys"
				            	if (jj==0) bf = bf.append(ss[0]).append('|').append(ss[2]).append('|').append(ss[3]).append('|').append(ss[0]).append('|').append(ss[1]).append('|').append(ss[2]).append('|').append(ss[3]).append('|').append(ss[4]).append('|').append(iii);
					            else bf = bf.append('\n').append(ss[0]).append('|').append(ss[2]).append('|').append(ss[3]).append('|').append(ss[0]).append('|').append(ss[1]).append('|').append(ss[2]).append('|').append(ss[3]).append('|').append(ss[4]).append('|').append(iii);
				            }
				            else if (what_to_do == SQL_MESS||ss[0].startsWith("OVR"))
				            {
				                //e.g: OVR_DDA_BAL|400800020017|Transaction exceeds ledger balance of $-25
					            if (jj==0) bf = bf.append(ss[0]).append('|').append(ss[3]).append('|').append(ss[2]).append('|').append(ss[0]).append('|').append(ss[1]).append('|').append(ss[2]).append('|').append(ss[3]).append('|').append(ss[4]).append('|').append(iii);
					            else bf = bf.append('\n').append(ss[0]).append('|').append(ss[3]).append('|').append(ss[2]).append('|').append(ss[0]).append('|').append(ss[1]).append('|').append(ss[2]).append('|').append(ss[3]).append('|').append(ss[4]).append('|').append(iii);
				            }
				            else
				            {
				                //e.g: "RFLG|access keys|error des"
					            if (jj==0) bf = bf.append(ss[0]).append('|').append(ss[3]).append('|').append(ss[2]).append('|').append(ss[0]).append('|').append(ss[1]).append('|').append(ss[2]).append('|').append(ss[3]).append('|').append(ss[4]).append('|').append(iii);
					            else bf = bf.append('\n').append(ss[0]).append('|').append(ss[3]).append('|').append(ss[2]).append('|').append(ss[0]).append('|').append(ss[1]).append('|').append(ss[2]).append('|').append(ss[3]).append('|').append(ss[4]).append('|').append(iii);
				            }
				        }
					    bf = bf.append('\n');
				    }
				    catch(Exception ex){
					    throw new ScProfileException(sErrorMesasge[iii]+"\n"+ex);
				    }
		    	}
		    }
		    String error = bf.toString();
		    
		    try {
				if (fEncoding == null) 
					error = new String(ScUtils.stringToByte(error),"8859_1");
				else if (fEncoding.equalsIgnoreCase("UTF16")||fEncoding.equalsIgnoreCase("UTF-16"))
				{
					error = new String(ScUtils.stringToByte(error),"UTF8");
					byte[] barray = error.getBytes("UTF16");
					error = new String(barray, "UTF16");
				}
				else error = new String(ScUtils.stringToByte(error),fEncoding);
			}
			catch(Exception e){}
		    
		    if (bf.toString().startsWith("XBAD"))
		        throw new ScProfileException("XBAD_1000|"+error);
		    else if (bf.toString().startsWith("OVR"))
		        throw new ScProfileException("OVR_1000|"+error);
		    else
		        throw new ScProfileException("RFLG_1000|"+error);
		}
	
	    for (int k=3; k<message[0];k++){
		    sPiece[k] = chopLV (temp_buffer,message[k]);
		    if (k==3) {
		        sPiece[k] = complxError(sPiece[k]);
		    }
		}
		String error = sPiece[3];
		if (message[5]>0) error = sPiece[3]+"|"+sPiece[5];
		
		try
		{
			if (fEncoding == null) 
				error = new String(ScUtils.stringToByte(error),"8859_1");
			else if (fEncoding.equalsIgnoreCase("UTF16")||fEncoding.equalsIgnoreCase("UTF-16"))
			{
				error = new String(ScUtils.stringToByte(error),"UTF8");
				byte[] barray = error.getBytes("UTF16");
				error = new String(barray, "UTF16");
			}
			else error = new String(ScUtils.stringToByte(error),fEncoding);
		}
		catch(Exception e){}
		
		throw new ScProfileException(error);
	}//METHOD errorCheck ENDS
	
	
	public int getFormResponseSize()
	{
		return 0;
	}
	public int getSendmessSize()
	{
		return 0;
	}
	
	public int getUnformResponseSize()
	{
		return 0;
	}
	//---------------
	public String[] parseMessRespHeadBody() {return null;}
	//---------------
	public String[] parseMessResponseHeader(String psbRespHead) {return null;}
	
	private void setup_column (byte    source_buffer[],
							   int     buffer_offset,
							   byte    dest_buffer[],
							   ScInt   ci)
	{
		int i, j;
	
		i = ScUtils_obj.unpack_number (source_buffer,buffer_offset,ci);
		for (j = 0; j < ci.val;  j++)
			dest_buffer[j] = source_buffer[j + i + buffer_offset];
	}
	
	private int setup_message_header  (byte   dest_buffer[],
									   String psToken,
									   String psWhatToDo,
									   String psStoreForward,
									   String psMessId,
									   ScProfToken oToken)
	{
		int i=0;
		int offset1=0, offset2=0;
		String what_to_do = psWhatToDo;
	
		byte temp_buffer[] = new byte[150];
	
		if (what_to_do.compareTo (SEND_SQL_MESS) == 0 )
			i +=  ScUtils_obj.pack_string (SEND_SQL_MESS,temp_buffer,0);
		else if (what_to_do.compareTo (SEND_LOGIN_REQUEST) == 0)
			i  += ScUtils_obj.pack_string (SEND_LOGIN_REQUEST,temp_buffer,0);
		else if (what_to_do.compareTo (SEND_HTML_MESS) == 0)
			i += ScUtils_obj.pack_string (SEND_HTML_MESS,temp_buffer,0);
		else if (what_to_do.compareTo (SEND_MRPC_MESS) == 0)
			i += ScUtils_obj.pack_string (SEND_MRPC_MESS,temp_buffer,0);
		else i += ScUtils_obj.pack_string (what_to_do,temp_buffer,0);
		
		//client token
		i  += ScUtils_obj.pack_string (psToken,temp_buffer,i);//(TOKEN,  temp_buffer,i);
		
		//message id
		i += ScUtils_obj.pack_string (psMessId,temp_buffer,i);
		
		//store & forward flag
		i += ScUtils_obj.pack_string (psStoreForward, temp_buffer, i);//("0", temp_buffer, i);
		
		//group records
		i += ScUtils_obj.pack_string ("", temp_buffer, i);
		
		//p/a client version
		i += ScUtils_obj.pack_string ("", temp_buffer, i);
		
		//p/a user identification
		if (oToken!=null){
			String userId = oToken.getUserId();
			if (userId.equals(null)) userId="";
			i += ScUtils_obj.pack_string (userId, temp_buffer, i);
	
			//server channel id
			String channelId = oToken.getServerChannelId();
		    if (channelId.equals(null)) channelId="";
			i += ScUtils_obj.pack_string (channelId, temp_buffer, i);
		}
		offset2 = ScUtils_obj.pack_string(temp_buffer,i,dest_buffer,(offset1));
    	return (offset1 + offset2);
	}//METHOD setup_message_header ENDS

	public String setup_mrpc_message (String psMrpcId,
		                              String psMrpcVersion,
		                              String pasMrpcArgs[],
		                              String psSpvAuth)
	{
		int iOffset=0;
		int ii=0, jj=0;
		int spv_len=0;
	
	    for (ii=0; ii<pasMrpcArgs.length; ii++)
			   jj += pasMrpcArgs[ii].length();
	    
	    if (psSpvAuth != null)
	    	spv_len = psSpvAuth.length();
	    
		byte abTempBuff1[] = new byte[jj+(ii*6)+200+spv_len];
		byte abTempBuff2[] = new byte[jj+(ii*6)+200+spv_len];
	
		//PACK THE MRPC ID
		iOffset  = ScUtils_obj.pack_string (psMrpcId,abTempBuff1,0);
		//PACK THE MRPC VERSION, USUALLY 1, BUT NOT GUARANTEED
		iOffset += ScUtils_obj.pack_string (psMrpcVersion,abTempBuff1,iOffset);
	
		//PACK THE INDIVIDUAL MRPC ARGUMENTS
		jj=0;
		for (ii=0;ii<pasMrpcArgs.length; ii++){
			jj += ScUtils_obj.pack_string (pasMrpcArgs[ii],abTempBuff2,jj);
		}
	
		//PACK ALL THE ARGUMENTS TOGETHER
		iOffset += ScUtils_obj.pack_string (abTempBuff2,jj,abTempBuff1,iOffset);
	
		//PACK THE MRPC AUTHORIZATION, USUALLY 1 , NULL OR *
	  	if (psSpvAuth != null)
		{
			String[] tempspv_info = new String[50];
			String[] tempspv_info1 = new String[20];
			
			int spv_index=0,spv_count=0,auth_count=0,count=0,i=0,j,k,char_count=0;
			do
			{
				spv_count = psSpvAuth.indexOf("##");
				if (spv_count < 0)
					tempspv_info[auth_count] = psSpvAuth.substring(0);
				else
				{
					tempspv_info[auth_count] = psSpvAuth.substring(0,spv_count);
					psSpvAuth = psSpvAuth.substring(spv_count+2);
				}
				char_count += tempspv_info[auth_count].toString().length();
				auth_count++;
			}while (spv_count > 0);
			
			byte spv_buffer[] = new byte[char_count+1];
			byte temp_spv[] = new byte[char_count+50];

			spv_count = 0;
			for (j = 0; j < auth_count;j++)
			{
				spv_index = 0;
				count = 0;
				do
				{
					spv_index = tempspv_info[j].indexOf('|');
					if (spv_index < 0)
						tempspv_info1[count] = tempspv_info[j].substring(0);
					else
					{
						tempspv_info1[count] = tempspv_info[j].substring(0,spv_index);
						tempspv_info[j] = tempspv_info[j].substring(spv_index+1);
					}
					count++;
				}while (spv_index > 0);
			    
				String[] spv_info = new String[count];
				
				for (i = 0; i < count ;i++)
					spv_info[i] = tempspv_info1[i];

				k = complex_pack_string(spv_info,spv_buffer);

			    for (int mm=1; mm<(k+1); mm++)
			        temp_spv[spv_count+mm]=spv_buffer[mm-1];
			    temp_spv[spv_count]=(byte)(k+1);
			    
			    spv_count += (k + 1);
			}
			
			byte temp_spv1[] = new byte[spv_count];
			for (i = 0; i < spv_count ;i++)
				temp_spv1[i] = temp_spv[i];
			
	        iOffset +=  ScUtils_obj.pack_string (temp_spv1,spv_count,abTempBuff1,iOffset);
	    }
	
		//PACK EVERYTHING INTO DESTINATION ARRAY
		byte abDestBuffer [] = new byte[iOffset+10];
		jj = ScUtils_obj.pack_string (abTempBuff1,iOffset,abDestBuffer,0);
		return ScUtils.byteToString(abDestBuffer,jj);
	}
	
	private  int setup_signon(byte dest_buffer[],
							 int  offset,
							 String psUserId,
							 String psPassWord,
							 String psStationId,
							 String psInstId,
							 String psFapId,
							 Hashtable psContext,
							 String psNewPassword,
							 String srverProcedure) 
	{
		String user_id    = psUserId;
		String password   = psPassWord;
		String station_id = psStationId;
		String INST_ID    = psInstId;
		String FAP_IDS    = psFapId;
		String NEW_PASS   = psNewPassword;
		int i=0, j=0, k=0;
	
		byte temp_buffer[] = new byte[600];
		byte  context_buffer[] = new byte[20];
	
		i += ScUtils_obj.pack_string (srverProcedure,temp_buffer,0);
		i += ScUtils_obj.pack_string (user_id,temp_buffer,i);
		i += ScUtils_obj.pack_string (station_id,temp_buffer,i);
		i += ScUtils_obj.pack_string (password,temp_buffer,i);
	    i += ScUtils_obj.pack_string (INST_ID,temp_buffer,i);
		i += ScUtils_obj.pack_string (FAP_IDS,temp_buffer,i);

		k  =  ScUtils_obj.pack_string ("5", context_buffer,0);
		if(psContext.size() > 0)
	    {
		    String o;
		    Enumeration enum = psContext.keys();
		    while(enum.hasMoreElements())
		    {
			    o = (String)enum.nextElement();
			    k +=  ScUtils_obj.pack_string (o,context_buffer,k);
			    k +=  ScUtils_obj.pack_string ((String)psContext.get(o),context_buffer,k);
			}
		}

		byte temp[] = new byte[k+5];
        k = ScUtils_obj.pack_string(context_buffer,k,temp,0);
	    i +=  ScUtils_obj.pack_string (temp,k,temp_buffer,i);

		i += ScUtils_obj.pack_string (NEW_PASS,temp_buffer,i);
		j += ScUtils_obj.pack_string(temp_buffer,i,dest_buffer,offset);

        temp_buffer = null;
		return j;
	} //END OF SETUP_SIGNON
	
	//=============================PRIVATE METHODS/DATA============================================
	//--------------------------------------------------------------------------------------------------------------------------
	
	private int setup_sql_message (byte    dest_buffer[],
			                       int     dest_offset,
					               String  psSqlMessage,
					               String  psSqlQualifiers) 
	{
		String sql_message    = psSqlMessage;
		String sql_qualifiers = psSqlQualifiers;

		int offset;
		byte temp_buffer[] = new byte [sql_message.length()+sql_qualifiers.length()+24];

		offset   = ScUtils_obj.pack_string (sql_message,temp_buffer,0);
		offset += ScUtils_obj.pack_string (sql_qualifiers,temp_buffer,offset);
		offset += ScUtils_obj.pack_string ("", temp_buffer,offset);
		offset = ScUtils_obj.pack_string (temp_buffer,offset,dest_buffer,dest_offset);

		return offset;
	} //END OF SETUP_SQL_MESSAGE

	//=============================PRIVATE METHODS===============================================
	private String setupLogoff(ScProfToken a_oToken) 
	{
		byte temp_buffer2[] = new byte [100];
		int  offset2=0;

		offset2=0;
		offset2 += ScUtils_obj.pack_string (SIGNOFF,temp_buffer2,0);
	    offset2 += ScUtils_obj.pack_string (a_oToken.getToken(),temp_buffer2,offset2);
        byte dest_buffer[] = new byte[100];
        offset2 = ScUtils_obj.pack_string(temp_buffer2,offset2,dest_buffer,0);
        return new String(dest_buffer, 0, offset2);
	}//METHOD setupLogoff ends
	
	public ScProfToken unwrapLoginResponse(String sMessToParse) throws ScProfileException 
	{
		errorCheck (PROFILE_LOGIN, sMessToParse);
	
		int ii=0;
	
		byte reply_message2[] = new byte[sMessToParse.length()+10];//[getFormattedResponse().toString().length()+10];
	
		byte temp[] = ScUtils.stringToByte(sMessToParse);
	
		int  header_and_message[]  = new int[3];
		int  header_strings[]      = new int[8];
		int  message_strings1[]    = new int[50];
		int  message_strings2[]    = new int[50];
	
	    String sTemp= ScUtils.byteToString(temp,temp.length-2);
		ii += ScUtils_obj.pack_string(sTemp,reply_message2,0);
	
		ScUtils_obj.parse_string(reply_message2,0,header_and_message, ScUtils.EXTRACT);
	
		ScUtils_obj.parse_string(reply_message2,header_and_message[1],header_strings,ScUtils.EXTRACT);
	
	//GET THE MESSAGE ID TO USE WITH THE GET TOKEN;
		String sMessageId = chopLV(reply_message2,header_strings[2]);
	
		ScUtils_obj.parse_string(reply_message2,header_and_message[2],message_strings1,ScUtils.EXTRACT);
	
		ScUtils_obj.parse_string(reply_message2,message_strings1[2],message_strings2,ScUtils.EXTRACT);
	
		String sTempx = chopLV(reply_message2,message_strings2[1]);
	
		return new ScProfToken(sTempx, sMessageId);
	}//METHOD unwrapLoginResponse ENDS
	
	public String unwrapMrpcResponse(String sMessToParse) throws ScProfileException   
	{
	        errorCheck(3, sMessToParse);
	        int ii = 0;
	        int header_and_message[] = new int[5];
	        int header_strings[] = new int[17];
	        int message_strings1[] = new int[25];
	        int message_strings2[] = new int[25];
	        byte reply_message2[] = new byte[sMessToParse.length() + 10];
	        ii += ScUtils_obj.pack_string(sMessToParse.substring(0, sMessToParse.length() - 2), reply_message2, 0);
	        ScUtils_obj.parse_string(reply_message2, 0, header_and_message, 2);
	        ScUtils_obj.parse_string(reply_message2, header_and_message[1], header_strings, 2);
	        ScUtils_obj.parse_string(reply_message2, header_and_message[2], message_strings1, 2);
	        ScUtils_obj.parse_string(reply_message2, message_strings1[2], message_strings2, 2);
	        String sTemp = "";
	        String sPiece = "";
	        for(int k = 1; k < message_strings2[0]; k++)
	        {
	            sPiece = chopLV(reply_message2, message_strings2[k]);
	            if(message_strings2[0] > 2)
	            {
	                sPiece = sPiece.replace('\t', '\b');
	                sPiece = sPiece.replace('\r', '\f');
	                sPiece = sPiece.replace('\n', '|');
	            }
	            if(k == 1)
	                sTemp = sPiece;
	            else
	                sTemp = sTemp + "\t" + sPiece;
	        }
	
	        return sTemp;
	}
	
	public String unwrapMrpcResponse(String sMessToParse, String size, String mrpcId) throws ScProfileException 
	{
		errorCheck (MRPC_MESS, sMessToParse);
		int ii=0;
	
		int  header_and_message[]    = new int[5];
		int  header_strings[]        = new int[17];
		int  message_strings1[]      = new int[25];
		int  message_strings2[]      = new int[25];
	
		byte reply_message2 [] = new byte[sMessToParse.length()+10];
	
		ii += ScUtils_obj.pack_string(sMessToParse.substring(0,sMessToParse.length()-2),reply_message2,0);
	
		ScUtils_obj.parse_string(reply_message2,0,header_and_message, ScUtils.EXTRACT);
	
		ScUtils_obj.parse_string(reply_message2,header_and_message[1],header_strings,ScUtils.EXTRACT);
	
		ScUtils_obj.parse_string(reply_message2,header_and_message[2],message_strings1,ScUtils.EXTRACT);
	
	    String sTemp = "";
	    try
	    {
		    ScUtils_obj.parse_string(reply_message2,message_strings1[2],message_strings2,ScUtils.EXTRACT);
		    //for LLV, single column , e.g XML message
		    if ((size.equals("1")&&(message_strings2[0]>2)))
			{
			    sTemp = chopLV (reply_message2,message_strings1[2]);
				sTemp = sTemp.replace('\r', (char)200);
				sTemp = sTemp.replace('\n', (char)201);
				return sTemp;
			}
		
			//For LLV, mutiply columns with 't' as delimiter, '/r/n' as row delimeter
			int colCount = Integer.parseInt(size);
			if ((colCount>1)&&(message_strings2[0]<3))
			{
				sTemp = chopLV (reply_message2,message_strings2[1]);
			    return sTemp;
			}
		
			String sPiece ="";
		
		    //For LLVLVLV, mutiply columns with LV as delimeter
		    for (int k=1; k<message_strings2[0];k++){
			    sPiece = chopLV (reply_message2,message_strings2[k]);
			    if (size.equals("1") == false)
			    {
			    	sPiece = sPiece.replace('\t',(char)199);
			    }
		    	sPiece = sPiece.replace('\r', (char)200);
		    	sPiece = sPiece.replace('\n', (char)201);
		
			    if (k==1) sTemp = sPiece;
			    else sTemp +="\t"+ sPiece;
		    }
	    }
	    catch(Exception ex){
	        //for LV, MRPC return unwarp string
	        sTemp = chopLV (reply_message2,message_strings1[2]);
		    if (size.equals("1") == false)
		    {
		        sTemp = sTemp.replace('\t',(char)199);
		    }
			sTemp = sTemp.replace('\r', (char)200);
			sTemp = sTemp.replace('\n', (char)201);
	    }
	    return sTemp;
	
	}//METHOD unwrapMrpcResponse ENDS
	
	public String unwrapMrpcResponse(String sMessToParse, String size) throws ScProfileException {
	
		errorCheck (MRPC_MESS, sMessToParse);
		int ii=0;
	
		int  header_and_message[]    = new int[5];
		int  header_strings[]        = new int[17];
		int  message_strings1[]      = new int[25];
		int  message_strings2[]      = new int[25];
	
		byte reply_message2 [] = new byte[sMessToParse.length()+10];
	
		ii += ScUtils_obj.pack_string(sMessToParse.substring(0,sMessToParse.length()-2),reply_message2,0);
	
		ScUtils_obj.parse_string(reply_message2,0,header_and_message, ScUtils.EXTRACT);
	
		ScUtils_obj.parse_string(reply_message2,header_and_message[1],header_strings,ScUtils.EXTRACT);
	
		ScUtils_obj.parse_string(reply_message2,header_and_message[2],message_strings1,ScUtils.EXTRACT);
	
		ScUtils_obj.parse_string(reply_message2,message_strings1[2],message_strings2,ScUtils.EXTRACT);
	
		String sTemp = "";
	
		if ((size.equals("1")&&(message_strings2[0]>2)))
		{
		    sTemp = chopLV (reply_message2,message_strings1[2]);
			sTemp = sTemp.replace('\r', (char)200);
			sTemp = sTemp.replace('\n', (char)201);
			return sTemp.trim();
		}
	
		try{
		    int colCount = Integer.parseInt(size);
		    if ((colCount>1)&&(message_strings2[0]<3))
		    {
		        sTemp = chopLV (reply_message2,message_strings1[2]);
	    	    return sTemp;
		    }
		}
		catch(Exception e){}
	
		String sPiece ="";
	    try{
	    for (int k=1; k<message_strings2[0];k++){
		    sPiece = chopLV (reply_message2,message_strings2[k]);
	
		    if (size.equals("1") == false)
		    {
			    sPiece = sPiece.replace('\t',(char)199);
		    }
			sPiece = sPiece.replace('\r', (char)200);
			sPiece = sPiece.replace('\n', (char)201);

			if (k==1) sTemp = sPiece;
		    else sTemp +="\t"+ sPiece;
	    }
	    }
	    catch(Exception ex){
	        sTemp = chopLV (reply_message2,message_strings1[2]);
		    if (size.equals("1") == false)
		    {
		        sTemp = sTemp.replace('\t',(char)199);
		    }
			sTemp = sTemp.replace('\r', (char)200);
			sTemp = sTemp.replace('\n', (char)201);
	    }
	
		return sTemp;
	
	}//METHOD unwrapMrpcResponse ENDS

	public String[] unwrapSqlResponse(String sMessToParse) throws ScProfileException {
	
		  errorCheck (SQL_MESS, sMessToParse);
	
		  int ii=0;
	
		  int  header_and_message[]    = new int[5];
		  int  header_strings[]        = new int[15];
		  int  message_strings1[]      = new int[24];
		  int  message_strings2[]      = new int[24];
	
		  byte reply_message2 [] = new byte[sMessToParse.length()+1000];
	
		  ii += ScUtils_obj.pack_string(sMessToParse.substring(0,sMessToParse.length()-2),reply_message2,0);
	   	  ScUtils_obj.parse_string(reply_message2,0,header_and_message, ScUtils.EXTRACT);
	
		  ScUtils_obj.parse_string(reply_message2,header_and_message[1],header_strings,ScUtils.EXTRACT);
	
		  ScUtils_obj.parse_string(reply_message2,header_and_message[2],message_strings1,ScUtils.EXTRACT);
	
		  ScUtils_obj.parse_string(reply_message2,message_strings1[2],message_strings2,ScUtils.EXTRACT);
	
		  String[] sTemp = new String[3];
		  sTemp[0] = chopLV (reply_message2,message_strings2[1]); //SQL State Code
		  sTemp[1] = chopLV (reply_message2,message_strings2[3]); //Number of rows returned
		  sTemp[2] = chopLV (reply_message2,message_strings2[4]); //results table
	
		  return sTemp;
	
	}//METHOD unwrapSQLResponse ENDS
	
	public String[] unwrapCursorResponse(String sMessToParse) throws ScProfileException {
		  errorCheck (SQL_MESS, sMessToParse);
	
		  int ii=0;
	
		  int  header_and_message[]    = new int[5];
		  int  header_strings[]        = new int[15];
		  int  message_strings1[]      = new int[24];
		  int  message_strings2[]      = new int[24];
	
		  byte reply_message2 [] = new byte[sMessToParse.length()+1000];
	
		  ii += ScUtils_obj.pack_string(sMessToParse.substring(0,sMessToParse.length()-2),reply_message2,0);
	   	  ScUtils_obj.parse_string(reply_message2,0,header_and_message, ScUtils.EXTRACT);
	
		  ScUtils_obj.parse_string(reply_message2,header_and_message[1],header_strings,ScUtils.EXTRACT);
	
		  ScUtils_obj.parse_string(reply_message2,header_and_message[2],message_strings1,ScUtils.EXTRACT);
	
		  ScUtils_obj.parse_string(reply_message2,message_strings1[2],message_strings2,ScUtils.EXTRACT);
	
		  String[] sTemp = new String[4];
		  sTemp[0] = chopLV (reply_message2,message_strings2[1]); //SQL State Code
		  sTemp[1] = chopLV (reply_message2,message_strings2[3]); //Number of rows returned
		  sTemp[2] = chopLV (reply_message2,message_strings2[4]); //results table
	
		  if (sTemp[2].length()>2){
		    int mm=0;
		    int jj=0;
		    int kk=0;
	        jj = ScUtils.unsigned((byte)(sTemp[2].charAt(0)));
	        kk = ScUtils.unsigned((byte)(sTemp[2].charAt(1)));
	        mm = ((jj*256)+kk);
		    if (mm<sTemp[2].length()){
		        sTemp[3]=sTemp[2].substring(2,mm+2);                    //meta data
		       	sTemp[2] = sTemp[2].substring(mm+2,sTemp[2].length());  //raw dada
		    }
		  }
	
		  return sTemp;
	}//METHOD unwrapCursorResponse ENDS

	public String[] unwrapCursorResponse(String sMessToParse, int meta) throws ScProfileException {
		  errorCheck (SQL_MESS, sMessToParse);
	
		  int ii=0;
	
		  int  header_and_message[]    = new int[5];
		  int  header_strings[]        = new int[15];
		  int  message_strings1[]      = new int[24];
		  int  message_strings2[]      = new int[24];
	
		  byte reply_message2 [] = new byte[sMessToParse.length()+1000];
	
		  ii += ScUtils_obj.pack_string(sMessToParse.substring(0,sMessToParse.length()-2),reply_message2,0);
	   	  ScUtils_obj.parse_string(reply_message2,0,header_and_message, ScUtils.EXTRACT);
	
		  ScUtils_obj.parse_string(reply_message2,header_and_message[1],header_strings,ScUtils.EXTRACT);
	
		  ScUtils_obj.parse_string(reply_message2,header_and_message[2],message_strings1,ScUtils.EXTRACT);
	
		  ScUtils_obj.parse_string(reply_message2,message_strings1[2],message_strings2,ScUtils.EXTRACT);
	
		  String[] sTemp = new String[4];
		  sTemp[0] = chopLV (reply_message2,message_strings2[1]); //SQL State Code
		  sTemp[1] = chopLV (reply_message2,message_strings2[3]); //Number of rows returned
		  sTemp[2] = chopLV (reply_message2,message_strings2[4]); //results table
	
		  if (sTemp[2].length()>2){
		    int mm=0;
		    int jj=0;
		    int kk=0;
	        jj = ScUtils.unsigned((byte)(sTemp[2].charAt(0)));
	        kk = ScUtils.unsigned((byte)(sTemp[2].charAt(1)));
	        mm = ((jj*256)+kk);
		    if ((mm<sTemp[2].length()) || (meta != 1)){
		        sTemp[3]=sTemp[2].substring(2,mm+2);                    //meta data
		       	sTemp[2] = sTemp[2].substring(mm+2,sTemp[2].length());  //raw dada
		    }
		  }
	
		  return sTemp;
	}//METHOD unwrapCursorResponse ENDS

	public String[] unwrapApiSqlResponse(String sMessToParse) throws ScProfileException {
		  errorCheck (SQL_MESS, sMessToParse);
	
		  int ii=0;
	
		  int  header_and_message[]    = new int[5];
		  int  header_strings[]        = new int[15];
		  int  message_strings1[]      = new int[24];
		  int  message_strings2[]      = new int[24];
	
		  byte reply_message2 [] = new byte[sMessToParse.length()+1000];
	
		  ii += ScUtils_obj.pack_string(sMessToParse.substring(0,sMessToParse.length()-2),reply_message2,0);
	   	  ScUtils_obj.parse_string(reply_message2,0,header_and_message, ScUtils.EXTRACT);
		  ScUtils_obj.parse_string(reply_message2,header_and_message[1],header_strings,ScUtils.EXTRACT);
		  ScUtils_obj.parse_string(reply_message2,header_and_message[2],message_strings1,ScUtils.EXTRACT);
		  ScUtils_obj.parse_string(reply_message2,message_strings1[2],message_strings2,ScUtils.EXTRACT);
	
		  String[] sTemp = new String[4];
		  sTemp[0] = chopLV (reply_message2,message_strings2[1]); //SQL State Code
		  sTemp[1] = chopLV (reply_message2,message_strings2[3]); //Number of rows returned
		  sTemp[2] = chopLV (reply_message2,message_strings2[4]); //results table
		  sTemp[3] = chopLV (reply_message2,message_strings2[6]); //scheme
	
		  return sTemp;
	
	}//METHOD unwrapSQLResponse ENDS

	public String wrapLoginRequest (String psUserName,
									 String psPassWord,
									 String psStationId,
									 Hashtable psContext) 
	{
			return  wrapLoginRequest (psUserName,
						 psPassWord,
						 psStationId,
						 "\1",
						 "0",
						 "",
						 "",
						 psContext);
	
	}//METHOD wrapLoginRequest ends
	
	/**
	*challenge/response client sign-on request
	*@param psUserName user name
	*@param psMessId message id, default to 1
	*@param psStoreForward strore forward flag, default to 0
	*/
	public String wrapLoginRequest (String psUserName){
	
	        return wrapLoginRequest(psUserName,
									"",
									"",
									"0",
									"",
									"",
									new Hashtable(),
									"",
									null,
									"4");
	}
	
	//-----------------------------PROFILE LOGIN FORMATTER METHODS--------------------------------------------
	public String wrapLoginRequest (String psUserName,
									 String psPassWord,
									 String psStationId,
									 String psMessId,
									 String psStoreForward,
									 String psInstId,
									 String psFapId,
									 Hashtable psContext) 
	{
			  return wrapLoginRequest(psUserName,
						           psPassWord,
						           psStationId,
								   "0",
								   "",
								   "",
								   psContext,
								   "",
								   null,
								   SIGNON);
	
	}//METHOD wrapLoginRequest ENDS
	
	/**
	*challenge/response
	*signOnType=4,client sign-on authentication
	*signOnType=5,client sign-on authentication
	*
	*@param psUserName user name
	*@param psPassWord password
	*@param psStationId client station identification
	*@param psStoreForward store and forward flag
	*@param psInstId indtitute identification
	*@param psFapId FAP IDs
	*@param psFapId By service class
	*@param psNewPassword new password to be changed to
	*@param oToken token
	*@param signOnType sign on type: 4 -- client sign-on request; 5--client sign-on authtication
	*/
	public String wrapLoginRequest (String psUserName,
									 String psPassWord,
									 String psStationId,
									 String psStoreForward,
									 String psInstId,
									 String psFapId,
									 Hashtable psContext,
									 String psNewPassword,
									 ScProfToken oToken,
									 String serverProcedure) 
	{
			byte abRequestMessage[] = new byte[350];
	
	        String sToken="", sMessId="\1";
	        if (oToken!=null) {
	            sToken = oToken.getToken();
	            sMessId = oToken.getMessId();
	        }
	
			String sHeader = wrapProfHeader(sToken,
								            SEND_LOGIN_REQUEST,
								            psStoreForward,
								            sMessId,
								            oToken
								            );
	
			int iSize = setup_signon (abRequestMessage,
									  0,
									  psUserName,
									  psPassWord,
									  psStationId,
									  psInstId,
									  psFapId,
									  psContext,
									  psNewPassword,
									  serverProcedure
									  );
	
		   StringBuffer sbTemp = new StringBuffer("");
		   sbTemp.insert(0,sHeader);
		   sbTemp.append(ScUtils.byteToString(abRequestMessage, iSize));
		   return sbTemp.toString();
	
	}//METHOD wrapLoginRequest ENDS
	
	//-----------------------------PROFILE LOGOUT FORMATTER METHODS-----------------------------------------
	public String wrapLogoutRequest (ScProfToken a_oToken) {
		return wrapLogoutRequest(a_oToken, "0");
	}
	
	public String wrapLogoutRequest (ScProfToken a_oToken, String sStoreForward) {
	
		String sHeader = wrapProfHeader (a_oToken.getToken(),
				                         SEND_LOGIN_REQUEST,
						                 sStoreForward,
						                 a_oToken.getMessId(),
						                 a_oToken
						                 );
	
		String sLogoffMess = setupLogoff (a_oToken);
	
		StringBuffer sMess = new StringBuffer("");
	
		sMess.insert(0,sLogoffMess);
		sMess.insert(0,sHeader);
	
		return sMess.toString();
	
	}//CONSTRUCTOR wrapLogoutRequest ENDS
	
	//-----------------------------PROFILE MRPC FORMATTER METHODS--------------------------------------------
	public String wrapMrpcRequest (String psMrpcId,
	                       String psVersion,
						   String pasMrpcArgs[],
						   String psSpv,    // 09/09/03 MKT - XBAD Changes //**MKT-XBAD
						   String psStoreForward,
						   ScProfToken oToken) {
	
		String sHeader = wrapProfHeader (oToken.getToken(),
										 SEND_MRPC_MESS,
										 psStoreForward,
										 oToken.getMessId(),
										 oToken
										 );
	
	    if (psVersion.length()<1) psVersion = "1";
		String sMrpc = setup_mrpc_message (psMrpcId,
										   psVersion,
										   pasMrpcArgs,
										   psSpv); // 09/09/03 MKT - XBAD Changes	//**MKT-XBAD
	
	
		StringBuffer sMess = new StringBuffer("");
	
		sMess.insert(0,sMrpc);
		sMess.insert(0,sHeader);
	
		return sMess.toString();
	}

	//--------------------------------------------------------------
	
	public String wrapProfHeader (String psToken,
					              String psServiceClass,
							      String psStoreForward,
							      String psMessId,
							      ScProfToken oToken) 
	{
		  byte abBuffer [] = new byte [300];
	
		  int offset = setup_message_header  (abBuffer, psToken, psServiceClass, psStoreForward, psMessId, oToken);
	
	      return ScUtils.byteToString(abBuffer,offset);
	
	}//METHOD createMessHead ENDS

	//-----------------------------PROFILE SQL FORMATTER METHODS--------------------------------------------
	public String wrapSqlRequest (String psSqlMess,
						  String psQualifier,
						  String psStoreForward,
						  ScProfToken oToken)
	{
		int iIndex = 0;
		//convert variable to host variable
	
		if (psQualifier.indexOf("PREPARE=0")<0 && psQualifier.indexOf("/EFD=")<0 && !psSqlMess.toUpperCase().trim().startsWith("EXECUTE"))
	    {
	      psSqlMess = convToHostVar(psSqlMess);
	      iIndex = psSqlMess.indexOf("\t");
	    }
	
	    if (iIndex>0){
	        if (psQualifier.indexOf("USING=")>=0)
	        {
	            String s = psSqlMess.substring(iIndex+1,psSqlMess.length()).trim();
	            s = s.substring(s.indexOf("/USING=")+7,s.length());
	            if (psQualifier.charAt(psQualifier.length()-1)==')') psQualifier = psQualifier.substring(0,psQualifier.length()-1)+","+s.substring(s.indexOf('(')+1);
	            else  psQualifier = psQualifier+","+s;
	        }
	        else psQualifier =psQualifier+ psSqlMess.substring(iIndex+1,psSqlMess.length()).trim();
	
	        psSqlMess = psSqlMess.substring(0,iIndex);
	
	    }//
	
		String sHeader = wrapProfHeader (oToken.getToken(),
										 SEND_SQL_MESS,
										 psStoreForward,
										 oToken.getMessId(),
										 oToken
										 );
	
		byte abBuffer[] = new byte[psSqlMess.length()+psQualifier.length()+20];
	
		int iMessSize = setup_sql_message (abBuffer,
		                                   0,
			                               psSqlMess,
			                               psQualifier);
	
		String sSqlMess = ScUtils.byteToString(abBuffer,iMessSize);
	
		StringBuffer sMess = new StringBuffer("");
	
		sMess.insert(0,sSqlMess);
		sMess.insert(0,sHeader);
	
		return sMess.toString();
	
	}//CONSTRUCTOR wrapSqlRequest ENDS

	public byte[] wrapProfHeader1 (String psToken,
					              String psServiceClass,
							      String psStoreForward,
							      String psMessId,
							      ScProfToken oToken) 
	{
		  byte abBuffer [] = new byte [300];
	
		  int offset = setup_message_header  (abBuffer, psToken, psServiceClass, psStoreForward, psMessId, oToken);
	
		  return abBuffer;
	 }
	
	public String convToHostVar(String sSQLStatement)
    {
	
	    int i = sSQLStatement.trim().toUpperCase().indexOf("INSERT");
	    if (i==0||((i>0)&&(sSQLStatement.trim().toUpperCase().indexOf("BUFFER")==0))) return ScMSQLFormat.InsertHostConv(sSQLStatement);
	    return ScMSQLFormat.host(sSQLStatement);
    }
	
	public String wrapGenericRequest (String sHtmlMessage,
						           String psStoreForward,
						           ScProfToken oToken,
						           String sHeaderIndicator) 
	{
		String sHeader = wrapProfHeader (oToken.getToken(),
										 sHeaderIndicator,
										 psStoreForward,
										 oToken.getMessId(),
										 oToken);
	
	    byte bBuffer[] = new byte[sHtmlMessage.length()+500];
	
		int iMessSize = setup_html_message (bBuffer, 0, sHtmlMessage);
	
		String sHtmlMess = ScUtils.byteToString(bBuffer, iMessSize);
	
		StringBuffer sMess = new StringBuffer("");
	
		sMess.insert(0,sHtmlMess);
		sMess.insert(0,sHeader);
	
		return sMess.toString();
	}

	public String unwrapHtmlResponse(String sMessToParse) throws ScProfileException 
	{
		  errorCheck (HTML_MESS, sMessToParse);
		  int ii=0;
	
		  int  header_and_message[]    = new int[5];
		  int  header_strings[]        = new int[15];
		  int  message_strings1[]      = new int[24];
		  int  message_strings2[]      = new int[24];
	
		  byte reply_message2 [] = new byte[sMessToParse.length()+1000];
	
		  ii += ScUtils_obj.pack_string(sMessToParse.substring(0,sMessToParse.length()-2),reply_message2,0);
	   	  ScUtils_obj.parse_string(reply_message2,0,header_and_message, ScUtils.EXTRACT);
		  ScUtils_obj.parse_string(reply_message2,header_and_message[1],header_strings,ScUtils.EXTRACT);
		  ScUtils_obj.parse_string(reply_message2,header_and_message[2],message_strings1,ScUtils.EXTRACT);
	
		  String sTemp = new String();
		  sTemp = chopLV (reply_message2,message_strings1[2]);
		  return sTemp;
	
	}//METHOD unwrapSQLResponse ENDS
	
	private int setup_html_message (byte dest_buffer[], int dest_offset, String html_message) 
	{
			int i, offset;
			byte temp_buffer[] = new byte [html_message.length()+24];
	
			offset  = ScUtils_obj.pack_string (html_message,temp_buffer,0);
			offset  = ScUtils_obj.pack_string (temp_buffer,offset,dest_buffer,dest_offset);
	
			return offset;
	} //END OF SETUP_HTML_MESSAGE
	
	/**
	*unwrap client sign-on requset for challenge/response
	*@param LV reply message from Profile/Anyware
	*@return
	*/
	public String[] unwrapChallengeLoginResponse(String sMessToParse) throws ScProfileException 
	{
		errorCheck (PROFILE_LOGIN, sMessToParse);
	
		int ii=0;
	
		byte reply_message2[] = new byte[sMessToParse.length()+10];
		byte temp[] = ScUtils.stringToByte(sMessToParse);
	
		int  header_and_message[]  = new int[3];
		int  header_strings[]      = new int[8];
		int  message_strings1[]    = new int[50];
		int  message_strings2[]    = new int[50];
	
	    String sTemp= ScUtils.byteToString(temp,temp.length-2);
		ii += ScUtils_obj.pack_string(sTemp,reply_message2,0);
	
		ScUtils_obj.parse_string(reply_message2,0,header_and_message, ScUtils.EXTRACT);
	
		ScUtils_obj.parse_string(reply_message2,header_and_message[1],header_strings,ScUtils.EXTRACT);
	
	    //GET THE MESSAGE ID TO USE WITH THE GET TOKEN;
		String sMessageId = chopLV(reply_message2,header_strings[2]);
		ScUtils_obj.parse_string(reply_message2,header_and_message[2],message_strings1,ScUtils.EXTRACT);
	
		ScUtils_obj.parse_string(reply_message2,message_strings1[2],message_strings2,ScUtils.EXTRACT);
	
		String sToken = chopLV(reply_message2,message_strings2[1]);  //token
	    String sKey = chopLV(reply_message2,message_strings2[2]);	 //sign on key
	
		String[] s = {sToken,sKey};
		return s;
	
	}//METHOD unwrapLoginResponse ENDS
	
	public int unwrap(String sMessToParse, Vector v) throws ScProfileException 
	{
		int ii=0;
		byte reply_message2[] = new byte[sMessToParse.length()+10];
		int  header_and_message[]  = new int[200];
	
	    ii += ScUtils_obj.pack_string(sMessToParse,reply_message2,0);
		ScUtils_obj.parse_string(reply_message2,0,header_and_message, ScUtils.EXTRACT);
	
		String[] sTempx = new String[header_and_message[0]-1];
		int colCount = 0;
	
		for (int i=1; i<header_and_message[0]; i++)
		{
		    sTempx[i-1] = chopLV (reply_message2,header_and_message[i]);
		    int  lvCount[]  = new int[10];
		    byte replyTemp[] = new byte[sTempx[i-1].length()+10];
		    ScUtils_obj.pack_string(sTempx[i-1],replyTemp,0);
		    ScUtils_obj.parse_string(replyTemp,0,lvCount, ScUtils.EXTRACT);
		    if (lvCount[0]>2) {
		        unwrap(sTempx[i-1],v);
		        colCount = lvCount[0]-1;
		    }
		    else {
		        if ((sTempx[i-1]==null)||(sTempx[i-1].length()<1)) sTempx[i-1]="";
		        v.add(sTempx[i-1]);
		    }
		}
		return colCount;
	}//METHOD unwrapLoginResponse ENDS
	
	public Vector chopLV(String lvMessage,int colCount)
	    throws Exception
	{
	    Vector v = new Vector();
	    int count = unwrap(lvMessage, v);
	
	    Vector output = new Vector();
	    Enumeration e = v.elements();
	    String[] sArray = new String[colCount];
	    int i = 0;
	    String s="";
	    while (e.hasMoreElements())
		{
		    s = (String)e.nextElement();
		    sArray[i] = s;
	        i++;
	        if (i==colCount)
	        {
	            output.addElement(sArray);
	            sArray = new String[colCount];
	            i=0;
	        }
	    }
	    return output;
	}
	
	private String complxError(String errorMessage)
	{
	   try{
	    Vector v = new Vector();
	    int count = unwrap(errorMessage, v);
	
	    Vector output = new Vector();
	    Enumeration e = v.elements();
	    int i = 0;
	    String s="";
	    while (e.hasMoreElements())
		{
		    String s1 = (String)e.nextElement();
		    if (i>0) s = s + " " + s1.trim();
		    else s = s1.trim();
		    i++;
		}
	
	    s.replace('|', ' ');
	    if (s.length()<1) return errorMessage;
	    else return s;
	   }
	   catch(Exception e){return errorMessage; }
	}
}//CLASS ScProfileMess ENDS
