module Scripting
  module Scripts
    module Maximo

        require 'java'
        require 'rubygems'
  #      require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems'

        # require File.expand_path(File.join(File.dirname(__FILE__), '../../../core/db/mssql/mssql_table.rb'))
        MssqlTable = Scripting::Core::Db::Mssql::MssqlTable unless defined?(MssqlTable)

        YourDbServer = Scripting::Db::Maximo::YourDbServer unless defined?(YourDbServer)

        class ExportLongdescriptionJpJt < AbstractScript # EmptyScript # SampleScript # AbstractScript
          include Scripting
          include Scripting::Scripts::Common::ExceptionHandling # e.g.: def generic_exception_handler(e)
          include Scripting::Scripts::Common::Exportable # e.g.: def script_path(root_path, script_file_name, include_date = true, include_time = true)
          include Scripting::Scripts::Common::Xml
          include Scripting::Scripts::Common::Misc

          def self.description
            ret_val = self.class.name + ":"
            ret_val << AbstractScript.newline + AbstractScript.newline
            ret_val << "Export the long descriptions from one of the NASA ESC Cloud Maximo's."
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
            ret_val << "   * path info : where to place files for the to-be-generated sql files"
            ret_val << AbstractScript.newline
            ret_val
          end # def self.description

          def initialize
#              super
#              jframeName = self.name
#              setTitle(jframeName)
#              super(self.name)
              super("ExportLongdescriptionJpJt")
            log.warn("This is " + self.class.name + ".")
            puts "ClassPathReferences... self.class.name == " + self.class.name
            puts "ClassPathReferences... self.methods.inspect == " + self.methods.inspect
            puts "ClassPathReferences... self.instance_variables.inspect == " + self.instance_variables.inspect
          end # def initialize

          def gen_sql_jobplan_longdesc(ldownertable, ldownercol, ldkey, ldtext)
#            sql_txt = <<txt
#DECLARE
#
#BEGIN
#
#END;
#txt
            return ldtext # should return as sql code, but for now, we'll just export the content of the ldtext field.
            #set_ld_sql = "insert into longdescription (ldownertable, ldownercol, ldkey, ldtext) values ("
            #set_ld_sql << "'" + ldownertable + "', "
            #set_ld_sql << "'" + ldownercol + "', "
            #set_ld_sql << "'" + ldkey + "', "
            #set_ld_sql << "'" + ldtext + "')"
          end

          def gen_sql_jobtask_longdesc(ldownertable, ldownercol, ldkey, ldtext)
            return ldtext # should return as sql code, but for now, we'll just export the content of the ldtext field.
          end

          def startScriptHook

            begin
              msg = "Exporting LongDescription records ..."
    #           log.warn(msg)

    #            progressCurrent
              update_progress(0, msg);

              #MssqlTable.connect(self.fromConnParams)
              YourDbServer.connect(self.fromConnParams)

              # jpnum_list = "'1036','1037','1038','1039','1040'"
              get_ld_sql = <<sql_code
select ldownertable, ldownercol, ldkey, ldtext, orgid, siteid, jpnum
from longdescription
  join jobplan on
    longdescription.ldownertable = 'JOBPLAN'
    and
    longdescription.ldownercol = 'DESCRIPTION'
    and
    longdescription.ldkey = jobplan.jobplanid
