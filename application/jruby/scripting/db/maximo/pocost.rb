module Scripting
  module Db
    module Maximo

        require File.expand_path(File.join(File.dirname(__FILE__), 'mxtbl.rb'))
#        require File.expand_path(File.join(File.dirname(__FILE__), 'poline.rb'))

#        Poline = Scripting::Db::Maximo::Poline unless defined?(Poline)

#        require 'composite_primary_keys'

        # explicit shortcut specifying namespaced class:
        # Pocost = Scripting::Db::Maximo::Pocost unless defined?(Pocost)
        class Pocost < Scripting::Db::Maximo::Mxtbl
          
          set_table_name "pocost"

          def self.max_prim_key
            "pocostid" # Should be an array, pulled from maxattributes, like...
#            if defined(@@max_uniq_key)
#              return @@max_uniq_key
#            else
#              prim_keys_hash = Maxattribute.find_primarykeycolseq_for_table(self.table_name)
#              @@max_uniq_key = ...
#            end
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