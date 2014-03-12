require 'rspec'
require 'rspec-deep-ignore-order-matcher/version'

module RSpec::Matchers::DeepEq
	class DeepEq
		attr_accessor :actual, :expected, :bad_attrs

		def initialize(expected)
		  @expected = expected
			@bad_attrs = []
		end

	  def failure_message
	  	generic_failure_message
	  end

	  def negative_failure_message
	  	generic_failure_message " not "
	  end

	  def description
			"be deep equal with #{expected}"
	  end

	  def diffable?
	    true
	  end

		def matches?(actual)
			self.actual = actual
			m? actual, expected, "actual"
	  end

	  private

	  def generic_failure_message(_not=" ")
			unless is_array? or is_hash?
				return "expected that #{actual} would#{_not}be deep equal with "+
				"#{expected}"
			end
			# Adding diff information for hashes and arrays
			self.bad_attrs.inject("") do |msg, bad_attr|
				msg+
				"\n#{bad_attr[:path]} was #{bad_attr[:actual].inspect}"+
				", expected #{bad_attr[:expected].inspect}"
			end
		end

		def is_array?
			expected.is_a?(Array) && actual.is_a?(Array)
		end

		def is_hash?
			expected.is_a?(Hash) && actual.is_a?(Hash)
		end

		def m?(actual, expected, path)
			return arrays_matches?(actual, expected, path) if expected.is_a?(Array) && actual.is_a?(Array)
			return hashes_matches?(actual, expected, path) if expected.is_a?(Hash) && actual.is_a?(Hash)
			return true if expected == actual
			add_bad_attr(actual, expected, path) if path.nil? == false
			return false
		end

		def add_bad_attr(actual, expected, path)
			bad_attrs.push(
				path: path,
				actual: actual,
				expected: expected
			)
		end

		def arrays_matches?(actual, expected, path)
			exp = expected.clone
			actual.each_with_index do |a, i|
				index = exp.find_index { |e| m? a, e, nil }
				return false if index.nil?
				add_bad_attr(a, nil, "#{path}[#{i}]") if path.nil? == false
				exp.delete_at(index)
			end
			exp.each do |e|
				i = expected.index(e)
				add_bad_attr(nil, e, "#{path}[#{i}]") if path.nil? == false
			end
			exp.length == 0
		end

		def hashes_matches?(actual, expected, path)
			valid = true
			actual.each do |key, value|
				if actual.include? key
					valid &&= m? value, expected[key], "#{path}[#{key.inspect}]"
				else
					valid = false
					add_bad_attr(nil, value, "#{path}[#{key.inspect}]")
				end
			end
			if actual.keys.sort != expected.keys.sort
				valid = false
				expected.each do |key, value|
					unless actual.include? key
						add_bad_attr(value, nil, "#{path}[#{key.inspect}]")
					end
				end
			end
			return valid
		end

	end

	def deep_eq(expected)
		DeepEq.new(expected)
	end

	alias be_deep_eq deep_eq
end

RSpec::configure do |config|
  config.include(RSpec::Matchers::DeepEq)
end

