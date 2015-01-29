module Reconn
module Analyzer
  # Represents a class in the project
  class Class
    attr_reader :name, :methods, :filepaths
    attr_accessor :lines, :complexity, :dependencies

    include Comparable

    def ==(other)
      name == other.name
    end

    def initialize(name, filepaths = [])
      @name = name
      @filepaths = filepaths
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

    def +(other)
      other.methods.each do |method|
        if !@methods.index(method)
          @methods << method
        end
      end
      @dependencies += other.dependencies
      @filepaths += other.filepaths
      self
    end

    def to_s
      name.to_s
    end

  end
end
end
