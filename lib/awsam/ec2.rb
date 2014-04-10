module Awsam
  module Ec2

    def self.find_instance(acct, instance_id)
      logger = Logger.new(File.open("/dev/null", "w"))
      ec2 = RightAws::Ec2.new(acct.access_key, acct.secret_key, :logger => logger)
      
      unless ec2
        puts "Unable to connect to EC2"
        return nil
      end

      inst = find(ec2, instance_id)
    end
    
    def self.find(ec2, instance_id)
      if instance_id =~ /^i-[0-9a-f]{7,9}$/
        inst = find_by_instance_id(ec2, instance_id)
      else
        inst = find_by_tag(ec2, instance_id)
      end
    end
    
    def self.find_by_instance_id(ec2, instance_id)
      begin
        inst = ec2.describe_instances(instance_id).first
      rescue RightAws::AwsError
        puts "instance_id does not exist"
        exit 1
      end
      
      return inst
    end
    
    def self.find_by_tag(ec2, instance_id)
      tag = ec2.describe_tags(:filters => { :value => instance_id })

      if !tag || tag.length == 0
        puts "No tags available in account"
        return nil
      end

      insts = ec2.describe_instances

      if !insts || insts.length == 0
        puts "No instances available in account"
        return nil
      end

      insts.each do |inst|
        return inst if inst[:aws_instance_id] == tag.first[:resource_id]
      end
    end
  end
end
