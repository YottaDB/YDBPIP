package sanchez.him_pa.utils;
import java.util.Hashtable;

/**        
 * ScUnicodeBlock
 * A family of character subsets representing the character blocks defined
 * by the Unicode 2.0 specification.  Any given character is contained by
 * at most one Unicode block.
 *
 * 
 * @version     1.0  Jan. 15, 2003
 * @author      Quansheng Jia 
 * 
 */
 

 
 
public final class ScUnicodeBlock
{

    static Hashtable langList = new Hashtable(); 
    
    static {
        //langList.put("BASIC_LATIN","");
	    //langList.put("LATIN_1_SUPPLEMENT","");
	    langList.put("LATIN_EXTENDED_A","");
	    //langList.put("LATIN_EXTENDED_B","");
	    //langList.put("IPA_EXTENSIONS","");
	    //langList.put("SPACING_MODIFIER_LETTERS","");
	    //langList.put("COMBINING_DIACRITICAL_MARKS","");
	    langList.put("GREEK","");
	    langList.put("CYRILLIC","");
	    //langList.put("ARMENIAN","");
	    //langList.put("HEBREW","");
	    //langList.put("ARABIC","");
	    //langList.put("DEVANAGARI","");
	    //langList.put("BENGALI","");
	    //langList.put("GURMUKHI","");
	    //langList.put("GUJARATI","");
	    //langList.put("ORIYA","");
	    //langList.put("TAMIL","");
	    //langList.put("TELUGU","");
	    //langList.put("KANNADA","");
	    //langList.put("MALAYALAM","");
	    //langList.put("THAI","");
	    //langList.put("LAO","");
	    //langList.put("TIBETAN","");
	    //langList.put("GEORGIAN","");
	    //langList.put("HANGUL_JAMO","");
	    langList.put("LATIN_EXTENDED_ADDITIONAL","");
	    //langList.put("GREEK_EXTENDED","");
	    //langList.put("GENERAL_PUNCTUATION","");
	    //langList.put("SUPERSCRIPTS_AND_SUBSCRIPTS","");
	    //langList.put("CURRENCY_SYMBOLS","");
	    //langList.put("COMBINING_MARKS_FOR_SYMBOLS","");
	    //langList.put("LETTERLIKE_SYMBOLS","");
	    //langList.put("NUMBER_FORMS","");
	    //langList.put("ARROWS","");
	    //langList.put("MATHEMATICAL_OPERATORS","");
	    //langList.put("MISCELLANEOUS_TECHNICAL","");
	    //langList.put("CONTROL_PICTURES","");
	    //langList.put("OPTICAL_CHARACTER_RECOGNITION","");
	    //langList.put("ENCLOSED_ALPHANUMERICS","");
	    //langList.put("BOX_DRAWING","");
	    //langList.put("BLOCK_ELEMENTS","");
	    //langList.put("GEOMETRIC_SHAPES","");
	    //langList.put("MISCELLANEOUS_SYMBOLS","");
	    //langList.put("DINGBATS","");
	    //langList.put("CJK_SYMBOLS_AND_PUNCTUATION","");
	    //langList.put("HIRAGANA","");
	    //langList.put("KATAKANA","");
	    //langList.put("BOPOMOFO","");
	    //langList.put("HANGUL_COMPATIBILITY_JAMO","");
	    //langList.put("KANBUN","");
	    //langList.put("ENCLOSED_CJK_LETTERS_AND_MONTHS","");
	    //langList.put("CJK_COMPATIBILITY","");
	    //langList.put("CJK_UNIFIED_IDEOGRAPHS","");
	    //langList.put("HANGUL_SYLLABLES","");
	    //langList.put("SURROGATES_AREA","");
	    //langList.put("PRIVATE_USE_AREA","");
	    //langList.put("CJK_COMPATIBILITY_IDEOGRAPHS","");
	    //langList.put("ALPHABETIC_PRESENTATION_FORMS","");
	    //langList.put("ARABIC_PRESENTATION_FORMS_A","");
	    //langList.put("COMBINING_HALF_MARKS","");
	    //langList.put("CJK_COMPATIBILITY_FORMS","");
	    //langList.put("SMALL_FORM_VARIANTS","");
	    //langList.put("ARABIC_PRESENTATION_FORMS_B","");
	    //langList.put("SPECIALS","");
	    //langList.put("HALFWIDTH_AND_FULLWIDTH_FORMS","");
	}
    
    public static class Subset  {

	private String name;

	/**
         * Constructs a new <code>Subset</code> instance.
	 *
	 * @param  name  The name of this subset
         */
    	protected Subset(String name) {
	    this.name = name;
	}

