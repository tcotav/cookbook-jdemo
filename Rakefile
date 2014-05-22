require "foodcritic"
require "rspec/core/rake_task"
require "serverspec"

desc "Run Foodcritic lint checks"
FoodCritic::Rake::LintTask.new(:lint) do |t|
  t.options = { :fail_tags => ["correctness"] }
end

desc "Run ChefSpec examples"
RSpec::Core::RakeTask.new(:spec)
#RSpec::Core::RakeTask.new(:spec) do |t|
#  t.rspec_opts = %w[-f JUnit -o results.xml]
#end

desc "Run Server Spec examples"
RSpec::Core::RakeTask.new(:unit) do |t|
  t.pattern = "test/integration/default/serverspec/*_spec.rb"
end

desc "Run Docker Server Spec tests"
RSpec::Core::RakeTask.new(:docker) do |t|
  t.pattern = "test/integration/default/serverspec/localhost/*_spec.rb"
end

desc "Run all tests"
task :test => [:lint, :spec, :unit]
task :default => :test


begin
  require 'kitchen/rake_tasks'
  Kitchen::RakeTasks.new
rescue LoadError
  puts ">>>>> Kitchen gem not loaded, omitting tasks" unless ENV['CI']
end