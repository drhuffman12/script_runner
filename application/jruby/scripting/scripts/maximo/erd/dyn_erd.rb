module Scripting
  module Scripts
    module Maximo
      module Erd

        require 'java'
        require 'rubygems'
  #      require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems'

        SWT_Display = Java::org.eclipse.swt.widgets.Display unless defined?(SWT_Display)
        SWT_Shell = Java::org.eclipse.swt.widgets.Shell unless defined?(SWT_Shell)
        SWT_SWT = Java::org.eclipse.swt.SWT unless defined?(SWT_SWT)
        SWT_Tree = Java::org.eclipse.swt.widgets.Tree unless defined?(SWT_Tree)
        SWT_TreeColumn = Java::org.eclipse.swt.widgets.TreeColumn unless defined?(SWT_TreeColumn)
        SWT_TreeItem = Java::org.eclipse.swt.widgets.TreeItem unless defined?(SWT_TreeItem)

        SWT_Listener = Java::org.eclipse.swt.widgets.Listener unless defined?(SWT_Listener)
        SWT_GC = Java::org.eclipse.swt.graphics.GC unless defined?(SWT_GC)
        SWT_Rectangle = Java::org.eclipse.swt.graphics.Rectangle unless defined?(SWT_Rectangle)
        SWT_Color = Java::org.eclipse.swt.graphics.Color unless defined?(SWT_Color)
        SWT_Point = Java::org.eclipse.swt.graphics.Point unless defined?(SWT_Point)

        J_Math = Java::java.lang.Math unless defined?(JMath)

        Mxtbl = Scripting::Db::Maximo::Mxtbl
        Maxrelationship = Scripting::Db::Maximo::Maxrelationship unless defined?(Maxrelationship)
        Maxtable = Scripting::Db::Maximo::Maxtable unless defined?(Maxtable)
        Maxattribute = Scripting::Db::Maximo::Maxattribute unless defined?(Maxattribute)


        class DynErd < AbstractScript # EmptyScript # SampleScript # AbstractScript

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
                super("DynErd")
              log.warn("This is " + self.class.name + ".")
              puts "ClassPathReferences... self.class.name == " + self.class.name
              puts "ClassPathReferences... self.methods.inspect == " + self.methods.inspect
              puts "ClassPathReferences... self.instance_variables.inspect == " + self.instance_variables.inspect

              Mxtbl
              self.fromConnParams['database']

            end

            # static void checkItems(TreeItem item, boolean checked)
            def checkItems(item, checked)
              item.setGrayed(false)
              item.setChecked(checked)
              items = item.getItems() # TreeItem[]
              items.each do |item|
                checkItems(item, checked)
              end
            end

            # static void checkPath(TreeItem item, boolean checked, boolean grayed)
            def checkPath(item, checked, grayed)
                unless (item.nil?)
                  if (grayed)
                    checked = true
                  else
                    index = 0
                    items = item.getItems() # SWT_TreeItem[]
                    while (index < items.length)
                      child = items[index] # TreeItem
                      if (child.getGrayed() || checked != child.getChecked())
                        checked = grayed = true
                        break
                      end
                      index += 1
                    end
                  end
                  item.setChecked(checked)
                  item.setGrayed(grayed)
                  checkPath(item.getParentItem(), checked, grayed)
                end
            end

            def swt_demo
              display = SWT_Display.new
              shell = SWT_Shell.new(display)
              shell.setSize(800, 600)
              shell.setLayout(org.eclipse.swt.layout.FillLayout.new)
              shell.setText("Show results as a bar chart in Tree")


  #            tree = SWT_Tree.new(shell, SWT_SWT::BORDER) # 2048) # SWT_SWT.BORDER)
              tree = SWT_Tree.new(shell, SWT_SWT::BORDER | SWT_SWT::CHECK | SWT_SWT::MULTI | SWT_SWT::FULL_SELECTION)
              tree.setHeaderVisible(true)
              tree.setLinesVisible(true)
              column1 = SWT_TreeColumn.new(tree, SWT_SWT::NONE) # 0) # SWT_SWT.NONE)
              column1.setText("Bug Status")
              column1.setWidth(100)
              column2 = SWT_TreeColumn.new(tree, SWT_SWT::NONE) # 0) # SWT_SWT.NONE)
              column2.setText("Percent")
              column2.setWidth(200)
              states = ["Resolved", "New", "Won't Fix", "Invalid"]
              #mx_table_list = ["UI", "SWT", "OSGI"]

              update_progress(20, 'mx_table_list = ..');
              mx_table_list = []
              update_progress(20, 'mx_table_list = .. parent ..');
              #mx_table_list << Maxrelationship.select("parent").all.map(&:parent)
              mx_table_list << Mxtbl.find_by_sql("select distinct(parent) from maxrelationship").map{|rec| rec.parent}
              #update_progress(20, 'mx_table_list = .. child ..');
              #mx_table_list << Maxrelationship.select("child").all.map(&:child)
              #update_progress(20, 'mx_table_list = .. sort!.uniq! ..');
              #mx_table_list.sort!.uniq!
              update_progress(20, 'mx_table_list.sort!.uniq!');

              mx_table_list.each_index do |i|
                item = SWT_TreeItem.new(tree, SWT_SWT::NONE) # 0) # SWT_SWT.NONE)
                item.setText(mx_table_list[i])
                states.each_index do |j|
                  subItem = SWT_TreeItem.new(item, SWT_SWT::RADIO) # 0) # SWT_SWT.NONE)
                  subItem.setText(states[j])
                end
              end

              # NOTE: MeasureItem, PaintItem and EraseItem are called repeatedly.
              # Therefore, it is critical for performance that these methods be
              # as efficient as possible.
              tree.addListener(SWT_SWT::PaintItem,
                              SWT_Listener.impl do |method, event|
                                percents = [50, 30, 5, 15]
                                # def handleEvent(event)
                                  if (event.index == 1)
                                    item = event.item # SWT_TreeItem
                                    parent = item.getParentItem() # SWT_TreeItem
                                    unless (parent.nil?)
                                      gc = event.gc # SWT_GC
                                      index = parent.indexOf(item)
                                      percent = percents[index]
                                      foreground = gc.getForeground() # SWT_Color
                                      background = gc.getBackground() # SWT_Color
                                      gc.setForeground(display.getSystemColor(SWT_SWT::COLOR_RED))
                                      gc.setBackground(display.getSystemColor(SWT_SWT::COLOR_YELLOW))
                                      width = (column2.getWidth - 1) * percent / 100
                                      gc.fillGradientRectangle(event.x, event.y, width, event.height, true)
                                      rect2 = SWT_Rectangle.new(event.x, event.y, width-1, event.height-1) # SWT_Rectangle
                                      gc.drawRectangle(rect2)
                                      gc.setForeground(display.getSystemColor(SWT_SWT::COLOR_LIST_FOREGROUND))
                                      text = percent.to_s + "%"
                                      size = event.gc.textExtent(text) # SWT_Point
                                      offset = J_Math.max(0, (event.height - size.y) / 2)
                                      gc.drawText(text, event.x+2, event.y+offset, true)
                                      gc.setForeground(background)
                                      gc.setBackground(foreground)
                                    end # unless (parent.nil?)
                                  end # if (event.index == 1)
                                # end # def handleEvent(event)
                              end
              )


              tree.addListener(SWT_SWT::Selection,
                              SWT_Listener.impl do |method, event|
                                # public void handleEvent(Event event) {
                                    if (event.detail == SWT_SWT::CHECK)
                                        item = event.item
                                        checked = item.getChecked()
                                        checkItems(item, checked)
                                        checkPath(item.getParentItem(), checked, false)
                                    end
                                # }
                              end
              )

              shell.pack
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

              Mxtbl.connect(self.fromConnParams)
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
              Mxtbl.disconnect(self.fromConnParams)
             update_progress(80, msg);
  #            @log.warn("bye from jruby")
  #            updateProgress(80, "*>* bye from jruby");
  #            puts("... bye from jruby")
              #fromConnParamsWithoutPw.inspect
             update_progress(100, msg);
            end
        end # class DynErd

      end # module Logs
    end # module Maximo
  end # module Scripts
end # module Scripting