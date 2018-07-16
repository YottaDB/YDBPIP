package sanchez.base;

import java.text.MessageFormat;
import java.util.Locale;
import java.util.MissingResourceException;
import java.util.ResourceBundle;

/**
 * Resource bundles contain key/value pairs. The keys uniquely
 * identify a locale-specific object in the bundle.
 * This class is to load the Resource.properties file.
 * 
 * 
 * @author SMohana1
 * 
 */

public class ScBundle {

	static ResourceBundle labels = null;

	/**
	 * This method is to load the property file
	 * 
	 * @throws MissingResourceException
	 */
	public static void loadProperty() throws MissingResourceException {
		labels = ResourceBundle.getBundle("Resource", Locale.getDefault());
	}

	/**
	 * Returns a String value for the given key from the ResourceBundle.
	 * 
	 * @param key the keystring to retrieve
	 * @return the value for the given key 
	 * @throws MissingResourceException
	 */
	public static String getMessage(String key) throws MissingResourceException {

		return labels.getString(key);
	}

	/**
	 * Returns the formatted String with the given arguments from the ResourceBundle.
	 * 
	 * @param key the keystring on which to apply arguments
	 * @param placeValues the object arguments for the formatter
	 * @return the formatted string
	 * @throws MissingResourceException
	 */
	public static String getMessage(String key, Object[] placeValues)
			throws MissingResourceException {
		String str = labels.getString(key);
		MessageFormat form = new MessageFormat(str);
		return form.format(placeValues);

	}
}
