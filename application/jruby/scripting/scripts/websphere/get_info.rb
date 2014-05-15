module Scripting
  module Scripts
    module Websphere

      require 'java'
      require 'rubygems'
      require 'rbconfig'
#      require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems'

      # TODO: 
      #   - Determine how to:
      #     - Specify SOAP target host from within Jython script
      #     - Use WebSphere's "com.ibm.ws.admin.client_6.1.0.jar" and "com.ibm.ws.webservices.thinclient_6.1.0.jar" instead of "wsadmin.bat"
      #   - Merge this file and 'getinfo.py' into one subclass of AbstractClass.
      # See:
      #   * "D:\FGG_SVN\MaximoScriptGeneratorAndUtils\websphere"
      #   * "http://publib.boulder.ibm.com/infocenter/wasinfo/beta/index.jsp?topic=%2Fcom.ibm.websphere.express.doc%2Finfo%2Fexp%2Fae%2Ftxml_adminclient.html"
      #   * "http://publib.boulder.ibm.com/infocenter/wasinfo/beta/index.jsp?topic=%2Fcom.ibm.websphere.express.doc%2Finfo%2Fexp%2Fae%2Ftxml_j2se.html"
      #   * "http://publib.boulder.ibm.com/infocenter/wasinfo/beta/topic/com.ibm.websphere.express.doc/info/exp/ae/txml_nonosgi.html"
      #   * "http://publib.boulder.ibm.com/infocenter/wasinfo/beta/index.jsp?topic=%2Fcom.ibm.websphere.express.doc%2Finfo%2Fexp%2Fae%2Ftxml_scriptingep.html"
      #   * "http://en.wikipedia.org/wiki/Wsadmin#Invocation_syntax"

      # JGridLayout = Java::java.awt.GridLayout unless defined?(JGridLayout)
      class GetInfo < AbstractScript
          include Scripting
          include Scripting::Scripts::Common::ExceptionHandling # e.g.: def generic_exception_handler(e)
          include Scripting::Scripts::Common::Exportable # e.g.: def script_path(root_path, script_file_name, include_date = true, include_time = true)
          include Scripting::Scripts::Common::Xml
          include Scripting::Scripts::Common::Misc

          def self.description
            ret_val = self.name + ":"
            ret_val << AbstractScript.newline + AbstractScript.newline
            ret_val << "NOTE: Currently, this requires 'wsadmin.bat' and must be run on a system that has WebSphere installed."
            ret_val << AbstractScript.newline
            ret_val << "TODO: Merge this file and 'getinfo.py' into one subclass of AbstractClass."
            ret_val << AbstractScript.newline
            ret_val << "Required initial params:"
            ret_val << AbstractScript.newline
            ret_val << " * 'from' database settings (pointing to a Maximo database)"
            ret_val << AbstractScript.newline
            ret_val << " * 'to' database settings (pointing to FGG_MAXIMO_DATALOADS database)"
            ret_val << AbstractScript.newline + AbstractScript.newline
            ret_val << "This script is for the Maximo Server List. This script gathers Maximo server data from Maximo databases and adds it to the 'FGG_MAXIMO_DATALOADS' database."
            ret_val << AbstractScript.newline + AbstractScript.newline

            ret_val
          end # def self.description


          def initialize
            super("GetInfo")

          end

          def initUISettingsHook
            self.quickstart = true # false # i.e.: true = Hide options panel and just start running the script; false = Show options panel and require the user to click the "Start" button.
          end

          def initUIComponentsHook
            begin
            rescue Exception => e
              generic_exception_handler(e)
            end
          end

          def startScriptHook
            log_prefix = "startScriptHook()... "
            begin
              update_progress(@progressCurrent, log_prefix + "STARTED")

              update_progress(@progressCurrent, log_prefix + "RUBY_PLATFORM == " + RUBY_PLATFORM)
              update_progress(@progressCurrent, log_prefix + "Config::CONFIG['host_os'] == " + Config::CONFIG['host_os'])
              is_windows = !((Config::CONFIG['host_os'] =~ /mswin|mingw/).nil?)
              # is_windows = !(('mswin32' =~ /mswin|mingw/).nil?)
              update_progress(@progressCurrent, log_prefix + "is_windows == " + is_windows.inspect)
              # update_progress(@progressCurrent, log_prefix + "Connecting with 'from' db...")
              # Mxtbl.connect(self.fromConnParams)

              # update_progress(@progressCurrent, log_prefix + "Connecting with 'to' db...")
              # Fmdtbl.connect(self.toConnParams)
              
              target_host = self.fromConnParams['server'].to_s
              # update_progress(@progressCurrent, "target_host == '" + target_host + "'" + AbstractScript.newline)
              if ([''].include?(target_host))
                target_host = 'localhost'
              end
              update_progress(@progressCurrent, "target_host == '" + target_host + "'" + AbstractScript.newline)
              un = self.fromConnParams['username'].to_s
              pw = self.fromConnParams['password'].to_s
              was_root = self.fromConnParams['path'].to_s

              pkg_path = "scripting/scripts/websphere"
              # class_name = "Getinfo"
              class_name = "GetNodeInfo"
              bat_file_path = ENV['AppRoot'] + "/jython/" + pkg_path
              bat_file_name = bat_file_path + "/getinfo.bat" if is_windows
              bat_file_name.gsub!('/','\\') if is_windows
              jython_file_path = ENV['AppRoot'] + "/jython/" + pkg_path
              jython_file_path.gsub!('/','\\') if is_windows
              # @javaClassName = "scripting.core.AbstractScript"
              jython_file_name = class_name.underscore + ".py"
              
              output_path = self.toConnParams['path'].to_s
              if ([''].include?(output_path))
                # output_path = ENV['AppRoot'] + '/jython/scripting/scripts'
                output_path = bat_file_path
              end
              output_file_name = output_path + "/" + jython_file_name + "host(" + target_host + ").output"
              output_file_name.gsub!('/','\\') if is_windows
              
              # puts "Running Jython Class: " + @jythonFileName + " ..."
              cmd = bat_file_name + " " + un + " " + pw + " " + was_root + " " + target_host + " " + jython_file_path + " " + jython_file_name + " " + output_file_name
              cmd.gsub!('/','\\') if is_windows
              update_progress(progressCurrent, "cmd == " + cmd + AbstractScript.newline)
              output = IO.popen(cmd)
