
module Awsam
  module Utils
    # Scan a directory yielding for each file
    def self.confdir_scan(dir)
      Dir.entries(dir).each do |name|
        next if name == '.' || name == '..' || name == Awsam::DEFAULT_LINK_NAME
        yield(name)
      end
    end

    # Unset each of the environ settings to clear the environ
    def self.bash_unset_environ(envs)
      envs.each_pair do |k, v|
        puts "unset #{k}"
      end
    end

    # Print the appropriate environment variables set commands for bash
    def self::bash_environ(envs, set_export = true)
      envs.each_pair do |k, v|
        puts "%s#{k}=\"#{v}\"" % [set_export ? "export " : ""]
      end
    end

    # Set the default resource with link directory and target
    def self.set_default(basedir, target)
      link = File.join(basedir, Awsam::DEFAULT_LINK_NAME)
      if File.exist?(link)
        begin
          FileUtils.rm(link)
        rescue => err
          $stderr.puts "Failed to remove link #{link}: #{err.message}"
          return false
        end
      end
      begin
        FileUtils.ln_s(target, link)
      rescue => err
        $stderr.puts "Failed to create symlink: #{err.message}"
        return false
      end
      true
    end

    # Get the target of the default link
    def self.get_default(basedir)
      link = File.join(basedir, Awsam::DEFAULT_LINK_NAME)
      File.exist?(link) ? File.readlink(link) : nil
    end

    # Remove the default link
    def self.remove_default(basedir)
      FileUtils.rm File.join(basedir, Awsam::DEFAULT_LINK_NAME)
    end
  end
end
