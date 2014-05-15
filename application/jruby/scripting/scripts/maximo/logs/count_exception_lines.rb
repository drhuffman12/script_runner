module Scripting
  module Scripts
    module Maximo
      module Logs

        require 'java'
        require 'rubygems'
        require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems'
        require 'fileutils'
        require 'active_support'
        require 'json'

        # explicit shortcuts specifying namespaced classes:
        Fmdtbl = Scripting::Db::FggMaximoDataloads::Fmdtbl unless defined?(Fmdtbl)
        EnvNode = Scripting::Db::FggMaximoDataloads::EnvNode unless defined?(EnvNode)

        class CountExceptionLines < AbstractScript
            include Scripting
            include Scripting::Scripts::Common::ExceptionHandling # e.g.: def generic_exception_handler(e)
            include Scripting::Scripts::Common::Exportable # e.g.: def script_path(root_path, script_file_name, include_date = true, include_time = true)
            include Scripting::Scripts::Common::Xml
            include Scripting::Scripts::Common::Misc

            def self.description
              ret_val = self.name + ":"
              ret_val << AbstractScript.newline + AbstractScript.newline
              ret_val << "Required initial params:"
              ret_val << AbstractScript.newline
              ret_val << " * 'from' database settings (pointing to FGG_MAXIMO_DATALOADS database)"
              ret_val << AbstractScript.newline
              ret_val << " * 'to' path setting (for where you want the log summary)"
              ret_val << AbstractScript.newline + AbstractScript.newline
              ret_val << "This generates summary files of the Java Exception occurrences from Maximo 'System.*log' files."
              ret_val << AbstractScript.newline + AbstractScript.newline

              # TODO:
              ret_val << "TODO:"
              ret_val << AbstractScript.newline + AbstractScript.newline
              ret_val << " * Add pickers for 'proj', 'env_type', 'env', and 'log_folders' ... For now, we will use *ALL* from 'FGG_MAXIMO_DATALOADS.dbo.env_nodes.log_path'."
              ret_val << AbstractScript.newline + AbstractScript.newline
              ret_val << " * Add pickers for 'file_name_to_match' and 'string_to_match' ... For now, we will use hard-coded values."
              ret_val << AbstractScript.newline + AbstractScript.newline

              ret_val
            end # def self.description

            def initialize
              super("CountExceptionLines")

            end

            def initUISettingsHook
              self.quickstart = true # false # i.e.: true = Hide options panel and just start running the script; false = Show options panel and require the user to click the "Start" button.
            end

            def initUIComponentsHook
              begin
                # TODO: Add pickers for 'proj', 'env_type', 'env', and 'log_folders'
                # TODO: Add pickers for 'file_name_to_match' and 'string_to_match'
              rescue Exception => e
                generic_exception_handler(e)
              end
            end

            def generic_exception_handler(e)
                puts "Exception => e == " + e.inspect.to_s
                puts " ... backtrace == "
                e.backtrace.each do |a_step|
                  puts " >> " + a_step.to_s
                end
            end

            def script_path(root_path, script_file_name, include_date = true, include_time = true)
              # In case a file is passed in instead of a folder:
              dest_folder_path = ""
              if (File.directory?(root_path))
                dest_folder_path << root_path
              else
                dest_folder_path << File.dirname(root_path)
              end

#              # Include the timestamp in the folder path:
              if (include_date)
                # Include the datestamp in the folder path:
                t_folder = Time.now.strftime("%Y-%m-%d")
                dest_folder_path << "/" + t_folder
                FileUtils.mkdir(dest_folder_path) unless (File.directory?(dest_folder_path))
                update_progress(@progress_val, " ... Entered folder: '" + dest_folder_path + "' ...")
              end

              if (include_time)
                # Include the timestamp in the folder path:
                t_folder = Time.now.strftime("%Z_%I-%M%p")
                dest_folder_path << "/" + t_folder
                FileUtils.mkdir(dest_folder_path) unless (File.directory?(dest_folder_path))
                update_progress(@progress_val, " ... Entered folder: '" + dest_folder_path + "' ...")
              end

              dest_folder_path << "/" + script_file_name unless script_file_name.nil?
            end

            # Returns:
            # Array of Hashes
            def get_occurrences(env_nodes_count_current,env_nodes_count_all,node_log_path, file_name_to_match, string_to_match, exclude_strings)

              scan_folder_path = node_log_path.gsub('\\','/') # to handle  Windows path slashes
              date_segment_regex = Regexp.new(/^(\[)[a-zA-Z0-9\s\/:]*(\])/)
              occurs = []
              files = []
              if (File.directory?(scan_folder_path))
                files = Dir.glob(scan_folder_path + '/**/*')
