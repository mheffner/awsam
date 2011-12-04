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

Given /^a proxy on port (\d+) with arguments "(.*)"$/ do |port, args|
  arguments = Shellwords.shellsplit(args)
  @subprocess_pids << fork do
    ENV['RACK_ENV'] = "test"
    Dir.chdir(@tmpdir)
    STDIN.close
    output = File.open("#{@tmpdir}/proxy.out", "w")
    STDOUT.reopen(output)
    exec "ruby", File.expand_path(File.join(File.dirname(__FILE__), "..", "..",
                                            "spec/proxy_server.rb")), "--port", port, *arguments
  end
  Given "a server listening on port #{port}"
  @proxy_host = "localhost"
  @proxy_port = port
end

Given /^a proxy$/ do
  Given "a proxy on port 9090 with arguments \"\""
end

Given /^a proxy with a username and password$/ do
  Given "a proxy on port 9090 with arguments \"--username username --password password\""
  @proxy_username = "username"
  @proxy_password = "password"
end

Given /^a proxy that refuses CONNECT requests$/ do
  Given "a proxy on port 9090 with arguments \"--disable-connect\""
end

Given /^a proxy with the wrong username and password$/ do
  Given "a proxy with a username and password"
  @proxy_username = "wrong_username"
  @proxy_password = "wrong_password"
end