where jpnum in ('1036','1037','1038','1039','1040') order by ldownertable, ldkey
sql_code

              # JOBPLAN:
              # record_set = YourDbServer.find_by_sql("select ldownertable, ldownercol, ldkey, ldtext from longdescription where ldownertable = 'JOBPLAN' and ldownercol = 'DESCRIPTION' and ldkey in (select jobplanid from jobtask where jpnum in (" + jpnum_list + ")) order by ldownertable, ldkey")
              record_set = YourDbServer.find_by_sql(get_ld_sql)
              record_set_count_all = record_set.count
              record_set.each_index do |record_set_count_current|
                rec = record_set[record_set_count_current]
                count_sets = [[record_set_count_current,record_set_count_all]]
                recalc_progress_by_counters(count_sets)
                msg = "ldownertable = '" + rec.ldownertable + "'"
                msg << ", ldownercol = '" + rec.ldownercol + "'"
                msg << ", ldkey = '" + rec.ldkey.to_s + "'"
                msg << ", ldtext = '" + rec.ldtext + "'"
                update_progress(@progressCurrent, msg)

                # Save File:
                file_path = self.toConnParams['path'].to_s
                #file_name = File.new(File.join(File.expand_path(file_path), rec.app.downcase + ".xml")).gsub('/',"\\"), # gsub for Windows servers
                include_date = true # false # true
                include_time = true # false # true
                # file_name = (script_path(file_path, rec.ldownertable.to_s.downcase + "." + rec.ldownercol.to_s.downcase + "." + rec.ldkey.to_s.downcase + ".sql", include_date, include_time)).gsub('/',"\\") # gsub for Windows servers
                file_name_relative = rec.ldownertable.to_s.downcase + "." + rec.ldownercol.to_s.downcase + "." + rec.ldkey.to_s.downcase + "(" + rec.jpnum.to_s.downcase + ").sql"
                file_name = (script_path(file_path, file_name_relative, include_date, include_time)).gsub('/',"\\") # gsub for Windows servers


                dest_file = File.new(file_name,"w")
                dest_file.write(gen_sql_jobplan_longdesc(rec.ldownertable,rec.ldownercol,rec.ldkey,rec.ldtext))
                #dest_file.write(rec.presentation.to_s.gsub(/>(\s)*</,">\n<")) # to split the maximo-merged super long one-line xml file into multiple lines
                dest_file.flush
                dest_file.close
                #File.new(file_name, 'w') {|f| f.write(rec.presentation.to_s) }

              end

              # JOBTASK:
              get_ld_sql = <<sql_code
select ldownertable, ldownercol, ldkey, ldtext, orgid, siteid, jpnum, jptask
from longdescription
  join jobtask on
    longdescription.ldownertable = 'JOBTASK'
    and
    longdescription.ldownercol = 'DESCRIPTION'
    and
    longdescription.ldkey = jobtask.jobtaskid
where jpnum in ('1036','1037','1038','1039','1040') order by ldownertable, ldkey
sql_code
              # record_set = YourDbServer.find_by_sql("select ldownertable, ldownercol, ldkey, ldtext from longdescription where ldownertable = 'JOBTASK' and ldownercol = 'DESCRIPTION' and ldkey in (select jobtaskid from jobtask where jpnum in (" + jpnum_list + ")) order by ldownertable, ldkey")
              record_set = YourDbServer.find_by_sql(get_ld_sql)
              record_set_count_all = record_set.count
              record_set.each_index do |record_set_count_current|
                rec = record_set[record_set_count_current]
                count_sets = [[record_set_count_current,record_set_count_all]]
                recalc_progress_by_counters(count_sets)
                msg = "ldownertable = '" + rec.ldownertable + "'"
                msg << ", ldownercol = '" + rec.ldownercol + "'"
                msg << ", ldkey = '" + rec.ldkey.to_s + "'"
                msg << ", ldtext = '" + rec.ldtext + "'"
                update_progress(@progressCurrent, msg)

                # Save File:
                file_path = self.toConnParams['path'].to_s
                #file_name = File.new(File.join(File.expand_path(file_path), rec.app.downcase + ".xml")).gsub('/',"\\"), # gsub for Windows servers
                include_date = true # false # true
                include_time = true # false # true
                # file_name = (script_path(file_path, rec.ldownertable.to_s.downcase + "." + rec.ldownercol.to_s.downcase + "." + rec.ldkey.to_s.downcase + ".sql", include_date, include_time)).gsub('/',"\\") # gsub for Windows servers
                file_name_relative = rec.ldownertable.to_s.downcase + "." + rec.ldownercol.to_s.downcase + "." + rec.ldkey.to_s.downcase + "(" + rec.jpnum.to_s.downcase + "." + rec.jptask.to_s.downcase + ").sql"
                file_name = (script_path(file_path, file_name_relative, include_date, include_time)).gsub('/',"\\") # gsub for Windows servers

                dest_file = File.new(file_name,"w")
                dest_file.write(gen_sql_jobtask_longdesc(rec.ldownertable,rec.ldownercol,rec.ldkey,rec.ldtext))
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
