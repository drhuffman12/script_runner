module Scripting
  module Scripts
    module Utils

      require 'java'
      require 'rubygems'
#      require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems'
#require 'win32ole'
  require 'fileutils'

      class LowercaseAllFilenames < AbstractScript # EmptyScript # SampleScript # AbstractScript

            include Scripting

            def self.description
              ret_val = self.class.name + ":"
              ret_val << AbstractScript.newline + AbstractScript.newline
              ret_val << "Required initial params:"
              ret_val << AbstractScript.newline
              ret_val << " * 'from' path setting"
              ret_val << AbstractScript.newline
              ret_val << " * 'to' path setting"
              ret_val << AbstractScript.newline + AbstractScript.newline
              ret_val << "This is to copy all files in the 'from' path  and paste them in the 'to' path but using lowercase filenames."
              ret_val
            end # def self.description

#  include 'fileutils'
          def initialize
            super("LowercaseAllFilenames")
            log.warn("This is " + self.name + ".")
          end

          def force_folder_for_path(path)
            begin
              if (File.directory?(path))
                folder_path = File.expand_path(path)
              else
                folder_path = File.expand_path(File.dirname(path))
              end
              folder_path
            rescue Exception => e
              raise e
            end
          end

          def startScriptHook
            begin
              msg = "About to " + self.class.name + " from '" + self.fromConnParams['path'].to_s + "' to '" + self.toConnParams['path'].to_s + "'..."
#           log.warn(msg)
              from_path = force_folder_for_path(self.fromConnParams['path'].to_s)
              to_path = force_folder_for_path(self.toConnParams['path'].to_s)


#                fso = WIN32OLE.new("Scripting.FileSystemObject")
#                folder = fso.GetFolder(self.fromConnParams['path'].to_s)
#                file_count = folder.Files.count
#                msg = "There are " + file_count.to_s + " file(s) in folder '" + path + "'"
#                update_progress(10, msg);

              files = Dir.glob(from_path + '/**/*')
              files.each do |file|
                puts file
                from_file_path = File.expand_path(file)
                file_name = File.basename(file).downcase

#                file_name_len = file_name.length
#                sub_path = File.expand_path(file).gsub(from_path,"")
#                sub_path_len = sub_path.length
#                sub_path = sub_path[0..(sub_path_len-file_name_len)] # trim the filename out

                sub_path = File.dirname(file).gsub(from_path,"")

                dest_folder_path = to_path + "/" + sub_path
                dest_file_path = to_path + "/" + sub_path + "/" + file_name
                FileUtils.mkdir(dest_folder_path) unless (File.directory?(dest_folder_path))
                if (File.directory?(file))
#                  File.delete(dest_file_path) if (File.file?(dest_file_path))
#                  FileUtils.cp(file,dest_file_path)
                   FileUtils.mkdir(dest_file_path) unless (File.directory?(dest_file_path))
                else
                  File.delete(dest_file_path) if (File.file?(dest_file_path))
                  FileUtils.cp(file,dest_file_path)
                end
                update_progress(50, "Copied '" + from_file_path + "' to '" + dest_file_path + "'");
              end



#            progressCurrent
              update_progress(10, msg);
#            puts("... hello from jruby")
#            exec('gem list')
            rescue Exception => e
              puts "Exception => e == " + e.inspect.to_s
              puts " ... backtrace == "
              e.backtrace.each do |a_step|
                puts " >> " + a_step.to_s
              end
            end
          end # startScriptHook

          def endScriptHook
            begin
              msg = "About to " + self.class.name + " from '" + self.fromConnParams['path'].to_s + "' to '" + self.toConnParams['path'].to_s + "'..."
#           log.warn(msg)

#            progressCurrent
              update_progress(100, msg);
#            puts("... hello from jruby")
#            exec('gem list')
            rescue Exception => e
              puts "Exception => e == " + e.inspect.to_s
              puts " ... backtrace == "
              e.backtrace.each do |a_step|
                puts " >> " + a_step.to_s
              end
            end
          end # endScriptHook

      end # LowercaseAllFilenames

    end # Utils
  end # Scripts
end # Scripting