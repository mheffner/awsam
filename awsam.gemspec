# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'awsam/version'

Gem::Specification.new do |spec|
  spec.name          = "awsam"
  spec.version       = Awsam::VERSION
  spec.authors       = ["Mike Heffner"]
  spec.email         = ["mikeh@fesnel.com"]
  spec.summary       = %q{Amazon Web Services Account Manager}
  spec.description   = %q{Amazon Web Services Account Manager (modeled after 'rvm')}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'right_aws', '3.1.0'
  spec.add_dependency 'trollop', '2.0'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
