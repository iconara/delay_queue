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

    it 'returns elements whose timestamp has been updated to an earlier time' do
      @clock.now = 4
      @q.put('blopp', 5)
      @q.put('blipp', 4)
      @q.put('blupp', 3)
      @q.put('blopp', 1)
      @q.pop.should == 'blopp'
    end
  end
end