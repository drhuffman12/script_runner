#! /usr/bin/jruby

# Filename: start.rb
# Run via: java -jar jruby-complete-1.6.0.RC2.jar -S max_script_gen.rb
# Description: Launch main window for script picker/generator.

@header_debug_mode = true # false # true
#JRUBY_OPTS="--1.9"
puts "ENV['AppRoot'] == " + ENV['AppRoot'].to_s

ENV['AppRoot'] = File.expand_path(File.dirname(__FILE__))

puts "ENV['AppRoot'] == " + ENV['AppRoot'].to_s

require 'java'
require 'rubygems'
require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems.jar'
$CLASSPATH << 'java/lib' # FOR JAVA! Must add any applicable 'classpaths'
$CLASSPATH << 'java/bin' # FOR JAVA! Must add any applicable 'classpaths'

JythonFactory = Java::scripting.core.JythonFactory unless defined? JythonFactory

## For launching Jython apps (or other languages via Java's JSR-223 scripting engines):
## See: "http://jythonpodcast.hostjava.net/jythonbook/en/1.0/JythonAndJavaIntegration.html#using-jython-within-java-applications"
#java_import org.python.core.PyException
#java_import org.python.core.PyInteger
#java_import org.python.core.PyObject
#java_import org.python.util.PythonInterpreter
##java_import javax.script.ScriptEngine
##java_import javax.script.ScriptEngineManager
##java_import javax.script.ScriptException
##JScriptEngine        = javax.script.ScriptEngine
##JScriptEngineManager = javax.script.ScriptEngineManager
##JScriptException     = javax.script.ScriptException


# For launching Jython apps (or other languages via Java's JSR-223 scripting engines):

#libdir = File.dirname(__FILE__)
#libdir_expanded = File.expand_path(File.dirname(__FILE__))
#$:.unshift(libdir_expanded) unless
#    $:.include?(libdir) || $:.include?(File.expand_path(libdir_expanded))
puts "log4j..."
require ENV['AppRoot'] + '/java/lib/log4j.jar'
puts "...log4j"

@script_list = []
#@logger = Scripting::Core::Logging::Logger.new(self.class.name)
#@logger.log.info "initialize(#{script_list})"  

@script_metadata = Hash.new

def indent_chars(indent_level, indent_char = "  ")
  indent_char*indent_level
end

def line_separator
  Java::java.lang.System.getProperty("line.separator")
end

def include_for_path_and_file_filter(path_root,sub_path,file_filter)
  @indent_level = 2
    puts
  @script_root = File.expand_path(File.dirname(__FILE__) + path_root)
  puts(indent_chars(@indent_level) + "path_root      : " + path_root) if @header_debug_mode
  puts(indent_chars(@indent_level) + "sub_path       : " + sub_path) if @header_debug_mode
  puts(indent_chars(@indent_level) + "file_filter    : " + file_filter) if @header_debug_mode
  puts(indent_chars(@indent_level) + ".. @script_root: " + @script_root) if @header_debug_mode

  Dir[@script_root + sub_path + file_filter].each do |req_file_path|
    begin
      @indent_level = 3
      puts
      req_file_name_without_ext = (File.basename(req_file_path, File.extname(req_file_path))).to_s
      puts(indent_chars(@indent_level) + "req_file_path: " + req_file_path) if @header_debug_mode
      puts(indent_chars(@indent_level) + "req_file_name_without_ext: " + req_file_name_without_ext) if @header_debug_mode

      # **** Dynamically convert the file sub-script-root path (i.e.: under '@script_root') into a jar/class name for inclusion.
      # Remove '@script_root' and '/' from path:
      puts(indent_chars(@indent_level) + "@script_root        : " + @script_root + ", @script_root.length == " + @script_root.length.to_s) if @header_debug_mode
      sub_script_root_part = (File.dirname(req_file_path)).gsub(@script_root + '/',"")
      puts(indent_chars(@indent_level) + "sub_script_root_part: " + sub_script_root_part + ", sub_script_root_part.length == " + sub_script_root_part.length.to_s) if @header_debug_mode
      (sub_script_root_part).gsub!(@script_root + '/',"") # Am I getting '@script_root' pre-pended an extra time? Work-around for now is to trim it twice.
      puts(indent_chars(@indent_level) + "sub_script_root_part: " + sub_script_root_part + ", sub_script_root_part.length == " + sub_script_root_part.length.to_s) if @header_debug_mode


      # Convert to array, dividing at "/"'s:
      sub_script_root_part_array = sub_script_root_part.split('/')

      # Separate the path/package/module parts vs the jar/class name part):
      path_parts = sub_script_root_part
      file_part = File.basename(req_file_path)
      puts(indent_chars(@indent_level) + "sub_script_root_part_array: " + sub_script_root_part_array.join('/')) if @header_debug_mode
      puts(indent_chars(@indent_level) + "file_part: " + file_part) if @header_debug_mode

      # Now, we do our filtering to convert the path parts to package/module parts:
      puts(indent_chars(@indent_level) + "Attempting to require: " + req_file_path) if @header_debug_mode
      lang = ""
      req_class_name = ""
      req_pkg_or_mod_name = ""
      req_or_include_cmd = ""
