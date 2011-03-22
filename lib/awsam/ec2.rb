require 'right_aws'

module Awsam
  module Ec2

    def self.find_instance(acct, instance_id)
      logger = Logger.new(File.open("/dev/null", "w"))
      ec2 = RightAws::Ec2.new(acct.access_key, acct.secret_key,
                              :logger => logger)
      unless ec2
        puts "Unable to connect to EC2"
        return nil
      end

      insts = ec2.describe_instances
      if !insts || insts.length == 0
        puts "No instances available in account"
        return nil
      end

      insts.each do |inst|
        return inst if inst[:aws_instance_id] == instance_id
      end

      return nil
    end
  end
end
