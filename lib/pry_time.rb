# pry_time.rb
# (C) 2011 John Mair (banisterfiend); MIT license

require "pry_time/version"
require 'binding_of_caller'
require "continuation"
require 'pry'

module PryTime
  def self.wrap
    begin
      yield
    rescue Exception => e
      PryTime.data[:binding_index]               = 0
      PryTime.data[:__pry_current_exception__]   = e

      index = PryTime.data[:binding_index]
      prompt = Pry::DEFAULT_PROMPT.map do |p|
        proc { |*args| "<Frame: #{PryTime.data[:binding_index]}> #{p.call(*args)}" }
      end

      instance = PryTime.data[:__pry_instance__] = Pry.new(:prompt => prompt)

      instance.repl(PryTime.data[:__pry_exception_bindings__].first)
    end
  end
end

module PryTime
  def self.data
    Thread.current[:__pry_time_hash__] ||= {}
  end

  PryTimeCommands = Pry::CommandSet.new do
    command "up", "Go up to the caller's context" do |inc_str|
      inc = inc_str.nil? ? 1 : inc_str.to_i

      PryTime.data[:binding_index] += inc
      current_binding = PryTime.data[:__pry_exception_bindings__][PryTime.data[:binding_index]]

      if current_binding
        output.puts "Can't locate source for eval'd code" if current_binding.eval("__FILE__") == "(eval)"

        PryTime.data[:__pry_instance__].binding_stack[-1] = current_binding
        PryTime.data[:__pry_instance__].run_command "whereami"
      else
        output.puts "Reached end of stacktrace, go back down the stack by typing down"
      end
    end

    command "down", "Go down to the callee's context" do |inc_str|
      inc = inc_str.nil? ? 1 : inc_str.to_i

      PryTime.data[:binding_index] -= inc
      current_binding = PryTime.data[:__pry_exception_bindings__][PryTime.data[:binding_index]]

      if current_binding
        output.puts "Can't locate source for eval'd code" if current_binding.eval("__FILE__") == "(eval)"

        PryTime.data[:__pry_instance__].binding_stack[-1] = current_binding
        PryTime.data[:__pry_instance__].run_command "whereami"
      else
        output.puts "belzebub"
      end
    end

    command "bt", "Show the full backtrace for the current exception" do
      output.puts "Current exception: #{PryTime.data[:__pry_current_exception__]}"
      output.puts "\n"
      output.puts PryTime.data[:__pry_current_exception__].backtrace
    end

    command "continue", "Continue the program." do
      PryTime.data[:__pry_current_exception__].continue
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
    PryTime.data[:__pry_exception_bindings__] = []

    i = 2
    loop do
      begin
        PryTime.data[:__pry_exception_bindings__] <<  binding.of_caller(i)
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
      super(obj)
    end
  end
end

Pry.commands.import PryTime::PryTimeCommands
