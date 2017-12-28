
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "todo/version"

Gem::Specification.new do |spec|
  spec.name          = "todo"
  spec.version       = Todo::VERSION
  spec.authors       = ["Isaac Priestley"]
  spec.email         = ["progressions@gmail.com"]

  spec.summary       = %q{Simple CLI to manage todos}
  spec.description   = %q{Simple CLI to manage todos}
  spec.homepage      = "http://www.github.com/progressions/todo"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = ["todo"]
  spec.require_paths = ["lib", "lib/todoable/lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  # get an array of submodule dirs by executing 'pwd' inside each submodule
  gem_dir = File.expand_path(File.dirname(__FILE__)) + "/"
  `git submodule --quiet foreach pwd`.split($\).each do |submodule_path|
    Dir.chdir(submodule_path) do
      submodule_relative_path = submodule_path.sub gem_dir, ""
      # issue git ls-files in submodule's directory and
      # prepend the submodule path to create absolute file paths
      `git ls-files`.split($\).each do |filename|
        spec.files << "#{submodule_relative_path}/#{filename}"
      end
    end
  end
end
