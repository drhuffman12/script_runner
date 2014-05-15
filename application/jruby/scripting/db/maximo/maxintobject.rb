module Scripting
  module Db
    module Maximo

        require File.expand_path(File.join(File.dirname(__FILE__), 'mxtbl.rb'))
        # explicit shortcut specifying namespaced class:
        # Maxintobject = Scripting::Db::Maximo::Maxintobject unless defined?(Maxintobject)
        class Maxintobject < Scripting::Db::Maximo::Mxtbl

            set_table_name "maxintobject"
        end

    end # module Maximo
  end # module Db
end # module Scripting