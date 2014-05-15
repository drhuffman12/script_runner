module Scripting
  module Db
    module Maximo

        require File.expand_path(File.join(File.dirname(__FILE__), 'mxtbl.rb'))

#        require 'composite_primary_keys'

        # Inventory = Scripting::Db::Maximo::Inventory unless defined?(Inventory)
        class Inventory < Scripting::Db::Maximo::Mxtbl
          
          set_table_name "inventory"
          set_primary_key "fgg_id"

          def self.max_prim_key
#            ['siteid', 'ponum'] # Should be an array, pulled from maxattributes
            Maxattribute.find_primarykeycolseq_for_table(self.table_name).collect{|rec| rec.attributename}
          end


          def store_loc_descr
            # Use "find_by_sql", since Locations has a field called "type", which messes up ActiveRecord's 'automagical' sql-generating methods
            loc_descr_set = Locations.find_by_sql("SELECT description FROM locations WHERE locations.[orgid] = '#{self.orgid}' AND locations.[siteid] = '#{self.siteid}' AND locations.[location] = '#{self.location}'")
            desc = loc_descr_set.collect{|rec| rec.description}.join(', ')
            return self.location + "[" + desc + "]"
          end

        end

    end # module Maximo
  end # module Db
end # module Scripting