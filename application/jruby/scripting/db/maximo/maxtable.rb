module Scripting
  module Db
    module Maximo

        require File.expand_path(File.join(File.dirname(__FILE__), 'mxtbl.rb'))
        # explicit shortcut specifying namespaced class:
        # Maxtable = Scripting::Db::Maximo::Maxtable unless defined?(Maxtable)
        class Maxtable < Scripting::Db::Maximo::Mxtbl
          
            set_table_name "maxtable"
            
#            belongs_to :maxobject,
#                   # :class_name => 'ClassreferencesFgg',
#                   :foreign_key => 'objectname',
#                   :conditions => ['objectname = ?', self.tablename]

            # usage: Maxtable.find_uniquecolumnname_for_table('someTableName')
            def self.find_uniquecolumnname_for_table(table_name)
              where(['tablename = ?', table_name]).select('uniquecolumnname')
            end
        end

    end # module Maximo
  end # module Db
end # module Scripting