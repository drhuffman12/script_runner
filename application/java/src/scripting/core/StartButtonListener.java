package scripting.core;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class StartButtonListener implements ActionListener {
	
	public AbstractScript aScript;
	
	public StartButtonListener(AbstractScript aScript)
	{
		this.aScript = aScript;		
	}

    public void actionPerformed(ActionEvent evt) {
    	this.aScript.startScript();
    }

}