	/**
	 * Compares two <code>Subset</code> objects for equality.  This
         * method returns <code>true</code> if and only if <code>x</code> and
         * <code>y</code> refer to the same object, and because it is final it
	 * guarantees this for all subclasses.
	 */
	public final boolean equals(Object obj) {
	    return (this == obj);
	}

	/**
         * Returns the standard hash code as defined by the <code>{@link
	 * Object#hashCode}</code> method.  This method is final in order to
	 * ensure that the <code>equals</code> and <code>hashCode</code>
	 * methods will be consistent in all subclasses.
	 */
	public final int hashCode() {
	    return super.hashCode();
	}

	/**
	 * Returns the name of this subset.
	 */
	public final String toString() {
	    return name;
	}

    }

    /**
     * A family of character subsets representing the character blocks defined
     * by the Unicode 2.0 specification.  Any given character is contained by
     * at most one Unicode block.
     *
     * @since JDK1.2
     */
    public static final class UnicodeBlock extends Subset {

	private UnicodeBlock(String name) {
	    super(name);
	}

        /** Constant for the Unicode character block of the same name. */
        public static final UnicodeBlock
	    BASIC_LATIN
                = new UnicodeBlock("BASIC_LATIN"),
	    LATIN_1_SUPPLEMENT
                = new UnicodeBlock("LATIN_1_SUPPLEMENT"),
            LATIN_EXTENDED_A
                = new UnicodeBlock("LATIN_EXTENDED_A"),
            LATIN_EXTENDED_B
                = new UnicodeBlock("LATIN_EXTENDED_B"),
            IPA_EXTENSIONS
                = new UnicodeBlock("IPA_EXTENSIONS"),
            SPACING_MODIFIER_LETTERS
                = new UnicodeBlock("SPACING_MODIFIER_LETTERS"),
            COMBINING_DIACRITICAL_MARKS
                = new UnicodeBlock("COMBINING_DIACRITICAL_MARKS"),
            GREEK
                = new UnicodeBlock("GREEK"),
            CYRILLIC
                = new UnicodeBlock("CYRILLIC"),
            ARMENIAN
                = new UnicodeBlock("ARMENIAN"),
            HEBREW
                = new UnicodeBlock("HEBREW"),
            ARABIC
                = new UnicodeBlock("ARABIC"),
            DEVANAGARI
                = new UnicodeBlock("DEVANAGARI"),
            BENGALI
                = new UnicodeBlock("BENGALI"),
            GURMUKHI
                = new UnicodeBlock("GURMUKHI"),
            GUJARATI
                = new UnicodeBlock("GUJARATI"),
            ORIYA
                = new UnicodeBlock("ORIYA"),
            TAMIL
                = new UnicodeBlock("TAMIL"),
            TELUGU
                = new UnicodeBlock("TELUGU"),
            KANNADA
                = new UnicodeBlock("KANNADA"),
            MALAYALAM
                = new UnicodeBlock("MALAYALAM"),
            THAI
                = new UnicodeBlock("THAI"),
            LAO
                = new UnicodeBlock("LAO"),
            TIBETAN
                = new UnicodeBlock("TIBETAN"),
            GEORGIAN
                = new UnicodeBlock("GEORGIAN"),
            HANGUL_JAMO
                = new UnicodeBlock("HANGUL_JAMO"),
            LATIN_EXTENDED_ADDITIONAL
                = new UnicodeBlock("LATIN_EXTENDED_ADDITIONAL"),
            GREEK_EXTENDED
                = new UnicodeBlock("GREEK_EXTENDED"),
            GENERAL_PUNCTUATION
                = new UnicodeBlock("GENERAL_PUNCTUATION"),
            SUPERSCRIPTS_AND_SUBSCRIPTS
                = new UnicodeBlock("SUPERSCRIPTS_AND_SUBSCRIPTS"),
            CURRENCY_SYMBOLS
                = new UnicodeBlock("CURRENCY_SYMBOLS"),
            COMBINING_MARKS_FOR_SYMBOLS
                = new UnicodeBlock("COMBINING_MARKS_FOR_SYMBOLS"),
            LETTERLIKE_SYMBOLS
                = new UnicodeBlock("LETTERLIKE_SYMBOLS"),
            NUMBER_FORMS
                = new UnicodeBlock("NUMBER_FORMS"),
            ARROWS
                = new UnicodeBlock("ARROWS"),
            MATHEMATICAL_OPERATORS
                = new UnicodeBlock("MATHEMATICAL_OPERATORS"),
            MISCELLANEOUS_TECHNICAL
                = new UnicodeBlock("MISCELLANEOUS_TECHNICAL"),
            CONTROL_PICTURES
                = new UnicodeBlock("CONTROL_PICTURES"),
            OPTICAL_CHARACTER_RECOGNITION
                = new UnicodeBlock("OPTICAL_CHARACTER_RECOGNITION"),
            ENCLOSED_ALPHANUMERICS
                = new UnicodeBlock("ENCLOSED_ALPHANUMERICS"),
            BOX_DRAWING
                = new UnicodeBlock("BOX_DRAWING"),
            BLOCK_ELEMENTS
                = new UnicodeBlock("BLOCK_ELEMENTS"),
            GEOMETRIC_SHAPES
                = new UnicodeBlock("GEOMETRIC_SHAPES"),
            MISCELLANEOUS_SYMBOLS
                = new UnicodeBlock("MISCELLANEOUS_SYMBOLS"),
            DINGBATS
                = new UnicodeBlock("DINGBATS"),
            CJK_SYMBOLS_AND_PUNCTUATION
                = new UnicodeBlock("CJK_SYMBOLS_AND_PUNCTUATION"),
            HIRAGANA
                = new UnicodeBlock("HIRAGANA"),
            KATAKANA
                = new UnicodeBlock("KATAKANA"),
            BOPOMOFO
                = new UnicodeBlock("BOPOMOFO"),
            HANGUL_COMPATIBILITY_JAMO
                = new UnicodeBlock("HANGUL_COMPATIBILITY_JAMO"),
            KANBUN
                = new UnicodeBlock("KANBUN"),
            ENCLOSED_CJK_LETTERS_AND_MONTHS
                = new UnicodeBlock("ENCLOSED_CJK_LETTERS_AND_MONTHS"),
            CJK_COMPATIBILITY
                = new UnicodeBlock("CJK_COMPATIBILITY"),
            CJK_UNIFIED_IDEOGRAPHS
                = new UnicodeBlock("CJK_UNIFIED_IDEOGRAPHS"),
            HANGUL_SYLLABLES
                = new UnicodeBlock("HANGUL_SYLLABLES"),
            SURROGATES_AREA
                = new UnicodeBlock("SURROGATES_AREA"),
            PRIVATE_USE_AREA
                = new UnicodeBlock("PRIVATE_USE_AREA"),
            CJK_COMPATIBILITY_IDEOGRAPHS
                = new UnicodeBlock("CJK_COMPATIBILITY_IDEOGRAPHS"),
            ALPHABETIC_PRESENTATION_FORMS
                = new UnicodeBlock("ALPHABETIC_PRESENTATION_FORMS"),
            ARABIC_PRESENTATION_FORMS_A
                = new UnicodeBlock("ARABIC_PRESENTATION_FORMS_A"),
            COMBINING_HALF_MARKS
                = new UnicodeBlock("COMBINING_HALF_MARKS"),
            CJK_COMPATIBILITY_FORMS
                = new UnicodeBlock("CJK_COMPATIBILITY_FORMS"),
            SMALL_FORM_VARIANTS
                = new UnicodeBlock("SMALL_FORM_VARIANTS"),
            ARABIC_PRESENTATION_FORMS_B
                = new UnicodeBlock("ARABIC_PRESENTATION_FORMS_B"),
            HALFWIDTH_AND_FULLWIDTH_FORMS
                = new UnicodeBlock("HALFWIDTH_AND_FULLWIDTH_FORMS"),
            SPECIALS
                = new UnicodeBlock("SPECIALS");

