module Scripting
  module Db
    module Maximo
      
        require 'rubygems'
        require 'composite_primary_keys'
        require File.expand_path(File.join(File.dirname(__FILE__), '../../core/db/mssql/mssql_table.rb'))

        # Class for handling Maximo-ish table particulars
        # explicit shortcut specifying namespaced class:
        # Mxtbl = Scripting::Db::Maximo::Mxtbl unless defined?(Mxtbl)
        class Mxtbl < Scripting::Core::Db::Mssql::MssqlTable

          def self.is_fgg_db_server
            #['GVMAXCLUST', 'GVSDFGG442'].include?(conn_params['server'])
            #['GVMAXCLUST', 'GVSDFGG442'].include?(self.class.connection.current_server)
            #puts("self.connection.instance_variable_get(:@config) == " + self.connection.instance_variable_get(:@config).inspect)
            #['GVMAXCLUST', 'GVSDFGG442'].include?(self.connection.instance_variable_get(:@config)[:host])  # TODO: re-code to make this work!
          end

          set_table_name "maxvars" # to work-around for running generic sql
          set_primary_key "fgg_id"

          #def self.establish_connection(spec = nil)
          #  set_primary_key "fgg_id" if is_fgg_db_server  # TODO: re-code to make this work!
          #  super.establish_connection(spec)
          #end

          # TODO: refactor this method to use some combo of 'MaximoProject' ('name'), 'EnvironmentType' ('name'), and 'Envs' ('dbserver' and 'dbname') from 'Scripting::Db::FggMaximoDataloads'
          def self.conn_is_for_prod(conn_params)
            ret_val = ((['GVMAXCLUST'].include?(conn_params['server'])) and (['FGG_MAXIMO'].include?(conn_params['database'])))
          end

          # TODO: refactor this method to use some combo of 'MaximoProject' ('name'), 'EnvironmentType' ('name'), and 'Envs' ('dbserver' and 'dbname') from 'Scripting::Db::FggMaximoDataloads'
          # MUST call this from a sub-class of "Mxtbl"; a sub-class that is for an actual table!
          def self.tbl_is_in_prod
            srvr_and_db_info_all = self.find_by_sql("SELECT @@SERVERNAME as dbserver, db_name() as dbname")
            srvr_and_db_info = srvr_and_db_info_all[0]
            dbserver = srvr_and_db_info.send('dbserver')
            dbname = srvr_and_db_info.send('dbname')
            ret_val = ((['GVMAXCLUST'].include?(dbserver)) and (['FGG_MAXIMO'].include?(dbname)))
          end

        end

    end # module Maximo
  end # module Db
end # module Scripting