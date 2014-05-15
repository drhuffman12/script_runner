module Scripting
  module Db
    module Maximo

        require File.expand_path(File.join(File.dirname(__FILE__), 'mxtbl.rb'))
        # explicit shortcut specifying namespaced class:
        # Crontaskdef = Scripting::Db::Maximo::Crontaskdef unless defined?(Crontaskdef)
        class Crontaskdef < Mxtbl
          
            set_table_name "crontaskdef"
            set_primary_key "crontaskname"
            
        end

    end # module Maximo
  end # module Db
end # module Scripting