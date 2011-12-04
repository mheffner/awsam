#--  -*- mode: ruby; encoding: utf-8 -*-
# Copyright: Copyright (c) 2011 RightScale, Inc.
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

Given /^a really dumb web server$/ do
  @subprocess_pids << fork do
    ENV['RACK_ENV'] = "test"
    Dir.chdir(@tmpdir)
    STDIN.close
    output = File.open("#{@tmpdir}/weblog.out", "w")
    STDOUT.reopen(output)
    exec "ruby",  File.expand_path(File.join(File.dirname(__FILE__), "..", "..",
                                             "spec/really_dumb_webserver.rb"))
  end
  Given "a server listening on port 7890"
end

Given /^a really dumb SSL enabled web server$/ do
  @subprocess_pids << fork do
    ENV['RACK_ENV'] = "test"
    Dir.chdir(@tmpdir)
    STDIN.close
    output = File.open("#{@tmpdir}/weblog.out", "w")
    STDOUT.reopen(output)
    exec("ruby",
         File.expand_path(File.join(File.dirname(__FILE__), "..", "..",
                                    "spec/really_dumb_webserver.rb")),
         File.expand_path(File.join(File.dirname(__FILE__), "..", "..",
                                    "spec/server.crt")),
         File.expand_path(File.join(File.dirname(__FILE__), "..", "..",
                                    "spec/server.key")))
  end
  Given "a server listening on port 7890"
end

Given /^a really dumb SSL handshake enabled web server$/ do
  @subprocess_pids << fork do
    ENV['RACK_ENV'] = "test"
    Dir.chdir(@tmpdir)
    STDIN.close
    output = File.open("#{@tmpdir}/weblog.out", "w")
    STDOUT.reopen(output)
    exec("ruby",
         File.expand_path(File.join(File.dirname(__FILE__), "..", "..",
                                    "spec/really_dumb_webserver.rb")),
         File.expand_path(File.join(File.dirname(__FILE__), "..", "..",
                                    "spec/server.crt")),
         File.expand_path(File.join(File.dirname(__FILE__), "..", "..",
                                    "spec/server.key")),
         File.expand_path(File.join(File.dirname(__FILE__), "..", "..",
                                    "spec/client/cacert.pem")))
  end
  Given "a server listening on port 7890"
end

Given /^a URL$/ do
  Given "a really dumb web server"
  @uri = URI.parse("http://127.0.0.1:7890/good")
  @expected_contents = "good"
end

Given /^a URL that hangs intermittently$/ do
  Given "a really dumb web server"
  Rightscale::HttpConnection.params[:http_connection_read_timeout] = 2
  @uri = URI.parse("http://127.0.0.1:7890/intermittent-hang")
  @expected_contents = "good"
end

Given /^a URL that hangs all the time$/ do
  Given "a really dumb web server"
  Rightscale::HttpConnection.params[:http_connection_read_timeout] = 2
  @uri = URI.parse("http://127.0.0.1:7890/hang")
  @expected_contents = "irrelevant"
end

Given /^a URL that fails intermittently$/ do
  pending "this seems to require custom server code"
end

Given /^a URL whose server is unreliable$/ do
  pending "this seems to require custom server code"
end

Given /^a URL that fails all the time$/ do
  pending "this seems to require custom server code"
end

Given /^a URL whose server is listening but always down$/ do
  pending "this seems to require custom server code"
end

