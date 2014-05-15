module Scripting
  module Scripts
    module Samples

      require 'java'
      require 'rubygems'
      require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems'
      require 'active_support' # Used here for 'ActiveSupport::JSON.encode(...)'


      require File.expand_path(File.join(File.dirname(__FILE__), '../../db/maximo/mxtbl.rb'))
      require File.expand_path(File.join(File.dirname(__FILE__), '../../db/maximo/maxvars.rb'))
      require File.expand_path(File.join(File.dirname(__FILE__), '../../db/maximo/maxsession.rb'))
#      require File.expand_path(File.join(File.dirname(__FILE__), '../../db/maximo/*.rb'))

      Maxsession = Scripting::Db::Maximo::Maxsession
      Mxtbl = Scripting::Db::Maximo::Mxtbl
      Maxvars = Scripting::Db::Maximo::Maxvars

      class SampleScriptJrubyMaximo < AbstractScript # EmptyScript # SampleScript # AbstractScript
          include Scripting

          def self.description
            ret_val = self.class.name + ":"
            ret_val << AbstractScript.newline + AbstractScript.newline
            ret_val << "Required initial params:"
            ret_val << AbstractScript.newline
            ret_val << " * 'from' database settings (pointing to a Maximo database)"
            ret_val << AbstractScript.newline + AbstractScript.newline
            ret_val << "This is a minimal sample script that displays the version number (maxvars.max_upg) and session info (maxsession) from a Maximo db."
            ret_val
          end # def self.description

          def initialize
#              super
#              jframeName = self.name
#              setTitle(jframeName)
#              super(self.name)
              super("SampleScriptJrubyMaximo")

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

#              Maxvars.connect(self.fromConnParams)
#              msg = AbstractScript.newline
              msg = ""
              msg << "Maxvars.maximo_version == "
              msg << Maxvars.maximo_version.to_s
              update_progress(2, msg);
#              Maxvars.disconnect(self.fromConnParams)

#              Maxsession.connect(self.fromConnParams)
              mxs_count = Maxsession.count
              mxs_set = Maxsession.all
              mxs_set.each_index do |i|
                mxs = mxs_set[i]
                counter = 1 + i


#                msg = AbstractScript.newline + counter.to_s + " of " + mxs_count.to_s + ": " + mxs.inspect
#                update_progress(10 + counter, msg);
#                Maxsession.column_names.each do |col|
#                  msg = AbstractScript.newline + " .. " + col + ": " + mxs.send(col).to_s
#                  update_progress(10 + counter, msg);
#                end

#                msg = AbstractScript.newline + counter.to_s + " of " + mxs_count.to_s + ": " + ActiveSupport::JSON.encode(mxs)
                msg = counter.to_s + " of " + mxs_count.to_s + ": " + ActiveSupport::JSON.encode(mxs)
                update_progress(10 + counter, msg);

              end
  #            puts("... hello from jruby")

              #fromConnParamsWithoutPw.inspect

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

