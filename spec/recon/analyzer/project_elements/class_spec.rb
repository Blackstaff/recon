require 'spec_helper'

describe Class do
  it 'is not valid without a name' do
    expect { Class.new }.to raise_error
  end
end
