# encoding: utf-8

if RUBY_PLATFORM == 'java'
  require 'java'

  class DelayQueue
    include Enumerable

    java_import 'java.util.TreeMap'
    java_import 'java.util.HashSet'

    def initialize(clock=Time)
      @clock = clock
      @timestamp_to_elements = TreeMap.new
      @element_to_timestamp = {}
    end

    def put(element, timestamp=Time.now.to_i, options={})
      existing_timestamp = @element_to_timestamp[element]
      if !existing_timestamp || existing_timestamp < timestamp || options[:force]
        remove(element) if existing_timestamp
        elements = @timestamp_to_elements.get(timestamp)
        elements ||= HashSet.new
        elements.add(element)
        @timestamp_to_elements.put(timestamp, elements)
        @element_to_timestamp[element] = timestamp
      end
    end
    
    def remove(element)
      timestamp = @element_to_timestamp.delete(element)
      if timestamp
        elements = @timestamp_to_elements.get(timestamp)
        elements.remove(element)
        @timestamp_to_elements.remove(timestamp) if elements.empty?
      end
    end
    
    def pop(n=1)
      popped_elements = []
      loop do
        entry = @timestamp_to_elements.first_entry
        break unless entry
        break if entry.key > @clock.now.to_i
        elements = entry.value
        iterator = elements.iterator
        while iterator.has_next && popped_elements.size < n
          element = iterator.next
          @element_to_timestamp.delete(element)
          iterator.remove
          popped_elements << element
        end
        break unless elements.empty?
        @timestamp_to_elements.delete(entry.key)
      end
      if n == 1
        popped_elements.first
      else
        popped_elements
      end
    end
    
    def pop_all
      popped_elements = []
      cutoff = @timestamp_to_elements.floor_key(@clock.now.to_i)
      if cutoff
        loop do
          entry = @timestamp_to_elements.poll_first_entry
          elements = entry.value
          elements.each do |element|
            @element_to_timestamp.delete(element)
            popped_elements << element
          end
          break if entry.key == cutoff 
        end
      end
      popped_elements
    end

    def each
      return to_enum unless block_given?
      @timestamp_to_elements.each do |ts, elements|
        elements.each do |element|
          yield element, ts
        end
      end
    end

    def include?(element)
      @element_to_timestamp.key?(element)
    end
    
    def to_h
      @element_to_timestamp.dup
    end

    def size
      @element_to_timestamp.size
    end
  end
else
  require 'set'

  class DelayQueue
    include Enumerable

    def initialize(clock=Time)
      @clock = clock
      @elements = {}
      @timestamps = SortedSet.new
      @reverse_elements = Hash.new { |h, k| h[k] = Set.new }
    end
    
    def put(element, timestamp=Time.now.to_i, options={})
      if @elements[element]
        return unless options[:force] || timestamp > @elements[element]
        remove(element)
      end
      @elements[element] = timestamp
      @reverse_elements[timestamp] << element
      @timestamps << timestamp
    end
    
    def remove(element)
      timestamp = @elements.delete(element)
      return unless timestamp
      @reverse_elements[timestamp].delete(element)
      if @reverse_elements[timestamp].empty?
        @reverse_elements.delete(timestamp)
        @timestamps.delete(timestamp)
      end
    end
    
    def pop(n=1)
      elements = peek_all.take(n)
      elements.each { |e| remove(e) }
      if n == 1
        elements.first
      else
        elements
      end
    end
    
    def pop_all
      elements = peek_all
      elements.each { |e| remove(e) }
      elements
    end

    def each
      return to_enum unless block_given?
      @timestamps.each do |ts|
        @reverse_elements[ts].each do |element|
          yield element, ts
        end
      end
    end

    def include?(element)
      @elements.key?(element)
    end
    
    def to_h
      @elements.dup
    end

    def size
      @elements.size
    end

  private
    
    def peek_all
      now = @clock.now.to_i
      expired_timestamps = @timestamps.take_while { |ts| ts <= now }
      expired_timestamps.flat_map { |ts| @reverse_elements[ts].to_a }
    end
  end
end