# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "tty/fzy/version"

Gem::Specification.new do |spec|
  spec.name          = "tty-fzy"
  spec.version       = TTY::Fzy::VERSION
  spec.authors       = "Nick Pezza"
  spec.email         = "npezza93@gmail.com"
  spec.license       = "MIT"
  spec.summary       = %q(Fuzzy find interface)

  spec.homepage = "https://github.com/npezza93/tty-fzy"
  spec.metadata["github_repo"] = "ssh://github.com/npezza93/tty-fzy"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.executables   = ["fuzzy", "fzy-ctags"]
  spec.require_paths = ["lib"]

  spec.add_dependency "fzy"
  spec.add_dependency "pastel"
  spec.add_dependency "tty-cursor"
  spec.add_dependency "tty-reader"

  spec.add_development_dependency "bundler", ">= 1.17", "< 3"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 10.0"
end
