package sanchez.utils;

/**
 * This type was created in VisualAge.
 */
public class ScLengthException extends sanchez.base.ScException {
/**
 * LengthException constructor comment.
 */
public ScLengthException() {
	super();
}
/**
 * LengthException constructor comment.
 * @param a_iMessageId int
 */
public ScLengthException(int a_iMessageId) {
	super(a_iMessageId);
}
/**
 * LengthException constructor comment.
 * @param a_sOtherInfo java.lang.String
 * @param a_iMessageId int
 */
public ScLengthException(String a_sOtherInfo, int a_iMessageId) {
	super(a_sOtherInfo, a_iMessageId);
}
/**
 * Returns a String that represents the value of this object.
 * @return a string representation of the receiver
 */
public String toString() {
	// Insert code to print the receiver here.
	// This implementation forwards the message to super. You may replace or supplement this.
	return super.toString();
}
}