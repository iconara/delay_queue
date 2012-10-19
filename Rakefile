# encoding: utf-8

require 'rspec/core/rake_task'


RSpec::Core::RakeTask.new(:spec)

desc 'Tag & release the gem'
task :release => :spec do
  project_name = Dir['*.gemspec'].first.scan(/^(.+)\.gemspec$/).flatten.first

  version = File.readlines("#{project_name}.gemspec").map { |line| line.scan(/version\s+=\D+([\d.]+)\D/).flatten.first }.compact.first
  version_string = "v#{version}"
  
  unless %x(git tag -l).include?(version_string)
    system %(git tag -a #{version_string} -m #{version_string})
  end

  system %(git push && git push --tags; gem build #{project_name}.gemspec && gem push #{project_name}-*.gem && mv #{project_name}-*.gem pkg)
end
