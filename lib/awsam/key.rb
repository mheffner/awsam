require 'fileutils'

module Awsam
  class Key
    KEYFILE = "key.pem"

    attr_reader :name

    def initialize(keydir)
      @name = File.basename(keydir)
      @dir = keydir
      if @name == Awsam::DEFAULT_LINK_NAME
        # This is required for the default link
        raise "Can not name a key: #{Awsam::DEFAULT_LINK_NAME}"
      end
    end

    def path
      File.join(@dir, KEYFILE)
    end

    def self.import(acctdir, key_name, key_file)
      dir = File.join(Key::keys_dir(acctdir), key_name)
      FileUtils.mkdir(dir) unless File.exist?(dir)

      File.open(File.join(dir, KEYFILE), "w", 0400) do |f|
        f << File.read(key_file)
      end

      Key.new(dir)
    end

    def self.keys_dir(base)
      dir = File.join(base, "keys")
      FileUtils.mkdir(dir) unless File.exist?(dir)
      dir
    end

    def print_environ
      envs = {
        "AMAZON_SSH_KEY_NAME" => @name,
        "AMAZON_SSH_KEY_FILE" => self.path
      }

      Utils::bash_environ(envs)
    end

    def remove
      FileUtils.rm(self.path)
      FileUtils.rmdir(@dir)
    end
  end
end
