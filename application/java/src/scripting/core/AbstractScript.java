/**
 * 
 */
package scripting.core;

//import org.apache.log4j.Logger;

import java.util.Date;
import java.util.HashMap;

import javax.swing.JFrame;
import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.GridLayout;
import java.awt.Toolkit;

import javax.swing.JProgressBar;

import javax.swing.BorderFactory;
//import javax.swing.JLabel;
import javax.swing.JPanel;
//import javax.swing.JScrollBar;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.AdjustmentListener;
//import java.awt.event.AdjustmentEvent;
//import java.awt.event.AdjustmentListener;
//import java.awt.Adjustable;

import javax.swing.JButton;
// import javax.xml.datatype.Duration;
import javax.swing.border.Border;
import javax.swing.border.TitledBorder;

/**
 * @author  Daniel Huffman
 * @date    2011-03-21
 * @version 
 *
 * scripting.core.AbstractScript
 */
abstract public class AbstractScript extends JFrame implements ActionListener, Runnable // implements IScript 
{
  public String jframeName;
  
//  protected HashMap<String,String> fromConnParams;
//  protected HashMap<String,String> toConnParams;
//
//  protected HashMap<String,String> fromConnParamsWithoutPw;
//  protected HashMap<String,String> toConnParamsWithoutPw;
  
  public HashMap<String,String> fromConnParams;
  public HashMap<String,String> toConnParams;

  public HashMap<String,String> fromConnParamsWithoutPw;
  public HashMap<String,String> toConnParamsWithoutPw;
  
//  protected org.apache.log4j.Logger log; // .getLogger log;
  public org.apache.log4j.Logger log; // .getLogger log;
  
//  protected String myClassName;
  public String myClassName;
  
  public boolean quickstart; // i.e.: Hide options panel and just start running the script.
  protected JPanel optionsPanelHolder;
  public JPanel optionsPanel;
  public JPanel optionBtnPanel;
  public JButton startBtn;
  
  public int progressMin, progressMax, progressCurrent;
//  protected JProgressBar myProgressBar;
//  protected JScrollPane myProgressPanel;
//  protected JTextArea myProgressText;
  public JProgressBar myProgressBar;
  public JScrollPane myProgressPanel;
  public AdjustmentListener autoscroll;
  public JTextArea myProgressText;
  
  public static String newline = System.getProperty("line.separator");
  
  public String logMsg;
  
//  protected JButton cancelButton;
  public JButton cancelButton;
  

  public java.text.SimpleDateFormat dateFormatter;
  
//  protected StringBuffer tempStringBuffer;
  public StringBuffer tempStringBuffer;

    private static final int MILLISECONDS_PER_SECOND = 1000;
    private static final int MILLISECONDS_PER_MINUTE = 60 * MILLISECONDS_PER_SECOND;
//    private static final int MILLISECONDS_PER_HOUR = 60 * MILLISECONDS_PER_MINUTE;
  protected Date whenStart, whenFinish;
  //protected Duration whenDuration;
  protected long whenDuration;

  public Thread runner;
  public Thread auto_scroller;

  public String scriptStatus;
  public String scriptResults;

//  abstract static public String description();
  /*
   * This is for displaying a description in the script picker ui. 
   * Each script should customize description() as applicable.
   */
  static public String description()
  {
    return "Required initial params: (no database or path settings required)";
  }

  /*
   * This is for displaying a description in the script picker ui. 
   * Each script should customize description() as applicable.
   */
  public String descr()
  {
    return this.description();
  }
  
