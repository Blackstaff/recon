module Analyzer
  # Represents a method in the project
  class Method
    attr_reader :name, :class_name, :lines

    include Comparable

    def <=>(other)
      lines <=> other.lines
    end

    def initialize(name, class_name = :none, lines = 0)
      @name = name
      @class_name = class_name
      @lines = lines
    end

    def to_s
      name.to_s
    end

  end
end
