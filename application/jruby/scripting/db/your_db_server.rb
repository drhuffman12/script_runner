module Scripting
  module Db

    require 'java'
    require 'rubygems'
#      require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems'

    require File.expand_path(File.join(File.dirname(__FILE__), '../core/db/mssql/mssql_table.rb'))
    MssqlTable = Scripting::Core::Db::Mssql::MssqlTable unless defined?(MssqlTable)

    # YourDbServer = Scripting::Db::YourDbServer unless defined?(YourDbServer)
    class YourDbServer < MssqlTable # db_server_baseline_prod

      def self.conn_port # will be ignored if 'conn_instance' is not nil
	#1433 # typical
	1433
      end

      def self.conn_instance
	'maximo'
      end

      set_table_name "maxvars" # to work-around for running generic sql

    end # class YourDbServer

  end # module Scripts
end # module Scripting
