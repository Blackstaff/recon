module Analyzer
  class Class
    attr_reader :name, :dependencies, :methods
    attr_accessor :lines

    def initialize(name)
      @name = name
      @dependencies = []
      @methods = []
    end

    def add_dependency(class_name)
      @dependencies << class_name
    end

    def add_method(method_name)
      @methods << method_name
    end

  end
end
