module Scripting
  module Scripts
    module Samples

      require 'java'
      require 'rubygems'
      require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems'
      require 'active_support' # Used here for 'ActiveSupport::JSON.encode(...)'


      require File.expand_path(File.join(File.dirname(__FILE__), '../../db/fgg_maximo_dataloads/fmdtbl.rb'))
#      require File.expand_path(File.join(File.dirname(__FILE__), '../../db/maximo/mxtbl.rb'))
#      require File.expand_path(File.join(File.dirname(__FILE__), '../../db/maximo/maxvars.rb'))
#      require File.expand_path(File.join(File.dirname(__FILE__), '../../db/maximo/maxsession.rb'))
#      require File.expand_path(File.join(File.dirname(__FILE__), '../../db/maximo/*.rb'))

      # explicit shortcut specifying namespaced class:
      Fmdtbl = Scripting::Db::FggMaximoDataloads::Fmdtbl unless defined?(Fmdtbl)
      MaximoProject = Scripting::Db::FggMaximoDataloads::MaximoProject unless defined?(MaximoProject)
      EnvironmentType = Scripting::Db::FggMaximoDataloads::EnvironmentType unless defined?(EnvironmentType)
      Env = Scripting::Db::FggMaximoDataloads::Env unless defined?(Env)
#      Maxsession = Scripting::Db::Maximo::Maxsession
#      Mxtbl = Scripting::Db::Maximo::Mxtbl
#      Maxvars = Scripting::Db::Maximo::Maxvars

      class SampleScriptJrubyMaximoEnvs < AbstractScript # EmptyScript # SampleScript # AbstractScript
          include Scripting

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

          def test_one
              record_counter = 0
              tbl_obj = MaximoProject
              record_set = tbl_obj.all
              record_set_count = record_set.count
              record_set.each_index do |i|
                a_record = record_set[i]
                record_counter = 1 + i
                msg = record_counter.to_s + " of " + record_set_count.to_s + ": " + ActiveSupport::JSON.encode(a_record)
                update_progress(10 + record_counter, msg);
                update_progress(10 + record_counter, "");

                envs_record_counter = 0
                envs_record_set = a_record.envs
                envs_record_set_count = record_set.count
                envs_record_set.each_index do |j|
                  envs_a_record = envs_record_set[j]
                  envs_record_counter = 1 + j
                  msg = ".. env " + envs_record_counter.to_s + " of " + envs_record_set_count.to_s + ": " + ActiveSupport::JSON.encode(envs_a_record)
                  update_progress(10 + record_counter, msg);
                  update_progress(10 + record_counter, "");
                end

              end
          end

          def test_two
              projs = MaximoProject.all # .select(:fgg_id,:name)
              env_types = EnvironmentType.all #.order(:position) # .select(:name)

              projs.each do |proj|
                msg = "MaximoProject: " + proj.name.to_s
                update_progress(@progressCurrent, msg);

                env_types.each do |env_type|
                  msg = "  EnvironmentType: " + env_type.name.to_s
                  update_progress(@progressCurrent, msg);

                  envs = Env.where(:maximo_project_id => proj.fgg_id, :environment_type_id => env_type.fgg_id).all
                  envs.each do |env|
                    msg = "    Env: " + ActiveSupport::JSON.encode(env)
                    update_progress(@progressCurrent, msg);
                  end
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
              update_progress(2, "Connecting with 'from' db for Maximo Environment info...");
              Fmdtbl.connect(self.fromConnParams)

              # test_one

              test_two

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

              Fmdtbl.disconnect(self.fromConnParams)
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
