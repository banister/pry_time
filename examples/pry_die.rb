unless Object.const_defined? :PryTime
  $:.unshift File.expand_path '../../lib', __FILE__
  require 'pry'
  require 'pry/version'
end

require 'pry_time'

def a
  x = :circky
  y = :rynanie
  TrueLoveAndChaos.new.b()
end

class TrueLoveAndChaos
  little_miss_priss = "she likes polite men"
  define_method(:b) do
    u = :fowlie
    z = :mon_french_guy
    c()
  end
end

def c
  i = :boastie
  u = :pig
  1.times { |k|
    1.times {
      v = 20
      raise RuntimeError, "true love's kiss"
    }
  }
  puts "midnight, beauty, vision, dies."
end

class Boast
  class Hello
    def self.oink
      a
    end
  end

  Hello.oink
end