	private static final char blockStarts[] = {
	    '\u0000',
	    '\u0080',
	    '\u0100',
	    '\u0180',
	    '\u0250',
	    '\u02B0',
	    '\u0300',
	    '\u0370',
	    '\u0400',
	    '\u0500', // unassigned
	    '\u0530',
	    '\u0590',
	    '\u0600',
	    '\u0700', // unassigned
	    '\u0900',
	    '\u0980',
	    '\u0A00',
	    '\u0A80',
	    '\u0B00',
	    '\u0B80',
	    '\u0C00',
	    '\u0C80',
	    '\u0D00',
	    '\u0D80', // unassigned
	    '\u0E00',
	    '\u0E80',
	    '\u0F00',
	    '\u0FC0', // unassigned
	    '\u10A0',
	    '\u1100',
	    '\u1200', // unassigned
	    '\u1E00',
	    '\u1F00',
	    '\u2000',
	    '\u2070',
	    '\u20A0',
	    '\u20D0',
	    '\u2100',
	    '\u2150',
	    '\u2190',
	    '\u2200',
	    '\u2300',
	    '\u2400',
	    '\u2440',
	    '\u2460',
	    '\u2500',
	    '\u2580',
	    '\u25A0',
	    '\u2600',
	    '\u2700',
	    '\u27C0', // unassigned
	    '\u3000',
	    '\u3040',
	    '\u30A0',
	    '\u3100',
	    '\u3130',
	    '\u3190',
	    '\u3200',
	    '\u3300',
	    '\u3400', // unassigned
	    '\u4E00',
	    '\uA000', // unassigned
	    '\uAC00',
	    '\uD7A4', // unassigned
	    '\uD800',
	    '\uE000',
	    '\uF900',
	    '\uFB00',
	    '\uFB50',
	    '\uFE00', // unassigned
	    '\uFE20',
	    '\uFE30',
	    '\uFE50',
	    '\uFE70',
	    '\uFEFF', // special
	    '\uFF00',
	    '\uFFF0'
	};

