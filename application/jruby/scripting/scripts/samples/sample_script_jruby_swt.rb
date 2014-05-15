module Scripting
  module Scripts
    module Samples

      require 'java'
      require 'rubygems'
#      require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems'

      class SampleScriptJrubySwt < AbstractScript # EmptyScript # SampleScript # AbstractScript

          def self.description
            ret_val = self.class.name + ":"
            ret_val << AbstractScript.newline + AbstractScript.newline
            ret_val << AbstractScript.description
            ret_val << AbstractScript.newline + AbstractScript.newline
            ret_val << "This is a minimal sample script that demos SWT."
            ret_val
          end # def self.description

          def initialize
#              super
#              jframeName = self.name
#              setTitle(jframeName)
#              super(self.name)
              super("SampleScriptJrubySwt")
            log.warn("This is " + self.class.name + ".")
            puts "ClassPathReferences... self.class.name == " + self.class.name
            puts "ClassPathReferences... self.methods.inspect == " + self.methods.inspect
            puts "ClassPathReferences... self.instance_variables.inspect == " + self.instance_variables.inspect
          end

          def swt_demo
            display = org.eclipse.swt.widgets.Display.new
            shell = org.eclipse.swt.widgets.Shell.new(display)
            shell.setSize(800, 600)
            shell.setText("First Example")

            shell.setLayout(org.eclipse.swt.layout.RowLayout.new)
            org.eclipse.swt.widgets.Button.new(shell, \
                         org.eclipse.swt.SWT::PUSH).setText("Click me!")

            shell.open
            # Classic SWT stuff
            while (!shell.isDisposed) do
              display.sleep unless display.readAndDispatch
            end
            display.dispose
          end

          def startScriptHook
            msg = "*>* hello from jruby"
#           log.warn(msg)

            swt_demo

#            progressCurrent
            update_progress(10, msg);
#            puts("... hello from jruby")
#            exec('gem list') # TODO: Why is this killing the ui?
            #fromConnParamsWithoutPw.inspect
          end

          def endScriptHook
            msg = "*>* bye from jruby"
#           log.warn(msg)
           update_progress(80, msg);
#            @log.warn("bye from jruby")
#            updateProgress(80, "*>* bye from jruby");
#            puts("... bye from jruby")
            #fromConnParamsWithoutPw.inspect
           update_progress(100, msg);
          end
      end
    end
  end
end
