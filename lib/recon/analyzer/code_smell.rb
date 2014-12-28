module Analyzer
  class CodeSmell
    attr_reader :type, :class_name, :method_name

    def initialize(type, class_name = :none, method_name)
      @type = type
      @class_name = class_name
      @method_name = method_name
    end

    def to_s
      "Smell: #{@type.to_s} in Class: #{@class_name.to_s} "\
      "Method: #{@method_name.to_s}"
    end
  end
end
