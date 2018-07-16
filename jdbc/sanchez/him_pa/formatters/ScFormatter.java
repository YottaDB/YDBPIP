package sanchez.him_pa.formatters;

import sanchez.base.ScObject;


public abstract class ScFormatter extends ScObject
{
	private String sbFormattedSendMessage;

	public String getFormattedMessage() {
		return sbFormattedSendMessage;
	}
	protected void setFormattedMessage(String psbBuffer) {
		sbFormattedSendMessage = psbBuffer;
	}
}