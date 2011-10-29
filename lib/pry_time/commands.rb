PryTime::PryTimeCommands = Pry::CommandSet.new do

  command "up", "Go up to the caller's context" do |inc_str|
    inc = inc_str.nil? ? 1 : inc_str.to_i

    PryTime.data[:instance].binding_index += inc
    _pry_.run_command "whereami"
  end

  command "down", "Go down to the callee's context" do |inc_str|
    inc = inc_str.nil? ? 1 : inc_str.to_i

    PryTime.data[:instance].binding_index -= inc
    _pry_.run_command "whereami"
  end

  command "bt", "Show the full backtrace for the current exception" do
    output.puts PryTime.data[:instance].backtrace
  end

  command "continue", "Continue the program." do
    PryTime.data[:current_exception].continue
  end

  helpers do
    def update_current_binding(current_binding)
      if current_binding
        output.puts "Can't locate source for eval'd code" if current_binding.eval("__FILE__") == "(eval)"

        PryTime.data[:instance].binding_stack[-1] = current_binding
        PryTime.data[:instance].run_command "whereami"
      else
        output.puts "Reached end of stacktrace, go back down the stack by typing down"
      end
    end
  end
end
