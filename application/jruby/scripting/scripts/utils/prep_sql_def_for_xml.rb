module Scripting
  module Scripts
    module Utils

        require 'java'
        require 'rubygems'
        require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems'
        require 'active_support' # Used here for 'ActiveSupport::JSON.encode(...)'
        # require 'json'

        require 'fileutils'

        Mxtbl = Scripting::Db::Maximo::Mxtbl unless defined?(Mxtbl)
        Maxattribute = Scripting::Db::Maximo::Maxattribute unless defined?(Maxattribute)

        Fmdtbl = Scripting::Db::FggMaximoDataloads::Fmdtbl unless defined?(Fmdtbl)
#        Sr7476PoXml = Scripting::Db::FggMaximoDataloads::Sr07476::Sr7476PoXml unless defined?(Sr7476PoXml)
#        Sr07476XmlMatpointerface = Scripting::Db::FggMaximoDataloads::Sr07476::Sr07476XmlMatpointerface unless defined?(Sr07476XmlMatpointerface)
#        Sr07476XmlMatpointerfaceHeader = Scripting::Db::FggMaximoDataloads::Sr07476::Sr07476XmlMatpointerfaceHeader unless defined?(Sr07476XmlMatpointerfaceHeader)

        # Scripting::Scripts::Utils::PrepSqlDefForXml
        class PrepSqlDefForXml < AbstractScript # EmptyScript # SampleScript # AbstractScript
          include Scripting
          include Scripting::Scripts::Common::ExceptionHandling # e.g.: def generic_exception_handler(e)
          include Scripting::Scripts::Common::Exportable # e.g.: def script_path(root_path, script_file_name, include_date = true, include_time = true)
          include Scripting::Scripts::Common::Xml
          include Scripting::Scripts::Common::Misc

            def self.description
              ret_val = self.class.name + ":"
              ret_val << AbstractScript.newline + AbstractScript.newline
              ret_val << "Required initial params:"
              ret_val << AbstractScript.newline
              ret_val << " * 'from' path setting"
              ret_val << AbstractScript.newline
              ret_val << " * 'to' path setting"
              ret_val << AbstractScript.newline + AbstractScript.newline
              ret_val << "This is to guess a db schema for given set of xml (for pulling interface xml files into db tables for datafixing)."
              ret_val << AbstractScript.newline + AbstractScript.newline
              ret_val << "THIS ASSUMES THAT ALL THE XML FILES WITHIN THE 'FROM' PATH HAVE A COMMON 'SUPER' XML SCHEMA!"
              ret_val
            end # def self.description

          def initialize
            super("PrepSqlDefForXml")

            begin
              log.warn(AbstractScript.newline + "Initializing " + self.class.name + ".")

            rescue Exception => e
              puts "Exception => e == " + e.inspect.to_s
              puts " ... backtrace == "
              e.backtrace.each do |a_step|
                puts " >> " + a_step.to_s
              end
            end
          end

          def force_folder_for_path(path)
            begin
              if (File.directory?(path))
                folder_path = File.expand_path(path)
              else
                folder_path = File.expand_path(File.dirname(path))
              end
              folder_path
            rescue Exception => e
              raise e
            end
          end

          def debug_show_file_content(file_content)
            section_label = ": ... file_content == "
            update_progress(@progressCurrent, count_sets_to_s(count_sets) + section_label + file_content.to_s + AbstractScript.newline)
            puts section_label + file_content[0..99] + '...'
            puts ''

            file_as_hash = Hash.from_xml(file_content)
            section_label = ": ... file_as_hash == "
            update_progress(@progressCurrent, count_sets_to_s(count_sets) + section_label + file_as_hash.to_s + AbstractScript.newline)
            puts section_label + file_as_hash.to_s[0..99] + '...'
            puts ''

            file_as_json = file_as_hash.to_json
            section_label = ": ... file_as_json == "
            update_progress(@progressCurrent, count_sets_to_s(count_sets) + section_label + file_as_json.to_s + AbstractScript.newline)
            puts section_label + file_as_json.to_s[0..99] + '...'
            puts ''
          end

          def flag_content_type(xpath, elem_text)
            update_progress(@progressCurrent, "flag_content_type(xpath == '" + xpath + "', elem_text == '" + elem_text + "') ..." + AbstractScript.newline + AbstractScript.newline)
            field_type_flags = @tag_db_defs[xpath]
            # Init value if key doesn't exist:
            field_type_flags['max_len'] = 0         unless (field_type_flags.key?('max_len'))
            field_type_flags['has_nums'] = false    unless (field_type_flags.key?('has_nums'))
            field_type_flags['has_decimal'] = false unless (field_type_flags.key?('has_decimal'))
            field_type_flags['dec_pre_digits'] = 0  unless (field_type_flags.key?('dec_pre_digits'))
            field_type_flags['dec_post_digits'] = 0 unless (field_type_flags.key?('dec_post_digits'))
            field_type_flags['has_date'] = false    unless (field_type_flags.key?('has_date'))

            # Set flag for length:
            elem_text_len = elem_text.length
            old_max_len = field_type_flags['max_len']
            field_type_flags['max_len'] = ((elem_text_len > old_max_len) ? elem_text_len : old_max_len)

            # Set flags for data types:
            old_has_nums    = field_type_flags['has_nums']
            old_has_decimal = field_type_flags['has_decimal']
            old_has_date    = field_type_flags['has_date']
            old_dec_pre_digits    = field_type_flags['dec_pre_digits']
            old_dec_post_digits    = field_type_flags['dec_post_digits']

            elem_has_nums = has_exactly_one_regexp_match(/[((\-)(\+))*0-9]*/,elem_text)
            elem_has_decimal = has_exactly_one_regexp_match(/((\-)(\+))*[0-9]+((\.)[0-9]*)+?/,elem_text)
            if (elem_has_decimal)
              pre_and_post = elem_text.split('.')
              elem_dec_pre_digits = pre_and_post[0].to_s.length
              elem_dec_post_digits = pre_and_post[1].to_s.length
            else
              elem_dec_pre_digits = 0
              elem_dec_post_digits = 0
            end
            elem_has_date = confirm_is_date(xpath, elem_text)

            field_type_flags['has_nums'] = ((old_has_nums or elem_has_nums) ? true : false)
            field_type_flags['has_decimal'] = ((old_has_decimal or elem_has_decimal) ? true : false)
            field_type_flags['dec_pre_digits'] = ((elem_dec_pre_digits > old_dec_pre_digits) ? elem_dec_pre_digits : old_dec_pre_digits)
            field_type_flags['dec_post_digits'] = ((elem_dec_post_digits > old_dec_post_digits) ? elem_dec_post_digits : old_dec_post_digits)


            field_type_flags['has_date'] = ((old_has_date or elem_has_date) ? true : false)

