module Scripting
  module Scripts
    module Utils

      require 'java'
      require 'rubygems'

      require 'jexamxml.jar'
#      require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems'

      JLabel = Java::javax.swing.JLabel unless defined?(JLabel)
      JCheckBox = Java::javax.swing.JCheckBox unless defined?(JCheckBox)
      JComboBox = Java::javax.swing.JComboBox unless defined?(JComboBox)
      JGridLayout = Java::java.awt.GridLayout unless defined?(JGridLayout)

      ExamXML = Java::com.a7soft.examxml.ExamXML unless defined?(ExamXML)
      ExamXMLOptions = Java::com.a7soft.examxml.Options unless defined?(ExamXMLOptions)

      class CompareXml < AbstractScript # EmptyScript # SampleScript # AbstractScript

          def self.description
            ret_val = self.class.name + ":"
            ret_val << AbstractScript.newline + AbstractScript.newline
            ret_val << "Required initial params:"
            ret_val << AbstractScript.newline
            ret_val << " * 'from' path setting (containing an XML string or pointing to an XML file for comparison)"
            ret_val << AbstractScript.newline
            ret_val << " * 'to'   path setting (containing an XML string or pointing to an XML file for comparison)"
            ret_val << AbstractScript.newline + AbstractScript.newline
            ret_val << "This compares XML files using ExamXML."
            ret_val
          end # def self.description

          def initialize
#            super
#            jframeName = self.name
#            setTitle(jframeName)
#            super(self.name)
            super("CompareXml")
#            msg = "Launching: " + self.name + "..."
            msg = self.name + ".initialize()"
            log.warn(msg)
#            update_progress(0, msg)
            @options_file_path = ENV['AppRoot'] + "/properties/examxml_options.txt"
          end

          def show_options_status
            msg ='**** @combo_string_or_file.get_selected_index == ' + @combo_string_or_file.get_selected_index.to_s
            update_progress(@progressCurrent, msg)

            msg = '**** @combo_string_or_file.get_selected_item == ' + @combo_string_or_file.get_selected_item.to_s
            update_progress(@progressCurrent, msg)

            msg = '**** @ck_print.is_selected == ' + @ck_print.is_selected.to_s
            update_progress(@progressCurrent, msg)

            msg = '**** @ck_print.is_enabled == ' + @ck_print.is_enabled.to_s
            update_progress(@progressCurrent, msg)
          end

          def initUISettingsHook
            self.quickstart = false # i.e.: true = Hide options panel and just start running the script; false = Show options panel and require the user to click the "Start" button.
          end

          def initUIComponentsHook
            begin
              self.optionsPanel.setLayout(JGridLayout.new(3,1))

              @lbl_string_or_file = JLabel.new('Use Paths as:')
              @combo_string_or_file = JComboBox.new
              @ck_print = JCheckBox.new("Print?", false)

              self.optionsPanel.add(@lbl_string_or_file)
              self.optionsPanel.add(@combo_string_or_file)
              self.optionsPanel.add(@ck_print)

              @combo_string_or_file.maximum_row_count = 8
              @combo_string_or_file.add_item "-- pick one --"
              @combo_string_or_file.add_item 'Strings'
              @combo_string_or_file.add_item 'Entities'
              @combo_string_or_file.add_item 'Files'
              @combo_string_or_file.add_item 'Folders'
              @combo_string_or_file.add_action_listener do |e|
                msg = '**** Action event for @combo_string_or_file :' + e.inspect
                update_progress(@progressCurrent, msg)

                show_options_status

                idx = @combo_string_or_file.get_selected_index
                if idx != 0
                  @selected = @combo_string_or_file.get_selected_item

                  case @selected
                    when 'Strings' #:
                      msg = '**** handling Strings'
                      update_progress(@progressCurrent, msg)
                      @ck_print.enabled = false
                    when 'Entities' #:
                      msg = '**** handling Entities'
                      update_progress(@progressCurrent, msg)
                      @ck_print.enabled = true
                    when 'Files' #:
                      msg = '**** handling Files'
                      update_progress(@progressCurrent, msg)
                      @ck_print.enabled = true
                    when 'Folders' #:
                      msg = '**** handling Folders'
                      update_progress(@progressCurrent, msg)
                      @ck_print.enabled = true
                    else
                      msg = '**** handling else'
                      update_progress(@progressCurrent, msg)
                      @ck_print.enabled = false
                  end
                    msg = '**** Action event ... done.'
                    update_progress(@progressCurrent, msg)
                end
              end

              @ck_print.enabled = false
              @ck_print.add_action_listener do |e|
                msg = '**** Action event for @ck_print :' + e.inspect
                update_progress(@progressCurrent, msg)

                show_options_status
              end

            rescue Exception => e
              generic_exception_handler(e)
            end
          end

          def startScriptHook
            begin
              msg_prefix = self.name + ".startScriptHook()"
              msg = msg_prefix
              update_progress(10, msg)

              show_options_status

              idx = @combo_string_or_file.get_selected_index
              if idx != 0
                @selected = @combo_string_or_file.get_selected_item