  /* 
   * 
   */
//  public AbstractScript(String jframeName, HashMap<String,String> fromConnParams, HashMap<String,String> toConnParams)
  //public AbstractScript(String jframeName)
  public AbstractScript(String jframeName)
  {
    super(jframeName);
//    this.fromConnParams = fromConnParams;
//    this.toConnParams = toConnParams;
    
    this.fromConnParams = new HashMap<String,String>();
    this.toConnParams = new HashMap<String,String>();
    
//    this.fromConnParamsWithoutPw = (HashMap<String,String>) this.fromConnParams.clone();
//    this.toConnParamsWithoutPw = (HashMap<String,String>) this.toConnParams.clone();
    
    this.fromConnParamsWithoutPw = new HashMap<String,String>();
    this.toConnParamsWithoutPw = new HashMap<String,String>();
    
    // title:
    this.myClassName = this.getClass().getName();
    // this.jframeName = jframeName;
    if ((null == jframeName) || ("" == jframeName))
    {
      this.jframeName = this.myClassName ;
    }
    else
    {
      this.jframeName = jframeName ;
    }
    
    // logs:
    this.log = org.apache.log4j.Logger.getLogger(myClassName);
    this.log.info(myClassName + "... in constructor");
    System.out.print(myClassName + "... in constructor");
    System.out.print(" " + this.log.getName() + " : " + this.log.toString());

      this.progressMin = 0;
      this.progressMax = 100;
      
//      this.scriptResults = '';

      this.dateFormatter = new java.text.SimpleDateFormat("yyyy-MM-dd G 'at' HH:mm:ss z");

      this.runner = new Thread(this, this.jframeName);
      // this.auto_scroller = new Thread(this, this.jframeName + "_auto_scroller");
      
//      runner.start();
      
  }

  /*
   * NOTE: Sub-classes should use "initParamsHook()" for init'ing additional UI parts before running their scripts.
   *       (Leave empty if no additional parameters are needed.)
   */
  public void initUISettingsHook()
  {
      this.quickstart = true; // i.e.: true = Hide options panel and just start running the script; false = Show options panel and require the user to click the "Start" button.
  }

  /*
   * NOTE: Sub-classes should use "initParamsHook()" for setting additional UI parts before running their scripts.
   *       (Leave empty if no additional parameters are needed.)
   */
  public void initUIComponentsHook()
  {
  }
  
  public void initUI()
  {
      this.setTitle(this.jframeName);
    // general layout:
      // this.setPreferredSize(new Dimension(400, 200));
      // this.setMaximumSize(new Dimension(100,20));
    
    // Alignment:
    Toolkit toolkit = Toolkit.getDefaultToolkit();  
    Dimension screen = toolkit.getScreenSize();
    int x , y, width, height;
    width = screen.width / 2;
    height = screen.height / 2; 
    x = width / 2;
    y = height / 2; 
    this.setLocation(x, y);
    
    // this.setBounds(x, y, width, height);
      this.setPreferredSize(new Dimension(width, height));
      this.setMaximumSize(new Dimension(width, height));
    // this.setSize(screen.width / 2, screen.height / 2);

      // Layout and form controls common to "this.quickstart" settings:
    // cancelButton:
      this.cancelButton = new JButton("Cancel");
      this.cancelButton.addActionListener(this);

      this.initUISettingsHook(); // sub-classes over-ride the default setting for "this.quickstart" via "this.initUISettingsHook()"
      // Layout and form controls dependent on "this.quickstart" settings:
      if (this.quickstart)
      {
      // optionBtnPanel: 
        this.optionBtnPanel = new JPanel();
        this.optionBtnPanel.setLayout(new GridLayout(1,1));
        this.optionBtnPanel.add(this.cancelButton);
//        this.optionsPanelHolder.add(this.optionBtnPanel, BorderLayout.PAGE_END);
        this.add(this.optionBtnPanel, BorderLayout.PAGE_END);
      }
      else
      {
      // optionsPanelFrame:
      this.optionsPanelHolder = new JPanel();
//      this.optionsPanelHolder.setLayout(new GridLayout(3,1));
      this.optionsPanelHolder.setLayout(new BorderLayout());
        this.add(this.optionsPanelHolder, BorderLayout.LINE_START);

        // optionsPanel: 
        this.optionsPanel = new JPanel();
        JPanel optionsPanelSpacer = new JPanel();
        Border blacklineBorder=BorderFactory.createLineBorder(Color.black);
        TitledBorder tb=new TitledBorder(blacklineBorder,"Options");
        this.optionsPanel.setBorder(tb);
//        this.optionsPanelHolder.add(this.optionsPanel);
        this.optionsPanelHolder.add(this.optionsPanel, BorderLayout.PAGE_START);
        this.optionsPanelHolder.add(optionsPanelSpacer, BorderLayout.CENTER);
  
        // startBtn:
          this.startBtn = new JButton("Start");
//          this.startBtn.addActionListener(new ActionListener() {
//              public void actionPerformed(ActionEvent evt) {
//                startScript();
//              }
//          });
          this.startBtn.addActionListener(new StartButtonListener(this));

        // optionBtnPanel: 
          this.optionBtnPanel = new JPanel();
          this.optionBtnPanel.setLayout(new GridLayout(1,2));
        this.optionBtnPanel.add(this.startBtn);
          this.optionBtnPanel.add(this.cancelButton);
          this.optionsPanelHolder.add(this.optionBtnPanel, BorderLayout.PAGE_END);
      }
      
    // myProgressBar:
      this.myProgressBar = new JProgressBar(this.progressMin, this.progressMax);
      this.myProgressBar.setStringPainted(true);
      this.myProgressBar.setBorderPainted(true);

    // progress info area:
      this.add(this.myProgressBar, BorderLayout.PAGE_START);
      
    this.logMsg = this.toString();
    this.log.info(this.logMsg);
      this.myProgressText = new JTextArea(this.logMsg + newline);
      this.myProgressText.setEditable(false);
      this.myProgressText.setLineWrap(true);
      this.myProgressText.setWrapStyleWord(true);
//      this.myProgressText = new JTextPane(this.logMsg + newline);
//      this.myProgressText.setEditable(false);
      
      this.myProgressPanel = new JScrollPane();
      this.myProgressPanel.add(this.myProgressText);
      
//      this.progressPanelListener = new ProgressPanelListener();
//      
//      this.myProgressPanel.getVerticalScrollBar().addAdjustmentListener(new AdjustmentListener() {
//        public void adjustmentValueChanged(AdjustmentEvent e) {
//          Adjustable adjbl = e.getAdjustable();
//          adjbl.setValue(adjbl.getMaximum()); // Keep JTextArea scrolled to end;
//            }
//      });
      
//      JScrollBar jsb = this.myProgressPanel.getVerticalScrollBar();

      this.autoscroll = new scripting.core.ScrollToEndListener();
//      this.myProgressPanel.getVerticalScrollBar().addAdjustmentListener(autoscroll);
//      this.myProgressPanel.getVerticalScrollBar().removeAdjustmentListener(autoscroll);
      
      
      this.myProgressPanel.getViewport().add(this.myProgressText);
      this.add(this.myProgressPanel,BorderLayout.CENTER);

      initUIComponentsHook();
      // Now, show it:
      this.pack();
      this.setVisible(true);
  } // public void initUI()
  