#            update_progress(@progressCurrent, ": xpath == " + xpath + AbstractScript.newline + AbstractScript.newline)
#            update_progress(@progressCurrent, ": elem_text == " + elem_text + AbstractScript.newline + AbstractScript.newline)
            update_progress(@progressCurrent, ": @tag_db_defs[xpath].inspect == " + field_type_flags.inspect + AbstractScript.newline + AbstractScript.newline)
          end # def flag_content_type(xpath, elem_text)

          # IMPORTANT!: keep all blacklisted items as lowercase text!
          def datetime_blacklisted_tags_names
            ["description", "fgg_mm_ponum", "linecost", "loadedcost", "messageid", "orderqty", "polinenum", "purreqlinenum", "purreqrnum", "remark", "reqdeliverydate", "siteid", "unitcost", "warehouse"]
          end

          def confirm_is_date(xpath, elem_text)
            node_name = xpath.split('/').last.to_s.downcase
#            update_progress(@progressCurrent, "confirm_is_date('" + xpath + "', '" + elem_text + "): node_name == '" +node_name + "'" + field_type_flags.inspect + AbstractScript.newline + AbstractScript.newline)
            elem_has_date = false
            unless (datetime_blacklisted_tags_names.include?(node_name))
              begin
                elem_has_date = !(Date.parse(elem_text).nil?) # TODO: Exclude if has more than just the date in 'elem_text'
              rescue
                # leave as: has_date = false
              end
            end

            update_progress(@progressCurrent, "confirm_is_date('" + xpath + "', '" + elem_text + "): node_name == '" + node_name + "', elem_has_date == " + elem_has_date.to_s + "" + AbstractScript.newline + AbstractScript.newline)

            return elem_has_date
          end

