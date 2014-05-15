package scripting.scripts.samples;

import java.util.HashMap;

import scripting.core.AbstractScript;

public class SampleScript extends AbstractScript {

	static public String description()
	{
//		return "You selected " + this.getClass().getName() + ".";
		String linebreak = AbstractScript.newline;
//		String linebreak = "\r\n";
		return "SampleScript:" + linebreak + linebreak + AbstractScript.description() + linebreak + linebreak + "This will display the connection options (database and path) entered in the script runner ui (with the password hidden) and add a bunch of lines of dummy text.";
	}

	public SampleScript()
	{
//		super("SampleScript");
		super(null);
	}

	@Override
	public void startScriptHook() {
		String progMsgPrefix = "startScriptHook()";
		this.updateProgress(this.progressCurrent, progMsgPrefix + " ... FINISHED");
		/*
		 * We don't really need 'try-catch' blocks, but we include for sake of example. Here we have:
		 *   (a) We have three loops; one loop inside the other, so we will count up to an int[3][2] array.
		 *   (b) For the 1st loop, we are on part u of v.
		 *   (c) For the 2nd loop, we are on part w of x.
		 *   (c) For the 3rd loop, we are on part y of z.
		 *   (d) We re-calculate the progress counter with code like:
		 *         recalcProgressByCounters(countSetsHelper(u, v, w, x, y, z));
		 */
		try {
			this.updateProgress(0, progMsgPrefix + ".. this.fromConnParamsWithoutPw == " + this.fromConnParamsWithoutPw.toString());
			this.updateProgress(0, progMsgPrefix + ".. this.toConnParamsWithoutPw   == " + this.toConnParamsWithoutPw.toString());
			long millis = 10; // 1000;

			for (int u = 0, v = 10 ; u < v; u++)
			{
				try {
					recalcProgressByCounters(countSetsHelper(u, v));
					this.updateProgress(this.progressCurrent, progMsgPrefix + "this.progressCurrent == " + this.progressCurrent + " @ 1st level, step " + u + " of " + v); // this.newline
					for (int w = 0, x = 2 ; w < x; w++)
					{
						try {
							recalcProgressByCounters(countSetsHelper(u, v, w, x));
							this.updateProgress(this.progressCurrent, progMsgPrefix + "this.progressCurrent == " + this.progressCurrent + " @ .. 2nd level, step " + w + " of " + x);
							for (int y = 0, z = 5; y < z; y++)
							{
								try {
									recalcProgressByCounters(countSetsHelper(u, v, w, x, y, z));
									this.updateProgress(this.progressCurrent, progMsgPrefix + "this.progressCurrent == " + this.progressCurrent + " @ .. .. 3rd level, step " + y + " of " + z);
									this.runner.sleep(millis); // i.e.: Do something.
								} catch (InterruptedException e) {
									// TODO Auto-generated catch block
									e.printStackTrace();
								}
							}
						} catch (Exception e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
					}
				} catch (Exception e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		this.updateProgress(this.progressCurrent, progMsgPrefix + " ... FINISHED");
	}

	@Override
	public void endScriptHook() {
		this.updateProgress(100, this.newline + ".. endScriptHook()");
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		HashMap<String, String> fromConnParams = new HashMap<String, String>();
		HashMap<String, String> toConnParams = new HashMap<String, String>();

		fromConnParams.put("foo", "bar");
		toConnParams.put("widget", "builder");
		
		SampleScript ss = new SampleScript();
		ss.runForConnParams(fromConnParams, toConnParams);
		
	}

}
