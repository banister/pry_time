# pry_time.rb
# (C) 2011 John Mair (banisterfiend); MIT license

require "pry_time/version"
require 'binding_of_caller'
require "continuation"
require 'pry'
require 'pry_time/object_extensions'
require 'pry_time/config'
require 'pry_time/commands'

module PryTime
  class << self
    attr_accessor :config
  end

  self.config = Config.new

  def self.capture(&block)
    yield config
  end

  def self.pry_config
    {
      :prompt => Pry::DEFAULT_PROMPT.map do |p|
        proc { |*args| "<Frame: #{PryTime.data[:binding_index]}> #{p.call(*args)}" }
      end
    }
  end

  def self.start_session
    PryTime.data[:binding_index]       = 0
    instance = PryTime.data[:instance] = Pry.new(pry_config)

    instance.repl(PryTime.data[:exception_bindings].first)
  end

  def self.wrap
    begin
      yield
    rescue Exception => e
      PryTime.data[:binding_index]     = 0
      PryTime.data[:current_exception] = e

      start_session
    end
  end

  def self.data
    Thread.current[:__pry_time_hash__] ||= {}
  end

  def self.get_caller_bindings
    PryTime.data[:exception_bindings] = []
    i = 4
    loop do
      begin
        PryTime.data[:exception_bindings] <<  yield(i)
      rescue
        break
      end
      i += 1
    end
  end

end

Pry.commands.import PryTime::PryTimeCommands
