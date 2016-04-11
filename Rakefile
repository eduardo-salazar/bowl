require 'rake/testtask'
require './app'

task :default => [:spec]

desc 'Run all the tests'
Rake::TestTask.new(name=:spec) do |t|
  t.pattern = 'specs/*_spec.rb'
end