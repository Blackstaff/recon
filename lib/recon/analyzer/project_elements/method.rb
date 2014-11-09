module Analyzer
  class Method
    attr_reader :name, :class_name, :lines
    #attr_accessor :lines

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
