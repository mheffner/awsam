require 'yaml'
require 'fileutils'

require 'key'
require 'utils'

module Awsam
  class Account
    DEFAULT_REGION = "us-east-1"

    attr_reader :name, :keys

    def initialize(name, params)
      if name == Awsam::DEFAULT_LINK_NAME
        # We require this for our default account symlink
        raise "Can not name an account: #{Awsam::DEFAULT_LINK_NAME}"
      end
      @name = name
      @params = params

      @params[:aws_region] ||= DEFAULT_REGION

      load_keys
    end

    def self.load_from_disk(dir)
      name = File.basename(dir)
      conffile = File.join(dir, 'conf.yml')

      return nil unless File.exist?(conffile)

      File.open(conffile) do |yf|
        @conf = YAML::load(yf)
      end

      Account.new(name, @conf)
    end

    def load_keys
      @keys = Hash.new
      base = conf_file('keys')
      return unless File.exist?(base)
      Utils::confdir_scan(base) do |name|
        @keys[name] = Key.new(File.join(base, name))
      end
    end

    def print_unset_environ
      Utils::bash_unset_environ(get_environ)
    end

    def print_environ(set_export)
      Utils::bash_environ(get_environ, set_export)
    end

    def get_environ
      envs = {
        "AMAZON_ACCESS_KEY_ID"     => @params[:access_key],
        "AWS_ACCESS_KEY_ID"        => @params[:access_key],
        "AWS_ACCESS_KEY"           => @params[:access_key],

        "AMAZON_SECRET_ACCESS_KEY" => @params[:secret_key],
        "AWS_SECRET_ACCESS_KEY"    => @params[:secret_key],
        "AWS_SECRET_KEY"           => @params[:secret_key],

        "AMAZON_AWS_ID"            => @params[:aws_id],
        "AWS_DEFAULT_REGION"       => @params[:aws_region],

        "EC2_URL"                  => ec2_url
      }
    end

    def find_key(name)
      @keys[name]
    end

    def import_key(name, path)
      @keys[name] = Key.import(conf_file, name, path)
    end

    def remove_key(name)
      return false unless @keys.has_key?(name)

      dflt = get_default_key
      Utils::remove_default(conf_file('keys')) if dflt && dflt.name == name
      @keys[name].remove
      @keys.delete(name)
      true
    end

    def set_default_key(keyname)
      key = @keys[keyname]
      unless key
        $stderr.puts "No key named #{keyname}"
        return false
      end

      Utils::set_default(conf_file('keys'), keyname)
    end

    def get_default_key
      dflt = Utils::get_default(conf_file('keys'))
      @keys[dflt]
    end

    def remove
      dir = conf_file
      acct = Awsam::Accounts::get_default
      if acct && acct.name == @name
        # Need to remove default link if we're the default account
        Awsam::Accounts::remove_default
      end

      FileUtils.rm_rf(dir)
    end

    def save
      dir = File.join(Awsam::get_accts_dir, @name)
      FileUtils.mkdir(dir) unless File.exist?(dir)

      File.open(File.join(dir, 'conf.yml'), "w", 0600) do |out|
        YAML.dump(@params, out )
      end
    end

    # Export params...need better way to do this
    def desc
      @params[:description]
    end

    def access_key
      @params[:access_key]
    end

    def secret_key
      @params[:secret_key]
    end

    def aws_region
      @params[:aws_region]
    end

    def ec2_url
      "https://ec2.#{aws_region}.amazonaws.com"
    end

private

    def conf_file(file = nil)
      dir = File.join(Awsam::get_accts_dir(), @name)

      return file.nil? ? dir : File.join(dir, file)
    end
  end
end
