$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "worth_saving/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "worth_saving"
  s.version     = WorthSaving::VERSION
  s.authors     = ["John Lawrence"]
  s.email       = ["johnonrails@gmail.com"]
  s.homepage    = "https://github.com/johnnylaw/worth_saving"
  s.summary     = "Helps users of your app recover work by auto-saving drafts"
  s.description = "Helps users of your app recover work by auto-saving drafts"
  s.license     = 'MIT'

  s.files = Dir["{app,config,db,lib,vendor}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">=3.0.0"
  s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'database_cleaner', '~> 1.0.0'
  s.add_development_dependency "pry"
  s.add_development_dependency "slim"
  s.add_development_dependency "with_model", "~> 0.3.2"
  s.add_development_dependency "jasmine"
  s.add_development_dependency "jasmine-jquery-rails", "~>1.5"
  s.add_development_dependency "coveralls"
  s.add_development_dependency "tinymce-rails"
  s.add_development_dependency "ckeditor_rails"
  s.add_development_dependency "simple_form"

  s.test_files = Dir["spec/**/*"]
end
