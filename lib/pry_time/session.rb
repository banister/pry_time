module PryTime
  class Session

    attr_accessor :exception_bindings
    attr_accessor :backtrace

    attr_reader :pry_instance
    attr_reader :binding_index
    attr_reader :config

    def initialize(backtrace, exception_bindings, config, binding_index = 0)
      @backtrace          = backtrace
      @exception_bindings = exception_bindings
      @config             = config
      @binding_index      = binding_index
      @pry_instance       = Pry.new(pry_config)
    end

    def pry_config
      {
        :prompt => Pry::DEFAULT_PROMPT.map do |p|
          proc { |*args| "<Frame: #{binding_index}> #{p.call(*args)}" }
        end
      }
    end
    private :pry_config

    def should_capture_exception?
       config.from_class.include?(exception_bindings.first.eval("self.class")) &&
       config.from_method.include?(exception_bindings.first.eval("__method__")) &&
        config.exception_type.include?(exception_type)
    end

    def binding_index=(index)
      @binding_index = index
      pry_instance.binding_stack[-1] = exception_bindings[binding_index]
    end

    def start_session
      pry_instance.repl exception_bindings[binding_index]
    end
  end
end
