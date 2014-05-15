module Scripting
  module Db
    module Maximo
      
        require 'rubygems'

        # gem 'ActiveRecord-JDBC'
        require 'active_record'
        require 'jdbc_adapter'

        require 'composite_primary_keys'

        require File.expand_path(File.join(File.dirname(__FILE__), 'mxtbl.rb'))
        # explicit shortcut specifying namespaced class:
        # Maxattribute = Scripting::Db::Maximo::Maxattribute unless defined?(Maxattribute)
        class Maxattribute < Scripting::Db::Maximo::Mxtbl
          
          set_table_name "maxattribute"
          set_primary_keys :objectname, :attributename

#          belongs_to :maxobject,
#                   # :class_name => 'ClassreferencesFgg',
#                   :foreign_key => 'objectname',
#                   :conditions => ['objectname = ?', self.objectname]
#                   # :conditions => ['objectname = ? AND attributename = ?', self.objectname, self.attributename]
#
#
#          has_one :maxattributecfg,
#                   :foreign_key => ['objectname', 'attributename'],
#                   :conditions => ['objectname = ? AND attributename = ?', self.objectname, self.attributename]

          def mx_data_type
            maximo_type = self.send('maxtype').upcase
            maximo_len = self.send('length')
            maximo_scale = self.send('scale')
            maximo_required = self.send('required')

            return {:maximo_type => maximo_type, :maximo_len => maximo_len, :maximo_scale => maximo_scale, :maximo_required => maximo_required}
          end

          def self.mx_data_type(objectname, attributename)
            record_set = Maxattribute.where(:objectname => objectname, :attributename => attributename)
#            record_set = Maxattribute.find(:conditions => {:objectname => maybe_maximo_table_name, :attributename => maybe_maximo_field_name})
            matching_record = nil
            if (record_set.nil?)
            else
              if (record_set.empty?)
              else
                matching_record = record_set.first
              end
            end
            if (matching_record.nil?)
              return nil
            else
#              maximo_type = matching_record.send('maxtype').upcase
#              maximo_len = matching_record.send('length')
#              maximo_scale = matching_record.send('scale')
#              maximo_required = matching_record.send('required')

#              return {:maximo_type => maximo_type, :maximo_len => maximo_len, :maximo_scale => maximo_scale, :maximo_required => maximo_required}
#              return 'mx:' + maximo_type
              return matching_record.mx_data_type
            end
          end

#          def self.find_attrib_details_for_table(table_name)
#            find(:all, :conditions => ['objectname = ?', table_name])
#          end

          # usage: Maxattribute.find_primarykeycolseq_for_table('someTableName')
          def self.find_primarykeycolseq_for_table(table_name)
            where(['objectname = ? AND primarykeycolseq IS NOT NULL', table_name]).select('primarykeycolseq, attributename').order('primarykeycolseq, attributename')
          end

          # usage: Maxattribute.find_autokeynames_for_table('someTableName')
          def self.find_autokeynames_for_table(table_name)
            where(['objectname = ? AND autokeyname IS NOT NULL', table_name]).select('autokeyname, attributename')
          end

          def self.find_for_table(table_name)
            where(['objectname = ?', table_name])
          end

        end # class Maxattribute

    end # module Maximo
  end # module Db
end # module Scripting