#      case File.extname(file_part)
      case File.extname(req_file_path)
        when ".class" #:
          lang = "Java"
          req_pkg_or_mod_name = sub_script_root_part_array.join(".") + "." if (sub_script_root_part_array.length > 0)
          req_class_name = req_file_name_without_ext
          req_pkg_or_mod_class_name = "Java::#{req_pkg_or_mod_name}#{req_class_name}"
          req_or_include_cmd = "java_import #{req_pkg_or_mod_class_name}"
        when ".jar"  #:
          lang = "Java"
          req_or_include_cmd = "require '#{req_file_path}'"
        when ".rb"   #:
          lang = "JRuby"
#         req_pkg_or_mod_name = (sub_script_root_part_array.each { |name_part| name_part.to_s.capitalize! }).join("::") + "::" if (sub_script_root_part_array.length > 0)
          if (sub_script_root_part_array.length > 0)
            tmp_str = ''
            tmp_arr = sub_script_root_part_array.each do |name_part|
#              name_part.to_s.capitalize!
              name_part.to_s.split("_").each do |sub_name_part|
                tmp_str << sub_name_part.to_s.capitalize
              end #.capitalize!
              tmp_str << "::"
            end
#            req_pkg_or_mod_name = tmp_arr.join("::") + "::"
            req_pkg_or_mod_name = tmp_str
          else
            req_pkg_or_mod_name = ''
          end
          req_class_name = (req_file_name_without_ext.split("_").each { |name_part| name_part.to_s.capitalize! }).join("")
          req_pkg_or_mod_class_name = "#{req_pkg_or_mod_name}#{req_class_name}"
          req_or_include_cmd = "require '#{req_file_path}'"

        when ".py"  #:
          lang = "Jython"
          req_pkg_or_mod_name = sub_script_root_part_array.join(".") + "." if (sub_script_root_part_array.length > 0)
          req_class_name = req_file_name_without_ext
          req_pkg_or_mod_class_name = "Jython::#{req_pkg_or_mod_name}#{req_class_name}"
          req_or_include_cmd = "# jython_import #{req_pkg_or_mod_class_name}"
          

        else

      end             
  
      @script_metadata[req_pkg_or_mod_class_name] = {
                                                      'lang' => lang,
                                                      'req_pkg_or_mod_name' => req_pkg_or_mod_name,
                                                      'req_class_name' => req_class_name,
                                                      'req_or_include_cmd' => req_or_include_cmd
                                                    }

      # Now, require (or include) the file, but only if it made it through our filtering:
      @indent_level = 4
      puts
