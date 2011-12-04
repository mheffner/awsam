$:.unshift File.join(File.dirname(__FILE__), 'awsam')

require 'fileutils'

$:.unshift File.join(File.dirname(__FILE__), '../vendor/right_aws/lib')
$:.unshift File.join(File.dirname(__FILE__), '../vendor/right_http_connection/lib')

require 'right_aws'

require 'accounts'
require 'ec2'

module Awsam
  CONF_BASE_DIR = ".awsam"
  CONF_DIR = File.join(ENV['HOME'], CONF_BASE_DIR)
  DEFAULT_LINK_NAME = ".default"

  def self.get_conf_dir
    FileUtils.mkdir(CONF_DIR) unless File.exist?(CONF_DIR)
    CONF_DIR
  end

  def self.get_accts_dir
    base = get_conf_dir()
    acctsdir = File.join(base, 'accts')
    FileUtils.mkdir(acctsdir) unless File.exist?(acctsdir)
    acctsdir
  end

  def self.init_awsam
    dir = get_conf_dir
    File.open(File.join(dir, "bash.rc"), "w") do |f|
      f << File.read(File.join(File.dirname(__FILE__), '../bashrc/rc.scr'))
    end

    puts
    puts "Initialized AWS Account Manager"
    puts
    puts "Add the following to your $HOME/.bashrc:"
    puts
    puts "  if [ -s $HOME/#{CONF_BASE_DIR}/bash.rc ]; then"
    puts "      source $HOME/#{CONF_BASE_DIR}/bash.rc"
    puts "  fi"
    puts
  end
end
