module Scripting
  module Db
    module Maximo

        require File.expand_path(File.join(File.dirname(__FILE__), 'mxtbl.rb'))
#        require File.expand_path(File.join(File.dirname(__FILE__), 'matrectrans.rb'))

#        Matrectrans = Scripting::Db::Maximo::Matrectrans unless defined?(Matrectrans)

        # AMatrectrans = Scripting::Db::Maximo::AMatrectrans unless defined?(AMatrectrans)
        class AMatrectrans < Scripting::Db::Maximo::Mxtbl
          
          set_table_name "a_matrectrans"

#          def max_matrectrans
#            record_set = Matrectrans.where(:matrectransid => matrectransid)
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