#          compare_entities(self.fromConnParams['path'].to_s, self.toConnParams['path'].to_s)
#          compare_files_and_print(self.fromConnParams['path'].to_s, self.toConnParams['path'].to_s, self.toConnParams['path'].to_s+".delta.xml", options = @options_file_path)
#          compare_files(self.fromConnParams['path'].to_s, self.toConnParams['path'].to_s)
#          compare_strings(self.fromConnParams['path'].to_s, self.toConnParams['path'].to_s)

                case @selected
                  when 'Strings' #:
                    msg = msg_prefix + '---- handling Strings'
                    update_progress(@progressCurrent, msg)
#                    @ck_print.enabled = false
                    msg = compare_strings(self.fromConnParams['path'].to_s, self.toConnParams['path'].to_s)
                    update_progress(@progressCurrent, "String Diff Results == " + msg.to_s)

                  when 'Entities' #:
                    msg = msg_prefix + '---- handling Entities'
                    update_progress(@progressCurrent, msg)
#                    @ck_print.enabled = true
                    msg = compare_entities(self.fromConnParams['path'].to_s, self.toConnParams['path'].to_s)
                    update_progress(@progressCurrent, msg.to_s)

                  when 'Files' #:
                    msg = msg_prefix + '---- handling Files'
                    update_progress(@progressCurrent, msg)
#                    @ck_print.enabled = true
                    use_print_option = false
                    if ((@ck_print.is_enabled) and (@ck_print.is_selected))
                      use_print_option = true
                    end
                    update_progress(@progressCurrent, "use_print_option == " + use_print_option.to_s)

                    delta_filename = self.toConnParams['path'].to_s + ".delta.xml"
                    update_progress(@progressCurrent, "delta_filename == " + delta_filename)

                    if (use_print_option)
                      msg = compare_files_and_print(self.fromConnParams['path'].to_s, self.toConnParams['path'].to_s, delta_filename, options = @options_file_path)
                    else
                      msg = compare_files(self.fromConnParams['path'].to_s, self.toConnParams['path'].to_s)
                    end
                    update_progress(@progressCurrent, msg.to_s)

                  when 'Folders' #:
                    msg = msg_prefix + '---- handling Folders'
                    update_progress(@progressCurrent, msg)
                    msg =
#                    @ck_print.enabled = true

                    use_print_option = false
                    if ((@ck_print.is_enabled) and (@ck_print.is_selected))
                      use_print_option = true
                    end
                    update_progress(@progressCurrent, "use_print_option == " + use_print_option.to_s)

                    delta_filename = self.toConnParams['path'].to_s + ".delta.xml"
                    update_progress(@progressCurrent, "delta_filename == " + delta_filename)

                    if (use_print_option)
                      msg = compare_folders_and_print(self.fromConnParams['path'].to_s, self.toConnParams['path'].to_s, delta_filename, options = @options_file_path)
                    else
                      msg = compare_folders(self.fromConnParams['path'].to_s, self.toConnParams['path'].to_s)
                    end
                    update_progress(@progressCurrent, msg.to_s)

                  else
                    msg = msg_prefix + '---- handling else'
                    update_progress(@progressCurrent, msg)
