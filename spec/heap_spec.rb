require 'rspec'
require_relative '../lib/min_max.rb'


describe 'Thread Safety' do
  it 'maintains consistency with concurrent pushes and pops' do
    heap = MinMax.new
    threads = []

    1000.times do |i|
      threads << Thread.new { heap.push(rand(1000)) }
      threads << Thread.new { heap.pop_max if i % 2 == 0 } # Example, adjust as needed
    end

    threads.each(&:join)

    expect(heap.size).to be <= 1000
  end
end

describe 'Heap Property' do
  context 'MinMax' do
    it 'returns items in ascending order' do
      heap = MinMax.new
      [7, 3, 5, 1, 2, 8, 6, 4].each { |num| heap.push(num) }

      result = []
      8.times { result << heap.pop_min }
      expect(result).to eq(result.sort)
    end
  end

  context 'MaxHeap' do
    it 'returns items in descending order' do
      heap = MinMax.new
      [7, 3, 5, 1, 2, 8, 6, 4].each { |num| heap.push(num) }

      result = []
      8.times { result << heap.pop_max }
      expect(result).to eq(result.sort.reverse)
    end
  end
end

describe 'Large Scale Handling' do
  it 'can handle a large number of elements' do
    heap = MinMax.new
    heap.push(*10_000.times.map{ rand(100_000) })

    last_pop = heap.pop_min
    (10_000 - 1).times do
      current_pop = heap.pop_min
      expect(last_pop).to be <= current_pop
      last_pop = current_pop
    end
  end
end

describe 'Custom Object Handling' do
  it 'orders custom objects with a block' do
    class CustomObj
      attr_reader :priority
      def initialize(priority)
        @priority = priority
      end
    end

    heap = MinMax.new { |obj| obj.priority }
    heap.push(CustomObj.new(5), CustomObj.new(1), CustomObj.new(3))

    expect(heap.pop_min.priority).to eq(1)
    expect(heap.pop_min.priority).to eq(3)
    expect(heap.pop_min.priority).to eq(5)
  end
end


describe 'Comparison Modes' do
  context 'Default Ruby Ordering' do
    it 'orders using <=> by default' do
      heap = MinMax[3, 1, 2]
      expect(heap.pop_min).to eq(1)
      expect(heap.pop_min).to eq(2)
      expect(heap.pop_min).to eq(3)
    end
  end

  context 'Priority Integer Block' do
    it 'orders using the provided block' do
      heap = MinMax.new { |item| -item } # Inverting priorities for demonstration
      heap.push(3, 1, 2)
      expect(heap.pop_min).to eq(3) # With inverted priorities, 3 comes first
      expect(heap.pop_min).to eq(2)
      expect(heap.pop_min).to eq(1)
    end
  end
end

describe 'Empty Heap Behavior' do
  it 'returns nil on pop with no elements' do
    heap = MinMax.new
    expect(heap.pop_min).to be_nil
  end

  it 'handles multiple pops on empty heap gracefully' do
    heap = MinMax.new
    expect(heap.pop_min).to be_nil
    expect(heap.pop_min(2)).to eq([]) # Assuming pop(2) on empty heap returns empty array
    expect { heap.pop_min }.not_to raise_error
  end
end