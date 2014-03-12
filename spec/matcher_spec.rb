require 'rspec'
require 'rspec-deep-ignore-order-matcher'

describe Deep::Ignore::Order::Matcher do

	it 'should matches usual values' do
		['an_string', 1, 13.5, nil, [1, 2, 3], { a: 1, b: 2 }].each_slice(2) do |value1, value2|
			value1.should deep_eq value1
			value2.should deep_eq value2
			value1.should_not deep_eq value2
			# value2.should_not deep_eq value1
			value2.should_not deep_eq value1
		end
	end

	it 'should ignore order in plain arrays' do
		actual = Array.new(5) { Random.rand(1000) }
		expected = actual.sort
		actual.should deep_eq expected
	end

	it 'should match deep structs' do
		actual = [{ a: 1, b: 'str', c: [1, 2, 3] }, [{ a: [2, { a: 4 }] }, { b: 2 }, { c: 3 }]]
		expected = [{ a: 1, b: 'str', c: [3, 1, 2] }, [{ b: 2 }, { a: [{ a: 4 }, 2] }, { c: 3 }]]
		actual.should deep_eq expected
		actual[0][:c].push(4)
		actual.should_not deep_eq expected
	end

	it 'should do not match partials' do
		[1, 2, 3].should_not deep_eq [1, 2]
		[1, 2].should_not deep_eq [1, 2, 3]
		{ a: 1, b: 2 }.should_not deep_eq({ a: 1 })
		{ a: 1 }.should_not deep_eq({ a: 1, b: 2 })
	end

	it 'should ignore hash keys order' do
		{ a: 1, b: 2 }.should deep_eq({ b: 2, a: 1 })
	end
end