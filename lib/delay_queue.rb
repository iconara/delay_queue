# encoding: utf-8

require 'set'


class DelayQueue
  def initialize(clock=Time)
    @clock = clock
    @elements = {}
    @timestamps = SortedSet.new
    @reverse_elements = Hash.new { |h, k| h[k] = Set.new }
  end
  
  def put(element, timestamp=Time.now.to_i)
    if @elements[element]
      remove(element)
    end
    @elements[element] = timestamp
    @reverse_elements[timestamp] << element
    @timestamps << timestamp
  end
  
  def remove(element)
    timestamp = @elements.delete(element)
    @reverse_elements[timestamp].delete(element)
    if @reverse_elements[timestamp].empty?
      @reverse_elements.delete(timestamp)
      @timestamps.delete(timestamp)
    end
  end
  
  def pop(n=1)
    now = @clock.now.to_i
    expired_timestamps = @timestamps.take_while { |ts| ts <= now }
    expired_elements = expired_timestamps.flat_map { |ts| @reverse_elements[ts].to_a }
    elements = expired_elements.take(n).tap { |e| remove(e) }
    if n == 1
      elements.first
    else
      elements
    end
  end
end