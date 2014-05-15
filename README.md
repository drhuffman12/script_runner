script_runner
=============

Simple UI and framework for selecting and running scripts written in various languages via Java, JRuby, and JSR 223.

This uses a main 'AbstractScript' Java class and scripts which are sub-classes, along with a script-picker UI written in JRuby. These scripts are written in Java or other languages, such as JRuby and Jython.

Screenshots
---------------



Code Highlights
---------------

 Java:
  - "AbstractScript" and misc
    - abstract ui with areas for progress bar, progress text, start button, cancel/exit button, and script-specific-options
    - extended/sub-classed by scripts coded in Java, JRuby, and Jython (and potentially other languages that can extend a Java class)
  - sample scripts
  - Jars:
    - JRuby
    - Gem's (installed and jar'd via bat files ... or sh files)

Nailgun (optional):
  - "http://www.martiansoftware.com/nailgun/"
  - minimize JVM startup overhead
  - it's not secure, so be careful

JRuby:
  - 'script picker' ui
    - include/import Java Jar's and Class's
    - code to scan folders for scripts coded in Java, JRuby, and Jython and add them to the 'script picker' list
    - user selects:
      - 'from' db/folder info (editable pick lists)
      - desired script
      - 'start' button to launch the script (i.e.: use JRuby to launch scripts written in Java, JRuby, Jython, or other languages)
  - sample scripts
  - actual scripts using Active Record to read/write db's and/or generate sql scripts (e.g.: for app/db updates and data validation)

Jython:
  - sample scripts
  
Here is a sample script written in Java:

```java
package scripting.scripts.samples;

import java.util.HashMap;

import scripting.core.AbstractScript;

public class SampleScript extends AbstractScript {

    static public String description()
    {
        String linebreak = AbstractScript.newline;
        return "SampleScript:" + linebreak + linebreak + AbstractScript.description() + linebreak + linebreak + "This will display the connection options (database and path) entered in the script runner ui (with the password hidden) and add a bunch of lines of dummy text.";
    }

    public SampleScript()
    {
        super(null);
    }

    @Override
    public void startScriptHook() {
        String progMsgPrefix = "startScriptHook()";
        this.updateProgress(this.progressCurrent, progMsgPrefix + " ... FINISHED");
        /*
         * We don't really need 'try-catch' blocks, but we include for sake of example. Here we have:
         *   (a) We have three loops; one loop inside the other, so we will count up to an int[3][2] array.
         *   (b) For the 1st loop, we are on part u of v.
         *   (c) For the 2nd loop, we are on part w of x.
         *   (c) For the 3rd loop, we are on part y of z.
         *   (d) We re-calculate the progress counter with code like:
         *         recalcProgressByCounters(countSetsHelper(u, v, w, x, y, z));
         */
        try {
            this.updateProgress(0, progMsgPrefix + ".. this.fromConnParamsWithoutPw == " + this.fromConnParamsWithoutPw.toString());
            this.updateProgress(0, progMsgPrefix + ".. this.toConnParamsWithoutPw   == " + this.toConnParamsWithoutPw.toString());
            long millis = 10; // 1000;

            for (int u = 0, v = 10 ; u < v; u++)
            {
                try {
                    recalcProgressByCounters(countSetsHelper(u, v));
                    this.updateProgress(this.progressCurrent, progMsgPrefix + "this.progressCurrent == " + this.progressCurrent + " @ 1st level, step " + u + " of " + v); // this.newline
                    for (int w = 0, x = 2 ; w < x; w++)
                    {
                        try {
                            recalcProgressByCounters(countSetsHelper(u, v, w, x));
                            this.updateProgress(this.progressCurrent, progMsgPrefix + "this.progressCurrent == " + this.progressCurrent + " @ .. 2nd level, step " + w + " of " + x);
                            for (int y = 0, z = 5; y < z; y++)
                            {
                                try {
                                    recalcProgressByCounters(countSetsHelper(u, v, w, x, y, z));
                                    this.updateProgress(this.progressCurrent, progMsgPrefix + "this.progressCurrent == " + this.progressCurrent + " @ .. .. 3rd level, step " + y + " of " + z);
                                    this.runner.sleep(millis); // i.e.: Do something.
                                } catch (InterruptedException e) {
                                    // TODO Auto-generated catch block
                                    e.printStackTrace();
                                }
                            }
                        } catch (Exception e) {
                            // TODO Auto-generated catch block
                            e.printStackTrace();
                        }
                    }
                } catch (Exception e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
            }
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        this.updateProgress(this.progressCurrent, progMsgPrefix + " ... FINISHED");
    }

    @Override
    public void endScriptHook() {
        this.updateProgress(100, this.newline + ".. endScriptHook()");
    }

    /**
     * @param args
     */
    public static void main(String[] args) {
        // TODO Auto-generated method stub
        HashMap<String, String> fromConnParams = new HashMap<String, String>();
        HashMap<String, String> toConnParams = new HashMap<String, String>();

        fromConnParams.put("foo", "bar");
        toConnParams.put("widget", "builder");
        
        SampleScript ss = new SampleScript();
        ss.runForConnParams(fromConnParams, toConnParams);        
    }
}
```


