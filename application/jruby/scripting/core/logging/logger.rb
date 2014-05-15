module Scripting
  module Core
    module Logging
      require 'java'
      require "log4j.jar"
      require File.expand_path(File.dirname(__FILE__) + "/../properties/log4jproperties.jar")

      # Logger.new("xyz").log.warn "This is my warning message"
      class Logger
        
        attr_accessor :log

        def initialize(name)
          @log = Java::org.apache.log4j.Logger.getLogger name
    #      @log.trace "This is my trace message"
    #      @log.debug "This is my debug message"
    #      @log.info "This is my info message"
    #      @log.warn "This is my warning message"
    #      @log.error "This is my error message"
    #      @log.fatal "This is my critical error message"
        end # def initialize

      end # class Logger
    end # module Logging
  end # module Core
end # module Scripting
