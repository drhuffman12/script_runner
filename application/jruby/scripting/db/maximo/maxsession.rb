module Scripting
  module Db
    module Maximo

        require File.expand_path(File.join(File.dirname(__FILE__), 'mxtbl.rb'))
        # explicit shortcut specifying namespaced class:
        # Maxsession = Scripting::Db::Maximo::Maxsession unless defined?(Maxsession)
        class Maxsession < Scripting::Db::Maximo::Mxtbl

          set_table_name "maxsession"

          # Maxsession.list_of_nodes
          def self.list_of_nodes
            maximo_server_user_id = 'MAXIMO'
            where('userid' => maximo_server_user_id).select('serverhost,servername,logindatetime,servertimestamp')
          end

          # Maxsession.list_of_nodes
          def self.list_of_nodes_per_db(dbname, dbschema)
            maximo_server_user_id = 'MAXIMO'
            order_fields = 'serverhost,servername'
            time_fields = 'logindatetime,servertimestamp'
            select_fields = [order_fields,time_fields].join(',')
#            where('userid' => maximo_server_user_id).select(select_fields)
            sql_code = "SELECT " + select_fields + " FROM "
            sql_code << "[" + dbname.to_s + "]" + "." unless [''].include?(dbname.to_s)
            sql_code << "[" + dbschema.to_s + "]" + "." unless [''].include?(dbschema.to_s)
            sql_code << "[" + self.table_name + "]"
            sql_code << " WHERE userid = '" + maximo_server_user_id + "'"
            sql_code << " ORDER BY " + order_fields
            puts "self.list_of_nodes_per_db('" + dbname + "','" + dbschema + "') ... sql_code == " + sql_code
            find_by_sql(sql_code)
          end
        end

    end # module Maximo
  end # module Db
end # module Scripting