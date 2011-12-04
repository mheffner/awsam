#--  -*- mode: ruby; encoding: utf-8 -*-
# Copyright: Copyright (c) 2010 RightScale, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# 'Software'), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require 'rubygems'
require File.expand_path(File.join(File.dirname(__FILE__), 'lib', 'version'))

Gem::Specification.new do |spec|
  spec.name = 'right_http_connection'
  spec.rubyforge_project = 'rightscale'
  spec.version = RightHttpConnection::VERSION::STRING
  spec.authors = ['RightScale, Inc.']
  spec.email = 'rubygems@rightscale.com'
  spec.homepage = 'http://rightscale.rubyforge.org/'
  spec.summary = 'RightScale\'s robust HTTP/S connection module'
  spec.has_rdoc = true
  spec.rdoc_options = ['--quiet', '--main', 'README.txt', '--title',
                       'right_http_connection documentation', '--opname',
                       'index.html', '--line-numbers', '--inline-source']
  spec.extra_rdoc_files = ['README.txt']
  spec.required_ruby_version = '>= 1.8.7'
  spec.require_path = 'lib'

  spec.add_development_dependency('rake')
  spec.add_development_dependency('rspec', "~> 2.3")
  spec.add_development_dependency('cucumber', "~> 0.8")
  spec.add_development_dependency('flexmock', "~> 0.8.11")
  spec.add_development_dependency('trollop', "~> 1.16")

  spec.description = <<-EOF
Rightscale::HttpConnection is a robust HTTP/S library.  It implements a retry
algorithm for low-level network errors.

== FEATURES:

- provides put/get streaming
- does configurable retries on connect and read timeouts, DNS failures, etc.
- HTTPS certificate checking
EOF

  candidates = Dir.glob('{lib,spec}/**/*') + ['History.txt', 'Manifest.txt', 'README.txt', 'Rakefile',
                                              'right_http_connection.gemspec']
  spec.files = candidates.sort
end
