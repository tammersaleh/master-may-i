require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "master_may_i"
    gem.summary = %Q{Super simple model based authorization designed to work with AuthLogic and InheritedResources}
    gem.description = %Q{Super simple model based authorization designed to work with AuthLogic and InheritedResources}
    gem.email = "tsaleh@gmail.com"
    gem.homepage = "http://github.com/tsaleh/master_may_i"
    gem.authors = ["Tammer Saleh"]
    gem.add_development_dependency "yard", ">= 0"
    gem.add_development_dependency "shoulda", ">= 0"
    gem.add_development_dependency "factory_girl", ">= 0"
    gem.add_development_dependency "authlogic", ">= 0"
    gem.add_development_dependency "inherited_resources", ">= 0"
    gem.add_development_dependency "rails", ">= 0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
# Rake::TestTask.new(:test) do |test|
#   test.libs << 'lib' << 'test'
#   test.pattern = 'test/**/test_*.rb'
#   test.verbose = true
# end
desc 'Run the tests.'
task :test do
  rails_root = File.join(File.dirname(__FILE__), 'test', 'rails_root')
  system("cd #{rails_root} && rake")
end


begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
