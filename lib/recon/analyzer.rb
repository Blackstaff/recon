# @author Mateusz Czarnecki <mateusz.czarnecki92@gmail.com>

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
      @current_class = Class.new(:none)
    end

    # Analyzes all the ruby files in the given directory and its subdirectories
    # @param dir [String] path to the directory
    # @return [Array(Array<Class>, Array<Method>, Array<CodeSmell>)] found classes,
    #  methods and code smells
    def analyze(dir)
      parser = RubyParser.new
      paths = ProjectScanner.scan(dir)
      paths.each do |path|
        @current_path = path
        ast = parser.process(File.binread(path), path)
        process ast
        @current_class = Class.new(:none)
      end

      @classes.each {|klass| klass.lines = count_lines_in_class(klass)}
      prune_dependencies

      return @classes, @methods, @smells
    end

    #########################################
    # Process methods:

    def process_class(exp)
      exp.shift
      class_name = exp.shift.to_s
        @current_class = Class.new(class_name)
        @classes << @current_class
        process_until_empty exp
        s()
    end

    def process_defn(exp)
      exp.shift
      method_name = exp.shift.to_s
      lines = count_lines_in_method(method_name)
      method = Method.new(method_name, @current_class.name, lines)
      @methods << method
      @current_class.add_method(method)
      exp.shift
      process_until_empty exp
      s()
    end

    def process_const(exp)
      exp.shift
      name = exp.shift.to_s
      is_class = !(Object.const_get(name) rescue nil).nil?
      @current_class.add_dependency(name) if is_class

      exp.shift
      process_until_empty exp
      s()
    end

    ########################################

    #Counts lines of code in a method
    #
    #@param method_name [String] the name of the method
    #@return [Integer] lines of code count
    def count_lines_in_method(method_name)
      flag = false
      lines = []
      File.foreach(@current_path) do |line|
        break if line =~ /def/ && flag
        lines << line if flag && line.strip != '' && line.strip[0] != '#'
        flag = true if line =~ /def #{method_name}/
      end

      lines.size
    end

    #Counts lines of code in a class (sums LOC of methods)
    #
    #@param klass [Class] the class
    #@return [Integer] lines of code count
    def count_lines_in_class(klass)
      lines = klass.methods.map {|method| method.lines}.inject(:+)
      lines.nil? ? 0 : lines
    end

    #Deletes dependencies which are not classes within analyzed project
    def prune_dependencies
      class_names = @classes.map {|klass| klass.name}
      @classes.each do |klass|
        klass.dependencies = klass.dependencies.uniq.keep_if {|dep| class_names.include?(dep)}
      end
    end

  end
end