#                    @ck_print.enabled = false

                end
              else
                msg = msg_prefix + '---- ignoring first item in picklist'
                update_progress(@progressCurrent, msg)
              end
              msg = msg_prefix + '---- done'
              update_progress(@progressCurrent, msg)

            rescue Exception => e
              generic_exception_handler(e)
            end
          end

          def endScriptHook
            begin
              msg = self.name + ".endScriptHook()"
              update_progress(100, msg)
            rescue Exception => e
              generic_exception_handler(e)
            end
          end

          def generic_exception_handler(e)
              puts "Exception => e == " + e.inspect.to_s
              puts " ... backtrace == "
              e.backtrace.each do |a_step|
                puts " >> " + a_step.to_s
              end
          end

          def compare_entities(file1, file2)
            begin
  #            ExamXML.compareXMLFiles(String file1,String file2);
              ExamXML.compareXMLEntities(file1, file2)
            rescue Exception => e
              generic_exception_handler(e)
            end
          end

          def compare_files_and_print(file1, file2, file_delta, options = @options_file_path)
            begin
  #            ExamXML.compareXMLFiles(String file1,String file2,String file_delta,String options);
              ExamXML.compareXMLFiles(file1, file2, file_delta, options)
            rescue Exception => e
              generic_exception_handler(e)
            end
          end

          def compare_files(file1, file2)
            begin
  #            ExamXML.compareXMLFiles(String file1,String file2);
              ExamXML.compareXMLFiles(file1, file2)
            rescue Exception => e
              generic_exception_handler(e)
            end
          end

          # TODO: Finish...
          def compare_folders_and_print(root1, root2, root_delta, options = @options_file_path)
            begin
  #            ExamXML.compareXMLFiles(String file1,String file2,String file_delta,String options);
#              file_filter = "/**/*.xml" # Should we be this specific? Or
              file_filter = "/**/*.*"

              sub_paths_all = []
#              paths_all_count = 0
              paths_in_root1 = Hash.new
              paths_in_root2 = Hash.new
              Dir.foreach(root1 + file_filter) do |path|
                sub_paths_all <<  paths_in_root1['sub_path']
                paths_in_root1[sub_path] = Hash.new
                paths_in_root1[sub_path]['full_path'] = File.expand_path(sub_path)
#                paths_in_root1[sub_path]['sub_path'] = sub_path # paths_in_root1['full_path'].gsub(root1,"")
                paths_in_root1[sub_path]['sub_folder'] = File.dirname(sub_path)
                paths_in_root1[sub_path]['file'] = File.basename(sub_path)
              end
              Dir.foreach(root2 + file_filter) do |sub_path|
                sub_paths_all <<  paths_in_root1['sub_path']
                paths_in_root2[sub_path] = Hash.new
                paths_in_root2[sub_path]['full_path'] = File.expand_path(sub_path)
#                paths_in_root2[sub_path]['sub_path'] = sub_path # paths_in_root1['full_path'].gsub(root1,"")
                paths_in_root2[sub_path]['sub_folder'] = File.dirname(sub_path)
                paths_in_root2[sub_path]['file'] = File.basename(sub_path)
              end
              sub_paths_all.sort!.uniq!
              sub_paths_all_count = sub_paths_all.count
              file_current = 0                 
              comparison_results = Hash.new
              sub_paths_all.each do |sub_path|
                path1_is_dir  = File.directory?(paths_in_root1[sub_path]['full_path'])
                path1_is_file = File.file?(paths_in_root1[sub_path]['full_path'])

                path2_is_dir  = File.directory?(paths_in_root2[sub_path]['full_path'])
                path2_is_file = File.file?(paths_in_root2[sub_path]['full_path'])
              end

              ExamXML.compareXMLFiles(file1, file2, file_delta, options)

            rescue Exception => e
              generic_exception_handler(e)
            end
          end

          def compare_folders(file1, file2)
            begin
  #            ExamXML.compareXMLFiles(String file1,String file2);
              ExamXML.compareXMLFiles(file1, file2)
            rescue Exception => e
              generic_exception_handler(e)
            end
          end

          def compare_strings(str1, str2)
            begin
  #            ExamXML.compareXMLFiles(String file1,String file2);
              ExamXML.compareXMLEntities(str1, str2)
            rescue Exception => e
              generic_exception_handler(e)
            end
          end
      end # class CompareXml
    end # module Utils
  end # module Scripts
end # module Scripting
