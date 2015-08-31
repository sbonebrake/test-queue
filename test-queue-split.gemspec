require_relative 'lib/test_queue/version'

spec = Gem::Specification.new do |s|
  s.name        = 'test-queue-split'
  s.version     = TestQueue::VERSION
  s.date        = TestQueue::DATE
  s.summary     = 'parallel test runner'
  s.description = 'minitest/rspec parallel test runner for CI environments'

  s.homepage = 'http://github.com/tmm1/test-queue'

  s.authors = ['Aman Gupta']
  s.email   = 'ruby@tmm1.net'
  s.license = 'MIT'

  s.has_rdoc = false
  s.bindir   = 'bin'
  s.executables << 'rspec-queue'
  s.executables << 'minitest-queue'
  s.executables << 'testunit-queue'
  s.executables << 'cucumber-queue'

  s.add_development_dependency 'rspec', '>= 2.13', '< 4.0'
  s.add_development_dependency 'cucumber', '~> 1.3.10'
  s.add_development_dependency 'appium_thor', '~> 1.0.1'

  s.files = `git ls-files`.split("\n")
end