#      if (req_or_include_cmd.blank?)
      if (req_or_include_cmd.empty?)
        puts(indent_chars(@indent_level) + "Couldn't require : '" + req_file_path + "'")
      else
        puts(indent_chars(@indent_level) + "  ... req_or_include_cmd    : '" + req_or_include_cmd + "'") if @header_debug_mode

        begin
          eval(req_or_include_cmd)
          puts(indent_chars(@indent_level) + "Required                    : '" + req_file_path + "'") if @header_debug_mode
          puts(indent_chars(@indent_level) + "  aka                       : '" + req_file_name_without_ext + "'") if @header_debug_mode
          puts(indent_chars(@indent_level) + "  req_pkg_or_mod_name       : '" + req_pkg_or_mod_name.to_s + "'") if @header_debug_mode
          puts(indent_chars(@indent_level) + "  req_class_name            : '" + req_class_name.to_s + "'") if @header_debug_mode
          puts(indent_chars(@indent_level) + "  req_pkg_or_mod_class_name : '" + req_pkg_or_mod_class_name.to_s + "'") if @header_debug_mode
#          puts(indent_chars(@indent_level) + "  req_or_include_cmd        : '" + req_or_include_cmd + "'") if @header_debug_mode
        rescue Exception => e
          puts(indent_chars(@indent_level) + "Error requiring             : '" + req_file_path + "'")
          puts(indent_chars(@indent_level) + "  Error                     : " + e.inspect)
        end

        if ([".class",".rb"].include?(File.extname(req_file_path)))
          # if eval(script_class_name).kind_of?(AbstractScript)  # aka 'is_a'
          if (eval(req_pkg_or_mod_class_name) < AbstractScript)  # aka 'is_a'
          # if (eval(req_pkg_or_mod_class_name).is_a?(AbstractScript))
            @indent_level = 5
            puts
            puts(indent_chars(@indent_level) + "... and it is a subclass of 'AbstractScript'")
            @script_list << req_pkg_or_mod_class_name
          end
        elsif ([".py"].include?(File.extname(req_file_path)))
          unless (['__init__'].include?(req_file_name_without_ext))
          
            # @script_root
            # sub_script_root_part
            # req_file_name_without_ext
          
            jython_factory = JythonFactory.instance
            # puts "debug 2"
            @pythonFactoryClassPath = ENV['AppRoot'] + "/java/bin"
            #@pythonFactoryClassPath = File.expand_path(File.dirname(__FILE__) + "../../../../../java/bin")
            # puts "debug 3"
            @jythonFilePath = ENV['AppRoot'] + "/jython/" + sub_script_root_part
            # puts "debug 4"
            @javaClassName = "scripting.core.AbstractScript"
            # puts "debug 5"
            @jythonFileName = @jythonFilePath + "/" + req_file_name_without_ext + ".py"
            # puts "debug 6"
            # puts "Running Jython Class: " + @jythonFileName + " ..."
#                jython_factory.runAbstractScript(@pythonFactoryClassPath, @jythonFileName, JHashMap.new(@conn_from.conn_settings),JHashMap.new(@conn_to.conn_settings))
            # puts "... Done."
            begin
              # puts "@pythonFactoryClassPath == " + @pythonFactoryClassPath
              # puts "@javaClassName == " + @javaClassName
              # puts "@jythonFileName == " + @jythonFileName
              obj = jython_factory.getJythonObject(@pythonFactoryClassPath,@javaClassName,@jythonFileName)
              # puts "debug 7"
              kls = obj.java_class # .__init__
              puts(indent_chars(@indent_level) + "... Jython Script... Is it a subclass of 'AbstractScript'?")
              # if (kls < AbstractScript)
              # if (kls.kind_of?(AbstractScript))  # aka 'is_a'
              # if (kls < AbstractScript)  # aka 'is_a'
              # if (kls.is_a?(AbstractScript))
              if (obj.kind_of?(AbstractScript))  # aka 'is_a'
              # if (obj < AbstractScript)  # aka 'is_a'
              # if (obj.is_a?(AbstractScript))
                puts(indent_chars(@indent_level) + "... Jython Script... Is a subclass of 'AbstractScript'.")
                @script_list << req_pkg_or_mod_class_name
              else
                puts(indent_chars(@indent_level) + "... Jython Script... Is NOT a subclass of 'AbstractScript'.")
              end
            rescue Exception => e
                puts(indent_chars(@indent_level) + "... Jython Script... Is NOT a subclass of 'AbstractScript' (or is broken).")
            end
          end # unless (['__init__'].include?(req_file_name_without_ext))
        end # if ([".class",".rb"].include?(File.extname(req_file_path))) .. elsif ([".py"].include?(File.extname(req_file_path)))

      end # if (req_or_include_cmd.blank?)

      puts
    rescue Exception => e
      puts "Exception => e == " + e.inspect.to_s
      puts " ... backtrace == "
      e.backtrace.each do |a_step|
        puts " >> " + a_step.to_s
      end
    end
  end
  puts
