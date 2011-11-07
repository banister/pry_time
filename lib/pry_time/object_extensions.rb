class Exception
  NoContinuation = Class.new(StandardError)

  attr_accessor :continuation
  attr_accessor :exception_bindings

  def continue
    raise NoContinuation unless continuation.respond_to?(:call)
    continuation.call
  end
end

class Object
  def raise(exception = RuntimeError, string = nil, array = caller)
    return super if PryTime.data[:in_session]

    if exception.is_a?(String)
      string = exception
      exception = RuntimeError
    end

    ex = exception.exception(string)
    ex.set_backtrace(array)
    ex.exception_bindings = binding.callers.tap(&:shift)

    PryTime.data[:instance] = PryTime::Session.new(ex, PryTime.config, :raise)

    ret_val = nil
    if PryTime.data[:instance].should_capture_exception?
      ret_val = PryTime.data[:instance].start_session
    end

    if ret_val != :__continue__
      callcc do |cc|
        ex.continuation = cc
        super(ex)
      end
    end
  end
end
