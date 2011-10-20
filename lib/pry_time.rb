# pry_time.rb
# (C) 2011 John Mair (banisterfiend); MIT license

require "pry_time/version"
require 'binding_of_caller'
require 'pry'

module PryTime
  PryTimeCommands = Pry::CommandSet.new do
    command "up", "Go up to the caller's context" do
      Thread.current[:__pry_exception_bindings__].shift
      current_binding = Thread.current[:__pry_exception_bindings__].first

      output.puts "Can't locate source for eval'd code" if current_binding.eval("__FILE__") == "(eval)"
    end

    command "bt", "Show the full backtrace for the current exception" do
      output.puts Thread.current[:__pry_current_exception__].backtrace
    end
  end
end

class Object
  def raise(*args)
    begin
      Kernel.method(:raise).call(*args)
    rescue Exception => e
    end

    puts "Starting Pry session in context of exception: #{e.class}: #{e.message}"

    Thread.current[:__pry_exception_bindings__] = []
    Thread.current[:__pry_current_exception__]  = e

    i = 1
    loop do
      begin
        Thread.current[:__pry_exception_bindings__] <<  binding.of_caller(i)
      rescue
        break
      end

      i += 1
    end

    Thread.current[:__pry_exception_bindings__].first.pry
  end
end


Pry.commands.import PryTime::PryTimeCommands
