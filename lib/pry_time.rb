# pry_time.rb
# (C) 2011 John Mair (banisterfiend); MIT license

require "pry_time/version"
require 'binding_of_caller'
require "continuation"
require 'pry'
require 'pry_time/object_extensions'
require 'pry_time/session'
require 'pry_time/config'

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
      PryTime.data[:instance].session_type = :top_level
      PryTime.data[:instance].start_session
    end
  end

  def self.data
    Thread.current[:__pry_time_hash__] ||= {}
  end

end

