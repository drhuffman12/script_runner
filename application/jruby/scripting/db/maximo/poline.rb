module Scripting
  module Db
    module Maximo

        require File.expand_path(File.join(File.dirname(__FILE__), 'mxtbl.rb'))
#        require File.expand_path(File.join(File.dirname(__FILE__), 'a_poline.rb'))
#        require File.expand_path(File.join(File.dirname(__FILE__), 'pocost.rb'))
#        require File.expand_path(File.join(File.dirname(__FILE__), 'po.rb'))
#        require File.expand_path(File.join(File.dirname(__FILE__), 'matrectrans.rb'))

#        APoline = Scripting::Db::Maximo::APoline unless defined?(APoline)
#        Pocost = Scripting::Db::Maximo::Pocost unless defined?(Pocost)
#        Po = Scripting::Db::Maximo::Po unless defined?(Po)
#        Matrectrans = Scripting::Db::Maximo::Matrectrans unless defined?(Matrectrans)

#        require 'composite_primary_keys'

        # explicit shortcut specifying namespaced class:
        # Poline = Scripting::Db::Maximo::Poline unless defined?(Poline)
        class Poline < Scripting::Db::Maximo::Mxtbl
          
          set_table_name "poline"

          def self.max_prim_key
            "polineid" # Should be an array, pulled from maxattributes
          end
#          set_primary_keys :ponum, :polinenum
#
#          belongs_to :po,
#                   # :class_name => 'ClassreferencesFgg',
#                   :foreign_key => 'ponum',
#                   :conditions => ['ponum = ?', self.objectname]
#                   # :conditions => ['objectname = ? AND attributename = ?', self.objectname, self.attributename]
#
#
#          has_one :maxattributecfg,
#                   :foreign_key => ['objectname', 'attributename'],
#                   :conditions => ['objectname = ? AND attributename = ?', self.objectname, self.attributename]


#          def max_a_poline
#            record_set = Poline.where(:orgid => orgid, :siteid => siteid, :ponum => ponum, :polinenum => polinenum)
##            if (record_set.empty?)
##              return nil
##            else
##              return record_set.first
##            end
#          end # def max_a_po
#
#          def max_po
#            record_set = Po.where(:orgid => orgid, :siteid => siteid, :ponum => ponum)
#            if (record_set.empty?)
#              return nil
#            else
#              return record_set.first
#            end
#          end # def max_a_po
#
#          def max_pocost
#            record_set = Pocost.where(:orgid => orgid, :siteid => siteid, :ponum => ponum, :polinenum => polinenum)
##            if (record_set.empty?)
##              return nil
##            else
##              return record_set.first
##            end
#          end
#
#          def max_matrectrans
#            record_set = Matrectrans.where(:orgid => orgid, :siteid => siteid, :ponum => ponum, :polinenum => polinenum)
##            if (record_set.empty?)
##              return nil
##            else
##              return record_set.first
##            end
#          end

        end # class Poline

    end # module Maximo
  end # module Db
end # module Scripting