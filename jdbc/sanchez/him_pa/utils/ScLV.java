package sanchez.him_pa.utils;

/**
 * This type was created in VisualAge.
 */
public class ScLV extends sanchez.base.ScObject{
	
	private static final int MAX_BUFFER_SIZE = 35000;
	private static final int MAX_BYTE_VAL    = 0XFF;
	private static final int MAX_WORD_VAL    = 0XFFFF;
	private static final int MAX_3BYTE_VAL   = 0XFFFFFF;
	private boolean tPackAll=false;
	private ScUtils ScUtils_obj = new ScUtils();
	
	public StringBuffer sbPackedString = new StringBuffer("");
//--------------------------------------------------------------------------------------
//==================================CONSTRUCTORS======================================
	public ScLV () {return;}
	public ScLV (String pasSource[]) {
		this.pack(pasSource);
	}
	public ScLV (String psSource) {
		this.pack(psSource);
	}
//--------------------------------------------------------------------------------------
	public void pack (String pasSource[]){
		int ii;
		
		for (ii=0; pasSource[ii] != null && ii<pasSource.length;ii++){
			 pack(pasSource[ii]);
		}
	}
//===================================PUBLIC INTERFACE=================================	
	public void pack (String psSource){
	
		int ii, jj, iSizeofSource = psSource.length();
		byte abDestBuffer[] = new byte[psSource.length()+10];
		
		ii = packNumber (iSizeofSource, abDestBuffer, 0);
		for (jj=0; jj<iSizeofSource; jj++)
				abDestBuffer[ii + jj]	= (byte) psSource.charAt(jj);
	
	    sbPackedString.insert(0,ScUtils.byteToString(abDestBuffer,ii+jj));
	}//METHOD PACK (String psSource) ENDS
//--------------------------------------------------------------------------------------
	public void packAll() {
		String sTemp = sbPackedString.toString();
	
		sbPackedString.setLength(0);
		
		pack(sTemp);
		
		tPackAll = true;
	}//METHOD packAll ENDS
//--------------------------------------------------------------------------------------
	public int packNumber(int   source_number,
		                  byte  dest_buffer[],
						  int   buffer_offset) {
	
		int    temp_number=0, the_size;
		int    i;
	
		if (source_number + 1 <= MAX_BYTE_VAL)	{
			   the_size = 1;
			   temp_number = source_number + 1;
		}
		else if (source_number + 2 <= MAX_WORD_VAL) {
			  the_size = 2;
			  temp_number = source_number + 2;
		}
		else if (source_number + 3 <= MAX_3BYTE_VAL) {
			     the_size = 3;
				 temp_number = source_number + 3;
		}
		else {/*number is 4 bytes long*/
					the_size = 4;
				    temp_number = source_number + 4;
		}
	
		if (the_size == 1) {
			   dest_buffer[buffer_offset] = (byte)temp_number;
			   return 1;
		}
		else {	//ELSE A
			dest_buffer[buffer_offset++] = 0;
			dest_buffer[buffer_offset] = (byte)the_size;
			for (i = (buffer_offset+the_size);  i>buffer_offset;  i--) {
				dest_buffer[i] = (byte)(temp_number % 256);
				temp_number /= 256;
			}
			return (the_size + 2); 
	    }/*END OF ELSE A*/
	}//PACK_NUMBER ENDS
//--------------------------------------------------------------------------------------
	public int parse_string  (String psbSourceBuffer,int piSourceIndex,int aiDestArray[])  						  
	{
		 byte source_buffer[] = ScUtils.stringToByte(psbSourceBuffer);
		 int  dest_array[]    = aiDestArray;
		 int  source_index    = piSourceIndex;
		 
		int index = source_index, size_so_far=0, total_size, i, offset=0;
		ScInt ci = new ScInt();
	
		index        += unpack_number(source_buffer, source_index,ci);
		total_size   = ci.val;
		i=1;
		
		while (size_so_far < total_size)
		{
				dest_array[i++] = index;
		
				offset = unpack_number(source_buffer,index,ci);
				index       += offset+ci.val;
				size_so_far += offset+ci.val;
		}
	   
		dest_array[0] = i ;
 
		return (i);

	} //END OF PARSE_STRING
//--------------------------------------------------------------------------------------
	public String toString(){
	   return sbPackedString.toString();
	}
//--------------------------------------------------------------------------------------
	public String[] unpack() {
		String sHoldPacked;
		ScInt number = new ScInt ();
		int iLength=0, ii;
		
		if (tPackAll == false)
			 sHoldPacked = (new ScLV(sbPackedString.toString())).toString();
		else
			 sHoldPacked = sbPackedString.toString();
	
		int iHoldIndex[] = new int [256];
		
		int iNumSegments = parse_string(sHoldPacked,0,iHoldIndex);
		
		String sTemp[] = new String[iNumSegments];
		
		for (ii=0; ii<iNumSegments; ii++){
			   iLength = unpack_number (ScUtils.stringToByte(sHoldPacked),iHoldIndex[ii],number);
			   sTemp[ii] = sbPackedString.toString().substring(iHoldIndex[ii],iHoldIndex[ii]+number.val+iLength);
		}
	
		return sTemp;    
	}
//--------------------------------------------------------------------------------------------------------------------------
	public int unpack_number (byte  source_buffer[],
		                      int   source_index,
							  ScInt number) {

		int index = source_index, size;

		if (source_buffer[index]  != 0) {
			   number.val   = (unsigned(source_buffer[index]) - 1);	//abs
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
		number.total_size = (byte)(size + 2);
		return (size + 2);

	} //END OF UNPACK_NUMBER
//--------------------------------------------------------------------------------------------------------------------------
	public static int unsigned (int number) {

				if (number < 0)
						 return (number * -1);
			    else
					 	 return number;
	}
}//CLASS SCLV ENDS