end

# Get list of script file names and (a) require them for code access, and (b) pass them as param for picklist
def include_dependant_files_and_get_scripts
  @indent_level = 0
      puts

  @indent_level = 1
      puts

  # TODO: consolidate all these "puts" to use log4j instead.
  # TODO: Remove unnecessary logging (or make them 'info').
  #  @logger = Scripting::Core::Logging::Logger.new(self.class.name)
  #  @logger.log.info "initialize(#{script_list})"

  # TODO: determine and fix why order of '@includes' is not followed.
    @includes = [
                # {:path_root => '/properties', :file_filter => '/**/*.jar'},
                 {:path_root => '/java/lib', :file_filter => '/**/*.jar'},
                 {:path_root => '/java/lib', :file_filter => '/**/*.class'},
  #               {:path_root => '/bin/scripting', :file_filter => '/**/*.class'},
                 {:path_root => '/java/bin', :sub_path => '/scripting', :file_filter => '/**/*.class'},
#                 {:path_root => '/java/bin', :sub_path => '/scripting/core', :file_filter => '/**/*.class'},
#                 {:path_root => '/java/bin', :sub_path => '/scripting/scripts', :file_filter => '/**/*.class'},
#                 {:path_root => '/java/bin', :file_filter => '/**/*.class'},
                 {:path_root => '/jruby', :sub_path => '/scripting', :file_filter => '/**/*.rb'},
#                 {:path_root => '/jruby', :sub_path => '/scripting/core', :file_filter => '/**/*.rb'},
#                 {:path_root => '/jruby', :sub_path => '/scripting/db', :file_filter => '/**/*.rb'},
##                 {:path_root => '/jruby', :sub_path => '/scripting/scripts', :file_filter => '/**/*.rb'} #,
#                 {:path_root => '/jruby', :sub_path => '/scripting/scripts', :file_filter => '/**/*.rb'} ,
                 {:path_root => '/jython', :sub_path => '/scripting', :file_filter => '/**/*.py'} #,
#                 {:path_root => '/jython', :sub_path => '/scripting/scripts', :file_filter => '/**/*.py'} #,
  #               {:path_root => '/models', :file_filter => '/**/*.rb'},
  #               {:path_root => '/scripts', :file_filter => '/**/*.rb'},
  #               {:path_root => '/scripts', :file_filter => '/**/*.class'}
                ]

#  require 'fileutils'
#  include FileUtils
  jvm_bits = Java::java.lang.System.getProperty("sun.arch.data.model")
  puts "jvm_bits.inspect == '" + jvm_bits.inspect + "'"
  # TODO: Handle 32 vs 64 bit jars.
  # if (jvm_bits == 64)
