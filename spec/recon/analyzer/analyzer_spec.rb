require 'spec_helper'

describe Analyzer do
  describe '#analyze' do
    before :all do
      @result = Analyzer::Analyzer.new.analyze(File.dirname(__FILE__) + '/../../../lib')
      @classes, @methods, @smells = @result
    end

    it 'returns an Array' do
      expect( @result.respond_to?(:to_ary) ).to be true
    end

    it 'returns classes data' do
      expect( @classes ).not_to be_empty
      expect( @classes.map {|x| x.name } ).to include('Analyzer')
    end

    it 'returns methods data' do
      expect( @methods ).not_to be_empty
      expect( @methods.map {|x| x.name } ).to include('analyze')
    end

    it 'calculates lines of code in classes' do
    end

    it 'calculates lines of code in methods' do
    end

    it 'finds dependencies between classes' do
    end
  end
end
