module Scripting
  module Db
    module Maximo

        # require 'rubygems'
        # require 'composite_primary_keys'
        require File.expand_path(File.join(File.dirname(__FILE__), 'mxtbl.rb'))
        # explicit shortcut specifying namespaced class:
        # Maxattributecfg = Scripting::Db::Maximo::Maxattributecfg unless defined?(Maxattributecfg)
        class Maxattributecfg < Scripting::Db::Maximo::Mxtbl
          
          set_table_name "maxattributecfg"
          set_primary_keys :objectname, :attributename
                   
#          belongs_to :maxobjectcfg,
#                   # :class_name => 'ClassreferencesFgg',
#                   :foreign_key => 'objectname',
#                   :conditions => ['objectname = ?', self.objectname]
#
#          belongs_to :maxobject,
#                   # :class_name => 'ClassreferencesFgg',
#                   :foreign_key => 'objectname',
#                   :conditions => ['objectname = ?', self.objectname]
#                   # :conditions => ['objectname = ? AND attributename = ?', self.objectname, self.attributename]
#
#          belongs_to :maxattribute,
#                   :foreign_key => ['objectname', 'attributename'],
#                   :conditions => ['objectname = ? AND attributename = ?', self.objectname, self.attributename]
                   
          # "foo"
        end

    end # module Maximo
  end # module Db
end # module Scripting