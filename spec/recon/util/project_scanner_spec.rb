require 'spec_helper'

describe ProjectScanner do
  describe '::scan' do
    it 'should scan the project directory' +
      ' and return paths to ruby source files when the path is correct and the directory has .rb files' do
      paths = ProjectScanner.scan(File.dirname(__FILE__) + '/../../test_projects')
      expect(paths).not_to be_empty
    end

    it 'should raise an exception when the project directory path is invalid' do
      expect { ProjectScanner.scan('a_directory')}.to raise_error
    end

    it 'should return empty array when no ruby files were found' do
      paths = ProjectScanner.scan(File.dirname(__FILE__) + '/../../test_projects/empty_project')
      expect(paths).to be_empty
    end
  end
end
