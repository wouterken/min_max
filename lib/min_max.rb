# frozen_string_literal: true

require_relative "min_max/version"
require_relative "min_max/min_max"

class MinMax
  class Error < StandardError; end

  attr_reader :priority_blk, :storage

  def self.[](*args, &blk)
    new(*args, &blk)
  end

  def self.new(*args, &blk)
    self._new.tap{|s|
      s.instance_eval{
        @priority_blk = (blk || proc{|x| x.respond_to?(:priority) ? x.priority : x.to_i })
        @storage = Hash.new{|h,k| h[k] = [0, nil] }
      }
      s.push(*args)
    }
  end

  def push(*args)
    mapped = args.map do |a|
      hash = a.hash
      entry = self.storage[hash]
      entry[0] += 1
      entry[1] ||= a
      [
        (self.priority_blk.call(a) rescue 0),
        hash
      ]
    end
     _push(mapped)
  end

  def add(*args)
    push(*args)
  end

  def pop_max(*args)
    popped = _pop_max(*args)
    popped.kind_of?(Array) ? popped.map{|p| retrieve(p) } : retrieve(popped)
  end

  def pop_min(*args)
    popped = _pop_min(*args)
    popped.kind_of?(Array) ? popped.map{|p| retrieve(p) } : retrieve(popped)
  end

  def peek_min
    retrieve(_peek_min, false)
  end

  def peek_max
    retrieve(_peek_max, false)
  end

  def first
    peek_min
  end

  def last
    peek_max
  end

  def each(*args, &blk)
    if block_given?
      _each(*args) do |p|
        blk[retrieve(p, false)]
      end
    else
      to_enum(:each, *args)
    end
  end

  def to_a
    each.to_a
  end

  def count(val)
    counts.has_key?(val.hash) ? counts[val.hash] : 0
  end

  def contains?(val)
    counts.has_key?(val.hash) && counts[val.hash] > 0
  end

  def to_a_asc
    _to_a_asc.map{|p| retrieve(p, false) }
  end

  def to_a_desc
    _to_a_desc.map{|p| retrieve(p, false) }
  end

  def inspect
    "MinMax[#{each.first(10).map(&:to_s).join(", ")}#{size > 10 ? ", ..." : ""}]"
  end

  private
  def retrieve(hash, remove=true)
    entry = self.storage[hash]
    self.storage.delete(hash) if remove && (entry[0] -= 1) == 0
    entry[1]
  end

end

