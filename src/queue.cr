# Based on rubysl-thread ruby gem implementation
# Copyright (c) 2013, Brian Shirai
# Licensed under the BSD 3-clause

require "thread"

class Queue(T)
  class Error < Exception; end

  def initialize
    @que = [] of T
    @mutex = Mutex.new
    @resource = ConditionVariable.new
  end

  def push(item : T)
    @mutex.synchronize do
      @que.push(item)
      @resource.signal
    end
  end

  def pop(should_block = true)
    loop do
      @mutex.synchronize do
        if @que.empty?
          raise Error.new("queue is empty") unless should_block
          @resource.wait(@mutex)
        else
          item = @que.shift
          @resource.signal
          return item
        end
      end
    end
  end

  def clear
    @mutex.synchronize do
      @que.clear
    end
  end

  def empty?
    length == 0
  end

  def length
    @que.length
  end

  def size
    @que.size
  end
end
