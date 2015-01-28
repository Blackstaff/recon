module Analyzer
  # Represents a class in the project
  class Class
    attr_reader :name, :methods
    attr_accessor :lines, :complexity, :dependencies

    include Comparable

    def <=>(other)
      lines <=> other.lines
    end

    def initialize(name)
      @name = name
      @dependencies = []
      @methods = []
      @lines = 0
      @complexity = 0
    end

    def add_dependency(class_name)
      @dependencies << class_name.to_s
    end

    def add_method(method_name)
      @methods << method_name
    end

    def methods_number
      methods.size
    end

    def to_s
      name.to_s
    end

  end
end