	private static final UnicodeBlock blocks[] = {
	    BASIC_LATIN,
	    LATIN_1_SUPPLEMENT,
	    LATIN_EXTENDED_A,
	    LATIN_EXTENDED_B,
	    IPA_EXTENSIONS,
	    SPACING_MODIFIER_LETTERS,
	    COMBINING_DIACRITICAL_MARKS,
	    GREEK,
	    CYRILLIC,
	    null,
	    ARMENIAN,
	    HEBREW,
	    ARABIC,
	    null,
	    DEVANAGARI,
	    BENGALI,
	    GURMUKHI,
	    GUJARATI,
	    ORIYA,
	    TAMIL,
	    TELUGU,
	    KANNADA,
	    MALAYALAM,
	    null,
	    THAI,
	    LAO,
	    TIBETAN,
	    null,
	    GEORGIAN,
	    HANGUL_JAMO,
	    null,
	    LATIN_EXTENDED_ADDITIONAL,
	    GREEK_EXTENDED,
	    GENERAL_PUNCTUATION,
	    SUPERSCRIPTS_AND_SUBSCRIPTS,
	    CURRENCY_SYMBOLS,
	    COMBINING_MARKS_FOR_SYMBOLS,
	    LETTERLIKE_SYMBOLS,
	    NUMBER_FORMS,
	    ARROWS,
	    MATHEMATICAL_OPERATORS,
	    MISCELLANEOUS_TECHNICAL,
	    CONTROL_PICTURES,
	    OPTICAL_CHARACTER_RECOGNITION,
	    ENCLOSED_ALPHANUMERICS,
	    BOX_DRAWING,
	    BLOCK_ELEMENTS,
	    GEOMETRIC_SHAPES,
	    MISCELLANEOUS_SYMBOLS,
	    DINGBATS,
	    null,
	    CJK_SYMBOLS_AND_PUNCTUATION,
	    HIRAGANA,
	    KATAKANA,
	    BOPOMOFO,
	    HANGUL_COMPATIBILITY_JAMO,
	    KANBUN,
	    ENCLOSED_CJK_LETTERS_AND_MONTHS,
	    CJK_COMPATIBILITY,
	    null,
	    CJK_UNIFIED_IDEOGRAPHS,
	    null,
	    HANGUL_SYLLABLES,
	    null,
	    SURROGATES_AREA,
	    PRIVATE_USE_AREA,
	    CJK_COMPATIBILITY_IDEOGRAPHS,
	    ALPHABETIC_PRESENTATION_FORMS,
	    ARABIC_PRESENTATION_FORMS_A,
	    null,
	    COMBINING_HALF_MARKS,
	    CJK_COMPATIBILITY_FORMS,
	    SMALL_FORM_VARIANTS,
	    ARABIC_PRESENTATION_FORMS_B,
	    SPECIALS,
	    HALFWIDTH_AND_FULLWIDTH_FORMS,
	    SPECIALS
	};

	/**
         * Returns the object representing the Unicode block containing the
         * given character, or <code>null</code> if the character is not a
         * member of a defined block.
         *
         * @param   c  The character in question
         * @return  The <code>UnicodeBlock</code> instance representing the
         *          Unicode block of which this character is a member, or
         *          <code>null</code> if the character is not a member of any
         *          Unicode block
         */
	public static UnicodeBlock of(char c) {
	    int top, bottom, current;
	    bottom = 0;
	    top = blockStarts.length;
	    current = top/2;
	    // invariant: top > current >= bottom && ch >= unicodeBlockStarts[bottom]
	    while (top - bottom > 1) {
		if (c >= blockStarts[current]) {
		    bottom = current;
		} else {
		    top = current;
		}
		current = (top + bottom) / 2;
	    }
	    return blocks[current];
	}

    }
    
    public static UnicodeBlock what(char c)
    {
        UnicodeBlock block = UnicodeBlock.of(c);
        return block;
    }
    
    public static boolean inList(char c)
    {
        UnicodeBlock block = UnicodeBlock.of(c);
        if (langList.get(block.toString())!=null) return true;
        return false;
    }
    
    
}
