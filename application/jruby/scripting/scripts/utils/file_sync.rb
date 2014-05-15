module Scripting
  module Scripts
    module Utils

      require 'java'
      require 'rubygems'
      require 'fileutils'
      require 'json'

      # class FileSyncOneDirection < AbstractScript
      class FileSync < AbstractScript
        include Scripting
        include Scripting::Scripts::Common::ExceptionHandling # e.g.: def generic_exception_handler(e)
#            include Scripting::Scripts::Common::Exportable # e.g.: def script_path(root_path, script_file_name, include_date = true, include_time = true)
#            include Scripting::Scripts::Common::Xml
        include Scripting::Scripts::Common::Misc

        def self.description
          ret_val = self.class.name + ":"
          ret_val << AbstractScript.newline + AbstractScript.newline
          ret_val << "Required initial params:"
          ret_val << AbstractScript.newline
          ret_val << " * 'from' path setting"
          ret_val << AbstractScript.newline
          ret_val << " * 'to'   path setting"
          ret_val << AbstractScript.newline + AbstractScript.newline
          ret_val << "This is a simple backup/replace utility for syncing files and folders in one direction."
          ret_val
        end # def self.description

        def initialize
          super("FileSyncOneDirection")
          log_prefix = self.name + '#initialize() ... '
          log.info(log_prefix + "STARTED")
#            @options_file_path = ENV['AppRoot'] + "/properties/examxml_options.txt"
          log.info(log_prefix + "FINISHED")
        end


        def should_copy(from_entry_path_full,to_entry_path_full)
          # We should do a file content comparison and IGNORE the dates,
          #   unless we have some param set for checking the dates, passed into 'sync_from_to'.
          # For now, we will just use date comparison:
          (File.ctime(from_entry_path_full) > File.ctime(to_entry_path_full))
        end

        # def sync_from_to(from_path_start,to_path_start,path_sub,file_name,count_sets)
        # def sync_from_to(from_path_start,to_path_start,path_sub,count_sets)
        def sync_from_to(from_path_start,to_path_start,count_sets, over_write_existing_files)
          log_prefix = 'sync_from_to(..) ... '
          begin
            from_path_compare = from_path_start
            to_path_compare = to_path_start
#            unless (path_sub.nil?)
#              from_path_compare << "/" + path_sub
#              to_path_compare << "/" + path_sub
#            end
#            unless (file_name.nil?)
#              from_path_compare << "/" + file_name
#              to_path_compare << "/" + file_name
#            end
            from_path_compare_exists = File.exist?(from_path_compare)
            to_path_compare_exists = File.exist?(to_path_compare)
            from_path_compare_is_dir = File.directory?(from_path_compare)
            to_path_compare_is_dir = File.directory?(to_path_compare)
            from_path_compare_is_file = File.file?(from_path_compare)
            to_path_is_file = File.file?(to_path_compare)

            if (to_path_compare_exists)
              if (to_path_compare_is_dir)
                # We're ok.
              else
                raise "Error: The 'from_path' ('#{to_path_compare}') is not a dir!!"
              end # if (from_path_compare_is_dir) ... elsif (from_path_is_file)
            else
              FileUtils.mkdir_p(to_path_compare)
              update_progress(@progressCurrent, log_prefix + "      created dir")
            end # if (from_path_compare_exists)

            if (from_path_compare_exists)
              if (from_path_compare_is_dir)
                from_entries = Dir.entries(from_path_compare) # Dir.glob(from_path + '/**/*')
                from_entries = from_entries - [".",".."] # skipping self-reference to dir and reference to parent dir
                from_entries_count_all = from_entries.count
                from_entries.each_index do |from_entry_count_current|
                  from_entry = from_entries[from_entry_count_current]
                  from_entry_path_full = from_path_compare + "/" + from_entry
                  to_entry_path_full = to_path_compare + "/" + from_entry

                  # count_sets_next = (count_sets << [from_entry_count_current,from_entries_count_all])
                  count_sets.push([from_entry_count_current,from_entries_count_all])
                  # recalc_progress_by_counters(count_sets_next)
                  recalc_progress_by_counters(count_sets)
                  update_progress(@progressCurrent, log_prefix + "  counts: " + @progressCurrent.to_s + ", " + ActiveSupport::JSON.encode(count_sets)) # count_sets_next.to_s)
                  update_progress(@progressCurrent, log_prefix + "  ..from: " + from_entry_path_full)
                  update_progress(@progressCurrent, log_prefix + "  ..to  : " + to_entry_path_full)

                  if (File.directory?(from_entry_path_full))
#                    if (path_sub.nil?)
#                      entry_path_sub = from_entry
#                    else
#                      entry_path_sub = path_sub + "/" + from_entry
#                    end
                    if (File.exist?(to_entry_path_full))
                      if (File.directory?(to_entry_path_full))
                        # to_path exists already as a dir, so nothing else to do for this path
                        update_progress(@progressCurrent, log_prefix + "      skipped , since 'to' dir exists")
                      else
                        raise "Error: File/Dir Mismatch! The 'from_path' ('#{from_entry_path_full}') is a dir, but 'to_path' ('#{to_entry_path_full}') is a file!"
                      end
                    else
                      FileUtils.mkdir_p(to_entry_path_full)
                      update_progress(@progressCurrent, log_prefix + "      created dir")
                    end
