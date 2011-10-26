require 'helper'

puts "Testing pry_time version #{PryTime::VERSION}..."
puts "Ruby version: #{RUBY_VERSION}"

describe PryTime do

  it 'should catch unrescued exception and code surrounding raise invocation should be displayed' do

    mock_pry("exit 5\n") do
      PryTime.wrap do
        raise "hi"
      end
    end.should =~ /raise "hi"/
  end

end

