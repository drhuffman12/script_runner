package scripting.scripts.samples;

//import java.util.HashMap;

import java.awt.GridLayout;

import javax.swing.JCheckBox;

import scripting.core.AbstractScript;

public class SampleScriptWithOptions extends AbstractScript {

	public JCheckBox someOption;
	public JCheckBox otherOption;

	static public String description()
	{
//		return "You selected " + this.getClass().getName() + ".";
		String linebreak = AbstractScript.newline;
//		String linebreak = "\r\n";
		return "SampleScriptWithOptions:" + linebreak + linebreak + AbstractScript.description() + linebreak + linebreak + "This is an example of having additional options in the script (aside from the database and path options shown in the script runner ui).";
	}

	public SampleScriptWithOptions()
	{
//		super("SampleScriptWithOptions");
		super(null);
	}

	/*
	 * NOTE: Sub-classes should use "getParamsHook()" for getting additional parameters before running their scripts.
	 *       (Leave empty if no additional parameters are needed.)
	 */
	public void initUISettingsHook()
	{
	    this.quickstart = false; // false; // true; // i.e.: true = Hide options panel and just start running the script; false = Show options panel and require the user to click the "Start" button.
	}

	/*
	 * NOTE: Sub-classes should use "initParamsHook()" for setting additional UI parts before running their scripts.
	 *       (Leave empty if no additional parameters are needed.)
	 */
	public void initUIComponentsHook()
	{
		this.optionsPanel.setLayout(new GridLayout(2,1));
		this.someOption = new JCheckBox("some option", false);
		this.otherOption = new JCheckBox("other option", true);
		this.optionsPanel.add(this.someOption);
		this.optionsPanel.add(this.otherOption);
	}
	
	@Override
	public void startScriptHook() {
		this.updateProgress(0, this.newline + ".. this.someOption.isSelected()== " + this.someOption.isSelected());
		this.updateProgress(0, this.newline + ".. this.otherOption.isSelected()== " + this.otherOption.isSelected());
		
	}

	@Override
	public void endScriptHook() {
		this.updateProgress(100, this.newline + ".. endScriptHook()");
	}
	
} // public class SampleScriptWithOptions ...
