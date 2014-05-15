module Scripting
  module Db
    module Maximo

        require File.expand_path(File.join(File.dirname(__FILE__), 'mxtbl.rb'))
        # explicit shortcut specifying namespaced class:
        # Maxrelationship = Scripting::Db::Maximo::Maxrelationship unless defined?(Maxrelationship)
        class Maxrelationship < Scripting::Db::Maximo::Mxtbl
          
            set_table_name "maxrelationship"
            set_primary_key 'maxrelationshipid'
            
        end

    end # module Maximo
  end # module Db
end # module Scripting