#                files = Dir.glob(scan_folder_path + '/**/[' + file_name_to_match.to_s + ']')
                from_path = scan_folder_path
              else
                if (File.file?(scan_folder_path))
  #                files = Dir.glob(scan_folder_path + '/**/*')
                  files = Dir.glob(scan_folder_path + '/**/[' + file_name_to_match.to_s + ']')
                  from_path = scan_folder_path
                else
#                  throw Exception.new("ERROR! Path not accessible: '" + node_log_path + "' (aka '" + scan_folder_path + "').")
                  error = Exception.new("ERROR! Path not accessible: '" + node_log_path + "' (aka '" + scan_folder_path + "').")
                  error_as_json = ActiveSupport::JSON.encode(error)
                  update_progress(@progressCurrent, error_as_json)
                  return {:scan_folder_path => scan_folder_path,
                          :from_path => from_path,
                          :error => error_as_json
                          }
                end
              end

#              files = Dir.glob(from_path + '/**/*')
              files_count_all = files.count
              files.each_index do |files_count_current|
                file = files[files_count_current]
                recalc_progress_by_counters([[env_nodes_count_current,env_nodes_count_all],[files_count_current,files_count_all]])
                
                from_path_sub = File.dirname(file).gsub(from_path,"")
                from_file_parent_folder = File.basename(File.dirname(file))
                from_file_path = File.expand_path(file)
                from_file_name = File.basename(file)

                if (File.file?(from_file_path) and (file_name_to_match === from_file_name)) # from_file_name.include?(file_name_to_match)
#                if (File.file?(from_file_path)) # from_file_name.include?(file_name_to_match)
                  update_progress(@progressCurrent, "Scanning file: '" + from_file_path + "'")
                  File.open(from_file_path, 'r') do |f|
                    line_num = 0
                    f.each_line do |line|
                      line_num += 1
                      matches = string_to_match.match(line)
                      unless (matches.nil?) # if (matches.count > 0) # if (string_to_match === line) # line.include?(string_to_match)
                        match_arr = (matches.to_a - exclude_strings)
                        match_arr.each do |a_match|

                          # date = (line.split(" ").first).gsub("[","")
                          error_when = nil
                          date_str = nil
                          date_matches = date_segment_regex.match(line)
                          unless date_matches.nil?
                            date_matches_arr = date_matches.to_a
                            if (date_matches_arr.count > 0)
                              date_str = (date_matches_arr.first).gsub('[','').gsub(']','')
                              error_when = DateTime.parse(date_str)
                            end
                          end # unless date_matches.nil?
#                          next_occur ={:node_dbserver => node_dbserver, :node_dbname => node_dbname, :node_name => node_name,
                          # node_log_path, file_name_to_match, string_to_match, exclude_strings
#                          next_occur ={:node_log_path => node_log_path, :scan_folder_path => scan_folder_path,
#                                       :file_name_to_match => file_name_to_match, :string_to_match => string_to_match,
#                                       :from_path => from_path, :from_file_parent_folder => from_file_parent_folder, :from_path_sub => from_path_sub, :from_file_name => from_file_name,
#                                       :match => a_match, :line_num => line_num, :date => date, :line => line
#                                       }
                          next_occur ={:scan_folder_path => scan_folder_path,
                                       :from_path => from_path, :from_file_parent_folder => from_file_parent_folder, :from_path_sub => from_path_sub, :from_file_name => from_file_name,
                                       :match => a_match, :line_num => line_num,
                                       :is_predecessor => ((error_when.nil?) ? true : false),
                                       :date => error_when,
                                       :date_year => ((error_when.nil?) ? nil : error_when.year),
                                       :date_month => ((error_when.nil?) ? nil : error_when.month),
                                       :date_day => ((error_when.nil?) ? nil : error_when.day),
                                       :date_hour => ((error_when.nil?) ? nil : error_when.hour),
                                       :date_min => ((error_when.nil?) ? nil : error_when.min),
                                       :date_sec => ((error_when.nil?) ? nil : error_when.sec),
                                       :line => line
                                       }
                          occurs << next_occur
                        end # match_arr.each do |a_match|
                      end # unless (matches.nil?)
                    end # f.each_line do |line|
                  end # File.open(from_file_path, 'r') do |f|
                else
                  update_progress(@progressCurrent, "Skipping file: '" + from_file_path + "'")
                end # if (File.file?(from_file_path) and (file_name_to_match === from_file_name))

              end # files.each do |file|

              return occurs
            end # def get_occurrences(...)

            def startScriptHook
              log_prefix = "startScriptHook()... "
              begin
                update_progress(0, log_prefix + "STARTING")

                # TODO: Use pickers from 'initUIComponentsHook()' for 'file_name_to_match' and 'string_to_match'  ... For now, we will use hard-coded values.
                file_name_to_match = Regexp.new(/(System)[a-zA-Z0-9_\.]*(\.log)/) # [(System)(native_std)][a-zA-Z0-9_\.]*(\.log)
                string_to_match = Regexp.new(/\s[a-zA-Z]+[a-zA-Z0-9]*[\.[a-zA-Z0-9]*]*(Exception)/)
