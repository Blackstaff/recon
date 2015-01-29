module Reconn
  module Analyzer
    class CodeSmell
      attr_reader :type, :method

      def initialize(type, method)
        @type = type
        @method = method
      end

      def to_s
        "Smell: #{@type.to_s} in #{@method.to_s} in file: #{method.filepath}"
      end
    end
  end
end
