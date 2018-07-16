package sanchez.him_pa.utils;

import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

public class ScFileUtils extends sanchez.base.ScObject
{
	FileInputStream oFileInputStream = null;
	DataInputStream oDataInputStream = null;
	 
	public ScFileUtils (String psFileName) throws FileNotFoundException {
		
		  if (psFileName != null) {
			 oFileInputStream = new FileInputStream (psFileName);       
			 oDataInputStream = new DataInputStream (oFileInputStream); 
		  }
	}//CONSTRUCTOR ScFileUtils ENDS
	
	public String[] parseIntoParts (String psParts) throws IOException 
	{
		   if (oFileInputStream == null || oDataInputStream == null)
				return null;
		   byte abInputBuffer[]=null;
		   String asReturnThis[] = new String[100];
		   int iBytesRead=0;
		   int iIndex=0;
		   int ii;
		   for (ii=0; ii<asReturnThis.length; ii++)           
				asReturnThis[ii] = null;
		   try {
				abInputBuffer = new byte[oFileInputStream.available()+1];
				while ((iBytesRead = oDataInputStream.read (abInputBuffer, iIndex, 1000)) != -1)
				   iIndex += iBytesRead;                      
		   }
		   catch (IOException ioexcept) {}
		   
		   String sFileString = new String(abInputBuffer);
		   
		   iIndex=0; int iArrayIndex=0; int iPosInString=0;
		   while ((iPosInString = sFileString.indexOf(psParts, iIndex)) != -1) {
				   asReturnThis[iArrayIndex] = sFileString.substring(iIndex, iPosInString+psParts.length());
				   iArrayIndex++;
				   iIndex = iPosInString+psParts.length();                                      
		   }
		   asReturnThis[iArrayIndex] = sFileString.substring(iIndex, sFileString.length());
		   asReturnThis[++iArrayIndex]=null;
					 
		   oDataInputStream.close();
		   oFileInputStream.close();
		   
		   return asReturnThis;
	}//METHOD parseIntoParts ENDS*/
}//CLASS ScFileUtils ENDS