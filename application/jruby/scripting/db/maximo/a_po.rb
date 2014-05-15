module Scripting
  module Db
    module Maximo

        require File.expand_path(File.join(File.dirname(__FILE__), 'mxtbl.rb'))
#        require File.expand_path(File.join(File.dirname(__FILE__), 'po.rb'))
#
#        Po = Scripting::Db::Maximo::Po unless defined?(Po)

#        require 'composite_primary_keys'

        # APo = Scripting::Db::Maximo::APo unless defined?(APo)
        class APo < Scripting::Db::Maximo::Mxtbl
          
          set_table_name "a_po"

          # belongs_to :po, # TODO

#          def max_po
#            record_set = Po.where(:orgid => orgid, :siteid => siteid, :ponum => ponum)
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