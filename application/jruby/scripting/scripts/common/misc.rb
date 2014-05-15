module Scripting
  module Scripts
    module Common
      module Misc # Scripting::Scripts::Common::Misc
        
      # Usage examples, where params within the double array are all integers:
      #   * Loop A, with a1 of a2 steps:
      #       recalc_progress_by_counters()[[a1,a2]])
      #   * Sub-loop B, with b1 of b2 steps:
      #       recalc_progress_by_counters()[[a1,a2],[b1,b2]])
      #   * Sub-loop C, with c1 of c2 steps:
      #       recalc_progress_by_counters()[[a1,a2],[b1,b2],[c1,c2]])

      def count_sets_to_s(count_sets)
        ret_val = '['
        count_sets.each do |level_set|
          level_set_current = level_set[0]
          level_set_all = level_set[1]
          ret_val << '['
          ret_val << level_set_current.to_s
          ret_val << ','
          ret_val << level_set_all.to_s
          ret_val << ']'
        end
        ret_val << ']'
      end

      def recalc_progress_by_counters(count_sets)
        begin
          @progressCurrent = 0
          numerator = 0.0
          denominator = 1.0
          ratios = []
          count_sets_qty = count_sets.count
          prev_denominator = 1.0
          count_sets.each do |count_set|
            numerator = count_set[0]
            denominator = count_set[1] * prev_denominator
            prev_denominator = denominator
            ratios << numerator / denominator
          end

          ratio_sum = 0.0
          ratios.each do |r|
            ratio_sum += r
          end
          @progressCurrent = (100.0 * ratio_sum).to_i
        rescue
          #
        end
      end

      def has_exactly_one_regexp_match(regexp,str)
        ret_val = false
        matches = regexp.match(str)
        unless (matches.nil?)
          matches = matches.to_a
          if (matches.count == 1)
            unless (matches.first.nil?)
              if (matches.first.length == str.length)
                ret_val = true
              end
            end
          end
        end
        ret_val
      end

      class String
        def underscore
          self.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          downcase
        end
      end
        
      end # module Misc
    end # module Maximo
  end # module Scripts
end # module Scripting