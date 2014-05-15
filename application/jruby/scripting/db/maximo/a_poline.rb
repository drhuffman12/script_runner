module Scripting
  module Db
    module Maximo

        require File.expand_path(File.join(File.dirname(__FILE__), 'mxtbl.rb'))
#        require File.expand_path(File.join(File.dirname(__FILE__), 'poline.rb'))

#        Poline = Scripting::Db::Maximo::Poline unless defined?(Poline)

#        require 'composite_primary_keys'

        # explicit shortcut specifying namespaced class:
        # APoline = Scripting::Db::Maximo::APoline unless defined?(APoline)
        class APoline < Scripting::Db::Maximo::Mxtbl
          
          set_table_name "a_poline"

#          def max_poline
#            record_set = Poline.where(:orgid => orgid, :siteid => siteid, :ponum => ponum, :polinenum => polinenum)
#            if (record_set.empty?)
#              return nil
#            else
#              return record_set.first
#            end
#          end
          
        end

    end # module Maximo
  end # module Db
end # module Scripting