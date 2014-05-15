module Scripting
  module Scripts
    module Samples

      require 'java'
      require 'rubygems'
      require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems'
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
#              super
#              jframeName = self.name
#              setTitle(jframeName)
#              super(self.name)
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
#              msg = AbstractScript.newline + "*>* hello from jruby"
              msg = "Starting..."
              update_progress(10, msg);

  #            tbl_class = Maxsession
  #            tbl_object = tbl_class.new
  #            tbl_object.connect(self.fromConnParams)

  #            Maxsession.connect(self.fromConnParams)
              update_progress(2, "Connecting with 'from' db for Maximo version...");
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
#                si = line.split('\t')
                si = line.split("\t")
                siteid = nil
                itemnum = nil
                siteid = si[0] if (si.length > 0)
                itemnum = si[1].gsub("\r","").gsub("\n","") if (si.length > 1)

                inv_set = Inventory.select('orgid, siteid, location').where(:orgid => 'L4CP', :siteid => siteid, :itemnum => itemnum)
#                puts "inv_set.to_sql == #{inv_set.to_sql}"
                # update_progress(@progressCurrent, count_sets_to_s(count_sets) + ".. inv_set.to_sql == #{inv_set.to_sql}" + AbstractScript.newline)


                inv_loc_set = inv_set.collect{|rec| rec.store_loc_descr}

#                puts "siteid == #{siteid}, itemnum == #{itemnum}, location's == [#{inv_loc_set.join(', ')}]"
                # update_progress(@progressCurrent, count_sets_to_s(count_sets) + ".. siteid == #{siteid}, itemnum == #{itemnum}, location's == [#{inv_loc_set.join(', ')}]" + AbstractScript.newline)
                if (lines_count_current > 0)
                  to_file.write(siteid + "\t" + itemnum + "\t" + inv_loc_set.sort.uniq.join(', ') + "\n")
                else
                  to_file.write("siteid" + "\t" + "itemnum" + "\t" + "storerooms" + "\n")
                end
                to_file.flush
              end

              to_file.close
              from_file.close

#              Maxvars.connect(self.fromConnParams)
#              msg = AbstractScript.newline
              msg = ""
              update_progress(2, msg);
#              Maxvars.disconnect(self.fromConnParams)

##              msg = AbstractScript.newline + counter.to_s + " of " + mxs_count.to_s + ": " + ActiveSupport::JSON.encode(mxs)
#              msg = counter.to_s + " of " + mxs_count.to_s + ": " + ActiveSupport::JSON.encode(mxs)
#              update_progress(10 + counter, msg);


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
#              msg = AbstractScript.newline + "*>* bye from jruby"
              msg = "Done."
  #           log.warn(msg)

             update_progress(80, msg);

              Mxtbl.disconnect(self.fromConnParams)
#              Maxvars.disconnect(self.fromConnParams)
#              Maxsession.disconnect(self.fromConnParams)
  #            @log.warn("bye from jruby")
  #            updateProgress(80, "*>* bye from jruby");
  #            puts("... bye from jruby")
              #fromConnParamsWithoutPw.inspect
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