#                    sync_from_to(from_path_start,to_path_start,entry_path_sub,count_sets_next)
#                    sync_from_to(from_entry_path_full,to_entry_path_full,from_entry,count_sets_next)
#                    sync_from_to(from_entry_path_full,to_entry_path_full,count_sets_next)
                    sync_from_to(from_entry_path_full,to_entry_path_full,count_sets, over_write_existing_files)
                  elsif (File.file?(from_entry_path_full))
                    if (File.exist?(to_entry_path_full))
                      if (File.file?(to_entry_path_full))
                        # check date
                        # over_write_existing_files
                        if (over_write_existing_files and should_copy(from_entry_path_full,to_entry_path_full))
                          FileUtils.cp(from_entry_path_full,to_entry_path_full, {:preserve => true})
                          update_progress(@progressCurrent, log_prefix + "      copied, since 'from' file is newer")
                        else
                          # to_path exists already as a file and is newer, so nothing else to do for this path, unless we copy backwards:
                          # FileUtils.cp(to_entry_path_full,from_entry_path_full)
                          update_progress(@progressCurrent, log_prefix + "      skipped , since 'to' file is newer (or 'over_write_existing_files' is false)")
                        end # if (File.ctime("from_entry_path_full") > File.ctime("to_entry_path_full"))
                      else
                        raise "Error: File/Dir Mismatch! The 'from_path' ('#{from_entry_path_full}') is a file, but 'to_path' ('#{to_entry_path_full}') is a dir!"
                      end # if (File.file?(to_entry_path_full))
                    else
                      FileUtils.cp(from_entry_path_full,to_entry_path_full, {:preserve => true})
                      update_progress(@progressCurrent, log_prefix + "      copied file")
                    end # if (File.exist?(to_entry_path_full))

                  else
                    raise "Error: Problem detecting if 'from_path' ('#{from_entry_path_full}') is a file or is a dir!" # Should never happen
                  end # if (File.directory?(from_entry_path_full)) ... elsif (File.file?(from_entry_path_full)) ...
                  count_sets_finished = count_sets.pop
                end # from_entries.each_index do |from_entry_count_current|
              # elsif (from_path_is_file)
              #   FileUtils.cp(from_path,to_path)
              else
              #   raise "Error: Problem detecting if 'from_path' ('#{from_entry_path_full}') is a file or is a dir!"
                raise "Error: The 'from_path' ('#{from_path_compare}') is not a dir!!"
              end # if (from_path_compare_is_dir) ... elsif (from_path_is_file)
            else
              raise "Error: The 'from_path' does not exist for '#{from_path_compare}'!"
            end # if (from_path_compare_exists)
          rescue Exception => e
            # generic_exception_handler(e)
            raise e # bubble it up
          end
        end

        def startScriptHook
          log_prefix = 'startScriptHook() ... '
          begin
            update_progress(0, log_prefix + "STARTED")

            from_path = File.expand_path(self.fromConnParams['path'])
            to_path = File.expand_path(self.toConnParams['path'])

            # sync_from_to(from_path,to_path,nil,nil,[])
            # sync_from_to(from_path,to_path,nil,[])
            sync_one_direction = true # TODO: should parameterize this
            count_sets = []
            unless (sync_one_direction)
              count_sets = [[0,2]]
            end
            recalc_progress_by_counters(count_sets)
            update_progress(@progressCurrent, log_prefix + "[Copying: 'from' -> 'to'] ...")
            over_write_existing_files = true # TODO: should use file content comparison and date comparison
            sync_from_to(from_path,to_path,count_sets, true ) # over_write_existing_files)

            unless (sync_one_direction)
              count_sets = [[1,2]]
              recalc_progress_by_counters(count_sets)
              update_progress(@progressCurrent, log_prefix + "[Copying: 'to' -> 'from'] ...")
              over_write_existing_files = false # TODO: should use file content comparison and date comparison
              sync_from_to(to_path,from_path,count_sets, over_write_existing_files)
            end

            @progressCurrent = 100
#            count_sets = [[2,2]]
#            recalc_progress_by_counters(count_sets)
            update_progress(@progressCurrent, log_prefix + "FINISHED")
          rescue Exception => e
            generic_exception_handler(e)
          end
            update_progress(@progressCurrent, log_prefix + "EXITING")
        end

        def endScriptHook
          log_prefix = 'endScriptHook() ... '
          begin
            update_progress(@progressCurrent, log_prefix + "STARTED")

           @file_handle.close if (defined?(@file_handle) and defined?(@file_path_for_script) and File.readable?(@file_path_for_script))

            update_progress(@progressCurrent, log_prefix + "FINISHED")
          rescue Exception => e
            generic_exception_handler(e)
          end
          update_progress(@progressCurrent, log_prefix + "EXITING")
        end

      end # class CompareXml
    end # module Utils
  end # module Scripts
end # module Scripting
