# ** Filename: get_node_info.py

# import sys
import sys, traceback
import java
# import scripting.core.AbstractScript
from java.lang import System as javasystem
# from com.ibm.websphere.management.exception import AdminException
# from com.ibm.ws.scripting import ScriptingException

lineSeparator = java.lang.System.getProperty('line.separator')

class GetNodeInfo:
  # class GetNodeInfo(scripting.core.AbstractScript):
  # class GetNodeInfo(object):
  
  
  #    def startScriptHook(self):
  #        #scripting.core.AbstractScript.updateProgress(self,0,'GetNodeInfo.startScriptHook')
  #        for i in range(100):
  #            for j in range(40):
  #                scripting.core.AbstractScript.updateProgress(self,i,'GetNodeInfo.startScriptHook ... step # ' + str(i) + "," + str(j)) # + i)
  #    # end -- def startScriptHook
  #        
  #    def endScriptHook(self):
  #        scripting.core.AbstractScript.updateProgress(self,100,'GetNodeInfo.endScriptHook')
  #    # end -- def endScriptHook
  #
  #    def descr(self):
  #         return "This is a sample Jython Script called 'GetNodeInfo'"
  #    # end -- def descr
  #         
  ## @classmethod
  #    def description():
  #        return "This is a 'GetNodeInfo'"
  #    # end -- def description
  #    
  # description = classmethod(description)
  # description = staticmethod(description)

  def __init__(self):
    # javasystem.out.println("GetNodeInfo:Hello")
    # scripting.core.AbstractScript.__init__(self,'GetNodeInfo')
    # AbstractScript.__init__()
    self.indent_size = 2
    # javasystem.out.println("GetNodeInfo:World")
    # get_cells()
  # end -- def __init__

  # get_indent_chars(indent_level)
  def get_indent_chars(self,indent_level,prepend_with_newline = 1):
    return_str_arr = [""]
    # return_str = ""
    try:
      if (prepend_with_newline == 1):
        return_str_arr.append("\n")
      # return_str = ' ' * indent_level * self.indent_size
      return_str_arr.append(' ' * indent_level * self.indent_size)
    except (Exception): 
      # print "-----------------------------------------"
      # print "ERROR in get_indent_chars()" 
      # self.get_error_info()
      error_type, error_value, tb = sys.exc_info()
      # print "error_type:"
      # print error_type, type(error_type)
      # print "error_value:"
      # print error_value, type(error_value)
      # print "line:"
      # print traceback.tb_lineno(tb)
      # print "error (filename, line number, function, statement, value):"
      # print traceback.extract_tb(tb)
      # # print "message:"
      # # print error_value.message
      # print "-----------------------------------------"
      
    # return_str = "".join(return_str_arr)
    # return "\n" +return_str
    return "".join(return_str_arr)
  # end -- def get_indent_chars
  
  # e.g.: assuming 'self.indent_size == 2', then:
  # get_tag(1,0,'foo') => "\n  <foo>"
  # get_tag(1,1,'foo') => "\n  </foo>"
  def get_tag(self,indent_level,is_end_tag,tag_name,prepend_with_newline = 1):
    return_str_arr = [""]
    return_str_arr.append(self.get_indent_chars(indent_level,prepend_with_newline))
    return_str_arr.append("<")
    if (1 == is_end_tag):
      return_str_arr.append("/")
    return_str_arr.append(tag_name)
    return_str_arr.append(">")
    return "".join(return_str_arr)
  
  def get_error_info(self, indent_level , section_name):
    return_str_arr = [""]
    indent_level_delta = 0
    
    return_str_arr.append(self.get_tag(indent_level,0,'error'))
  
    indent_level_delta += 1
    return_str_arr.append(self.get_tag(indent_level + 1,0,section_name))
  
    indent_level_delta += 1
    error_type, error_value, tb = sys.exc_info()
    return_str_arr.append(self.get_tag(indent_level + 2,0,'error-type'))
    return_str_arr.append(str(type(error_type)))
    return_str_arr.append(self.get_tag(0,1,'error-type',0))
    
    return_str_arr.append(self.get_tag(indent_level + 2,0,'error-value'))
    return_str_arr.append(str(type(error_value)))
    return_str_arr.append(self.get_tag(0,1,'error-value',0))
    
    return_str_arr.append(self.get_tag(indent_level + 2,0,'line'))
    return_str_arr.append(str(traceback.tb_lineno(tb)))
    return_str_arr.append(self.get_tag(0,1,'line',0))
    
    
    return_str_arr.append(self.get_tag(indent_level + 2,0,'traceback'))
    err_tb_arr = traceback.extract_tb(tb)
    for err_tb in err_tb_arr:
      indent_level_delta += 1
      err_tb_len = len(err_tb)
      err_filename = ''
      err_linenum = ''
      err_function = ''
      err_statement = ''
      err_value = ''
      if (err_tb_len > 0):
        err_filename = str(err_tb[0])
      if (err_tb_len > 1):
        err_linenum = str(err_tb[1])
      if (err_tb_len > 2):
        err_function = str(err_tb[2])
      if (err_tb_len > 3):
        err_statement = str(err_tb[3])
      if (err_tb_len > 4):
        err_value = str(err_tb[4])
      
      return_str_arr.append(self.get_tag(indent_level + indent_level_delta,0,'filename'))
      return_str_arr.append(str(err_filename))
      return_str_arr.append(self.get_tag(0,1,'filename',0))
      
      return_str_arr.append(self.get_tag(indent_level + indent_level_delta,0,'linenum'))
      return_str_arr.append(str(err_linenum))
      return_str_arr.append(self.get_tag(0,1,'linenum',0))
      
      return_str_arr.append(self.get_tag(indent_level + indent_level_delta,0,'function'))
      return_str_arr.append(str(err_function))
      return_str_arr.append(self.get_tag(0,1,'function',0))
      
      return_str_arr.append(self.get_tag(indent_level + indent_level_delta,0,'statement'))
      return_str_arr.append(str(err_statement))
      return_str_arr.append(self.get_tag(0,1,'statement',0))
      
      return_str_arr.append(self.get_tag(indent_level + indent_level_delta,0,'value'))
      return_str_arr.append(str(err_value))
      return_str_arr.append(self.get_tag(0,1,'value',0))
    # end -- for err_tb in err_tb_arr:
    indent_level_delta -= 1
    return_str_arr.append(self.get_tag(indent_level + indent_level_delta,1,'traceback'))
    
    # print "error_type:"
    # print error_type, type(error_type)
    # print "error_value:"
    # print error_value, type(error_value)
    # print "line:"
    # print traceback.tb_lineno(tb)
    # print "error (filename, line number, function, statement, value):"
    # print traceback.extract_tb(tb)
    # # print "message:"
    # # print error_value.message
    # print "-----------------------------------------"
    indent_level_delta -= 1
    return_str_arr.append(self.get_tag(indent_level + indent_level_delta,1,section_name))
    return_str_arr.append(self.get_tag(indent_level,1,'error'))
    
    return "".join(return_str_arr)
    
  def  get_cells(self):
    return_str_arr = [""]
    indent_level = 0
    
    # return_str_arr.append(self.get_indent_chars(indent_level))
    # return_str_arr.append("<cells>")
    return_str_arr.append(self.get_tag(indent_level,0,'cells'))
    try:
      cells = AdminConfig.list('Cell').split(lineSeparator)
      # print 'str(cells) == "'  + str(cells) + '"'
      for cell in cells:
        return_str_arr.append(self.get_nodes(indent_level + 1,cell))
        # # print "debug 1a"
        # # print "debug 1b"
        # # print "debug 2"
        # # print "debug 3"
        # # print "debug 4"
    except (Exception): 
      # print "-----------------------------------------"
      # print "ERROR in get_cells()" 
      return_str_arr.append(self.get_error_info(indent_level + 1, 'cells'))
    return_str_arr.append(self.get_tag(indent_level,1,'cells'))
      
    return "".join(return_str_arr)
  # end -- def get_cells
    
  def get_nodes(self,indent_level,cell):
    return_str_arr = [""]
    
    return_str_arr.append(self.get_tag(indent_level,0,'nodes'))
    try:
      nodes = AdminConfig.list('Node', cell).split(lineSeparator)
      # print 'str(nodes) == "'  + str(nodes) + '"'
      cname = AdminConfig.showAttribute(cell, 'name')
      return_str_arr.append(self.get_tag(indent_level + 1,0,'cell-name'))
      return_str_arr.append(cname)
      return_str_arr.append(self.get_tag(0,1,'cell-name',0))
      for node in nodes:
        return_str_arr.append(self.get_servers(indent_level + 1,cname,node))
    except (Exception):
      # print "-----------------------------------------"
      # print "ERROR in get_nodes()" 
      return_str_arr.append(self.get_error_info(indent_level + 1, 'nodes'))
    return_str_arr.append(self.get_tag(indent_level,1,'nodes'))
      
    return "".join(return_str_arr)

  def get_servers(self,indent_level,cname,node):
    return_str_arr = [""]
    
    return_str_arr.append(self.get_tag(indent_level,0,'servers'))
    try:
      nname = AdminConfig.showAttribute(node, 'name')
      servs = AdminControl.queryNames('type=Server,cell=' + cname + ',node=' + nname + ',*').split(lineSeparator)
      # print "Number of running servers on node " + nname + ": %s \n" % (len(servs))
      
      # # print "DEBUG aa"
      # print 'str(servs) == "'  + str(servs) + '"'
      if ("['']" != str(servs)):
        for server in servs:
          return_str_arr.append(self.get_server_info(indent_level + 1, cname, nname, server))
    except (Exception): 
      # print "-----------------------------------------"
      # print "ERROR in get_servers()" 
      return_str_arr.append(self.get_error_info(indent_level + 1, 'servers'))
    return_str_arr.append(self.get_tag(indent_level,1,'servers'))
      
    return "".join(return_str_arr)
  # end -- def get_servers

  def get_server_info(self,indent_level, cname, nname, server):
    return_str_arr = [""]
    
    return_str_arr.append(self.get_tag(indent_level,0,'server-info'))
    try:
      # return_str_arr.append(1) # Uncomment to fake an error for debugging.
      
      # return_str_arr.append(self.get_indent_chars(indent_level))
      # return_str_arr.append(str(server))
      
      sname = AdminControl.getAttribute(server, 'name')
      return_str_arr.append(self.get_tag(indent_level + 1,0,'name'))
      return_str_arr.append(sname)
      return_str_arr.append(self.get_tag(0,1,'name',0))
      
      processType = AdminControl.getAttribute(server, 'processType')
      return_str_arr.append(self.get_tag(indent_level + 1,0,'processType'))
      return_str_arr.append(processType)
      return_str_arr.append(self.get_tag(0,1,'processType',0))
      
      pid   = AdminControl.getAttribute(server, 'pid')
      return_str_arr.append(self.get_tag(indent_level + 1,0,'pid'))
      return_str_arr.append(pid)
      return_str_arr.append(self.get_tag(0,1,'pid',0))
      
      state = AdminControl.getAttribute(server, 'state')
      return_str_arr.append(self.get_tag(indent_level + 1,0,'state'))
      return_str_arr.append(state)
      return_str_arr.append(self.get_tag(0,1,'state',0))
      
      jvm = AdminControl.queryNames('type=JVM,cell=' + cname + ',node=' + nname + ',process=' + sname + ',*')
      return_str_arr.append(self.get_tag(indent_level + 1,0,'jvm'))
      return_str_arr.append(jvm)
      return_str_arr.append(self.get_tag(0,1,'jvm',0))
      
      osname = AdminControl.invoke(jvm, 'getProperty', 'os.name')
      return_str_arr.append(self.get_tag(indent_level + 1,0,'os-name'))
      return_str_arr.append(osname)
      return_str_arr.append(self.get_tag(0,1,'os-name',0))
      
      wsroot = AdminControl.invoke(jvm, 'getProperty', 'user.install.root')
      print str(sys.platform.system())
      # if ('Windows' == platform.system()):
      #  wsroot = wsroot.replace("/", "\\")
      return_str_arr.append(self.get_tag(indent_level + 1,0,'user-install-root'))
      return_str_arr.append(wsroot)
      return_str_arr.append(self.get_tag(0,1,'user-install-root',0))
      
      wslogroot = (wsroot + '/logs')
      # if ('Windows' == platform.system()):
      #   wslogroot = wslogroot.replace("/", "\\")
      return_str_arr.append(self.get_tag(indent_level + 1,0,'log-root'))
      return_str_arr.append(wslogroot)
      return_str_arr.append(self.get_tag(0,1,'log-root',0))
      
    except (Exception): 
      # print "-----------------------------------------"
      # print "ERROR in get_server_info()" 
      return_str_arr.append(self.get_error_info(indent_level + 1, 'server-info'))
    return_str_arr.append(self.get_tag(indent_level,1,'server-info'))
      
    return "".join(return_str_arr)
  # end -- def get_server_info

# end -- class GetNodeInfo(scripting.core.AbstractScript):

gni = GetNodeInfo()
print gni.get_cells()