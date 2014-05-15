module Scripting
  module Scripts
    module Maximo

        require 'java'
        require 'rubygems'

        class GraphDotObj
          include Scripting::Scripts::Common::Exportable # e.g.: def script_path(root_path, script_file_name, include_date = true, include_time = true)

          attr_accessor :indent_str, :params_code_graph, :params_code_node_style, :nodes, :edges

          # @param indent_str [String]
          # @param initial_indent [String]
          # @param params_code_graph [Hash]
          # @param params_code_node_style [Hash]
          #def initialize( indent_str = '  ', initial_indent = 0, params_code_graph, params_code_node_style)
          def initialize( indent_str, initial_indent, params_code_graph, params_code_node_style)
            @eol = "\n"

            # general:
            tmp_str = indent_str.to_s
            @indent_str = (([''].include?(tmp_str)) ? '  ' : tmp_str)
            #@indent_str = (([''].include?(tmp_str)) ? '-.' : tmp_str)
            tmp_val = initial_indent.to_i
            @initial_indent = ((tmp_val >= 0) ? tmp_val : 0)

            # code_graph:
            @params_code_graph = Hash.new
            if (params_code_graph.nil?)
              @params_code_graph['rankdir'] = '"LR"'
              @params_code_graph['label'] = '"label goes here"'
              @params_code_graph['shape'] = 'plaintext'
              @params_code_graph['labelloc'] = '"t"'
              @params_code_graph['pack'] = '"true"'
            else
              @params_code_graph = params_code_graph # Hash.new
            end

            # code_node_style:
            @params_code_node_style = Hash.new
            if (params_code_node_style.nil?)
              @params_code_node_style['fontsize'] = '"16"'
              @params_code_node_style['shape'] = '"ellipse"'
            else
              @params_code_node_style = params_code_node_style # Hash.new
            end

            @nodes = Hash.new
            @edges = []

          end # def initialize(..)

          # @param node_name [String]
          # @param params_code_a_node [Hash]
          def add_node(node_name, params_code_a_node)
            #@nodes << {'node_name' => node_name, 'params_code_a_node' => params_code_a_node}
            @nodes[node_name] = params_code_a_node
          end

          # @param from_edge_name [String]
          # @param from_edge_key [String]
          # @param to_edge_name [String]
          # @param to_edge_key [String]
          # @param params_code_an_edge [Hash]
          def add_edge(from_edge_name, from_edge_key, to_edge_name, to_edge_key, params_code_an_edge)
            @edges << {'from_edge_name' => from_edge_name, 'from_edge_key' => from_edge_key,
                        'to_edge_name' => to_edge_name, 'to_edge_key' => to_edge_key,
                        'params_code_an_edge' => params_code_an_edge
                      }
          end

          def to_s
            code_diagraph(@initial_indent)
          end

          # @param file_path [String]
          # @param include_date [Boolean]
          # @param include_time [Boolean]
          # @param file_name_without_ext [String]
          # @return [String] of the 'dot' file content
          def gen_pdf_and_svg(file_path, include_date, include_time, file_name_without_ext)

            expanded_file_name_without_ext = (script_path(file_path, file_name_without_ext, include_date, include_time)).gsub('/',"\\") # .gsub("\\",'/')
            #dot_file_name = (script_path(file_path, file_name_without_ext + ".dot", include_date, include_time)).gsub('/',"\\") # .gsub("\\",'/')
            #pdf_file_name = (script_path(file_path, file_name_without_ext + ".pdf", include_date, include_time)).gsub('/',"\\") # .gsub("\\",'/')
            dot_file_name = expanded_file_name_without_ext + ".dot"
            pdf_file_name = expanded_file_name_without_ext + ".pdf"
            svg_file_name = expanded_file_name_without_ext + ".svg"

            win_dot_file_name = dot_file_name.gsub('/',"\\") # gsub for Windows servers
            dest_file = File.new(win_dot_file_name,"w")

            dot_file_content = self.to_s
            dest_file.write(dot_file_content)
            dest_file.flush
            dest_file.close

            gen_pdf_cmds = []
            gen_pdf_cmds << "cd #{File.dirname(dot_file_name).gsub('/',"\\")}"
            #gen_pdf_cmd << "\n"
            gen_pdf_cmds << "dot -Tpdf -o#{File.basename(pdf_file_name)} #{File.basename(dot_file_name)}"
            gen_pdf_cmds << "dot -Tsvg -o#{File.basename(svg_file_name)} #{File.basename(dot_file_name)}"
            cmd_str = gen_pdf_cmds.join(" & ")
            #puts("gen_pdf_cmds == '" + gen_pdf_cmds.to_s + "'")
            #gen_pdf_cmds.each do |cmd|
            #  exec(cmd)
            #end
            puts("cmd_str == '" + cmd_str + "'")
            system(cmd_str)

            #gen_pdf_cmd = "dot -Tpdf -o#{pdf_file_name.gsub("\\","\\\\")} #{dot_file_name.gsub("\\","\\\\")}"
            #puts("gen_pdf_cmd == '" + gen_pdf_cmd.to_s + "'")
            ##exec(gen_pdf_cmd)
            #system(gen_pdf_cmd)

            dot_file_content
          end

        protected

          # @return [String]
          def code_indent(level = 0)
            level = 0 if (level < 0)
            return @indent_str * level
          end

          # @return [String]
          def ci(level)
            code_indent(level)
          end

          # @return [String]
          def code_diagraph(level)
            code_lines = []
            code_lines << ci(level) + 'digraph g'
            code_lines << ci(level) + '{'
            code_lines << code_graph(level + 1)
            code_lines << code_node_style(level + 1)
            code_lines << code_edge_style(level + 1)
            @nodes.each_pair do |node_name, params_code_a_node|
              code_lines << code_a_node(level + 1, node_name, params_code_a_node)
            end
            @edges.each do |edge|
              code_lines << code_an_edge(level + 1,
                                         edge['from_edge_name'], edge['from_edge_key'],
                                         edge['to_edge_name'], edge['to_edge_key'],
                                         edge['params_code_an_edge']
                                        )
            end
            code_lines << ci(level) + '}'
            code_lines << ''
            code_lines.join(@eol)
          end

          #graph
          #[
          #  rankdir = "LR"
          #  label = "Tables in selected Relationships\n\n<RelationshipName> [ <Parent> : <Child> ]\nWHERE <WhereClause>\n\n'(uniq)' = 'unique column name'.\n\n'(pk)' = 'primary key field name'.\n\n'(autokey)' = 'auto key field name'.\n\n"
          #  shape=plaintext
          #  labelloc = "t"
          #  pack = "true"
          #];
          # @return [String]
          def code_graph(level)
            code_lines = []
            code_lines << ci(level) + 'graph'
            code_lines << ci(level) + '['
            @params_code_graph.each_pair do |k,v|
              code_lines << ci(level + 1) + k + ' = ' + v
            end
            #code_lines << ci(level + 1) + 'rankdir = ' + @rankdir
            #code_lines << ci(level + 1) + 'label = ' + @label
            #code_lines << ci(level + 1) + 'shape = ' + @shape
            #code_lines << ci(level + 1) + 'labelloc = ' + @labelloc
            #code_lines << ci(level + 1) + 'pack = ' + @pack
            code_lines << ci(level) + '];'
            code_lines << ''
            code_lines.join(@eol)
          end

          #node
          #[
          #  fontsize = "16"
          #  shape = "ellipse"
          #];
          # @return [String]
          def code_node_style(level)
            code_lines = []
            code_lines << ci(level) + 'node'
            code_lines << ci(level) + '['
            @params_code_node_style.each_pair do |k,v|
              code_lines << ci(level + 1) + k + ' = ' + v
            end
            code_lines << ci(level) + '];'
            code_lines << ''
            code_lines.join(@eol)
          end

          #edge
          #[
          #];
          # @return [String]
          def code_edge_style(level)
            code_lines = []
            code_lines << ci(level) + 'edge'
            code_lines << ci(level) + '['
            #@params_code_node_style.each_pair do |k,v|
            #  code_lines << ci(level + 1) + k + ' = ' + v
            #end
            code_lines << ci(level) + '];'
            code_lines << ''
            code_lines.join(@eol)
          end

          #"node0"
          #[
          #  label = "MAXAPPS | <rel_parent> rel_parent | (uniq) MAXAPPSID | (pk) 1 : APP | <rel_child> rel_child"
          #  shape = "record"
          #];
          # @return [String]
          def code_a_node(level, node_name, params_code_a_node)
            code_lines = []
            code_lines << ci(level) + '"' + node_name + '"'
            code_lines << ci(level) + '['
            params_code_a_node.each_pair do |k,v|
              code_lines << ci(level + 1) + k + ' = ' + v
            end
            code_lines << ci(level) + '];'
            code_lines << ''
            code_lines.join(@eol)
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
          # @return [String]
          def code_an_edge(level, from_edge_name, from_edge_key, to_edge_name, to_edge_key, params_code_an_edge)
            from_lbl = (@nodes.has_key?(from_edge_name) ? from_edge_name : 'missingnode')
            to_lbl = (@nodes.has_key?(to_edge_name) ? to_edge_name : 'missingnode')
            code_lines = []
            code_lines << ci(level) + '"' + from_lbl + '":' + from_edge_key + ' -> "' + to_lbl + '":' + to_edge_key
            code_lines << ci(level) + '['
            params_code_an_edge.each_pair do |k,v|
              code_lines << ci(level + 1) + k.to_s + ' = ' + v.to_s
            end
            code_lines << ci(level) + '];'
            code_lines << ''
            code_lines.join(@eol)
          end

        end # class GraphDotObj

    end # module Maximo
  end # module Scripts
end # module Scripting
