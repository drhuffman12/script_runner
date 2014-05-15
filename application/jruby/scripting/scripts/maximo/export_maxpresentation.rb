module Scripting
  module Scripts
    module Maximo

        require 'java'
        require 'rubygems'
  #      require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems'

        # require File.expand_path(File.join(File.dirname(__FILE__), '../../../core/db/mssql/mssql_table.rb'))
        MssqlTable = Scripting::Core::Db::Mssql::MssqlTable unless defined?(MssqlTable)

        YourDbServer = Scripting::Db::Maximo::YourDbServer unless defined?(YourDbServer)

        class ExportMaxpresentation < AbstractScript # EmptyScript # SampleScript # AbstractScript
          include Scripting
          include Scripting::Scripts::Common::ExceptionHandling # e.g.: def generic_exception_handler(e)
          include Scripting::Scripts::Common::Exportable # e.g.: def script_path(root_path, script_file_name, include_date = true, include_time = true)
          include Scripting::Scripts::Common::Xml
          include Scripting::Scripts::Common::Misc

          def self.description
            ret_val = self.class.name + ":"
            ret_val << AbstractScript.newline + AbstractScript.newline
            ret_val << "Export the screen xml's (from 'maxpresentation' table) from one of the NASA ESC Cloud Maximo's."
            ret_val << AbstractScript.newline
            ret_val << "Required initial params:"
            ret_val << AbstractScript.newline
            ret_val << " * 'from' setting"
            ret_val << AbstractScript.newline
            ret_val << "   * db conn info : a Maximo db"
            # ret_val << "   * path info : place containing the XML files"
            ret_val << AbstractScript.newline
            ret_val << " * 'to' setting"
            ret_val << AbstractScript.newline
            ret_val << "   * path info : where to place files for the 'maxpresentation' records"
            ret_val << AbstractScript.newline
            ret_val
          end # def self.description

          def initialize
#              super
#              jframeName = self.name
#              setTitle(jframeName)
#              super(self.name)
              super("ExportMaxpresentation")
            log.warn("This is " + self.class.name + ".")
            puts "ClassPathReferences... self.class.name == " + self.class.name
            puts "ClassPathReferences... self.methods.inspect == " + self.methods.inspect
            puts "ClassPathReferences... self.instance_variables.inspect == " + self.instance_variables.inspect
          end # def initialize

          def startScriptHook

            begin
              msg = "Exporting Maxpresentation records ..."
    #           log.warn(msg)

    #            progressCurrent
              update_progress(0, msg);

              #MssqlTable.connect(self.fromConnParams)
              YourDbServer.connect(self.fromConnParams)
              #MssqlTable.establish_connection(
              #  :adapter=> "jdbcmssql",
              #  :host => "10.153.79.37/maximo" # @conn_server.gsub('/',"\\"), # gsub for Windows servers
              #  :database=> @conn_database,
              #  :username => @conn_username,
              #  :password => password
              #)

              #record_set = MssqlTable.find_by_sql("select app, presentation from maxpresentation order by app")
              #record_set = MssqlTable.find_by_sql("select app from maxpresentation order by app")
              record_set = YourDbServer.find_by_sql("select app, presentation from maxpresentation where app is not null and presentation is not null order by app")
              record_set_count_all = record_set.count
              record_set.each_index do |record_set_count_current|
                rec = record_set[record_set_count_current]
                count_sets = [[record_set_count_current,record_set_count_all]]
                recalc_progress_by_counters(count_sets)
                msg = "app = '" + rec.app + "'"
                update_progress(@progressCurrent, msg)

                # Save File:
                file_path = self.toConnParams['path'].to_s
                #file_name = File.new(File.join(File.expand_path(file_path), rec.app.downcase + ".xml")).gsub('/',"\\"), # gsub for Windows servers
                include_date = true # false # true
                include_time = true # false # true
                file_name = (script_path(file_path, rec.app.to_s.downcase + ".xml", include_date, include_time)).gsub('/',"\\") # gsub for Windows servers
                    # D:\_NASA_\TFS\Maximo\baseline-ootb-7.1.1.8-zips\src\maxpresentation

                dest_file = File.new(file_name,"w")
                dest_file.write(rec.presentation.to_s)
                #dest_file.write(rec.presentation.to_s.gsub(/>(\s)*</,">\n<")) # to split the maximo-merged super long one-line xml file into multiple lines
                dest_file.flush
                dest_file.close
                #File.new(file_name, 'w') {|f| f.write(rec.presentation.to_s) }

              end
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
            YourDbServer.disconnect(self.fromConnParams)
#            @log.warn("bye from jruby")
#            updateProgress(80, "*>* bye from jruby");
#            puts("... bye from jruby")
            #fromConnParamsWithoutPw.inspect
            update_progress(100, msg);
          end # def endScriptHook

        end # class ExportMaxpresentation

    end # module Maximo
  end # module Scripts
end # module Scripting
