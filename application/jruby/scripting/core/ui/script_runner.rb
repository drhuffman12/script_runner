module Scripting
  module Core
    module Ui

      require 'java'
      require 'rubygems'
      require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems'
      # Shortcuts to Java Classes (also to avoid name-space collisions):

      JBorderLayout = java.awt.BorderLayout unless defined?(JBorderLayout)
#      JGridLayout = java.awt.GridLayout unless defined?(JGridLayout)
      JActionListener = java.awt.event.ActionListener unless defined?(JActionListener)
      JWindowListener = java.awt.event.WindowListener unless defined?(JWindowListener)
      JColor = java.awt.Color unless defined?(JColor)
      JDimension = java.awt.Dimension unless defined?(JDimension)
      JSystem = java.lang.System unless defined?(JSystem)
      JPanel = javax.swing.JPanel unless defined?(JPanel)
      JLabel = javax.swing.JLabel unless defined?(JLabel)
      JButton = javax.swing.JButton unless defined?(JButton)
      JHashMap = java.util.HashMap unless defined?(JHashMap)

      JToolkit = java.awt.Toolkit unless defined?(JToolkit)

      JythonFactory = Java::scripting.core.JythonFactory unless defined? JythonFactory

      #JSystem = Java::java.lang.System


      class ScriptRunner < javax.swing.JFrame

        include JWindowListener
        include JActionListener

      ##  include Scripting
      #  include Scripting::Core::Logging
      #  include Scripting::Core::Ui

        def initialize(script_list, script_metadata)
          super "Script Generator and Utilities (v2)"
          toolkit = JToolkit.defaultToolkit
          screensize = toolkit.screenSize
          a_width = screensize.width  # 1000
          a_height = 280
          setPreferredSize(JDimension.new(a_width, a_height))
          @script_metadata = script_metadata

          @logger = Scripting::Core::Logging::Logger.new(self.class.name)
          @logger.log.info "initialize(#{script_list})"


          @total = 0

          @conn_from = Scripting::Core::Ui::ConnParamPanel.new("From")
          @conn_to = Scripting::Core::Ui::ConnParamPanel.new("To")

          @script_picker = Scripting::Core::Ui::ScriptPicker.new(script_list, script_metadata)

          # @main_panel = Jpanel.new

      #    set_layout JGridLayout.new(1,3)
      #    add(@conn_from)
      ##    add((JPanel.new).add(JLabel.new("spacer")))
      #    add(@conn_to)
      #    add(@script_picker)

          set_layout JBorderLayout.new()
          add(@conn_from,JBorderLayout::WEST)
      #    add((JPanel.new).add(JLabel.new("spacer")),JBorderLayout::CENTER)
          add(@conn_to,JBorderLayout::EAST)

          @center_panel = JPanel.new
          @center_panel.set_layout JBorderLayout.new()
          @center_panel.add(@script_picker,JBorderLayout::CENTER)
          @run_script_btn = JButton.new("Run Script")
          @center_panel.add(@run_script_btn,JBorderLayout::SOUTH)

          @run_script_btn.enabled = false
          @script_picker.combo_box.add_action_listener do |e|
            if (Scripting::Core::Ui::SpecialValues.pick_one_index == @script_picker.selected_index)
              @run_script_btn.enabled = false
            else
              @run_script_btn.enabled = true
            end
          end
          @run_script_btn.add_action_listener do |e|
            idx = @script_picker.selected_index # @combo_box.get_selected_index
            if idx != 0
              @selected = @script_picker.selected_item # @combo_box.get_selected_item
      #          if @debug_mode
              p
              p '**** @script_picker.get_selected_index == ' + idx.to_s
              p '**** @script_picker.get_selected_item == ' + @selected.to_s

              script_class_name = @selected

                unless (script_class_name.nil?)
                  @logger.log.info("script_class_name == " + script_class_name.inspect)



                  # Log '@conn_from.conn_settings', but mask the password:
      #            @logger.log.info("@conn_from.conn_settings == " + @conn_from.conn_settings.inspect)
                  conn_settings_without_pw = @conn_from.conn_settings.clone
                  conn_settings_without_pw["password"]="********"
                  @logger.log.info("@conn_from.conn_settings == " + conn_settings_without_pw.inspect)

                  # Log '@conn_to.conn_settings', but mask the password:
      #            @logger.log.info("@conn_to.conn_settings == " + @conn_to.conn_settings.inspect)
                  conn_settings_without_pw = @conn_to.conn_settings.clone
                  conn_settings_without_pw["password"]="********"
                  @logger.log.info("@conn_from.conn_settings == " + conn_settings_without_pw.inspect)
                  @logger.log.info("----")

                  lang = @script_metadata[script_class_name]['lang']
                  case lang
                    when "Java", "JRuby" #:
                      script_class = eval("script_class = #{script_class_name}")
                      @logger.log.info("script_class == " + script_class.inspect)
                      script_results = (script_class.new).runForConnParams(JHashMap.new(@conn_from.conn_settings),JHashMap.new(@conn_to.conn_settings))
                      @logger.log.info("script_results == " + script_results.inspect)
                    when "Jython" #:
                      # TODO: (Jython) ...
                      # @jython_app_launcher.run_jython_file(file_path,params[])
                      # test_jython
                      jython_factory = JythonFactory.instance
                      # @pythonFactoryClassPath = $CLASSPATH
                      # @pythonFactoryClassPath = ENV['AppRoot'] + "/java/bin"
                      @pythonFactoryClassPath = File.expand_path(File.dirname(__FILE__) + "../../../../../java/bin")
                      
                      # script_class_name = "aaa.bbb.ccc.ddd.Eee" # test
                      pkg_and_class_parts_arr = script_class_name.gsub("Jython::","").split(".")
                      if(pkg_and_class_parts_arr.length > 0)
                        len = pkg_and_class_parts_arr.length
                        pkg_parts_arr = pkg_and_class_parts_arr[0..(len - 2)]
                        pkg_path = pkg_parts_arr.join("/")
                        class_name = pkg_and_class_parts_arr[(len - 1)]
                        
                        @jythonFilePath = ENV['AppRoot'] + "/jython/" + pkg_path
                        @javaClassName = "scripting.core.AbstractScript"
                        @jythonFileName = @jythonFilePath + "/" + class_name + ".py"
                        puts "Running Jython Class: " + @jythonFileName + " ..."
                        jython_factory.runAbstractScript(@pythonFactoryClassPath, @jythonFileName, JHashMap.new(@conn_from.conn_settings),JHashMap.new(@conn_to.conn_settings))
                        puts "... Done."
                      else
                        puts "... Error in Jython package and/or class name for '" + script_class_name + "'. Skipping...."
                      end
                        
                    else
                  end
                end # unless (script_class_name.nil?)

            end # if idx != 0
          end # @run_script_btn.add_action_listener do |e|

          add(@center_panel,JBorderLayout::CENTER)
      #    add(@script_picker,JBorderLayout::SOUTH)

          add_window_listener self
          pack

          # test_jython

        end

        def test_jython
