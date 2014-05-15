# ** Filename: getinfo.py

print "----------------------------------------------------"
print "----------------------------------------------------"
     
import java
from com.ibm.websphere.management.exception import AdminException
from com.ibm.ws.scripting import ScriptingException

lineSeparator = java.lang.System.getProperty('line.separator')

try:
  # print "\n"
  # print "++++++++++++++++++++++++++++++++++++++++++++++++++++"
  # # See "http://fixunix.com/websphere/558968-know-path-name-pid-file-jython-wsadmin-soapadminclnt.html"
  # id=AdminControl.queryNames('*:*,name=AdminOperatio ns')
  # # dirname=AdminControl.invoke(id,'expandVariable','[${SERVER_LOG_ROOT}]','[java.lang.String]');
  # serverName=AdminConfig.showAttribute(AdminConfig.getid('/Server:/'),'name');
  # print dirname+"/"+serverName+".pid";
  # print "++++++++++++++++++++++++++++++++++++++++++++++++++++"
  # print "\n"
  
  print "\n"
  print "++++++++++++++++++++++++++++++++++++++++++++++++++++"
  # http://groups.google.com/group/ibm.software.websphere.application-server/browse_thread/thread/757d1196ea4dbdfe
  import sys 
  def wsadminToList(inStr): 
    outList=[] 
    if (len(inStr)>0 and inStr[0]=='[' and inStr[-1]==']'): 
      tmpList = inStr[1:-1].split(" ") 
    else: 
      tmpList = inStr.split("\n")  #splits for Windows or Linux 
    for item in tmpList: 
      item = item.rstrip();        #removes any Windows "\r" 
      if (len(item)>0): 
        outList.append(item) 
    return outList 
  #endDef 
  typeStr = "Cell"
  # typeStr = "Node"
  # typeStr = "Cluster"
  # typeStr = "Server"
  cell = AdminConfig.list(typeStr) 
  print 'str(cell) == "'  + str(cell) + '"'
  cellName = AdminConfig.showAttribute(cell, "name") 
  print 'str(cellName) == "'  + str(cellName) + '"'
  cellWebSphereVariableMap = AdminConfig.getid("/" + typeStr + ":"+cellName+"/VariableMap:/") 
  print 'str(cellWebSphereVariableMap) == "'  + str(cellWebSphereVariableMap) + '"'
  cellEntries = AdminConfig.showAttribute(cellWebSphereVariableMap, "entries") 
  print 'str(cellEntries) == "'  + str(cellEntries) + '"'
  entryList = wsadminToList(cellEntries) 
  print 'str(entryList) == "'  + str(entryList) + '"'
  if (len(cellEntries) != '[]'): 
    for cellEntry in entryList: 
      varName = AdminConfig.showAttribute(cellEntry, "symbolicName") 
      print "var Name is : "+varName 
      varVal = AdminConfig.showAttribute(cellEntry, "value") 
      print " var value is : "+varVal 
    #endFor 
  #endIf 
  print "++++++++++++++++++++++++++++++++++++++++++++++++++++"
  print "\n"


  
  AdminConfig.list('VariableMap')

  # get Nodes
  NodeIDs = AdminConfig.getid('/Node:/')
  print 'str(NodeIDs) == "'  + str(NodeIDs) + '"'
  arrayNodeIDs = NodeIDs.split(lineSeparator)

  # get Ports
  EndPointIDs = AdminConfig.getid('/EndPoint:/')
  print 'str(EndPointIDs) == "'  + str(EndPointIDs) + '"'
  arrayEndPointIDs = EndPointIDs.split(lineSeparator)
  NamedEndPointIDs = AdminConfig.getid('/NamedEndPoint:/')
  print 'str(NamedEndPointIDs) == "'  + str(NamedEndPointIDs) + '"'
  arrayNamedEndPointIDs = NamedEndPointIDs.split(lineSeparator)

  # print
  for x in range(len(arrayNodeIDs)):


  #  # The commands to get a handle for the server and then its state are:
  #  runserv = AdminConfig.getObjectName()
  #  AdminControl.getAttribute(runserv, "state")

    ws_node_name = AdminConfig.showAttribute(arrayNodeIDs[x],'name')
    # ws_node_state = AdminConfig.showAttribute(arrayNodeIDs[x],'state')
    
        # print ws_node_name, ws_node_state
        # print ws_node_name

    for y in range(len(arrayEndPointIDs)):
      if arrayEndPointIDs[y].find(AdminConfig.showAttribute(arrayNodeIDs[x],'name')) > 0:
      
        ws_endPointName = AdminConfig.showAttribute(arrayNamedEndPointIDs[y],'endPointName')
        ws_port = AdminConfig.showAttribute(arrayEndPointIDs[y],'port')
        # print ws_node_name, ws_node_state, ws_endPointName, ws_port
        print ws_node_name, ws_endPointName, ws_port
        # print '    ', ws_endPointName, ws_port
        #print AdminConfig.showAttribute(arrayNodeIDs[x],'name'), AdminConfig.showAttribute(arrayNamedEndPointIDs[y],'endPointName'), AdminConfig.showAttribute(arrayEndPointIDs[y],'port')
        
      #endIf 
    #endFor - Endpoints by ID
  #endFor - Nodes by ID


  print "----------------------------------------------------"
  print "----------------------------------------------------"
       
  #----------------------------------------------------------------
  # find all the cells
  #----------------------------------------------------------------
  cells = AdminConfig.list('Cell').split(lineSeparator)
  print 'str(cells) == "'  + str(cells) + '"'
  for cell in cells:
    #----------------------------------------------------------------
    # find all the nodes belonging to the cell
    #-----------------------------------------------------------------
    nodes = AdminConfig.list('Node', cell).split(lineSeparator)
    print 'str(nodes) == "'  + str(nodes) + '"'
    for node in nodes:
      #--------------------------------------------------------------
      # find all the running servers belonging to the cell and node
      #--------------------------------------------------------------
      cname = AdminConfig.showAttribute(cell, 'name')
      nname = AdminConfig.showAttribute(node, 'name')
      servs = AdminControl.queryNames('type=Server,cell=' + cname + ',node=' + nname + ',*').split(lineSeparator)
      print "Number of running servers on node " + nname + ": %s \n" % (len(servs))

      # print "DEBUG aa"
      print 'str(servs) == "'  + str(servs) + '"'
      if ("['']" == str(servs)):
        # print "DEBUG aa 1"
        print "Error: 'str(servs)' == ['']"
      else:
        # print "DEBUG aa 2"
        for server in servs:
          #---------------------------------------------------------
          # get some attributes from the server to display; 
          # invoke an operation on the server JVM to display a property.
          #---------------------------------------------------------
          # print "DEBUG a"
          print "str(server) == "  + str(server)
          # print "type(server) == "  + type(server)
          # print "dir(server) == "  + dir(server)
          #if (server == "")
          #    print "server name == blank"
          #else
          #    print "server name == "  + server
          sname = AdminControl.getAttribute(server, 'name')
          # print "DEBUG a 1"
          ptype = AdminControl.getAttribute(server, 'processType')
          # print "DEBUG a 2"
          pid   = AdminControl.getAttribute(server, 'pid')
          # print "DEBUG a 3"
          state = AdminControl.getAttribute(server, 'state')
          # print "DEBUG a 4"
          jvm = AdminControl.queryNames('type=JVM,cell=' + cname + ',node=' + nname + ',process=' + sname + ',*')
          # print "DEBUG a 5"
          osname = AdminControl.invoke(jvm, 'getProperty', 'os.name')
          # print "DEBUG a 6"
          print "  Server info: " + sname + " " +  ptype + " has pid " + pid + "; state: " + state + "; on " + osname + "\n"
          # print "DEBUG a 7"
          wsroot = AdminControl.invoke(jvm, 'getProperty', 'user.install.root')
          # print "DEBUG a 8"
          print "  Websphere 'user.install.root': '" + wsroot + "'\n"
          # print "DEBUG a 9"
          print "  Websphere logging root (under 'user.install.root') : '" + wsroot + "\\logs'\n"
          # print "DEBUG b"

          #---------------------------------------------------------
          # find the applications running on this server and 
          # display the application name. 
          #---------------------------------------------------------
          apps = AdminControl.queryNames('type=Application,cell=' + cname + ',node=' + nname + ',process=' + sname + ',*').split(lineSeparator)
          # print "DEBUG c"
          print "  Number of applications running on " + sname + ": %s \n" % (len(apps))
          print "str(apps) == "  + str(apps)
          if ("['']" == str(apps)):
            # print "DEBUG c 1"
            print "Error: 'str(apps)' == ['']"
          else:
            # print "DEBUG c 2"
        
            for app in apps:
              aname = AdminControl.getAttribute(app, 'name')
              if (aname):
                print "    Application name: " + aname + "\n"
              # print aname + "\n"
            # end: for app in apps:
        # end: for server in servs:
      print "----------------------------------------------------"
      print "\n"
         
         
except (AdminException,ScriptingException,Exception): 
  Application.showMessage("Search Testcase Failed with Exception")
  context.report("Search Testcase Failed with Exception")
  
  error_type, error_value, tb = sys.exc_info()
  print error_type, type(error_type)
  print "-----------------------------------------"
  print error_value, type(error_value)
  print "message:"
  print error_value.message
  print "============================================= ==="
  print "Traceback:"
  print "============================================= ==="
  traceback.print_exception(error_type, error_value, tb)
  traceback.print_exc()
  print "==========END TRACEBACK========================"
  print_exception