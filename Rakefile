# frozen_string_literal: true

require 'rubocop/rake_task'
require 'rake/testtask'

RuboCop::RakeTask.new

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'app'
  t.test_files = FileList['test/**/*_test.rb']
end
