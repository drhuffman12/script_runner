module Scripting
  module Db
    module Maximo

        require File.expand_path(File.join(File.dirname(__FILE__), 'mxtbl.rb'))
#        require File.expand_path(File.join(File.dirname(__FILE__), 'a_assettrans.rb'))
#        require File.expand_path(File.join(File.dirname(__FILE__), 'matrectrans.rb'))

#        AAssettrans = Scripting::Db::Maximo::AAssettrans unless defined?(AAssettrans)
#        Matrectrans = Scripting::Db::Maximo::Matrectrans unless defined?(Matrectrans)

        # Assettrans = Scripting::Db::Maximo::Assettrans unless defined?(Assettrans)
        class Assettrans < Scripting::Db::Maximo::Mxtbl

          set_table_name "assettrans"

          def self.max_prim_key
            "assettransid" # Should be an array, pulled from maxattributes
          end

#          def max_assettrans
#            record_set = AAssettrans.where(:assettransid => assettransid)
##            if (record_set.empty?)
##              return nil
##            else
##              return record_set.first
##            end
#          end # def max_a_po
#
#          def max_matrectrans
#            record_set = Matrectrans.where(:matrectransid => matrectransid)
##            if (record_set.empty?)
##              return nil
##            else
##              return record_set.first
##            end
#          end # def max_a_po

        end

    end # module Maximo
  end # module Db
end # module Scripting