module Scripting
  module Db
    module Maximo

        require File.expand_path(File.join(File.dirname(__FILE__), 'mxtbl.rb'))
        # explicit shortcut specifying namespaced class:
        # Maxobjectcfg = Scripting::Db::Maximo::Maxobjectcfg unless defined?(Maxobjectcfg)
        class Maxobjectcfg < Scripting::Db::Maximo::Mxtbl

            set_table_name "maxobjectcfg"
            
            has_many :maxattributecfgs
            
#            belongs_to :maxobject,
#                   # :class_name => 'ClassreferencesFgg',
#                   :foreign_key => 'objectname',
#                   :conditions => ['objectname = ?', self.objectname]
                   
        end

    end # module Maximo
  end # module Db
end # module Scripting