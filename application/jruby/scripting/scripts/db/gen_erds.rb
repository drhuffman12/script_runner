module Scripting
  module Scripts
    module Db

      require 'java'
      require 'rubygems'
      require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems'
      require "rails_erd/diagram/graphviz"
      
      # gem 'ActiveRecord-JDBC'
      require 'active_record'
      require 'jdbc_adapter'
    
      Mxtbl = Scripting::Db::Maximo::Mxtbl
      # Maxsession = Scripting::Db::Maximo::Maxsession
      # Maxvars = Scripting::Db::Maximo::Maxvars

#      require File.expand_path(File.join(File.dirname(__FILE__), '../../../db/fgg_maximo_dataloads/fmdtbl.rb'))
      Fmdtbl = Scripting::Db::FggMaximoDataloads::Fmdtbl unless defined?(Fmdtbl)
      # MaximoProject = Scripting::Db::FggMaximoDataloads::MaximoProject unless defined?(MaximoProject)
      # EnvironmentType = Scripting::Db::FggMaximoDataloads::EnvironmentType unless defined?(EnvironmentType)
      # Env = Scripting::Db::FggMaximoDataloads::Env unless defined?(Env)
      # EnvNode = Scripting::Db::FggMaximoDataloads::EnvNode unless defined?(EnvNode)
  
      # [Sr7476PoReceiptMapping,Sr7476ReceiptLinesXml,Sr7476ReceiptXml,Sr7476Steps]
      Sr7476PoReceiptMapping = Scripting::Db::FggMaximoDataloads::Sr07476::Sr7476PoReceiptMapping unless defined?(Sr7476PoReceiptMapping)
      Sr7476ReceiptLinesXml = Scripting::Db::FggMaximoDataloads::Sr07476::Sr7476ReceiptLinesXml unless defined?(Sr7476ReceiptLinesXml)
      Sr7476ReceiptXml = Scripting::Db::FggMaximoDataloads::Sr07476::Sr7476ReceiptXml unless defined?(Sr7476ReceiptXml)
      Sr7476Steps = Scripting::Db::FggMaximoDataloads::Sr07476::Sr7476Steps unless defined?(Sr7476Steps)

      # YumlDiagram.create
      class YumlDiagram < RailsERD::Diagram
        
              # ################################
              # RailsERD.options.orientation = :horizontal # :horizontal # :vertical
              # RailsERD.options.notation = :bachman # :simple # :bachman # :uml
              # # RailsERD.options.inheritance = :true # :false # :true
              # # RailsERD.options.polymorphism = :true # :false # :true
              # # RailsERD.options.attributes = :true # :false # :true
              # RailsERD.options.title = "My custom model diagram"
              # # RailsERD.options.filename = File.dirname(__FILE__) + "/erds/" + (RailsERD.options.title.split(/\s/).each { |seg| seg.capitalize}.join("_"))
              # RailsERD.options.filename = File.dirname(__FILE__) + "/erds/" + (RailsERD.options.title.split(/\s/).join("_"))
              # RailsERD.options.filetype = "yuml.me" 
# 
              # update_progress(@progressCurrent + 1, log_prefix + "Saving to: '" + RailsERD.options.filename + "." + RailsERD.options.filetype + "'")
              # Fmdtbl.connect(self.toConnParams)
#               
              # setup { @edges = [] }
#             
              # # Invoked once for each relationship
              # each_relationship do |relationship|
#                 
                # update_progress(@progressCurrent + 1, log_prefix + "    ... relationship: " + relationship.to_s + AbstractScript.newline)
#                 
                # line = if relationship.indirect? then "-.-" else "-" end
#             
                # arrow = case
                  # when relationship.one_to_one?   then "1#{line}1>"
                  # when relationship.one_to_many?  then "1#{line}*>"
                  # when relationship.many_to_many? then "*#{line}*>"
                # end
#             
                # edge = "[#{relationship.source}] #{arrow} [#{relationship.destination}]"
                # update_progress(@progressCurrent + 1, log_prefix + "    ... edge: " + edge.to_s + AbstractScript.newline)
#                 
                # @edges << edge
              # end
