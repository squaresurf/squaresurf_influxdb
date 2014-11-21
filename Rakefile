task default: 'test:all'

namespace :test do
  desc 'Run all tests.'
  task all: [:chefspec, :foodcritic, :rubocop, :kitchen_test]

  desc 'Run chefspec.'
  task :chefspec do
    sh 'rspec --color'
  end

  desc 'Run foodcritic linter against cookbook.'
  task :foodcritic do
    sh 'thor foodcritic:lint -f any'
  end

  desc 'This is here as a convenience so that the test suite will check '\
    'kitchen as well as the other tests.'
  task :kitchen_test do
    sh 'kitchen test'
  end

  desc 'Run rubocop against cookbook ruby files.'
  task :rubocop do
    sh 'rubocop'
  end
end
