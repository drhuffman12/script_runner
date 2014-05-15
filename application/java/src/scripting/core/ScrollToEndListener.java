package scripting.core;

import java.awt.Adjustable;
import java.awt.event.AdjustmentEvent;
import java.awt.event.AdjustmentListener;

public class ScrollToEndListener implements AdjustmentListener
{
	/*
	// public JProgressBar progressBar
	public ProgressPanelListener() // (JProgressBar progressBar)
	{
		// this.progressBar = progressBar;
	}
	*/
	
	public void adjustmentValueChanged(AdjustmentEvent e) {
		Adjustable adjbl = e.getAdjustable();
		adjbl.setValue(adjbl.getMaximum()); // Keep JTextArea scrolled to end;
      }
}
