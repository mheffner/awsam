require 'fileutils'

module Awsam
  class Key
    KEYFILE = "key.pem"

    attr_reader :name

    def initialize(keydir)
      @name = File.basename(keydir)
      @dir = keydir
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

    def remove
      FileUtils.rm(self.path)
      FileUtils.rmdir(@dir)
    end
  end
end
