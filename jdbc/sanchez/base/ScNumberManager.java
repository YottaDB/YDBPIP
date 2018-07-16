package sanchez.base;

import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.text.FieldPosition;
import java.text.NumberFormat;
import java.text.ParsePosition;
import java.util.Locale;
import java.util.StringTokenizer;

import sanchez.utils.ScUtility;

public class ScNumberManager
{
	DecimalFormat i_oDecimalFormat;
	DecimalFormat i_oIntegerFormat;
	DecimalFormat i_oCurrencyFormat;
	public String i_sNumPattern;
	
	/**
	 * Constructor with a_oDecimalFormat, a_oIntegerFormat, pattern Parameters  
	 * @param a_oDecimalFormat
	 * @param a_oIntegerFormat
	 * @param pattern
	 */
	public ScNumberManager(DecimalFormat a_oDecimalFormat, DecimalFormat a_oIntegerFormat, String pattern)
	{
	    i_sNumPattern = pattern;
		i_oDecimalFormat = a_oDecimalFormat;
		i_oIntegerFormat = a_oIntegerFormat;

		try
		{    
			i_oCurrencyFormat = (DecimalFormat)ScUtility.deepCopy(i_oDecimalFormat);    
		}
		catch(Exception e)
		{
		}    
	}
	
	/**
	 * Constructor with a_oDecimalFormat Parameter
	 * @param a_oDecimalFormat
	 */
	public ScNumberManager(DecimalFormat a_oDecimalFormat)
	{
		i_oDecimalFormat = a_oDecimalFormat;
		NumberFormat nf = NumberFormat.getInstance(new Locale("en","US"));		
		i_oIntegerFormat = (DecimalFormat) nf;		
		i_oIntegerFormat.applyPattern("####");
		try
		{    
			i_oCurrencyFormat = (DecimalFormat)ScUtility.deepCopy(i_oDecimalFormat);    
		}
		catch(Exception e)
		{	
	    }
	}
	
	/**
	 * This method is to get the formatted integer
	 * @param a_sInt int
	 * @return String
	 */
	public String getFormattedInteger(int a_sInt)
	{
	    return i_oIntegerFormat.format(a_sInt);
	}
	
	/**
	 * This method is to get integer
	 * @param a_sFormattedInt String
	 * @return int 
	 * @exception throws java.lang.Exception
	 */
	public int getInteger(String a_sFormattedInt)throws Exception
	{
	    Number n = i_oDecimalFormat.parse(a_sFormattedInt);
	    return n.intValue();
	}
	
	/**
	 * This method is to get the formatted currency 
	 * @param a_sNumber double
	 * @return String
	 * @exception throws java.lang.Exception
	 */
	public String getFormattedCurrency(double a_sNumber)throws Exception
	{
		if(i_sNumPattern.length()>0)
		    i_oCurrencyFormat.applyPattern(i_sNumPattern);
		int p = i_oCurrencyFormat.getMinimumFractionDigits();
		if(p<2)
		    i_oCurrencyFormat.setMinimumFractionDigits(2);
		return i_oCurrencyFormat.format(a_sNumber);
	}
	
	/**
	 * This method is to get the formatted number
	 * @param a_sNumber double
	 * @return String
	 * @exception throws java.lang.Exception
	 */
	public String getFormattedNumber(double a_sNumber)throws Exception
	{
	    if(i_sNumPattern.length()>0)
	        i_oDecimalFormat.applyPattern(i_sNumPattern);
		StringBuffer sb = new StringBuffer();		
		i_oDecimalFormat.format(a_sNumber, sb, new FieldPosition(DecimalFormat.FRACTION_FIELD));
		return sb.toString();
	}
	
	/**
	 * This method is to get the formatted number
	 * @param a_sNumber double
	 * @param precision String
	 * @return String
	 * @exception throws java.lang.Exception
	 */
	public String getFormattedNumber(double a_sNumber, String precision)throws Exception
	{
		if(precision==null || precision.length()<=0)
	        return getFormattedNumber(a_sNumber);	    
		StringBuffer sb = new StringBuffer();		
	    int precise = new Integer(precision).intValue();
	    DecimalFormat df = (DecimalFormat)ScUtility.deepCopy(i_oDecimalFormat);
	    df.setMinimumFractionDigits(precise);
	    if(i_sNumPattern.length()>0)
	        df.applyPattern(i_sNumPattern);
		df.format(a_sNumber, sb, new FieldPosition(DecimalFormat.FRACTION_FIELD));
		return sb.toString();
	}

