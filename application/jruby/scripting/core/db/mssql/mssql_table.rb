module Scripting
  module Core
    module Db
      module Mssql #  Scripting::Core::Db::Mssql

        require 'java'
        require 'rubygems'
        require 'set' # See "https://github.com/rails/rails/pull/1780"

        # for ActiveRecord:
        # gem 'ActiveRecord-JDBC'
        require 'active_record'
        require 'jdbc_adapter'

        # See "http://stackoverflow.com/questions/1090801/how-do-i-get-the-last-sql-query-performed-by-activerecord-in-ruby-on-rails"
        # Add helper method to get the last query ran. Usage:
        #   ActiveRecord::Base.connection.last_query
        ActiveRecord::ConnectionAdapters::AbstractAdapter.class_eval do
          attr_reader :last_query
          def log_with_last_query(sql, name, &block)
            @last_query = [sql, name]
            log_without_last_query(sql, name, &block)
          end
          alias_method_chain :log, :last_query
        end

        # MssqlTable = Scripting::Core::Db::Mssql::MssqlTable unless defined?(MssqlTable)
        class MssqlTable < ActiveRecord::Base

          attr_reader :conn_server, :conn_database, :conn_username
#        module MssqlTable
      #    set_table_name "SR7476_Steps"
      #    set_primary_key "fgg_id"

          def conn_server
            @conn_server ||= ''
          end

          def conn_database
            @conn_database ||= ''
          end

          def conn_username
            @conn_username ||= ''
          end

          def self.conn_port # will be ignored if 'conn_instance' is not nil
            1433 # typical
          end

          def self.conn_instance
            nil
          end

          def self.connect(conn_params)
            begin

              @conn_status = Hash.new unless defined? @conn_status
              @conn_server = conn_params['server'].to_s
              # @conn_port = conn_params['port'].to_s  + conn_port
              #@conn_port = conn_port unless conn_port.nil?
              @conn_database = conn_params['database'].to_s
              @conn_username = conn_params['username'].to_s
              password = conn_params['password'].to_s
#              db = conn_params['database'].to_s

              conn_attempt_info = "[server '" + @conn_server + "', database '" + @conn_database + "', username '" + @conn_username + "'] for class '" + self.class.name + "'"  # self.class.name
              puts "Attempting to connect to " + conn_attempt_info
          #    if (["connecting","connected"].include?(@conn_status))
              if (["connected"].include?(@conn_status[{:server => @conn_server,:database => @conn_database,:username => @conn_username}]))
                puts "... ALREADY connected to " + conn_attempt_info
              else
                @conn_status[{:server => @conn_server,:database => @conn_database,:username => @conn_username}] = "connecting"
#                ActiveRecord::Base.establish_connection(
                self.establish_connection(
                  :adapter=> "jdbcmssql",
                  :host => @conn_server.gsub('/',"\\"), # gsub for Windows servers
                  # :port => ((conn_port.nil?) ? 1433 : conn_port),
                  :port => self.conn_port,
                  :instance => self.conn_instance, # 'maximo',
                  :database=> @conn_database,
                  :username => @conn_username,
                  :password => password
                )
                @conn_status[{:server => @conn_server,:database => @conn_database,:username => @conn_username}] = "connected"
                puts "... connected to " + conn_attempt_info
              end
            rescue Exception => e
              puts "Exception => e == " + e.inspect.to_s
              puts " ... backtrace == "
              e.backtrace.each do |a_step|
                puts " >> " + a_step.to_s
              end

            end
          end # def connect

          def self.disconnect(conn_params)
            begin
              @conn_server = conn_params['server'].to_s
              @conn_database = conn_params['database'].to_s
              @conn_username = conn_params['username'].to_s
              conn_attempt_info = "[server '" + @conn_server + "', database '" + @conn_database + "', username '" + @conn_username + "'] for class '" + self.class.name + "'"

              if (@conn_status.nil?)
                raise("Warning: No associated @conn_status (none declared yet)! (Did the user cancel before connecting to db?)")
              end
              puts "Attempting to disconnect from " + conn_attempt_info
          #    if (["disconnecting","disconnecting"].include?(@conn_status))
#              if (["disconnecting"].include?(@conn_status[{:server => server,:database => database,:username => username}]))
              if (["disconnected"].include?(@conn_status[{:server => @conn_server,:database => @conn_database,:username => @conn_username}]))
                puts "... ALREADY disconnected from " + conn_attempt_info
                raise("Error: ALREADY disconnected from " + conn_attempt_info)
              else
                @conn_status[{:server => @conn_server,:database => @conn_database,:username => @conn_username}] = "disconnecting"
#                ActiveRecord::Base.clear_active_connections! if defined?(ActiveRecord::Base)
                self.clear_active_connections!
                @conn_status[{:server => @conn_server,:database => @conn_database,:username => @conn_username}] = "disconnected"
                puts "... disconnected from " + conn_attempt_info
              end
            rescue Exception => e
              puts "Exception => e == " + e.inspect.to_s
              puts " ... backtrace == "
              e.backtrace.each do |a_step|
                puts " >> " + a_step.to_s
              end

            end
          end # def connect

          #### The below methods in this class are intended for 'REAL' tables, not just this abstract table class!
          def self.databases
            # find_by_sql("SELECT name FROM master..sysdatabases")
            # find_by_sql("EXEC sp_databases")
#            find_by_sql('select name from sys.databases order by name')
            find_by_sql('select name from sys.sysdatabases order by name')
          end

          def self.tables_per_db(dbname)
            # (tables ||= find_by_sql("exec sp_tables"))
#            find_by_sql("exec sp_tables")
            find_by_sql("SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' WHERE TABLE_CATALOG = '" + dbname + "'")
          end

          def self.db_has_table(dbname,tblname)
            # (tables ||= find_by_sql("exec sp_tables"))
#            find_by_sql("exec sp_tables")
            sql_code = "SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_CATALOG = '" + dbname + "' AND TABLE_NAME = '" + tblname + "'"
            puts "sql_code == " + sql_code
            results = find_by_sql("SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_CATALOG = '" + dbname + "' AND TABLE_NAME = '" + tblname + "'")
            puts "results.inspect == " + results.inspect
            puts "results.count == " + results.count.to_s
            results.count > 0
          end

          def self.tables
            # (tables ||= find_by_sql("exec sp_tables"))
#            find_by_sql("exec sp_tables")
            find_by_sql('select name from sys.Tables order by name')
          end

          def self.fields_per_table(dbname, tblname)

#            SELECT
#              table_name=sysobjects.name,
#              column_name=syscolumns.name,
#              datatype=systypes.name,
#              length=syscolumns.length,
#              prec=syscolumns.prec,
#              scale=syscolumns.scale
#              --,
#              --xprec=syscolumns.xprec,
#              --xscale=syscolumns.xscale,
#              --sysobjects.*,
#              --syscolumns.*
#            FROM sysobjects
#            JOIN syscolumns ON sysobjects.id = syscolumns.id
#            JOIN systypes ON syscolumns.xtype=systypes.xtype

            sql_str = "SELECT table_name=sysobjects.name, column_name=syscolumns.name, datatype=systypes.name, length=syscolumns.length, prec=syscolumns.prec, scale=syscolumns.scale FROM sysobjects JOIN syscolumns ON sysobjects.id = syscolumns.id JOIN systypes ON syscolumns.xtype=systypes.xtype"
            sql_str << "WHERE sysobjects.name = '" + tblname + "'" unless (tblname.nil?)

            find_by_sql(sql_str)
          end

        end # class MssqlTable

      end # module Mssql
    end # module Db
  end # module Core
end # module Scripting