module Scripting
  module Db
    module Maximo

        require File.expand_path(File.join(File.dirname(__FILE__), 'mxtbl.rb'))
        # explicit shortcut specifying namespaced class:
        # Maxservice = Scripting::Db::Maximo::Maxservice unless defined?(Maxservice)
        class Maxservice < Scripting::Db::Maximo::Mxtbl

            set_table_name "maxservice"

        end

    end # module Maximo
  end # module Db
end # module Scripting