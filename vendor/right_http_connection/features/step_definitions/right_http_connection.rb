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

class RightHttpConnectionFailure < Exception
end

Given /^a captive logger$/ do
  @output = StringIO.new("", "w")
  @logger = Logger.new(@output)
end

Given /^the user agent \"([^\"]*)\"$/ do |ua|
  @user_agent = ua
end

When /^I request that URL using RightHTTPConnection$/ do
  Given "a captive logger"
  hash = {:logger => @logger, :exception => RightHttpConnectionFailure}
  hash[:user_agent] = @user_agent if @user_agent
  hash[:ca_file] = @ca_file if @ca_file
  hash[:cert_file] = @client_cert_file if @client_cert_file
  hash[:key_file] = @client_key_file if @client_key_file
  hash[:proxy_host] = @proxy_host if @proxy_host
  hash[:proxy_port] = @proxy_port if @proxy_port
  hash[:use_server_auth] = @use_server_auth if @use_server_auth

  hash[:proxy_username] = @proxy_username if @proxy_username
  hash[:proxy_password] = @proxy_password if @proxy_password
  hash[:fail_if_ca_mismatch] = true if @fail_if_ca_mismatch
  @connection = Rightscale::HttpConnection.new(hash)
  @request = Net::HTTP::Get.new(@uri.request_uri)
  @request["Host"] = "#{@uri.host}:#{@uri.port}"
  begin
    @result = @connection.request(:server => @uri.host, :port => @uri.port,
                                  :protocol => @uri.scheme, :request => @request)
  rescue RightHttpConnectionFailure => e
    @result = nil
    @exception = e
  end
end

RSpec::Matchers.define :have_no_errors_in do |logs|
  match do |connection|
    logs !~ /Rightscale::HttpConnection : request failure count: \d+, exception: .*$/
  end
  failure_message_for_should do |connection|
    "should have no errors, but saw one in the logs, which are as follows: #{logs}"
  end
  failure_message_for_should_not do |connection|
    "should have seen some kind of errors in the logs, but none occurred; logs are: #{logs}"
  end
end

Then /^I should get the contents of the URL$/ do
  @result.should be_kind_of(Net::HTTPSuccess)
  @result.body.should == @expected_contents
  @connection.should have_no_errors_in(@output.string)
end

Then /^I should get the contents of the URL eventually$/ do
  @result.should be_kind_of(Net::HTTPSuccess)
  @result.body.should == @expected_contents
  @connection.should_not have_no_errors_in(@output.string)
end

Then /^I should get an exception$/ do
  @result.should be_nil
  @exception.should_not be_nil
end

Then /^I should get told to authenticate correctly$/ do
  @result.should be_kind_of(Net::HTTPProxyAuthenticationRequired)
  @connection.should have_no_errors_in(@output.string)
end