#          def build_tag_defs(count_sets, xpath, elem, @tag_db_defs)  
          def build_tag_defs(count_sets, xpath, elem) 
            # @tag_db_defs
            # update_progress(@progressCurrent, count_sets_to_s(count_sets) + ": elem.name == " + elem.name + AbstractScript.newline + AbstractScript.newline)
            update_progress(@progressCurrent, count_sets_to_s(count_sets) + ": xpath == " + xpath + AbstractScript.newline + AbstractScript.newline)
              
            unless @tag_db_defs.key?(xpath)
              @tag_db_defs[xpath] = Hash.new
            end
            elem_name = elem.name
            elem_text = elem.text.to_s
#            @tag_db_defs[xpath] = flag_content_type(xpath, elem_text)
            flag_content_type(xpath, elem_text)
            
            child_elems = elem.elements.to_a
            child_elems_count_all = child_elems.count
            child_elems.each_index do |child_elem_count_current|

              count_sets.push([child_elem_count_current,child_elems_count_all])
              recalc_progress_by_counters(count_sets)
              # child = child_elems[child_elem_count_current + 1] # The element indexes are 1+ based vs 0+ based
              # update_progress(@progressCurrent, count_sets_to_s(count_sets) + ": xpath == " + xpath + AbstractScript.newline + AbstractScript.newline)
              child = child_elems[child_elem_count_current] # The element indexes are 1+ based vs 0+ based

              if (child.nil?)
                update_progress(@progressCurrent, count_sets_to_s(count_sets) + xpath + ": child_elems[" + child_elem_count_current + "] IS NIL!!!" + AbstractScript.newline + AbstractScript.newline)
              else
                build_tag_defs(count_sets, xpath + '/' + child.name, child)
              end

              count_sets.pop
            end

          end # def build_tag_defs(count_sets, xpath, elem)

          def debug_show_tag_db_defs
            # update_progress(@progressCurrent, count_sets_to_s(count_sets) + ": @tag_db_defs.to_json == " + @tag_db_defs.to_json + AbstractScript.newline + AbstractScript.newline)
            tag_db_defs_str = AbstractScript.newline

#                tag_db_defs_str << "@tag_db_defs['" + k + "'] == " + v.to_json + AbstractScript.newline
#              update_progress(@progressCurrent, "@tag_db_defs == " + AbstractScript.newline)
            keys_sorted = @tag_db_defs.keys.sort
#              @tag_db_defs.each_pair do |k,v|
            keys_sorted.each do |k|
              v = @tag_db_defs[k]
              tag_db_defs_str << "@tag_db_defs['" + k + "'] == " + v.to_json + AbstractScript.newline
#                update_progress(@progressCurrent, "@tag_db_defs['" + k + "'] == " + v.to_json + AbstractScript.newline + AbstractScript.newline)
            end
            update_progress(@progressCurrent, "@tag_db_defs == " + tag_db_defs_str + AbstractScript.newline + AbstractScript.newline)
          end

          def gen_table_defs(tbl_prefix_underscored, id_field_name)
            tbl_prefix_underscored = tbl_prefix_underscored.to_s.downcase # just to be sure it is all lowercase!
            tbl_prefix_camelized = ''
            tbl_prefix_underscored.split('_').each do |sub_name_part|
              tbl_prefix_camelized << sub_name_part.to_s.capitalize
            end

