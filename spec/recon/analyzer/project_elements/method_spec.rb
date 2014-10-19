require 'spec_helper'

module Analyzer
  describe Method do
    it 'is not valid without a name' do
      expect { Method.new }.to raise_error
    end
  end
end
