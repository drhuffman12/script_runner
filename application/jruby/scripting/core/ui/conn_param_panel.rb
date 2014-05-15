module Scripting
  module Core
    module Ui
      
      require 'rbconfig'
      
      require 'java'
      require 'rubygems'
      # require File.join(ENV['AppRoot'].to_s,'jdbcmssql-gems')
      require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems'
      require 'active_support' # Used here for 'ActiveSupport::JSON.encode(...)' and decoding

      # Shortcuts to Java Classes (also to avoid name-space collisions):
      JGridLayout = java.awt.GridLayout unless defined? JGridLayout
      JColor = java.awt.Color unless defined? JColor
      JLabel = javax.swing.JLabel unless defined? JLabel
      JButton = javax.swing.JButton unless defined? JButton
      JPanel = javax.swing.JPanel unless defined? JPanel
      JTextField = javax.swing.JTextField unless defined? JTextField
      JPasswordField = javax.swing.JPasswordField unless defined? JPasswordField
      JTitledBorder = javax.swing.border.TitledBorder unless defined? JTitledBorder
      JComboBox = javax.swing.JComboBox unless defined? JComboBox
      JHashMap = java.util.HashMap unless defined? JHashMap

      class ConnParamParts
	
	  def self.is_windows
	    (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
	  end
	  
          def self.property_file_name
            "properties/com_param_panel.properties" # ConnParamParts.property_file_name
    #        "com_param_panel.properties" # ConnParamParts.property_file_name
          end
          def self.property_file_path_expanded
            # File.expand_path(self.property_file_name).gsub("/","\\") if is_windows # TODO: hack for Windows; fix it
	    fp = File.expand_path(self.property_file_name)
	    fp..gsub("/","\\") if is_windows # TODO: hack for Windows; fix it
	    fp
          end
          def self.conn_parts
            ['server', 'database', 'username', 'password', 'path'] # ConnParamParts.conn_parts
          end
          def self.conn_parts_savable
            conn_parts - ['password']  # ConnParamParts.conn_parts_savable
          end
    #      def self.pick_one_label
    ##        "- pick one -"  # ConnParamParts.pick_one_label
    #        Ui::SpecialValues.pick_one_label
    #      end
    #      def self.pick_one_index
    ##        0  # ConnParamParts.pick_one_index
    #        Ui::SpecialValues.pick_one_index
    #      end
      end

      # TODO: CLEAN UP 'ConnParamPicker' and 'ConnParamPanel' classes
      class ConnParamPicker < javax.swing.JComboBox

        def initialize(comm_param_panel)
          super()
          self.editable = true
          @comm_param_panel = comm_param_panel
          @@all_conn_settings = @@all_conn_settings ||= Hash.new # Init only once and cache it.... Broken?
          need_new_all_conn_settings = false
          unless (defined? @@all_conn_settings)
            need_new_all_conn_settings = true unless (@@all_conn_settings.kind_of?(Hash))
          else
    #        @@all_conn_settings = Hash.new
            need_new_all_conn_settings = true
          end
          if (need_new_all_conn_settings)
              puts "Need to add '@@all_conn_settings' ..."
            @@all_conn_settings = Hash.new
              puts "... '@@all_conn_settings' added."
          end
    #        puts "need to try 'import_settings'"
    #            puts "Loading " + self.class.name + " properties from " + File.expand_path(ConnParamParts.property_file_path_expanded)
          import_settings

          add_action_listener do |e|
            @debug_mode = true
            @selected_index = get_selected_index
            if @debug_mode
              p "======="
              p self.class.name + "... had an option selected:"
              p '  e == ' + e.to_s
              p '  get_selected_index == ' + @selected_index.to_s
              p '  e.get_source == ' + e.get_source.to_s
              p '  get_selected_item == ' + get_selected_item.to_s
            end
    #        if @selected_index != 0 # ignore 1st entry
            if @selected_index >= 0 # include 1st entry
              @selected_item = get_selected_item
              if @debug_mode
                p
                p '**** get_selected_index == ' + @selected_index.to_s
                p '**** get_selected_item == ' + @selected_item.to_s
                # dispose
                p 'switching to:' + @@all_conn_settings[@selected_item.to_s].inspect

                @comm_param_panel.conn_settings= @@all_conn_settings[@selected_item.to_s]
              end
            end
          end
      #      set_selected_index 1
      #      selected_index = 0
      #      selected_index = 1

        end # def initialize

        def import_settings
          puts "Loading '#{self.class.name}' properties from '#{ConnParamParts.property_file_path_expanded}'"
          remove_all_items

          begin
            puts "import_settings.. begin"

            props_to_load = false
            if (File.exist?(ConnParamParts.property_file_path_expanded))
              puts "import_settings.. if (File.exist?(" + ConnParamParts.property_file_path_expanded + "))"

              prop_file = File.open(ConnParamParts.property_file_path_expanded)
              prop_txt = ""
              prop_file.each {|line| prop_txt << line }
              @@all_conn_settings = ActiveSupport::JSON.decode(prop_txt)
              puts "import_settings.. @@all_conn_settings == " + @@all_conn_settings.inspect
              if @@all_conn_settings
                unless @@all_conn_settings.empty?
                  props_to_load = true
                end
              end
            end

    #        if (File.exist?(ConnParamParts.property_file_path_expanded))
            puts "import_settings.. props_to_load == " + props_to_load.to_s
            if (props_to_load)
              puts "import_settings.. if...start"
    #          prop_file_name = ConnParamParts.property_file_path_expanded
    #          prop_file = File.open(ConnParamParts.property_file_path_expanded)
    #          prop_txt = ""
    #          prop_file.each {|line| prop_txt << line }
    #          @@all_conn_settings = ActiveSupport::JSON.decode(prop_txt)
              @@all_conn_settings.each_key {|key| add_item(key) }
              puts "import_settings.. if...done"

    #          # Test for Java HaspMap from Ruby Hash:
    #          @test = JHashMap.new(@@all_conn_settings)
    #          puts "******** @test == " + @test.inspect
            else
              puts "import_settings.. else...start"
              name = SpecialValues.pick_one_label # "- pick one -"
              settings_hash = {'server' => '' , 'database' => '' , 'username' => '' , 'path' => '' }
              add_settings(name, settings_hash)
              puts "import_settings.. else...mid"
              File.open(ConnParamParts.property_file_path_expanded, "w") {|f| f.write(ActiveSupport::JSON.encode(@@all_conn_settings)) }
              puts "import_settings.. else...done"
            end
          rescue Exception => e
            puts "Exception at :" + self.class.name + ".import_settings"
            puts "-> Error message :" + e.inspect
            puts "->     backtrace :" + e.backtrace.to_s
          end
        end

        def export_settings

    #      if ([ConnParamParts.pick_one_label].include?(selected_item))
    #      if (0 == selected_index)
          if ((Ui::SpecialValues.pick_one_index == selected_index) or ([SpecialValues.pick_one_label].include?(selected_item)))
            puts "First option in pick list ('" + SpecialValues.pick_one_label + "') is just a label and can not be saved.... Skipping."
          else
            puts "Saving '#{self.class.name}' properties to '#{File.expand_path(ConnParamParts.property_file_path_expanded)}'"
            add_settings(get_selected_item, @comm_param_panel.conn_settings)
            File.open(ConnParamParts.property_file_path_expanded, "w") {|f| f.write(ActiveSupport::JSON.encode(@@all_conn_settings)) }
          end
        end

        # TODO:
        def delete_current_setting(name)
#          puts "delete_current_setting(" + name + "): START"

#          puts "delete_current_setting(" + name + "): @@all_conn_settings.delete(name.to_s)"
          del_results = @@all_conn_settings.delete(name.to_s) # if (@@all_conn_settings.has_key?(name.to_s))
#          puts "delete_current_setting(" + name + "): del_results == '" + del_results.to_s + "'"

#          puts "delete_current_setting(" + name + "): remove_item(name)"
          del_results = remove_item(name)
#          puts "delete_current_setting(" + name + "): del_results == '" + del_results.to_s + "'"

#          puts "delete_current_setting(" + name + "): self.export_settings"
          self.export_settings

#          puts "self.import_settings"
#          self.import_settings # TODO

#          puts "delete_current_setting(" + name + "): @comm_param_panel.reload_pick_list"
          @comm_param_panel.reload_pick_list

#          puts "delete_current_setting(" + name + "): END"
        end


        # settings_hash expects 'ConnParamParts.conn_parts_saved' as keys
        def add_settings(name, settings_hash)
          add_item(name)
    #        @@all_conn_settings[name.to_s] = @@all_conn_settings[name.to_s] ||= Hash.new
          need_new_setting = false
    #      if (@@all_conn_settings.kind_of?(Hash))
            if (@@all_conn_settings.has_key?(name.to_s))
              unless (@@all_conn_settings[name.to_s].kind_of?(Hash))
                need_new_setting = true
              end
            else
              need_new_setting = true
            end
    #      else
    #        @@all_conn_settings = Hash.new
    #        need_new_setting = true
    #      end
          if (need_new_setting)
            @@all_conn_settings[name.to_s] = Hash.new
          end

    #        need_new_setting = true
    #
    #        if (@@all_conn_settings[name.to_s])
    #          need_new_setting = false
    ##          if(@@all_conn_settings[name.to_s].empty?)
    ##            # need_new_setting = false
    ##          else
    ##            # need_new_setting = false
    ##          end
    #        else
    #          # need_new_setting = true
    #        end
    #
    #        if (need_new_setting)
    #          @@all_conn_settings[name.to_s] = Hash.new
    #        end

    #        @@all_conn_settings[name.to_s] = Hash.new unless @@all_conn_settings[name.to_s]

    #        if (@@all_conn_settings[name.to_s])
    #          unless (@@all_conn_settings[name.to_s].empty?)
              ConnParamParts.conn_parts_savable.each do |cps|
                (@@all_conn_settings[name.to_s])[cps] = settings_hash[cps].to_s
              end
    #          end
    #        end
    #        ConnParamParts.conn_parts_savable.each do |cps|
    #          (@@all_conn_settings[name.to_s])[cps] = settings_hash[cps].to_s
    #        end
        end # def add_settings(name, settings_hash)
        # end

        def settings(name)
          @@all_conn_settings[name.to_s]
        end


        def selected_index
          get_selected_index
        end

        def selected_index=(new_index)
          set_selected_index(new_index)
        end

        def selected_item
          get_selected_item
        end

        def selected_item=(new_item)
          set_selected_item(new_item)
        end



      end # class ConnParamPicker

      class ConnParamPanel < javax.swing.JPanel

        def initialize(name)
          super()
          @name = name


          @logger = Logging::Logger.new(self.class.name)
          @logger.log.info "initialize(#{name})"

          set_border(JTitledBorder.new(@name))

          # @conn_panel = JPanel.new
          @conn_panel_labels = JPanel.new
          @conn_panel_inputs = JPanel.new

          set_background(JColor.new(127,127,255))
          @conn_panel_labels.set_background(JColor.new(192,192,255))
          @conn_panel_inputs.set_background(JColor.new(192,192,255))

          @conn_panel_labels.set_layout JGridLayout.new(ConnParamParts.conn_parts.length+2, 1)
          @conn_panel_inputs.set_layout JGridLayout.new(ConnParamParts.conn_parts.length+2, 1)


          @conn_panel_labels.add(JLabel.new("Settings"))

          @conn_param_picker = ConnParamPicker.new(self)
          @conn_panel_inputs.add(@conn_param_picker)

          @refresh_button = JButton.new("Refresh")
          @conn_panel_labels.add(@refresh_button)

          save_and_delete_panel = JPanel.new
          save_and_delete_panel.set_layout JGridLayout.new(1,2)
          @save_button = JButton.new("Save")
          @delete_button = JButton.new("Delete")
          save_and_delete_panel.add(@save_button)
          save_and_delete_panel.add(@delete_button)
          @conn_panel_inputs.add(save_and_delete_panel)

          @conn_panel_labels.add(JLabel.new("")) # for spacers
          @conn_panel_inputs.add(JLabel.new("")) # for spacers

          border_text = " " # @name
          label_text = "Path"
          button_text = "Browse"
          dialog_title = "Pick '#{@name}' path for scripts"
          @file_picker = Ui::FilePicker.new(border_text, label_text, button_text, dialog_title)

          @conn_settings = Hash.new
          @conn_part_labels = Hash.new
          @conn_part_inputs = Hash.new
          ConnParamParts.conn_parts.each do |cp|
            @conn_settings[cp] = nil

            case cp
              when 'password'
                @conn_part_inputs[cp] = JPasswordField.new(20)
              when 'path'
                @conn_part_inputs[cp] = @file_picker
              else
                @conn_part_inputs[cp] = JTextField.new(20)
            end

            # UI parts for 'path' added via @file_picker,
            #   so we exclude 'path' from "@conn_part_labels[cp] = ...", "@conn_panel_labels.add(...)", and "@conn_panel_inputs.add(...)":
            unless (['path'].include?(cp))
              @conn_part_labels[cp] = JLabel.new(cp)
              @conn_panel_labels.add(@conn_part_labels[cp])
              @conn_panel_inputs.add(@conn_part_inputs[cp])
            end
          end

          # Button actions:
          @refresh_button.add_action_listener do |e|
#            last_selected = @conn_param_picker.selected_item ||= SpecialValues.pick_one_label # "- pick one -"
#            @conn_param_picker.import_settings
#            @conn_param_picker.selected_item = last_selected
            reload_pick_list
          end
          @save_button.add_action_listener do |e|
            @conn_param_picker.export_settings
          end
          @delete_button.add_action_listener do |e|
            if (0 != @conn_param_picker.selected_index)
              last_selected = @conn_param_picker.selected_item
              @conn_param_picker.delete_current_setting(last_selected) # TODO
              @conn_param_picker.selected_index = 0
            end
          end

          @save_button.enabled = false
          @delete_button.enabled = false
          @conn_param_picker.add_action_listener do |e|
            if (0 == @conn_param_picker.selected_index)
              @save_button.enabled = false
              @delete_button.enabled = false
            else
              @save_button.enabled = true
              @delete_button.enabled = true
            end
          end

          set_layout JBorderLayout.new
          add(@conn_panel_labels,JBorderLayout::WEST)
          add(JLabel.new(""),JBorderLayout::CENTER) # Spacer
          add(@conn_panel_inputs,JBorderLayout::EAST)
          add(@file_picker,JBorderLayout::SOUTH)
        end # def initialize(...)

        def reload_pick_list
          last_selected = @conn_param_picker.selected_item ||= SpecialValues.pick_one_label # "- pick one -"
          @conn_param_picker.import_settings
          @conn_param_picker.selected_item = last_selected
        end

        def conn_settings
          ConnParamParts.conn_parts.each do |cp|
            @conn_settings[cp] = @conn_part_inputs[cp].text
          end
          @conn_settings
        end # def conn_settings

        def conn_settings=(comm_settings_hash)
          ConnParamParts.conn_parts.each do |cp|
            val = comm_settings_hash[cp]
            @conn_part_inputs[cp].text = val
          end
        end # def conn_settings=(...)

      end # class ConnParamPanel
    end # module Ui
  end # module Core
end # module Scripting