#            @tag_db_defs[xpath]['max_len'] = 0         unless (@tag_db_defs[xpath].key?('max_len'))
#            @tag_db_defs[xpath]['has_nums'] = false    unless (@tag_db_defs[xpath].key?('has_nums'))
#            @tag_db_defs[xpath]['has_decimal'] = false unless (@tag_db_defs[xpath].key?('has_decimal'))
#            @tag_db_defs[xpath]['dec_pre_digits'] = 0  unless (@tag_db_defs[xpath].key?('dec_pre_digits'))
#            @tag_db_defs[xpath]['dec_post_digits'] = 0 unless (@tag_db_defs[xpath].key?('dec_post_digits'))
#            @tag_db_defs[xpath]['has_date'] = false    unless (@tag_db_defs[xpath].key?('has_date'))
            table_defs = Hash.new
            keys_sorted = @tag_db_defs.keys.sort
            keys_sorted_count_all = keys_sorted.count
            keys_sorted.each_index do |i|
              k = keys_sorted[i]

              nodes = k.split('/')
              nodes = nodes - [''] # safeguard against empty nodes, like the root
              # nodes_qty = nodes.length
              if (nodes.length > 0)
                field_name = nodes.pop.downcase # assume the last nod is the data field
                
                # parent_node_set = nodes - [nodes.last]
                parent_node_set = nodes.clone
                parent_node_set.pop
                xpath_parent_table = '/' + parent_node_set.join('/') # nodes.join('/') # '/' + nodes.join('/')
                
                xpath_table = '/' + nodes.join('/') # nodes.join('/') # '/' + nodes.join('/')

                unless (['/'].include?(xpath_table))

                  field_flags = @tag_db_defs[k]

                  # Add table to defs if not exist yet:
                  unless (table_defs.key?(xpath_table))
                    table_defs[xpath_table] = Hash.new

                    xpath_as_table_name_camelized = ''
                    xpath_as_table_name_underscored = tbl_prefix_underscored + '_' + (nodes.join('_').downcase)
                    xpath_as_table_name_underscored.split('_').each do |sub_name_part|
                      xpath_as_table_name_camelized << sub_name_part.to_s.capitalize
                    end
                    table_defs[xpath_table][:xpath_parent_table] = xpath_parent_table
                    table_defs[xpath_table][:plural_class_name] = xpath_as_table_name_camelized
                    table_defs[xpath_table][:plural_name] = xpath_as_table_name_underscored
                    table_defs[xpath_table][:options] = {:skip_timestamps => false}
                    table_defs[xpath_table][:model_attributes] = []
                    table_defs[xpath_table][:model_attributes] << {:name => id_field_name, :ar_type => ':integer', :sql_type => '[int] IDENTITY(1,1) NOT NULL'}
                    if (['/'].include?(xpath_parent_table))
                      table_defs[xpath_table][:model_attributes] << {:name => 'file_root', :ar_type => ':string', :sql_type => '[varchar](255)'}
                      table_defs[xpath_table][:model_attributes] << {:name => 'sub_path', :ar_type => ':string', :sql_type => '[varchar](255)'}
                      table_defs[xpath_table][:model_attributes] << {:name => 'file_name', :ar_type => ':string', :sql_type => '[varchar](255)'}
                      table_defs[xpath_table][:model_attributes] << {:name => 'file_content', :ar_type => ':text', :sql_type => '[xml]'} # '[xml](.)'}
