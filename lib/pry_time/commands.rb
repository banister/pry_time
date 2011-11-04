PryTime::PryTimeCommands = Pry::CommandSet.new do

  command "up", "Go up to the caller's context" do |inc_str|
    inc = inc_str.nil? ? 1 : inc_str.to_i

    PryTime.data[:instance].binding_index += inc
  end

  command "down", "Go down to the callee's context" do |inc_str|
    inc = inc_str.nil? ? 1 : inc_str.to_i

    PryTime.data[:instance].binding_index -= inc
  end

  command "frame", "Switch to a particular frame" do |frame_num|
    PryTime.data[:instance].binding_index = frame_num.to_i
  end

  command "frame-type", "Display current frame type." do
    bindex = PryTime.data[:instance].binding_index
    output.puts PryTime.data[:instance].exception_bindings[bindex].frame_type
  end

  command "bt", "Show the full backtrace for the current exception" do
    output.puts PryTime.data[:instance].current_exception.backtrace
  end

  command "continue", "Continue the program." do
    case PryTime.data[:instance].session_type
    when :raise
      _pry_.run_command "exit-all :__continue__"
    else
      PryTime.data[:instance].current_exception.continue
    end
  end
end
