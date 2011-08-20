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
  end
end