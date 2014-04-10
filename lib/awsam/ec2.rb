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

      if instance_id =~ /^i-[0-9a-f]{7,9}$/
        begin
          inst = ec2.describe_instances(instance_id)[0]
        rescue RightAws::AwsError
          puts "instance_id does not exist"
          exit 1
        end
        
        return inst
      else
        tags = ec2.describe_tags
        if !tags || tags.length == 0
          puts "No tags available in account"
          return nil
        end

        tags.each do |tag|
          if tag[:value] == instance_id
            insts = ec2.describe_instances

            if !insts || insts.length == 0
              puts "No instances available in account"
              return nil
            end
            
            insts.each do |inst|
              return inst if inst[:aws_instance_id] == tag[:resource_id]
            end
          end
        end
      end
      
      return nil
    end
  end
end
