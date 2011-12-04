require 'rubygems'
require 'bundler'
Bundler::GemHelper.install_tasks
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/contrib/rubyforgepublisher'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'fileutils'
include FileUtils
require File.join(File.dirname(__FILE__), 'lib', 'right_http_connection')

Bundler::GemHelper.install_tasks

# == Gem == #

gemtask = Rake::GemPackageTask.new(Gem::Specification.load("right_http_connection.gemspec")) do |package|
  package.package_dir = ENV['PACKAGE_DIR'] || 'pkg'
  package.need_zip = true
  package.need_tar = true
end

directory gemtask.package_dir

CLEAN.include(gemtask.package_dir)

desc 'Generate website files'
task :website_generate do
  Dir['website/**/*.txt'].each do |txt|
    sh %{ ruby scripts/txt2html #{txt} > #{txt.gsub(/txt$/,'html')} }
  end
end

desc 'Upload website files to rubyforge'
task :website_upload do
  config = YAML.load(File.read(File.expand_path("~/.rubyforge/user-config.yml")))
  host = "#{config["username"]}@rubyforge.org"
  remote_dir = "/var/www/gforge-projects/#{RUBYFORGE_PROJECT}/"
  # remote_dir = "/var/www/gforge-projects/#{RUBYFORGE_PROJECT}/#{GEM_NAME}"
  local_dir = 'website'
  sh %{rsync -av #{local_dir}/ #{host}:#{remote_dir}}
end

desc 'Generate and upload website files'
task :website => [:website_generate, :website_upload]

desc 'Release the website and new gem version'
task :deploy => [:check_version, :website, :release]

task :check_version do
  unless ENV['VERSION']
    puts 'Must pass a VERSION=x.y.z release version'
    exit
  end
  unless ENV['VERSION'] == VERS
    puts "Please update your version.rb to match the release version, currently #{VERS}"
    exit
  end
end

task :default => 'spec'

# == Unit Tests == #

desc "Run unit tests"
RSpec::Core::RakeTask.new

namespace :spec do
  desc "Run unit tests with RCov"
  RSpec::Core::RakeTask.new(:rcov) do |t|
    t.rcov = true
    t.rcov_opts = %q[--exclude "spec"]
  end

  desc "Print Specdoc for unit tests"
  RSpec::Core::RakeTask.new(:doc) do |t|
    t.rspec_opts = ["--format", "documentation"]
  end
end

# == Functional tests == #
desc "Run functional tests"
Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = %w{--color --format pretty}
end
