module Scripting
  module Core
    module Ui

      require 'java'
      require 'rubygems'
      require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems'
      jython_jar_path = File.dirname(__FILE__) + '../../../../../java/lib/jython.jar'
      puts ("Is 'jython.jar' at: '" + jython_jar_path + "'?")
      require File.expand_path(jython_jar_path) # '../../../../java/lib/jython' # 'jython'

    #  $CLASSPATH << File.join(Rails.root, "bin")
    #  java_import Java::scripting.AbstractScript
    #  java_import Java::scripting.AbstractScript
    #  AbstractScript = Java::scripting.java.AbstractScript

      # Shortcuts to Java Classes (also to avoid name-space collisions):
      JGridLayout = java.awt.GridLayout unless defined? JGridLayout
    #  JBorderLayout = java.awt.BorderLayout
      JColor = java.awt.Color unless defined? JColor
    #  JLabel = javax.swing.JLabel
    #  JButton = javax.swing.JButton
      JPanel = javax.swing.JPanel unless defined? JPanel
    #  JTextField = javax.swing.JTextField
    #  JFileChooser = javax.swing.JFileChooser
      JComboBox = javax.swing.JComboBox unless defined? JComboBox
      JTitledBorder = javax.swing.border.TitledBorder unless defined? JTitledBorder
#      JTextField = javax.swing.JTextField unless defined? JTextField
      JScrollPane = javax.swing.JScrollPane unless defined? JScrollPane
      JTextArea = javax.swing.JTextArea unless defined? JTextArea

#      JythonFactory = Java::scripting.core.JythonFactory unless defined? JythonFactory

      class ScriptPicker < javax.swing.JPanel

    #    attr_reader :selected_index
    #    attr_reader :selected_item
    
        def is_jython_class(full_class_name)
          (['Jython::'].include?(full_class_name[0..7]))
        end

        def initialize(script_list, script_metadata)
          super()

          set_border(JTitledBorder.new("Script"))
          set_background(JColor.new(232,232,255))

#          # TODO: (Jython) ...
#          jf = JythonFactory.instance
#          javaClassName = "scripting.core.AbstractScript"
#          jythonFileName = ENV['AppRoot'] + "/jython/scripting/scripts/samples/SampleScriptJython.py"
#          jythonScript = jf.jython_object(javaClassName, jythonFileName)
#          puts "Launching Jython Class: " + jythonFileName + " ..."
#          jythonScript.runForConnParams(fromConnParams, toConnParams)
#          puts "... Done."

    #      @debug_mode = false # false # true

    #      @conn_from = Hash.new # nil
    #      @conn_to = Hash.new # nil

          @selected = nil
          @combo_box = JComboBox.new
          @combo_box.maximum_row_count = 8
          @combo_box.add_action_listener do |e|
            idx = selected_index # @combo_box.get_selected_index

    #        if @debug_mode
    #          p "======="
    #          p self.class.name + "...@jcb_script had an option selected:"
    #    #      p 'chosen perhaps?', e, @jcb_script.get_selected_index, e.get_source, @jcb_script.get_selected_item
    #          p '  e == ' + e.to_s
    #          p '  @jcb_script.get_selected_index == ' + @combo_box.get_selected_index.to_s
    #          p '  e.get_source == ' + e.get_source.to_s
    #          p '  @jcb_script.get_selected_item == ' + @combo_box.get_selected_item.to_s
    #        end

            if idx != 0
              @selected = selected_item # @combo_box.get_selected_item
#              @readme.text = "You picked " + @selected.to_s

              kls = nil
              @readme.text = ''
                # TODO: (Jython)
              if is_jython_class(selected_item)
                trouble_accessing_jython_class_methods = true # false # true
                if (trouble_accessing_jython_class_methods)
                  # TODO: fix bug re accessing a class method of a Jython class
                  @readme.text = "Jython Script. See source for 'description'."
                else
                  # puts "debug 1"
                  jython_factory = JythonFactory.instance
                  # puts "debug 2"
        #          @pythonFactoryClassPath = $CLASSPATH
        #          @pythonFactoryClassPath = ENV['AppRoot'] + "/java/bin"
                  @pythonFactoryClassPath = File.expand_path(File.dirname(__FILE__) + "../../../../../java/bin")
                  # puts "debug 3"
                  @jythonFilePath = ENV['AppRoot'] + "/jython/scripting/scripts/samples"
                  # puts "debug 4"
                  @javaClassName = "scripting.core.AbstractScript"
                  # puts "debug 5"
                  @jythonFileName = @jythonFilePath + "/SampleScriptJython.py"
                  # puts "debug 6"
                  # puts "Running Jython Class: " + @jythonFileName + " ..."
  #                jython_factory.runAbstractScript(@pythonFactoryClassPath, @jythonFileName, JHashMap.new(@conn_from.conn_settings),JHashMap.new(@conn_to.conn_settings))
                  # puts "... Done."
                  obj = jython_factory.getJythonObject(@pythonFactoryClassPath,@javaClassName,@jythonFileName)
                  # puts "debug 7"
                  kls = obj.java_class # .__init__
                  # puts "debug 8"
                  # puts "debug 8b, kls == " + kls.inspect
                  # @readme.text = ((kls.nil?) ? "" : kls.descr) # kls.descr # ((kls.nil?) ? "" : kls.descr)
                  # @readme.text = ((kls.nil?) ? "" : kls.classmethod(descriptionX)) # kls.descr # ((kls.nil?) ? "" : kls.descr)
                  @readme.text = ((kls.nil?) ? "" : kls.description) # kls.descr # ((kls.nil?) ? "" : kls.descr)
                  # puts "debug 9"
                end
              else
                kls = eval(selected_item)
                @readme.text = ((kls.nil?) ? "" : kls.description)
              end

