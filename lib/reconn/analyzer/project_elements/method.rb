module Analyzer
  # Represents a method in the project
  class Method
    attr_reader :name, :class_name, :lines, :complexity

    include Comparable

    def ==(other)
      name == other.name && class_name == other.class_name
    end

    def initialize(name, class_name = :none, lines = 0, is_singleton = false)
      @name = name
      @class_name = class_name
      @lines = lines
      @complexity = 1
      @is_singleton = is_singleton
    end

    def to_s
      class_name.to_s + (is_singleton? ? "::" : "#")  + name.to_s
    end

    def incr_complexity
      @complexity += 1
    end

    def is_singleton?
      @is_singleton
    end

  end
end
