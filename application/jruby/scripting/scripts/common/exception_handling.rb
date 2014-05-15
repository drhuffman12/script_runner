module Scripting
  module Scripts
    module Common
      module ExceptionHandling # Scripting::Scripts::Common::ExceptionHandling

            def generic_exception_handler(e)
                puts "Exception => e == " + e.inspect.to_s
                puts " ... backtrace == "
                e.backtrace.each do |a_step|
                  puts " >> " + a_step.to_s
                end
            end

      end # module Exportable
    end # module Maximo
  end # module Scripts
end # module Scripting