	/**
	 * This method is to get the number
	 * @param a_sFormattedNumber String
	 * @return double
	 * @exception throws java.lang.Exception
	 */
	public double getNumber(String a_sFormattedNumber) throws Exception 
	{	    	    
		ParsePosition pp = new ParsePosition(0);		
		Number n = i_oDecimalFormat.parse(a_sFormattedNumber, pp);		
		double d = n.doubleValue();		
		int ind = pp.getIndex();
		if(a_sFormattedNumber.length() > ind)
			throw new Exception(ScBundle.getMessage(ScResourceKeys.Invalid_Number_Format));
		else
		{
			char c = a_sFormattedNumber.charAt(ind-1);
			if(!Character.isDigit(c))
				throw new Exception(ScBundle.getMessage(ScResourceKeys.Number_Expected));
			String pat = i_oDecimalFormat.toLocalizedPattern();
			DecimalFormatSymbols dfs = i_oDecimalFormat.getDecimalFormatSymbols();
			char decSym = dfs. getDecimalSeparator();
			char grpSym = dfs.getGroupingSeparator();
			int dec = pat.indexOf(decSym);
			int grp = pat.indexOf(grpSym);
			if(dec==-1)
				dec=pat.length();
			if(grp!=-1)
			{
				int x = a_sFormattedNumber.indexOf(decSym);
				String sFormattedNumber;
				if(x>0)
				{					
					sFormattedNumber= a_sFormattedNumber.substring(0,x);
				}
				else
				{
					sFormattedNumber= a_sFormattedNumber;
				}

				int group = dec-grp;	
				group--;						
				StringBuffer sb = new StringBuffer();
				sb.append(grpSym);			
				String delimiter = sb.toString();
				StringTokenizer st = new StringTokenizer(sFormattedNumber,delimiter);
				if(st.hasMoreTokens())
					st.nextToken();
				while(st.hasMoreTokens())
				{
					String t = st.nextToken();
					int len = t.length();					
					if(len!=group)
					{
						throw new Exception(ScBundle.getMessage(ScResourceKeys.Pattern_mismatch));
					}
				}
			}
		return d;
		}
	}
	/**
	 * This method is to get the currency
	 * @param a_sFormattedNumber
	 * @return double
	 * @exception throws java.lang.Exception
	 */
	public double getCurrency(String a_sFormattedNumber) throws Exception 
	{	    
		ParsePosition pp = new ParsePosition(0);
		Number n = i_oCurrencyFormat.parse(a_sFormattedNumber, pp);		
		double d = n.doubleValue();
		String s = getFormattedCurrency(d);
		if(s.equals(a_sFormattedNumber))
			return d;
		else
		{
			return this.getNumber(a_sFormattedNumber);
		}	
	}
	
	/**
	 * This method is to get the localized number pattern
	 * @return String 
	 */
	public String getLocalizedNumberPattern()
	{
	    String str = i_oDecimalFormat.toLocalizedPattern();
	    return str;	    
	}
	
	/**
	 * This method is to get the number pattern
	 * @return String 
	 */
	public String getNumberPattern()
	{	    
	    return i_oDecimalFormat.toPattern();
	}
	
	/**
	 * This method is to get the localized currency pattern
	 * @return String 
	 */
	public String getLocalizedCurrencyPattern()
	{
	    String str = i_oCurrencyFormat.toLocalizedPattern();
	    return str;	    
	}
	
	/**
	 * This method is to get the currency pattern
	 * @return String 
	 */
	public String getCurrencyPattern()
	{
	    return i_oCurrencyFormat.toPattern();
	}
	
	/**
	 * This method is to get the localized integer pattern
	 * @return String 
	 */
	public String getLocalizedIntegerPattern()
	{
	    String str = i_oIntegerFormat.toLocalizedPattern();
	    return str;	    
	}
	
	/**
	 * This method is to get the Integer pattern
	 * @return String 
	 */
	public String getIntegerPattern()
	{
	    return i_oIntegerFormat.toPattern();
	}
	
	/**
	 * This method is to get the Decimal format
	 * @return DecimalFormat 
	 */
	public DecimalFormat getDecimalFormat()
	{
		return i_oDecimalFormat;
	}
	
	/**
	 * This method is to get the Integer format
	 * @return DecimalFormat
	 */
	public DecimalFormat getIntegerFormat()
	{
		return i_oIntegerFormat;
	}
	
	/**
	 * This method is to get the currency format
	 * @return DecimalFormat
	 */
	public DecimalFormat getCurrencyFormat()
	{
		return i_oCurrencyFormat;
	}
	
	/**
	 * refresh
	 */
	public void refresh() 
	{
	} 

	/**
	 * reset
	 */
	public void reset() 
	{
	}
}