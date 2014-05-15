module Scripting
  module Scripts
    module Samples

#      module Sr07476

        require 'java'
        require 'rubygems'
        require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems'
        require 'active_support' # Used here for 'ActiveSupport::JSON.encode(...)'
        require File.expand_path(File.dirname(__FILE__) + '/sample_tree.rb')

        JFrame = Java::javax.swing.JFrame unless defined?(JFrame)
        DefaultMutableTreeNode = Java::javax.swing.tree.DefaultMutableTreeNode unless defined?(DefaultMutableTreeNode)
        JScrollPane = Java::javax.swing.JScrollPane unless defined?(JScrollPane)
        SampleTree = Scripting::Scripts::Samples::SampleTree unless defined?(SampleTree)

        # explicit shortcut specifying namespaced class:
        Fmdtbl = Scripting::Db::FggMaximoDataloads::Fmdtbl unless defined?(Fmdtbl)
#        MaximoProject = Scripting::Db::FggMaximoDataloads::MaximoProject unless defined?(MaximoProject)
  #      Maxsession = Scripting::Db::Maximo::Maxsession
  #      Mxtbl = Scripting::Db::Maximo::Mxtbl
  #      Maxvars = Scripting::Db::Maximo::Maxvars

        class SampleScriptJtree < AbstractScript # EmptyScript # SampleScript # AbstractScript
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
              ret_val << " * 'from' database settings (pointing to FGG_MAXIMO_DATALOADS database)"
              ret_val << AbstractScript.newline + AbstractScript.newline
              ret_val << "This is a minimal sample script that displays the Maximo Envs per [MaximoProject,EnvironmentType]."
              ret_val
            end # def self.description

            def initialize
              super("SampleScriptJtree")

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

            def initUISettingsHook
              self.quickstart = false # i.e.: true = Hide options panel and just start running the script; false = Show options panel and require the user to click the "Start" button.
            end

            def initUIComponentsHook
              begin
#                @jtree_frame = JFrame.new
#                @jtree_frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE)

                @jtree_root = DefaultMutableTreeNode.new("Root")
                @jtree = JTree.new(@jtree_root)
#                @jtree = SampleTree.new()

                @jtree_scrollpane = JScrollPane.new(@jtree)

                self.optionsPanel.setLayout(JGridLayout.new(1,1))
                self.optionsPanel.add(@jtree_scrollpane)

              rescue Exception => e
                generic_exception_handler(e)
              end
            end

            def startScriptHook
              begin
                msg = "Starting..."
                update_progress(10, msg);

                update_progress(2, "Connecting with 'from' db for Maximo Environment info...");
                Fmdtbl.connect(self.fromConnParams)

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

                update_progress(80, msg);

                Fmdtbl.disconnect(self.fromConnParams)

               update_progress(100, msg);
              rescue Exception => e
                puts "Exception => e == " + e.inspect.to_s
                puts " ... backtrace == "
                e.backtrace.each do |a_step|
                  puts " >> " + a_step.to_s
                end
              end
            end

        end # class SampleScriptJtree

#      end # module Sr07476
    end # module Samples
  end # module Db
end # module Scripting
