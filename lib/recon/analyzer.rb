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
        @current_path = path
        ast = parser.process(File.binread(path), path)
        process ast
        @current_class = :none
      end

      return @classes, @methods, @smells
    end

    #########################################
    # Process methods:

    def process_class(exp)
      exp.shift
      class_name = exp.shift.to_s
      @classes << Class.new(class_name)
      @current_class = class_name
      exp.shift
      process_until_empty exp
      s()
    end

    def process_defn(exp)
      exp.shift
      method_name = exp.shift.to_s
      lines = count_lines_in_method(method_name)
      print "#{method_name} => #{lines} \n"
      @methods << Method.new(method_name, @current_class, lines)
      exp.shift
      process_until_empty exp
      s()
    end

    def process_if(exp)
      s()
    end

    ########################################

    def count_lines_in_method(method_name)
      flag = false
      lines = []
      File.foreach(@current_path) do |line|
        break if line =~ /def/ && flag
        lines << line if flag
        flag = true if line =~ /def #{method_name}/
      end

      lines.size
    end

  end
end
