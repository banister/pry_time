# pry_time.rb
# (C) 2011 John Mair (banisterfiend); MIT license

require "pry_time/version"
require 'binding_of_caller'
require 'pry'

module PryTime
  def self.wrap
    begin
      yield
    rescue Exception => e
      Thread.current[:__pry_current_exception__] = e
      Thread.current[:__pry_exception_bindings__].first.pry
    end
  end
end

module PryTime
  PryTimeCommands = Pry::CommandSet.new do
    command "up", "Go up to the caller's context" do
      Thread.current[:__pry_exception_bindings__].shift
      current_binding = Thread.current[:__pry_exception_bindings__].first

      if current_binding
        output.puts "Can't locate source for eval'd code" if current_binding.eval("__FILE__") == "(eval)"
        current_binding.pry
      else
        output.puts "Reached end of stacktrace, go back down the stack by pressing ^D"
      end
    end

    command "bt", "Show the full backtrace for the current exception" do
      output.puts Thread.current[:__pry_current_exception__].backtrace
    end

    command "continue", "Continue the program." do
      Thread.current[:__pry_current_exception__].continue
    end
  end
end

class Exception
  NoContinuation = Class.new(StandardError)

  attr_accessor :continuation

  def continue
    raise NoContinuation unless continuation.respond_to?(:call)
    continuation.call
  end
end


class Object
  def raise(exception = RuntimeError, string = nil, array = caller)
    Thread.current[:__pry_exception_bindings__] = []

    i = 2
    loop do
      begin
        Thread.current[:__pry_exception_bindings__] <<  binding.of_caller(i)
      rescue
        break
      end

      i += 1
    end

    if exception.is_a?(String)
      string = exception
      exception = RuntimeError
    end

    callcc do |cc|
      obj = exception.exception(string)
      obj.set_backtrace(array)
      obj.continuation = cc
      super obj
    end
  end
end

Pry.commands.import PryTime::PryTimeCommands
