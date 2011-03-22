
module Awsam
  class Key
    attr_reader :name, :path

    def initialize(keydir)
      @name = File.basename(keydir)
      @path = File.join(keydir, "key.pem")
    end

    def self.import(acctdir, key_name, key_file)
      dir = File.join(Key::keys_dir(acctdir), key_name)
      FileUtils.mkdir(dir) unless File.exist?(dir)

      File.open(File.join(dir, "key.pem"), "w", 0400) do |f|
        f << File.read(key_file)
      end

      Key.new(dir)
    end

    def self.keys_dir(base)
      dir = File.join(base, "keys")
      FileUtils.mkdir(dir) unless File.exist?(dir)
      dir
    end
  end
end
