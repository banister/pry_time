require 'pry_time/commands'

module PryTime
  class Session

    attr_accessor :current_exception
    attr_accessor :session_type

    attr_reader :pry_instance
    attr_reader :binding_index
    attr_reader :config

    def initialize(current_exception, config, session_type, binding_index = 0)
      @current_exception  = current_exception
      @config             = config
      @binding_index      = binding_index
      @pry_instance       = Pry.new(pry_config)
      @session_type       = session_type
    end

    def exception_bindings
      current_exception.exception_bindings
    end

    def pry_config
      {
        :prompt => Pry::DEFAULT_PROMPT.map do |p|
          proc { |*args| "<Frame: #{binding_index}> #{p.call(*args)}" }
        end,

        :commands => Pry::CommandSet.new do
          import Pry::Commands
          import PryTime::PryTimeCommands
        end
      }
    end
    private :pry_config

    def should_capture_exception?
       config.from_class.include?(exception_bindings.first.eval("self.class")) ||
       config.from_method.include?(exception_bindings.first.eval("__method__")) ||
        config.exception_type.any? { |v| v === current_exception }
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
