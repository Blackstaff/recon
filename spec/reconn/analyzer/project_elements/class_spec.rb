require 'spec_helper'

module Analizer
  describe Class do
    it 'is not valid without a name' do
      expect { Analizer::Class.new }.to raise_error
    end
  end
end
