# MinMax Heap

The MinMax Heap gem provides a high-performance minmax heap implementation for Ruby, written in Rust. 
The gem wraps the excellent [min-max-heap-rs](https://github.com/tov/min-max-heap-rs) Rust library.
It allows for the creation of a min-max-heap and supporting operations like pushing and popping multiple items, iterating over heap items, and converting heaps to arrays. 

## Features

- MinMax heap implementation.
- Sorts according to #priority or #to_i by default. Can be overridden using a custom priority block.
- Efficient push and pop operations for single or multiple items.
- Iteration support with `#each`.
- Convert heap to array with `#to_a`, `#to_a_asc` and `#to_a_desc`.

## Prequisites
- You must have a working Rust compiler installed on your system. 
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | 
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'min_max'
```


And then execute:

```bash
bundle install
```

Or install it yourself as:
```bash
gem install min_max

# or manually specify target . E.g.

CARGO_BUILD_TARGET=x86_64-apple-darwin gem install min_max
```

## Usage

Instantiate a heap
```ruby
heap = MinMax.new
# Alternate syntax
heap = MinMax[6,3,2,6]

# Custom priority block
heap = MinMax.new{|x| -x }
heap = MinMax[1,4,5,-43]{|x| -x }

```

### Adding items
```ruby
heap.push(5, 3, 7, 1)
```

### Popping items
```ruby
heap.pop_max    # => 7
heap.pop_min(3) # => [1, 3, 5]
```

## Iterating over heap items
```ruby
heap.each.with_index { |item, i| puts "#{i}: #{item}" }
```

## To array
```ruby
heap.to_a_asc  # => [1, 3, 5]
heap.to_a_desc # => [5, 3, 1]
heap.to_a # => Heap order
```

## Peek at min and max items
```ruby
heap.peek_min # => 1
heap.first # => 1

heap.peek_max # => 1
heap.last # => 1
```

## Size
```ruby
heap.size # => 4
heap.length # Alias for size
```

## Clear
```ruby
heap.clear
```

## Count number of times an item is in the heap
```ruby
heap.count(item)
```

## Check if item is contained in the heap
```ruby
heap.contains?(item)
```

## Performance
You can run the `benchmarks/benchmarks.rb` file inside this repository for comparison to other popular heap libraries:
* [rb_heap](https://github.com/florian/rb_heap)
* [algorithms](https://github.com/kanwei/algorithms)
* [ruby-heap](https://github.com/general-CbIC/ruby-heap)
* [pqueue](https://github.com/rubyworks/pqueue)

min-max should be the fastest to pop from a large heap, often by a significant margin, while also offering both min and max operations from a single heap.
Some options are faster at pushing individual items, but the difference is within the same order of magnitude.
Batch pushing to min-max also significantly increases insert speed.

