module Scripting
  module Scripts
    module Maximo
      module Logs

        require 'java'
        require 'rubygems'
        require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems'
        require 'fileutils'

        class GrabErrorLinesUncaughtExceptionInServlet < AbstractScript
            include Scripting

            def self.description
              ret_val = self.name + ":"
              ret_val << AbstractScript.newline + AbstractScript.newline
              ret_val << "Required initial params:"
              ret_val << AbstractScript.newline
              ret_val << " * 'to' path setting (for where you want the log summary)"
              ret_val << AbstractScript.newline + AbstractScript.newline
              ret_val << "This generates summary files of the 'SRVE0068E' error occurrences from Production Maximo 'SystemOut.*log' files."
              ret_val
            end # def self.description

            def initialize
#              super
#              jframeName = self.name
#              setTitle(jframeName)
#              super(self.name)
              super("GrabErrorLinesUncaughtExceptionInServlet")

              @file_name_to_match = ''
              @string_to_match = ''
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
#              t_folder = Time.now.strftime("%Y-%m-%d_%Z_%I-%M%p")
#              dest_folder_path << "/" + t_folder
#              FileUtils.mkdir(dest_folder_path) unless (File.directory?(dest_folder_path))
#              update_progress(@progress_val, " ... Entered folder: '" + dest_folder_path + "' ...")
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

            def startScriptHook
              log_prefix = "startScriptHook()... "
              begin
                update_progress(0, log_prefix + "STARTING")

#                  update_progress(0, log_prefix + "================================================================")
#                update_progress(0, log_prefix + "@how_much_detail == " + @how_much_detail.inspect)
#                update_progress(0, log_prefix + "@how_much_detail.get_selected_index == " + @how_much_detail.get_selected_index.to_s)
#                update_progress(0, log_prefix + "@how_much_detail.get_selected_item == " + @how_much_detail.get_selected_item.to_s)
#
#                update_progress(0, log_prefix + "connecting to 'From' db...")

#                @file_path = script_path(__FILE__)
#                @from_folder_path = script_path(File.expand_path(self.fromConnParams['path']),nil)
                @server_names = ['gvppfgg920','gvppfgg921','gvppfgg922']
                @from_folder_paths = ['//gvppfgg920/maximoui_logs','//gvppfgg921/maximoui_logs','//gvppfgg922/maximoui_logs']
#                @from_folder_path = script_path(File.expand_path(self.fromConnParams['path']),nil)

                # date_today = Date.now
                date_today = Date.parse(Time.now.to_s)
                date_today_str = date_today.month.to_s + "/" + date_today.day.to_s + "/" + date_today.year.to_s[2..3]
                update_progress(@progressCurrent, "date_today_str: '" + date_today_str + "'");
                date_yesterday = date_today - 1
                date_yesterday_str = date_yesterday.month.to_s + "/" + date_yesterday.day.to_s + "/" + date_yesterday.year.to_s[2..3]
                update_progress(@progressCurrent, "date_yesterday_str: '" + date_yesterday_str + "'");
                
                @error_types = [date_yesterday_str,date_today_str,'java.lang.ClassCastException','java.lang.NullPointerException','java.lang.IllegalStateException']
                @server_names.each do |srvr|

                  @error_type_counts = Hash.new

                  @error_types.each do |et|
                    @error_type_counts[et] = 0
                  end
                  @error_type_counts['all'] = 0

                  @from_folder_path = '//' + srvr + '/maximoui_logs'

                  @to_file_path   = script_path(File.expand_path(self.toConnParams['path']) , srvr + "_error_lines.txt",true,false)
                  @generated_script_file = File.new(@to_file_path,"w")
#                  @generated_script_file.write("hello world")
#                  @generated_script_file.flush


                  paths = Dir.glob(@from_folder_path + '/**/*')
                  paths_count_all = paths.count
                  paths_current = 0

                  paths.each do |path|
                    paths_current += 1
#                    @progressCurrent = (100 * (1.0 * paths_current / paths_count_all) / @server_names.count ).to_i
                    @progressCurrent = (100 * (1.0 * paths_current / paths_count_all)).to_i
                    puts path
                    from_file_path = File.expand_path(path)
                    file_name = File.basename(path) #.downcase
                    folder_name = File.dirname(path)

    #                file_name_len = file_name.length
    #                sub_path = File.expand_path(file).gsub(from_path,"")
    #                sub_path_len = sub_path.length
    #                sub_path = sub_path[0..(sub_path_len-file_name_len)] # trim the filename out

