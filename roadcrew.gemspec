$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "roadcrew/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "roadcrew"
  s.version     = Roadcrew::VERSION
  s.authors     = ["matsuda"]
  s.email       = ["matsuda@halenohi.jp"]
  s.homepage    = ""
  s.summary     = "API Client for Garage"
  s.description = "API Client for Garage"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.5"
  s.add_dependency "oauth2"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec", "~> 3.0.0"
  s.add_development_dependency "tapp"
end
