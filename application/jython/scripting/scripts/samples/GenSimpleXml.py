# ** Filename: gen_simple_xml.py

# import sys
import sys, traceback
import java
import scripting.core.AbstractScript
from java.lang import System as javasystem
# from com.ibm.websphere.management.exception import AdminException
# from com.ibm.ws.scripting import ScriptingException

class GenSimpleXml(scripting.core.AbstractScript):
  # class GenSimpleXml(scripting.core.AbstractScript):
  # class GenSimpleXml(object):
  
  def __init__(self):
    javasystem.out.println("GenSimpleXml:Hello")
    scripting.core.AbstractScript.__init__(self,'GenSimpleXml')
    # AbstractScript.__init__()
    javasystem.out.println("GenSimpleXml:World")
    self.return_msg_results_list = []
    self.return_msg_error_list = []
    self.indent_size = 2
    # get_cells()
  # end -- def __init__
  
  def startScriptHook(self):
    scripting.core.AbstractScript.updateProgress(self,0,'GenSimpleXml.startScriptHook')
    scripting.core.AbstractScript.updateProgress(self,50,self.get_cells())
  # end -- def startScriptHook
     
  def endScriptHook(self):
     scripting.core.AbstractScript.updateProgress(self,100,'GenSimpleXml.endScriptHook')
  # end -- def endScriptHook

  def descr(self):
       return "This is a sample Jython Script called 'GenSimpleXml'"
  # end -- def descr
       
  ## @classmethod
  def description():
      return "This is a 'GenSimpleXml'"
  # end -- def description
  
  # description = classmethod(description)
  # description = staticmethod(description)
  
  def get_error_info(self, indent_level , section_name):
    return_str_arr = [""]
    return_str = ""
    return_str_arr.append(self.get_indent_chars(indent_level))
    return_str_arr.append("<error>")
    return_str_arr.append(self.get_indent_chars(indent_level))
    return_str_arr.append("<" + section_name + ">")
    error_type, error_value, tb = sys.exc_info()
    print "error_type:"
    print error_type, type(error_type)
    print "error_value:"
    print error_value, type(error_value)
    print "line:"
    print traceback.tb_lineno(tb)
    print "error (filename, line number, function, statement, value):"
    print traceback.extract_tb(tb)
    # print "message:"
    # print error_value.message
    print "-----------------------------------------"
    return_str_arr.append(self.get_indent_chars(indent_level))
    return_str_arr.append("</" + section_name + ">")
    return_str_arr.append(self.get_indent_chars(indent_level))
    return_str_arr.append("</error>")
    
    return_str = "".join(return_str_arr)
    return return_str

  # get_indent_chars(indent_level)
  def get_indent_chars(self,indent_level):
    return_str = ""
    try:
      return_str = ' ' * indent_level * self.indent_size
    except (Exception): 
      print "-----------------------------------------"
      print "ERROR in get_indent_chars()" 
      self.get_error_info()
      
    # return_str = "".join(return_str_arr)
    return "\n" +return_str
  # end -- def get_indent_chars
  
  # e.g.: assuming 'self.indent_size == 2', then:
  # get_tag(1,0,'foo') => "\n  <foo>"
  # get_tag(1,1,'foo') => "\n  </foo>"
  def get_tag(self,indent_level,is_end_tag,tag_name):
    return_str_arr = [""]
    return_str_arr.append(self.get_indent_chars(indent_level))
    return_str_arr.append("<")
    if (1 == is_end_tag):
      return_str_arr.append("/")
    return_str_arr.append(tag_name)
    return_str_arr.append(">")
    return "".join(return_str_arr)
    
  def  get_cells(self):
    return_str_arr = [""]
    indent_level = 0
    
    # return_str_arr.append(self.get_indent_chars(indent_level))
    # return_str_arr.append("<cells>")
    return_str_arr.append(self.get_tag(indent_level,0,'cells'))
    try:
      return_str_arr.append(self.get_nodes(indent_level + 1,"a cell"))
                      # print "debug 1a"
                      # print "debug 1b"
                      # print "debug 2"
                      # print "debug 3"
                      # print "debug 4"
    except (Exception): 
      print "-----------------------------------------"
      print "ERROR in get_cells()" 
      self.get_error_info(indent_level + 1, section_name)
    return_str_arr.append(self.get_tag(indent_level,1,'cells'))
      
    return "".join(return_str_arr)
  # end -- def get_cells
    
  def get_nodes(self,indent_level,cell):
    return_str_arr = [""]
    
    return_str_arr.append(self.get_tag(indent_level,0,'nodes'))
    try:
      return_str_arr.append(self.get_servers(indent_level + 1,"a cell","a node"))
    except (Exception):
      print "-----------------------------------------"
      print "ERROR in get_nodes()" 
      self.get_error_info()
    return_str_arr.append(self.get_tag(indent_level,1,'nodes'))
      
    return "".join(return_str_arr)

  def get_servers(self,indent_level,cell,node):
    return_str_arr = [""]
    
    return_str_arr.append(self.get_tag(indent_level,0,'servers'))
    try:
      return_str_arr.append(self.get_server_info(indent_level + 1,"a cell","a node","a server"))
    except (Exception): 
      print "-----------------------------------------"
      print "ERROR in get_servers()" 
      self.get_error_info()
    return_str_arr.append(self.get_tag(indent_level,1,'servers'))
      
    return "".join(return_str_arr)
  # end -- def get_servers

  def get_server_info(self,indent_level,cell,node,server):
    return_str_arr = [""]
    
    return_str_arr.append(self.get_tag(indent_level,0,'server-info'))
    try:
      return_str_arr.append(self.get_indent_chars(indent_level + 1))
      return_str_arr.append("some info")
    except (Exception): 
      print "-----------------------------------------"
      print "ERROR in get_server_info()" 
      self.get_error_info()
    return_str_arr.append(self.get_tag(indent_level,1,'server-info'))
      
    return "".join(return_str_arr)
  # end -- def get_server_info

# end -- class GenSimpleXml(scripting.core.AbstractScript):

# gni = GenSimpleXml()
# print gni.get_cells()