#                    sub_path = File.dirname(file).gsub(from_path,"")
#
#                    dest_folder_path = to_path + "/" + sub_path
#                    dest_file_path = to_path + "/" + sub_path + "/" + file_name
#                    FileUtils.mkdir(dest_folder_path) unless (File.directory?(dest_folder_path))
                    if (File.file?(path) and file_name.include?("SystemOut"))
                       update_progress(@progressCurrent, "Scanning file: '" + path + "'");
#                  @generated_script_file.write("Scanning file: '" + path + "'")
#                  @generated_script_file.flush

    #                  File.delete(dest_file_path) if (File.file?(dest_file_path))
    #                  FileUtils.cp(file,dest_file_path)
#                       FileUtils.mkdir(dest_file_path) unless (File.directory?(dest_file_path))
                      File.open(path, 'r') do |f|
                        f.each_line do |line|
                          if (line.include?("SRVE0068E"))
                            update_progress(@progressCurrent, " Found line: '" + line + "'");
#                            @generated_script_file.write("Server: '" + srvr + "', File: '" + path + "', Line: '" + line + "'" + AbstractScript.newline + AbstractScript.newline)
#                            @generated_script_file.write("Server: '" + srvr + "'" + AbstractScript.newline + "File:   '" + path + "'" + AbstractScript.newline + "Line:   '" + line + "'" + AbstractScript.newline)
                            @generated_script_file.write("File:   '" + path + "'" + AbstractScript.newline + "Line:   '" + line.gsub(AbstractScript.newline,'') + "'" + AbstractScript.newline)
                            @generated_script_file.write(AbstractScript.newline)
                            @generated_script_file.flush


                            # Scan for sub-error-types:
                            @error_types.each do |et|
                              if (line.include?(et))
                                @error_type_counts[et] += 1
                              end
                            end
                            if (@error_type_counts.has_key?(folder_name))
                              @error_type_counts[folder_name] += 1
                            else
                              @error_type_counts[folder_name] = 1
                            end
                            @error_type_counts['all'] += 1

                          end
                        end
                      end
                    else
#                      File.delete(dest_file_path) if (File.file?(dest_file_path))
#                      FileUtils.cp(file,dest_file_path)
                       update_progress(@progressCurrent, "Non-matching path: '" + path + "'");
                    end
                       update_progress(@progressCurrent, "");
#                    update_progress(50, "Copied '" + from_file_path + "' to '" + dest_file_path + "'");
                  end


                  # Log counts of sub-error-types:
                  @error_type_counts.each_key do |et|
#                    msg = log_prefix + "Count of error '" + et + "' : " + @error_type_counts[et].to_s
                    if ["all"].include?(et)
                      msg = "Count of all : " + @error_type_counts['all'].to_s
                    else
                      msg = "Count of per '" + et + "' : " + @error_type_counts[et].to_s
                    end
                    update_progress(@progressCurrent, msg)
                    @generated_script_file.write(msg)
                    @generated_script_file.write(AbstractScript.newline)
                    @generated_script_file.flush
                  end
##                  msg = log_prefix + "Count of all : " + @error_type_counts['all'].to_s
#                  msg = "Count of all : " + @error_type_counts['all'].to_s
#                  update_progress(@progressCurrent, msg)
#                  @generated_script_file.write(msg)
#                  @generated_script_file.write(AbstractScript.newline)
#                  @generated_script_file.flush
                end


                # branch depending on @how_much_detail
                # within the branches, read in records with preference going to

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

  #             Mxtbl.disconnect(self.fromConnParams)
#               Fmdtbl.disconnect(self.fromConnParams)
#               Fmdtbl.disconnect(self.toConnParams)
                if (defined?(@generated_script_file))
                  @generated_script_file.close if (File.readable?(@generated_script_file))
                end


                msg = "Done."
    #           log.warn(msg)
               update_progress(100, msg)
              rescue Exception => e
                puts "Exception => e == " + e.inspect.to_s
                puts " ... backtrace == "
                e.backtrace.each do |a_step|
                  puts " >> " + a_step.to_s
                end
              end
  #            @log.warn("bye from jruby")
  #            updateProgress(80, "*>* bye from jruby")
  #            puts("... bye from jruby")
              #fromConnParamsWithoutPw.inspect
            end # def endScriptHook(...)

        end # class GrabErrorLines

      end # module Logs
    end # module Maximo
  end # module Scripts
end # module Scripting
