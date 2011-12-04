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

require 'webrick'

ssl_cert, ssl_key, ca_cert = ARGV[0], ARGV[1], ARGV[2]

# Monkey patch bad User-Agent parsing
module WEBrick::AccessLog
  module_function

  def format(format_string, params)
    format_string.gsub(/\%(?:\{(.*?)\})?>?([a-zA-Z%])/){
      param, spec = $1, $2
      case spec[0]
      when ?e, ?i, ?n, ?o
        raise AccessLogError,
        "parameter is required for \"#{spec}\"" unless param
        if params[spec][param]
          escape(params[spec][param])
        else
          "-"
        end
      when ?t
        params[spec].strftime(param || CLF_TIME_FORMAT)
      when ?%
        "%"
      else
        escape(params[spec].to_s)
      end
    }
  end
end

logger = WEBrick::Log.new($stderr, WEBrick::Log::WARN)#WEBrick::Log::DEBUG
config = {}
config[:Port] = 7890
config[:Logger] = logger
config[:AccessLog] = [[$stdout, WEBrick::AccessLog::COMBINED_LOG_FORMAT]]
unless ssl_cert.nil? || ssl_key.nil?
  require 'webrick/https'
  config[:SSLEnable] = true
  # http://www.openssl.org/docs/ssl/SSL_CTX_set_verify.html#
  # SSL_VERIFY_FAIL_IF_NO_PEER_CERT
  # => Server mode: if the client did not return a certificate, the TLS/SSL handshake is immediately terminated with a 'handshake failure' alert.
  # => This flag must be used together with SSL_VERIFY_PEER.
  config[:SSLVerifyClient] = OpenSSL::SSL::VERIFY_PEER
  config[:SSLVerifyClient] |= OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT if ca_cert
  config[:SSLPrivateKey] = OpenSSL::PKey::RSA.new(File.open(ssl_key).read)
  config[:SSLCertificate] = OpenSSL::X509::Certificate.new(File.open(ssl_cert).read)
  # KHRVI: option config[:SSLCertName] does make sense only when config[:SSLCertificate] isn't specified
  # see: webrick/ssl.rb method :setup_ssl_context
  # config[:SSLCertName] = [["CN", "Graham Hughes"]]
  config[:SSLVerifyDepth] = 9
  config[:SSLCACertificateFile] = ca_cert if ca_cert
end
$stdout.sync = true
server = WEBrick::HTTPServer.new(config)

server.mount_proc('/good') {|req, resp|
  resp.status = 200
  resp['Content-Type'] = "text/plain"
  resp.body = "good"
}
intermittent_times = 0
server.mount_proc('/intermittent-hang') {|req, resp|
  intermittent_times += 1
  if intermittent_times % 2 == 1
    sleep 5
    resp.status = 403
    resp['Content-Type'] = "text/plain"
    resp.body = "bad"
  else
    resp.status = 200
    resp['Content-Type'] = "text/plain"
    resp.body = "good"
  end
}
server.mount_proc('/hang') {|req, resp|
  sleep 5
  resp.status = 200
  resp['Content-Type'] = "text/plain"
  resp.body = "good"
}
server.mount_proc('/ugly') {|req, resp|
  resp.status = 404
  resp['Content-Type'] = "text/plain"
  resp.body = "ugly"
}
server.mount_proc('/filename') {|req, resp|
  resp.status = 200
  resp['ETag'] = File.stat('filename').mtime
  resp['Content-Type'] = "text/plain"
  resp.body = File.open("filename").read
}

# trap signals to invoke shutdown cleanly
['INT', 'TERM'].each { |signal|
  trap(signal) { server.shutdown }
}

server.start
