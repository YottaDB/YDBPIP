package sanchez.security;

import sanchez.base.ScObject;

/**
 * This object encapsulates all the user information retrieved from the GAEA database. 
 * This object will be saved by the App Object and might be passed around to the HIM's 
 * for host connectivity.
 * @author Saurin Shah
 */
public class ScUIO extends ScObject {
	private String i_sUserID;
	private String i_sPassword;
	private String i_sUserClass;
	private String i_sCertificate;
	private String i_sPublicKey;
	private String i_sPrivateKey;
	private String i_sCustomerID;
	/* VS - added 05/28/99 */ 
	private String i_sFullName;

	/**
	 * This consctructor creates a valid object
	 */
	public ScUIO() {
	}
	/**
	 * This method gets the Certificate
	 * @return String                   is the certificate.
	 */
	public String getCertificate() {
		return i_sCertificate;
	}
	/**
	 * This method gets the customer id
	 * @return String                   is the customer id.
	 */
	public String getCustomerID () {
		return i_sCustomerID;
	}
    /**
    * This method returns the Full Name of the user.
    *@return String                     is the full name.
    */
    public String getFullName () {
		    return i_sFullName;
	    }
	/**
	 * This method gets the password
	 * @return String                   is the password.
	 */
	public String getPassword() {
		return i_sPassword;
	}
	/**
	 * This method gets the private key
	 * @return String                   is the private key
	 */
	public String getPrivateKey() {
		return i_sPrivateKey;
	}
	/**
	 * This method gets the public key
	 * @return String                   is the public key.
	 */
	public String getPublicKey() {
		return i_sPublicKey;
	}
	/**
	 * This method gets the user class
	 * @return String                   is the user class.
	 */
	public String getUserClass() {
		return i_sUserClass;
	}
	/**
	 * This method gets the user id
	 * @return String                   is the user id.
	 */
	public String getUserID() {
		return i_sUserID;
	}
	/**
	 * This method sets the certificate
	 * @param a_sCertificate            is the new Certificate.
	 */
	public void setCertificate(String a_sCertificate) {
		i_sCertificate = a_sCertificate;
	}
	/**
	 * This method sets the customer id
	 * @param a_sCustomerID             is the new customer id
	 */
	public void setCustomerID(String a_sCustomerID) {
		i_sCustomerID = a_sCustomerID;
	}
    /**
    * This method sets the Full Name attribute.
    * @param a_sFullName                is the new full name.
    */
    public void setFullName(String a_sFullName) {
		    i_sFullName = a_sFullName;
	    }
	/**
	 * This method sets the password
	 * @param a_sPassword               is the new password
	 */
	public void setPassword(String a_sPassword) {
		i_sPassword = a_sPassword;
	}
	/**
	 * This method sets the private key
	 * @param a_sPrivateKey             is the new private key
	 */
	public void setPrivateKey(String a_sPrivateKey) {
		i_sPrivateKey = a_sPrivateKey;
	}
	/**
	 * This method sets the public key
	 * @param a_sPublicKey              is the new public key
	 */
	public void setPublicKey(String a_sPublicKey) {
		i_sPublicKey = a_sPublicKey;
	}
	/**
	 * This method sets the user class
	 * @param a_sUserClass              is the new user class
	 */
	public void setUserClass(String a_sUserClass) {
		i_sUserClass = a_sUserClass;
	}
	/**
	 * This method sets the user id
	 * @param a_sUserID                 is the new user id
	 */
	public void setUserID(String a_sUserID) {
		i_sUserID = a_sUserID;
	}
}