#              update_progress(98, "Jython script output == " + AbstractScript.newline)
#              update_progress(99, output.readlines + AbstractScript.newline)
              update_progress(progressCurrent, "Jython script cmd == " + AbstractScript.newline)
              lines = output.readlines
              lines_count_all = lines.count
              # update_progress(@progressCurrent, "Jython script cmd == " + AbstractScript.newline + AbstractScript.newline)
              cmd_prompt = ''
              
              display_cmd_lines = false # true
              if (display_cmd_lines)
                lines.each_index do |lines_count_current|
                  line = lines[lines_count_current]
                  
                  if (lines_count_current == 0)
                    cmd_prompt = line.gsub(cmd,'')
                    update_progress(progressCurrent, "cmd_prompt == '" + cmd_prompt + "'" + AbstractScript.newline)
                  end
                  
                  line.gsub!(cmd_prompt,'')
                  recalc_progress_by_counters([[lines_count_current,lines_count_all]])
                  update_progress(@progressCurrent, line)
                end
              end
              
              lines = []
              output_file = File.new(output_file_name, "r")
              while (line = output_file.gets)
                  lines << line
              end
              output_file.close
              lines_count_all = lines.count
              update_progress(@progressCurrent, "Jython script output == " + AbstractScript.newline + AbstractScript.newline)
              cmd_prompt = ''
              lines.each_index do |lines_count_current|
                line = lines[lines_count_current]
                recalc_progress_by_counters([[lines_count_current,lines_count_all]])
                update_progress(@progressCurrent, line.gsub('\r','').gsub('\n',''))
              end
              
              update_progress(100, log_prefix + "FINISHED")
            rescue Exception => e
              update_progress(@progressCurrent, log_prefix + "EXCEPTION")
              puts log_prefix + "Exception => e == " + e.inspect.to_s
              puts log_prefix + " ... backtrace == "
              e.backtrace.each do |a_step|
                puts log_prefix + " >> " + a_step.to_s
              end
            end
              update_progress(@progressCurrent, log_prefix + "EXITING")
          end

          def endScriptHook
            begin

             # Mxtbl.disconnect(self.fromConnParams)
             # Fmdtbl.disconnect(self.fromConnParams)
             # @file_handle.close if (defined?(@file_handle) and defined?(@file_path_for_script) and File.readable?(@file_path_for_script))

              if (defined?(@generated_file))
                if (File.readable?(@generated_file))
                  unless (@generated_file.closed?)
                    @generated_file.flush
                    @generated_file.close
                  end
                end
              end

              msg = "Done."
             update_progress(100, msg)
            rescue Exception => e
              puts "Exception => e == " + e.inspect.to_s
              puts " ... backtrace == "
              e.backtrace.each do |a_step|
                puts " >> " + a_step.to_s
              end
            end
          end # def endScriptHook(...)



      end # class GetInfo
    end # module Websphere
  end # module Scripts
end # module Scripting
