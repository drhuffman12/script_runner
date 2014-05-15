module Scripting
  module Core
    module Ui

      require 'java'
      require 'rubygems'
      require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems'

      # Shortcuts to Java Classes (also to avoid name-space collisions):
      # JGridLayout = java.awt.GridLayout
      JBorderLayout = java.awt.BorderLayout unless defined? JBorderLayout
      JColor = java.awt.Color unless defined? JColor
      JLabel = javax.swing.JLabel unless defined? JLabel
      JButton = javax.swing.JButton unless defined? JButton
      JPanel = javax.swing.JPanel unless defined? JPanel
      JTextField = javax.swing.JTextField unless defined? JTextField
      JFileChooser = javax.swing.JFileChooser unless defined? JFileChooser

      class FilePicker < javax.swing.JPanel

        def initialize(border_text, label_text, button_text, dialog_title)
          super()

          set_border(JTitledBorder.new(border_text))
          set_background(JColor.new(232,232,255))

          @label_text = label_text
          @button_text = button_text
          @dialog_title = dialog_title

          @label = JLabel.new(@label_text)

          @path   = JTextField.new
          
          @dialog = JFileChooser.new()  
          @dialog.set_dialog_title(@dialog_title)    # "Pick '#{@name}' path for scripts"
          @dialog.setFileSelectionMode(JFileChooser::DIRECTORIES_ONLY)
#          @dialog.setFileSelectionMode(JFileChooser::FILES_AND_DIRECTORIES)
#          @dialog.setMultiSelectionEnabled(true)
                                                                                       
          @button = JButton.new(@button_text)        # "Set (#{@name}) path"     
          @button.add_action_listener do |e|
            success = @dialog.show_open_dialog(nil)
            p "==== success == " + success.to_s
            # if (success == Java::javax::swing::JFileChooser::APPROVE_OPTION)
            if (success == JFileChooser::APPROVE_OPTION)
              puts "Paths selected for '" + button_text + "' in '" + border_text + "'."
              if (@dialog.isMultiSelectionEnabled)
                paths = []

#                if (@dialog.isFileSelectionEnabled)
#                  paths << @dialog.get_selected_files
#                end
#
#                if (@dialog.isDirectorySelectionEnabled)
#                  paths << @dialog.get_selected_files
#                end

                paths << @dialog.get_selected_files

                @path.text = ""
                paths.each do |path|
#                  puts 'path.isDirectory == ' + path.isDirectory.to_s
#                  puts 'path.get_name == ' + path.get_name.to_s
                  puts 'path.get_absolute_path == ' + path.get_absolute_path.to_s

#                  @path.text << ',' unless (path == paths.first)
##                  @path.text << path.get_absolute_path
#                  @path.text << path.get_path
##                  @path.text << path.to_s
#
#                  puts ',' unless (path == paths.first)
##                  puts path.get_absolute_path
#                  puts path.get_path
##                  puts path.to_s
                end

              else
                path = @dialog.get_selected_file.get_absolute_path
                @path.text = path
                puts path
              end
            else
              #  ...
            end
          end

          set_layout JBorderLayout.new
          add(@label,JBorderLayout::WEST)
          add(JLabel.new(""),JBorderLayout::CENTER) # Spacer
          add(@button,JBorderLayout::EAST)
          add(@path,JBorderLayout::SOUTH)

        end # def initialize(...)

        def text=(new_path)
          @path.text = new_path
        end

        def text
          @path.text
        end

      end # class FilePicker
    end # module Ui
  end # module Core
end # module Scripting