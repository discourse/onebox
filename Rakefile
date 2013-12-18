#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"
require "yard"
 
ENV["COVERALLS_NOISY"] = "true"
 
desc "Check all files for style guidelines"
Rubocop::RakeTask.new
 
desc "Run all the tests in spec"
RSpec::Core::RakeTask.new(:spec)
 
desc "Generate all of the docs"
YARD::Rake::YardocTask.new do |config|
  config.files = Dir["lib/**/*.rb"]
end
 
desc "Default: run tests and generate docs"
task default: [ :spec, :yard, :rubocop ]