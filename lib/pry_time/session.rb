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

    def current_frame_type
      exception_bindings[binding_index].frame_type
    end

    def pry_config
      {
        :prompt => Pry::DEFAULT_PROMPT.map do |p|
          proc { |*args| "<Frame: #{binding_index}/#{exception_bindings.size - 1} (#{current_frame_type})> #{p.call(*args)}" }
        end,

        :commands => Pry::CommandSet.new do
          import Pry::Commands
          import PryTime::PryTimeCommands
        end
      }
    end
    private :pry_config

    def exec_predicate_proc
      cur = self
      context = Object.new.tap do |obj|
        class << obj; self; end.class_eval do
          define_method(:exception) { cur.current_exception }
          define_method(:bindings) { cur.exception_bindings }
        end
      end

      context.instance_eval(&config.predicate_proc) if config.predicate_proc
    end

    def should_capture_exception?
      config.all_exceptions ||
        config.from_class.include?(exception_bindings.first.eval("self.class")) ||
       config.from_method.include?(exception_bindings.first.eval("__method__")) ||
        config.exception_type.any? { |v| v === current_exception } ||
        exec_predicate_proc
    end

    def binding_index=(index)
      if index > exception_bindings.size - 1
        pry_instance.output.puts "Warning: At top of stack, cannot go further!"
      elsif index < 0
        pry_instance.output.puts "Warning: At bottom of stack, cannot go further!"
      else
        @binding_index = index
        pry_instance.binding_stack[-1] = exception_bindings[binding_index]
        pry_instance.run_command "whereami"
      end
    end

    def start_session
      PryTime.data[:in_session]   = true
      begin
        pry_instance.repl exception_bindings[binding_index]
      ensure
        PryTime.data[:in_session] = false
      end
    end
  end
end
