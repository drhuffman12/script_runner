package scripting.scripts.samples;

//import java.util.HashMap;

import scripting.core.AbstractScript;

public class EmptyScript extends AbstractScript {

	static public String description()
	{
//		return "You selected " + this.getClass().getName() + ".";
		String linebreak = AbstractScript.newline;
//		String linebreak = "\r\n";
		return "EmptyScript:" + linebreak + linebreak + AbstractScript.description() + linebreak + linebreak + "This is a minimal sample script that basically does nothing (aka 'empty').";
	}

	public EmptyScript()
	{
//		super("EmptyScript");
		super(null);
	}

	/*
	 * NOTE: Sub-classes should use "getParamsHook()" for getting additional parameters before running their scripts.
	 *       (Leave empty if no additional parameters are needed.)
	 */
	public void initUISettingsHook()
	{
	    this.quickstart = true; // false; // true; // i.e.: true = Hide options panel and just start running the script; false = Show options panel and require the user to click the "Start" button.
	}
	
	@Override
	public void startScriptHook() {
		this.updateProgress(0, this.newline + ".. startScriptHook()");
	}

	@Override
	public void endScriptHook() {
		this.updateProgress(100, this.newline + ".. endScriptHook()");
	}

}
