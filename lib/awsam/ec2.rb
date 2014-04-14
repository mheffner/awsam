module Awsam
  module Ec2

    def self.find_instance(acct, instance_id, opts)
      logger = Logger.new(File.open("/dev/null", "w"))
      ec2 = RightAws::Ec2.new(acct.access_key, acct.secret_key, :logger => logger)
      
      unless ec2
        puts "Unable to connect to EC2"
        return nil
      end

      inst = find(ec2, instance_id, opts)
    end
    
    def self.find(ec2, instance_id, opts)
      if instance_id =~ /^i-[0-9a-f]{7,9}$/
        inst = find_by_instance_id(ec2, instance_id)
      else
        inst = find_by_tag(ec2, instance_id, opts)
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
    
    def self.find_by_tag(ec2, instance_id, opts)
      results = []
      
      ec2.describe_tags.each do |tag|
        if tag[:value].include?(instance_id) && tag[:resource_type] == "instance"
          results << tag
        end
      end

      if !results || results.length == 0
        puts "No tags by this name are available in your account"
        exit 1
      end
      
      results.uniq! { |a| a[:resource_id] }
      results.sort! { |a,b| a[:value] <=> b[:value] }
      
      if opts[:first_node]
        node = results.first
      else
        puts "Please select which node you wish to use:"

        results.each_with_index do |elem, i|
          puts "#{i}) #{elem[:value]} (#{elem[:resource_id]})"
        end
        
        print "> " 
        input = $stdin.gets
        node = results[input.to_i]
      end

      inst = ec2.describe_instances(node[:resource_id])

      if !inst || inst.length == 0
        puts "No instances available in account"
        return nil
      end

      return inst.first
    end
  end
end
