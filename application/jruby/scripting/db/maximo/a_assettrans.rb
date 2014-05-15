module Scripting
  module Db
    module Maximo

        require File.expand_path(File.join(File.dirname(__FILE__), 'mxtbl.rb'))
#        require File.expand_path(File.join(File.dirname(__FILE__), 'assettrans.rb'))
        # explicit shortcut specifying namespaced class:
#        Assettrans = Scripting::Db::Maximo::Assettrans unless defined?(Assettrans)
        
        # TODO: Turn on auditing for 'assettrans' to add this table to Maximo! (and then uncomment the subclassing of 'Scripting::Db::Maximo::Mxtbl')

        # AAssettrans = Scripting::Db::Maximo::AAssettrans unless defined?(AAssettrans)
        class AAssettrans # < Scripting::Db::Maximo::Mxtbl

#          def max_assettrans
#            record_set = Assettrans.where(:assettransid => assettransid)
#            if (record_set.empty?)
#              return nil
#            else
#              return record_set.first
#            end
#          end # def max_a_po

        end

    end # module Maximo
  end # module Db
end # module Scripting