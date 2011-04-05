
module Awsam
  module Utils
    # Scan a directory yielding for each file
    def self.confdir_scan(dir)
      Dir.entries(dir).each do |name|
        next if name == '.' || name == '..'
        yield(name)
      end
    end

    # Print the appropriate environment variables set commands for bash
    def self::bash_environ(envs)
      envs.each_pair do |k, v|
        puts "export #{k}=\"#{v}\""
      end
    end
  end
end
