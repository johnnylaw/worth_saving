$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "worth_saving/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "worth_saving"
  s.version     = WorthSaving::VERSION
  s.authors     = ["John Lawrence"]
  s.email       = ["johnonrails@gmail.com"]
  s.homepage    = ""
  s.summary     = "Helps users recover work"
  s.description = "Helps users recover work"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency "rails", "~> 4.0.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "pry"
end
