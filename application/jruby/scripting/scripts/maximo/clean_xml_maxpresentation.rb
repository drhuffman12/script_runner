module Scripting
  module Scripts
    module Maximo

        require 'java'
        require 'rubygems'
  #      require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems'

        # require File.expand_path(File.join(File.dirname(__FILE__), '../../../core/db/mssql/mssql_table.rb'))
        MssqlTable = Scripting::Core::Db::Mssql::MssqlTable unless defined?(MssqlTable)

        YourDbServer = Scripting::Db::Maximo::YourDbServer unless defined?(YourDbServer)

        class CleanXmlMaxpresentation < AbstractScript # EmptyScript # SampleScript # AbstractScript
          include Scripting
          include Scripting::Scripts::Common::ExceptionHandling # e.g.: def generic_exception_handler(e)
          include Scripting::Scripts::Common::Exportable # e.g.: def script_path(root_path, script_file_name, include_date = true, include_time = true)
          include Scripting::Scripts::Common::Xml
          include Scripting::Scripts::Common::Misc

          def self.description
            ret_val = self.class.name + ":"
            ret_val << AbstractScript.newline + AbstractScript.newline
            ret_val << "Clean the XML for easier file-comparison. (i.e.: add line-breaks between tags)"
            ret_val << AbstractScript.newline
            ret_val << "Required initial params:"
            ret_val << AbstractScript.newline
            ret_val << " * 'from' setting"
            ret_val << AbstractScript.newline
            ret_val << "   * path info : location of the files for the 'maxpresentation' records"
            ret_val << AbstractScript.newline
            ret_val
          end # def self.description

          def initialize
            super("CleanXmlMaxpresentation")
            log.warn("This is " + self.class.name + ".")
          end # def initialize

          def startScriptHook
            begin
              msg = "Cleaning Maxpresentation files ..."
              update_progress(0, msg);

              file_set = (Dir.entries(self.fromConnParams['path']) - ['.','..'])
              file_set_count_all = file_set.count
              file_set.each_index do |file_set_count_current|

                file_name = File.join(self.fromConnParams['path'],file_set[file_set_count_current])

                count_sets = [[file_set_count_current,file_set_count_all]]
                recalc_progress_by_counters(count_sets)
                msg = ".. file : '" + file_name + "'"
                update_progress(@progressCurrent, msg)

                new_lines = []
                new_file = File.open(file_name, "r") do |f|
                  f.each_line {|line| puts new_lines << line.gsub(/>(\s)*</,">\n<") }
                end
                File.open(file_name, 'w') {|f| f.write(new_lines) }

              end # file_set.each_index do |file_set_count_current|

#                # Dis-Conn from DB:
              @progressCurrent = 100
              update_progress(@progressCurrent, "startScriptHook() .. DONE!" + AbstractScript.newline)
#                Fmdtbl.disconnect(self.toConnParams)
            rescue Exception => e
              puts "Exception => e == " + e.inspect.to_s
              puts " ... backtrace == "
              e.backtrace.each do |a_step|
                puts " >> " + a_step.to_s
              end
            end

#            puts("... hello from jruby")
#            exec('gem list') # TODO: Why is this killing the ui?
            #fromConnParamsWithoutPw.inspect
          end # def startScriptHook

          def endScriptHook

            msg = "Done; Exiting!"
            #MssqlTable.disconnect(self.fromConnParams)
#            @log.warn("bye from jruby")
#            updateProgress(80, "*>* bye from jruby");
#            puts("... bye from jruby")
            #fromConnParamsWithoutPw.inspect
            update_progress(100, msg);
          end # def endScriptHook

        end # class CleanXmlMaxpresentation

    end # module Maximo
  end # module Scripts
end # module Scripting
