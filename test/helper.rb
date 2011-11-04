unless Object.const_defined? :PryTime
  $:.unshift File.expand_path '../../lib', __FILE__
end

require 'pry_time'

Pry.color = false
Pry.pager = false
Pry.config.should_load_rc      = false
Pry.config.plugins.enabled     = false
Pry.config.history.should_load = false
Pry.config.history.should_save = false
Pry.config.auto_indent         = false


def mock_pry(input)
  old_input, old_output = Pry.config.input, Pry.config.output

  Pry.config.input = StringIO.new(input)
  Pry.config.output = StringIO.new
  begin
    yield
  ensure
    output = Pry.config.output.string
    Pry.config.input, Pry.config.output = old_input, old_output
  end
  output
end

