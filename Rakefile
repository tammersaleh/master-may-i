require 'rubygems'
require 'rake'

# begin
#   require 'jeweler'
#   Jeweler::Tasks.new do |gem|
#     gem.name = "master_may_i"
#     gem.summary = %Q{Simple model based authorization designed to work with AuthLogic and InheritedResources}
#     gem.description = %Q{Simple model based authorization designed to work with AuthLogic and InheritedResources}
#     gem.email = "tsaleh@gmail.com"
#     gem.homepage = "http://tammersaleh.com/posts/master-may-i"
#     gem.authors = ["Tammer Saleh"]
#     gem.add_development_dependency "yard", ">= 0"
#     gem.add_development_dependency "shoulda", ">= 0"
#     gem.add_development_dependency "factory_girl", ">= 0"
#     gem.add_development_dependency "authlogic", ">= 2.1.1"
#     gem.add_development_dependency "inherited_resources", "~> 0.9.3"
#     gem.add_development_dependency "rails", ">= 0"
#   end
#   Jeweler::GemcutterTasks.new
# rescue LoadError
#   puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
# end

require 'rake/testtask'

task :default => :test

desc 'Run the tests.'
task :test => ["test:rails2", "test:rails3"]

namespace :test do
  task :rails2 do
    rails_root = File.join(File.dirname(__FILE__), 'test', 'rails2_root')
    system("cd #{rails_root} && rake")
  end

  task :rails3 do
    rails_root = File.join(File.dirname(__FILE__), 'test', 'rails3_root')
    system("cd #{rails_root} && rake")
  end
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


begin
  require 'active_support'
  require 'yard'
  YARD::Rake::YardocTask.new(:yard) do |t|
    t.files   = ["lib/**/*.rb", "shoulda_macros/*.rb"]
    t.options = ["--protected", 
                 "--private", 
                 "--title=\"Master May I?\"", 
                 "--readme=README.rdoc", 
                 "--output-dir=doc"]
  end
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