#                string_to_match = Regexp.new(/^(\[)[a-zA-Z0-9\s:\/]*(\])(.)*\s[a-zA-Z]+[a-zA-Z0-9]*[\.[a-zA-Z0-9]*]*(Exception)/)
                exclude_strings = ["Exception"] # for helping filter matches

                @progressCurrent = 0
                msg = "Connecting with 'from' db..."
                update_progress(@progressCurrent, msg)
                Fmdtbl.connect(self.fromConnParams)
                @generated_file = nil
                # TODO: Use pickers from 'initUIComponentsHook()' for 'proj', 'env_type', 'env', and 'log_folders'
                env_nodes = EnvNode.all # TODO: Use pickers from 'initUIComponentsHook()' (see above) ... For now, we will use *ALL* from 'EnvNode':
                env_nodes_count_all = env_nodes.count
                env_nodes_count_current = 0

                occurrences = []
                to_path = self.toConnParams['path']
                if (File.file?(to_path))
                  to_path_parent_folder = File.dirname(to_path)
                  to_path_file_name = File.basename(to_path)
                else
                  if (File.directory?(self.toConnParams['path']))
                    to_path_parent_folder = to_path
#                    to_path_file_name = node_dbserver + "." + node_dbname + "." + node_name + ".exception_counts.log.xml"
                    to_path_file_name = "Maximo_log_exception_counts.xml"
                  else
                    throw Exception.new("Invalid 'to' path!")
                  end
                end
                @generated_file = File.new(script_path(to_path_parent_folder,to_path_file_name,true,false),"w")

                env_nodes_count_all = env_nodes.count
                env_nodes.each_index do |env_nodes_count_current|
                  node = env_nodes[env_nodes_count_current]
                  recalc_progress_by_counters([[env_nodes_count_current,env_nodes_count_all]])
                  
                  node_dbserver = node.dbserver
                  node_dbname = node.dbname
                  node_name = node.name
                  node_log_path = node.log_path.to_s

                  # @progressCurrent = (100.0 * ( env_nodes_count_current / env_nodes_count_all ) ).to_i
                  # env_nodes_count_current += 1
                  if ([''].include?(node_log_path))
                    msg = "  Skipping (missing log path): " + ActiveSupport::JSON.encode(node_log_path)
                    update_progress(@progressCurrent, msg)
                  else
  #                  msg = "  Scanning: " + ActiveSupport::JSON.encode(node)
                    msg = "  Scanning: " + ActiveSupport::JSON.encode(node_log_path)
                    update_progress(@progressCurrent, msg)

  #                  occurrences[{:node_dbserver => node_dbserver, :node_dbname => node_dbname, :node_name => node_name}] = get_occurrences(node_log_path, file_name_to_match, string_to_match, exclude_strings)
                    occurrences << {:search_in => {:node_dbserver => node_dbserver, :node_dbname => node_dbname, :node_name => node_name, :node_log_path => node_log_path},
                                    :search_for => {:file_name_to_match => file_name_to_match, :string_to_match => string_to_match, :node_name => node_name, :exclude_strings => exclude_strings},
                                    :results => get_occurrences(env_nodes_count_current,env_nodes_count_all,node_log_path, file_name_to_match, string_to_match, exclude_strings)}
                  end
                end

                if (defined?(@generated_file))
                  if (File.writable?(@generated_file))
#                    unless (@generated_file.closed?)
                      @generated_file.write(JSON.parse(ActiveSupport::JSON.encode(occurrences)).to_xml(:root => :exception_log))
      #                    @file_handle.write(ActiveSupport::JSON.encode(an_occur).to_xml)
                      @generated_file.write(AbstractScript.newline)
                      @generated_file.flush
                      @generated_file.close
#                    end
                  end
                end

                update_progress(@progressCurrent, log_prefix + "FINISHED")
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

               Fmdtbl.disconnect(self.fromConnParams)

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

        end # class GrabErrorLines

      end # module Logs
    end # module Maximo
  end # module Scripts
end # module Scripting
