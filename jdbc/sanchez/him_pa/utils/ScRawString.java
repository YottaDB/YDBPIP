package sanchez.him_pa.utils;

/*
 *
 * CLASS TITLE: ScRawString
 *
 */
public class ScRawString extends sanchez.base.ScObject{

//-------------------------PUBLIC & PRIVATE DATA------------------	
	public   static final int DEFAULT_BUFF_SIZE = 1048576;
	public   static final int MAX_BUFF_SIZE = DEFAULT_BUFF_SIZE;

	public   byte   buffer[];
	public	 int    buffer_size  =  0;
	public	 int    string_size  =  0;


	public ScRawString () {
		 buffer = new byte[DEFAULT_BUFF_SIZE];
		 string_size = 0;
		 this.buffer_size = DEFAULT_BUFF_SIZE;
	}
	public ScRawString (byte newbuff[], int size) {
		 int i;
		 buffer = new byte [size+1];

		 for (i=0;i<size;i++) 
				 buffer[i] = newbuff[i];
	
		 buffer_size = size + 1;
		 string_size = size;
	}
	public ScRawString (char newbuff[], int size) {
		 int i;
		 buffer = new byte [size+1];

		 for (i=0;i<size;i++) 
				 buffer[i] = (byte)newbuff[i];
	
		 buffer_size = size + 1;
		 string_size = size;
	}
//--------------------------CONSTRUCTORS-------------------------
	public ScRawString (int buffer_size) {
		 buffer = new byte[buffer_size];
		 string_size = 0;
		 this.buffer_size = buffer_size;
	}
	public ScRawString (String newbuff) {
			int ii;
			buffer = new byte [newbuff.length()+1];
			
			for (ii=0; ii<newbuff.length(); ii++)
					buffer[ii] = (byte)newbuff.charAt(ii);
					
			buffer_size = newbuff.length() + 1;
			string_size = newbuff.length();
	}
//---------------------------------------------------------------
	public void append (byte new_buff[], int size) {

		int  i;
	    byte temp_buff[];

		//IF NEW STRING + ORIG STRING > BUFF SIZE ENLARGE BUFFER
		if (this.string_size + size > buffer_size) {
		   		temp_buff = new byte[this.string_size+size];
			   	for (i=0;i<this.string_size;i++) 
					   	  temp_buff[i] = buffer[i];

						   buffer = temp_buff;
						   buffer_size = this.string_size + size;
			    }

		//COPY NEW STRING TO END OF OLD STRING
		for (i = 0; i < size; i++)
		    buffer[this.string_size + i] = new_buff[i];

		string_size += size;

		
	}//SECOND APPEND ENDS
//---------------------------------------------------------------
	public void append (ScRawString rstring) {
	    int  i;
	    byte temp_buff[];

		//IF NEW STRING + ORIG STRING > BUFF SIZE ENLARGE BUFFER
		if (string_size + rstring.string_size > buffer_size) {
		   		temp_buff = new byte[string_size+rstring.string_size];
			   	for (i=0;i<string_size;i++) 
					   	  temp_buff[i] = buffer[i];

						   buffer = temp_buff;
						   buffer_size = string_size + rstring.string_size;
	    }

		//COPY NEW STRING TO END OF OLD STRING
		for (i = 0; i < rstring.string_size; i++)
		    buffer[string_size + i] = rstring.buffer[i];

		string_size += rstring.string_size;
				    
	}//APPEND ENDS
//---------------------------------------------------------------
	public void append (String source_string) {
		   int ii=0;
		   byte temp_buffer[];

//IF NEW STRING + ORIG STRING > BUFF SIZE ENLARGE BUFFER
		if (string_size + source_string.length() > buffer_size) {
				temp_buffer = new byte[string_size+source_string.length()];

				for (ii=0; ii<string_size; ii++)
					   temp_buffer[ii] = buffer[ii];

			    buffer = temp_buffer;
				buffer_size = string_size + source_string.length();            
		}

		//COPY NEW STRING TO END OF OLD STRING
		for (ii = 0; ii < source_string.length(); ii++)
		    buffer[string_size + ii] = (byte)source_string.charAt(ii);

		string_size += source_string.length();
	
	
	
	}//METHOD APPEND ENDS    
	public void copy (byte dest_buffer[], int dest_offset, ScInt ii) {
		int i;

		for (i=0; i<string_size;i++)
			 dest_buffer[i + dest_offset] = buffer[i];

		ii.val  = string_size;
		ii.total_size = -1;
	}
//---------------------------------------------------------------
	public void copy (byte dest_buffer[], ScInt ii) {
		int i;

		for (i=0;i<string_size;i++)
			dest_buffer[i] = buffer[i];

		ii.val  = string_size;
		ii.total_size = -1;
	}//END OF COPY
	public void copy (char dest_buffer[], ScInt ii) {
		int i;

		for (i=0; i<string_size;i++)
			 dest_buffer[i] = (char)buffer[i];

		ii.val  = string_size;
		ii.total_size = -1;
	}
//---------------------------------------------------------------
	public int get_buffer_size () {
		return buffer_size;
	}
//---------------------------------------------------------------
	public byte get_byte (int index) {

		return (buffer[index]);
	}
//--------------------------METHODS------------------------------
	public int get_string_size () {
		return string_size;
	}
//---------------------------------------------------------------
	public byte [] getBuffer() {
			return buffer;
	}
//---------------------------------------------------------------
	public void insert (byte[] array, int size, int insert_point) {
	
	    int  i, j, new_buff_size;
	    byte temp_buff[];

		//ERROR CHECK FOR ARRAY OUT OF BOUNDS. USE DEFAULTS INSTEAD OF
		//THROWING AN ERROR
		if (insert_point > string_size)
			insert_point = string_size;
		if (insert_point < 0)
			insert_point = 0;

		//IF NEW STRING + ORIG STRING > BUFF SIZE ENLARGE BUFFER
		if (string_size + size > buffer_size)
			new_buff_size = string_size+size;
		else
			new_buff_size = buffer_size;

		temp_buff = new byte[new_buff_size];
		
		
		for (i=0;i<insert_point;i++) 
		   	  temp_buff[i] = buffer[i];

		for (i=0;i<size;i++)
			  temp_buff[insert_point+i] = array[i];

		j=i+insert_point;
		for (i=0;i<(string_size-insert_point);i++) {
			temp_buff[j+i] = buffer[insert_point+i];
		}
	
		buffer = temp_buff;
		buffer_size = new_buff_size;
		string_size += size;		
			
		    
	} //END OF INSERT 2
//---------------------------------------------------------------
	public void insert (ScRawString rstring, int insert_point) {
	
	    int  i, j, new_buff_size;
	    byte temp_buff[];

		//ERROR CHECK FOR ARRAY OUT OF BOUNDS. USE DEFAULTS INSTEAD OF
		//THROWING AN ERROR
		if (insert_point > string_size)
			insert_point = string_size;
		if (insert_point < 0)
			insert_point = 0;

		//IF NEW STRING + ORIG STRING > BUFF SIZE ENLARGE BUFFER
		if (string_size + rstring.string_size > buffer_size)
			new_buff_size = string_size+rstring.string_size;
		else
			new_buff_size = buffer_size;

		temp_buff = new byte[new_buff_size];
		
		
		for (i=0;i<insert_point;i++) 
		   	  temp_buff[i] = buffer[i];

		for (i=0;i<rstring.string_size;i++)
			  temp_buff[insert_point+i] = rstring.buffer[i];

		j=i+insert_point;
		for (i=0;i<(string_size-insert_point);i++) {
			temp_buff[j+i] = buffer[insert_point+i];
		}
	
		buffer = temp_buff;
		buffer_size = new_buff_size;
		string_size += rstring.string_size;		
			
		    
	} //END OF INSERT 1
//---------------------------------------------------------------
	public void replace (byte new_buffer[], int size) {

			int i;

			if (size > buffer_size) {
				buffer = new byte [size];   
				buffer_size = size;
			}

			for (i=0; i<size; i++)
				   buffer[i] = new_buffer[i];
		
			string_size = size;

	}
//---------------------------------------------------------------
	public void replace (char new_buffer[], int size) {

			int i;

			if (size > buffer_size) {
				buffer = new byte [size];   
				buffer_size = size;
			}

			for (i=0; i<size; i++)
				   buffer[i] = (byte)new_buffer[i];
		
			string_size = size;

	}
}//ScRawString ends