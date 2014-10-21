require 'ruby_parser'
require 'sexp_processor'
require_relative 'util/project_scanner'
require_relative 'analyzer/project_elements/class.rb'
require_relative 'analyzer/project_elements/method.rb'

module Analyzer
  class Analyzer < MethodBasedSexpProcessor
    def initialize
      super()
      self.auto_shift_type = false
      @classes = []
      @methods = []
      @smells = []
      @current_class = :none
    end

    def analyze(dir)
      parser = RubyParser.new
      paths = ProjectScanner.scan(dir)
      paths.each do |path|
        ast = parser.process(File.binread(path), path)
        process ast
        @current_class = :none
      end

      return @classes, @methods, @smells
    end

    #########################################
    # Process methods:

    def process_class(exp)
      class_name = exp.shift.to_s
      @classes << Class.new(class_name)
      @current_class = class_name
      exp.shift
      exp.shift
      process_until_empty exp
      s()
    end

    def process_defn(exp)
      method_name = exp.shift.to_s
      @methods << Method.new(method_name, @current_class)
      exp.shift
      exp.shift
      process_until_empty exp
      s()
    end

    def process_if(exp)
      s()
    end

  end
end
