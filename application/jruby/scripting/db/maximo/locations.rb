module Scripting
  module Db
    module Maximo

        require File.expand_path(File.join(File.dirname(__FILE__), 'mxtbl.rb'))

#        require 'composite_primary_keys'

        # Locations = Scripting::Db::Maximo::Locations unless defined?(Locations)
        class Locations < Scripting::Db::Maximo::Mxtbl
          
          set_table_name "locations"
          set_primary_key "fgg_id"

          # Use "find_by_sql", since Locations has a field called "type", which messes up ActiveRecord's 'automagical' sql-generating methods

          def self.max_prim_key
#            ['siteid', 'ponum'] # Should be an array, pulled from maxattributes
            Locations.find_primarykeycolseq_for_table(self.table_name).collect{|rec| rec.attributename}
          end

        end

    end # module Maximo
  end # module Db
end # module Scripting