#                      table_defs[xpath_table][:model_attributes] << {:name => 'orig_is_old_or_new', :ar_type => ':string', :sql_type => '[varchar](1)'}
#                      table_defs[xpath_table][:model_attributes] << {:name => 'old_in_maximo', :ar_type => ':integer', :sql_type => '[smallint](1)'}
#                      table_defs[xpath_table][:model_attributes] << {:name => 'new_in_maximo', :ar_type => ':integer', :sql_type => '[smallint](1)'}
                    else
                      table_defs[xpath_table][:model_attributes] << {:name => table_defs[xpath_parent_table][:plural_name] + '_' + id_field_name, :ar_type => ':integer', :sql_type => '[int] NULL'} # :sql_type => '[int] NOT NULL'}
                    end
                    update_progress(@progressCurrent, "Created 'table' Hash for: table_defs[#{xpath_table}]" + AbstractScript.newline)
                  end

                  # Check if this is a parent node
                  is_parent_node = false
                  if (i < keys_sorted_count_all - 1)
                    k_len = k.length
                    key_next = keys_sorted[i+1]
                    key_next_len = key_next.length
                    if (key_next_len > k_len)
                      look_for_slash = key_next[0..k_len]
                      if ([k + '/'].include?(look_for_slash))
                        is_parent_node = true
                      end
                    end
                  end

                  unless (is_parent_node)
                    len = field_flags['max_len']
                    len_str = len.to_s
                    if (field_flags['has_date'])
                      ar_type = ':datetime'
                      sql_type = '[datetime]'
                    elsif (field_flags['has_decimal'])
                      scale = field_flags['dec_post_digits']
                      precision = field_flags['dec_pre_digits'] + scale
                      scale_str = scale.to_s
                      precision_str = precision.to_s
                      ar_type = ':decimal, :precision => ' + precision_str + ', :scale => ' + scale_str
                      sql_type = '[decimal](' + precision_str + ',' + scale_str + ')'
                    elsif (field_flags['has_nums'])
                      ar_type = ':integer'
                      sql_type = '[int]'
                    else
                      ar_type = ':string, :limit => ' + len_str
                      sql_type = '[varchar](' + len_str + ')'
                    end
                    mew_ma = {:name => field_name, :ar_type => ar_type, :sql_type => sql_type}
                    table_defs[xpath_table][:model_attributes] << mew_ma
                    update_progress(@progressCurrent, "table_defs[xpath_table][:model_attributes] << '" + ActiveSupport::JSON.encode(mew_ma) + "'" + AbstractScript.newline)

                  end
                end
              end
            end
            return table_defs
          end # def gen_table_defs(tbl_prefix_underscored)

          def get_sql_data_type_per_maximo(maybe_maximo_table_name, maybe_maximo_field_name)
            record_set = Maxattribute.where(:objectname => maybe_maximo_table_name, :attributename => maybe_maximo_field_name)
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
              maximo_type = matching_record.send('maxtype').upcase
              maximo_len = matching_record.send('length')
              maximo_scale = matching_record.send('scale')
              maximo_required = matching_record.send('required')

              return {:maximo_type => maximo_type, :maximo_len => maximo_len, :maximo_scale => maximo_scale, :maximo_required => maximo_required}
#              return 'mx:' + maximo_type
            end
          end

          def export_table_defs(tbl_prefix_underscored, id_field_name, table_defs, target_folder)
            update_progress(@progressCurrent, "Preping SQL code to go into: '" + target_folder + "'" + AbstractScript.newline + AbstractScript.newline)

            # TODO: create 'target_folder' if it doesn't exist...
            unless (File.directory?(target_folder))
              FileUtils.mkdir_p(target_folder)
            end


