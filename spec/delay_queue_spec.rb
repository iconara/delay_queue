# encoding: utf-8

require_relative 'spec_helper'


class Clock
  attr_accessor :now
end

describe DelayQueue do
  before do
    @clock = Clock.new
    @q = DelayQueue.new(@clock)
  end

  describe '#put' do
    it 'does not replace elements whose timestamp has been updated to an earlier time (by default)' do
      @clock.now = 4
      @q.put('blopp', 5)
      @q.put('blipp', 4)
      @q.put('blupp', 3)
      @q.put('blopp', 1)
      @q.pop.should == 'blupp'
    end
    
    it 'does not replace elements whose timestamp has been updated to an earlier time unless specifically asked to' do
      @clock.now = 4
      @q.put('blopp', 5)
      @q.put('blipp', 4)
      @q.put('blupp', 3)
      @q.put('blopp', 1, :force => true)
      @q.pop.should == 'blopp'
    end
  end
  
  describe '#pop' do
    it 'returns nil if no elements have expired' do
      @clock.now = 1
      @q.put('blipp', 4)
      @q.pop.should be_nil
    end

    it 'returns the oldest expired element' do
      @clock.now = 5
      @q.put('blopp', 4)
      @q.put('blipp', 3)
      @q.pop.should == 'blipp'
    end
    
    it 'removes elements' do
      @clock.now = 5
      @q.put('blopp', 4)
      @q.pop
      @q.pop.should be_nil
    end

    it 'returns as many expired elements as you want, in age order' do
      @clock.now = 5
      @q.put('blopp', 5)
      @q.put('blipp', 4)
      @q.put('blupp', 3)
      @q.pop(2).should == %w(blupp blipp)
    end

    it 'returns only as many elements as are available' do
      @clock.now = 4
      @q.put('blopp', 5)
      @q.put('blipp', 4)
      @q.put('blupp', 3)
      @q.pop(10).should == %w(blupp blipp)
    end

    it 'does not return elements whose timestamp has been updated to a later time' do
      @clock.now = 4
      @q.put('blopp', 5)
      @q.put('blipp', 4)
      @q.put('blupp', 3)
      @q.put('blipp', 10)
      @q.pop(2).should == %w(blupp)
    end
  end
  
  describe '#pop_all' do
    it 'returns all expired elements' do
      @clock.now = 3
      @q.put('blopp', 1)
      @q.put('blipp', 2)
      @q.put('blupp', 3)
      @q.put('blepp', 4)
      @q.pop_all.should == %w(blopp blipp blupp)
    end
    
    it 'removes elements' do
      @clock.now = 3
      @q.put('blopp', 1)
      @q.put('blipp', 2)
      @q.put('blupp', 3)
      @q.put('blepp', 4)
      @q.pop_all.should == %w(blopp blipp blupp)
      @q.pop_all.should == []
      @clock.now = 4
      @q.pop_all.should == ['blepp']
      @q.pop_all.should == []
    end
  end
  
  describe '#include?' do
    it 'returns true if the element is in the queue' do
      @q.put('x', 3)
      @q.should include('x')
    end

    it 'returns false if the element is not in the queue' do
      @q.should_not include('x')
    end
  end

  describe '#each' do
    before do
      @q.put('blopp', 5)
      @q.put('blipp', 4)
      @q.put('blupp', 3)
      @q.put('blipp', 10)
    end

    it 'yields each session_id and timestamp in timestamp order' do
      yielded_elements = []
      @q.each { |*pair| yielded_elements << pair }
      yielded_elements.should == [['blupp', 3], ['blopp', 5], ['blipp', 10]]
    end

    it 'returns an enumerator when called without a block' do
      @q.each.should be_a(Enumerator)
    end
  end

  context 'as an Enumerable' do
    it 'can be mapped over' do
      @q.put('blopp', 5)
      @q.put('blipp', 4)
      @q.put('blupp', 3)
      @q.put('blipp', 10)
      @q.map { |e, ts| e }.should == %w[blupp blopp blipp]
    end
  end
end