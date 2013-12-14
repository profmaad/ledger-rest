module RSpec
  module Deepmatch
    module Methods

      def match?(actual, expected)
        return arrays_match?(actual, expected) if expected.is_a?(Array) && actual.is_a?(Array)
        return hashes_match?(actual, expected) if expected.is_a?(Hash) && actual.is_a?(Hash)
        expected == actual
      end

      def arrays_match?(actual, expected)
        exp = expected.clone
        actual.each do |a|
          index = exp.find_index { |e| match? a, e }
          return false if index.nil?
          exp.delete_at(index)
        end
        exp.length == 0
      end

      def hashes_match?(actual, expected)
        return false unless actual.keys.sort == expected.keys.sort
        actual.each do |key, value|
          return false unless match?(value, expected[key])
        end
        true
      end

      def diff(actual, expected, depth, options = {})
        if actual.is_a?(Hash) && expected.is_a?(Hash)
          diff_hash(actual, expected, depth+1)
        elsif actual.is_a?(Array) && expected.is_a?(Array)
          diff_array(actual, expected, depth+1)
        else
          if actual == expected
            @diff << "#{options[:prefix]}#{actual.inspect}\n"
          else
            if depth > 0
              if options[:missing]
                @diff << "#{options[:prefix_missing]}#{expected.inspect}\n"
              elsif options[:additional]
                @diff << "#{options[:prefix_additional]}#{actual.inspect}\n"
              else
                @diff << "#{options[:prefix_missing]}#{expected.inspect}\n"
                @diff << "#{options[:prefix_additional]}#{actual.inspect}\n"
              end
            else
              @diff << "expected #{actual.inspect} to be equal #{expected.inspect}"
            end
          end
        end
      end

      def diff_array(actual, expected, depth = 1, color = :red)
        intersection = intersection(actual, expected)
        missing      = missing(actual, expected)
        additional   = additional(actual, expected)

        @diff << '  '*(depth-1) + "[\n"

        missing.each do |element|
          @diff << '  '*depth + "missing: #{element.inspect}\n"
        end
        additional.each do |element|
          @diff << '  '*depth + "additional: #{element.inspect}\n"
        end

        @diff << '  '*(depth-1) + "]\n"
      end

      def diff_hash(actual, expected, depth = 1)
        intersecting_keys    = expected.keys & actual.keys
        missing_keys    = expected.keys - actual.keys
        additional_keys = actual.keys   - expected.keys

        @diff << '  '*(depth-1) + "{\n"

        intersecting_keys.each do |key|
          diff(actual[key], expected[key], depth,
               prefix: '  '*depth + "#{key.inspect} => ",
               prefix_missing: '  '*depth + "missing: #{key.inspect} => ",
               prefix_additional: '  '*depth + "additional: #{key.inspect} => ")
        end

        missing_keys.each do |key|
          diff(actual[key], expected[key], depth,
               missing: true,
               prefix_missing: '  '*depth + "missing: #{key.inspect} => ")
        end

        additional_keys.each do |key|
          diff(actual[key], expected[key], depth,
               additional: true,
               prefix_additional: '  '*depth + "additional: #{key.inspect} => ")
        end

        @diff << '  '*(depth-1) + "}\n"
      end

      def intersection(actual, expected)
        exp = expected.clone
        actual.select do |a|
          index = exp.index { |e| match?(a, e) }
          exp.delete_at(index) if index
          index
        end
      end

      def missing(actual, expected)
        exp = expected.clone
        actual.each do |a|
          index = exp.index { |e| match?(a, e) }
          exp.delete_at(index) if index
        end
        exp
      end

      def additional(actual, expected)
        act = actual.clone
        expected.each do |e|
          index = act.index { |a| match?(a, e) }
          act.delete_at(index) if index
        end
        act
      end
    end
  end
end

RSpec::Matchers.define :deep_eq do |expected|
  include RSpec::Deepmatch::Methods

  match do |actual|
    match?(actual, expected)
  end

  failure_message_for_should do |actual|
    @diff = ''
    "expected: #{expected}\ngot: #{actual}\n"
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual} would not equal #{expected}"
  end

  description do
    "be deeply equal #{expected}"
  end
end