#            Mxtbl.connect(self.fromConnParams)

            table_defs.each_pair do |k,v|

              # TODO: Save table_defs to file as JSON, so can re-load it later (for use with loading xml content from po files)

              unless (v.key?(:model_attributes))
              else
                if (v[:model_attributes].count > 0)
                  field_code = ''
                  v[:model_attributes].each do |ma|
                    # TODO: Attempt to get from Maximo
                    maybe_maximo_table_name = k.split('/').last
                    maybe_maximo_field_name = ma[:name]
                      # update_progress(@progressCurrent, "maybe_maximo_table_name: '" + maybe_maximo_table_name + "', maybe_maximo_field_name: '" + maybe_maximo_field_name + "'" + AbstractScript.newline + AbstractScript.newline)

                    sql_data_type_per_maximo = get_sql_data_type_per_maximo(maybe_maximo_table_name, maybe_maximo_field_name)
                      # update_progress(@progressCurrent, "sql_data_type_per_maximo: '" + sql_data_type_per_maximo.to_s + "'" + AbstractScript.newline + AbstractScript.newline)
                    if (sql_data_type_per_maximo.nil?)
                      # update_progress(@progressCurrent, "Using guessed data type" + AbstractScript.newline + AbstractScript.newline)
                      field_code << '    [' + ma[:name] + '] ' + ma[:sql_type] + ',' + AbstractScript.newline
                    else
                      mx_type = sql_data_type_per_maximo[:maximo_type]
                      mx_len = sql_data_type_per_maximo[:maximo_len]
                      mx_scale = sql_data_type_per_maximo[:maximo_scale]
                      len_str = '(' + mx_len.to_s + ')'
                      len2_str = '(' + mx_len.to_s + ',' + mx_scale.to_s + ')'
                      sql_type = case mx_type
                        when 'ALN', 'GL', 'LOWER', 'UPPER'
                          'varchar' + len_str
                        when 'AMOUNT', 'DECIMAL'
                          'decimal' + len2_str
                        when 'BLOB'
                          'image' + len_str
                        when 'CLOB', 'LONGALN'
                          'text' + len_str
                        when 'DATETIME'
                          'datetime'
                        when 'DATE'
                          'date'
                        when 'TIME'
                          'time'
                        when 'DURATION', 'FLOAT'
                          'float' + len_str
                        when 'INTEGER'
                          'integer'
                        when 'SMALLINT', 'FLOAT', 'YORN'
                          'smallint'
                        else
                          '(MX:TBD)'
                      end
                      # update_progress(@progressCurrent, "Using sql_data_type_per_maximo!" + AbstractScript.newline + AbstractScript.newline)
                      field_code << '    [' + ma[:name] + '] ' + sql_type + ',' + ' /* mx:' + sql_data_type_per_maximo[:maximo_type] + ' */ ' + AbstractScript.newline
                    end
                  end
                      # update_progress(@progressCurrent, 'field_code == ' + field_code + AbstractScript.newline)
                  sql_code = <<END_OF_STRING
