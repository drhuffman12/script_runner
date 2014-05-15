module Scripting
  module Db
    module Maximo

        require File.expand_path(File.join(File.dirname(__FILE__), 'mxtbl.rb'))
#        require File.expand_path(File.join(File.dirname(__FILE__), 'a_po.rb'))
#        require File.expand_path(File.join(File.dirname(__FILE__), 'poline.rb'))
#        require File.expand_path(File.join(File.dirname(__FILE__), 'postatus.rb'))

#        APo = Scripting::Db::Maximo::APo unless defined?(APo)
#        Poline = Scripting::Db::Maximo::Poline unless defined?(Poline)
#        Postatus = Scripting::Db::Maximo::Postatus unless defined?(Postatus)

#        require 'composite_primary_keys'

        # Po = Scripting::Db::Maximo::Po unless defined?(Po)
        class Po < Scripting::Db::Maximo::Mxtbl
          
          set_table_name "po"
          set_primary_key "fgg_id"

          def self.max_prim_key
            ['siteid', 'ponum'] # Should be an array, pulled from maxattributes
          end

#          def max_a_po
#            record_set = APo.where(:orgid => orgid, :siteid => siteid, :ponum => ponum)
##            if (record_set.empty?)
##              return nil
##            else
##              return record_set # .first
##            end
#          end
#
#          def max_polines
#            record_set = Poline.where(:orgid => orgid, :siteid => siteid, :ponum => ponum)
##            if (record_set.empty?)
##              return nil
##            else
##              return record_set # .first
##            end
#          end
#
#          def max_postatus
#            record_set = Postatus.where(:orgid => orgid, :siteid => siteid, :ponum => ponum)
##            if (record_set.empty?)
##              return nil
##            else
##              return record_set # .first
##            end
#          end

        end

    end # module Maximo
  end # module Db
end # module Scripting