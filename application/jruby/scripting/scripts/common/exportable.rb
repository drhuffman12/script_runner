module Scripting
  module Scripts
    module Common
      module Exportable # Scripting::Scripts::Common::Exportable

        def script_path(root_path, script_file_name, include_date = true, include_time = true)
          # In case a file is passed in instead of a folder:
          dest_folder_path = ""
          if (File.directory?(root_path))
            dest_folder_path << root_path
          else
            dest_folder_path << File.dirname(root_path)
          end

#              # Include the timestamp in the folder path:
#              t_folder = Time.now.strftime("%Y-%m-%d_%Z_%I-%M%p")
#              dest_folder_path << "/" + t_folder
#              FileUtils.mkdir(dest_folder_path) unless (File.directory?(dest_folder_path))
#              # update_progress(@progress_val, " ... Entered folder: '" + dest_folder_path + "' ...")
          if (include_date)
            # Include the datestamp in the folder path:
            t_folder = Time.now.strftime("%Y-%m-%d")
            dest_folder_path << "/" + t_folder
            FileUtils.mkdir(dest_folder_path) unless (File.directory?(dest_folder_path))
            # update_progress(@progress_val, " ... Entered folder: '" + dest_folder_path + "' ...")
          end

          if (include_time)
            # Include the timestamp in the folder path:
            t_folder = Time.now.strftime("%Z_%H-%M")
            dest_folder_path << "/" + t_folder
            FileUtils.mkdir(dest_folder_path) unless (File.directory?(dest_folder_path))
            # update_progress(@progress_val, " ... Entered folder: '" + dest_folder_path + "' ...")
          end

          dest_folder_path << "/" + script_file_name unless script_file_name.nil?
        end

      end # module Exportable
    end # module Maximo
  end # module Scripts
end # module Scripting