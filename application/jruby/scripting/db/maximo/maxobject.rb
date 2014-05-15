module Scripting
  module Db
    module Maximo

        require File.expand_path(File.join(File.dirname(__FILE__), 'mxtbl.rb'))
        # explicit shortcut specifying namespaced class:
        # Maxobject = Scripting::Db::Maximo::Maxobject unless defined?(Maxobject)
        class Maxobject < Scripting::Db::Maximo::Mxtbl
          
            set_table_name "maxobject"
            
            has_many :maxattributes
            
#            belongs_to :maxobjectcfg,
#                   # :class_name => 'ClassreferencesFgg',
#                   :foreign_key => 'objectname',
#                   :conditions => ['objectname = ?', self.objectname]

        end

    end # module Maximo
  end # module Db
end # module Scripting