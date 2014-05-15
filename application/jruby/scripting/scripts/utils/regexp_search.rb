module Scripting
  module Scripts
    module Utils

        require 'java'
        require 'rubygems'
  #      require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems'
  #require 'win32ole'
    require 'fileutils'

        class RegexpSearch < AbstractScript
          include Scripting
          include Scripting::Scripts::Common::ExceptionHandling # e.g.: def generic_exception_handler(e)
          include Scripting::Scripts::Common::Misc

          def self.description
            ret_val = self.class.name + ":"
            ret_val << AbstractScript.newline + AbstractScript.newline
            ret_val << "Required initial params:"
            ret_val << AbstractScript.newline
            ret_val << " * 'from' path setting"
            ret_val << AbstractScript.newline
            ret_val << " * 'to' path setting"
            ret_val << AbstractScript.newline + AbstractScript.newline
            ret_val << "This is to copy all filenames in the 'from' path  and paste them in the 'to' path but using lowercase filenames."
            ret_val
          end # def self.description

          def initialize
            super("RegexpSearch")
            log_prefix = self.name + '#initialize() ... '
              # log_prefix = self.name + '#endScriptHook() ... '
              log_prefix = '#endScriptHook() ... '
            log.info(log_prefix + "STARTED")
            log.info(log_prefix + "FINISHED")
          end

          def get_file_as_string(filename)
            data = ''
            f = File.open(filename, "r")
            f.each_line do |line|
              data += line
            end
            return data
          end

          def startScriptHook
            log_prefix = self.name + '#startScriptHook() ... '
            begin
              # pattern = /(RFQ)[\s\"\,a-zA-Z0-9\&\$\/\\\=\+\-\{\}\|\!\'\(\)\n\:\;\.\[\]]*(ActionNotAllowedInvalidStatus)/
              # pattern = /(RFQ)[\s\S]*(ActionNotAllowedInvalidStatus)/
              pattern = /(internal)[\s\S]*(ActionNotAllowedInvalidStatus)/
              # pattern = /(ActionNotAllowedInvalidStatus)/
              filenames1 = [self.fromConnParams['path'].to_s]
              filenames2 = [self.fromConnParams['path'].to_s]
              filenames = (filenames1 + filenames2).flatten

              update_progress(@progressCurrent, log_prefix + "pattern: " + pattern.to_s)
              update_progress(@progressCurrent, log_prefix + "filenames: ['" + filenames.join("','") + "']")
              filenames_count_all = filenames.count
              filenames.each_index do |filenames_count_current|
                filename = filenames[filenames_count_current].gsub("/","\\")
                count_sets = [[filenames_count_current,filenames_count_all]]
                recalc_progress_by_counters(count_sets)
                update_progress(@progressCurrent, log_prefix + "  @progressCurrent: " + @progressCurrent.to_s + ", filename: '" + filename +"'")
                str = get_file_as_string(filename)
                matches = str.scan(pattern)
                if (matches.nil?)
                  update_progress(@progressCurrent, log_prefix + "  -- NO AVAIL MATCHES!")
                else
                  matches_arr = matches.to_a
                  matches_arr_count_all = matches_arr.count
                  if (matches_arr_count_all > 0)
                    update_progress(@progressCurrent, log_prefix + "  ++ matches: ")
                    matches_arr.each_index do |matches_count_current|
                      match = matches_arr[matches_count_current]
                      count_sets = [[filenames_count_current,filenames_count_all],[matches_count_current,matches_arr_count_all]]
                      recalc_progress_by_counters(count_sets)
                      update_progress(@progressCurrent, log_prefix + "  >> @progressCurrent: " + @progressCurrent.to_s + ",   match: ['" + match.join("', '") + "']")
                    end
                  else
                  update_progress(@progressCurrent, log_prefix + "  -- NO MATCHES!")
                  end
                end
              end # filenames.each_index do |filenames_count_current|

            rescue Exception => e
              puts "Exception => e == " + e.inspect.to_s
              puts " ... backtrace == "
              e.backtrace.each do |a_step|
                puts " >> " + a_step.to_s
              end
            end
          end # startScriptHook

          def endScriptHook
            begin
              log_prefix = self.name + '#endScriptHook() ... '
              # log_prefix = '#endScriptHook() ... '
              update_progress(@progressCurrent, log_prefix + "STARTED");
              update_progress(100, log_prefix + "FINISHED");
            rescue Exception => e
              puts "Exception => e == " + e.inspect.to_s
              puts " ... backtrace == "
              e.backtrace.each do |a_step|
                puts " >> " + a_step.to_s
              end
            end
          end # endScriptHook

        end # RegexpSearch

    end # Utils
  end # Scripts
end # Scripting