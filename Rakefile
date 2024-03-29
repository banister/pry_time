$:.unshift 'lib'

direc = File.expand_path(File.dirname(__FILE__))

PROJECT_NAME = "pry_time"

require "#{PROJECT_NAME}/version"

CLASS_NAME = PryTime

require 'rake/clean'
require 'rake/gempackagetask'

CLOBBER.include("**/*~", "**/*#*", "**/*.log", "**/*.o")
CLEAN.include("ext/**/*.log", "ext/**/*.o",
              "ext/**/*~", "ext/**/*#*", "ext/**/*.obj", "**/*#*", "**/*#*.*",
              "ext/**/*.def", "ext/**/*.pdb", "**/*_flymake*.*", "**/*_flymake")

def apply_spec_defaults(s)
  s.name = PROJECT_NAME
  s.summary = "A Pry-based error console."
  s.version = CLASS_NAME::VERSION
  s.date = Time.now.strftime '%Y-%m-%d'
  s.author = "John Mair (banisterfiend)"
  s.email = 'jrmair@gmail.com'
  s.description = s.summary
  s.require_path = 'lib'
  s.add_dependency("binding_of_caller","~>0.5.0")
  s.add_dependency("pry","~>0.9.7.4")
  s.add_development_dependency("bacon","~>1.1.0")
  s.homepage = "http://github.com/banister/#{PROJECT_NAME}"
  s.executables = ["pry_time"]
  s.has_rdoc = 'yard'
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- test/*`.split("\n")
end

desc "start a pry session with the library loaded"
task :pry do
  sh "pry -I./lib/ -r./lib/pry_time.rb"
end

desc "Run tests"
task :test do
  sh "bacon -Itest -rubygems test.rb -q"
end

desc "reinstall the gem locally for testing"
task :reinstall do
  sh "rake gems"
  sh "gem uninstall pry_time"
  sh "gem install #{direc}/pkg/pry_time-#{PryTime::VERSION}.gem"
end

desc "Show version"
task :version do
  puts "pry_time version: #{PryTime::VERSION}"
end

desc "Run example"
task :example do
  sh "ruby -I#{direc}/lib/ #{direc}/bin/pry_time #{direc}/examples/pry_die.rb"
end

namespace :ruby do
  spec = Gem::Specification.new do |s|
    apply_spec_defaults(s)
    s.platform = Gem::Platform::RUBY
  end

  Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_zip = false
    pkg.need_tar = false
  end
end

desc "build all platform gems at once"
task :gems => [:clean, :rmgems, "ruby:gem"]

task :gem => [:gems]

desc "remove all platform gems"
task :rmgems => ["ruby:clobber_package"]

desc "build and push latest gems"
task :pushgems => :gems do
  chdir("./pkg") do
    Dir["*.gem"].each do |gemfile|
      sh "gem push #{gemfile}"
    end
  end
end

