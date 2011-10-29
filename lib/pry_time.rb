# pry_time.rb
# (C) 2011 John Mair (banisterfiend); MIT license

require "pry_time/version"
require 'binding_of_caller'
require "continuation"
require 'pry'
require 'pry_time/object_extensions'
require 'pry_time/session'
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

  def self.wrap
    begin
      yield
    rescue Exception => e
      PryTime.data[:instance].start_session
    end
  end

  def self.data
    Thread.current[:__pry_time_hash__] ||= {}
  end

  def self.get_caller_bindings
    exception_bindings = []

    i = 4
    loop do
      begin
        exception_bindings <<  yield(i)
      rescue
        break
      end
      i += 1
    end

    exception_bindings
  end

end

Pry.commands.import PryTime::PryTimeCommands
