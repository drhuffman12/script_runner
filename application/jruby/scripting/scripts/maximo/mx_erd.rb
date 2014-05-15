module Scripting
  module Scripts
    module Maximo

        require 'java'
        require 'rubygems'

        require File.expand_path(File.join(File.dirname(__FILE__), 'mx_graph_dot_obj.rb'))

        # require File.expand_path(File.join(File.dirname(__FILE__), '../../../core/db/mssql/mssql_table.rb'))
        MssqlTable = Scripting::Core::Db::Mssql::MssqlTable unless defined?(MssqlTable)

        YourDbServer = Scripting::Db::Maximo::YourDbServer unless defined?(YourDbServer)


        class MxErd < AbstractScript # EmptyScript # SampleScript # AbstractScript
          include Scripting
          include Scripting::Scripts::Common::ExceptionHandling # e.g.: def generic_exception_handler(e)
          include Scripting::Scripts::Common::Exportable # e.g.: def script_path(root_path, script_file_name, include_date = true, include_time = true)
          include Scripting::Scripts::Common::Xml
          include Scripting::Scripts::Common::Misc

          def self.description
            ret_val = self.class.name + ":"
            ret_val << AbstractScript.newline + AbstractScript.newline
            ret_val << "Generate dynamic partial ERD of Maximo."
            ret_val << AbstractScript.newline
            ret_val << "Required initial params:"
            ret_val << AbstractScript.newline
            ret_val << " * 'from' setting"
            ret_val << AbstractScript.newline
            ret_val << "   * db conn info : a Maximo db"
            ret_val << AbstractScript.newline
            ret_val << " * 'to' setting"
            ret_val << AbstractScript.newline
            ret_val << "   * path info : where to place generated ERDs"
            ret_val << AbstractScript.newline
            ret_val
          end # def self.description

          def initialize
#              super
#              jframeName = self.name
#              setTitle(jframeName)
#              super(self.name)
              super("MxErd")
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

              #record_set = MssqlTable.find_by_sql("select app, presentation from maxpresentation order by app")
              #record_set = MssqlTable.find_by_sql("select app from maxpresentation order by app")

              mx_table_list = []
              if ([''].include?(self.fromConnParams['path'].to_s))
                update_progress(@progressCurrent, "no list in from path")
                # mx_table_list = ['ASSET','JOBPLAN','JOBTASK','JPASSETSPLINK','MAXGROUP','MAXROLE','PERSON','PERSONGROUP','PM','SIGOPTION','WFACTION','WFASSIGNMENT','WFCALLSTACK','WFINSTANCE','WFINTERACTION','WFNODE','WFPROCESS','WFTRANSACTION','WOACTIVITY','WOANCESTOR','WOCHANGE','WORKFLOWMAP','WORKORDER']
                # mx_table_list = ['ASSET','ASSETTOPOCACHE','JOBPLAN','JOBTASK','JPASSETSPLINK','MAXGROUP','MAXROLE','PERSON','PERSONGROUP','PM','SIGOPTION','WFACTION','WFASSIGNMENT','WFCALLSTACK','WFINSTANCE','WFINTERACTION','WFNODE','WFPROCESS','WFTRANSACTION','WOACTIVITY','WOANCESTOR','WOCHANGE','WORKFLOWMAP','WORKORDER']
                # mx_table_list = ['ASSET','JOBPLAN','JOBTASK','WORKORDER','PERSON','PERSONGROUP','PM','SIGOPTION','WFACTION','WFASSIGNMENT']
                # mx_table_list = ['ASSET','JOBPLAN','JOBTASK','WORKORDER','PERSON','PERSONGROUP','PM','SIGOPTION','WFACTION','WFASSIGNMENT', 'WOACTIVITY', 'WOCHANGESTATUS']
                #mx_table_list = ['ASSET','JOBPLAN','JOBTASK','WORKORDER','PERSON']
                mx_table_list = ['ASSET','JOBPLAN','JOBTASK','WORKORDER','PERSON','PERSONGROUP','PM','SIGOPTION','WFACTION','WFASSIGNMENT', 'WFNODE','WFTASK','WOACTIVITY', 'WOCHANGESTATUS','MAXUSER','LABOR','LABORAUTH','MAXGROUP','GROUPUSER']
                
              else
                update_progress(@progressCurrent, "found list in from path")
                mx_table_list = (self.fromConnParams['path']).gsub('"',"").gsub("'","").gsub(/\s/,"").split(",")
              end

              mx_table_list_joined = mx_table_list.join("','")

              sql_code = "select name, parent, child, whereclause, remarks from maxrelationship"
              sql_code << " where parent in ('"
              sql_code << mx_table_list_joined
              sql_code << "') and child in ('"
              sql_code << mx_table_list_joined
              sql_code << "')"
              sql_code << " and parent != child"

              @mxg = MxGraphDotObj.new

              #list_parent_tables = []
              #list_children_tables = []
              #list_all_tables = []
              #list_connections = []

                update_progress(@progressCurrent, sql_code)

              record_set = YourDbServer.find_by_sql(sql_code)
              record_set_count_all = record_set.count
              record_set.each_index do |record_set_count_current|
                rec = record_set[record_set_count_current]
                count_sets = [[record_set_count_current,record_set_count_all]]
                recalc_progress_by_counters(count_sets)
                msg = "name = '" + rec.name + "'"
                msg << ", parent = '" + rec.parent + "'"
                msg << ", child = '" + rec.child + "'"
                msg << ", whereclause = '" + rec.whereclause.to_s + "'"
                msg << ", remarks = '" + rec.remarks.to_s + "'"
                update_progress(@progressCurrent, msg)

                #list_parent_tables << rec.parent
                #list_children_tables << rec.child
                #list_connections << {:name => rec.name,
                #                     :parent => rec.parent, :child => rec.child,
                #                     :description => rec.whereclause.to_s}


                mxrel_name = rec.name
                mxrel_parent = rec.parent
                mxrel_child = rec.child
                mxrel_where = rec.whereclause.to_s
                @mxg.add_mxrel(mxrel_name, mxrel_parent, mxrel_child, mxrel_where)


              end

              # Save File:
              file_path = self.toConnParams['path'].to_s
              #file_name = File.new(File.join(File.expand_path(file_path), rec.app.downcase + ".xml")).gsub('/',"\\"), # gsub for Windows servers
              include_date = true # false # true
              include_time = true # false # true
              file_name_without_ext = "mxrel-partial-map"
              msg = @mxg.gen_pdf_and_svg(file_path, include_date, include_time, file_name_without_ext)

              #file_name = (script_path(file_path, "mxrel-partial-map.dot", include_date, include_time)).gsub('/',"\\") # gsub for Windows servers
              #    # D:\_NASA_\TFS\Maximo\baseline-ootb-7.1.1.8-zips\src\maxpresentation
              #
              #dest_file = File.new(file_name,"w")
              #
              #msg = "@mxg.to_s == " + @mxg.to_s
              #
              #dest_file.write(@mxg.to_s)
              ##dest_file.write(rec.presentation.to_s.gsub(/>(\s)*</,">\n<")) # to split the maximo-merged super long one-line xml file into multiple lines
              #dest_file.flush
              #dest_file.close
              ##File.new(file_name, 'w') {|f| f.write(rec.presentation.to_s) }

              update_progress(@progressCurrent, msg)

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

        end # class MxErd

    end # module Maximo
  end # module Scripts
end # module Scripting
