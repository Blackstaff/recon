# @author Mateusz Czarnecki <mateusz.czarnecki92@gmail.com>

require 'ruby_parser'
require 'sexp_processor'

module Reconn
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

      merged_classes = merge_duplicate_classes
      @classes = merged_classes unless merged_classes.nil?

      @classes.each do |klass|
        klass.lines = count_lines_in_class(klass)
        klass.complexity = count_complexity_in_class(klass)
      end
      prune_dependencies
      find_external_dependencies(paths)

      # Deletes empty classes
      #@classes.delete(Class.new(:none))

      @smells = find_code_smells

      return @classes, @methods, @smells
    end

    #########################################
    # Process methods:

    def process_class(exp)
      exp.shift
      in_klass(exp.shift) do
        @current_class = Class.new(klass_name, [@current_path.to_s])
        @classes << @current_class
        process_until_empty exp
      end

      @current_class = Class.new(:none)
      s()
    end

    def process_defn(exp)
      is_singleton = exp.shift.to_s == "defn" ? false : true
      method_name = exp.shift.to_s
      lines = count_lines_in_method(method_name)
      @current_method = Method.new(method_name, @current_path.to_s, @current_class.name, lines, is_singleton)
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
    def prune_dependencies
      class_names = @classes.map {|klass| klass.name}
      @classes.each do |klass|
        klass.dependencies =  klass.dependencies.map do |dep|
          dep_split = dep.split('::')
          if class_names.include?(dep)
            next dep
          end
          klass_split = klass.name.split('::')
          if klass_split.size != dep_split.size
            klass_split.pop(dep_split.size)
          else
            klass_split.pop(dep_split.size - 1)
          end
          (klass_split + dep_split).join('::')
        end
        klass.dependencies = klass.dependencies.uniq.keep_if {|dep| dep != klass.name && class_names.include?(dep)}
      end
    end

    def merge_duplicate_classes
      duplicates = @classes.group_by {|c| c.name}.select {|k, v| v.size > 1}.values
      if !duplicates.empty?
        merged_dups = []
        duplicates.each do |dup|
          merged_dups << dup.inject(:+)
        end
        @classes.uniq {|c| c.name}.each do |klass|
          klass = merged_dups.find {|d| d == klass} if merged_dups.include?(klass)
        end
      end
    end

    def find_external_dependencies(paths)
      @classes.each do |klass|
        external_deps = []
        klass.filepaths.each do |path|
          File.foreach(path) do |line|
            line.strip!
            if line =~ /^require .*$/
              dep = line.split(" ")[1].gsub(/([\"\'])/, "")
              external_deps << dep if !paths.find {|p| p.to_s =~ /.*#{dep}.*/}
            else
              next
            end
          end
        end
        klass.external_deps = external_deps
      end
    end

    def find_code_smells
      code_smells = []
      @methods.each do |method|
        if method.lines > MAX_METHOD_LENGTH
          code_smells << CodeSmell.new(:too_big_method, method)
        end
        if method.complexity > MAX_COMPLEXITY
          code_smells << CodeSmell.new(:too_complex_method, method)
        end
      end
      code_smells
    end

  end
end
end
