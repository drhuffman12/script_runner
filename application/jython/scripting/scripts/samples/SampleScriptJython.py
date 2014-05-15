import scripting.core.AbstractScript
from java.lang import System as javasystem

class SampleScriptJython(scripting.core.AbstractScript):
    def __init__(self):
        javasystem.out.println("SampleScriptJython:Hello")
        scripting.core.AbstractScript.__init__(self,'SampleScriptJython')
        # AbstractScript.__init__()
        javasystem.out.println("SampleScriptJython:World")
    
    def startScriptHook(self):
        #scripting.core.AbstractScript.updateProgress(self,0,'SampleScriptJython.startScriptHook')
        
        for i in range(100):
            for j in range(40):
                scripting.core.AbstractScript.updateProgress(self,i,'SampleScriptJython.startScriptHook ... step # ' + str(i) + "," + str(j)) # + i)
        
    
    def endScriptHook(self):
        scripting.core.AbstractScript.updateProgress(self,100,'SampleScriptJython.endScriptHook')

        
    def descr(self):
         return "This is a sample Jython Script called 'SampleScriptJython'"
         
# @classmethod
    def description(self):
        return "This is a 'SampleScriptJython'"
    
# description = classmethod(description)
# description = staticmethod(description)