Here is a sample script written in JRuby that collects some data from a Maximo db: 

```ruby
module Scripting
  module Scripts
    module Samples

      require 'java'
      require 'rubygems'
      require 'jdbcmssql-gems'
      require 'active_support' # Used here for 'ActiveSupport::JSON.encode(...)'

      require File.expand_path(File.join(File.dirname(__FILE__), '../../db/maximo/mxtbl.rb'))
      require File.expand_path(File.join(File.dirname(__FILE__), '../../db/maximo/inventory.rb'))

      Mxtbl = Scripting::Db::Maximo::Mxtbl unless defined?(Mxtbl)
      Inventory = Scripting::Db::Maximo::Inventory unless defined?(Inventory) unless defined?(Inventory)
      Locations = Scripting::Db::Maximo::Locations unless defined?(Locations)

      class SampleScriptJrubyMaximoGetStorerooms < AbstractScript # EmptyScript # SampleScript # AbstractScript
          include Scripting
          include Scripting::Scripts::Common::Misc

          def self.description
            ret_val = self.class.name + ":"
            ret_val << AbstractScript.newline + AbstractScript.newline
            ret_val << "Required initial params:"
            ret_val << AbstractScript.newline
            ret_val << " * 'from' database settings (pointing to a Maximo database)"
            ret_val << " * 'from' path (pointing to a text file containing the siteid's and itemnum's)"
            ret_val << AbstractScript.newline + AbstractScript.newline
            ret_val << "This is a minimal sample script that gets all storerooms for a siteid-itemnum combo from a Maximo db."
            ret_val
          end # def self.description

          def initialize
              super("SampleScriptJrubyMaximoGetStorerooms")

            begin
              log.warn(AbstractScript.newline + "This is " + self.class.name + ".")
            rescue Exception => e
              puts "Exception => e == " + e.inspect.to_s
              puts " ... backtrace == "
              e.backtrace.each do |a_step|
                puts " >> " + a_step.to_s
              end
            end
          end

          def startScriptHook
            begin
              msg = "Starting..."
              update_progress(0, msg);
              update_progress(0, "Connecting with 'from' db for Maximo version...");
              Mxtbl.connect(self.fromConnParams)
              from_path = self.fromConnParams['path']
              counter = 1
              from_file = File.new(from_path, "r")
              lines = []
              while (line = from_file.gets)
                lines << line
              end

              to_path = from_path + '.storelocations.txt'
              to_file = File.new(to_path, "w")
              lines_count_all = lines.count
              lines.each_index do |lines_count_current|

                line = lines[lines_count_current]
                puts "#{counter}: #{line}"

                count_sets = [[lines_count_current,lines_count_all]]
                recalc_progress_by_counters(count_sets)
                update_progress(@progressCurrent, count_sets_to_s(count_sets) + "processing: '#{line}'" + AbstractScript.newline)

                counter = counter + 1
                si = line.split("\t")
                siteid = nil
                itemnum = nil
                siteid = si[0] if (si.length > 0)
                itemnum = si[1].gsub("\r","").gsub("\n","") if (si.length > 1)

                inv_set = Inventory.select('orgid, siteid, location').where(:orgid => 'L4CP', :siteid => siteid, :itemnum => itemnum)
                inv_loc_set = inv_set.collect{|rec| rec.store_loc_descr}

                if (lines_count_current > 0)
                  to_file.write(siteid + "\t" + itemnum + "\t" + inv_loc_set.sort.uniq.join(', ') + "\n")
                else
                  to_file.write("siteid" + "\t" + "itemnum" + "\t" + "storerooms" + "\n")
                end
                to_file.flush
              end

              to_file.close
              from_file.close

              msg = "Ending ..."
              update_progress(@progressCurrent, msg);

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
              Mxtbl.disconnect(self.fromConnParams)
              msg = "Done."
              update_progress(100, msg);
            rescue Exception => e
              puts "Exception => e == " + e.inspect.to_s
              puts " ... backtrace == "
              e.backtrace.each do |a_step|
                puts " >> " + a_step.to_s
              end
            end
          end

      end # class SampleScriptJrubyMaximo

    end # module Samples
  end # module Scripts
end # module Scripting
```

Here is some sample code written in Jython:

```python
import scripting.core.AbstractScript
from java.lang import System as javasystem

class SampleScriptJython(scripting.core.AbstractScript):

    def __init__(self):
        javasystem.out.println("SampleScriptJython:Hello")
        scripting.core.AbstractScript.__init__(self,'SampleScriptJython')
        javasystem.out.println("SampleScriptJython:World")
    
    def startScriptHook(self):        
        for i in range(100):
            for j in range(40):
                scripting.core.AbstractScript.updateProgress(self,i,'SampleScriptJython.startScriptHook ... step # ' + str(i) + "," + str(j)) # + i)
     
    def endScriptHook(self):
        scripting.core.AbstractScript.updateProgress(self,100,'SampleScriptJython.endScriptHook')
        
    def descr(self):
         return "This is a sample Jython Script called 'SampleScriptJython'"
         
# @classmethod
    def description(self):
        return "This is a 'SampleScriptJython'"
```