require "bundler/setup"
require "min_max"

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'rb_heap'
  gem 'algorithms'
  gem 'ruby-heap'
  gem 'pqueue'
end

require 'benchmark'
require 'rb_heap'
require 'min_max'


data = 100_000.times.map{ Random.rand(0...1000_000_000) }
rb_hp = Heap.new(:<)
mm_hp = MinMax[]

Benchmark.bm do |x|
  x.report("push_rb_heap"){ data.each{|d| rb_hp.add(d) } }
  x.report("push_mm_heap"){ data.each{|d| mm_hp.push(d) } }
  x.report("push_mm_heap_batches"){ mm_hp = MinMax[]; data.each_slice(1000){|d| mm_hp.push(*d) } }
end

Benchmark.bm do |x|
  x.report("pop_rb_heap"){ 100_000.times{|d| rb_hp.pop } }
  x.report("pop_mm_heap"){ 100_000.times{|d| mm_hp.pop_min } }
  x.report("pop_mm_heap_batches"){ 1000.times{|d| mm_hp.pop_min(100) } }
end

Object.send(:remove_const, :Heap)

require 'Heap'
puts "# ruby-heap vs min_max"
ruby_hp = Heap::BinaryHeap::MinHeap.new
mm_hp = MinMax[]

Benchmark.bm do |x|
  x.report("push_ruby_heap"){ data.each{|d| ruby_hp.add(d) } }
  x.report("push_mm_heap"){ data.each{|d| mm_hp.push(d) } }
  x.report("push_mm_heap_batches"){ mm_hp = MinMax[]; data.each_slice(1000){|d| mm_hp.push(*d) } }
end

Benchmark.bm do |x|
  x.report("pop_ruby_heap"){ 100_000.times{|d| ruby_hp.extract_min! } }
  x.report("pop_mm_heap"){ 100_000.times{|d| mm_hp.pop_min } }
  x.report("pop_mm_heap_batches"){ 1000.times{|d| mm_hp.pop_min(100) } }
end


require 'algorithms'
minheap = Containers::MinHeap.new()
mm_hp = MinMax[]

Benchmark.bm do |x|
  x.report("push_algos_heap"){ data.each{|d| minheap.push(d) } }
  x.report("push_mm_heap"){ data.each{|d| mm_hp.push(d) } }
  x.report("push_mm_heap_batches"){ mm_hp = MinMax[]; data.each_slice(1000){|d| mm_hp.push(*d) } }
end

Benchmark.bm do |x|
  x.report("pop_algos_heap"){ 100_000.times{|d| minheap.pop } }
  x.report("pop_mm_heap"){ 100_000.times{|d| mm_hp.pop_min } }
  x.report("pop_mm_heap_batches"){ 1000.times{|d| mm_hp.pop_min(100) } }
end

require 'pqueue'
pqueue = PQueue.new()
mm_hp = MinMax[]

Benchmark.bm do |x|
  x.report("push_pqueue_heap"){ data.each{|d| pqueue.push(d) } }
  x.report("push_mm_heap"){ data.each{|d| mm_hp.push(d) } }
  x.report("push_mm_heap_batches"){ mm_hp = MinMax[]; data.each_slice(1000){|d| mm_hp.push(*d) } }
end

Benchmark.bm do |x|
  x.report("pop_pqueue_heap"){ 100_000.times{|d| pqueue.pop } }
  x.report("pop_mm_heap"){ 100_000.times{|d| mm_hp.pop_min } }
  x.report("pop_mm_heap_batches"){ 1000.times{|d| mm_hp.pop_min(100) } }
end