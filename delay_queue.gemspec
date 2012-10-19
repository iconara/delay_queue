$: << File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'delay_queue'
  s.version     = '1.1.0'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Theo Hultberg']
  s.email       = ['theo@burtcorp.com']
  s.homepage    = 'https://github.com/iconara/delay_queue'
  s.summary     = 'A TTL based priority queue'
  s.description = 'Delay queue keeps it\'s elements ordered by a timestamp, popping off the items with the lowest timestamp first'

  s.rubyforge_project = 'delay_queue'
  
  s.add_development_dependency 'rspec', '~> 2.5.0'

  s.files         = `git ls-files`.split("\n")
  # s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  # s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end