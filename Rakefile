require "bundler/gem_tasks"
require "rspec/core/rake_task"

desc "Runs test suite"
task default: ['spec']

desc "Run all specs"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w[--color]
end