  public void startScript()
  {
      //  "Start" button to call "this.startScriptHook()" 
    this.scriptStatus = "Starting";
    this.scriptResults = null;
      this.myProgressPanel.getVerticalScrollBar().addAdjustmentListener(autoscroll);
      this.startScriptHook();
      this.endScriptHook();
      this.myProgressPanel.getVerticalScrollBar().removeAdjustmentListener(autoscroll);
    this.logEndOfScript();
  }
  
  public void run()
  {
    this.initUI();
      this.logStartOfScript();
      
      // TODO: Maybe deprecate "this.getParamsHook()"???
//      this.getParamsHook(); // Do we show 'options' panel and wait for 'Start' button, or just run the script?

      if (this.quickstart)
      {
        // "this.quickstart" can be true if we don't have any options to select, and therefore we 'auto-start' the script:
        startScript();
      }
      else
      {
        // "this.quickstart" is false, so we might have any options to select, and therefore should wait for the "Start" button to be clicked.
//        startScript();
      }
    
  } // public void run()

  public String msgPercent(double progressPercent) {
    return " % done: " + String.format("%08.4f", progressPercent) + "; at: " + this.dateFormatter.format(new Date());
  }

  public void updateProgress(int progressVal, String progressMsg) {
    java.util.Date currentTime;
    String currentTimeMsg;
    
    //this.logMsg = msg;
    if ((this.progressMin <= progressVal) && (this.progressMax >= progressVal))
    {
      currentTime = new java.util.Date();
      
      currentTimeMsg = newline + currentTime.toString() + ": " + progressMsg;
      
      this.progressCurrent = progressVal;
      this.myProgressBar.setValue(this.progressCurrent);

//      this.log.info(currentTimeMsg);
      this.log.warn(currentTimeMsg);
      this.myProgressText.append(currentTimeMsg);

      if (this.progressMax == progressVal)
      {
        this.cancelButton.setText("Exit");
      }
      else
      {
        this.cancelButton.setText("CANCEL .. " + progressVal);
      }
    }
  }
  