#             
              # # Should save or return the generated diagram
              # save { @edges * "\n" }
              
        setup { @edges = [] }
      
        RailsERD.options.title = "My custom model diagram"
        # RailsERD.options.filename = File.dirname(__FILE__) + "/erds/" + (RailsERD.options.title.split(/\s/).each { |seg| seg.capitalize}.join("_"))
        RailsERD.options.filename = File.dirname(__FILE__) + "/erds/" + (RailsERD.options.title.split(/\s/).join("_"))
        RailsERD.options.filetype = "txt"
        
        @edges = [] 
        # Invoked once for each relationship
        each_relationship do |relationship|
          puts "    ... relationship: " + relationship.to_s
          line = if relationship.indirect? then "-.-" else "-" end
      
          arrow = case
            when relationship.one_to_one?   then "1#{line}1>"
            when relationship.one_to_many?  then "1#{line}*>"
            when relationship.many_to_many? then "*#{line}*>"
          end
      
          
          edge = "[#{relationship.source}] #{arrow} [#{relationship.destination}]"
          puts "    ... edge: " + edge.to_s
          
          @edges << edge
        end
        
        puts
        puts(@edges * "\n")
        puts
      
        # Should save or return the generated diagram
        save { @edges * "\n" }
      end

      class GenErds < AbstractScript
          # include Scripting
          # include Scripting::Scripts::Common::ExceptionHandling # e.g.: def generic_exception_handler(e)
          # include Scripting::Scripts::Common::Exportable # e.g.: def script_path(root_path, script_file_name, include_date = true, include_time = true)
          # include Scripting::Scripts::Common::Xml
          # include Scripting::Scripts::Common::Misc

          def self.description
            ret_val = self.class.name + ":"
            ret_val << AbstractScript.newline + AbstractScript.newline
            ret_val << "This Generates an ERD of the database objects."
            ret_val
          end # def self.description

          def initialize
            super("GenErds")
          end

          def startScriptHook
            msg = "Starting"
            log_prefix = "startScriptHook() .. "
            @progressCurrent = 0
            update_progress(@progressCurrent, log_prefix + "Starting");
            begin
              update_progress(@progressCurrent + 1, log_prefix + "Connecting with 'from' db...")
              Mxtbl.connect(self.fromConnParams)

              update_progress(@progressCurrent + 1, log_prefix + "Connecting with 'to' db...")
              Fmdtbl.connect(self.toConnParams)
              
              RailsERD.options.orientation = :horizontal # :horizontal # :vertical
              RailsERD.options.notation = :bachman # :simple # :bachman # :uml
              RailsERD.options.inheritance = true # :false # :true
              RailsERD.options.polymorphism = true # :false # :true
              # RailsERD.options.indirect = true # :false # :true
              # RailsERD.options.attributes = [:foreign_keys,:primary_keys,:timestamps,:inheritance,:content] # :false # :true
              RailsERD.options.attributes = [:foreign_keys,:primary_keys,:timestamps,:inheritance] # :false # :true
              RailsERD.options.title = "My auto model diagram"
              # RailsERD.options.filename = File.dirname(__FILE__) + "/erds/" + (RailsERD.options.title.split(/\s/).each { |seg| seg.capitalize}.join("_"))
              RailsERD.options.filename = File.dirname(__FILE__) + "/erds/" + (RailsERD.options.title.split(/\s/).join("_"))
              RailsERD.options.filetype = "pdf" 

              update_progress(@progressCurrent + 1, log_prefix + "Saving to: '" + RailsERD.options.filename + "." + RailsERD.options.filetype + "'")
              Fmdtbl.connect(self.toConnParams)
              
              update_progress(@progressCurrent + 1, log_prefix + "domain = RailsERD::Domain.new");
              # domain = RailsERD::Domain.new([Maxsession,Maxsession,MaximoProject,EnvironmentType,Env,EnvNode])
              domain = RailsERD::Domain.new([Sr7476PoReceiptMapping,Sr7476ReceiptLinesXml,Sr7476ReceiptXml,Sr7476Steps])
                    

              # update_progress(@progressCurrent + 1, log_prefix + "domain = RailsERD::Domain.generate");
              # domain = RailsERD::Domain.generate
              
              # update_progress(@progressCurrent, log_prefix + "  ... domain == " + ActiveSupport::JSON.encode(domain) + AbstractScript.newline)

              update_progress(@progressCurrent + 1, log_prefix + "  ... domain == " + domain.to_s + AbstractScript.newline)

              update_progress(@progressCurrent + 1, log_prefix + "  ... domain.entities : " + AbstractScript.newline)
              domain.entities.each do |entity|
                update_progress(@progressCurrent + 1, log_prefix + "    ... " + entity.to_s + AbstractScript.newline)
              end

              update_progress(@progressCurrent + 1, log_prefix + "  ... domain.relationships : " + AbstractScript.newline)
              domain.relationships.each do |relationship|
                update_progress(@progressCurrent + 1, log_prefix + "    ... " + relationship.to_s + AbstractScript.newline)
              end

              update_progress(@progressCurrent + 1, log_prefix + "  ... domain.specializations : " + AbstractScript.newline)
              domain.specializations.each do |sp|
                update_progress(@progressCurrent + 1, log_prefix + "    ... " + sp.to_s + AbstractScript.newline)
              end

              
              update_progress(@progressCurrent + 1, log_prefix + "RailsERD::Diagram::Graphviz.create ... ");
              RailsERD::Diagram::Graphviz.create
              
              update_progress(@progressCurrent + 1, log_prefix + "YumlDiagram.create ...");
              YumlDiagram.create
              
              update_progress(@progressCurrent + 1, log_prefix + "DONE");
              
              
            rescue Exception => e
              update_progress(@progressCurrent, log_prefix + "EXCEPTION")
              puts log_prefix + "Exception => e == " + e.inspect.to_s
              puts log_prefix + " ... backtrace == "
              e.backtrace.each do |a_step|
                puts log_prefix + " >> " + a_step.to_s
              end
            end
              update_progress(@progressCurrent, log_prefix + "EXITING")
          end

          def endScriptHook
            msg = "Done"
            update_progress(100, msg);
          end
      end
    end
  end
end