-- SQL Generated on #{Time.now.to_s} by user #{self.toConnParams['username']}
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[FGG_MAXIMO_DATALOADS].[dbo].[#{v[:plural_name]}]') AND type in (N'U'))
BEGIN
	DROP TABLE [FGG_MAXIMO_DATALOADS].[dbo].[#{v[:plural_name]}]
END
ELSE
BEGIN
	CREATE TABLE [FGG_MAXIMO_DATALOADS].[dbo].[#{v[:plural_name]}](
#{field_code}
 CONSTRAINT [#{v[:plural_name]}_#{id_field_name}_pk] PRIMARY KEY NONCLUSTERED
(
  [fgg_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END
GO

SET ANSI_PADDING OFF
GO
END_OF_STRING

                  file_name = "Create_" + v[:plural_class_name] + ".sql"
                  file_path = target_folder + '/' + file_name
                  file_path.gsub!('/',"\\") # for Windows file paths

                  update_progress(@progressCurrent, "Saving SQL code to: '" + file_path + "'" + AbstractScript.newline + AbstractScript.newline)

                  file = File.open(file_path,'w+')
                  file.write(sql_code)
                  file.flush
                  file.close
                  update_progress(@progressCurrent, "Saved!" + AbstractScript.newline + AbstractScript.newline)
                end # if (v["model_attributes"].count > 0)
              end # if (v.key?("model_attributes"))
            end # table_defs.each_pair do |k,v|
          end # def export_table_defs(tbl_prefix_underscored, id_field_name, table_defs, target_folder)

          def gather_tag_db_defs(count_sets, file_names, from_path, to_path, tbl_prefix_underscored, id_field_name)
            file_names_count_all = file_names.count
            count_sets.push([0,3])
            file_names.each_index do |file_names_count_current|

              # temp for debugging:
              skip_next = false
#                if (file_names_count_current > 3)
#                  skip_next = true
#                end

              unless (skip_next)

                count_sets.push([file_names_count_current,file_names_count_all])
                recalc_progress_by_counters(count_sets)

                file_name = file_names[file_names_count_current]
                file_name_len = file_name.length

                update_progress(@progressCurrent, count_sets_to_s(count_sets) + ": file_name == " + file_name.to_s + AbstractScript.newline)
                puts file_name
                puts ''

                from_file_path = File.expand_path(file_name)
                sub_path = File.dirname(file_name).gsub(from_path,"")

                if (File.file?(file_name))

                  file_content = IO.read(file_name)
                  # debug_show_file_content(file_content)
                  doc = REXML::Document.new(file_content)
                  xpath = '' # '/' # '//'
                  elem = doc

#                  @tag_db_defs[xpath] = build_tag_defs(count_sets, xpath, elem)
                  build_tag_defs(count_sets, xpath, elem)
                end


                count_sets.pop
              end # if (file_names_count_current > 3)
            end # file_names.each_index do |file_names_count_current|
            count_sets.pop

            debug_show_tag_db_defs

            count_sets.push([1,3])
            table_defs = gen_table_defs(tbl_prefix_underscored, id_field_name)

            table_defs.each_pair do |k,v|
              update_progress(@progressCurrent, "table_defs[" + k + "] == " + ActiveSupport::JSON.encode(v) + AbstractScript.newline + AbstractScript.newline)
            end
            count_sets.pop

            count_sets.push([2,3])
#              target_folder = File.dirname(__FILE__) + '/' + tbl_prefix_underscored  # Should be a param associated with the 'to_folder'
            target_folder = to_path + '/' + tbl_prefix_underscored
              update_progress(@progressCurrent, "target_folder == " + target_folder + AbstractScript.newline + AbstractScript.newline)
            export_table_defs(tbl_prefix_underscored, id_field_name, table_defs, target_folder)
            count_sets.pop
          end

#          def read_xml_into_tables(count_sets, file_names, from_path, table_defs, tbl_prefix_underscored, id_field_name)
          def read_xml_into_tables(count_sets, file_names, from_path) # , table_defs, tbl_prefix_underscored, id_field_name)
          end # read_xml_into_tables(count_sets, file_names, from_path)

          def startScriptHook
            begin
              msg = "About to " + self.class.name + " from '" + self.fromConnParams['path'].to_s + "' to '" + self.toConnParams['path'].to_s + "'..."
              from_path = force_folder_for_path(self.fromConnParams['path'].to_s)
              to_path = force_folder_for_path(self.toConnParams['path'].to_s)
              tbl_prefix_underscored = 'sr07476_xml' # TODO: Should be a param associated with the 'from_folder'
              id_field_name = 'fgg_id'

              Mxtbl.connect(self.fromConnParams)
              Fmdtbl.connect(self.toConnParams)

              @tag_db_defs = Hash.new # [] # Hash.new
#              @tag_db_defs['/'] = Hash.new
              count_sets = []
              file_names = Dir.glob(from_path + '/**/*.xml') # TODO: change to handle sub-folders

#              count_sets = [0,2]
              gather_tag_db_defs(count_sets, file_names, from_path, to_path, tbl_prefix_underscored, id_field_name)

#              count_sets = [1,2]
#              read_xml_into_tables(count_sets, file_names, from_path, table_defs, tbl_prefix_underscored, id_field_name)
#              read_xml_into_tables(count_sets, file_names, from_path)


            rescue Exception => e
              puts "Exception => e == " + e.inspect.to_s
              puts " ... backtrace == "
              e.backtrace.each do |a_step|
                puts " >> " + a_step.to_s
              end
            end
          end

          def endScriptHook
            begin
              msg = "Done."

              update_progress(@progressCurrent, msg)

              Mxtbl.disconnect(self.fromConnParams)
              Fmdtbl.disconnect(self.toConnParams)

              update_progress(100, msg)
            rescue Exception => e
              puts "Exception => e == " + e.inspect.to_s
              puts " ... backtrace == "
              e.backtrace.each do |a_step|
                puts " >> " + a_step.to_s
              end
            end
          end

        end # class PrepSqlDefForXml

    end # Utils
  end # Scripts
end # Scripting
