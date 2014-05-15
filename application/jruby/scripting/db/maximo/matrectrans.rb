module Scripting
  module Db
    module Maximo

        require File.expand_path(File.join(File.dirname(__FILE__), 'mxtbl.rb'))
#        require File.expand_path(File.join(File.dirname(__FILE__), 'a_matrectrans.rb'))
#        require File.expand_path(File.join(File.dirname(__FILE__), 'poline.rb'))
#        require File.expand_path(File.join(File.dirname(__FILE__), 'assettrans.rb'))

#        AMatrectrans = Scripting::Db::Maximo::AMatrectrans unless defined?(AMatrectrans)
#        Poline = Scripting::Db::Maximo::Poline unless defined?(Poline)
#        Assettrans = Scripting::Db::Maximo::Assettrans unless defined?(Assettrans)

        # Matrectrans = Scripting::Db::Maximo::Matrectrans unless defined?(Matrectrans)
        class Matrectrans < Scripting::Db::Maximo::Mxtbl
          
          set_table_name "matrectrans"

          def self.max_prim_key
            "matrectransid" # Should be an array, pulled from maxattributes
          end

#          def max_a_matrectrans
#            record_set = AMatrectrans.where(:matrectransid => matrectransid)
##            if (record_set.empty?)
##              return nil
##            else
##              return record_set.first
##            end
#          end # def max_a_po
#
#          def max_poline
#            record_set = Poline.where(:orgid => orgid, :siteid => siteid, :ponum => ponum, :polinenum => polinenum)
#            if (record_set.empty?)
#              return nil
#            else
#              return record_set.first
#            end
#          end
#
#          def max_assettrans
#            record_set = Assettrans.where(:matrectransid => matrectransid)
##            if (record_set.empty?)
##              return nil
##            else
##              return record_set.first
##            end
#          end # def max_a_po

          def is_parent
            receiptref.nil?
          end

          def is_child
            !is_parent
          end

          def max_matrectrans_parent
            record_set = Matrectrans.where(:matrectransid => receiptref)
            if (record_set.empty?)
              return nil
            else
              return record_set.first
            end
          end

          def max_matrectrans_children
            record_set = Matrectrans.where(:receiptref => matrectransid)
#            if (record_set.empty?)
#              return nil
#            else
#              return record_set.first
#            end
          end

        end

    end # module Maximo
  end # module Db
end # module Scripting