  /*
   * Update the progress counter, based on an array of arrays containing numerators and denominators of (sub-)counters.
   * See also:
   *   - the "countSetsHelper(..)" methods (to help Java with int[<various>][2] arrays for the counters)
   *   - the "SampleScript.java" example class (in package "scripting.scripts.samples")
   * Based on:
   *   - the "recalc_progress_by_counters(..)" jruby method (in the "Scripting::Scripts::Common::Misc" module),
   *       which doesn't require the "countSetsHelper" methods
   */
  public void recalcProgressByCounters(int[][] countSets)
  {
    this.progressCurrent = 0;
    int countSetsQty = countSets.length;
    int[] countSet = new int[countSetsQty];
    double numerator = 0.0;
    double denominator = 1.0;
    double prev_denominator = 1.0;
    double[] ratios = new double[countSetsQty];
    double ratio_sum = 0.0;
    // for (int[] countSet : countSets)
    for (int i = 0; i < countSetsQty; i++)
    {
      countSet = countSets[i];
      numerator = countSet[0];
      denominator = countSet[1] * prev_denominator;
      prev_denominator = denominator;
      ratios[i] = numerator / denominator;
    }

    // ratio_sum = 0.0
    for (double r : ratios)
    {
      ratio_sum += r;
    }
    
    this.progressCurrent = (int) (100.0 * ratio_sum);
  }

  // countSets = myCountSetsHelper(a1, a2);
  public int[][] countSetsHelper(int a1, int a2)
  {
    int[][] countSets = new int[1][2]; // {{a1,a2}};
    
    countSets[0][0] = a1; 
    countSets[0][1] = a2;
    
    return countSets; 
  }

  // countSets = myCountSetsHelper(a1, a2, b1, b2);
  public int[][] countSetsHelper(int a1, int a2, int b1, int b2)
  {
    int[][] countSets = new int[2][2]; // {{a1,a2},{b1,b2}};
    
    countSets[0][0] = a1; 
    countSets[0][1] = a2;
    countSets[1][0] = b1;
    countSets[1][1] = b2;
    
    return countSets; 
  }

  // countSets = myCountSetsHelper(a1, a2, b1, b2, c1, c2);
  public int[][] countSetsHelper(int a1, int a2, int b1, int b2, int c1, int c2)
  {
    int[][] countSets = new int[3][2]; // {{a1,a2},{b1,b2},{c1,c2}};
    
    countSets[0][0] = a1; 
    countSets[0][1] = a2;
    countSets[1][0] = b1;
    countSets[1][1] = b2;
    countSets[2][0] = c1;
    countSets[2][1] = c2;
    
    return countSets; 
  }

  // countSets = myCountSetsHelper(a1, a2, b1, b2, c1, c2);
  public int[][] countSetsHelper(int a1, int a2, int b1, int b2, int c1, int c2, int d1, int d2)
  {
    int[][] countSets = new int[4][2]; // {{a1,a2},{b1,b2},{c1,c2},{d1,d2}};
    
    countSets[0][0] = a1; 
    countSets[0][1] = a2;
    countSets[1][0] = b1;
    countSets[1][1] = b2;
    countSets[2][0] = c1;
    countSets[2][1] = c2;
    countSets[3][0] = d1;
    countSets[3][1] = d2;
    
    return countSets; 
  }

  @Override
  public String toString()
  {
    tempStringBuffer = new StringBuffer("");
    tempStringBuffer.append(this.myClassName + "(");
    tempStringBuffer.append("'" + this.jframeName + "'");
    tempStringBuffer.append(", ");
    tempStringBuffer.append("{" + this.fromConnParamsWithoutPw.toString() + "}"); // NOTE: we exclude the 'password' k/v combo here!
    tempStringBuffer.append(", ");
    tempStringBuffer.append("{" + this.toConnParamsWithoutPw.toString() + "}"); // NOTE: we exclude the 'password' k/v combo here!
    tempStringBuffer.append(")");
    tempStringBuffer.append("): " + this.msgPercent((1.0*this.progressCurrent)/100.0));
    return tempStringBuffer.toString();
  }

