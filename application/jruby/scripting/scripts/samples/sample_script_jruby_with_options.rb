module Scripting
  module Scripts
    module Samples

      require 'java'
      require 'rubygems'
#      require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems'

      JCheckBox = Java::javax.swing.JCheckBox unless defined?(JCheckBox)
      JComboBox = Java::javax.swing.JComboBox unless defined?(JComboBox)
      JGridLayout = Java::java.awt.GridLayout unless defined?(JGridLayout)
#      JBoxLayout = Java::java.awt.BoxLayout unless defined?(JBoxLayout)

      class SampleScriptJrubyWithOptions < AbstractScript # EmptyScript # SampleScript # AbstractScript

          def self.description
            ret_val = self.class.name + ":"
            ret_val << AbstractScript.newline + AbstractScript.newline
            ret_val << AbstractScript.description
            begin
              (1..10).each do |rownum|
                ret_val << AbstractScript.newline + AbstractScript.newline
                ret_val << "For testing of this text area, here is an additional row # " + rownum.to_s + "."
                ("a".."z").to_a.each do |char|
                  ret_val << " " + char
                end
#                ("foo".."food").to_a.each do |word|
                ("bob".."boy").to_a.each do |word|
                  ret_val << " " + word
                end
              end
            rescue Exception => e
              generic_exception_handler(e)
            end
            ret_val
          end # def self.description

          def initialize
#              super
#              jframeName = self.name
#              setTitle(jframeName)
#              super(self.name)
              super("SampleScriptJrubyWithOptions")
            log.warn("This is " + self.class.name + ".")
          end

          def generic_exception_handler(e)
              puts "Exception => e == " + e.inspect.to_s
              puts " ... backtrace == "
              e.backtrace.each do |a_step|
                puts " >> " + a_step.to_s
              end
          end

          def show_options_status
            msg = '**** @someOption.is_enabled == ' + @someOption.is_enabled.to_s
            update_progress(@progressCurrent, msg)
            msg = '**** @someOption.is_selected == ' + @someOption.is_selected.to_s
            update_progress(@progressCurrent, msg)

            msg = '**** @otherOption.is_enabled == ' + @otherOption.is_enabled.to_s
            update_progress(@progressCurrent, msg)
            msg = '**** @otherOption.is_selected == ' + @otherOption.is_selected.to_s
            update_progress(@progressCurrent, msg)

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

#              self.optionsPanel.setLayout(JBoxLayout.new(5,1))
              @someOption = JCheckBox.new("some option", false)
              @otherOption = JCheckBox.new("other option", true)
              @combo_string_or_file = JComboBox.new
              @ck_print = JCheckBox.new("Print?", false)
#              @spacer = JLabel.new("")


              @someOption.add_action_listener do |e|
                msg = '**** Action event for @someOption :' + e.inspect
                update_progress(@progressCurrent, msg)

                show_options_status
              end
              @otherOption.add_action_listener do |e|
                msg = '**** Action event for @otherOption :' + e.inspect
                update_progress(@progressCurrent, msg)

                show_options_status
              end


#              @combo_string_or_file = JComboBox.new
              @combo_string_or_file.add_item "-- pick one --"
              @combo_string_or_file.add_item 'String'
              @combo_string_or_file.add_item 'File'
#              @ck_print = JCheckBox.new("Print?", false)
              @ck_print.enabled = false

              @combo_string_or_file.maximum_row_count = 8
              @ck_print.add_action_listener do |e|
                msg = '**** Action event for @ck_print :' + e.inspect
                update_progress(@progressCurrent, msg)

                show_options_status
              end
              @combo_string_or_file.add_action_listener do |e|
                msg_prefix = self.name + "@combo_string_or_file... action_listener"
                msg = msg_prefix
                update_progress(10, msg)

                msg = '**** Action event for @combo_string_or_file :' + e.inspect
                update_progress(@progressCurrent, msg)

                show_options_status

                idx = @combo_string_or_file.get_selected_index
                if idx != 0
                  @selected = @combo_string_or_file.get_selected_item

                  case @selected
                    when 'String'
                      msg = '**** handling String'
                      update_progress(@progressCurrent, msg)
                      @ck_print.enabled = false
                    when 'File'
                      msg = '**** handling File'
                      update_progress(@progressCurrent, msg)
                      @ck_print.enabled = true
                    else
                      msg = '**** handling else'
                      update_progress(@progressCurrent, msg)
                      @ck_print.enabled = false
                  end
                    msg = '**** Action event ... done.'
                    update_progress(@progressCurrent, msg)
                else
                  msg = msg_prefix + '---- ignoring first item in picklist'
                  update_progress(@progressCurrent, msg)
                end
                msg = msg_prefix + '---- done'
                update_progress(@progressCurrent, msg)
              end

              self.optionsPanel.setLayout(JGridLayout.new(4,1))
              self.optionsPanel.add(@someOption)
              self.optionsPanel.add(@otherOption)
              self.optionsPanel.add(@combo_string_or_file)
              self.optionsPanel.add(@ck_print)
#              self.optionsPanel.add(@spacer) # Spacer
            rescue Exception => e
              generic_exception_handler(e)
            end
          end

          def startScriptHook
            msg = "*>* hello from jruby"
#           log.warn(msg)

#            progressCurrent
            update_progress(10, msg)

            updateProgress(0, AbstractScript.newline + ".. @someOption.isSelected()== " + @someOption.isSelected.to_s)
            updateProgress(0, AbstractScript.newline + ".. @otherOption.isSelected()== " + @otherOption.isSelected.to_s)

#            puts("... hello from jruby")
            # exec('gem list')
            #fromConnParamsWithoutPw.inspect
          end

          def endScriptHook
            msg = "*>* bye from jruby"
#           log.warn(msg)
           update_progress(80, msg)
#            @log.warn("bye from jruby")
#            updateProgress(80, "*>* bye from jruby")
#            puts("... bye from jruby")
            #fromConnParamsWithoutPw.inspect
           update_progress(100, msg)
          end

      end # class SampleScriptJrubyWithOptions

    end # module Samples
  end # module Scripts
end # module Scripting