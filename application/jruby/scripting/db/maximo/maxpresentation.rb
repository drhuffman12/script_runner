module Scripting
  module Db
    module Maximo

        require File.expand_path(File.join(File.dirname(__FILE__), 'mxtbl.rb'))
        # explicit shortcut specifying namespaced class:
        # Maxpresentation = Scripting::Db::Maximo::Maxpresentation unless defined?(Maxpresentation)
        class Maxpresentation < Scripting::Db::Maximo::Mxtbl

            set_table_name "maxpresentation"
            
        end

    end # module Maximo
  end # module Db
end # module Scripting