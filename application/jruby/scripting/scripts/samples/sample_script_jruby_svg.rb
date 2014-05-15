module Scripting
  module Scripts
    module Samples

      require 'java'
      require 'rubygems'
#      require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems'
#      require 'quotes'


      class SampleScriptJrubySvg < AbstractScript # EmptyScript # SampleScript # AbstractScript

          def self.description
            ret_val = self.class.name + ":"
            ret_val << AbstractScript.newline + AbstractScript.newline
            ret_val << AbstractScript.description
            ret_val << AbstractScript.newline + AbstractScript.newline
            ret_val << "This is a minimal sample script to render an SVG image. See 'http://old.nabble.com/Example%3A-Quick-code-for-SVG-display-under-JRuby-td12079072.html'."
            ret_val
          end # def self.description

          def initialize
#              super
#              jframeName = self.name
#              setTitle(jframeName)
#              super(self.name)
              super("SampleScriptJrubySvg")
            log.warn("This is " + self.class.name + ".")
            puts "ClassPathReferences... self.class.name == " + self.class.name
            puts "ClassPathReferences... self.methods.inspect == " + self.methods.inspect
            puts "ClassPathReferences... self.instance_variables.inspect == " + self.instance_variables.inspect
          end

          def gen_svg

            include_class 'com.kitfox.svg.SVGDisplayPanel'
            include_class 'com.kitfox.svg.SVGCache'

            frame = javax.swing.JFrame.new("nui")
            panel = Java::com.kitfox.svg.SVGDisplayPanel.new
            panel.setPreferredSize(java.awt.Dimension.new(400, 400))
            frame.getContentPane.add(panel)
            frame.setDefaultCloseOperation javax.swing.JFrame::EXIT_ON_CLOSE
            frame.pack

            svg_text = <<END_SVG;
<svg width="400" height="400" style="fill:none;stroke-width:4">
<circle cx="200" cy="200" r="200" style="stroke:blue"/>
<circle cx="140" cy="140" r="40" style="stroke:red"/>
<circle cx="260" cy="140" r="40" style="stroke:red"/>
<polyline points="100 300 150 340 250 240 300 300" style="stroke:red"/>
</svg>
END_SVG
            p svg_text
            string_reader = java.io.StringReader.new(svg_text)
            uri = SVGCache.getSVGUniverse().loadSVG(string_reader, "myImage")
            panel.setDiagram(SVGCache.getSVGUniverse().getDiagram(uri))

            frame.setVisible true
          end

          def startScriptHook
            msg = "*>* hello from jruby"
#           log.warn(msg)
#            progressCurrent
            update_progress(10, msg);

            gen_svg

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
