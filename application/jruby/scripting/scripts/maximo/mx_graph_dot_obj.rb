module Scripting
  module Scripts
    
    module Maximo

        require 'java'
        require 'rubygems'

        require File.expand_path(File.join(File.dirname(__FILE__), 'graph_dot_obj.rb'))

        class MxGraphDotObj < GraphDotObj
          attr_accessor :table_names

          def initialize( indent_str = nil, initial_indent = nil, params_code_graph = nil, params_code_node = nil)
            super(indent_str, initial_indent, params_code_graph, params_code_node)
            @rel_color_set = [ 'dodgerblue4' , 'forestgreen', 'crimson', 'darkorchid3' , 'goldenrod3']
            #@rel_color_set_len = @rel_color_set.length
          end # def initialize(..)

          def wrap(s, width=78)
            s.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n")
          end

          def wrap2(s, width=78)
            s.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\n")
          end

          def crop(s, width=78)
            if (s.length > width)
              return s[0..(width - 1)] + '..'
            else
              return s
            end
          end

          #"node0":rel_parent -> "node0":rel_child
          #[
          #  label = "ORIGAPP[ MAXAPPS : MAXAPPS ]\n WHERE app = :originalapp\n"
          #  id = 5
          #  labelloc = "c"
          #  style="dashed"
          #  lhead = "(parent)"
          #  ltail = "(child)"
          #  color = "dodgerblue4"
          #  fontcolor = "dodgerblue4"
          #];
          # @param mxrel_name [String]
          # @param mxrel_parent [String]
          # @param mxrel_child [String]
          # @param mxrel_where [String]
          def add_mxrel(mxrel_name, mxrel_parent, mxrel_child, mxrel_where)

            # add/update node:
            #add_node(mxrel_parent, {'shape' => '"record"', "label" => '"' + mxrel_parent + '"'})
            add_node(mxrel_parent, {'shape' => '"record"'})
            add_node(mxrel_child, {'shape' => '"record"'})

            # add edge:
            from_edge_name = mxrel_parent
            from_edge_key = 'rel_parent'
            to_edge_name = mxrel_child
            to_edge_key = 'rel_child'
            params_code_an_edge = Hash.new

            #where_len = mxrel_where.length
            #where_col_max = 80
            #where_rows = (where_len / where_col_max)
            #'\\' + 'n'
            #params_code_an_edge['label'] = '"' + mxrel_name + '[ ' + mxrel_parent + ' : ' + mxrel_child + ' ]' + "\n"
            #params_code_an_edge['label'] << ' WHERE ' + mxrel_where + "\n" + '"' unless mxrel_where.nil?
            params_code_an_edge['label'] = '"' + mxrel_name + '[ ' + mxrel_parent + ' : ' + mxrel_child + ' ]' + '\\' + 'n'
            #params_code_an_edge['label'] << ' WHERE ' + wrap(mxrel_where) + '\\' + 'n' + '"' unless mxrel_where.nil?
            #params_code_an_edge['label'] << ' WHERE ' + wrap2(mxrel_where) + '\\' + 'n' + '"' unless mxrel_where.nil?
            params_code_an_edge['label'] << ' WHERE ' + crop(mxrel_where) + '\\' + 'n' + '"' unless mxrel_where.nil?

            params_code_an_edge['id'] = @edges.length

            params_code_an_edge['labelloc'] = '"c"'
            params_code_an_edge['style'] = '"dashed"'
            params_code_an_edge['lhead'] = '"(parent)"'
            params_code_an_edge['ltail'] = '"(child)"'

            num_colors = @rel_color_set.length
            num_edges = @edges.length
            color_index = num_edges % num_colors
            color_name = @rel_color_set[color_index]

            #params_code_an_edge['color'] = '"dodgerblue4"'
            params_code_an_edge['color'] = '"' + color_name +'"'
            params_code_an_edge['fontcolor'] = '"' + color_name +'"'

            add_edge(from_edge_name, from_edge_key, to_edge_name, to_edge_key, params_code_an_edge)
          end

          def add_mxaks(mxrel_table_name)
            '(uniq) FOO'
            aks = []
            begin
              sql_code = "select attributename, autokeyname from maxattribute where objectname = '" + mxrel_table_name + "' and autokeyname is not null order by autokeyname"
              record_set = YourDbServer.find_by_sql(sql_code)
              record_set.each do |rec|
                aks << "(uniq) #{rec.attributename} ('#{rec.autokeyname}')"
              end
            rescue Exception => e
              puts "Exception => e == " + e.inspect.to_s
              puts " ... backtrace == "
              e.backtrace.each do |a_step|
                puts " >> " + a_step.to_s
              end
            end
            return aks.join(" | ")
          end
          
          def add_mxpks(mxrel_table_name)
            '(pk) 1 : BAR'
            pks = []
            begin
              sql_code = "select attributename, primarykeycolseq from maxattribute where objectname = '" + mxrel_table_name + "' and primarykeycolseq is not null order by primarykeycolseq"
              record_set = YourDbServer.find_by_sql(sql_code)
              record_set.each do |rec|
                pks << "(pk) #{rec.primarykeycolseq} : #{rec.attributename}"              
              end
            rescue Exception => e
              puts "Exception => e == " + e.inspect.to_s
              puts " ... backtrace == "
              e.backtrace.each do |a_step|
                puts " >> " + a_step.to_s
              end
            end
            return pks.join(" | ")
          end
          
          #"node0"
          #[
          #  label = "MAXAPPS | <rel_parent> rel_parent | (uniq) MAXAPPSID | (pk) 1 : APP | <rel_child> rel_child"
          #  shape = "record"
          #];
          def gen_lbl_for_nodes
            @nodes.each_pair do |node_name,params_code_a_node|
              #params_code_a_node['label'] = '"' + node_name + '"'
              uniq_fld_for_tbl = add_mxaks(node_name) # '(uniq) FOO'
              prim_flds_for_tbl = add_mxpks(node_name) # '(pk) 1 : BAR'
              lbl = '"' + node_name + ' | <rel_parent> rel_parent '
              lbl << '| ' + uniq_fld_for_tbl + ' '
              lbl << '| ' + prim_flds_for_tbl + ' '
              lbl << '| <rel_child> rel_child"'
              params_code_a_node['label'] = lbl
            end
          end

          def to_s
            gen_lbl_for_nodes
            super.to_s
          end

        end # class MxGraphDotObj

    end # module Maximo
  end # module Scripts
end # module Scripting
