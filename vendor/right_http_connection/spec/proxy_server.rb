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

require 'rubygems'
require 'bundler/setup'
require 'trollop'
require 'webrick/httpproxy'
require 'webrick/httpauth'
require 'cgi'

# Patch broken WEBrick escape
module WEBrick::HTMLUtils
  def escape(string)
    CGI.escapeHTML(string.to_s)
  end
  module_function :escape
end

opts = Trollop::options do
  version "proxy_server 0.1 (c) 2011 RightScale, Inc."
  banner <<-EOS
Run a very simple proxy server for debugging.

Usage:
    proxy_server [options]
where [options] are:
EOS
  opt :username, "Username to use for authentication", :type => :string
  opt :password, "Password to use for authentication", :type => :string
  opt :port, "Port to use", :default => 9090
  opt :disable_connect, "Whether to disable using CONNECT through the proxy"
end

logger = WEBrick::Log.new($stderr, WEBrick::Log::WARN)
config = {}
config[:Port] = opts[:port]
config[:Logger] = logger
config[:AccessLog] = [[$stdout, WEBrick::AccessLog::COMBINED_LOG_FORMAT]]
config[:ProxyAuthProc] = Proc.new do |req, res|
  if opts[:disable_connect] && req.request_method == "CONNECT"
    raise WEBrick::HTTPStatus::Forbidden
  end

  unless opts[:username].nil? || opts[:password].nil?
    WEBrick::HTTPAuth.proxy_basic_auth(req, res, "Test realm") {|user, pass|
      user == opts[:username] && pass == opts[:password]
    }
  end
end
$stdout.sync = true
server = WEBrick::HTTPProxyServer.new(config)
['INT', 'TERM'].each {|signal|
  trap(signal) { server.shutdown }
}
server.start
