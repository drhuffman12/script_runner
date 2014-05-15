module Scripting
  module Db
    module Maximo

        require File.expand_path(File.join(File.dirname(__FILE__), 'mxtbl.rb'))

        # explicit shortcut specifying namespaced class:
        # Maxvars = Scripting::Db::Maximo::Maxvars unless defined?(Maxvars)
        class Maxvars < Scripting::Db::Maximo::Mxtbl

            set_table_name "maxvars"

          def self.dbgovernment
            a_record = self.first(:conditions => "varname = 'DBGOVERNMENT'", :select => 'varvalue')
            return (a_record.nil? ? '' : a_record.send('varvalue').to_s)
          end

          def self.maxupg
            a_record = self.first(:conditions => "varname = 'MAXUPG'", :select => 'varvalue')
            return (a_record.nil? ? '' : a_record.send('varvalue').to_s)
          end

          # alias in case the storage of the version changes to some other place
          def self.maximo_version
#            self.dbgovernment # This seems to be 'older' than what is in 'MAXUPG'.
            self.maxupg # This seems to be 'newer' than what is in 'DBGOVERNMENT'.
          end

        end # class Maxvars

    end # module Maximo
  end # module Db
end # module Scripting