  /* 
   * 
   */
  public void actionPerformed(ActionEvent e) {
    this.runner.interrupt();
    this.updateProgress(this.progressCurrent, this.myClassName + " was CANCELLED!");
    this.endScriptHook();
    this.logEndOfScript();
//    this.runner.stop();
    this.dispose();
  }
  
  public String simpleStatusTimestamp(String statusMsg, Date statusTimestamp)
  {
    return this.myClassName + ": " + statusMsg + " at: " + this.dateFormatter.format(statusTimestamp);
  }
  
  public void logStartOfScript() {
    // TODO Auto-generated method stub
    this.whenStart = new Date();
    // this.progressCurrent = 0;
    this.updateProgress(0, this.simpleStatusTimestamp("STARTING", this.whenStart));
    //this.updateProgress(0, this.myClassName + ": STARTING.");
    
//    startScriptMain();
//    run();
  }

//  public void startScriptMain()
//  {
//    // Do something then method should end with call to "endScriptCleanup()";
//  }

//  /*
//   * NOTE: Sub-classes should use "getParamsHook()" for getting additional parameters before running their scripts.
//   *       (Leave empty if no additional parameters are needed.)
//   */
//  public void getParamsHook()
//  {
////      this.quickstart = false; // i.e.: true = Hide options panel and just start running the script; false = Show options panel and require the user to click the "Start" button.
//  }
  

//  public boolean waitingOnParamsHook()
//  {
//    return true;
//  }

  /*
   * NOTE: Sub-classes should use "startScriptHook()" for running their scripts.
   * e.g.: 
   *   // Do something then update progress bar:
   *   someScriptMethod();
   *   updateProgress(someProgressVal, someProgressMsg);
   */
  abstract public void startScriptHook();

  /*
   * NOTE: Sub-classes should use "endScriptHook()" for ending their scripts.
   * Use this method to close any db connections and file handles.
   */
  abstract public void endScriptHook();
  
  public void logEndOfScript() {
    this.whenFinish = new Date();
    this.whenDuration = (this.whenFinish.getTime() - this.whenStart.getTime()); //this.whenFinish - this.whenStart;

    this.updateProgress(this.progressCurrent, this.simpleStatusTimestamp("FINISHED", this.whenFinish));
//    this.updateProgress(this.progressCurrent, "Duration was " + this.whenDuration * 1.0 / this.MILLISECONDS_PER_MINUTE + " minutes");
    this.updateProgress(this.progressCurrent, "Duration was " + this.whenDuration * 1.0 / AbstractScript.MILLISECONDS_PER_MINUTE + " minutes");
  }
  
  
  public void runForConnParams(HashMap<String,String> fromConnParams, HashMap<String,String> toConnParams)
  {
    this.scriptStatus = null;
    this.scriptResults = null;
    this.log.warn("");
    this.log.warn("jframeName     == " + this.jframeName);
    
    this.log.warn("runForConnParams(...) .. beginning");
    this.fromConnParams = fromConnParams;
    this.toConnParams = toConnParams;

//    this.log.warn("runForConnParams(...) .. fromConnParams == " + fromConnParams.toString());
//    this.log.warn("runForConnParams(...) .. toConnParams == " + toConnParams.toString());
    
//    this.fromConnParamsWithoutPw = (HashMap<String,String>) this.fromConnParams.clone();
//    this.toConnParamsWithoutPw = (HashMap<String,String>) this.toConnParams.clone();

    this.fromConnParamsWithoutPw = (HashMap<String,String>) fromConnParams.clone();
    this.toConnParamsWithoutPw = (HashMap<String,String>) toConnParams.clone();

//    this.fromConnParamsWithoutPw.remove("password");
//    this.toConnParamsWithoutPw.remove("password");
    
    this.fromConnParamsWithoutPw.put("password", "********"); // .remove("password");
    this.toConnParamsWithoutPw.put("password", "********"); // remove("password");
    
    this.log.warn("runForConnParams(...) .. fromConnParams == " + fromConnParamsWithoutPw.toString());
    this.log.warn("runForConnParams(...) .. toConnParams == " + toConnParamsWithoutPw.toString());
    
    this.log.warn("runForConnParams(...) .. runner.start();");

      runner.start();
    this.log.warn("runForConnParams(...) .. ending");
  } // public void runForConnParams(...)

} // abstract public class AbstractScript ...