#              @readme.text = eval(selected_item).description
              @readme.caret_position = 0 # Force scroll to top
    #          if @debug_mode
                p
                p '**** @jcb_script.get_selected_index == ' + idx.to_s
                p '**** @jcb_script.get_selected_item == ' + @selected.to_s
    #
    #            script_class_name = @selected.to_s
    #            unless (script_class_name.nil?)
    ##              script_results = eval(script_class_name + ".new('" + server + "','" + db + "','" + un + "','" + pw + "','" + dest + "')")
    #              script_results = eval(script_class_name + ".new('" + @conn_from + "','" + @conn_to + "')")
    #
    #            end
    #            # dispose
    #          end
            end
          end



    #      puts "1. txt_labels == " if @debug_mode
          txt_labels = [SpecialValues.pick_one_label] # ["- pick one -"]
    #      puts "1. txt_labels == " + txt_labels.inspect if @debug_mode


#          @script_metadata = script_metadata
    #      p '**** Check "script_list" for subclass of AbstractMaximoScript: ' + script_list.inspect if @debug_mode
          implemented_abstract_scripts = []
          if script_list.empty?
            # No scripts passed in.
          else
            script_list.each do |script_class_name|
    #          if eval(script_class_name) < AbstractMaximoScript # aka 'is_a'

              if is_jython_class(script_class_name)
                # Check if the Jython class is a sub-class of AbstractScript
                temp_script_class_name = "Java" + script_class_name[6..(script_class_name.length)]
                p '**** script_class_name == ' + script_class_name.to_s
                p '**** temp_script_class_name == ' + temp_script_class_name.to_s
                # TODO: (Jython) How do we test a Jython class for being a subclass of a Java Class?
                is_subclass_of_AbstractScript = true
#                is_subclass_of_AbstractScript = (eval(temp_script_class_name) < AbstractScript)
                if (is_subclass_of_AbstractScript)
                  implemented_abstract_scripts << script_class_name
                end

              else
                # Check if the (other) class a sub-class of AbstractScript
                if eval(script_class_name) < AbstractScript # aka 'is_a'
      #          if eval(script_class_name).kind_of?(AbstractScript)  # aka 'is_a'
      #          if eval(script_class_name) < Java::scripting.AbstractScript # aka 'is_a'
                  implemented_abstract_scripts << script_class_name
        #          p '**** Found subclass of AbstractMaximoScript: ' + script_class_name.to_s if @debug_mode
                else
        #          p '**** Not a subclass of AbstractMaximoScript: ' + script_class_name.to_s if @debug_mode
                end
              end
            end
            txt_labels << implemented_abstract_scripts # script_list

      #      puts "2. txt_labels == " + txt_labels.inspect if @debug_mode
            txt_labels.flatten!
      #      puts "3. txt_labels == " + txt_labels.inspect if @debug_mode
          end

          txt_labels.each do |lbl|
            @combo_box.add_item lbl
          end

    #      form_selectors.add(@combo_box)

          set_layout JBorderLayout.new
#          add(@combo_box)
          add(@combo_box,JBorderLayout::PAGE_START)


#          @readme = JTextField.new
          @readme = JTextArea.new
          @readme.line_wrap = true
          @readme.wrap_style_word = true
#          @readme.setHorizontalAlignment(JTextField::LEFT_ALIGNMENT)
#          @readme.setVerticalAlignment(JTextField::TOP_ALIGNMENT)
#          @readme.set_horizontal_alignment(JTextField::RIGHT_ALIGNMENT)
#          @readme.vertical_alignment = JTextField::BOTTOM_ALIGNMENT
#          add(JLabel.new(""),JBorderLayout::CENTER) # Spacer

#          add(@readme,JBorderLayout::CENTER)

          # TODO: Put '@readme' into a 'JScrollPane'. (Why does the following code not work?)
          @readme_panel = JScrollPane.new;
#          @readme_panel.add(@readme);
          @readme_panel.viewport.add(@readme);
          add(@readme_panel,JBorderLayout::CENTER) # Spacer

        end # def initialize(...)


        # external handle for adding action listeners and such:
        def combo_box
          @combo_box
        end

        # shortcut to get selected index:
        def selected_index
          @combo_box.get_selected_index
        end

        # shortcut to get selected item:
        def selected_item
          @combo_box.get_selected_item
        end
      end # class ScriptPicker
    end # module Ui
  end # module Core
end # module Scripting