#  if (["64"].include?(jvm_bits))
##    @includes << {:path_root => '/java/lib64', :file_filter => '/**/*.jar'}
##    $CLASSPATH << 'java/lib64' # FOR JAVA! Must add any applicable 'classpaths'
##    puts "Loaded additional Jar files for 64-bit"
##    Fileutils.cp '/java/lib64', '/java/lib'
##    puts "Loaded additional Jar files for 64-bit"
#  else
##    @includes << {:path_root => '/java/lib32', :file_filter => '/**/*.jar'}
##    $CLASSPATH << 'java/lib32' # FOR JAVA! Must add any applicable 'classpaths'
##    puts "Loaded additional Jar files for 32-bit"
##    Fileutils.cp '/java/lib32', '/java/lib'
#  end
#  puts "Loading additional Jar files for " + jvm_bits + "-bit"
##  cmd_str = 'xcopy "' + File.expand_path(File.dirname(__FILE__) + '/java/lib' + jvm_bits + '/*.*') + '" "' + File.expand_path(File.dirname(__FILE__) + '/java/lib"')
#  cmd_str = 'xcopy ' + File.expand_path(File.dirname(__FILE__) + '/java/lib' + jvm_bits + '/*.*') + ' ' + File.expand_path(File.dirname(__FILE__) + '/java/lib')
#  cmd_str = cmd_str.gsub("/","\\") + ' /e'
#  puts(cmd_str)
#  exec(cmd_str)
#  puts "Loaded additional Jar files for " + jvm_bits + "-bit"

  @includes.each do |incl|
    path_root = incl[:path_root]
    sub_path = incl[:sub_path] ||= ''
    file_filter = incl[:file_filter]

    puts "path_root == " + path_root
    puts "sub_path == " + sub_path
    puts "file_filter == " + file_filter
    # include_for_path_and_file_filter(path_root,sub_path,file_filter)
    # Append the Loadpath:
    $: << File.expand_path(File.dirname(__FILE__) + path_root)
  end
  @includes.each do |incl|
    path_root = incl[:path_root]
    sub_path = incl[:sub_path] ||= ''
    file_filter = incl[:file_filter]

    puts "path_root == " + path_root
    puts "sub_path == " + sub_path
    puts "file_filter == " + file_filter
    # Require files and look for scripts:
    include_for_path_and_file_filter(path_root,sub_path,file_filter)
  end

  puts
  @script_list.sort!
#  puts "@script_list.inspect == " + @script_list.inspect if @header_debug_mode
end

#include_dependant_files_and_get_scripts

#exec('gem list')

include_dependant_files_and_get_scripts

case ARGV[0]
  when 'test'
    puts 'testing...'
    puts("")

    script_class = eval(ARGV[1])
    if (script_class < AbstractScript)

      fr_server = (ARGV[2] ||= '')
      fr_database = (ARGV[3] ||= '')
      fr_username = (ARGV[4] ||= '')
      fr_password = (ARGV[5] ||= '')
      fr_path = (ARGV[6] ||= '')

      to_server = (ARGV[7] ||= '')
      to_database = (ARGV[8] ||= '')
      to_username = (ARGV[9] ||= '')
      to_password = (ARGV[10] ||= '')
      to_path = (ARGV[11] ||= '')

      JHashMap = java.util.HashMap unless defined? JHashMap

#      Overview = Scripting::Scripts::FggMaximoDataloads::Sr07476::Overview unless defined?(Overview)
#      script_class = Overview

#      from_conn_settings = {"server" => "GVSDFGG442", "database" => "FGG_MAXIMO_DATALOADS", "username" => un, "path" => "", "password" => pw}
      from_conn_settings = {"server" => fr_server, "database" => fr_database, "username" => fr_username, "path" => fr_path, "password" => fr_password}
      to_conn_settings = {"server" => to_server, "database" => to_database, "username" => to_username, "path" => to_path, "password" => to_password}
  #    script_results = (script_class.new).runForConnParams(JHashMap.new(@conn_from.conn_settings),JHashMap.new(@conn_to.conn_settings))

      obj = script_class.new
      Thread.new do
        script_results = obj.runForConnParams(JHashMap.new(from_conn_settings),JHashMap.new(to_conn_settings))
        puts("script_results == " + script_results.inspect)
      end


      delay_in_secs = 10
      Thread.new do
        puts("checking obj status")
        while (obj)
          while (['running'].include?(obj.status[0]))
  #        until (['exiting'].include?(obj.status[0]))
            sleep(delay_in_secs)
            puts obj.to_s + ": still running"
            puts obj.to_s + "..."
  #          'exiting','Overview'
          end
        end
        puts("sleeping")
        sleep(delay_in_secs)
      end
    else
      puts("Usage:")
      puts("    start.rb test <script_class> <fr_server> <fr_database> <fr_username> <fr_password> <fr_path> <to_server> <to_database> <to_username> <to_password> <to_path>")
    end

    puts("")
  else
    puts 'running ui...'

    script_runner = Scripting::Core::Ui::ScriptRunner.new(@script_list,@script_metadata)
    script_runner.set_visible(true)

#    while (defined?(script_runner))
#      puts "defined?(script_runner) " + Time.now.to_s
#      sleep(10)
#    end
#    puts "UN-defined?(script_runner) " + Time.now.to_s
end
