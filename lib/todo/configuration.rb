require "yaml"

module Todo
  class << self
    def todorc
      if File.exists?(config_path)
        YAML.load_file(config_path)
      else
        {}
      end
    end

    private

    def config_path
      File.join(Dir.home, ".todorc")
    end
  end
end