#          @jython_app_launcher = JythonAppLauncher.new
          # TODO: (Jython) ...
          # This is just a test. Actual Jython integration TBD!
          jython_factory = JythonFactory.instance
#          @pythonFactoryClassPath = $CLASSPATH
#          @pythonFactoryClassPath = ENV['AppRoot'] + "/java/bin"
          @pythonFactoryClassPath = File.expand_path(File.dirname(__FILE__) + "../../../../../java/bin")
          @jythonFilePath = ENV['AppRoot'] + "/jython/scripting/scripts/samples"
          @javaClassName = "scripting.core.AbstractScript"
          @jythonFileName = @jythonFilePath + "/SampleScriptJython.py"
          puts "Running Jython Class: " + @jythonFileName + " ..."
          jython_factory.runAbstractScript(@pythonFactoryClassPath, @jythonFileName, JHashMap.new(@conn_from.conn_settings),JHashMap.new(@conn_to.conn_settings))
          puts "... Done."
        end

        def actionPerformed(event)
          @total += 1
        end

        # Bah, humbug!
        def windowActivated(event); end
        def windowClosed(event); end
        def windowDeactivated(event); end
        def windowDeiconified(event); end
        def windowIconified(event); end
        def windowOpened(event); end

        def windowClosing(event)
          puts "Total clicks: #{@total}"
          JSystem::exit 0
        end

      end # class ScriptRunner
    end # module Ui
  end # module Core
end # module Scripting