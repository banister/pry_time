module PryTime
  class Config
    attr_accessor :predicate_proc
    attr_accessor :all_exceptions

    def self.option_builder(option_name)
      define_method(option_name) do
        instance_variable_set("@#{option_name}", []) if !instance_variable_get("@#{option_name}")
        instance_variable_get("@#{option_name}")
      end
    end

    [:from_method, :from_class, :exception_type].each do |v|
      option_builder(v)
    end
  end
end
