module Analyzer
  class Method
    attr_reader :name, :class_name
    attr_accessor :lines

    def initialize(name, class_name = :none)
      @name = name
      @class_name = class_name
    end

    def to_s
      name.to_s
    end

  end
end
