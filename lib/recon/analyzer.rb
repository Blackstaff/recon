# @author Mateusz Czarnecki <mateusz.czarnecki92@gmail.com>

require 'ruby_parser'
require 'sexp_processor'
require_relative 'util/project_scanner'
require_relative 'analyzer/project_elements/class.rb'
require_relative 'analyzer/project_elements/method.rb'
require 'pp' #DELETE

module Analyzer
  class Analyzer < MethodBasedSexpProcessor

    MAX_METHOD_LENGTH = 10
    MAX_COMPLEXITY = 6

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

      @classes.each do |klass|
        klass.lines = count_lines_in_class(klass)
        klass.complexity = count_complexity_in_class(klass)
      end
      prune_dependencies

      # Deletes empty classes
      # @classes.delete(Class.new(:none))

      @smells = find_code_smells

      #pp @classes.map {|c| "#{c.name} => #{c.dependencies}"}

      return @classes, @methods, @smells
    end

    #########################################
    # Process methods:

    def process_class(exp)
      exp.shift
      in_klass(exp.shift) do
        @current_class = Class.new(klass_name)
        @classes << @current_class
        process_until_empty exp
      end

      @current_class = Class.new(:none)
      s()
    end

    def process_defn(exp)
      exp.shift
      method_name = exp.shift.to_s
      lines = count_lines_in_method(method_name)
      @current_method = Method.new(method_name, @current_class.name, lines)
      exp.shift
      process_until_empty exp

      @methods << @current_method
      @current_class.add_method(@current_method)
      @current_method = Method.new(:none)
      s()
    end

    def process_defs(exp)
      exp.shift
      process_defn(exp)
    end

    def process_colon2(exp)
      exp.shift
      name = exp.flatten
      name.delete :colon2
      name.delete :const
      name = name.join("::")
      @current_class.add_dependency(name)
      exp.shift
      process_until_empty exp

      s()
    end

    def process_const(exp)
      exp.shift
      name = exp.shift.to_s
      @current_class.add_dependency(name)
      exp.shift
      process_until_empty exp

      s()
    end

    def process_if(exp)
      exp.shift
      process_until_empty exp

      @current_method.incr_complexity unless @current_method.nil?
      s()
    end
    alias process_for process_if
    alias process_when process_if
    alias process_until process_if
    alias process_while process_if
    alias process_rescue process_if
    alias process_and process_if
    alias process_or process_if

    ########################################

    #Counts lines of code in a method
    #
    #@param method_name [String] the name of the method
    #@return [Integer] lines of code count
    def count_lines_in_method(method_name)
      method_name = method_name.gsub(/[\.\|\(\)\[\]\{\}\+\\\^\$\*\?]/) {|match| '\\' + match}
      flag = false
      lines = []
      File.foreach(@current_path) do |line|
        break if line =~ /def/ && flag
        lines << line if flag && line.strip != '' && line.strip[0] != '#'
        flag = true if line =~ /def #{method_name}/ || line =~ /def self.#{method_name}/
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

    def count_complexity_in_class(klass)
      complexity = klass.methods.map {|method| method.complexity}.inject(:+)
      complexity.nil? ? 0 : complexity
    end

    #Deletes dependencies which are not classes within analyzed project
    def prune_dependencies #TODO correct
      class_names = @classes.map {|klass| klass.name}
      @classes.each do |klass|
        klass.dependencies =  klass.dependencies.map do |dep|
          dep_split = dep.split('::')
          klass_split = klass.name.split('::')
          klass_split.pop(dep_split.size)
          (klass_split + dep_split).join('::')
        end
        klass.dependencies = klass.dependencies.uniq.keep_if {|dep| class_names.include?(dep)}
      end
    end

    def find_code_smells
      code_smells = []
      @methods.each do |method|
        if method.lines > MAX_METHOD_LENGTH
          code_smells << CodeSmell.new(:too_big_method, method.class_name, method.name)
        end
        if method.complexity > MAX_COMPLEXITY
          code_smells << CodeSmell.new(:too_complex_method, method.class_name, method.name)
        end
      end
      code_smells
    end

  end
end
