require 'spec_helper'

describe ProjectScanner do
  describe '::scan' do
    it 'should scan the project directory' +
    ' and return paths to ruby source files' do
      paths = ProjectScanner.scan(__FILE__)
      expect(paths).not_to be_empty
    end
    it ' should raise an exception if the project directory path is invalid' do
      expect { ProjectScanner.scan('a_directory')}.to raise_error
    end
  end
end
