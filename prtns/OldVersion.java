import java.io.BufferedReader;
import java.io.FileReader;
import java.util.StringTokenizer;

/**
 * @author CooneyJ
 *
 * Used to detect problems with StarTeam labeling where
 * an old version of an element may be used.
 * 
 * These problems need to be identified so they can 
 * be fixed moving forward.
 * 
 * This is a single java class runnable at the command prompt.
 */
public class OldVersion {

	public static void main(String[] args) {
		int i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11,i12,i13,i14;
		
		System.out.println("");		
		System.out.println("OldVersion");
		System.out.println("This script processes the build_contents file");
		System.out.println("for several labels, and flags old versions");
		System.out.println("");		
		System.out.println("Ex:  $ java OldVersion DEP-BU_IPF.TRIG");		
		System.out.println("");				
		
		String searchElement="";
		if (args.length<1) {
			return;
		}
		searchElement=args[0];

		System.out.println("Searching for: "+searchElement);						

		// we will add entries to this section to process more labels;
		
		i1=Processfile("SP_Profile01_01_20020927",searchElement);
		i2=Processfile("SP_Profile01_01_20021009",searchElement);
		if (i2<i1) {System.out.println("WARNING:  Older version detected");}		
		i3=Processfile("SP_Profile01_01_20021017",searchElement);
		if (i3<i2) {System.out.println("WARNING:  Older version detected");}		
		i4=Processfile("SP_Profile01_NEW_01_20021023",searchElement);
		if (i4<i3) {System.out.println("WARNING:  Older version detected");}		
		i5=Processfile("SP_Profile01_01_20021023",searchElement);
		if (i5<i4) {System.out.println("WARNING:  Older version detected");}
		i6=Processfile("SP_Profile01_01_20021113",searchElement);
		if (i6<i5) {System.out.println("WARNING:  Older version detected");}
		i7=Processfile("SP_Profile01_01_20021121",searchElement);
		if (i7<i6) {System.out.println("WARNING:  Older version detected");}
		i8=Processfile("SP_Profile01_01_20021211",searchElement);
		if (i8<i7) {System.out.println("WARNING:  Older version detected");}
		i9=Processfile("SP_Profile01_01_20021218",searchElement);
		if (i9<i8) {System.out.println("WARNING:  Older version detected");}
		i10=Processfile("SP_Profile01_01_20021231",searchElement);
		if (i10<i9) {System.out.println("WARNING:  Older version detected");}
		i11=Processfile("SP_Profile01_01_20030109",searchElement);
		if (i11<i10) {System.out.println("WARNING:  Older version detected");}
		i12=Processfile("SP_Profile01_01_20030114",searchElement);
		if (i12<i11) {System.out.println("WARNING:  Older version detected");}
		i13=Processfile("SP_Profile01_P01_DEV_17",searchElement);
		if (i13<i12) {System.out.println("WARNING:  Older version detected");}
		i14=Processfile("SP_Profile01_P01_DEV_18",searchElement);
		if (i14<i13) {System.out.println("WARNING:  Older version detected");}

		
	}
	
	public static int Processfile(String filename, String searchElement) {
		StringTokenizer st1;
		
		System.out.println("===========================================");	
		System.out.println("Label: "+filename);	
		String text1;
		filename="/profile_release/sp/"+filename+"/release_doc/build_contents.txt";
		
        try {
            BufferedReader readtext = new BufferedReader (new FileReader(filename));
            text1 = readtext.readLine();
            while (text1 !=null){
				
				//found the entry we are after...
            	if (text1.startsWith(searchElement)) {
					System.out.println(text1); 
                    
                    st1=new StringTokenizer(text1, "|");    //uses quotes as tokenizer
                    st1.nextToken(); //item
                    st1.nextToken(); //type
                    int retval = (int) Integer.parseInt(st1.nextToken()); //version
					return retval; 
					           		
            	}
                text1 = readtext.readLine();
                
            }
        }
        catch (java.lang.Exception ex) {
			System.err.println("An error occured while parsing the file");            		        	
            ex.printStackTrace ();  // Got some other type of exception.  Dump it.
            return -1;
        }		
		
		return 0;					
				
	}
}
