require 'find'

class ProjectScanner
  def self.scan(proj_path)
    paths = []
    begin
      Find.find(proj_path) do |path|
        if FileTest.directory?(path)
          if File.basename(path)[0] == '.'
            Find.prune
          end
        end
        if File.extname(path) == '.rb'
          paths << path
        end
      end
    rescue
      raise InvalidPathException, "Can't open the directory"
    end

    paths
  end
end
