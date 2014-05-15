module Scripting
  module Db
    module Maximo

        require File.expand_path(File.join(File.dirname(__FILE__), 'mxtbl.rb'))
#        require File.expand_path(File.join(File.dirname(__FILE__), 'po.rb'))

#        Po = Scripting::Db::Maximo::Po unless defined?(Po)

#        require 'composite_primary_keys'

        # explicit shortcut specifying namespaced class:
        # Postatus = Scripting::Db::Maximo::Postatus unless defined?(Postatus)
        class Postatus < Scripting::Db::Maximo::Mxtbl
          
          set_table_name "postatus"

          def self.max_prim_key
            "postatusid" # Should be an array, pulled from maxattributes
          end

#          def max_po
#            record_set = Po.where(:orgid => orgid, :siteid => siteid, :ponum => ponum)
#            if (record_set.empty?)
#              return nil
#            else
#              return record_set.first
#            end
#          end # def max_a_po

        end

    end # module Maximo
  end # module Db
end # module Scripting