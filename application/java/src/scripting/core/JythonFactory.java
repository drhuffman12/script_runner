package scripting.core;

import java.util.HashMap;
import java.util.Properties;

import org.python.util.PythonInterpreter;

/* 
 * See "Accessing Jython from Java Without Using jythonc" 
 *   at "http://wiki.python.org/jython/JythonMonthly/Articles/September2006/1"
 */
public class JythonFactory
{
	private static JythonFactory instance = null;

	public synchronized static JythonFactory getInstance()
	{
		if (instance == null)
		{
			instance = new JythonFactory();
		}

		return instance;
	} // public synchronized static JythonFactory getInstance()

//	public static Object getJythonObject(String interfaceName, String pathToJythonModule)
    // TODO: refactor "pythonFactoryClassPath" as something like "javaBinPkgRootForJythonFactoryClass"
	public Object getJythonObject(String pythonFactoryClassPath, String interfaceName, String pathToJythonModule)
	{
		System.out.println("getJythonObject(...): START" );
		System.out.println("  pythonPath                   == '" + pythonFactoryClassPath + "'" );
		System.out.println("  interfaceName                == '" + interfaceName + "'" );
		System.out.println("  pathToJythonModule           == '" + pathToJythonModule + "'" );
		System.out.println("  AbstractScript.description() == '" + AbstractScript.description() + "'");
		
		// "http://www.jython.org/archive/22/userfaq.html#how-can-i-use-jython-classes-from-my-java-application"
		Properties props = new Properties();
		props.setProperty("python.path", pythonFactoryClassPath);
		PythonInterpreter.initialize(System.getProperties(), props,
		                             new String[] {""});

		System.out.println("getJythonObject(...): MID 1" );
		// "http://wiki.python.org/jython/JythonMonthly/Articles/September2006/1"
		Object javaInt = null;
		PythonInterpreter interpreter = new PythonInterpreter();
		System.out.println("getJythonObject(...): MID 1a" );
		interpreter.execfile(pathToJythonModule);
		System.out.println("getJythonObject(...): MID 1b" );
		String tempName = pathToJythonModule.substring(pathToJythonModule.lastIndexOf("/") + 1);
		System.out.println("getJythonObject(...): MID 1c" );
		tempName = tempName.substring(0, tempName.indexOf("."));
		System.out.println("getJythonObject(...): MID 2" );
		System.out.println("tempName == " + tempName);
		String instanceName = tempName.toLowerCase();
		String javaClassName = tempName.substring(0, 1).toUpperCase()
				+ tempName.substring(1);
		String objectDef = "=" + javaClassName + "()";
		System.out.println("getJythonObject(...): MID 3" );
		interpreter.exec(instanceName + objectDef);
		try
		{
			System.out.println("getJythonObject(...): MID 4" );
			Class JavaInterface = Class.forName(interfaceName);
			javaInt = interpreter.get(instanceName).__tojava__(JavaInterface);
			System.out.println("getJythonObject(...): MID 5" );
		}
		catch (ClassNotFoundException ex)
		{
			ex.printStackTrace(); // Add logging here
		}
		
		System.out.println("getJythonObject(...): END" );
		return javaInt;
	} // public static Object getJythonObject(...)
	

    
    /**
     * @param args the command line arguments
     * 
     * scripting.core.JythonFactory.main()
     */
    public static void main(String[] args) {
        JythonFactory jf = JythonFactory.getInstance();
        String pythonPath = ".";
        String javaClassName = "scripting.core.AbstractScript";
//        String jythonFileName = "SampleScriptJython.py";
        String jythonFileName = "jython/scripting/scripts/samples/SampleScriptJython.py";
        AbstractScript jythonScript = (AbstractScript) jf.getJythonObject(pythonPath, javaClassName, jythonFileName);
        System.out.println("Launching Jython Class: " + jythonFileName + " ...");

		HashMap<String, String> fromConnParams = new HashMap<String, String>();
		HashMap<String, String> toConnParams = new HashMap<String, String>();

		fromConnParams.put("foo", "bar");
		toConnParams.put("widget", "builder");
		
        jythonScript.runForConnParams(fromConnParams, toConnParams);
        System.out.println("... Done.");
        
    }
    
    public void runAbstractScript(String pythonFactoryClassPath, String jythonFileName, HashMap<String, String> fromConnParams, HashMap<String, String> toConnParams)
    {
        JythonFactory jf = JythonFactory.getInstance();
//        String pythonPath = ".";
        String javaClassName = "scripting.core.AbstractScript";
//        String jythonFileName = "SampleScriptJython.py";
//        String jythonFileName = "jython/scripting/scripts/samples/SampleScriptJython.py";
        System.out.println("Getting Jython Class from Java: '" + jythonFileName + "' ...");
        AbstractScript jythonScript = (AbstractScript) jf.getJythonObject(pythonFactoryClassPath, javaClassName, jythonFileName);
        System.out.println("Launching Jython Class from Java: '" + jythonFileName + "' ...");

//		HashMap<String, String> fromConnParams = new HashMap<String, String>();
//		HashMap<String, String> toConnParams = new HashMap<String, String>();

//		fromConnParams.put("foo", "bar");
//		toConnParams.put("widget", "builder");
		
        jythonScript.runForConnParams(fromConnParams, toConnParams);
        System.out.println("... Done from Java.");
    	
    }
	
} // public class JythonFactory