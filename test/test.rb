direc = File.dirname(__FILE__)

require 'rubygems'
require "#{direc}/../lib/pry_time"
require 'bacon'

puts "Testing pry_time version #{PryTime::VERSION}..." 
puts "Ruby version: #{RUBY_VERSION}"

describe PryTime do
end

