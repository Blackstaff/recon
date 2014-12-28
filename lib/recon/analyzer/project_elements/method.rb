module Analyzer
  # Represents a method in the project
  class Method
    attr_reader :name, :class_name, :lines, :complexity

    include Comparable

    def <=>(other)
      lines <=> other.lines
    end

    def initialize(name, class_name = :none, lines = 0)
      @name = name
      @class_name = class_name
      @lines = lines
      @complexity = 1
    end

    def to_s
      name.to_s
    end

    def incr_complexity
      @complexity += 1
    end

  end
end
