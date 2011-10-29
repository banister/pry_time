class Exception
  NoContinuation = Class.new(StandardError)

  attr_accessor :continuation

  def continue
    raise NoContinuation unless continuation.respond_to?(:call)
    continuation.call
  end
end

class Object
  def raise(exception = RuntimeError, string = nil, array = caller)
    if exception.is_a?(String)
      string = exception
      exception = RuntimeError
    end

    ex = exception.exception(string)
    ex.set_backtrace(array)

    exception_bindings = PryTime.get_caller_bindings { |i| binding.of_caller(i) }
    session            = PryTime.data[:instance] = PryTime::Session.new(caller, exception_bindings, PryTime.config)

    # session.start_session if session.should_capture_exception?
    # if PryTime.should_capture_exception?

    # end


    callcc do |cc|
      ex.continuation = cc
      super(ex)
    end
  end
end
