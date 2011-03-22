
module Awsam
  module Utils
    # Scan a directory yielding for each file
    def self.confdir_scan(dir)
      Dir.entries(dir).each do |name|
        next if name == '.' || name == '..'
        yield(name)
      end
    end
  end
end
